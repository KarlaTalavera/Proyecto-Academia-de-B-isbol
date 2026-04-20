const path             = require('path')
const fs               = require('fs')
const router           = require('express').Router()
const JugadorController = require('../controllers/jugador.controller')
const { verificarToken } = require('../middlewares/auth')
const { soloRoles }    = require('../middlewares/roles')
const upload           = require('../middlewares/upload')
const db               = require('../config/database')

router.get('/',    verificarToken, JugadorController.listar)
router.get('/:id', verificarToken, JugadorController.obtener)

router.post('/',      verificarToken, soloRoles('administrador', 'dueno'), JugadorController.crear)
router.put('/:id',    verificarToken, soloRoles('administrador', 'dueno'), JugadorController.actualizar)
router.delete('/:id', verificarToken, soloRoles('administrador', 'dueno'), JugadorController.eliminar)

// ── Foto del jugador ──────────────────────────────────────────
router.post('/:id/foto',
  verificarToken,
  soloRoles('administrador', 'dueno'),
  (req, _res, next) => { req.uploadPrefix = 'jugador'; next() },
  upload.single('foto'),
  async (req, res) => {
    if (!req.file) return res.status(400).json({ error: 'No se envió ningún archivo' })

    // Borrar foto anterior si existe
    const [[jugador]] = await db.query('SELECT foto_url FROM jugador WHERE id_jugador = ?', [req.params.id])
    if (jugador?.foto_url) {
      const oldPath = path.join(__dirname, '../../uploads', path.basename(jugador.foto_url))
      if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath)
    }

    const foto_url = `/uploads/${req.file.filename}`
    await db.query('UPDATE jugador SET foto_url = ? WHERE id_jugador = ?', [foto_url, req.params.id])
    res.json({ foto_url })
  }
)

router.delete('/:id/foto',
  verificarToken,
  soloRoles('administrador', 'dueno'),
  async (req, res) => {
    const [[jugador]] = await db.query('SELECT foto_url FROM jugador WHERE id_jugador = ?', [req.params.id])
    if (jugador?.foto_url) {
      const oldPath = path.join(__dirname, '../../uploads', path.basename(jugador.foto_url))
      if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath)
    }
    await db.query('UPDATE jugador SET foto_url = NULL WHERE id_jugador = ?', [req.params.id])
    res.json({ ok: true })
  }
)

module.exports = router
