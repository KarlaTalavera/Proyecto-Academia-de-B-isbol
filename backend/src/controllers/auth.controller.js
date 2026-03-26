const bcrypt     = require('bcryptjs')
const jwt        = require('jsonwebtoken')
const UsuarioModel = require('../models/usuario.model')

const AuthController = {
  async login(req, res) {
    const { email, password } = req.body
    if (!email || !password) {
      return res.status(400).json({ error: 'Email y password requeridos' })
    }
    const usuario = await UsuarioModel.findByEmail(email)
    if (!usuario) return res.status(401).json({ error: 'Credenciales inválidas' })

    const ok = await bcrypt.compare(password, usuario.password_hash)
    if (!ok) return res.status(401).json({ error: 'Credenciales inválidas' })

    const token = jwt.sign(
      { id: usuario.id_usuario, rol: usuario.rol, nombre: usuario.nombre },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '8h' }
    )
    res.json({ token, rol: usuario.rol, nombre: usuario.nombre })
  },

  async registro(req, res) {
    const { nombre, email, password } = req.body
    if (!nombre || !email || !password) {
      return res.status(400).json({ error: 'nombre, email y password son requeridos' })
    }
    const existe = await UsuarioModel.findByEmail(email)
    if (existe) return res.status(409).json({ error: 'Email ya registrado' })

    const password_hash = await bcrypt.hash(password, 10)
    const id = await UsuarioModel.create({ nombre, email, password_hash, rol: 'publico' })
    res.status(201).json({ id_usuario: id })
  },

  async perfil(req, res) {
    const usuario = await UsuarioModel.findById(req.usuario.id)
    if (!usuario) return res.status(404).json({ error: 'Usuario no encontrado' })
    res.json(usuario)
  },
}

module.exports = AuthController
