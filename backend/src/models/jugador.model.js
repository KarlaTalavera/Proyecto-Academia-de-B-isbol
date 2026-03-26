const db = require('../config/database')

const JugadorModel = {
  async findAll() {
    const [rows] = await db.query(
      `SELECT j.*, e.nombre_equipo
       FROM jugador j
       JOIN equipo e ON j.id_equipo = e.id_equipo
       ORDER BY j.apellido, j.nombre`
    )
    return rows
  },

  async findById(id) {
    const [rows] = await db.query(
      `SELECT j.*, e.nombre_equipo
       FROM jugador j
       JOIN equipo e ON j.id_equipo = e.id_equipo
       WHERE j.id_jugador = ?`,
      [id]
    )
    return rows[0] || null
  },

  async create({ id_equipo, cedula, nombre, apellido, fecha_nacimiento, rol, posicion, brazo_dominante }) {
    const [result] = await db.query(
      `INSERT INTO jugador (id_equipo, cedula, nombre, apellido, fecha_nacimiento, rol, posicion, brazo_dominante)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [id_equipo, cedula || null, nombre, apellido, fecha_nacimiento, rol, posicion, brazo_dominante || null]
    )
    return result.insertId
  },

  async update(id, { id_equipo, cedula, nombre, apellido, fecha_nacimiento, rol, posicion, brazo_dominante, activo }) {
    const [result] = await db.query(
      `UPDATE jugador SET id_equipo=?, cedula=?, nombre=?, apellido=?, fecha_nacimiento=?,
       rol=?, posicion=?, brazo_dominante=?, activo=? WHERE id_jugador=?`,
      [id_equipo, cedula || null, nombre, apellido, fecha_nacimiento, rol, posicion, brazo_dominante || null, activo ?? 1, id]
    )
    return result.affectedRows
  },

  async delete(id) {
    const [result] = await db.query('DELETE FROM jugador WHERE id_jugador = ?', [id])
    return result.affectedRows
  },
}

module.exports = JugadorModel
