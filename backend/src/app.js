require('dotenv').config()
const express = require('express')
const cors    = require('cors')

const app = express()

app.use(cors({ origin: process.env.FRONTEND_URL || 'http://localhost:5173' }))
app.use(express.json())

// ── Rutas ────────────────────────────────────────────────────
app.use('/api/pub',        require('./routes/public.routes'))
app.use('/api/auth',       require('./routes/auth.routes'))
app.use('/api/usuarios',   require('./routes/usuarios.routes'))
app.use('/api/temporadas', require('./routes/temporada.routes'))
app.use('/api/equipos',    require('./routes/equipo.routes'))
app.use('/api/jugadores',  require('./routes/jugador.routes'))
app.use('/api/partidos',   require('./routes/partido.routes'))
app.use('/api/finanzas',   require('./routes/finanzas.routes'))
app.use('/api/reportes',   require('./routes/reporte.routes'))
app.use('/api/fan',        require('./routes/fan.routes'))
app.use('/api/tasa',       require('./routes/tasa.routes'))

// ── Manejo global de errores ─────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err)
  res.status(500).json({ error: 'Error interno del servidor' })
})

const PORT = process.env.PORT || 3000
app.listen(PORT, () => console.log(`API Liga Diamante escuchando en http://localhost:${PORT}`))
