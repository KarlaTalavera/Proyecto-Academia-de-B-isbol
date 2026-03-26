const router             = require('express').Router()
const PartidoController  = require('../controllers/partido.controller')
const { verificarToken } = require('../middlewares/auth')
const { soloRoles }      = require('../middlewares/roles')

// Administrador o dueño pueden crear/modificar/eliminar partidos
const dueno    = soloRoles('administrador', 'dueno')
// Anotador es el ÚNICO que puede cargar lineup, resultado y estadísticas
const anotador = soloRoles('anotador')

// ── Partidos ────────────────────────────────────────────────
router.get('/',    verificarToken, PartidoController.listar)
router.get('/:id', verificarToken, PartidoController.obtener)
router.post('/',   verificarToken, dueno, PartidoController.crear)
router.patch('/:id/estado', verificarToken, dueno, PartidoController.actualizarEstado)
router.delete('/:id',       verificarToken, dueno, PartidoController.eliminar)

// ── Lineup (solo anotador) ───────────────────────────────────
router.get('/:id/lineup',  verificarToken, PartidoController.getLineup)
router.post('/:id/lineup', verificarToken, anotador, PartidoController.setLineup)

// ── Resultado (solo anotador) ────────────────────────────────
router.get('/:id/resultado',  verificarToken, PartidoController.getResultado)
router.post('/:id/resultado', verificarToken, anotador, PartidoController.guardarResultado)

// ── Desempeño individual (solo anotador) ─────────────────────
router.get('/:id/desempeno',           verificarToken, PartidoController.getDesempeno)
router.post('/:id/desempeno/bateador', verificarToken, anotador, PartidoController.guardarDesempenoBateador)
router.post('/:id/desempeno/pitcher',  verificarToken, anotador, PartidoController.guardarDesempenoPitcher)

module.exports = router
