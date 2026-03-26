const db = require('../config/database')

const PartidoModel = {
  async findAll(id_temporada) {
    const base = `
      SELECT p.*,
             ec.nombre_equipo AS equipo_casa,
             ev.nombre_equipo AS equipo_visitante,
             t.nombre         AS temporada
      FROM partido p
      JOIN equipo ec    ON p.id_equipo_casa      = ec.id_equipo
      JOIN equipo ev    ON p.id_equipo_visitante  = ev.id_equipo
      JOIN temporada t  ON p.id_temporada         = t.id_temporada`
    if (id_temporada) {
      const [rows] = await db.query(base + ' WHERE p.id_temporada = ? ORDER BY p.fecha_juego, p.hora_juego', [id_temporada])
      return rows
    }
    const [rows] = await db.query(base + ' ORDER BY p.fecha_juego, p.hora_juego')
    return rows
  },

  async findById(id) {
    const [rows] = await db.query(
      `SELECT p.*,
              ec.nombre_equipo AS equipo_casa,
              ev.nombre_equipo AS equipo_visitante
       FROM partido p
       JOIN equipo ec ON p.id_equipo_casa     = ec.id_equipo
       JOIN equipo ev ON p.id_equipo_visitante = ev.id_equipo
       WHERE p.id_partido = ?`,
      [id]
    )
    return rows[0] || null
  },

  async create({ id_temporada, id_equipo_casa, id_equipo_visitante, fecha_juego, hora_juego, lugar, innings_programados }) {
    const [result] = await db.query(
      `INSERT INTO partido (id_temporada, id_equipo_casa, id_equipo_visitante, fecha_juego, hora_juego, lugar, innings_programados)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [id_temporada, id_equipo_casa, id_equipo_visitante, fecha_juego, hora_juego, lugar || null, innings_programados || 9]
    )
    return result.insertId
  },

  async updateEstado(id, estado) {
    const [result] = await db.query('UPDATE partido SET estado=? WHERE id_partido=?', [estado, id])
    return result.affectedRows
  },

  async delete(id) {
    const [result] = await db.query('DELETE FROM partido WHERE id_partido = ?', [id])
    return result.affectedRows
  },

  async findLineup(id_partido) {
    const [rows] = await db.query(
      `SELECT l.*, j.nombre, j.apellido, j.posicion, e.nombre_equipo
       FROM lineup l
       JOIN jugador j ON l.id_jugador = j.id_jugador
       JOIN equipo  e ON l.id_equipo  = e.id_equipo
       WHERE l.id_partido = ?
       ORDER BY e.id_equipo, l.orden_bateo`,
      [id_partido]
    )
    return rows
  },

  async setLineup(entries) {
    // entries: [{ id_partido, id_jugador, id_equipo, orden_bateo, posicion_juego, es_titular }]
    const values = entries.map(e => [e.id_partido, e.id_jugador, e.id_equipo, e.orden_bateo, e.posicion_juego, e.es_titular ?? 1])
    await db.query(
      `INSERT INTO lineup (id_partido, id_jugador, id_equipo, orden_bateo, posicion_juego, es_titular)
       VALUES ?
       ON DUPLICATE KEY UPDATE orden_bateo=VALUES(orden_bateo), posicion_juego=VALUES(posicion_juego), es_titular=VALUES(es_titular)`,
      [values]
    )
  },
}

module.exports = PartidoModel
