const router = require('express').Router()
const db = require('../config/database')

// Partidos de la temporada activa (para Resultados y Calendario)
router.get('/partidos', async (req, res) => {
  try {
    // Buscar temporada activa
    const [[temp]] = await db.query('SELECT id_temporada, nombre FROM temporada WHERE activa = 1 LIMIT 1')
    if (!temp) return res.json([])

    const [rows] = await db.query(`
      SELECT p.id_partido, p.fecha_juego, p.hora_juego, p.estado, p.lugar,
             r.carreras_home      AS carreras_casa,
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

// Posiciones de la temporada activa (standings)
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

module.exports = router
