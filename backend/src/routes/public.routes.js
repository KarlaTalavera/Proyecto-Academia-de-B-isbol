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
             ? AS temporada
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

    const [rows] = await db.query(`
      SELECT e.id_equipo, e.nombre_equipo,
        COUNT(CASE WHEN (p.id_equipo_casa = e.id_equipo AND r.carreras_home > r.carreras_visitantes)
                     OR (p.id_equipo_visitante = e.id_equipo AND r.carreras_visitantes > r.carreras_home) THEN 1 END) AS ganados,
        COUNT(CASE WHEN (p.id_equipo_casa = e.id_equipo AND r.carreras_home < r.carreras_visitantes)
                     OR (p.id_equipo_visitante = e.id_equipo AND r.carreras_visitantes < r.carreras_home) THEN 1 END) AS perdidos,
        COUNT(CASE WHEN r.id_resultado IS NOT NULL THEN 1 END) AS jugados
      FROM equipo e
      LEFT JOIN partido p ON (p.id_equipo_casa = e.id_equipo OR p.id_equipo_visitante = e.id_equipo)
        AND p.id_temporada = ? AND p.estado = 'finalizado'
      LEFT JOIN resultado r ON r.id_partido = p.id_partido
      GROUP BY e.id_equipo, e.nombre_equipo
      ORDER BY ganados DESC, perdidos ASC
    `, [temp.id_temporada])
    res.json(rows)
  } catch (e) {
    console.error(e)
    res.status(500).json({ error: 'Error al obtener posiciones' })
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
        j.nombre, j.apellido, j.posicion, j.rol,
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