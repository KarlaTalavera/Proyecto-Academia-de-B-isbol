<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Jugadores</h2>
        <p class="page-subtitle">Plantillas de todos los equipos</p>
      </div>
      <button v-if="auth.puedeEditar" class="btn btn-primary d-flex align-items-center gap-2" @click="abrirFormulario()">
        <IconPlus :size="18" stroke-width="2" /> Nuevo Jugador
      </button>
    </div>

    <!-- Tabla -->
    <div class="card">
      <div class="card-header d-flex align-items-center gap-2 flex-wrap">
        <div class="input-group input-group-sm" style="max-width:260px;">
          <span class="input-group-text" style="background:transparent;">
            <IconSearch :size="14" class="text-muted" />
          </span>
          <input v-model="busqueda" class="form-control" placeholder="Buscar jugador..." style="border-left:none;" />
        </div>
        <select v-model="filtroEquipo" class="form-select form-select-sm" style="max-width:200px;">
          <option value="">Todos los equipos</option>
          <option v-for="eq in equipos" :key="eq.id_equipo" :value="eq.id_equipo">{{ eq.nombre_equipo }}</option>
        </select>
        <span class="ms-auto text-muted" style="font-size:0.8rem;">{{ jugadoresFiltrados.length }} jugador(es)</span>
      </div>

      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>Jugador</th>
              <th>Equipo</th>
              <th>Posición</th>
              <th>Rol</th>
              <th>Brazo Dom.</th>
              <th>Estado</th>
              <th v-if="auth.puedeEditar" style="width:100px;"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando">
              <td colspan="7" class="text-center py-5">
                <span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...
              </td>
            </tr>
            <tr v-else-if="!jugadoresFiltrados.length">
              <td colspan="7" class="text-center py-5 text-muted">
                <IconUsers :size="32" stroke-width="1.2" class="mb-2 d-block mx-auto" style="opacity:0.3;" />
                No hay jugadores registrados
              </td>
            </tr>
            <tr v-for="j in jugadoresPagina" :key="j.id_jugador">
              <td>
                <div class="d-flex align-items-center gap-2">
                  <div class="team-avatar" style="background: linear-gradient(135deg,#6366f1,#8b5cf6);">
                    {{ j.nombre?.charAt(0)?.toUpperCase() }}
                  </div>
                  <div>
                    <div class="fw-semibold" style="font-size:0.875rem; color:#1e293b;">{{ j.nombre }} {{ j.apellido }}</div>
                    <div v-if="j.cedula" class="text-muted" style="font-size:0.75rem;">CI: {{ j.cedula }}</div>
                  </div>
                </div>
              </td>
              <td>
                <div class="d-flex align-items-center gap-1">
                  <div class="team-avatar" style="width:22px;height:22px;font-size:0.6rem;border-radius:6px;">{{ j.nombre_equipo?.charAt(0) }}</div>
                  <span class="text-muted" style="font-size:0.82rem;">{{ j.nombre_equipo }}</span>
                </div>
              </td>
              <td class="text-muted" style="font-size:0.82rem;">{{ j.posicion }}</td>
              <td>
                <span class="badge" :class="badgeRol(j.rol)">{{ j.rol }}</span>
              </td>
              <td class="text-muted" style="font-size:0.82rem;">{{ j.brazo_dominante || '—' }}</td>
              <td>
                <span class="badge" :class="j.activo ? 'bg-success-lt text-success' : 'bg-danger-lt text-danger'">
                  {{ j.activo ? 'Activo' : 'Inactivo' }}
                </span>
              </td>
              <td v-if="auth.puedeEditar" class="text-end">
                <button class="btn btn-sm btn-ghost-primary me-1" @click="abrirFormulario(j)"><IconPencil :size="15" /></button>
                <button class="btn btn-sm btn-ghost-danger" @click="confirmarEliminar(j)"><IconTrash :size="15" /></button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Paginación -->
    <div v-if="totalPaginas > 1" class="d-flex align-items-center justify-content-between mt-3">
      <span class="text-muted" style="font-size:0.8rem;">
        Mostrando {{ (paginaActual - 1) * porPagina + 1 }}–{{ Math.min(paginaActual * porPagina, jugadoresFiltrados.length) }}
        de {{ jugadoresFiltrados.length }} jugadores
      </span>
      <div class="d-flex gap-1">
        <button class="btn btn-sm btn-ghost-secondary" :disabled="paginaActual === 1" @click="paginaActual--">‹ Anterior</button>
        <button
          v-for="n in totalPaginas" :key="n"
          class="btn btn-sm"
          :class="n === paginaActual ? 'btn-primary' : 'btn-ghost-secondary'"
          style="min-width:34px;"
          @click="paginaActual = n"
        >{{ n }}</button>
        <button class="btn btn-sm btn-ghost-secondary" :disabled="paginaActual === totalPaginas" @click="paginaActual++">Siguiente ›</button>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="modalAbierto" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ editando ? 'Editar Jugador' : 'Nuevo Jugador' }}</h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <form @submit.prevent="guardar">
            <div class="modal-body">
              <div v-if="errorModal" class="alert alert-danger py-2 mb-3">{{ errorModal }}</div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Nombre <span class="text-danger">*</span></label>
                  <input v-model="form.nombre" class="form-control" required />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Apellido <span class="text-danger">*</span></label>
                  <input v-model="form.apellido" class="form-control" required />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Cédula</label>
                  <input v-model="form.cedula" class="form-control" placeholder="V-00000000" />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Fecha de Nacimiento <span class="text-danger">*</span></label>
                  <input v-model="form.fecha_nacimiento" type="date" class="form-control" required />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Equipo <span class="text-danger">*</span></label>
                  <select v-model="form.id_equipo" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option v-for="eq in equipos" :key="eq.id_equipo" :value="eq.id_equipo">{{ eq.nombre_equipo }}</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Rol <span class="text-danger">*</span></label>
                  <select v-model="form.rol" class="form-select" required>
                    <option value="bateador">Bateador</option>
                    <option value="pitcher">Pitcher</option>
                    <option value="utilidad">Utilidad</option>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Posición <span class="text-danger">*</span></label>
                  <select v-model="form.posicion" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option v-for="p in posiciones" :key="p">{{ p }}</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Brazo Dominante</label>
                  <select v-model="form.brazo_dominante" class="form-select">
                    <option value="">— Seleccionar —</option>
                    <option value="Derecho">Derecho</option>
                    <option value="Zurdo">Zurdo</option>
                    <option value="Ambidiestro">Ambidiestro</option>
                  </select>
                </div>
              </div>
              <div v-if="editando" class="mb-3">
                <label class="form-label fw-semibold" style="font-size:0.82rem;">Estado</label>
                <select v-model="form.activo" class="form-select">
                  <option :value="1">Activo</option>
                  <option :value="0">Inactivo</option>
                </select>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-ghost-secondary" @click="cerrarModal">Cancelar</button>
              <button type="submit" class="btn btn-primary d-flex align-items-center gap-2" :disabled="guardando">
                <span v-if="guardando" class="spinner-border spinner-border-sm"></span>
                <IconDeviceFloppy v-else :size="16" />
                {{ guardando ? 'Guardando...' : 'Guardar' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="modalAbierto" class="modal-backdrop show"></div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'
import { IconPlus, IconSearch, IconPencil, IconTrash, IconUsers, IconDeviceFloppy } from '@tabler/icons-vue'

const auth     = useAuthStore()
const jugadores  = ref([])
const equipos    = ref([])
const busqueda   = ref('')
const filtroEquipo = ref('')
const cargando   = ref(false)
const modalAbierto = ref(false)
const editando   = ref(false)
const guardando  = ref(false)
const errorModal = ref('')

const posiciones = [
  'Lanzador (P)', 'Receptor (C)', 'Primera Base (1B)', 'Segunda Base (2B)',
  'Tercera Base (3B)', 'Shortstop (SS)', 'Jardinero Izquierdo (LF)',
  'Jardinero Central (CF)', 'Jardinero Derecho (RF)', 'Bateador Designado (DH)',
]

const form = ref({ id_equipo: '', cedula: '', nombre: '', apellido: '', fecha_nacimiento: '', rol: 'bateador', posicion: '', brazo_dominante: '', activo: 1 })

const paginaActual = ref(1)
const porPagina    = 10

const jugadoresFiltrados = computed(() =>
  jugadores.value.filter(j => {
    const texto = `${j.nombre} ${j.apellido}`.toLowerCase()
    return texto.includes(busqueda.value.toLowerCase()) &&
      (!filtroEquipo.value || j.id_equipo === Number(filtroEquipo.value) || j.id_equipo === filtroEquipo.value)
  })
)

const totalPaginas    = computed(() => Math.max(1, Math.ceil(jugadoresFiltrados.value.length / porPagina)))
const jugadoresPagina = computed(() => {
  const inicio = (paginaActual.value - 1) * porPagina
  return jugadoresFiltrados.value.slice(inicio, inicio + porPagina)
})

watch([busqueda, filtroEquipo], () => { paginaActual.value = 1 })

function badgeRol(rol) {
  return { bateador: 'bg-blue-lt text-blue', pitcher: 'bg-purple-lt text-purple', utilidad: 'bg-orange-lt text-orange' }[rol] || 'bg-secondary-lt'
}

async function cargar() {
  cargando.value = true
  try {
    const [resJ, resE] = await Promise.all([api.get('/jugadores'), api.get('/equipos')])
    jugadores.value = resJ.data
    equipos.value   = resE.data
  } finally { cargando.value = false }
}

function abrirFormulario(jugador = null) {
  errorModal.value = ''
  if (jugador) {
    editando.value = true
    form.value = { ...jugador, fecha_nacimiento: jugador.fecha_nacimiento?.substring(0, 10) }
  } else {
    editando.value = false
    form.value = { id_equipo: '', cedula: '', nombre: '', apellido: '', fecha_nacimiento: '', rol: 'bateador', posicion: '', brazo_dominante: '', activo: 1 }
  }
  modalAbierto.value = true
}

function cerrarModal() { modalAbierto.value = false }

async function guardar() {
  const nombre = (form.value.nombre || '').trim()
  const apellido = (form.value.apellido || '').trim()
  if (nombre.length < 2) { alert('El nombre debe tener al menos 2 caracteres'); return }
  if (apellido.length < 2) { alert('El apellido debe tener al menos 2 caracteres'); return }
  if (form.value.cedula && !/^[VEve]-\d{6,8}$/.test(form.value.cedula)) {
    alert('La cédula debe tener el formato V-00000000 o E-00000000'); return
  }
  if (form.value.fecha_nacimiento) {
    const hoy = new Date()
    const nacimiento = new Date(form.value.fecha_nacimiento)
    const edad = (hoy - nacimiento) / (1000 * 60 * 60 * 24 * 365.25)
    if (edad < 10 || edad > 60) { alert('La edad del jugador debe estar entre 10 y 60 años'); return }
  }
  guardando.value = true
  errorModal.value = ''
  try {
    if (editando.value) await api.put(`/jugadores/${form.value.id_jugador}`, form.value)
    else await api.post('/jugadores', form.value)
    cerrarModal()
    cargar()
  } catch (e) {
    errorModal.value = e.response?.data?.error || 'Error al guardar'
  } finally { guardando.value = false }
}

async function confirmarEliminar(j) {
  if (!confirm(`¿Eliminar a "${j.nombre} ${j.apellido}"?`)) return
  await api.delete(`/jugadores/${j.id_jugador}`)
  cargar()
}

onMounted(cargar)
</script>
