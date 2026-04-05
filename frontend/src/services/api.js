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

// Redirige al login si el token expiró (no en la propia ruta de auth)
api.interceptors.response.use(
  res => res,
  err => {
    const url = err.config?.url || ''
    const esRutaAuth = url.includes('/auth/login') || url.includes('/auth/registro')
    if (!esRutaAuth && (err.response?.status === 401 || err.response?.status === 403)) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)

export default api
