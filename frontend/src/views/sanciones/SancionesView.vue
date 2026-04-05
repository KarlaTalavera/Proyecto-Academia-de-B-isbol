<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Sanciones</h2>
        <p class="page-subtitle">Control disciplinario de jugadores y equipos</p>
      </div>
      <button v-if="auth.puedeSancionar" class="btn btn-warning btn-sm" @click="abrirFormulario()">+ Nueva Sanción</button>
    </div>

    <!-- Filtros -->
    <div class="d-flex gap-2 mb-3 flex-wrap">
      <select v-model="temporadaFiltro" class="form-select form-select-sm" style="max-width:220px;" @change="cargar">
        <option value="">Todas las temporadas</option>
        <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">{{ t.nombre }}</option>
      </select>
      <select v-model="filtroEstado" class="form-select form-select-sm" style="max-width:160px;">
        <option value="">Todos los estados</option>
        <option value="activa">Activa</option>
        <option value="cumplida">Cumplida</option>
        <option value="apelada">Apelada</option>
        <option value="revocada">Revocada</option>
      </select>
    </div>

    <!-- Resumen rápido -->
    <div class="row g-3 mb-3">
      <div class="col-sm-3">
        <div class="card card-sm"><div class="card-body text-center">
          <div class="text-muted" style="font-size:0.75rem;">Activas</div>
          <div class="fw-bold text-danger" style="font-size:1.3rem;">{{ sanciones.filter(s => s.estado === 'activa').length }}</div>
        </div></div>
      </div>
      <div class="col-sm-3">
        <div class="card card-sm"><div class="card-body text-center">
          <div class="text-muted" style="font-size:0.75rem;">Suspensiones</div>
          <div class="fw-bold text-orange" style="font-size:1.3rem;">{{ sanciones.filter(s => s.tipo === 'suspension').length }}</div>
        </div></div>
      </div>
      <div class="col-sm-3">
        <div class="card card-sm"><div class="card-body text-center">
          <div class="text-muted" style="font-size:0.75rem;">Multas</div>
          <div class="fw-bold text-warning" style="font-size:1.3rem;">{{ formatBs(sanciones.reduce((s, x) => s + Number(x.monto_multa || 0), 0)) }}</div>
        </div></div>
      </div>
      <div class="col-sm-3">
        <div class="card card-sm"><div class="card-body text-center">
          <div class="text-muted" style="font-size:0.75rem;">Total</div>
          <div class="fw-bold" style="font-size:1.3rem;">{{ sanciones.length }}</div>
        </div></div>
      </div>
    </div>

    <!-- Tabla -->
    <div class="card">
      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Tipo</th>
              <th>Jugador / Equipo</th>
              <th>Descripción</th>
              <th class="text-center">Partidos</th>
              <th class="text-end">Multa</th>
              <th class="text-center">Estado</th>
              <th v-if="auth.puedeSancionar"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando"><td :colspan="auth.puedeSancionar ? 8 : 7" class="text-center py-4">Cargando...</td></tr>
            <tr v-else-if="!sancionesFiltradas.length"><td :colspan="auth.puedeSancionar ? 8 : 7" class="text-center py-4 text-muted">Sin sanciones registradas</td></tr>
            <tr v-for="s in sancionesFiltradas" :key="s.id_sancion">
              <td>{{ formatFecha(s.fecha_sancion) }}</td>
              <td>
                <span class="badge" :class="{'bg-red-lt text-red': s.tipo==='expulsion','bg-orange-lt text-orange': s.tipo==='suspension','bg-yellow-lt text-yellow': s.tipo==='multa','bg-secondary-lt': s.tipo==='amonestacion'}">
                  {{ s.tipo }}
                </span>
              </td>
              <td>
                <div v-if="s.jugador_nombre" class="fw-semibold">{{ s.jugador_nombre }}</div>
                <div class="text-muted" style="font-size:0.82rem;">{{ s.nombre_equipo }}</div>
              </td>
              <td style="max-width:250px; font-size:0.85rem;">{{ s.descripcion }}</td>
              <td class="text-center">{{ s.partidos_suspension || '—' }}</td>
              <td class="text-end">{{ s.monto_multa > 0 ? formatBs(s.monto_multa) : '—' }}</td>
              <td class="text-center">
                <span class="badge" :class="{'bg-danger-lt text-danger': s.estado==='activa','bg-success-lt text-success': s.estado==='cumplida','bg-blue-lt text-blue': s.estado==='apelada','bg-secondary-lt': s.estado==='revocada'}">
                  {{ s.estado }}
                </span>
              </td>
              <td v-if="auth.puedeSancionar" class="text-end">
                <button class="btn btn-sm btn-ghost-secondary me-1" @click="abrirFormulario(s)">Editar</button>
                <button class="btn btn-sm btn-ghost-danger" @click="eliminar(s)">✕</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="modal" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ editando ? 'Editar' : 'Nueva' }} Sanción</h5>
            <button type="button" class="btn-close" @click="modal = false"></button>
          </div>
          <form @submit.prevent="guardar">
            <div class="modal-body">
              <div v-if="error" class="alert alert-danger mb-3">{{ error }}</div>
              <div class="row">
                <div class="col-md-4 mb-3">
                  <label class="form-label required">Temporada</label>
                  <select v-model="form.id_temporada" class="form-select" required>
                    <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">{{ t.nombre }}</option>
                  </select>
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label required">Tipo</label>
                  <select v-model="form.tipo" class="form-select" required>
                    <option value="amonestacion">Amonestación</option>
                    <option value="suspension">Suspensión</option>
                    <option value="multa">Multa</option>
                    <option value="expulsion">Expulsión</option>
                  </select>
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label required">Fecha</label>
                  <input v-model="form.fecha_sancion" type="date" class="form-control" required />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Equipo</label>
                  <select v-model="form.id_equipo" class="form-select" @change="cargarJugadoresEquipo">
                    <option value="">— Ninguno —</option>
                    <option v-for="e in equipos" :key="e.id_equipo" :value="e.id_equipo">{{ e.nombre_equipo }}</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Jugador</label>
                  <select v-model="form.id_jugador" class="form-select">
                    <option value="">— Ninguno (sanción a equipo) —</option>
                    <option v-for="j in jugadoresEquipo" :key="j.id_jugador" :value="j.id_jugador">{{ j.nombre }} {{ j.apellido }}</option>
                  </select>
                </div>
              </div>
              <div class="mb-3">
                <label class="form-label required">Descripción</label>
                <textarea v-model="form.descripcion" class="form-control" rows="2" required></textarea>
              </div>
              <div class="row">
                <div class="col-md-4 mb-3">
                  <label class="form-label">Partidos de Suspensión</label>
                  <input v-model="form.partidos_suspension" type="number" min="0" class="form-control" />
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label">Monto Multa (Bs.)</label>
                  <input v-model="form.monto_multa" type="number" step="0.01" min="0" class="form-control" />
                </div>
                <div v-if="editando" class="col-md-4 mb-3">
                  <label class="form-label">Estado</label>
                  <select v-model="form.estado" class="form-select">
                    <option value="activa">Activa</option>
                    <option value="cumplida">Cumplida</option>
                    <option value="apelada">Apelada</option>
                    <option value="revocada">Revocada</option>
                  </select>
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-ghost-secondary me-auto" @click="modal = false">Cancelar</button>
              <button type="submit" class="btn btn-warning" :disabled="guardando">{{ guardando ? 'Guardando...' : 'Guardar' }}</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="modal" class="modal-backdrop show"></div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'

