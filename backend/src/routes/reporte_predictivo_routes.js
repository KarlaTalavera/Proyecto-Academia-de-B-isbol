const router = require('express').Router()
const { verificarToken } = require('../middlewares/auth')
const { soloRoles } = require('../middlewares/roles')
const db = require('../config/database')

// ── Middleware base: verificar token en todas las rutas ──────────────────────
router.use(verificarToken)

// ══════════════════════════════════════════════════════════════════════════════
// 1. PROYECCIÓN FINANCIERA
//    Usa regresión lineal simple sobre los ingresos históricos por mes
//    para proyectar los próximos N meses.
// ══════════════════════════════════════════════════════════════════════════════
router.get('/proyeccion-financiera', soloRoles('administrador'), async (req, res) => {
  try {
    const { temporada, mesesProyeccion = 3 } = req.query
    if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })

    // Ingresos reales agrupados por mes
    const [ingresosHistoricos] = await db.query(
      `SELECT
         DATE_FORMAT(fecha_ingreso, '%Y-%m') AS periodo,
         MIN(fecha_ingreso)                  AS fecha_inicio,
         SUM(valor)                          AS total_ingresos
       FROM ingreso
       WHERE id_temporada = ?
       GROUP BY periodo
       ORDER BY fecha_inicio ASC`,
      [temporada]
    )

    // Egresos reales agrupados por mes
    const [egresosHistoricos] = await db.query(
      `SELECT
         DATE_FORMAT(fecha_egreso, '%Y-%m') AS periodo,
         MIN(fecha_egreso)                  AS fecha_inicio,
         SUM(gasto)                         AS total_egresos
       FROM egreso
       WHERE id_temporada = ?
       GROUP BY periodo
       ORDER BY fecha_inicio ASC`,
      [temporada]
    )

    // Combinar en un único mapa de periodos
    const mapa = {}
    for (const r of ingresosHistoricos) {
      mapa[r.periodo] = { periodo: r.periodo, fecha_inicio: r.fecha_inicio,
                          total_ingresos: Number(r.total_ingresos), total_egresos: 0 }
    }
    for (const r of egresosHistoricos) {
      if (!mapa[r.periodo]) mapa[r.periodo] = { periodo: r.periodo, fecha_inicio: r.fecha_inicio,
                                                 total_ingresos: 0, total_egresos: 0 }
      mapa[r.periodo].total_egresos = Number(r.total_egresos)
    }

    const historico = Object.values(mapa).sort((a, b) => a.periodo.localeCompare(b.periodo))
    const n = historico.length

    if (n < 2) {
      return res.json({ historico, proyeccion: [], mensaje: 'Se necesitan al menos 2 meses de datos para proyectar.' })
    }

    // Regresión lineal simple: y = a + b*x   (x = índice 0..n-1)
    function regresionLineal(valores) {
      const n = valores.length
      const sumX  = (n * (n - 1)) / 2
      const sumX2 = (n * (n - 1) * (2 * n - 1)) / 6
      const sumY  = valores.reduce((s, v) => s + v, 0)
      const sumXY = valores.reduce((s, v, i) => s + i * v, 0)
      const b = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
      const a = (sumY - b * sumX) / n
      return { a, b }
    }

    const valoresIngresos = historico.map(h => h.total_ingresos)
    const valoresEgresos  = historico.map(h => h.total_egresos)
    const regI = regresionLineal(valoresIngresos)
    const regE = regresionLineal(valoresEgresos)

    // Último mes del histórico → sumarle meses para proyectar
    const ultimoPeriodo = historico[n - 1].periodo
    const [anioBase, mesBase] = ultimoPeriodo.split('-').map(Number)

    const proyeccion = []
    for (let k = 1; k <= Number(mesesProyeccion); k++) {
      const xIdx = n - 1 + k
      const ingresoProyectado = Math.max(0, Math.round(regI.a + regI.b * xIdx))
      const egresoProyectado  = Math.max(0, Math.round(regE.a + regE.b * xIdx))

      let mes  = mesBase + k
      let anio = anioBase
      while (mes > 12) { mes -= 12; anio++ }

      const MESES = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic']
      proyeccion.push({
        periodo: `${anio}-${String(mes).padStart(2, '0')}`,
        etiqueta: `${MESES[mes - 1]} ${anio}`,
        total_ingresos: ingresoProyectado,
        total_egresos:  egresoProyectado,
        balance:        ingresoProyectado - egresoProyectado,
        es_proyeccion:  true,
      })
    }

    // Enriquecer histórico con balance y etiqueta
    const MESES = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic']
    const historicoEnriquecido = historico.map(h => {
      const [a, m] = h.periodo.split('-').map(Number)
      return {
        ...h,
        etiqueta: `${MESES[m - 1]} ${a}`,
        balance: h.total_ingresos - h.total_egresos,
        es_proyeccion: false,
      }
    })

    // Métricas de tendencia
    const tendenciaIngresos = regI.b >= 0 ? 'creciente' : 'decreciente'
    const tendenciaEgresos  = regE.b >= 0 ? 'creciente' : 'decreciente'
    const porcentajeCambioIngresos = valoresIngresos[0]
      ? ((valoresIngresos[n - 1] - valoresIngresos[0]) / valoresIngresos[0] * 100).toFixed(1)
      : 0

    res.json({
      historico: historicoEnriquecido,
      proyeccion,
      tendencia: {
        ingresos: tendenciaIngresos,
        egresos:  tendenciaEgresos,
        cambio_ingresos_pct: Number(porcentajeCambioIngresos),
        pendiente_ingresos:  Math.round(regI.b),
        pendiente_egresos:   Math.round(regE.b),
      },
    })
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: 'Error al generar proyección financiera' })
  }
})

