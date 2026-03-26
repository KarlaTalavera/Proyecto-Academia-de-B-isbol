const router              = require('express').Router()
const FinanzasController  = require('../controllers/finanzas.controller')
const { verificarToken }  = require('../middlewares/auth')
const { soloRoles }       = require('../middlewares/roles')

const finanzas = soloRoles('administrador', 'caja')
const soloAdmin = soloRoles('administrador')

// Balance — solo administrador
router.get('/balance', verificarToken, soloAdmin, FinanzasController.balance)

// Ingresos
router.get('/ingresos',    verificarToken, finanzas, FinanzasController.listarIngresos)
router.get('/ingresos/:id',verificarToken, finanzas, FinanzasController.obtenerIngreso)
router.post('/ingresos',   verificarToken, finanzas, FinanzasController.crearIngreso)
router.put('/ingresos/:id',verificarToken, finanzas, FinanzasController.actualizarIngreso)
router.delete('/ingresos/:id', verificarToken, soloAdmin, FinanzasController.eliminarIngreso)

// Egresos
router.get('/egresos',    verificarToken, finanzas, FinanzasController.listarEgresos)
router.get('/egresos/:id',verificarToken, finanzas, FinanzasController.obtenerEgreso)
router.post('/egresos',   verificarToken, finanzas, FinanzasController.crearEgreso)
router.put('/egresos/:id',verificarToken, finanzas, FinanzasController.actualizarEgreso)
router.delete('/egresos/:id', verificarToken, soloAdmin, FinanzasController.eliminarEgreso)

module.exports = router
