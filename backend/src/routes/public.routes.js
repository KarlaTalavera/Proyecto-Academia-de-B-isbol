const router = require('express').Router()
const db     = require('../config/database')

// ── Partidos de la temporada activa ──────────────────────────
router.get('/partidos', async (req, res) => {
  try {
    const [[temp]] = await db.query('SELECT id_temporada, nombre FROM temporada WHERE activa = 1 LIMIT 1')
    if (!temp) return res.json([])

    const [rows] = await db.query(`
      SELECT p.id_partido, p.fecha_juego, p.hora_juego, p.estado, p.lugar,
             p.id_equipo_casa, p.id_equipo_visitante,
             r.carreras_home       AS carreras_casa,
             r.carreras_visitantes AS carreras_visitante,
             ec.nombre_equipo AS equipo_casa,
             ev.nombre_equipo AS equipo_visitante,
             ? AS temporada,
             EXISTS(SELECT 1 FROM lineup l WHERE l.id_partido = p.id_partido) AS tiene_lineup
      FROM partido p
      JOIN equipo ec ON p.id_equipo_casa     = ec.id_equipo
      JOIN equipo ev ON p.id_equipo_visitante = ev.id_equipo
      LEFT JOIN resultado r ON r.id_partido   = p.id_partido
      WHERE p.id_temporada = ?
      ORDER BY p.fecha_juego DESC, p.hora_juego DESC
      LIMIT 100
    `, [temp.nombre, temp.id_temporada])
    res.json(rows)
  } catch (e) {
    console.error(e)
    res.status(500).json({ error: 'Error al obtener partidos' })
  }
})

// ── Posiciones / standings ────────────────────────────────────
router.get('/posiciones', async (req, res) => {
  try {
    const [[temp]] = await db.query('SELECT id_temporada FROM temporada WHERE activa = 1 LIMIT 1')
    if (!temp) return res.json([])

    const id_temp = temp.id_temporada
    const { vuelta } = req.query   // '1' | '2' | undefined

    // Para 1V y 2V: tomar solo la primera o segunda mitad de juegos finalizados
    let filtroIds = ''
    if (vuelta === '1' || vuelta === '2') {
      const [[{ total }]] = await db.query(
        `SELECT COUNT(*) AS total FROM partido WHERE id_temporada = ${id_temp} AND estado = 'finalizado'`
      )
      if (!total) return res.json([])
      const mitad  = Math.ceil(total / 2)
      const offset = vuelta === '1' ? 0 : mitad
      const [mitadRows] = await db.query(
        `SELECT id_partido FROM partido WHERE id_temporada = ${id_temp} AND estado = 'finalizado'
         ORDER BY fecha_juego, hora_juego LIMIT ${mitad} OFFSET ${offset}`
      )
      if (!mitadRows.length) return res.json([])
      filtroIds = `AND p.id_partido IN (${mitadRows.map(r => r.id_partido).join(',')})`
    }

    const [rows] = await db.query(`
      SELECT
        e.id_equipo,
        e.nombre_equipo,
        COUNT(CASE
          WHEN p.id_equipo_casa      = e.id_equipo AND r.carreras_home         > r.carreras_visitantes THEN 1
          WHEN p.id_equipo_visitante = e.id_equipo AND r.carreras_visitantes   > r.carreras_home       THEN 1
        END) AS ganados,
        COUNT(CASE
          WHEN p.id_equipo_casa      = e.id_equipo AND r.carreras_home         < r.carreras_visitantes THEN 1
          WHEN p.id_equipo_visitante = e.id_equipo AND r.carreras_visitantes   < r.carreras_home       THEN 1
        END) AS perdidos,
        COUNT(r.id_partido) AS jugados,
        COALESCE(SUM(CASE
          WHEN p.id_equipo_casa      = e.id_equipo THEN r.carreras_home
          WHEN p.id_equipo_visitante = e.id_equipo THEN r.carreras_visitantes
          ELSE 0
        END), 0) AS carreras_favor,
        COALESCE(SUM(CASE
          WHEN p.id_equipo_casa      = e.id_equipo THEN r.carreras_visitantes
          WHEN p.id_equipo_visitante = e.id_equipo THEN r.carreras_home
          ELSE 0
        END), 0) AS carreras_contra
      FROM equipo e
      LEFT JOIN partido p
        ON (p.id_equipo_casa = e.id_equipo OR p.id_equipo_visitante = e.id_equipo)
        AND p.id_temporada = ${id_temp}
        AND p.estado = 'finalizado'
        ${filtroIds}
      LEFT JOIN resultado r ON r.id_partido = p.id_partido
      GROUP BY e.id_equipo, e.nombre_equipo
      ORDER BY ganados DESC, perdidos ASC
    `)

    res.json(rows)
  } catch (e) {
    console.error(e)
    res.status(500).json({ error: 'Error al obtener posiciones' })
  }
})

