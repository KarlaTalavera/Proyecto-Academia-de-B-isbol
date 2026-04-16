const db = require('../config/database')

const EgresoModel = {
  async findAll(id_temporada) {
    const base = `
      SELECT e.*, t.nombre AS temporada,
             p.nombre_proveedor, p.rif AS proveedor_rif
      FROM egreso e
      JOIN temporada t ON e.id_temporada = t.id_temporada
      LEFT JOIN proveedor p ON e.id_proveedor = p.id_proveedor`
    if (id_temporada) {
      const [rows] = await db.query(base + ' WHERE e.id_temporada=? ORDER BY e.fecha_egreso DESC', [id_temporada])
      return rows
    }
    const [rows] = await db.query(base + ' ORDER BY e.fecha_egreso DESC')
    return rows
  },

  async findById(id) {
    const [rows] = await db.query(
      `SELECT e.*, t.nombre AS temporada,
              p.rif AS proveedor_rif, p.nombre_proveedor, p.servicio
       FROM egreso e
       JOIN temporada t ON e.id_temporada = t.id_temporada
       LEFT JOIN proveedor p ON e.id_proveedor = p.id_proveedor
       WHERE e.id_egreso = ?`,
      [id]
    )
    return rows[0] || null
  },

  async create({ id_temporada, id_proveedor, nota_gastos, gasto, fecha_egreso, tipo_pago }) {
    const [result] = await db.query(
      'INSERT INTO egreso (id_temporada, id_proveedor, nota_gastos, gasto, fecha_egreso, tipo_pago) VALUES (?, ?, ?, ?, ?, ?)',
      [id_temporada, id_proveedor || null, nota_gastos, gasto, fecha_egreso, tipo_pago || null]
    )
    return result.insertId
  },

  async update(id, { id_temporada, id_proveedor, nota_gastos, gasto, fecha_egreso, tipo_pago }) {
    const [result] = await db.query(
      'UPDATE egreso SET id_temporada=?, id_proveedor=?, nota_gastos=?, gasto=?, fecha_egreso=?, tipo_pago=? WHERE id_egreso=?',
      [id_temporada, id_proveedor || null, nota_gastos, gasto, fecha_egreso, tipo_pago || null, id]
    )
    return result.affectedRows
  },

  async delete(id) {
    const [result] = await db.query('DELETE FROM egreso WHERE id_egreso = ?', [id])
    return result.affectedRows
  },

  async totalPorTemporada(id_temporada) {
    const [rows] = await db.query(
      'SELECT SUM(gasto) AS total FROM egreso WHERE id_temporada = ?',
      [id_temporada]
    )
    return rows[0].total || 0
  },

  // Resumen balance: ingresos - egresos
  async balance(id_temporada) {
    const [rows] = await db.query(
      `SELECT
         (SELECT COALESCE(SUM(valor), 0) FROM ingreso WHERE id_temporada = ?) AS total_ingresos,
         (SELECT COALESCE(SUM(gasto),  0) FROM egreso  WHERE id_temporada = ?) AS total_egresos`,
      [id_temporada, id_temporada]
    )
    const { total_ingresos, total_egresos } = rows[0]
    return { total_ingresos, total_egresos, balance: total_ingresos - total_egresos }
  },
}

module.exports = EgresoModel
