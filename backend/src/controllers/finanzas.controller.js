const IngresoModel = require('../models/ingreso.model')
const EgresoModel  = require('../models/egreso.model')

const FinanzasController = {
  // ── INGRESOS ──────────────────────────────────────────────
  async listarIngresos(req, res) {
    const { temporada } = req.query
    const data = await IngresoModel.findAll(temporada || null)
    res.json(data)
  },

  async obtenerIngreso(req, res) {
    const ingreso = await IngresoModel.findById(req.params.id)
    if (!ingreso) return res.status(404).json({ error: 'Ingreso no encontrado' })
    res.json(ingreso)
  },

  async crearIngreso(req, res) {
    const { id_equipo, id_temporada, concepto, valor, fecha_ingreso } = req.body
    if (!id_equipo || !id_temporada || !concepto || !valor || !fecha_ingreso) {
      return res.status(400).json({ error: 'id_equipo, id_temporada, concepto, valor y fecha_ingreso son requeridos' })
    }
    const id = await IngresoModel.create(req.body)
    res.status(201).json({ id_ingreso: id })
  },

  async actualizarIngreso(req, res) {
    const affected = await IngresoModel.update(req.params.id, req.body)
    if (!affected) return res.status(404).json({ error: 'Ingreso no encontrado' })
    res.json({ ok: true })
  },

  async eliminarIngreso(req, res) {
    const affected = await IngresoModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Ingreso no encontrado' })
    res.json({ ok: true })
  },

  // ── EGRESOS ───────────────────────────────────────────────
  async listarEgresos(req, res) {
    const { temporada } = req.query
    const data = await EgresoModel.findAll(temporada || null)
    res.json(data)
  },

  async obtenerEgreso(req, res) {
    const egreso = await EgresoModel.findById(req.params.id)
    if (!egreso) return res.status(404).json({ error: 'Egreso no encontrado' })
    res.json(egreso)
  },

  async crearEgreso(req, res) {
    const { id_temporada, nota_gastos, gasto, fecha_egreso } = req.body
    if (!id_temporada || !nota_gastos || !gasto || !fecha_egreso) {
      return res.status(400).json({ error: 'id_temporada, nota_gastos, gasto y fecha_egreso son requeridos' })
    }
    const id = await EgresoModel.create(req.body)
    res.status(201).json({ id_egreso: id })
  },

  async actualizarEgreso(req, res) {
    const affected = await EgresoModel.update(req.params.id, req.body)
    if (!affected) return res.status(404).json({ error: 'Egreso no encontrado' })
    res.json({ ok: true })
  },

  async eliminarEgreso(req, res) {
    const affected = await EgresoModel.delete(req.params.id)
    if (!affected) return res.status(404).json({ error: 'Egreso no encontrado' })
    res.json({ ok: true })
  },

  // ── BALANCE ───────────────────────────────────────────────
  async balance(req, res) {
    const { temporada } = req.query
    if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' })
    const data = await EgresoModel.balance(temporada)
    res.json(data)
  },
}

module.exports = FinanzasController
