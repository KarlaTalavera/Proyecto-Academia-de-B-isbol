const router = require('express').Router()
const { verificarToken } = require('../middlewares/auth')

// Cache en memoria: evita llamar a dolarapi.com en cada request
let cache = { bcv: null, paralelo: null, actualizado: null }
const CACHE_MS = 60 * 60 * 1000 // 1 hora

async function obtenerTasas() {
  const ahora = Date.now()
  if (cache.bcv && cache.actualizado && (ahora - cache.actualizado) < CACHE_MS) {
    return cache
  }

  const res  = await fetch('https://ve.dolarapi.com/v1/dolares')
  if (!res.ok) throw new Error('Error al consultar dolarapi.com')
  const data = await res.json()

  const oficial  = data.find(d => d.fuente === 'oficial' || d.fuente === 'bcv')
  const paralelo = data.find(d => d.fuente === 'paralelo')

  cache = {
    bcv:        oficial?.promedio  ?? null,
    paralelo:   paralelo?.promedio ?? null,
    actualizado: ahora,
    fechaBcv:   oficial?.fechaActualizacion ?? null,
  }
  return cache
}

// GET /api/tasa — requiere autenticación
router.get('/', verificarToken, async (req, res, next) => {
  try {
    const tasas = await obtenerTasas()
    res.json(tasas)
  } catch (e) {
    next(e)
  }
})

module.exports = router
