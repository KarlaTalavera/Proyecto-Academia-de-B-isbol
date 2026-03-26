<template>
  <div>
    <div class="page-header mb-4">
      <h2 class="page-title">Tabla de Posiciones</h2>
      <p class="page-subtitle">Clasificación de equipos en la temporada</p>
    </div>

    <!-- Selector de temporada -->
    <div class="card mb-4" style="background:rgba(255,255,255,0.78);">
      <div class="card-body py-3 d-flex align-items-center gap-3 flex-wrap">
        <IconTrophy :size="20" style="color:#f59e0b;" />
        <label class="fw-semibold mb-0" style="font-size:0.875rem; color:#475569;">Temporada:</label>
        <select v-model="temporadaId" class="form-select form-select-sm" style="max-width:200px;" @change="cargarPosiciones">
          <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">{{ t.nombre }}</option>
        </select>
      </div>
    </div>

    <div v-if="cargando" class="text-center py-5 text-muted">Cargando clasificación...</div>

    <div v-else-if="!posiciones.length" class="text-center py-5 text-muted">
      Sin datos para esta temporada aún.
    </div>

    <div v-else class="card">
      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th style="width:40px;">#</th>
              <th>Equipo</th>
              <th class="text-center">JJ</th>
              <th class="text-center" style="color:#22c55e;">G</th>
              <th class="text-center" style="color:#ef4444;">P</th>
              <th class="text-center">%</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(eq, i) in posiciones"
              :key="eq.id_equipo"
              :style="esMiEquipo(eq.id_equipo) ? 'background:rgba(239,68,68,0.04);' : ''"
            >
              <td>
                <div class="d-flex align-items-center gap-1">
                  <span v-if="i === 0">🥇</span>
                  <span v-else-if="i === 1">🥈</span>
                  <span v-else-if="i === 2">🥉</span>
                  <span v-else class="text-muted" style="font-size:0.8rem;">{{ i+1 }}</span>
                </div>
              </td>
              <td>
                <div class="d-flex align-items-center gap-2">
                  <div class="team-avatar" style="width:32px; height:32px; font-size:0.8rem;">{{ eq.nombre_equipo?.charAt(0) }}</div>
                  <span class="fw-semibold" style="font-size:0.875rem; color:#1e293b;">{{ eq.nombre_equipo }}</span>
                  <IconHeart v-if="esMiEquipo(eq.id_equipo)" :size="13" style="color:#ef4444;" />
                </div>
              </td>
              <td class="text-center" style="font-size:0.875rem; color:#64748b;">{{ eq.jugados }}</td>
              <td class="text-center fw-bold" style="color:#22c55e;">{{ eq.ganados }}</td>
              <td class="text-center fw-bold" style="color:#ef4444;">{{ eq.perdidos }}</td>
              <td class="text-center">
                <span class="fw-bold" style="font-size:0.875rem; color:#3b82f6;">
                  {{ pct(eq.ganados, eq.jugados) }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { IconTrophy, IconHeart } from '@tabler/icons-vue'

const cargando    = ref(true)
const temporadas  = ref([])
const temporadaId = ref(null)
const posiciones  = ref([])
const misEquiposIds = ref(new Set())

function pct(g, j) {
  if (!j) return '.000'
  return '.' + String(Math.round((g / j) * 1000)).padStart(3, '0')
}
function esMiEquipo(id) { return misEquiposIds.value.has(id) }

async function cargarPosiciones() {
  if (!temporadaId.value) return
  cargando.value = true
  try {
    const { data } = await api.get('/reportes/posiciones', { params: { temporada: temporadaId.value } })
    posiciones.value = data
  } finally {
    cargando.value = false
  }
}

onMounted(async () => {
  try {
    const [tRes, eRes] = await Promise.all([
      api.get('/temporadas').catch(() => ({ data: [] })),
      api.get('/fan/mis-equipos').catch(() => ({ data: [] })),
    ])
    temporadas.value = tRes.data
    misEquiposIds.value = new Set(eRes.data.map(e => e.id_equipo))
    if (temporadas.value.length) {
      const activa = temporadas.value.find(t => t.activa)
      temporadaId.value = (activa ?? temporadas.value[0]).id_temporada
      await cargarPosiciones()
    } else {
      cargando.value = false
    }
  } catch {
    cargando.value = false
  }
})
</script>
