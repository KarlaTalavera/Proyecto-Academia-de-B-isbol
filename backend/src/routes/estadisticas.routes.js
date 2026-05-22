const router = require('express').Router()
const ctrl   = require('../controllers/estadisticas.controller')
const { verificarToken } = require('../middlewares/auth')

router.use(verificarToken)

router.get('/partido/:id/bateadores',    ctrl.bateadoresPorPartido)
router.get('/partido/:id/pitchers',      ctrl.pitcheresPorPartido)

router.get('/jugador/:id/bateador/partidos',    ctrl.bateadorPartidos)
router.get('/jugador/:id/bateador/temporadas',  ctrl.bateadorTemporadas)
router.get('/jugador/:id/bateador/fechas',      ctrl.bateadorFechas)

router.get('/jugador/:id/pitcher/partidos',     ctrl.pitcherPartidos)
router.get('/jugador/:id/pitcher/temporadas',   ctrl.pitcherTemporadas)
router.get('/jugador/:id/pitcher/fechas',       ctrl.pitcherFechas)

module.exports = router