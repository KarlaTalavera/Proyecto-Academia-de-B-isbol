const db = require('../config/database')

const EstadioModel = {
  async findAll(activos = false) {
    let sql = 'SELECT * FROM estadio'
    const params = []
    if (activos) {
      sql += ' WHERE activo = 1'
    }
    sql += ' ORDER BY nombre'
    const [rows] = await db.query(sql, params)
    return rows
  },

  async findById(id) {
    const [rows] = await db.query('SELECT * FROM estadio WHERE id_estadio = ?', [id])
    return rows[0] || null
  },

  async create({ nombre, ciudad, direccion, capacidad, foto_url, activo }) {
    const [result] = await db.query(
      `INSERT INTO estadio (nombre, ciudad, direccion, capacidad, activo)
       VALUES (?, ?, ?, ?, ?)`,
      [
        nombre,
        ciudad,
        direccion || null,
        Number(capacidad) || 0,
        activo === 0 || activo === '0' ? 0 : 1,
      ]
    )
    return result.insertId
  },

  async update(id, { nombre, ciudad, direccion, capacidad, activo }) {
    const [result] = await db.query(
      `UPDATE estadio SET
         nombre = ?,
         ciudad = ?,
         direccion = ?,
         capacidad = ?,
         activo = ?
       WHERE id_estadio = ?`,
      [
        nombre,
        ciudad,
        direccion || null,
        Number(capacidad) || 0,
        activo === 0 || activo === '0' ? 0 : 1,
        id,
      ]
    )
    return result.affectedRows
  },

  async delete(id) {
    const [result] = await db.query('DELETE FROM estadio WHERE id_estadio = ?', [id])
    return result.affectedRows
  },
}

module.exports = EstadioModel