// ══════════════════════════════════════════════════════════════════════════════
// 2. PREDICCIÓN DE RENDIMIENTO DE JUGADORES
//    Analiza la trayectoria de cada jugador partido a partido y calcula
//    tendencia de mejora/declive + proyección del próximo partido.
// ══════════════════════════════════════════════════════════════════════════════
router.get('/prediccion-jugadores', soloRoles('administrador', 'dueno'), async (req, res) => {
  try {
    const { temporada, tipo = 'bateadores', limite = 20 } = req.query
    if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })

    if (tipo === 'bateadores') {
      const [rows] = await db.query(
        `SELECT
           j.id_jugador,
           CONCAT(j.nombre, ' ', j.apellido)              AS jugador,
           e.nombre_equipo,
           p.fecha_juego,
           d.turnos_al_bate,
           d.hits,
           d.jonrones,
           d.carreras_impulsadas,
           d.carreras,
           ROUND(d.hits / NULLIF(d.turnos_al_bate, 0), 3) AS ave_partido
         FROM desempeno_bateador d
         JOIN jugador j ON d.id_jugador = j.id_jugador
         JOIN equipo  e ON d.id_equipo  = e.id_equipo
         JOIN partido p ON d.id_partido = p.id_partido
         WHERE p.id_temporada = ?
           AND d.turnos_al_bate > 0
         ORDER BY j.id_jugador, p.fecha_juego ASC`,
        [temporada]
      )

      const jugadoresMap = {}
      for (const r of rows) {
        if (!jugadoresMap[r.id_jugador]) {
          jugadoresMap[r.id_jugador] = {
            id_jugador:    r.id_jugador,
            jugador:       r.jugador,
            nombre_equipo: r.nombre_equipo,
            partidos:      [],
          }
        }
        jugadoresMap[r.id_jugador].partidos.push({
          fecha:       r.fecha_juego,
          AB:          r.turnos_al_bate,
          H:           r.hits,
          HR:          r.jonrones,
          RBI:         r.carreras_impulsadas,
          R:           r.carreras,
          ave_partido: r.ave_partido ?? 0,
        })
      }

      const resultado = []
      for (const jug of Object.values(jugadoresMap)) {
        const pts = jug.partidos
        const n   = pts.length
        if (n < 2) continue

        const avePts = pts.map(p => p.ave_partido)

        // Tendencia simple: promedio última mitad vs primera mitad
        const mitad       = Math.floor(n / 2)
        const promedioIni = avePts.slice(0, mitad).reduce((s, v) => s + v, 0) / mitad
        const promedioFin = avePts.slice(mitad).reduce((s, v) => s + v, 0) / (n - mitad)
        const tendenciaPct = promedioIni > 0
          ? ((promedioFin - promedioIni) / promedioIni * 100)
          : 0

        // Estadísticas acumuladas (deben ir ANTES del fallback de regresión)
        const totalAB  = pts.reduce((s, p) => s + p.AB, 0)
        const totalH   = pts.reduce((s, p) => s + p.H, 0)
        const totalHR  = pts.reduce((s, p) => s + p.HR, 0)
        const totalRBI = pts.reduce((s, p) => s + p.RBI, 0)
        const aveAcum  = totalAB > 0 ? (totalH / totalAB) : 0

        // Regresión lineal sobre ave_partido
        const sumX  = (n * (n - 1)) / 2
        const sumX2 = (n * (n - 1) * (2 * n - 1)) / 6
        const sumY  = avePts.reduce((s, v) => s + v, 0)
        const sumXY = avePts.reduce((s, v, i) => s + i * v, 0)
        const denom = (n * sumX2 - sumX * sumX)

        let aveProyectado
        if (denom === 0 || !isFinite(denom)) {
          aveProyectado = aveAcum
        } else {
          const b = (n * sumXY - sumX * sumY) / denom
          const a = (sumY - b * sumX) / n
          const raw = a + b * n
          aveProyectado = isFinite(raw) ? Math.max(0, Math.min(1, raw)) : aveAcum
        }

        resultado.push({
          id_jugador:       jug.id_jugador,
          jugador:          jug.jugador,
          nombre_equipo:    jug.nombre_equipo,
          partidos_jugados: n,
          ave_acumulado:    Math.round(aveAcum * 1000) / 1000,
          ave_proyectado:   Math.round(aveProyectado * 1000) / 1000,
          tendencia_pct:    Math.round(tendenciaPct * 10) / 10,
          tendencia:        tendenciaPct >= 5 ? 'subiendo' : tendenciaPct <= -5 ? 'bajando' : 'estable',
          total_HR:         totalHR,
          total_RBI:        totalRBI,
          ultimos_3:        pts.slice(-3).map(p => ({ fecha: p.fecha, ave: p.ave_partido })),
        })
      }

      resultado.sort((a, b) => b.ave_acumulado - a.ave_acumulado)
      return res.json(resultado.slice(0, Number(limite)))
    }

    // ── tipo === 'pitchers' ───────────────────────────────────────────────────
    const [rows] = await db.query(
      `SELECT
         j.id_jugador,
         CONCAT(j.nombre, ' ', j.apellido)                                               AS jugador,
         e.nombre_equipo,
         p.fecha_juego,
         d.innings_pitcheados,
         d.carreras_limpias,
         d.ponches,
         d.bases_por_bolas,
         d.hits_permitidos,
         ROUND(d.carreras_limpias * 9 / NULLIF(d.innings_pitcheados, 0), 2)              AS era_partido
       FROM desempeno_pitcher d
       JOIN jugador j ON d.id_jugador = j.id_jugador
       JOIN equipo  e ON d.id_equipo  = e.id_equipo
       JOIN partido p ON d.id_partido = p.id_partido
       WHERE p.id_temporada = ?
         AND d.innings_pitcheados > 0
       ORDER BY j.id_jugador, p.fecha_juego ASC`,
      [temporada]
    )

    const pitchersMap = {}
    for (const r of rows) {
      if (!pitchersMap[r.id_jugador]) {
        pitchersMap[r.id_jugador] = {
          id_jugador:    r.id_jugador,
          jugador:       r.jugador,
          nombre_equipo: r.nombre_equipo,
          partidos:      [],
        }
      }
      pitchersMap[r.id_jugador].partidos.push({
        fecha:       r.fecha_juego,
        IP:          Number(r.innings_pitcheados),
        ER:          Number(r.carreras_limpias),
        K:           Number(r.ponches),
        BB:          Number(r.bases_por_bolas),
        era_partido: Number(r.era_partido ?? 0),
      })
    }

    const resultado = []
    for (const pit of Object.values(pitchersMap)) {
      const pts = pit.partidos
      const n   = pts.length
      if (n < 2) continue

      const eraPts = pts.map(p => p.era_partido)

      // Tendencia simple: promedio última mitad vs primera mitad
      const mitad      = Math.floor(n / 2)
      const eraIni     = eraPts.slice(0, mitad).reduce((s, v) => s + v, 0) / mitad
      const eraFin     = eraPts.slice(mitad).reduce((s, v) => s + v, 0) / (n - mitad)
      // ERA más baja = mejor; tendencia negativa en ERA = mejora
      const tendenciaPct = eraIni > 0 ? ((eraFin - eraIni) / eraIni * 100) : 0

      // Acumulados ANTES del fallback de regresión
      const totalIP = pts.reduce((s, p) => s + p.IP, 0)
      const totalER = pts.reduce((s, p) => s + p.ER, 0)
      const eraAcum = totalIP > 0 ? (totalER * 9 / totalIP) : 0
      const totalK  = pts.reduce((s, p) => s + p.K, 0)
      const totalBB = pts.reduce((s, p) => s + p.BB, 0)

      // Regresión lineal sobre era_partido
      const sumX  = (n * (n - 1)) / 2
      const sumX2 = (n * (n - 1) * (2 * n - 1)) / 6
      const sumY  = eraPts.reduce((s, v) => s + v, 0)
      const sumXY = eraPts.reduce((s, v, i) => s + i * v, 0)
      const denom = (n * sumX2 - sumX * sumX)

      let eraProyectada
      if (denom === 0 || !isFinite(denom)) {
        eraProyectada = eraAcum
      } else {
        const b = (n * sumXY - sumX * sumY) / denom
        const a = (sumY - b * sumX) / n
        const raw = a + b * n
        eraProyectada = isFinite(raw) ? Math.max(0, raw) : eraAcum
      }

      resultado.push({
        id_jugador:       pit.id_jugador,
        jugador:          pit.jugador,
        nombre_equipo:    pit.nombre_equipo,
        partidos_jugados: n,
        era_acumulada:    Math.round(eraAcum * 100) / 100,
        era_proyectada:   Math.round(eraProyectada * 100) / 100,
        tendencia_pct:    Math.round(tendenciaPct * 10) / 10,
        // Para ERA, bajando = mejorando
        tendencia:        tendenciaPct <= -5 ? 'mejorando' : tendenciaPct >= 5 ? 'empeorando' : 'estable',
        total_K:          totalK,
        total_BB:         totalBB,
        ultimos_3:        pts.slice(-3).map(p => ({ fecha: p.fecha, era: p.era_partido })),
      })
    }

    resultado.sort((a, b) => a.era_acumulada - b.era_acumulada)
    res.json(resultado.slice(0, Number(limite)))

  } catch (err) {
    console.error(err)
    res.status(500).json({ error: 'Error al generar predicción de jugadores' })
  }
})

