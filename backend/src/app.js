require('dotenv').config()
const express = require('express')
const cors    = require('cors')
const path    = require('path')

const app = express()

app.use(cors({ origin: process.env.FRONTEND_URL || 'http://localhost:5173' }))
app.use(express.json())

// ── Archivos subidos (fotos de jugadores y logos de equipos) ──
app.use('/uploads', express.static(path.join(__dirname, '../uploads')))

// ── Wrapper para capturar errores en rutas async (Express 4) ──
require('express-async-errors')

// ── Rutas ────────────────────────────────────────────────────
app.use('/api/pub',           require('./routes/public.routes'))
app.use('/api/auth',          require('./routes/auth.routes'))
app.use('/api/usuarios',      require('./routes/usuarios.routes'))
app.use('/api/temporadas',    require('./routes/temporada.routes'))
app.use('/api/equipos',       require('./routes/equipo.routes'))
app.use('/api/jugadores',     require('./routes/jugador.routes'))
app.use('/api/partidos',      require('./routes/partido.routes'))
app.use('/api/finanzas',      require('./routes/finanzas.routes'))
app.use('/api/reportes',      require('./routes/reporte.routes'))
app.use('/api/fan',           require('./routes/fan.routes'))
app.use('/api/tasa',          require('./routes/tasa.routes'))
app.use('/api/inscripciones', require('./routes/inscripcion.routes'))
app.use('/api/proveedores',   require('./routes/proveedor.routes'))
app.use('/api/sanciones',     require('./routes/sancion.routes'))
app.use('/api/noticias',      require('./routes/noticia.routes'))

// ── Manejo global de errores ─────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Error:', err.message || err)
  // FK constraint: el registro tiene dependencias
  if (err.code === 'ER_ROW_IS_REFERENCED_2' || err.errno === 1451) {
    return res.status(409).json({ error: 'No se puede eliminar porque tiene datos asociados.' })
  }
  res.status(500).json({ error: 'Error interno del servidor' })
})

const PORT = process.env.PORT || 3000
app.listen(PORT, () => console.log(`API Liga Diamante escuchando en http://localhost:${PORT}`))
