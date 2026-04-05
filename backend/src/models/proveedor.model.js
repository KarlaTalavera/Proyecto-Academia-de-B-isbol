const db = require('../config/database')

const ProveedorModel = {
  async findAll() {
    const [rows] = await db.query('SELECT * FROM proveedor ORDER BY nombre_proveedor')
    return rows
  },

  async findById(id) {
    const [rows] = await db.query('SELECT * FROM proveedor WHERE id_proveedor = ?', [id])
    return rows[0] || null
  },

  async create({ rif, nombre_proveedor, servicio, telefono, email }) {
    const [result] = await db.query(
      'INSERT INTO proveedor (rif, nombre_proveedor, servicio, telefono, email) VALUES (?, ?, ?, ?, ?)',
      [rif, nombre_proveedor, servicio, telefono || null, email || null]
    )
    return result.insertId
  },

  async update(id, { rif, nombre_proveedor, servicio, telefono, email, activo }) {
    const [result] = await db.query(
      'UPDATE proveedor SET rif=?, nombre_proveedor=?, servicio=?, telefono=?, email=?, activo=? WHERE id_proveedor=?',
      [rif, nombre_proveedor, servicio, telefono || null, email || null, activo ?? 1, id]
    )
    return result.affectedRows
  },

  async delete(id) {
    const [result] = await db.query('DELETE FROM proveedor WHERE id_proveedor = ?', [id])
    return result.affectedRows
  },
}

module.exports = ProveedorModel
