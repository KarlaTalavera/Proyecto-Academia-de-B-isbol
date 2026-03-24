const router   = require('express').Router()
const FanModel = require('../models/fan.model')
const { verificarToken } = require('../middlewares/auth')

// Todos los endpoints requieren autenticación
router.use(verificarToken)

// GET /api/fan/equipos — todos los equipos con flag siguiendo
router.get('/equipos', async (req, res, next) => {
  try {
    const equipos = await FanModel.listarEquiposConFlag(req.usuario.id)
    res.json(equipos)
  } catch (e) { next(e) }
})

// GET /api/fan/mis-equipos — solo los que sigue
router.get('/mis-equipos', async (req, res, next) => {
  try {
    const equipos = await FanModel.misEquipos(req.usuario.id)
    res.json(equipos)
  } catch (e) { next(e) }
})

// POST /api/fan/seguir/:id_equipo
router.post('/seguir/:id_equipo', async (req, res, next) => {
  try {
    await FanModel.seguir(req.usuario.id, req.params.id_equipo)
    res.json({ ok: true })
  } catch (e) { next(e) }
})

// DELETE /api/fan/seguir/:id_equipo
router.delete('/seguir/:id_equipo', async (req, res, next) => {
  try {
    await FanModel.dejarSeguir(req.usuario.id, req.params.id_equipo)
    res.json({ ok: true })
  } catch (e) { next(e) }
})

// GET /api/fan/proximos-juegos
router.get('/proximos-juegos', async (req, res, next) => {
  try {
    const partidos = await FanModel.proximosJuegos(req.usuario.id)
    res.json(partidos)
  } catch (e) { next(e) }
})

// GET /api/fan/estadisticas
router.get('/estadisticas', async (req, res, next) => {
  try {
    const stats = await FanModel.estadisticasBateadores(req.usuario.id)
    res.json(stats)
  } catch (e) { next(e) }
})

// GET /api/fan/ultimos-resultados
router.get('/ultimos-resultados', async (req, res, next) => {
  try {
    const resultados = await FanModel.ultimosResultados(req.usuario.id)
    res.json(resultados)
  } catch (e) { next(e) }
})

module.exports = router
