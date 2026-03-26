const router             = require('express').Router()
const db                 = require('../config/database')
const { verificarToken } = require('../middlewares/auth')
const { soloRoles }      = require('../middlewares/roles')

const soloAdmin = soloRoles('administrador')

// Listar temporadas
router.get('/', verificarToken, async (req, res) => {
  const [rows] = await db.query('SELECT * FROM temporada ORDER BY anio DESC, id_temporada DESC')
  res.json(rows)
})

// Obtener una temporada
router.get('/:id', verificarToken, async (req, res) => {
  const [rows] = await db.query('SELECT * FROM temporada WHERE id_temporada = ?', [req.params.id])
  if (!rows[0]) return res.status(404).json({ error: 'Temporada no encontrada' })
  res.json(rows[0])
})

// Crear temporada
router.post('/', verificarToken, soloAdmin, async (req, res) => {
  const { nombre, anio, categoria, costo_inscripcion } = req.body
  if (!nombre || !anio || !categoria) {
    return res.status(400).json({ error: 'nombre, anio y categoria son requeridos' })
  }
  const [result] = await db.query(
    'INSERT INTO temporada (nombre, anio, categoria, costo_inscripcion) VALUES (?,?,?,?)',
    [nombre, anio, categoria, costo_inscripcion || 0]
  )
  res.status(201).json({ id_temporada: result.insertId })
})

// Activar/desactivar temporada
router.patch('/:id/activa', verificarToken, soloAdmin, async (req, res) => {
  const { activa } = req.body
  await db.query('UPDATE temporada SET activa=? WHERE id_temporada=?', [activa ? 1 : 0, req.params.id])
  res.json({ ok: true })
})

// Actualizar temporada
router.put('/:id', verificarToken, soloAdmin, async (req, res) => {
  const { nombre, anio, categoria, costo_inscripcion, activa } = req.body
  const [result] = await db.query(
    'UPDATE temporada SET nombre=?, anio=?, categoria=?, costo_inscripcion=?, activa=? WHERE id_temporada=?',
    [nombre, anio, categoria, costo_inscripcion || 0, activa ? 1 : 0, req.params.id]
  )
  if (!result.affectedRows) return res.status(404).json({ error: 'Temporada no encontrada' })
  res.json({ ok: true })
})

// Eliminar temporada
router.delete('/:id', verificarToken, soloAdmin, async (req, res) => {
  const [result] = await db.query('DELETE FROM temporada WHERE id_temporada = ?', [req.params.id])
  if (!result.affectedRows) return res.status(404).json({ error: 'Temporada no encontrada' })
  res.json({ ok: true })
})

module.exports = router
