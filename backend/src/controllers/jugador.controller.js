const JugadorModel = require('../models/jugador.model')

function validarCedula(cedula) {
  if (!cedula) return null
  const c = cedula.toUpperCase()
  if (!/^[VE]-\d{1,8}$/.test(c)) return 'Formato de cédula inválido. Use V-00000000 o E-00000000'
  const num = parseInt(c.split('-')[1], 10)
  if (num < 1 || num > 34000000) return 'El número de cédula debe estar entre 1 y 34.000.000'
  return null
}

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
    const err = validarCedula(req.body.cedula)
    if (err) return res.status(400).json({ error: err })
    const id = await JugadorModel.create(req.body)
    res.status(201).json({ id_jugador: id })
  },

  async actualizar(req, res) {
    const err = validarCedula(req.body.cedula)
    if (err) return res.status(400).json({ error: err })
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
