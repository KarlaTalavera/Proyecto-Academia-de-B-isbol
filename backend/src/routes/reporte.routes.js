const router = require('express').Router()
const DesempenoModel = require('../models/desempeno.model')
const { verificarToken } = require('../middlewares/auth')
const db = require('../config/database')
const { soloRoles } = require('../middlewares/roles')

//  eta tabla de posiciones extendida
router.get('/posiciones', verificarToken, async (req, res) => {
  const { temporada } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })
  const [rows] = await db.query(
    `SELECT * FROM (
       SELECT
         e.id_equipo,
         e.nombre_equipo,
         COUNT(DISTINCT CASE WHEN (p.id_equipo_casa = e.id_equipo AND r.carreras_home > r.carreras_visitantes)
                                 OR (p.id_equipo_visitante = e.id_equipo AND r.carreras_visitantes > r.carreras_home)
                               THEN p.id_partido END) AS ganados,
         COUNT(DISTINCT CASE WHEN (p.id_equipo_casa = e.id_equipo AND r.carreras_home < r.carreras_visitantes)
                                 OR (p.id_equipo_visitante = e.id_equipo AND r.carreras_visitantes < r.carreras_home)
                               THEN p.id_partido END) AS perdidos,
         COUNT(DISTINCT p.id_partido) AS jugados,
         COALESCE(SUM(CASE WHEN p.id_equipo_casa = e.id_equipo THEN r.carreras_home
                           WHEN p.id_equipo_visitante = e.id_equipo THEN r.carreras_visitantes
                           ELSE 0 END), 0) AS carreras_favor,
         COALESCE(SUM(CASE WHEN p.id_equipo_casa = e.id_equipo THEN r.carreras_visitantes
                           WHEN p.id_equipo_visitante = e.id_equipo THEN r.carreras_home
                           ELSE 0 END), 0) AS carreras_contra
       FROM equipo e
       LEFT JOIN partido  p ON (p.id_equipo_casa = e.id_equipo OR p.id_equipo_visitante = e.id_equipo)
                            AND p.id_temporada = ? AND p.estado = 'finalizado'
       LEFT JOIN resultado r ON r.id_partido = p.id_partido
       GROUP BY e.id_equipo, e.nombre_equipo
     ) AS t
     WHERE jugados > 0
     ORDER BY ganados DESC, (carreras_favor - carreras_contra) DESC`,
    [temporada]
  )
  res.json(rows)
})

//  Líderes de bateo
router.get('/promedios-bateo', verificarToken, async (req, res) => {
  const { temporada } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })
  const data = await DesempenoModel.promediosBateo(temporada)
  res.json(data)
})

//Líderes de pitcheo
router.get('/promedios-pitcheo', verificarToken, async (req, res) => {
  const { temporada } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })
  const [rows] = await db.query(
    `SELECT
       j.id_jugador,
       CONCAT(j.nombre, ' ', j.apellido) AS jugador,
       e.nombre_equipo,
       COUNT(d.id_desempeno_pitcher)           AS JJ,
       SUM(d.innings_pitcheados)               AS IP,
       SUM(d.hits_permitidos)                  AS H,
       SUM(d.carreras_limpias)                 AS ER,
       SUM(d.bases_por_bolas)                  AS BB,
       SUM(d.ponches)                          AS K,
       SUM(d.ganado)                           AS W,
       SUM(d.perdido)                          AS L,
       SUM(d.salvado)                          AS SV,
       ROUND(SUM(d.carreras_limpias) * 9 / NULLIF(SUM(d.innings_pitcheados), 0), 2) AS ERA,
       ROUND((SUM(d.hits_permitidos) + SUM(d.bases_por_bolas)) / NULLIF(SUM(d.innings_pitcheados), 0), 2) AS WHIP
     FROM desempeno_pitcher d
     JOIN jugador j ON d.id_jugador = j.id_jugador
     JOIN equipo  e ON d.id_equipo  = e.id_equipo
     JOIN partido p ON d.id_partido = p.id_partido
     WHERE p.id_temporada = ?
     GROUP BY j.id_jugador, j.nombre, j.apellido, e.nombre_equipo
     ORDER BY ERA ASC`,
    [temporada]
  )
  res.json(rows)
})

