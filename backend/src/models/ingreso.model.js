const db = require('../config/database')

const IngresoModel = {
  async findAll(id_temporada) {
    const base = `
      SELECT i.*, e.nombre_equipo, t.nombre AS temporada
      FROM ingreso i
      JOIN equipo    e ON i.id_equipo    = e.id_equipo
      JOIN temporada t ON i.id_temporada = t.id_temporada`
    if (id_temporada) {
      const [rows] = await db.query(base + ' WHERE i.id_temporada=? ORDER BY i.fecha_ingreso DESC', [id_temporada])
      return rows
    }
    const [rows] = await db.query(base + ' ORDER BY i.fecha_ingreso DESC')
    return rows
  },

  async findById(id) {
    const [rows] = await db.query(
      `SELECT i.*, e.nombre_equipo, t.nombre AS temporada
       FROM ingreso i
       JOIN equipo    e ON i.id_equipo    = e.id_equipo
       JOIN temporada t ON i.id_temporada = t.id_temporada
       WHERE i.id_ingreso = ?`,
      [id]
    )
    return rows[0] || null
  },

  async create({ id_equipo, id_temporada, concepto, valor, fecha_ingreso, tipo_pago }) {
    const [result] = await db.query(
      `INSERT INTO ingreso (id_equipo, id_temporada, concepto, valor, fecha_ingreso, tipo_pago)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [id_equipo, id_temporada, concepto, valor, fecha_ingreso, tipo_pago || null]
    )
    return result.insertId
  },

  async update(id, { id_equipo, id_temporada, concepto, valor, fecha_ingreso, tipo_pago }) {
    const [result] = await db.query(
      `UPDATE ingreso SET id_equipo=?, id_temporada=?, concepto=?, valor=?, fecha_ingreso=?, tipo_pago=?
       WHERE id_ingreso=?`,
      [id_equipo, id_temporada, concepto, valor, fecha_ingreso, tipo_pago || null, id]
    )
    return result.affectedRows
  },

  async delete(id) {
    const [result] = await db.query('DELETE FROM ingreso WHERE id_ingreso = ?', [id])
    return result.affectedRows
  },

  async totalPorTemporada(id_temporada) {
    const [rows] = await db.query(
      'SELECT SUM(valor) AS total FROM ingreso WHERE id_temporada = ?',
      [id_temporada]
    )
    return rows[0].total || 0
  },
}

module.exports = IngresoModel
