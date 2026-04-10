const db = require('../config/database')

const InscripcionModel = {
  async findAll(id_temporada) {
    const base = `
      SELECT i.*, e.nombre_equipo, t.nombre AS temporada, t.costo_inscripcion
      FROM inscripcion i
      JOIN equipo    e ON i.id_equipo    = e.id_equipo
      JOIN temporada t ON i.id_temporada = t.id_temporada`
    if (id_temporada) {
      const [rows] = await db.query(base + ' WHERE i.id_temporada=? ORDER BY i.fecha_inscripcion DESC', [id_temporada])
      return rows
    }
    const [rows] = await db.query(base + ' ORDER BY i.fecha_inscripcion DESC')
    return rows
  },

  async findById(id) {
    const [rows] = await db.query(
      `SELECT i.*, e.nombre_equipo, t.nombre AS temporada, t.costo_inscripcion
       FROM inscripcion i
       JOIN equipo    e ON i.id_equipo    = e.id_equipo
       JOIN temporada t ON i.id_temporada = t.id_temporada
       WHERE i.id_inscripcion = ?`,
      [id]
    )
    return rows[0] || null
  },

  async create({ id_equipo, id_temporada, fecha_inscripcion, estado_pago, monto_pagado, observaciones }) {
    const [result] = await db.query(
      `INSERT INTO inscripcion (id_equipo, id_temporada, fecha_inscripcion, estado_pago, monto_pagado, observaciones)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [id_equipo, id_temporada, fecha_inscripcion, estado_pago || 'pendiente', monto_pagado || 0, observaciones || null]
    )
    return result.insertId
  },

  async update(id, { id_equipo, id_temporada, fecha_inscripcion, estado_pago, monto_pagado, observaciones }) {
    const [result] = await db.query(
      `UPDATE inscripcion SET id_equipo=?, id_temporada=?, fecha_inscripcion=?, estado_pago=?, monto_pagado=?, observaciones=?
       WHERE id_inscripcion=?`,
      [id_equipo, id_temporada, fecha_inscripcion, estado_pago, monto_pagado || 0, observaciones || null, id]
    )
    return result.affectedRows
  },

  async delete(id) {
    const [result] = await db.query('DELETE FROM inscripcion WHERE id_inscripcion = ?', [id])
    return result.affectedRows
  },
}

module.exports = InscripcionModel
