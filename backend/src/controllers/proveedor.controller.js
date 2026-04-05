const ProveedorModel = require('../models/proveedor.model')

const ProveedorController = {
  async listar(req, res) {
    const data = await ProveedorModel.findAll()
    res.json(data)
  },

  async obtener(req, res) {
    const item = await ProveedorModel.findById(req.params.id)
    if (!item) return res.status(404).json({ error: 'Proveedor no encontrado' })
    res.json(item)
  },

  async crear(req, res) {
    const { rif, nombre_proveedor, servicio } = req.body
    if (!rif || !nombre_proveedor || !servicio) {
      return res.status(400).json({ error: 'rif, nombre_proveedor y servicio son requeridos' })
    }
    try {
      const id = await ProveedorModel.create(req.body)
      res.status(201).json({ id_proveedor: id })
    } catch (e) {
      if (e.code === 'ER_DUP_ENTRY') return res.status(409).json({ error: 'Ya existe un proveedor con ese RIF' })
      throw e
    }
  },

  async actualizar(req, res) {
    const affected = await ProveedorModel.update(req.params.id, req.body)
    if (!affected) return res.status(404).json({ error: 'Proveedor no encontrado' })
    res.json({ ok: true })
  },

  async eliminar(req, res) {
    const affected = await ProveedorModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Proveedor no encontrado' })
    res.json({ ok: true })
  },
}

module.exports = ProveedorController
