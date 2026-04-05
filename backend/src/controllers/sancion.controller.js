const SancionModel = require('../models/sancion.model')

const SancionController = {
  async listar(req, res) {
    const data = await SancionModel.findAll(req.query.temporada || null)
    res.json(data)
  },

  async obtener(req, res) {
    const item = await SancionModel.findById(req.params.id)
    if (!item) return res.status(404).json({ error: 'Sanción no encontrada' })
    res.json(item)
  },

  async crear(req, res) {
    const { id_temporada, tipo, descripcion, fecha_sancion } = req.body
    if (!id_temporada || !tipo || !descripcion || !fecha_sancion) {
      return res.status(400).json({ error: 'id_temporada, tipo, descripcion y fecha_sancion son requeridos' })
    }
    const id = await SancionModel.create(req.body)
    res.status(201).json({ id_sancion: id })
  },

  async actualizar(req, res) {
    const affected = await SancionModel.update(req.params.id, req.body)
    if (!affected) return res.status(404).json({ error: 'Sanción no encontrada' })
    res.json({ ok: true })
  },

  async eliminar(req, res) {
    const affected = await SancionModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Sanción no encontrada' })
    res.json({ ok: true })
  },
}

module.exports = SancionController
