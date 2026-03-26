const db = require('../config/database')

const ROLES_VALIDOS = ['administrador', 'dueno', 'caja', 'anotador', 'publico']

const UsuarioModel = {
  async findByEmail(email) {
    const [rows] = await db.query('SELECT * FROM usuario WHERE email = ? AND activo = 1', [email])
    return rows[0] || null
  },

  async findById(id) {
    const [rows] = await db.query(
      'SELECT id_usuario, nombre, email, rol, id_jugador, activo, created_at FROM usuario WHERE id_usuario = ?',
      [id]
    )
    return rows[0] || null
  },

  async findAll() {
    const [rows] = await db.query(
      'SELECT id_usuario, nombre, email, rol, activo, created_at FROM usuario ORDER BY created_at DESC'
    )
    return rows
  },

  async findAllNonPublico() {
    const [rows] = await db.query(
      "SELECT id_usuario, nombre, email, rol, activo, created_at FROM usuario WHERE rol != 'publico' ORDER BY created_at DESC"
    )
    return rows
  },

  async create({ nombre, email, password_hash, rol, id_jugador }) {
    if (rol && !ROLES_VALIDOS.includes(rol)) rol = 'publico'
    const [result] = await db.query(
      'INSERT INTO usuario (nombre, email, password_hash, rol, id_jugador) VALUES (?, ?, ?, ?, ?)',
      [nombre, email, password_hash, rol || 'publico', id_jugador || null]
    )
    return result.insertId
  },

  async updateRol(id, rol) {
    if (!ROLES_VALIDOS.includes(rol)) throw new Error('Rol inválido')
    const [result] = await db.query('UPDATE usuario SET rol=? WHERE id_usuario=?', [rol, id])
    return result.affectedRows
  },

  async updateActivo(id, activo) {
    const [result] = await db.query('UPDATE usuario SET activo=? WHERE id_usuario=?', [activo ? 1 : 0, id])
    return result.affectedRows
  },

  async delete(id) {
    const [result] = await db.query('DELETE FROM usuario WHERE id_usuario = ?', [id])
    return result.affectedRows
  },
}

module.exports = UsuarioModel