// Balance financiero por temporada
router.get('/finanzas', verificarToken, async (req, res) => {
  const { temporada } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })

  const [[balance]] = await db.query(
    `SELECT
       (SELECT COALESCE(SUM(valor), 0) FROM ingreso WHERE id_temporada = ?) AS total_ingresos,
       (SELECT COALESCE(SUM(gasto), 0) FROM egreso  WHERE id_temporada = ?) AS total_egresos`,
    [temporada, temporada]
  )

  const [ingresosPorConcepto] = await db.query(
    `SELECT
       CASE
         WHEN concepto LIKE '%inscripci%' THEN 'Inscripciones'
         WHEN concepto LIKE '%patrocin%'  THEN 'Patrocinios'
         WHEN concepto LIKE '%boleto%'    THEN 'Taquilla'
         WHEN concepto LIKE '%donaci%'    THEN 'Donaciones'
         ELSE 'Otros'
       END AS categoria,
       SUM(valor) AS total
     FROM ingreso WHERE id_temporada = ?
     GROUP BY categoria ORDER BY total DESC`,
    [temporada]
  )

  const [egresosPorProveedor] = await db.query(
    `SELECT
       COALESCE(p.nombre_proveedor, 'Sin proveedor') AS proveedor,
       SUM(e.gasto) AS total
     FROM egreso e
     LEFT JOIN proveedor p ON e.id_proveedor = p.id_proveedor
     WHERE e.id_temporada = ?
     GROUP BY proveedor ORDER BY total DESC`,
    [temporada]
  )

  res.json({
    total_ingresos: balance.total_ingresos,
    total_egresos: balance.total_egresos,
    balance: balance.total_ingresos - balance.total_egresos,
    ingresos_por_concepto: ingresosPorConcepto,
    egresos_por_proveedor: egresosPorProveedor,
  })
})

//Rendimiento comparativo por equipo
router.get('/rendimiento-equipos', verificarToken, async (req, res) => {
  const { temporada } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })
  const [rows] = await db.query(
    `SELECT
       e.id_equipo,
       e.nombre_equipo,
       COUNT(DISTINCT p.id_partido) AS partidos,
       -- Bateo colectivo
       SUM(db.turnos_al_bate) AS AB,
       SUM(db.hits) AS H,
       SUM(db.jonrones) AS HR,
       SUM(db.carreras) AS R,
       SUM(db.carreras_impulsadas) AS RBI,
       ROUND(SUM(db.hits) / NULLIF(SUM(db.turnos_al_bate), 0), 3) AS AVG_equipo,
       -- Errores
       COALESCE(SUM(CASE WHEN p.id_equipo_casa = e.id_equipo THEN r.errores_home
                         WHEN p.id_equipo_visitante = e.id_equipo THEN r.errores_visitantes
                         ELSE 0 END), 0) AS errores_totales
     FROM equipo e
     JOIN desempeno_bateador db ON db.id_equipo = e.id_equipo
     JOIN partido p ON db.id_partido = p.id_partido AND p.id_temporada = ?
     LEFT JOIN resultado r ON r.id_partido = p.id_partido
     GROUP BY e.id_equipo, e.nombre_equipo
     ORDER BY AVG_equipo DESC`,
    [temporada]
  )
  res.json(rows)
})

//historial de jugadores por temporada
router.get('/historial-jugadores', verificarToken, async (req, res) => {
  const { temporada } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })
  const [rows] = await db.query(
    `SELECT
       e.id_equipo,
       e.nombre_equipo,
       COUNT(DISTINCT j.id_jugador) AS total_jugadores,
       SUM(j.activo = 1) AS activos,
       SUM(j.activo = 0) AS inactivos,
       ROUND(AVG(TIMESTAMPDIFF(YEAR, j.fecha_nacimiento, CURDATE())), 1) AS edad_promedio,
       COUNT(DISTINCT db.id_jugador) AS jugadores_con_participacion
     FROM equipo e
     JOIN jugador j ON j.id_equipo = e.id_equipo
     LEFT JOIN desempeno_bateador db ON db.id_jugador = j.id_jugador
       AND db.id_partido IN (SELECT id_partido FROM partido WHERE id_temporada = ?)
     GROUP BY e.id_equipo, e.nombre_equipo
     ORDER BY total_jugadores DESC`,
    [temporada]
  )
  res.json(rows)
})

