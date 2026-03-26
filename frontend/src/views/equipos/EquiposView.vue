<template>
  <div>

    <!-- Page header -->
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Equipos</h2>
        <p class="page-subtitle">Gestión de equipos de la liga</p>
      </div>
      <button v-if="auth.puedeEditar" class="btn btn-primary d-flex align-items-center gap-2" @click="abrirFormulario()">
        <IconPlus :size="18" stroke-width="2" />
        Nuevo Equipo
      </button>
    </div>

    <!-- Card tabla -->
    <div class="card">
      <div class="card-header d-flex align-items-center gap-2">
        <div class="input-group input-group-sm" style="max-width:280px;">
          <span class="input-group-text" style="background:transparent;">
            <IconSearch :size="15" class="text-muted" />
          </span>
          <input v-model="busqueda" class="form-control" placeholder="Buscar equipo..." style="border-left:none;" />
        </div>
        <span class="ms-auto text-muted" style="font-size:0.8rem;">{{ equiposFiltrados.length }} equipo(s)</span>
      </div>

      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>Equipo</th>
              <th>Entrenador</th>
              <th>Responsable</th>
              <th>Contacto</th>
              <th v-if="auth.puedeEditar" style="width:120px;"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando">
              <td :colspan="auth.puedeEditar ? 5 : 4" class="text-center py-5">
                <span class="spinner-border spinner-border-sm text-primary me-2"></span>
                Cargando equipos...
              </td>
            </tr>
            <tr v-else-if="!equiposFiltrados.length">
              <td :colspan="auth.puedeEditar ? 5 : 4" class="text-center py-5 text-muted">
                <IconShield :size="32" stroke-width="1.2" class="mb-2 d-block mx-auto" style="opacity:0.3;" />
                No hay equipos registrados
              </td>
            </tr>
            <tr v-for="eq in equiposFiltrados" :key="eq.id_equipo">
              <td>
                <div class="d-flex align-items-center gap-3">
                  <div class="team-avatar">{{ eq.nombre_equipo?.charAt(0)?.toUpperCase() }}</div>
                  <span class="fw-semibold" style="color:#1e293b;">{{ eq.nombre_equipo }}</span>
                </div>
              </td>
              <td class="text-muted">{{ eq.entrenador }}</td>
              <td class="text-muted">{{ eq.responsable }}</td>
              <td>
                <div v-if="eq.email" class="d-flex align-items-center gap-1 text-muted" style="font-size:0.8rem;">
                  <IconMail :size="13" /> {{ eq.email }}
                </div>
                <div v-if="eq.telefono" class="d-flex align-items-center gap-1 text-muted" style="font-size:0.8rem;">
                  <IconPhone :size="13" /> {{ eq.telefono }}
                </div>
              </td>
              <td v-if="auth.puedeEditar" class="text-end">
                <button class="btn btn-sm btn-ghost-primary me-1" @click="abrirFormulario(eq)" title="Editar">
                  <IconPencil :size="15" />
                </button>
                <button class="btn btn-sm btn-ghost-danger" @click="confirmarEliminar(eq)" title="Eliminar">
                  <IconTrash :size="15" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal formulario -->
    <div v-if="modalAbierto" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-md modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <div class="d-flex align-items-center gap-2">
              <div class="team-avatar" style="width:32px;height:32px;font-size:0.8rem;">
                {{ form.nombre_equipo?.charAt(0)?.toUpperCase() || '+' }}
              </div>
              <h5 class="modal-title mb-0">{{ editando ? 'Editar Equipo' : 'Nuevo Equipo' }}</h5>
            </div>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <form @submit.prevent="guardar">
            <div class="modal-body">
              <div v-if="errorModal" class="alert alert-danger py-2 mb-3">{{ errorModal }}</div>

              <div class="mb-3">
                <label class="form-label fw-semibold" style="font-size:0.82rem;">Nombre del Equipo <span class="text-danger">*</span></label>
                <input v-model="form.nombre_equipo" class="form-control" placeholder="Ej: Tiburones de La Guaira" required />
              </div>
              <div class="mb-3">
                <label class="form-label fw-semibold" style="font-size:0.82rem;">Entrenador <span class="text-danger">*</span></label>
                <input v-model="form.entrenador" class="form-control" placeholder="Nombre del entrenador" required />
              </div>
              <div class="mb-3">
                <label class="form-label fw-semibold" style="font-size:0.82rem;">Responsable / Manager <span class="text-danger">*</span></label>
                <input v-model="form.responsable" class="form-control" placeholder="Nombre del responsable" required />
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Email</label>
                  <input v-model="form.email" type="email" class="form-control" placeholder="correo@equipo.com" />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Teléfono</label>
                  <input v-model="form.telefono" type="tel" class="form-control" placeholder="0414-0000000" />
                </div>
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
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'
import {
  IconPlus, IconSearch, IconPencil, IconTrash,
  IconShield, IconMail, IconPhone, IconDeviceFloppy,
} from '@tabler/icons-vue'

const auth     = useAuthStore()
const equipos  = ref([])
const busqueda = ref('')
const cargando = ref(false)

const modalAbierto = ref(false)
const editando     = ref(false)
const guardando    = ref(false)
const errorModal   = ref('')
const form = ref({ nombre_equipo: '', entrenador: '', responsable: '', email: '', telefono: '' })

const equiposFiltrados = computed(() =>
  equipos.value.filter(e =>
    e.nombre_equipo.toLowerCase().includes(busqueda.value.toLowerCase()) ||
    e.entrenador.toLowerCase().includes(busqueda.value.toLowerCase())
  )
)

async function cargarEquipos() {
  cargando.value = true
  try {
    const { data } = await api.get('/equipos')
    equipos.value = data
  } finally {
    cargando.value = false
  }
}

function abrirFormulario(equipo = null) {
  errorModal.value = ''
  if (equipo) {
    editando.value = true
    form.value = { ...equipo }
  } else {
    editando.value = false
    form.value = { nombre_equipo: '', entrenador: '', responsable: '', email: '', telefono: '' }
  }
  modalAbierto.value = true
}

function cerrarModal() { modalAbierto.value = false }

async function guardar() {
  const nombre = (form.value.nombre_equipo || '').trim()
  const entrenador = (form.value.entrenador || '').trim()
  const responsable = (form.value.responsable || '').trim()
  if (!nombre) { alert('El nombre del equipo es obligatorio'); return }
  if (!entrenador) { alert('El entrenador es obligatorio'); return }
  if (!responsable) { alert('El responsable es obligatorio'); return }
  if (form.value.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email)) {
    alert('El formato del email no es válido'); return
  }
  if (form.value.telefono && !/^0\d{3}-\d{3}-\d{4}$/.test(form.value.telefono)) {
    alert('El teléfono debe tener el formato 0414-000-0000'); return
  }
  guardando.value  = true
  errorModal.value = ''
  try {
    if (editando.value) {
      await api.put(`/equipos/${form.value.id_equipo}`, form.value)
    } else {
      await api.post('/equipos', form.value)
    }
    cerrarModal()
    cargarEquipos()
  } catch (e) {
    errorModal.value = e.response?.data?.error || 'Error al guardar'
  } finally {
    guardando.value = false
  }
}

async function confirmarEliminar(equipo) {
  if (!confirm(`¿Eliminar el equipo "${equipo.nombre_equipo}"?`)) return
  await api.delete(`/equipos/${equipo.id_equipo}`)
  cargarEquipos()
}

onMounted(cargarEquipos)
</script>
