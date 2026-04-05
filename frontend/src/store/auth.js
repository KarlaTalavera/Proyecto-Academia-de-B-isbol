import { defineStore } from 'pinia'
import api from '@/services/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token:  localStorage.getItem('token') || null,
    rol:    localStorage.getItem('rol')   || null,
    nombre: localStorage.getItem('nombre')|| null,
  }),

  getters: {
    esAdmin:       s => s.rol === 'administrador',
    esDueno:       s => s.rol === 'dueno',
    esCaja:        s => s.rol === 'caja',
    esAnotador:    s => s.rol === 'anotador',
    puedeFinanzas: s => ['administrador', 'caja'].includes(s.rol),
    // admin y dueno gestionan equipos, jugadores y programan partidos
    puedeEditar:   s => ['administrador', 'dueno'].includes(s.rol),
    // admin, dueno y anotador pueden gestionar sanciones
    puedeSancionar: s => ['administrador', 'dueno', 'anotador'].includes(s.rol),
    // solo el anotador carga lineup, resultado y estadísticas de un partido
    puedeAnotar:   s => s.rol === 'anotador',
  },

  actions: {
    async login(email, password) {
      const { data } = await api.post('/auth/login', { email, password })
      this.token  = data.token
      this.rol    = data.rol
      this.nombre = data.nombre
      localStorage.setItem('token',  data.token)
      localStorage.setItem('rol',    data.rol)
      localStorage.setItem('nombre', data.nombre)
    },
    logout() {
      this.token = this.rol = this.nombre = null
      localStorage.removeItem('token')
      localStorage.removeItem('rol')
      localStorage.removeItem('nombre')
    },
  },
})