//Origen de Ingresos
router.get('/origen-ingresos', verificarToken, async (req, res) => {
  const { temporada, fechaDesde, fechaHasta } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })

  const paramsIngreso = [temporada]
  let dateClause = ''
  if (fechaDesde) { dateClause += ' AND fecha_ingreso >= ?'; paramsIngreso.push(fechaDesde) }
  if (fechaHasta) { dateClause += ' AND fecha_ingreso <= ?'; paramsIngreso.push(fechaHasta) }

  // Ingresos generales agrupados por categoría (tabla ingreso)
  const [porConcepto] = await db.query(
    `SELECT
       CASE
         WHEN LOWER(concepto) LIKE '%patrocin%'                          THEN 'Patrocinios'
         WHEN LOWER(concepto) LIKE '%boleto%'
           OR LOWER(concepto) LIKE '%taquill%'
           OR LOWER(concepto) LIKE '%entrada%'                           THEN 'Taquilla'
         WHEN LOWER(concepto) LIKE '%inscripci%'
           OR LOWER(concepto) LIKE '%registro%'
           OR LOWER(concepto) LIKE '%equipo%'                            THEN 'Inscripciones de Equipos'
         WHEN LOWER(concepto) LIKE '%concesi%'
           OR LOWER(concepto) LIKE '%comida%'
           OR LOWER(concepto) LIKE '%bebida%'
           OR LOWER(concepto) LIKE '%aliment%'
           OR LOWER(concepto) LIKE '%venta%'                             THEN 'Concesiones'
         ELSE 'Otros'
       END AS categoria,
       SUM(valor) AS total,
       COUNT(*)   AS cantidad
     FROM ingreso
     WHERE id_temporada = ?${dateClause}
     GROUP BY categoria
     ORDER BY total DESC`,
    paramsIngreso
  )

  // ── Inscripciones de equipos (tabla inscripcion) ──
  const paramsInscripcion = [temporada]
  let dateClauseInscripcion = ''
  if (fechaDesde) { dateClauseInscripcion += ' AND fecha_inscripcion >= ?'; paramsInscripcion.push(fechaDesde) }
  if (fechaHasta) { dateClauseInscripcion += ' AND fecha_inscripcion <= ?'; paramsInscripcion.push(fechaHasta) }

  const [[inscripciones]] = await db.query(
    `SELECT
       COALESCE(SUM(monto_pagado), 0) AS total,
       COUNT(*) AS cantidad
     FROM inscripcion
     WHERE id_temporada = ? AND estado_pago != 'pendiente'${dateClauseInscripcion}`,
    paramsInscripcion
  )

  // Inscripciones de Equipos en por concepto, sumar
  const mapa = {}
  for (const row of porConcepto) {
    mapa[row.categoria] = { total: Number(row.total), cantidad: Number(row.cantidad) }
  }

  const totalInscripciones = Number(inscripciones.total)
  if (totalInscripciones > 0) {
    if (mapa['Inscripciones de Equipos']) {
      mapa['Inscripciones de Equipos'].total    += totalInscripciones
      mapa['Inscripciones de Equipos'].cantidad += Number(inscripciones.cantidad)
    } else {
      mapa['Inscripciones de Equipos'] = {
        total: totalInscripciones,
        cantidad: Number(inscripciones.cantidad),
      }
    }
  }

  // Garantizar las 4 categorías principales siempre presentes
  const CATEGORIAS = ['Patrocinios', 'Taquilla', 'Inscripciones de Equipos', 'Concesiones']
  for (const cat of CATEGORIAS) {
    if (!mapa[cat]) mapa[cat] = { total: 0, cantidad: 0 }
  }

  // convertir a array ordenado por total desc
  const categorias = Object.entries(mapa)
    .map(([categoria, { total, cantidad }]) => ({ categoria, total, cantidad }))
    .sort((a, b) => b.total - a.total)

  const grandTotal = categorias.reduce((s, c) => s + c.total, 0)

  // el porcentaje
  const resultado = categorias.map(c => ({
    ...c,
    porcentaje: grandTotal > 0 ? Number(((c.total / grandTotal) * 100).toFixed(2)) : 0,
  }))

  res.json({
    total_general: grandTotal,
    categorias: resultado,
  })
})

router.get('/historico-ingresos', verificarToken, soloRoles('administrador', 'caja'), async (req, res) => {
  const { temporada, agrupacion = 'mes', fechaDesde, fechaHasta } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })

  const formato = agrupacion === 'semana'
    ? "YEARWEEK(fecha_ingreso, 1)"
    : "DATE_FORMAT(fecha_ingreso, '%Y-%m')"

  const etiqueta = agrupacion === 'semana'
    ? "CONCAT('Sem ', WEEK(fecha_ingreso, 1))"
    : "DATE_FORMAT(fecha_ingreso, '%b %Y')"

  const params = [temporada]
  let dateClause = ''
  if (fechaDesde) { dateClause += ' AND fecha_ingreso >= ?'; params.push(fechaDesde) }
  if (fechaHasta) { dateClause += ' AND fecha_ingreso <= ?'; params.push(fechaHasta) }

  const [rows] = await db.query(
    `SELECT
       ${formato}           AS periodo_key,
       ${etiqueta}          AS periodo,
       MIN(fecha_ingreso)   AS fecha_inicio,
       SUM(valor)           AS total,
       COUNT(*)             AS cantidad
     FROM ingreso
     WHERE id_temporada = ?${dateClause}
     GROUP BY periodo_key, periodo
     ORDER BY fecha_inicio ASC`,
    params
  )
  res.json(rows)
})

