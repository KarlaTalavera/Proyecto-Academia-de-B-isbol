import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
})

// Adjunta el JWT en cada petición
api.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Redirige al login SOLO si el token expiró (401 = no autenticado)
// El 403 significa "sin permiso" — no debe cerrar sesión
api.interceptors.response.use(
  res => res,
  err => {
    const url = err.config?.url || ''
    const esRutaAuth = url.includes('/auth/login') || url.includes('/auth/registro')
    if (!esRutaAuth && err.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)

export default api