const UsuarioModel = require('../models/usuario.model')
const bcrypt       = require('bcryptjs')

const UsuariosController = {
  async listar(req, res) {
    const usuarios = await UsuarioModel.findAllNonPublico()
    res.json(usuarios)
  },

  async actualizarRol(req, res) {
    const { rol } = req.body
    if (!rol) return res.status(400).json({ error: 'rol es requerido' })

    // No permitir degradar al propio admin
    if (Number(req.params.id) === req.usuario.id && rol !== 'administrador') {
      return res.status(403).json({ error: 'No puedes cambiar tu propio rol de administrador' })
    }

    try {
      const affected = await UsuarioModel.updateRol(req.params.id, rol)
      if (!affected) return res.status(404).json({ error: 'Usuario no encontrado' })
      res.json({ ok: true })
    } catch (e) {
      res.status(400).json({ error: e.message })
    }
  },

  async toggleActivo(req, res) {
    const usuario = await UsuarioModel.findById(req.params.id)
    if (!usuario) return res.status(404).json({ error: 'Usuario no encontrado' })
    if (usuario.id_usuario === req.usuario.id) {
      return res.status(403).json({ error: 'No puedes desactivar tu propia cuenta' })
    }
    await UsuarioModel.updateActivo(req.params.id, !usuario.activo)
    res.json({ ok: true, activo: !usuario.activo })
  },

  async resetPassword(req, res) {
    const { password } = req.body
    if (!password || password.length < 6) {
      return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' })
    }
    const password_hash = await bcrypt.hash(password, 10)
    const db = require('../config/database')
    const [result] = await db.query(
      'UPDATE usuario SET password_hash=? WHERE id_usuario=?',
      [password_hash, req.params.id]
    )
    if (!result.affectedRows) return res.status(404).json({ error: 'Usuario no encontrado' })
    res.json({ ok: true })
  },

  async eliminar(req, res) {
    if (Number(req.params.id) === req.usuario.id) {
      return res.status(403).json({ error: 'No puedes eliminar tu propia cuenta' })
    }
    const affected = await UsuarioModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Usuario no encontrado' })
    res.json({ ok: true })
  },

  async crear(req, res) {
    const { nombre, email, password, rol } = req.body
    if (!nombre || !email || !password) {
      return res.status(400).json({ error: 'nombre, email y password son requeridos' })
    }
    // Admin cannot create publico users through this endpoint
    const ROLES_ADMIN = ['administrador', 'dueno', 'caja', 'anotador']
    if (!ROLES_ADMIN.includes(rol)) {
      return res.status(400).json({ error: 'Rol inválido. Use: administrador, dueno, caja, anotador' })
    }
    const existe = await UsuarioModel.findByEmail(email)
    if (existe) return res.status(409).json({ error: 'Email ya registrado' })

    const bcrypt = require('bcryptjs')
    const password_hash = await bcrypt.hash(password, 10)
    const id = await UsuarioModel.create({ nombre, email, password_hash, rol })
    res.status(201).json({ id_usuario: id })
  },
}

module.exports = UsuariosController
