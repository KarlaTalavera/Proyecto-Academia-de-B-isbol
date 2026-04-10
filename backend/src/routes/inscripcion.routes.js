const router = require('express').Router()
const ctrl = require('../controllers/inscripcion.controller')
const { verificarToken } = require('../middlewares/auth')
const { soloRoles } = require('../middlewares/roles')

const admin = soloRoles('administrador')
const gestion = soloRoles('administrador', 'dueno', 'caja')

router.get('/',    verificarToken, gestion, ctrl.listar)
router.get('/:id', verificarToken, gestion, ctrl.obtener)
router.post('/',   verificarToken, gestion, ctrl.crear)
router.put('/:id', verificarToken, gestion, ctrl.actualizar)
router.delete('/:id', verificarToken, admin, ctrl.eliminar)

module.exports = router
