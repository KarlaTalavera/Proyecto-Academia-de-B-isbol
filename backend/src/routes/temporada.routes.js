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
  const id = req.params.id

  // Verificar dependencias antes de borrar
  const [[{ inscripciones }]] = await db.query('SELECT COUNT(*) AS inscripciones FROM inscripcion WHERE id_temporada = ?', [id])
  const [[{ partidos }]]      = await db.query('SELECT COUNT(*) AS partidos      FROM partido      WHERE id_temporada = ?', [id])
  const [[{ ingresos }]]      = await db.query('SELECT COUNT(*) AS ingresos      FROM ingreso      WHERE id_temporada = ?', [id])
  const [[{ egresos }]]       = await db.query('SELECT COUNT(*) AS egresos       FROM egreso       WHERE id_temporada = ?', [id])
  const [[{ sanciones }]]     = await db.query('SELECT COUNT(*) AS sanciones     FROM sancion      WHERE id_temporada = ?', [id])

  const total = inscripciones + partidos + ingresos + egresos + sanciones
  if (total > 0) {
    return res.status(409).json({
      error: 'No se puede eliminar la temporada porque tiene datos registrados (inscripciones, partidos, finanzas o sanciones). Elimina esos registros primero.',
    })
  }

  const [result] = await db.query('DELETE FROM temporada WHERE id_temporada = ?', [id])
  if (!result.affectedRows) return res.status(404).json({ error: 'Temporada no encontrada' })
  res.json({ ok: true })
})

module.exports = router
