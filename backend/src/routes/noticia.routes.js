const router  = require('express').Router()
const db      = require('../config/database')
const path    = require('path')
const fs      = require('fs')
const multer  = require('multer')
const { verificarToken } = require('../middlewares/auth')
const { soloRoles }      = require('../middlewares/roles')

const soloGestion = soloRoles('administrador', 'dueno')

const uploadsDir = path.join(__dirname, '../../uploads')
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadsDir),
  filename:    (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase()
    cb(null, `noticia-${Date.now()}${ext}`)
  },
})
const upload = multer({
  storage,
  fileFilter: (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase()
    if (['.jpg', '.jpeg', '.png'].includes(ext)) cb(null, true)
    else cb(new Error('Solo se permiten JPG y PNG'))
  },
  limits: { fileSize: 5 * 1024 * 1024 },
})

// ── GET todas (admin) ─────────────────────────────────────────
router.get('/', verificarToken, soloGestion, async (req, res) => {
  const [rows] = await db.query(
    'SELECT * FROM noticia ORDER BY created_at DESC'
  )
  res.json(rows)
})

// ── POST crear ────────────────────────────────────────────────
router.post('/', verificarToken, soloGestion, upload.single('foto'), async (req, res) => {
  const { titulo, contenido, fecha_publicacion, activa } = req.body
  const foto_url = req.file ? `/uploads/${req.file.filename}` : null
  const [result] = await db.query(
    `INSERT INTO noticia (titulo, contenido, foto_url, fecha_publicacion, activa)
     VALUES (?, ?, ?, ?, ?)`,
    [titulo, contenido || null, foto_url, fecha_publicacion || null, activa ?? 1]
  )
  res.status(201).json({ id_noticia: result.insertId, foto_url })
})

// ── PUT actualizar texto ──────────────────────────────────────
router.put('/:id', verificarToken, soloGestion, async (req, res) => {
  const { titulo, contenido, fecha_publicacion, activa } = req.body
  await db.query(
    `UPDATE noticia SET titulo=?, contenido=?, fecha_publicacion=?, activa=?
     WHERE id_noticia=?`,
    [titulo, contenido || null, fecha_publicacion || null, activa ?? 1, req.params.id]
  )
  res.json({ ok: true })
})

// ── PATCH cambiar foto ────────────────────────────────────────
router.patch('/:id/foto', verificarToken, soloGestion, upload.single('foto'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No se envió ninguna foto' })
  const [[old]] = await db.query(
    'SELECT foto_url FROM noticia WHERE id_noticia=?', [req.params.id]
  )
  if (old?.foto_url) {
    const oldPath = path.join(__dirname, '../..', old.foto_url)
    if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath)
  }
  const foto_url = `/uploads/${req.file.filename}`
  await db.query('UPDATE noticia SET foto_url=? WHERE id_noticia=?', [foto_url, req.params.id])
  res.json({ foto_url })
})

// ── DELETE ────────────────────────────────────────────────────
router.delete('/:id', verificarToken, soloGestion, async (req, res) => {
  const [[n]] = await db.query(
    'SELECT foto_url FROM noticia WHERE id_noticia=?', [req.params.id]
  )
  if (n?.foto_url) {
    const p = path.join(__dirname, '../..', n.foto_url)
    if (fs.existsSync(p)) fs.unlinkSync(p)
  }
  await db.query('DELETE FROM noticia WHERE id_noticia=?', [req.params.id])
  res.json({ ok: true })
})

module.exports = router
