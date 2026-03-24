const JugadorModel = require('../models/jugador.model')

const JugadorController = {
  async listar(req, res) {
    const jugadores = await JugadorModel.findAll()
    res.json(jugadores)
  },

  async obtener(req, res) {
    const jugador = await JugadorModel.findById(req.params.id)
    if (!jugador) return res.status(404).json({ error: 'Jugador no encontrado' })
    res.json(jugador)
  },

  async crear(req, res) {
    const { id_equipo, nombre, apellido, fecha_nacimiento, rol, posicion } = req.body
    if (!id_equipo || !nombre || !apellido || !fecha_nacimiento || !posicion) {
      return res.status(400).json({ error: 'id_equipo, nombre, apellido, fecha_nacimiento y posicion son requeridos' })
    }
    const id = await JugadorModel.create(req.body)
    res.status(201).json({ id_jugador: id })
  },

  async actualizar(req, res) {
    const affected = await JugadorModel.update(req.params.id, req.body)
    if (!affected) return res.status(404).json({ error: 'Jugador no encontrado' })
    res.json({ ok: true })
  },

  async eliminar(req, res) {
    const affected = await JugadorModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Jugador no encontrado' })
    res.json({ ok: true })
  },
}

module.exports = JugadorController