// ══════════════════════════════════════════════════════════════════════════════
// 3. PREDICCIÓN DE ASISTENCIA A PARTIDOS
//    Usa el promedio móvil y tendencia de los últimos partidos para estimar
//    la asistencia (boletos vendidos) del próximo partido por equipo local.
// ══════════════════════════════════════════════════════════════════════════════
router.get('/prediccion-asistencia', soloRoles('administrador'), async (req, res) => {
  try {
    const { temporada } = req.query
    if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })

    const [rows] = await db.query(
      `SELECT
         p.id_partido,
         p.fecha_juego,
         ec.id_equipo                                         AS id_equipo_casa,
         ec.nombre_equipo                                     AS equipo_casa,
         ev.nombre_equipo                                     AS equipo_visitante,
         COALESCE(p.boletos_general, 0) + COALESCE(p.boletos_vip, 0) AS asistencia_total,
         COALESCE(p.capacidad_estadio, 0)                     AS capacidad,
         ROUND(
           (COALESCE(p.boletos_general, 0) + COALESCE(p.boletos_vip, 0))
           / NULLIF(p.capacidad_estadio, 0) * 100, 1
         )                                                    AS pct_ocupacion,
         ROUND(
           COALESCE(p.boletos_general, 0) * COALESCE(p.precio_general, 0) +
           COALESCE(p.boletos_vip, 0)     * COALESCE(p.precio_vip, 0), 2
         )                                                    AS recaudado
       FROM partido p
       JOIN equipo ec ON p.id_equipo_casa      = ec.id_equipo
       JOIN equipo ev ON p.id_equipo_visitante = ev.id_equipo
       WHERE p.id_temporada = ? AND p.estado = 'finalizado'
         AND (p.boletos_general > 0 OR p.boletos_vip > 0)
       ORDER BY p.fecha_juego ASC`,
      [temporada]
    )

    const equiposMap = {}
    for (const r of rows) {
      const key = r.id_equipo_casa
      if (!equiposMap[key]) {
        equiposMap[key] = { id_equipo: key, equipo_casa: r.equipo_casa, partidos: [] }
      }
      equiposMap[key].partidos.push({
        fecha:            r.fecha_juego,
        equipo_visitante: r.equipo_visitante,
        asistencia:       r.asistencia_total,
        capacidad:        r.capacidad,
        pct_ocupacion:    r.pct_ocupacion,
        recaudado:        r.recaudado,
      })
    }

    const resultado = []
    for (const eq of Object.values(equiposMap)) {
      const pts        = eq.partidos
      const n          = pts.length
      const asistencias = pts.map(p => p.asistencia)

      // Promedio móvil últimos 3 partidos
      const ultimos3      = asistencias.slice(-3)
      const promedioMovil = Math.round(ultimos3.reduce((s, v) => s + v, 0) / ultimos3.length)

      // Tendencia lineal
      let asistenciaProyectada = promedioMovil
      if (n >= 3) {
        const sumX  = (n * (n - 1)) / 2
        const sumX2 = (n * (n - 1) * (2 * n - 1)) / 6
        const sumY  = asistencias.reduce((s, v) => s + v, 0)
        const sumXY = asistencias.reduce((s, v, i) => s + i * v, 0)
        const b = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        const a = (sumY - b * sumX) / n
        asistenciaProyectada = Math.max(0, Math.round(a + b * n))
      }

      const capacidadPromedio = pts.reduce((s, p) => s + p.capacidad, 0) / n
      const pctProyectado = capacidadPromedio > 0
        ? Math.min(100, Math.round((asistenciaProyectada / capacidadPromedio) * 100))
        : null

      resultado.push({
        id_equipo:                eq.id_equipo,
        equipo_casa:              eq.equipo_casa,
        partidos_analizados:      n,
        asistencia_promedio:      Math.round(asistencias.reduce((s, v) => s + v, 0) / n),
        asistencia_max:           Math.max(...asistencias),
        asistencia_min:           Math.min(...asistencias),
        promedio_movil_3:         promedioMovil,
        asistencia_proyectada:    asistenciaProyectada,
        pct_ocupacion_proyectado: pctProyectado,
        historial:                pts.slice(-6),
      })
    }

    resultado.sort((a, b) => b.asistencia_promedio - a.asistencia_promedio)
    res.json(resultado)
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: 'Error al generar predicción de asistencia' })
  }
})

