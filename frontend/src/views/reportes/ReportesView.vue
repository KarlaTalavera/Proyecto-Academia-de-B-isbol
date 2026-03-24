<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Reportes</h2>
        <p class="page-subtitle">Estadísticas y tabla de posiciones</p>
      </div>
      <select v-model="temporadaId" class="form-select form-select-sm" style="max-width:220px;" @change="cargar">
        <option value="">— Seleccionar temporada —</option>
        <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">
          {{ t.nombre }} ({{ t.anio }})
        </option>
      </select>
    </div>

    <!-- Tabs -->
    <div class="d-flex gap-1 mb-4 p-1" style="background:rgba(0,0,0,0.06); border-radius:10px; display:inline-flex!important;">
      <button
        class="btn btn-sm"
        :class="tab === 'posiciones' ? 'btn-white shadow-sm fw-semibold' : 'btn-ghost-secondary'"
        style="border-radius:8px; font-size:0.82rem;"
        @click="tab = 'posiciones'"
      >
        <IconTrophy :size="15" class="me-1" /> Tabla de Posiciones
      </button>
      <button
        class="btn btn-sm"
        :class="tab === 'bateo' ? 'btn-white shadow-sm fw-semibold' : 'btn-ghost-secondary'"
        style="border-radius:8px; font-size:0.82rem;"
        @click="tab = 'bateo'"
      >
        <IconChartBar :size="15" class="me-1" /> Promedios de Bateo
      </button>
    </div>

    <!-- Sin temporada -->
    <div v-if="!temporadaId" class="card">
      <div class="card-body text-center py-5 text-muted">
        <IconChartBar :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
        <p class="mb-0">Selecciona una temporada para ver los reportes</p>
      </div>
    </div>

    <!-- Tabla de Posiciones -->
    <div v-else-if="tab === 'posiciones'">
      <div class="card">
        <div class="card-header d-flex align-items-center gap-2">
          <IconTrophy :size="18" class="text-warning" />
          <span class="fw-bold" style="font-size:0.9rem;">Tabla de Posiciones</span>
          <span v-if="temporadaNombre" class="ms-auto text-muted" style="font-size:0.78rem;">{{ temporadaNombre }}</span>
        </div>
        <div v-if="cargandoPos" class="text-center py-5">
          <span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...
        </div>
        <div v-else class="table-responsive">
          <table class="table table-vcenter card-table">
            <thead>
              <tr>
                <th style="width:40px;">#</th>
                <th>Equipo</th>
                <th class="text-center" title="Juegos Jugados">JJ</th>
                <th class="text-center" title="Ganados">G</th>
                <th class="text-center" title="Perdidos">P</th>
                <th class="text-center" title="Porcentaje de victorias">PCT</th>
                <th class="text-center" title="Juegos de diferencia">JD</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!posiciones.length">
                <td colspan="7" class="text-center py-5 text-muted">Sin datos. Los partidos deben estar finalizados.</td>
              </tr>
              <tr v-for="(eq, i) in posiciones" :key="eq.id_equipo" :class="i === 0 ? 'table-success-lt' : ''">
                <td>
                  <div class="d-flex align-items-center justify-content-center">
                    <IconTrophy v-if="i === 0" :size="16" class="text-warning" />
                    <span v-else class="text-muted fw-bold" style="font-size:0.82rem;">{{ i + 1 }}</span>
                  </div>
                </td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <div class="team-avatar" :style="i === 0 ? 'background:linear-gradient(135deg,#f59e0b,#f97316);' : ''">
                      {{ eq.nombre_equipo?.charAt(0) }}
                    </div>
                    <span class="fw-semibold" style="font-size:0.875rem; color:#1e293b;">{{ eq.nombre_equipo }}</span>
                  </div>
                </td>
                <td class="text-center fw-bold">{{ eq.jugados }}</td>
                <td class="text-center text-success fw-bold">{{ eq.ganados }}</td>
                <td class="text-center text-danger">{{ eq.perdidos }}</td>
                <td class="text-center">
                  <span class="fw-bold" :style="eq.ganados > eq.perdidos ? 'color:#16a34a;' : ''">
                    {{ pct(eq.ganados, eq.jugados) }}
                  </span>
                </td>
                <td class="text-center text-muted">
                  {{ i === 0 ? '—' : (posiciones[0].ganados - eq.ganados) + '.0' }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Promedios de Bateo -->
    <div v-else-if="tab === 'bateo'">
      <div class="card">
        <div class="card-header d-flex align-items-center gap-2">
          <IconChartBar :size="18" class="text-primary" />
          <span class="fw-bold" style="font-size:0.9rem;">Promedios de Bateo</span>
          <span v-if="temporadaNombre" class="ms-auto text-muted" style="font-size:0.78rem;">{{ temporadaNombre }}</span>
        </div>
        <div class="card-header d-flex align-items-center gap-2">
          <div class="input-group input-group-sm" style="max-width:240px;">
            <span class="input-group-text" style="background:transparent;"><IconSearch :size="14" class="text-muted" /></span>
            <input v-model="busquedaBateo" class="form-control" placeholder="Buscar jugador..." style="border-left:none;" />
          </div>
        </div>
        <div v-if="cargandoBateo" class="text-center py-5">
          <span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...
        </div>
        <div v-else class="table-responsive">
          <table class="table table-vcenter card-table">
            <thead>
              <tr>
                <th>#</th>
                <th>Jugador</th>
                <th>Equipo</th>
                <th class="text-center" title="Turnos al Bate">AB</th>
                <th class="text-center" title="Hits">H</th>
                <th class="text-center" title="Dobles">2B</th>
                <th class="text-center" title="Triples">3B</th>
                <th class="text-center" title="Jonrones">HR</th>
                <th class="text-center" title="Carreras">R</th>
                <th class="text-center" title="Carreras Impulsadas">RBI</th>
                <th class="text-center fw-bold" title="Promedio de Bateo">AVG</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!bateoFiltrado.length">
                <td colspan="11" class="text-center py-5 text-muted">Sin estadísticas de bateo en esta temporada</td>
              </tr>
              <tr v-for="(j, i) in bateoFiltrado" :key="j.id_jugador">
                <td class="text-muted" style="font-size:0.8rem;">{{ i + 1 }}</td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <div class="team-avatar" style="width:28px;height:28px;font-size:0.7rem;background:linear-gradient(135deg,#6366f1,#8b5cf6);">
                      {{ j.jugador?.charAt(0) }}
                    </div>
                    <span class="fw-semibold" style="font-size:0.875rem; color:#1e293b;">{{ j.jugador }}</span>
                  </div>
                </td>
                <td class="text-muted" style="font-size:0.82rem;">{{ j.nombre_equipo }}</td>
                <td class="text-center">{{ j.AB }}</td>
                <td class="text-center">{{ j.H }}</td>
                <td class="text-center">{{ j.X2B }}</td>
                <td class="text-center">{{ j.X3B }}</td>
                <td class="text-center fw-semibold text-primary">{{ j.HR }}</td>
                <td class="text-center">{{ j.R }}</td>
                <td class="text-center">{{ j.RBI }}</td>
                <td class="text-center">
                  <span class="badge fw-bold" style="font-size:0.82rem;"
                    :style="j.AVG >= 0.300 ? 'background:rgba(34,197,94,0.15);color:#16a34a;' : j.AVG >= 0.250 ? 'background:rgba(59,130,246,0.12);color:#3b82f6;' : 'background:rgba(100,116,139,0.1);color:#64748b;'">
                    .{{ avgStr(j.AVG) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { IconTrophy, IconChartBar, IconSearch } from '@tabler/icons-vue'

const tab          = ref('posiciones')
const temporadas   = ref([])
const temporadaId  = ref('')
const posiciones   = ref([])
const bateadores   = ref([])
const busquedaBateo = ref('')
const cargandoPos  = ref(false)
const cargandoBateo = ref(false)

const temporadaNombre = computed(() => {
  const t = temporadas.value.find(t => t.id_temporada === temporadaId.value || t.id_temporada === Number(temporadaId.value))
  return t ? `${t.nombre} (${t.anio})` : ''
})

const bateoFiltrado = computed(() =>
  bateadores.value.filter(j =>
    j.jugador?.toLowerCase().includes(busquedaBateo.value.toLowerCase()) ||
    j.nombre_equipo?.toLowerCase().includes(busquedaBateo.value.toLowerCase())
  )
)

function pct(g, j) {
  if (!j) return '.000'
  return (g / j).toFixed(3).replace('0.', '.')
}

function avgStr(avg) {
  if (avg == null) return '000'
  return avg.toFixed(3).replace('0.', '').padStart(3, '0')
}

async function cargar() {
  if (!temporadaId.value) return
  cargandoPos.value = true
  cargandoBateo.value = true
  try {
    const [resPos, resBat] = await Promise.all([
      api.get('/reportes/posiciones', { params: { temporada: temporadaId.value } }),
      api.get('/reportes/promedios-bateo', { params: { temporada: temporadaId.value } }),
    ])
    posiciones.value = resPos.data
    bateadores.value = resBat.data
  } finally {
    cargandoPos.value = false
    cargandoBateo.value = false
  }
}

async function cargarTemporadas() {
  const { data } = await api.get('/temporadas')
  temporadas.value = data
  // Seleccionar la activa por defecto
  const activa = data.find(t => t.activa)
  if (activa) {
    temporadaId.value = activa.id_temporada
    cargar()
  }
}

onMounted(cargarTemporadas)
</script>
