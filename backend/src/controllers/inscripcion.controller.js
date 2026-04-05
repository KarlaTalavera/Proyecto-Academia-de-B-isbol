const InscripcionModel = require('../models/inscripcion.model')

const InscripcionController = {
  async listar(req, res) {
    const data = await InscripcionModel.findAll(req.query.temporada || null)
    res.json(data)
  },

  async obtener(req, res) {
    const item = await InscripcionModel.findById(req.params.id)
    if (!item) return res.status(404).json({ error: 'Inscripción no encontrada' })
    res.json(item)
  },

  async crear(req, res) {
    const { id_equipo, id_temporada, fecha_inscripcion } = req.body
    if (!id_equipo || !id_temporada || !fecha_inscripcion) {
      return res.status(400).json({ error: 'id_equipo, id_temporada y fecha_inscripcion son requeridos' })
    }
    try {
      const id = await InscripcionModel.create(req.body)
      res.status(201).json({ id_inscripcion: id })
    } catch (e) {
      if (e.code === 'ER_DUP_ENTRY') return res.status(409).json({ error: 'Este equipo ya está inscrito en esta temporada' })
      throw e
    }
  },

  async actualizar(req, res) {
    const affected = await InscripcionModel.update(req.params.id, req.body)
    if (!affected) return res.status(404).json({ error: 'Inscripción no encontrada' })
    res.json({ ok: true })
  },

  async eliminar(req, res) {
    const affected = await InscripcionModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Inscripción no encontrada' })
    res.json({ ok: true })
  },
}

module.exports = InscripcionController
