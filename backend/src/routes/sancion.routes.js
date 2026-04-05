const router = require('express').Router()
const ctrl = require('../controllers/sancion.controller')
const { verificarToken } = require('../middlewares/auth')
const { soloRoles } = require('../middlewares/roles')

const gestion   = soloRoles('administrador', 'dueno')
const sancionar = soloRoles('administrador', 'dueno', 'anotador')

router.get('/',    verificarToken, ctrl.listar)
router.get('/:id', verificarToken, ctrl.obtener)
router.post('/',   verificarToken, sancionar, ctrl.crear)
router.put('/:id', verificarToken, sancionar, ctrl.actualizar)
router.delete('/:id', verificarToken, soloRoles('administrador'), ctrl.eliminar)

module.exports = router
