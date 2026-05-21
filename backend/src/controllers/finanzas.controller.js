const db           = require('../config/database')
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
  const { temporada, fechaDesde, fechaHasta, servicios } = req.query;
  if (!temporada) return res.status(400).json({ error: 'Parámetro temporada requerido' });

  let serviciosArray = [];
  if (servicios) {
    serviciosArray = Array.isArray(servicios) ? servicios : servicios.split(',');
    serviciosArray = serviciosArray.map(s => s.trim());
  }

  // 1. TOTAL INGRESOS
  let ingresosQuery = `
    SELECT SUM(valor) as total
    FROM ingreso
    WHERE id_temporada = ?
  `;
  const paramsIng = [temporada];
  if (fechaDesde) {
    ingresosQuery += ` AND fecha_ingreso >= ?`;
    paramsIng.push(fechaDesde);
  }
  if (fechaHasta) {
    ingresosQuery += ` AND fecha_ingreso <= ?`;
    paramsIng.push(fechaHasta);
  }
  const [ingresoTotal] = await db.query(ingresosQuery, paramsIng);
  const totalIngresos = Number(ingresoTotal[0]?.total || 0);

  // 2. INGRESOS POR CONCEPTO
  let ingresosConceptoQuery = `
    SELECT concepto as categoria, SUM(valor) as total
    FROM ingreso
    WHERE id_temporada = ?
  `;
  const paramsConc = [temporada];
  if (fechaDesde) {
    ingresosConceptoQuery += ` AND fecha_ingreso >= ?`;
    paramsConc.push(fechaDesde);
  }
  if (fechaHasta) {
    ingresosConceptoQuery += ` AND fecha_ingreso <= ?`;
    paramsConc.push(fechaHasta);
  }
  ingresosConceptoQuery += ` GROUP BY concepto ORDER BY total DESC`;
  const [ingresosConcepto] = await db.query(ingresosConceptoQuery, paramsConc);

  // 3. EGRESOS CON JOIN (¡tabla se llama 'egreso', no 'egresos'!)
  let egresosQuery = `
    SELECT e.id_egreso, e.fecha_egreso, e.nota_gastos, e.gasto, 
           COALESCE(p.nombre_proveedor, 'Sin proveedor') as proveedor,
           COALESCE(p.servicio, 'Sin servicio') as servicio
    FROM egreso e
    LEFT JOIN proveedor p ON e.id_proveedor = p.id_proveedor
    WHERE e.id_temporada = ?
  `;
  const paramsEgr = [temporada];
  if (fechaDesde) {
    egresosQuery += ` AND e.fecha_egreso >= ?`;
    paramsEgr.push(fechaDesde);
  }
  if (fechaHasta) {
    egresosQuery += ` AND e.fecha_egreso <= ?`;
    paramsEgr.push(fechaHasta);
  }
  if (serviciosArray.length > 0) {
    egresosQuery += ` AND p.servicio IN (${serviciosArray.map(() => '?').join(',')})`;
    paramsEgr.push(...serviciosArray);
  }
  const [egresos] = await db.query(egresosQuery, paramsEgr);

  const totalEgresos = egresos.reduce((sum, e) => sum + Number(e.gasto), 0);

  // Agrupar por proveedor
  const proveedorMap = new Map();
  for (const eg of egresos) {
    const proveedor = eg.proveedor;
    const current = proveedorMap.get(proveedor) || 0;
    proveedorMap.set(proveedor, current + Number(eg.gasto));
  }
  const egresosPorProveedor = Array.from(proveedorMap.entries()).map(([proveedor, total]) => ({ proveedor, total }));

  // Agrupar por servicio
  const servicioMap = new Map();
  for (const eg of egresos) {
    const servicio = eg.servicio;
    const current = servicioMap.get(servicio) || 0;
    servicioMap.set(servicio, current + Number(eg.gasto));
  }
  const egresosPorServicio = Array.from(servicioMap.entries()).map(([servicio, total]) => ({ servicio, total }));

  res.json({
    total_ingresos: totalIngresos,
    total_egresos: totalEgresos,
    balance: totalIngresos - totalEgresos,
    ingresos_por_concepto: ingresosConcepto,
    egresos_por_proveedor: egresosPorProveedor,
    egresos_por_servicio: egresosPorServicio,
    egresos_detalle: egresos
  });
},

async obtenerServiciosProveedores(req, res) {
    try {
      console.log('--- 🚀 ¡El flujo llegó con éxito al Backend! ---');
      
      // 1. Hacemos la consulta limpia a la base de datos
      const [rows] = await db.query(
        'SELECT DISTINCT servicio FROM proveedor WHERE servicio IS NOT NULL AND servicio != ""'
      );
      
      console.log('--- 📊 Filas reales devueltas por MySQL:', rows);
      
      // 2. Mapeamos y limpiamos los espacios en blanco de los textos
      const servicios = rows.map(r => r.servicio.trim());
      
      // 3. Enviamos los datos REALES directamente al frontend
      res.json(servicios);
      
    } catch (error) {
      console.error('Error en obtenerServiciosProveedores:', error);
      res.status(500).json({ error: 'Error al obtener los servicios reales de la base de datos' });
    }
  },
}

module.exports = FinanzasController