// ── Noticias activas ──────────────────────────────────────────
router.get('/noticias', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id_noticia, titulo, contenido, foto_url, fecha_publicacion
       FROM noticia WHERE activa = 1
       ORDER BY created_at DESC`
    )
    res.json(rows)
  } catch (e) {
    console.error(e)
    res.status(500).json({ error: 'Error al obtener noticias' })
  }
})

// ── Equipos de la temporada activa ───────────────────────────
router.get('/equipos', async (req, res) => {
  try {
    const [[temp]] = await db.query('SELECT id_temporada FROM temporada WHERE activa = 1 LIMIT 1')
    if (!temp) return res.json([])

    const [rows] = await db.query(`
      SELECT e.id_equipo, e.nombre_equipo, e.entrenador, e.responsable, e.email, e.telefono
      FROM equipo e
      JOIN inscripcion i ON i.id_equipo = e.id_equipo
      WHERE i.id_temporada = ?
      ORDER BY e.nombre_equipo ASC
    `, [temp.id_temporada])
    res.json(rows)
  } catch (e) {
    res.status(500).json({ error: 'Error al obtener equipos' })
  }
})

// ── Lineup de un partido ─────────────────────────────────────
router.get('/lineup/:id_partido', async (req, res) => {
  try {
    const { id_partido } = req.params
    const [rows] = await db.query(`
      SELECT
        l.orden_bateo, l.posicion_juego, l.es_titular,
        j.nombre, j.apellido, j.posicion, j.rol, j.foto_url,
        e.id_equipo, e.nombre_equipo,
        p.id_equipo_casa, p.id_equipo_visitante
      FROM lineup l
      JOIN jugador j ON j.id_jugador = l.id_jugador
      JOIN equipo e  ON e.id_equipo  = l.id_equipo
      JOIN partido p ON p.id_partido = l.id_partido
      WHERE l.id_partido = ?
      ORDER BY l.id_equipo, l.es_titular DESC, l.orden_bateo ASC
    `, [id_partido])
    res.json(rows)
  } catch (e) {
    console.error(e)
    res.status(500).json({ error: 'Error al obtener lineup' })
  }
})

// ── Jugadores de la temporada activa (para página Destacados) ─
router.get('/jugadores-temporada', async (req, res) => {
  try {
    const [[temp]] = await db.query('SELECT id_temporada FROM temporada WHERE activa = 1 LIMIT 1')
    if (!temp) return res.json([])

    const [rows] = await db.query(`
      SELECT DISTINCT
        j.id_jugador, j.nombre, j.apellido, j.posicion, j.rol,
        j.foto_url,
        e.nombre_equipo
      FROM jugador j
      JOIN lineup l  ON l.id_jugador = j.id_jugador
      JOIN partido p ON p.id_partido = l.id_partido
      JOIN equipo e  ON e.id_equipo  = l.id_equipo
      WHERE p.id_temporada = ?
      ORDER BY j.apellido ASC
    `, [temp.id_temporada])
    res.json(rows)
  } catch (e) {
    console.error(e)
    res.status(500).json({ error: 'Error al obtener jugadores' })
  }
})

// ── PROXY IA — Genera perfil creativo del jugador ────────────
// La llamada a Anthropic se hace desde el backend (nunca exponer la key al frontend)
router.post('/perfil-ia/:id_jugador', async (req, res) => {
  try {
    const { id_jugador } = req.params

    if (!process.env.ANTHROPIC_API_KEY) {
      return res.status(503).json({ error: 'API Key de IA no configurada en el servidor' })
    }

    // Obtiene datos del jugador desde la BD
    const [[jugador]] = await db.query(`
      SELECT j.nombre, j.apellido, j.posicion, j.rol, e.nombre_equipo
      FROM jugador j
      LEFT JOIN equipo e ON e.id_equipo = j.id_equipo
      WHERE j.id_jugador = ?
    `, [id_jugador])

    if (!jugador) return res.status(404).json({ error: 'Jugador no encontrado' })

    // Llama a Claude Haiku (rápido y económico)
    const aiRes = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 800,
        messages: [{
          role: 'user',
          content: `Eres el narrador oficial de la Liga Diamante de béisbol en Venezuela.
Genera un perfil creativo, inspirador y entretenido para este jugador amateur/semiprofesional venezolano.

Jugador: ${jugador.nombre} ${jugador.apellido}
Posición: ${jugador.posicion}
Equipo: ${jugador.nombre_equipo || 'Liga Diamante'}
${jugador.rol ? `Rol especial: ${jugador.rol}` : ''}

Responde ÚNICAMENTE con JSON válido (sin markdown, sin backticks, sin texto extra):
{
  "perfil": "2-3 oraciones sobre cómo juega y por qué es valioso para el equipo. Usa vocabulario beisbolero venezolano.",
  "dato_curioso": "Una anécdota creíble, divertida y memorable sobre el jugador o su posición.",
  "rutina": "Rutina de entrenamiento específica para su posición con consejos reales de béisbol. 3-4 oraciones.",
  "estilo": "Describe su estilo de juego: agresivo, disciplinado, técnico, explosivo, inteligente. 2 oraciones.",
  "comparacion": "A qué jugador venezolano famoso de MLB se parece o aspira y por qué. 1 oración."
}`
        }],
      }),
    })

    if (!aiRes.ok) {
      const err = await aiRes.text()
      console.error('Anthropic API error:', err)
      return res.status(500).json({ error: 'Error al contactar la IA' })
    }

    const data   = await aiRes.json()
    const text   = data.content?.map(b => b.text || '').join('') || ''
    const clean  = text.replace(/```json|```/g, '').trim()
    const perfil = JSON.parse(clean)

    res.json(perfil)
  } catch (e) {
    console.error('perfil-ia error:', e.message)
    res.status(500).json({ error: 'Error al generar perfil con IA' })
  }
})


// ── Directorio público de jugadores de la Liga ───────────────
router.get('/jugadores-liga', async (req, res) => {
  try {
    const { busqueda, equipo } = req.query
    let sql = `
      SELECT j.id_jugador, j.nombre, j.apellido, j.posicion, j.rol,
             j.brazo_dominante, j.foto_url,
             e.id_equipo, e.nombre_equipo, e.logo_url AS equipo_logo_url
      FROM jugador j
      JOIN equipo e ON j.id_equipo = e.id_equipo
      WHERE j.activo = 1
    `
    const params = []
    if (busqueda) {
      sql += ' AND CONCAT(j.nombre, " ", j.apellido) LIKE ?'
      params.push(`%${busqueda}%`)
    }
    if (equipo) {
      sql += ' AND j.id_equipo = ?'
      params.push(equipo)
    }
    sql += ' ORDER BY j.apellido, j.nombre'
    const [rows] = await db.query(sql, params)
    res.json(rows)
  } catch (e) {
    console.error(e)
    res.status(500).json({ error: 'Error al obtener jugadores' })
  }
})

// ── Perfil de jugador con estadísticas de carrera ────────────
router.get('/jugadores-liga/:id', async (req, res) => {
  try {
    const { id } = req.params
    const [[jugador]] = await db.query(`
      SELECT j.*, e.nombre_equipo, e.logo_url AS equipo_logo_url
      FROM jugador j
      JOIN equipo e ON j.id_equipo = e.id_equipo
      WHERE j.id_jugador = ?
    `, [id])

    if (!jugador) return res.status(404).json({ error: 'Jugador no encontrado' })

    const [[bateo]] = await db.query(`
      SELECT
        COUNT(DISTINCT db.id_partido)  AS juegos_jugados,
        COALESCE(SUM(db.turnos_al_bate),      0) AS AB,
        COALESCE(SUM(db.hits),                0) AS H,
        COALESCE(SUM(db.dobles),              0) AS dobles,
        COALESCE(SUM(db.triples),             0) AS triples,
        COALESCE(SUM(db.jonrones),            0) AS HR,
        COALESCE(SUM(db.carreras),            0) AS R,
        COALESCE(SUM(db.carreras_impulsadas), 0) AS RBI,
        COALESCE(SUM(db.bolas),               0) AS BB,
        CASE WHEN SUM(db.turnos_al_bate) > 0
          THEN ROUND(SUM(db.hits) / SUM(db.turnos_al_bate), 3)
          ELSE 0 END AS AVG
      FROM desempeno_bateador db
      WHERE db.id_jugador = ?
    `, [id])

    const [[pitcheo]] = await db.query(`
      SELECT
        COUNT(DISTINCT dp.id_partido)       AS juegos_jugados,
        COALESCE(SUM(dp.innings_pitcheados), 0) AS IP,
        COALESCE(SUM(dp.hits_permitidos),    0) AS H,
        COALESCE(SUM(dp.carreras_limpias),   0) AS ER,
        COALESCE(SUM(dp.ponches),            0) AS K,
        COALESCE(SUM(dp.bases_por_bolas),    0) AS BB,
        COALESCE(SUM(dp.ganado),             0) AS W,
        COALESCE(SUM(dp.perdido),            0) AS L,
        COALESCE(SUM(dp.salvado),            0) AS SV,
        CASE WHEN SUM(dp.innings_pitcheados) > 0
          THEN ROUND((SUM(dp.carreras_limpias) * 9) / SUM(dp.innings_pitcheados), 2)
          ELSE 0 END AS ERA
      FROM desempeno_pitcher dp
      WHERE dp.id_jugador = ?
    `, [id])

    res.json({ ...jugador, bateo: bateo || {}, pitcheo: pitcheo || {} })
  } catch (e) {
    console.error(e)
    res.status(500).json({ error: 'Error al obtener perfil del jugador' })
  }
})

// ── Perfil de equipo con plantilla y record ───────────────────
router.get('/equipos-liga/:id', async (req, res) => {
  try {
    const { id } = req.params
    const [[equipo]] = await db.query('SELECT * FROM equipo WHERE id_equipo = ?', [id])
    if (!equipo) return res.status(404).json({ error: 'Equipo no encontrado' })

    const [jugadores] = await db.query(`
      SELECT j.id_jugador, j.nombre, j.apellido, j.posicion, j.rol, j.foto_url
      FROM jugador j
      WHERE j.id_equipo = ? AND j.activo = 1
      ORDER BY j.apellido, j.nombre
    `, [id])

    const [[temp]] = await db.query('SELECT id_temporada FROM temporada WHERE activa = 1 LIMIT 1')
    let record = { ganados: 0, perdidos: 0, jugados: 0 }
    if (temp) {
      const [[rec]] = await db.query(`
        SELECT
          COUNT(CASE WHEN (p.id_equipo_casa = ? AND r.carreras_home > r.carreras_visitantes)
                       OR (p.id_equipo_visitante = ? AND r.carreras_visitantes > r.carreras_home) THEN 1 END) AS ganados,
          COUNT(CASE WHEN (p.id_equipo_casa = ? AND r.carreras_home < r.carreras_visitantes)
                       OR (p.id_equipo_visitante = ? AND r.carreras_visitantes < r.carreras_home) THEN 1 END) AS perdidos,
          COUNT(r.id_resultado) AS jugados
        FROM partido p
        LEFT JOIN resultado r ON r.id_partido = p.id_partido
        WHERE (p.id_equipo_casa = ? OR p.id_equipo_visitante = ?)
          AND p.id_temporada = ?
      `, [id, id, id, id, id, id, temp.id_temporada])
      if (rec) record = rec
    }

    res.json({ ...equipo, jugadores, record })
  } catch (e) {
    console.error(e)
    res.status(500).json({ error: 'Error al obtener equipo' })
  }
})

// ── Jugadores sin foto_url (fallback si la columna no existe aún) ─
router.get('/jugadores-temporada-simple', async (req, res) => {
  try {
    const [[temp]] = await db.query('SELECT id_temporada FROM temporada WHERE activa = 1 LIMIT 1')
    if (!temp) return res.json([])

    const [rows] = await db.query(`
      SELECT DISTINCT
        j.id_jugador, j.nombre, j.apellido, j.posicion, j.rol,
        e.nombre_equipo
      FROM jugador j
      JOIN lineup l  ON l.id_jugador = j.id_jugador
      JOIN partido p ON p.id_partido = l.id_partido
      JOIN equipo e  ON e.id_equipo  = l.id_equipo
      WHERE p.id_temporada = ?
      ORDER BY j.apellido ASC
    `, [temp.id_temporada])
    res.json(rows)
  } catch (e) {
    console.error(e)
    res.status(500).json({ error: 'Error al obtener jugadores' })
  }
})

module.exports = router