// ══════════════════════════════════════════════════════════════════════════════
// 4. ALERTA DE JUGADORES EN DECLIVE / ASCENSO
//    Detecta automáticamente jugadores con cambios significativos de rendimiento
// ══════════════════════════════════════════════════════════════════════════════
router.get('/alertas-rendimiento', soloRoles('administrador, dueno'), async (req, res) => {
  try {
    const { temporada, umbral = 15 } = req.query
    if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })

    const { rol, id_equipo } = req.user;
    
    // Si NO es administrador, filtramos por su equipo
    let filtroEquipo = '';
    let params = [temporada];
    
    if (rol !== 'administrador') {
      filtroEquipo = ' AND d.id_equipo = ?';
      params.push(id_equipo);
    }

    const umbralNum = Number(umbral)

    const [bateadores] = await db.query(
      `SELECT
         j.id_jugador,
         CONCAT(j.nombre, ' ', j.apellido) AS jugador,
         e.nombre_equipo,
         p.fecha_juego,
         d.turnos_al_bate,
         d.hits,
         d.jonrones
       FROM desempeno_bateador d
       JOIN jugador j ON d.id_jugador = j.id_jugador
       JOIN equipo  e ON d.id_equipo  = e.id_equipo
       JOIN partido p ON d.id_partido = p.id_partido
       WHERE p.id_temporada = ? ${filtroEquipo}
       ORDER BY j.id_jugador, p.fecha_juego ASC`,
      params 
    );

    const jugMap = {}
    for (const r of bateadores) {
      if (!jugMap[r.id_jugador]) jugMap[r.id_jugador] = { ...r, partidos: [] }
      jugMap[r.id_jugador].partidos.push({
        AB:  r.turnos_al_bate,
        H:   r.hits,
        ave: r.turnos_al_bate > 0 ? r.hits / r.turnos_al_bate : 0,
      })
    }

    const alertas = []
    for (const jug of Object.values(jugMap)) {
      const pts = jug.partidos
      if (pts.length < 4) continue

      const n          = pts.length
      const corte      = Math.max(1, n - 3)
      const ptsAntes   = pts.slice(0, corte)
      const ptsDespues = pts.slice(corte)

      const aveAntes   = ptsAntes.reduce((s, p) => s + p.ave, 0)   / ptsAntes.length
      const aveDespues = ptsDespues.reduce((s, p) => s + p.ave, 0) / ptsDespues.length

      const cambioPct = aveAntes > 0 ? ((aveDespues - aveAntes) / aveAntes * 100) : 0

      if (Math.abs(cambioPct) >= umbralNum) {
        alertas.push({
          tipo:                'bateador',
          id_jugador:          jug.id_jugador,
          jugador:             jug.jugador,
          nombre_equipo:       jug.nombre_equipo,
          estado:              cambioPct >= umbralNum ? 'ascenso' : 'declive',
          cambio_pct:          Math.round(cambioPct * 10) / 10,
          ave_antes:           Math.round(aveAntes * 1000) / 1000,
          ave_reciente:        Math.round(aveDespues * 1000) / 1000,
          partidos_analizados: n,
        })
      }
    }

    // Pitchers
    const [pitchers] = await db.query(
      `SELECT
         j.id_jugador,
         CONCAT(j.nombre, ' ', j.apellido) AS jugador,
         e.nombre_equipo,
         p.fecha_juego,
         d.innings_pitcheados,
         d.carreras_limpias
       FROM desempeno_pitcher d
       JOIN jugador j ON d.id_jugador = j.id_jugador
       JOIN equipo  e ON d.id_equipo  = e.id_equipo
       JOIN partido p ON d.id_partido = p.id_partido
       WHERE p.id_temporada = ? ${filtroEquipo}
       ORDER BY j.id_jugador, p.fecha_juego ASC`,
      params 
    );

    const pitMap = {}
    for (const r of pitchers) {
      if (!pitMap[r.id_jugador]) pitMap[r.id_jugador] = { ...r, partidos: [] }
      pitMap[r.id_jugador].partidos.push({
        IP:  Number(r.innings_pitcheados),
        ER:  Number(r.carreras_limpias),
        era: r.innings_pitcheados > 0 ? (Number(r.carreras_limpias) * 9) / Number(r.innings_pitcheados) : 0,
      })
    }

    for (const pit of Object.values(pitMap)) {
      const pts = pit.partidos
      if (pts.length < 4) continue

      const n          = pts.length
      const corte      = Math.max(1, n - 3)
      const ptsAntes   = pts.slice(0, corte)
      const ptsDespues = pts.slice(corte)

      const eraAntes   = ptsAntes.reduce((s, p) => s + p.era, 0)   / ptsAntes.length
      const eraDespues = ptsDespues.reduce((s, p) => s + p.era, 0) / ptsDespues.length

      // Para ERA: subir = empeorar, bajar = mejorar
      const cambioPct = eraAntes > 0 ? ((eraDespues - eraAntes) / eraAntes * 100) : 0

      if (Math.abs(cambioPct) >= umbralNum) {
        alertas.push({
          tipo:                'pitcher',
          id_jugador:          pit.id_jugador,
          jugador:             pit.jugador,
          nombre_equipo:       pit.nombre_equipo,
          estado:              cambioPct <= -umbralNum ? 'mejorando' : 'empeorando',
          cambio_pct:          Math.round(cambioPct * 10) / 10,
          era_antes:           Math.round(eraAntes * 100) / 100,
          era_reciente:        Math.round(eraDespues * 100) / 100,
          partidos_analizados: n,
        })
      }
    }

    alertas.sort((a, b) => Math.abs(b.cambio_pct) - Math.abs(a.cambio_pct))
    res.json(alertas)
  } catch (err) {
    console.error(err)
    res.status(500).json({ error: 'Error al generar alertas de rendimiento' })
  }
})

module.exports = router