const auth = useAuthStore()
const sanciones = ref([])
const temporadas = ref([])
const equipos = ref([])
const jugadoresEquipo = ref([])
const temporadaFiltro = ref('')
const filtroEstado = ref('')
const cargando = ref(false)
const modal = ref(false)
const editando = ref(false)
const guardando = ref(false)
const error = ref('')
const form = ref({})

function formatFecha(f) { return f ? new Date(f).toLocaleDateString('es-VE') : '—' }
function formatBs(v) { return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 2 }).format(v || 0) + ' Bs.' }

const sancionesFiltradas = computed(() =>
  sanciones.value.filter(s => !filtroEstado.value || s.estado === filtroEstado.value)
)

async function cargar() {
  cargando.value = true
  try {
    const params = temporadaFiltro.value ? { temporada: temporadaFiltro.value } : {}
    sanciones.value = (await api.get('/sanciones', { params })).data
  } finally { cargando.value = false }
}

async function cargarJugadoresEquipo() {
  if (!form.value.id_equipo) { jugadoresEquipo.value = []; return }
  const { data } = await api.get(`/equipos/${form.value.id_equipo}/jugadores`)
  jugadoresEquipo.value = data
}

function abrirFormulario(s = null) {
  error.value = ''
  jugadoresEquipo.value = []
  if (s) {
    editando.value = true
    form.value = { ...s, fecha_sancion: s.fecha_sancion?.substring(0, 10) }
    if (s.id_equipo) cargarJugadoresEquipo()
  } else {
    editando.value = false
    const activa = temporadas.value.find(t => t.activa)
    form.value = {
      id_temporada: activa?.id_temporada || '', tipo: 'amonestacion',
      fecha_sancion: new Date().toISOString().substring(0, 10),
      id_equipo: '', id_jugador: '', descripcion: '',
      partidos_suspension: 0, monto_multa: 0, estado: 'activa',
    }
  }
  modal.value = true
}

async function guardar() {
  guardando.value = true
  error.value = ''
  try {
    if (editando.value) await api.put(`/sanciones/${form.value.id_sancion}`, form.value)
    else await api.post('/sanciones', form.value)
    modal.value = false
    cargar()
  } catch (e) { error.value = e.response?.data?.error || 'Error al guardar' }
  finally { guardando.value = false }
}

async function eliminar(s) {
  if (!confirm('¿Eliminar esta sanción?')) return
  await api.delete(`/sanciones/${s.id_sancion}`)
  cargar()
}

onMounted(async () => {
  const [resT, resE] = await Promise.all([
    api.get('/temporadas').catch(() => ({ data: [] })),
    api.get('/equipos').catch(() => ({ data: [] })),
  ])
  temporadas.value = resT.data
  equipos.value = resE.data
  const activa = resT.data.find(t => t.activa)
  if (activa) temporadaFiltro.value = activa.id_temporada
  cargar()
})
</script>
