const EstadioModel = require('../models/estadio.model')

const EstadioController = {
  async listar(req, res) {
    const activos = req.query.activo === '1' || req.query.activo === 'true'
    const data = await EstadioModel.findAll(activos)
    res.json(data)
  },

  async obtener(req, res) {
    const estadio = await EstadioModel.findById(req.params.id)
    if (!estadio) return res.status(404).json({ error: 'Estadio no encontrado' })
    res.json(estadio)
  },

  async crear(req, res) {
    const { nombre, ciudad, direccion, capacidad, foto_url, activo } = req.body
    if (!nombre || !ciudad) {
      return res.status(400).json({ error: 'Nombre y ciudad son requeridos' })
    }
    const id = await EstadioModel.create({
      nombre: nombre.trim(),
      ciudad: ciudad.trim(),
      direccion: direccion?.trim(),
      capacidad,
      foto_url: foto_url?.trim(),
      activo,
    })
    res.status(201).json({ id_estadio: id })
  },

  async actualizar(req, res) {
    const { nombre, ciudad, direccion, capacidad, activo } = req.body
    if (!nombre || !ciudad) {
      return res.status(400).json({ error: 'Nombre y ciudad son requeridos' })
    }
    const affected = await EstadioModel.update(req.params.id, {
      nombre: nombre.trim(),
      ciudad: ciudad.trim(),
      direccion: direccion?.trim(),
      capacidad,
      activo,
    })
    if (!affected) return res.status(404).json({ error: 'Estadio no encontrado' })
    res.json({ ok: true })
  },

  async eliminar(req, res) {
    const affected = await EstadioModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Estadio no encontrado' })
    res.json({ ok: true })
  },
}

module.exports = EstadioController