// ── Reporte de Taquilla por Partido ──────────────────────────────────────────
router.get('/taquilla', verificarToken, async (req, res) => {
  const { temporada, limite = 10 } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })
  const [rows] = await db.query(
    `SELECT
       p.id_partido,
       p.fecha_juego,
       ec.nombre_equipo                                                    AS equipo_casa,
       ev.nombre_equipo                                                    AS equipo_visitante,
       COALESCE(r.carreras_home, 0)                                        AS carreras_casa,
       COALESCE(r.carreras_visitantes, 0)                                  AS carreras_visitante,
       COALESCE(p.boletos_general, 0)                                      AS boletos_general,
       COALESCE(p.precio_general,  0)                                      AS precio_general,
       COALESCE(p.boletos_vip,     0)                                      AS boletos_vip,
       COALESCE(p.precio_vip,      0)                                      AS precio_vip,
       ROUND(COALESCE(p.boletos_general, 0) * COALESCE(p.precio_general, 0), 2) AS recaudado_general,
       ROUND(COALESCE(p.boletos_vip,     0) * COALESCE(p.precio_vip,     0), 2) AS recaudado_vip,
       ROUND(
         COALESCE(p.boletos_general, 0) * COALESCE(p.precio_general, 0) +
         COALESCE(p.boletos_vip,     0) * COALESCE(p.precio_vip,     0), 2)     AS recaudado_total,
       COALESCE(p.capacidad_estadio, 0)                                    AS capacidad_estadio,
       CASE
         WHEN COALESCE(p.capacidad_estadio, 0) > 0
         THEN ROUND(
                (COALESCE(p.boletos_general, 0) + COALESCE(p.boletos_vip, 0))
                / p.capacidad_estadio * 100, 1)
         ELSE NULL
       END                                                                  AS capacidad_ocupada
     FROM partido p
     JOIN equipo ec ON p.id_equipo_casa      = ec.id_equipo
     JOIN equipo ev ON p.id_equipo_visitante = ev.id_equipo
     LEFT JOIN resultado r ON r.id_partido   = p.id_partido
     WHERE p.id_temporada = ? AND p.estado = 'finalizado'
     ORDER BY p.fecha_juego DESC
     LIMIT ?`,
    [temporada, Number(limite)]
  )
  res.json(rows)
})

// ── Estadísticas Ofensivas (Bateadores) ──────────────────────────────────────
router.get('/estadisticas-bateadores', verificarToken, async (req, res) => {
  const { temporada } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })
  const [rows] = await db.query(
    `SELECT
       j.id_jugador,
       CONCAT(j.nombre, ' ', j.apellido)                                   AS jugador,
       e.nombre_equipo,
       COUNT(DISTINCT d.id_partido)                                         AS juegos,
       COALESCE(SUM(d.turnos_al_bate),      0)                             AS AB,
       COALESCE(SUM(d.hits),               0)                              AS H,
       COALESCE(SUM(d.dobles),             0)                              AS dobles,
       COALESCE(SUM(d.triples),            0)                              AS triples,
       COALESCE(SUM(d.jonrones),           0)                              AS HR,
       COALESCE(SUM(d.carreras),           0)                              AS R,
       COALESCE(SUM(d.carreras_impulsadas),0)                              AS RBI,
       ROUND(SUM(d.hits) / NULLIF(SUM(d.turnos_al_bate), 0), 3)           AS AVE
     FROM desempeno_bateador d
     JOIN jugador j ON d.id_jugador = j.id_jugador
     JOIN equipo  e ON d.id_equipo  = e.id_equipo
     JOIN partido p ON d.id_partido = p.id_partido
     WHERE p.id_temporada = ?
     GROUP BY j.id_jugador, j.nombre, j.apellido, e.nombre_equipo
     ORDER BY AVE DESC`,
    [temporada]
  )
  res.json(rows)
})

module.exports = router