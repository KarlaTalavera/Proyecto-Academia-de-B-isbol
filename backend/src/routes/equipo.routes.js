const router           = require('express').Router()
const EquipoController = require('../controllers/equipo.controller')
const { verificarToken } = require('../middlewares/auth')
const { soloRoles }      = require('../middlewares/roles')

// Lectura — cualquier autenticado
router.get('/',            verificarToken, EquipoController.listar)
router.get('/:id',         verificarToken, EquipoController.obtener)
router.get('/:id/jugadores', verificarToken, EquipoController.jugadores)

// Escritura — dueno o administrador
router.post('/',    verificarToken, soloRoles('administrador', 'dueno'), EquipoController.crear)
router.put('/:id',  verificarToken, soloRoles('administrador', 'dueno'), EquipoController.actualizar)
router.delete('/:id', verificarToken, soloRoles('administrador', 'dueno'), EquipoController.eliminar)

module.exports = router
