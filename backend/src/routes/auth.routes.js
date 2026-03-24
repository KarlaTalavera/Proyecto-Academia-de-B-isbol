const router         = require('express').Router()
const AuthController = require('../controllers/auth.controller')
const { verificarToken } = require('../middlewares/auth')

router.post('/login',    AuthController.login)
router.post('/registro', AuthController.registro)
router.get('/perfil',    verificarToken, AuthController.perfil)

module.exports = router
