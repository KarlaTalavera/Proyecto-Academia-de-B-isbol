const router              = require('express').Router()
const UsuariosController  = require('../controllers/usuarios.controller')
const { verificarToken }  = require('../middlewares/auth')
const { soloRoles }       = require('../middlewares/roles')

const soloAdmin = soloRoles('administrador')

// Solo administrador puede gestionar usuarios
router.get('/',                verificarToken, soloAdmin, UsuariosController.listar)
router.patch('/:id/rol',       verificarToken, soloAdmin, UsuariosController.actualizarRol)
router.patch('/:id/activo',    verificarToken, soloAdmin, UsuariosController.toggleActivo)
router.patch('/:id/password',  verificarToken, soloAdmin, UsuariosController.resetPassword)
router.delete('/:id',          verificarToken, soloAdmin, UsuariosController.eliminar)

module.exports = router
