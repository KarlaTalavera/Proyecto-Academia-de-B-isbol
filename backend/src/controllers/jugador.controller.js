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

  // --- NUEVAS FUNCIONES DE TRANSFERENCIA ---
  
  async solicitarTransferencia(req, res) {
    // Asumimos que tu middleware de auth inyecta req.usuario
    const { rol, id_equipo } = req.usuario || {};
    const { id } = req.params; // ID del jugador
    const { id_equipo_destino } = req.body;

    // Validación estricta: Solo dueños
    if (rol !== 'dueno') {
      return res.status(403).json({ error: 'Solo los dueños de equipo pueden transferir jugadores' });
    }

    try {
      const jugador = await JugadorModel.findById(id);
      
      // Verificamos que el jugador exista y que pertenezca al equipo del dueño que hace la petición
      if (!jugador || jugador.id_equipo !== id_equipo) {
        return res.status(403).json({ error: 'El jugador no pertenece a tu equipo' });
      }

      await JugadorModel.solicitarTransferencia(id, id_equipo, id_equipo_destino);
      res.json({ ok: true, mensaje: 'Solicitud de transferencia enviada con éxito' });
    } catch (e) {
      console.error('Error en transferencia:', e);
      res.status(500).json({ error: 'Error al solicitar transferencia' });
    }
  },

  async obtenerPendientes(req, res) {
    const { rol, id_equipo } = req.usuario || {};
    
    // Si no es dueño, simplemente retornamos un arreglo vacío
    if (rol !== 'dueno') {
      return res.json([]); 
    }

    try {
      const pendientes = await JugadorModel.getTransferenciasPendientes(id_equipo);
      res.json(pendientes);
    } catch (e) {
      console.error('Error al buscar transferencias:', e);
      res.status(500).json({ error: 'Error al buscar transferencias' });
    }
  },

  async resolverTransferencia(req, res) {
    const { rol, id_equipo } = req.usuario || {};
    const { id_transferencia, estado, id_jugador } = req.body; // estado será 'aceptada' o 'rechazada'

    // Solo el dueño del equipo destino puede aceptar o rechazar
    if (rol !== 'dueno') {
      return res.status(403).json({ error: 'Solo los dueños pueden aceptar o rechazar transferencias' });
    }

    try {
      await JugadorModel.resolverTransferencia(id_transferencia, estado, id_jugador, id_equipo);
      res.json({ ok: true });
    } catch (e) {
      console.error('Error resolviendo transferencia:', e);
      res.status(500).json({ error: 'Error al resolver la transferencia' });
    }
  }
}

module.exports = JugadorController