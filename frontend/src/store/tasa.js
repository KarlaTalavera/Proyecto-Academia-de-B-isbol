import { defineStore } from 'pinia'
import api from '@/services/api'

export const useTasaStore = defineStore('tasa', {
  state: () => ({
    bcv:      null,   // tasa BCV oficial (Bs por 1 USD)
    cargando: false,
    error:    null,
  }),

  getters: {
    // Convierte Bs → USD usando tasa BCV
    bsADolar: (s) => (bs) => {
      if (!s.bcv || !bs) return null
      return Number(bs) / s.bcv
    },
    // Convierte USD → Bs usando tasa BCV
    dolarABs: (s) => (usd) => {
      if (!s.bcv || !usd) return null
      return Number(usd) * s.bcv
    },
    tasaDisponible: (s) => !!s.bcv,
  },

  actions: {
    async cargar() {
      if (this.bcv) return          // ya cargada en esta sesión
      this.cargando = true
      this.error    = null
      try {
        const { data } = await api.get('/tasa')
        this.bcv = data.bcv
      } catch {
        this.error = 'No se pudo obtener la tasa del día'
      } finally {
        this.cargando = false
      }
    },
  },
})
