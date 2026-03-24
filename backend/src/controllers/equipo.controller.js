const EquipoModel = require('../models/equipo.model')

const EquipoController = {
  async listar(req, res) {
    const equipos = await EquipoModel.findAll()
    res.json(equipos)
  },

  async obtener(req, res) {
    const equipo = await EquipoModel.findById(req.params.id)
    if (!equipo) return res.status(404).json({ error: 'Equipo no encontrado' })
    res.json(equipo)
  },

  async jugadores(req, res) {
    const jugadores = await EquipoModel.findJugadores(req.params.id)
    res.json(jugadores)
  },

  async crear(req, res) {
    const { nombre_equipo, entrenador, responsable, email, telefono } = req.body
    if (!nombre_equipo || !entrenador || !responsable) {
      return res.status(400).json({ error: 'nombre_equipo, entrenador y responsable son requeridos' })
    }
    const id = await EquipoModel.create({ nombre_equipo, entrenador, responsable, email, telefono })
    res.status(201).json({ id_equipo: id })
  },

  async actualizar(req, res) {
    const affected = await EquipoModel.update(req.params.id, req.body)
    if (!affected) return res.status(404).json({ error: 'Equipo no encontrado' })
    res.json({ ok: true })
  },

  async eliminar(req, res) {
    const affected = await EquipoModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Equipo no encontrado' })
    res.json({ ok: true })
  },
}

module.exports = EquipoController
