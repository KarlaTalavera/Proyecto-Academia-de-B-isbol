const path           = require('path')
const fs             = require('fs')
const router         = require('express').Router()
const EquipoController = require('../controllers/equipo.controller')
const { verificarToken } = require('../middlewares/auth')
const { soloRoles }  = require('../middlewares/roles')
const upload         = require('../middlewares/upload')
const db             = require('../config/database')

// Lectura — cualquier autenticado
router.get('/',              verificarToken, EquipoController.listar)
router.get('/:id',           verificarToken, EquipoController.obtener)
router.get('/:id/jugadores', verificarToken, EquipoController.jugadores)

// Escritura — dueno o administrador
router.post('/',    verificarToken, soloRoles('administrador', 'dueno'), EquipoController.crear)
router.put('/:id',  verificarToken, soloRoles('administrador', 'dueno'), EquipoController.actualizar)
router.delete('/:id', verificarToken, soloRoles('administrador', 'dueno'), EquipoController.eliminar)

// ── Logo del equipo ───────────────────────────────────────────
router.post('/:id/logo',
  verificarToken,
  soloRoles('administrador', 'dueno'),
  (req, _res, next) => { req.uploadPrefix = 'equipo'; next() },
  upload.single('logo'),
  async (req, res) => {
    if (!req.file) return res.status(400).json({ error: 'No se envió ningún archivo' })

    // Borrar logo anterior si existe
    const [[equipo]] = await db.query('SELECT logo_url FROM equipo WHERE id_equipo = ?', [req.params.id])
    if (equipo?.logo_url) {
      const oldPath = path.join(__dirname, '../../uploads', path.basename(equipo.logo_url))
      if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath)
    }

    const logo_url = `/uploads/${req.file.filename}`
    await db.query('UPDATE equipo SET logo_url = ? WHERE id_equipo = ?', [logo_url, req.params.id])
    res.json({ logo_url })
  }
)

router.delete('/:id/logo',
  verificarToken,
  soloRoles('administrador', 'dueno'),
  async (req, res) => {
    const [[equipo]] = await db.query('SELECT logo_url FROM equipo WHERE id_equipo = ?', [req.params.id])
    if (equipo?.logo_url) {
      const oldPath = path.join(__dirname, '../../uploads', path.basename(equipo.logo_url))
      if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath)
    }
    await db.query('UPDATE equipo SET logo_url = NULL WHERE id_equipo = ?', [req.params.id])
    res.json({ ok: true })
  }
)

module.exports = router
