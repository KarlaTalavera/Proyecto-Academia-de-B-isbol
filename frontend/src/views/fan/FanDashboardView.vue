<template>
  <div>

    <!-- Sin equipos seguidos: pantalla de bienvenida -->
    <div v-if="!cargando && misEquipos.length === 0" class="text-center py-5">
      <div style="font-size:4rem; margin-bottom:1rem;">⚾</div>
      <h2 class="fw-800 mb-2" style="color:#1e293b;">¡Bienvenido a tu zona de béisbol!</h2>
      <p class="text-muted mb-4" style="font-size:1rem; max-width:420px; margin:0 auto;">
        Sigue tus equipos favoritos para ver sus próximos juegos, resultados y estadísticas personalizadas aquí.
      </p>
      <RouterLink :to="{ name: 'MisEquipos' }" class="btn btn-primary d-inline-flex align-items-center gap-2 px-4 py-2">
        <IconHeart :size="18" /> Descubrir Equipos
      </RouterLink>
    </div>

    <!-- Con equipos seguidos: dashboard personalizado -->
    <template v-else>

      <!-- Mis Equipos (chips) -->
      <div class="mb-4">
        <div class="d-flex align-items-center gap-2 mb-3">
          <IconHeart :size="20" stroke-width="1.7" style="color:#ef4444;" />
          <h5 class="mb-0 fw-bold" style="color:#1e293b;">Tus Equipos</h5>
          <RouterLink :to="{ name: 'MisEquipos' }" class="ms-auto" style="font-size:0.78rem; color:#6366f1; text-decoration:none;">Administrar</RouterLink>
        </div>
        <div class="d-flex flex-wrap gap-2">
          <div
            v-for="eq in misEquipos"
            :key="eq.id_equipo"
            class="d-flex align-items-center gap-2 px-3 py-2"
            style="background:rgba(255,255,255,0.82); border:1px solid rgba(255,255,255,0.7); border-radius:50px; backdrop-filter:blur(10px); box-shadow:0 2px 12px rgba(0,0,0,0.06);"
          >
            <div class="team-avatar" style="width:28px; height:28px; font-size:0.75rem;">{{ eq.nombre_equipo?.charAt(0)?.toUpperCase() }}</div>
            <span style="font-size:0.875rem; font-weight:600; color:#1e293b;">{{ eq.nombre_equipo }}</span>
          </div>
        </div>
      </div>

      <div class="row g-3">

        <!-- Próximos juegos -->
        <div class="col-lg-6">
          <div class="card h-100">
            <div class="card-header d-flex align-items-center gap-2">
              <IconCalendarEvent :size="18" style="color:#6366f1;" />
              <span class="fw-bold" style="font-size:0.9rem;">Próximos Juegos</span>
            </div>
            <div class="card-body p-0">
              <div v-if="cargando" class="text-center py-4 text-muted" style="font-size:0.875rem;">Cargando...</div>
              <div v-else-if="!proximosJuegos.length" class="text-center py-4 text-muted" style="font-size:0.875rem;">
                No hay juegos programados para tus equipos
              </div>
              <div v-else>
                <div
                  v-for="j in proximosJuegos"
                  :key="j.id_partido"
                  class="px-4 py-3 d-flex align-items-center gap-3"
                  style="border-bottom:1px solid rgba(0,0,0,0.05);"
                >
                  <div class="text-center" style="min-width:44px;">
                    <div style="font-size:0.65rem; font-weight:700; text-transform:uppercase; color:#94a3b8;">{{ diaCorto(j.fecha_juego) }}</div>
                    <div style="font-size:1.3rem; font-weight:800; color:#1e293b; line-height:1;">{{ numeroDia(j.fecha_juego) }}</div>
                  </div>
                  <div class="flex-grow-1">
                    <div class="fw-semibold" style="font-size:0.875rem; color:#1e293b;">
                      {{ j.equipo_casa }} <span class="text-muted fw-normal">vs</span> {{ j.equipo_visitante }}
                    </div>
                    <div class="text-muted" style="font-size:0.75rem;">
                      {{ j.hora_juego ? horaFormato(j.hora_juego) : 'Hora por confirmar' }}
                      <span v-if="j.lugar"> · {{ j.lugar }}</span>
                    </div>
                  </div>
                  <span class="badge" :class="badgeEstado(j.estado)">{{ j.estado }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Últimos resultados -->
        <div class="col-lg-6">
          <div class="card h-100">
            <div class="card-header d-flex align-items-center gap-2">
              <IconTrophy :size="18" style="color:#f59e0b;" />
              <span class="fw-bold" style="font-size:0.9rem;">Últimos Resultados</span>
            </div>
            <div class="card-body p-0">
              <div v-if="cargando" class="text-center py-4 text-muted" style="font-size:0.875rem;">Cargando...</div>
              <div v-else-if="!ultimosResultados.length" class="text-center py-4 text-muted" style="font-size:0.875rem;">
                Sin resultados recientes para tus equipos
              </div>
              <div v-else>
                <div
                  v-for="r in ultimosResultados"
                  :key="r.id_partido"
                  class="px-4 py-3 d-flex align-items-center gap-3"
                  style="border-bottom:1px solid rgba(0,0,0,0.05);"
                >
                  <div class="text-center" style="min-width:44px;">
                    <div style="font-size:0.65rem; font-weight:700; text-transform:uppercase; color:#94a3b8;">{{ diaCorto(r.fecha_juego) }}</div>
                    <div style="font-size:1.3rem; font-weight:800; color:#1e293b; line-height:1;">{{ numeroDia(r.fecha_juego) }}</div>
                  </div>
                  <div class="flex-grow-1">
                    <div class="fw-semibold" style="font-size:0.875rem; color:#1e293b;">
                      {{ r.equipo_casa }} <span class="text-muted fw-normal">vs</span> {{ r.equipo_visitante }}
                    </div>
                    <div style="font-size:0.78rem; color:#64748b;" v-if="r.lugar">{{ r.lugar }}</div>
                  </div>
                  <div class="text-center">
                    <div style="font-size:1.1rem; font-weight:800; color:#1e293b; letter-spacing:2px;">
                      {{ r.carreras_home }} - {{ r.carreras_visitantes }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Estadísticas de bateadores -->
        <div class="col-12" v-if="estadisticas.length">
          <div class="card">
            <div class="card-header d-flex align-items-center gap-2">
              <IconChartBar :size="18" style="color:#3b82f6;" />
              <span class="fw-bold" style="font-size:0.9rem;">Mejores Bateadores de Tus Equipos</span>
            </div>
            <div class="table-responsive">
              <table class="table table-vcenter card-table">
                <thead>
                  <tr>
                    <th>Jugador</th>
                    <th>Equipo</th>
                    <th class="text-center">AB</th>
                    <th class="text-center">H</th>
                    <th class="text-center">HR</th>
                    <th class="text-center">RBI</th>
                    <th class="text-center fw-bold">AVG</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(s, i) in estadisticas" :key="s.id_jugador">
                    <td>
                      <div class="d-flex align-items-center gap-2">
                        <span style="font-size:0.65rem; font-weight:700; color:#94a3b8; min-width:16px;">{{ i+1 }}</span>
                        <span class="fw-semibold" style="font-size:0.875rem;">{{ s.jugador }}</span>
                      </div>
                    </td>
                    <td style="font-size:0.8rem; color:#64748b;">{{ s.nombre_equipo }}</td>
                    <td class="text-center" style="font-size:0.875rem;">{{ s.AB }}</td>
                    <td class="text-center" style="font-size:0.875rem;">{{ s.H }}</td>
                    <td class="text-center" style="font-size:0.875rem;">{{ s.HR }}</td>
                    <td class="text-center" style="font-size:0.875rem;">{{ s.RBI }}</td>
                    <td class="text-center">
                      <span class="fw-bold" style="font-size:0.9rem; color:#3b82f6;">{{ formatAvg(s.AVG) }}</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

      </div>
    </template>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import api from '@/services/api'
import { IconHeart, IconCalendarEvent, IconTrophy, IconChartBar } from '@tabler/icons-vue'

const cargando        = ref(true)
const misEquipos      = ref([])
const proximosJuegos  = ref([])
const ultimosResultados = ref([])
const estadisticas    = ref([])

function diaCorto(fecha) {
  if (!fecha) return ''
  const d = new Date(fecha)
  return d.toLocaleDateString('es-VE', { weekday: 'short' }).toUpperCase()
}
function numeroDia(fecha) {
  if (!fecha) return ''
  return new Date(fecha).getUTCDate()
}
function horaFormato(hora) {
  if (!hora) return ''
  const [h, m] = hora.split(':')
  const hh = parseInt(h)
  return `${hh > 12 ? hh - 12 : hh}:${m} ${hh >= 12 ? 'PM' : 'AM'}`
}
function badgeEstado(estado) {
  return {
    'bg-indigo-lt text-indigo': estado === 'en_juego',
    'bg-blue-lt text-blue':     estado === 'programado',
    'bg-green-lt text-green':   estado === 'finalizado',
  }
}
function formatAvg(val) {
  if (!val) return '.000'
  return '.' + String(Math.round(val * 1000)).padStart(3, '0')
}

async function cargar() {
  cargando.value = true
  try {
    const [eqRes, jRes, rRes, stRes] = await Promise.all([
      api.get('/fan/mis-equipos').catch(() => ({ data: [] })),
      api.get('/fan/proximos-juegos').catch(() => ({ data: [] })),
      api.get('/fan/ultimos-resultados').catch(() => ({ data: [] })),
      api.get('/fan/estadisticas').catch(() => ({ data: [] })),
    ])
    misEquipos.value        = eqRes.data
    proximosJuegos.value    = jRes.data
    ultimosResultados.value = rRes.data
    estadisticas.value      = stRes.data
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)
</script>
