const router             = require('express').Router()
const DesempenoModel     = require('../models/desempeno.model')
const { verificarToken } = require('../middlewares/auth')

// Promedios de bateo — público autenticado
router.get('/promedios-bateo', verificarToken, async (req, res) => {
  const { temporada } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })
  const data = await DesempenoModel.promediosBateo(temporada)
  res.json(data)
})

// Tabla de posiciones por temporada
router.get('/posiciones', verificarToken, async (req, res) => {
  const { temporada } = req.query
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })
  const db = require('../config/database')
  const [rows] = await db.query(
    `SELECT
       e.id_equipo,
       e.nombre_equipo,
       COUNT(DISTINCT CASE WHEN (p.id_equipo_casa = e.id_equipo AND r.carreras_home > r.carreras_visitantes)
                             OR (p.id_equipo_visitante = e.id_equipo AND r.carreras_visitantes > r.carreras_home)
                           THEN p.id_partido END) AS ganados,
       COUNT(DISTINCT CASE WHEN (p.id_equipo_casa = e.id_equipo AND r.carreras_home < r.carreras_visitantes)
                             OR (p.id_equipo_visitante = e.id_equipo AND r.carreras_visitantes < r.carreras_home)
                           THEN p.id_partido END) AS perdidos,
       COUNT(DISTINCT p.id_partido) AS jugados
     FROM equipo e
     LEFT JOIN partido  p ON (p.id_equipo_casa = e.id_equipo OR p.id_equipo_visitante = e.id_equipo)
                          AND p.id_temporada = ? AND p.estado = 'finalizado'
     LEFT JOIN resultado r ON r.id_partido = p.id_partido
     GROUP BY e.id_equipo, e.nombre_equipo
     ORDER BY ganados DESC, perdidos ASC`,
    [temporada]
  )
  res.json(rows)
})

module.exports = router
