<template>
  <div>

    <!-- Page header -->
    <div class="page-header mb-4">
      <h2 class="page-title">Dashboard</h2>
      <p class="page-subtitle">Resumen general de la liga</p>
    </div>

    <!-- KPI Cards -->
    <div class="row g-3 mb-4">

      <div class="col-sm-6 col-xl-3">
        <div class="kpi-card">
          <div class="kpi-icon" style="background: rgba(59,130,246,0.12); color:#3b82f6;">
            <IconShield :size="24" stroke-width="1.7" />
          </div>
          <div class="kpi-label">Equipos</div>
          <div class="kpi-value">{{ stats.equipos }}</div>
          <div class="kpi-sub">registrados en la liga</div>
        </div>
      </div>

      <div class="col-sm-6 col-xl-3">
        <div class="kpi-card">
          <div class="kpi-icon" style="background: rgba(99,102,241,0.12); color:#6366f1;">
            <IconUsers :size="24" stroke-width="1.7" />
          </div>
          <div class="kpi-label">Jugadores</div>
          <div class="kpi-value">{{ stats.jugadores }}</div>
          <div class="kpi-sub">activos en plantillas</div>
        </div>
      </div>

      <div class="col-sm-6 col-xl-3">
        <div class="kpi-card">
          <div class="kpi-icon" style="background: rgba(20,184,166,0.12); color:#14b8a6;">
            <IconCalendarEvent :size="24" stroke-width="1.7" />
          </div>
          <div class="kpi-label">Partidos</div>
          <div class="kpi-value">{{ stats.partidos }}</div>
          <div class="kpi-sub">programados</div>
        </div>
      </div>

      <div class="col-sm-6 col-xl-3" v-if="auth.rol === 'administrador'">
        <div class="kpi-card">
          <div class="kpi-icon" style="background: rgba(34,197,94,0.12); color:#16a34a;">
            <IconWallet :size="24" stroke-width="1.7" />
          </div>
          <div class="kpi-label">Balance</div>
          <div class="kpi-value" style="font-size:1.4rem;">{{ formatBs(stats.balance) }}</div>
          <div class="kpi-sub">ingresos − egresos</div>
        </div>
      </div>

    </div>

    <!-- Quick Access -->
    <div class="row g-3">

      <!-- Accesos rápidos -->
      <div class="col-lg-5">
        <div class="card h-100">
          <div class="card-header d-flex align-items-center gap-2">
            <IconBolt :size="18" class="text-warning" />
            <span class="fw-bold" style="font-size:0.9rem;">Accesos Rápidos</span>
          </div>
          <div class="card-body p-3">
            <div class="d-grid gap-2">
              <RouterLink :to="{ name: 'Equipos' }" class="btn btn-outline-primary d-flex align-items-center gap-2 justify-content-start py-2 px-3" style="border-radius:10px; border-color:rgba(59,130,246,0.3);">
                <IconShield :size="18" stroke-width="1.7" />
                <span>Gestionar Equipos</span>
                <IconChevronRight :size="16" class="ms-auto text-muted" />
              </RouterLink>
              <RouterLink :to="{ name: 'Jugadores' }" class="btn btn-outline-indigo d-flex align-items-center gap-2 justify-content-start py-2 px-3" style="border-radius:10px; border-color:rgba(99,102,241,0.3);">
                <IconUsers :size="18" stroke-width="1.7" />
                <span>Ver Jugadores</span>
                <IconChevronRight :size="16" class="ms-auto text-muted" />
              </RouterLink>
              <RouterLink :to="{ name: 'Partidos' }" class="btn btn-outline-teal d-flex align-items-center gap-2 justify-content-start py-2 px-3" style="border-radius:10px; border-color:rgba(20,184,166,0.3);">
                <IconCalendarEvent :size="18" stroke-width="1.7" />
                <span>Calendario de Partidos</span>
                <IconChevronRight :size="16" class="ms-auto text-muted" />
              </RouterLink>
              <RouterLink :to="{ name: 'Reportes' }" class="btn btn-outline-secondary d-flex align-items-center gap-2 justify-content-start py-2 px-3" style="border-radius:10px;">
                <IconChartBar :size="18" stroke-width="1.7" />
                <span>Ver Reportes y Estadísticas</span>
                <IconChevronRight :size="16" class="ms-auto text-muted" />
              </RouterLink>
            </div>
          </div>
        </div>
      </div>

      <!-- Equipos recientes -->
      <div class="col-lg-7">
        <div class="card h-100">
          <div class="card-header d-flex align-items-center gap-2">
            <IconShield :size="18" class="text-primary" />
            <span class="fw-bold" style="font-size:0.9rem;">Equipos de la Liga</span>
            <RouterLink :to="{ name: 'Equipos' }" class="ms-auto" style="font-size:0.78rem; color:#6366f1; text-decoration:none;">Ver todos</RouterLink>
          </div>
          <div class="card-body p-0">
            <div v-if="cargando" class="text-center py-4 text-muted" style="font-size:0.875rem;">Cargando...</div>
            <div v-else-if="!equipos.length" class="text-center py-4 text-muted" style="font-size:0.875rem;">No hay equipos registrados aún</div>
            <div v-else class="list-group list-group-flush" style="border-radius: 0 0 18px 18px; overflow:hidden;">
              <div
                v-for="eq in equipos.slice(0, 6)"
                :key="eq.id_equipo"
                class="list-group-item d-flex align-items-center gap-3 px-4"
                style="background:transparent; border-color:rgba(0,0,0,0.05); padding-top:0.7rem; padding-bottom:0.7rem;"
              >
                <div class="team-avatar">{{ eq.nombre_equipo?.charAt(0)?.toUpperCase() }}</div>
                <div class="flex-grow-1">
                  <div class="fw-semibold" style="font-size:0.875rem; color:#1e293b;">{{ eq.nombre_equipo }}</div>
                  <div class="text-muted" style="font-size:0.75rem;">{{ eq.entrenador }}</div>
                </div>
                <IconChevronRight :size="16" class="text-muted" />
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'
import {
  IconShield,
  IconUsers,
  IconCalendarEvent,
  IconWallet,
  IconChartBar,
  IconBolt,
  IconChevronRight,
} from '@tabler/icons-vue'

const auth    = useAuthStore()
const cargando = ref(false)
const equipos  = ref([])
const stats    = ref({ equipos: 0, jugadores: 0, partidos: 0, balance: 0 })

function formatBs(v) {
  return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(v || 0) + ' Bs.'
}

async function cargar() {
  cargando.value = true
  try {
    // Primero obtenemos la temporada activa para pasarla al balance
    const resTemp = await api.get('/temporadas').catch(() => ({ data: [] }))
    const temporadaActiva = resTemp.data.find(t => t.activa)?.id_temporada || resTemp.data[0]?.id_temporada

    const promesas = [
      api.get('/equipos').catch(() => ({ data: [] })),
      api.get('/jugadores').catch(() => ({ data: [] })),
      api.get('/partidos').catch(() => ({ data: [] })),
    ]
    if (auth.rol === 'administrador' && temporadaActiva) {
      promesas.push(api.get('/finanzas/balance', { params: { temporada: temporadaActiva } }).catch(() => ({ data: { balance: 0 } })))
    }
    const resultados = await Promise.all(promesas)
    equipos.value      = resultados[0].data
    stats.value.equipos   = resultados[0].data.length
    stats.value.jugadores = resultados[1].data.length
    stats.value.partidos  = resultados[2].data.length
    if (auth.puedeFinanzas && resultados[3]) {
      stats.value.balance = resultados[3].data.balance || 0
    }
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)
</script>
