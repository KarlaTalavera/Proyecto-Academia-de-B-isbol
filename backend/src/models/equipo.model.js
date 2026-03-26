const db = require('../config/database')

const EquipoModel = {
  async findAll() {
    const [rows] = await db.query('SELECT * FROM equipo ORDER BY nombre_equipo')
    return rows
  },

  async findById(id) {
    const [rows] = await db.query('SELECT * FROM equipo WHERE id_equipo = ?', [id])
    return rows[0] || null
  },

  async create({ nombre_equipo, entrenador, responsable, email, telefono }) {
    const [result] = await db.query(
      'INSERT INTO equipo (nombre_equipo, entrenador, responsable, email, telefono) VALUES (?, ?, ?, ?, ?)',
      [nombre_equipo, entrenador, responsable, email || null, telefono || null]
    )
    return result.insertId
  },

  async update(id, { nombre_equipo, entrenador, responsable, email, telefono }) {
    const [result] = await db.query(
      'UPDATE equipo SET nombre_equipo=?, entrenador=?, responsable=?, email=?, telefono=? WHERE id_equipo=?',
      [nombre_equipo, entrenador, responsable, email || null, telefono || null, id]
    )
    return result.affectedRows
  },

  async delete(id) {
    const [result] = await db.query('DELETE FROM equipo WHERE id_equipo = ?', [id])
    return result.affectedRows
  },

  async findJugadores(id_equipo) {
    const [rows] = await db.query(
      'SELECT * FROM jugador WHERE id_equipo = ? ORDER BY apellido, nombre',
      [id_equipo]
    )
    return rows
  },
}

module.exports = EquipoModel
