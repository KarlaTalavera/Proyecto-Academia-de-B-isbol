const router = require('express').Router()
const ctrl = require('../controllers/proveedor.controller')
const { verificarToken } = require('../middlewares/auth')
const { soloRoles } = require('../middlewares/roles')

const finanzas = soloRoles('administrador', 'caja')

router.get('/',    verificarToken, finanzas, ctrl.listar)
router.get('/:id', verificarToken, finanzas, ctrl.obtener)
router.post('/',   verificarToken, finanzas, ctrl.crear)
router.put('/:id', verificarToken, finanzas, ctrl.actualizar)
router.delete('/:id', verificarToken, soloRoles('administrador'), ctrl.eliminar)

module.exports = router
