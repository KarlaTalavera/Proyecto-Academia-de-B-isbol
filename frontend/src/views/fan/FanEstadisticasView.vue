<template>
  <div>
    <div class="page-header mb-4">
      <h2 class="page-title">Estadísticas</h2>
      <p class="page-subtitle">Rendimiento de bateadores y pitchers</p>
    </div>

    <!-- Tabs -->
    <div class="d-flex gap-1 mb-4 p-1" style="background:rgba(0,0,0,0.06); border-radius:10px; max-width:320px;">
      <button class="btn btn-sm flex-fill" :class="tab === 'bateo' ? 'btn-white shadow-sm fw-semibold' : 'btn-ghost-secondary'" style="border-radius:8px; font-size:0.82rem;" @click="tab='bateo'">Bateadores</button>
      <button class="btn btn-sm flex-fill" :class="tab === 'global' ? 'btn-white shadow-sm fw-semibold' : 'btn-ghost-secondary'" style="border-radius:8px; font-size:0.82rem;" @click="tab='global'">Toda la Liga</button>
    </div>

    <!-- Mis bateadores -->
    <template v-if="tab === 'bateo'">
      <div v-if="!misEquiposIds.size" class="alert" style="background:rgba(99,102,241,0.08); border:1px solid rgba(99,102,241,0.2); border-radius:14px;">
        <strong style="color:#4f46e5;">Sigue equipos</strong> para ver las estadísticas de sus jugadores aquí.
        <RouterLink :to="{ name: 'MisEquipos' }" class="ms-2" style="color:#6366f1;">Ir a Mis Equipos →</RouterLink>
      </div>
      <div v-else-if="cargando" class="text-center py-5 text-muted">Cargando...</div>
      <div v-else-if="!estadisticas.length" class="text-center py-5 text-muted">
        Aún no hay estadísticas cargadas para tus equipos.
      </div>
      <div v-else class="card">
        <div class="card-header fw-bold" style="font-size:0.9rem;">
          Bateadores de Tus Equipos
        </div>
        <div class="table-responsive">
          <table class="table table-vcenter card-table">
            <thead>
              <tr>
                <th>#</th><th>Jugador</th><th>Equipo</th>
                <th class="text-center"><AbrevTooltip ab="AB" /></th><th class="text-center"><AbrevTooltip ab="H" /></th>
                <th class="text-center"><AbrevTooltip ab="HR" /></th><th class="text-center"><AbrevTooltip ab="RBI" /></th>
                <th class="text-center fw-bold"><AbrevTooltip ab="AVG" /></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(s, i) in estadisticas" :key="s.id_jugador">
                <td class="text-muted" style="font-size:0.8rem;">{{ i+1 }}</td>
                <td class="fw-semibold" style="font-size:0.875rem;">{{ s.jugador }}</td>
                <td style="font-size:0.8rem; color:#64748b;">{{ s.nombre_equipo }}</td>
                <td class="text-center" style="font-size:0.875rem;">{{ s.AB }}</td>
                <td class="text-center" style="font-size:0.875rem;">{{ s.H }}</td>
                <td class="text-center" style="font-size:0.875rem;">{{ s.HR }}</td>
                <td class="text-center" style="font-size:0.875rem;">{{ s.RBI }}</td>
                <td class="text-center fw-bold" style="color:#3b82f6;">{{ formatAvg(s.AVG) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </template>

    <!-- Toda la liga (temporada) -->
    <template v-if="tab === 'global'">
      <div class="d-flex align-items-center gap-3 mb-4 flex-wrap">
        <label class="fw-semibold mb-0" style="font-size:0.875rem; color:#475569;">Temporada:</label>
        <select v-model="temporadaId" class="form-select form-select-sm" style="max-width:200px;" @change="cargarGlobal">
          <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">{{ t.nombre }}</option>
        </select>
      </div>
      <div v-if="cargandoGlobal" class="text-center py-5 text-muted">Cargando...</div>
      <div v-else-if="!promediosGlobal.length" class="text-center py-5 text-muted">Sin estadísticas para esta temporada.</div>
      <div v-else class="card">
        <div class="table-responsive">
          <table class="table table-vcenter card-table">
            <thead>
              <tr>
                <th>#</th><th>Jugador</th><th>Equipo</th>
                <th class="text-center"><AbrevTooltip ab="AB" /></th><th class="text-center"><AbrevTooltip ab="H" /></th>
                <th class="text-center"><AbrevTooltip ab="HR" /></th><th class="text-center"><AbrevTooltip ab="RBI" /></th>
                <th class="text-center fw-bold"><AbrevTooltip ab="AVG" /></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(s, i) in promediosGlobal" :key="s.id_jugador">
                <td class="text-muted" style="font-size:0.8rem;">{{ i+1 }}</td>
                <td class="fw-semibold" style="font-size:0.875rem;">{{ s.jugador }}</td>
                <td style="font-size:0.8rem; color:#64748b;">{{ s.nombre_equipo }}</td>
                <td class="text-center" style="font-size:0.875rem;">{{ s.AB }}</td>
                <td class="text-center" style="font-size:0.875rem;">{{ s.H }}</td>
                <td class="text-center" style="font-size:0.875rem;">{{ s.HR }}</td>
                <td class="text-center" style="font-size:0.875rem;">{{ s.RBI }}</td>
                <td class="text-center fw-bold" style="color:#3b82f6;">{{ formatAvg(s.AVG) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </template>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import api from '@/services/api'
import AbrevTooltip from '@/components/AbrevTooltip.vue'

const tab           = ref('bateo')
const cargando      = ref(true)
const cargandoGlobal = ref(false)
const estadisticas  = ref([])
const promediosGlobal = ref([])
const misEquiposIds = ref(new Set())
const temporadas    = ref([])
const temporadaId   = ref(null)

function formatAvg(val) {
  if (!val) return '.000'
  return '.' + String(Math.round(val * 1000)).padStart(3, '0')
}

async function cargarGlobal() {
  if (!temporadaId.value) return
  cargandoGlobal.value = true
  try {
    const { data } = await api.get('/reportes/promedios-bateo', { params: { temporada: temporadaId.value } })
    promediosGlobal.value = data
  } finally {
    cargandoGlobal.value = false
  }
}

onMounted(async () => {
  try {
    const [stRes, eRes, tRes] = await Promise.all([
      api.get('/fan/estadisticas').catch(() => ({ data: [] })),
      api.get('/fan/mis-equipos').catch(() => ({ data: [] })),
      api.get('/temporadas').catch(() => ({ data: [] })),
    ])
    estadisticas.value  = stRes.data
    misEquiposIds.value = new Set(eRes.data.map(e => e.id_equipo))
    temporadas.value    = tRes.data
    if (temporadas.value.length) {
      const activa = temporadas.value.find(t => t.activa)
      temporadaId.value = (activa ?? temporadas.value[0]).id_temporada
      await cargarGlobal()
    }
  } finally {
    cargando.value = false
  }
})
</script>
