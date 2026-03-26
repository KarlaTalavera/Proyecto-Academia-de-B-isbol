const router             = require('express').Router()
const JugadorController  = require('../controllers/jugador.controller')
const { verificarToken } = require('../middlewares/auth')
const { soloRoles }      = require('../middlewares/roles')

router.get('/',    verificarToken, JugadorController.listar)
router.get('/:id', verificarToken, JugadorController.obtener)

router.post('/',      verificarToken, soloRoles('administrador', 'dueno'), JugadorController.crear)
router.put('/:id',    verificarToken, soloRoles('administrador', 'dueno'), JugadorController.actualizar)
router.delete('/:id', verificarToken, soloRoles('administrador', 'dueno'), JugadorController.eliminar)

module.exports = router
