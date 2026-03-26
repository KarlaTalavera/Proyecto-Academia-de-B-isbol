const PartidoModel   = require('../models/partido.model')
const DesempenoModel = require('../models/desempeno.model')
const db             = require('../config/database')

const PartidoController = {
  async listar(req, res) {
    const { temporada } = req.query
    const data = await PartidoModel.findAll(temporada || null)
    res.json(data)
  },

  async obtener(req, res) {
    const partido = await PartidoModel.findById(req.params.id)
    if (!partido) return res.status(404).json({ error: 'Partido no encontrado' })
    res.json(partido)
  },

  async crear(req, res) {
    const { id_temporada, id_equipo_casa, id_equipo_visitante, fecha_juego, hora_juego } = req.body
    if (!id_temporada || !id_equipo_casa || !id_equipo_visitante || !fecha_juego || !hora_juego) {
      return res.status(400).json({ error: 'id_temporada, equipos, fecha_juego y hora_juego son requeridos' })
    }
    const id = await PartidoModel.create(req.body)
    res.status(201).json({ id_partido: id })
  },

  async actualizarEstado(req, res) {
    const { estado } = req.body
    const validos = ['programado', 'en_curso', 'finalizado', 'suspendido']
    if (!validos.includes(estado)) {
      return res.status(400).json({ error: `Estado inválido. Valores: ${validos.join(', ')}` })
    }
    const affected = await PartidoModel.updateEstado(req.params.id, estado)
    if (!affected) return res.status(404).json({ error: 'Partido no encontrado' })
    res.json({ ok: true })
  },

  async eliminar(req, res) {
    const affected = await PartidoModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Partido no encontrado' })
    res.json({ ok: true })
  },

  // ── Lineup ────────────────────────────────────────────────
  async getLineup(req, res) {
    const data = await PartidoModel.findLineup(req.params.id)
    res.json(data)
  },

  async setLineup(req, res) {
    const { entries } = req.body
    if (!Array.isArray(entries) || !entries.length) {
      return res.status(400).json({ error: 'Se requiere array "entries"' })
    }
    await PartidoModel.setLineup(entries)
    res.json({ ok: true })
  },

  // ── Resultado ─────────────────────────────────────────────
  async getResultado(req, res) {
    const [rows] = await db.query('SELECT * FROM resultado WHERE id_partido = ?', [req.params.id])
    res.json(rows[0] || null)
  },

  async guardarResultado(req, res) {
    const id_partido = req.params.id
    const {
      carreras_home, carreras_visitantes, hits_home, hits_visitantes,
      errores_home, errores_visitantes, innings_totales,
      id_pitcher_ganador, id_pitcher_perdedor, id_pitcher_salvador, observaciones,
    } = req.body
    await db.query(
      `INSERT INTO resultado
         (id_partido, carreras_home, carreras_visitantes, hits_home, hits_visitantes,
          errores_home, errores_visitantes, innings_totales,
          id_pitcher_ganador, id_pitcher_perdedor, id_pitcher_salvador, observaciones)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
       ON DUPLICATE KEY UPDATE
         carreras_home=VALUES(carreras_home), carreras_visitantes=VALUES(carreras_visitantes),
         hits_home=VALUES(hits_home), hits_visitantes=VALUES(hits_visitantes),
         errores_home=VALUES(errores_home), errores_visitantes=VALUES(errores_visitantes),
         innings_totales=VALUES(innings_totales),
         id_pitcher_ganador=VALUES(id_pitcher_ganador), id_pitcher_perdedor=VALUES(id_pitcher_perdedor),
         id_pitcher_salvador=VALUES(id_pitcher_salvador), observaciones=VALUES(observaciones)`,
      [id_partido, carreras_home, carreras_visitantes, hits_home, hits_visitantes,
       errores_home, errores_visitantes, innings_totales,
       id_pitcher_ganador || null, id_pitcher_perdedor || null, id_pitcher_salvador || null,
       observaciones || null]
    )
    await PartidoModel.updateEstado(id_partido, 'finalizado')
    res.json({ ok: true })
  },

  // ── Desempeño individual ──────────────────────────────────
  async getDesempeno(req, res) {
    const [bateadores, pitchers] = await Promise.all([
      DesempenoModel.findBateadorByPartido(req.params.id),
      DesempenoModel.findPitcherByPartido(req.params.id),
    ])
    res.json({ bateadores, pitchers })
  },

  async guardarDesempenoBateador(req, res) {
    await DesempenoModel.upsertBateador({ ...req.body, id_partido: req.params.id })
    res.json({ ok: true })
  },

  async guardarDesempenoPitcher(req, res) {
    await DesempenoModel.upsertPitcher({ ...req.body, id_partido: req.params.id })
    res.json({ ok: true })
  },
}

module.exports = PartidoController
