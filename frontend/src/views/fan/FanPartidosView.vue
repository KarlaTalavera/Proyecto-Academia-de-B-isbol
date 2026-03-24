<template>
  <div>
    <div class="page-header mb-4">
      <h2 class="page-title">Próximos Juegos</h2>
      <p class="page-subtitle">Calendario completo de la liga</p>
    </div>

    <div v-if="cargando" class="text-center py-5 text-muted">Cargando partidos...</div>

    <div v-else-if="!partidos.length" class="text-center py-5 text-muted">
      No hay partidos programados actualmente.
    </div>

    <div v-else class="card">
      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Hora</th>
              <th>Local</th>
              <th class="text-center">vs</th>
              <th>Visitante</th>
              <th>Lugar</th>
              <th>Estado</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in partidos" :key="p.id_partido" :class="{ 'table-active': esMiEquipo(p) }">
              <td style="font-size:0.875rem; font-weight:600; color:#1e293b;">{{ formatFecha(p.fecha_juego) }}</td>
              <td style="font-size:0.875rem; color:#64748b;">{{ p.hora_juego ? horaFormato(p.hora_juego) : '—' }}</td>
              <td>
                <div class="d-flex align-items-center gap-2">
                  <div class="team-avatar" style="width:28px; height:28px; font-size:0.72rem;">{{ p.equipo_casa?.charAt(0) }}</div>
                  <span style="font-size:0.875rem; font-weight:{{ esMiEquipoId(p.id_equipo_casa) ? '700' : '500' }}; color:#1e293b;">{{ p.equipo_casa }}</span>
                  <IconHeart v-if="esMiEquipoId(p.id_equipo_casa)" :size="13" style="color:#ef4444;" />
                </div>
              </td>
              <td class="text-center text-muted fw-bold" style="font-size:0.78rem;">VS</td>
              <td>
                <div class="d-flex align-items-center gap-2">
                  <div class="team-avatar" style="width:28px; height:28px; font-size:0.72rem;">{{ p.equipo_visitante?.charAt(0) }}</div>
                  <span style="font-size:0.875rem; color:#1e293b;">{{ p.equipo_visitante }}</span>
                  <IconHeart v-if="esMiEquipoId(p.id_equipo_visitante)" :size="13" style="color:#ef4444;" />
                </div>
              </td>
              <td style="font-size:0.8rem; color:#64748b;">{{ p.lugar || '—' }}</td>
              <td><span class="badge" :class="badgeEstado(p.estado)">{{ p.estado }}</span></td>
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
import { IconHeart } from '@tabler/icons-vue'

const cargando   = ref(true)
const partidos   = ref([])
const misEquiposIds = ref(new Set())

function formatFecha(f) {
  if (!f) return ''
  return new Date(f).toLocaleDateString('es-VE', { day: '2-digit', month: 'short', year: 'numeric' })
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
    'bg-red-lt text-red':       estado === 'cancelado',
  }
}
function esMiEquipoId(id) { return misEquiposIds.value.has(id) }
function esMiEquipo(p) { return esMiEquipoId(p.id_equipo_casa) || esMiEquipoId(p.id_equipo_visitante) }

async function cargar() {
  cargando.value = true
  try {
    const [pRes, eRes] = await Promise.all([
      api.get('/partidos').catch(() => ({ data: [] })),
      api.get('/fan/mis-equipos').catch(() => ({ data: [] })),
    ])
    partidos.value = pRes.data.filter(p => ['programado', 'en_juego'].includes(p.estado))
    misEquiposIds.value = new Set(eRes.data.map(e => e.id_equipo))
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)
</script>
