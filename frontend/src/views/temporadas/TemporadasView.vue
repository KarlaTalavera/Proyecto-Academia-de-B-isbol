<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Temporadas</h2>
        <p class="page-subtitle">Gestión de temporadas de la liga</p>
      </div>
      <button class="btn btn-primary d-flex align-items-center gap-2" @click="abrirFormulario()">
        <IconPlus :size="18" stroke-width="2" /> Nueva Temporada
      </button>
    </div>

    <div v-if="cargando" class="text-center py-5 text-muted">Cargando...</div>

    <div v-else class="card">
      <div v-if="!temporadas.length" class="text-center py-5 text-muted">
        No hay temporadas registradas. Crea la primera.
      </div>
      <div v-else class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Año</th>
              <th>Categoría</th>
              <th class="text-end">Costo Inscripción</th>
              <th class="text-center">Estado</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="t in temporadas" :key="t.id_temporada">
              <td class="fw-semibold" style="color:#1e293b;">{{ t.nombre }}</td>
              <td>{{ t.anio }}</td>
              <td>{{ t.categoria }}</td>
              <td class="text-end">{{ formatBs(t.costo_inscripcion) }}</td>
              <td class="text-center">
                <span v-if="t.activa" class="badge bg-green-lt text-green">Activa</span>
                <span v-else class="badge bg-secondary-lt text-muted">Inactiva</span>
              </td>
              <td class="text-end">
                <button
                  class="btn btn-sm me-1"
                  :class="t.activa ? 'btn-ghost-warning' : 'btn-ghost-success'"
                  @click="toggleActiva(t)"
                  :title="t.activa ? 'Desactivar' : 'Activar'"
                >
                  {{ t.activa ? 'Desactivar' : 'Activar' }}
                </button>
                <button class="btn btn-sm btn-ghost-secondary me-1" @click="abrirFormulario(t)">
                  <IconEdit :size="15" />
                </button>
                <button class="btn btn-sm btn-ghost-danger" @click="confirmarEliminar(t)">
                  <IconTrash :size="15" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="modalAbierto" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-md modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ editando ? 'Editar Temporada' : 'Nueva Temporada' }}</h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <form @submit.prevent="guardar">
            <div class="modal-body">
              <div v-if="errorModal" class="alert alert-danger mb-3">{{ errorModal }}</div>

              <div class="row">
                <div class="col-md-8 mb-3">
                  <label class="form-label required">Nombre</label>
                  <input v-model="form.nombre" class="form-control" placeholder="Ej: Temporada 2026 — Apertura" required />
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label required">Año</label>
                  <input v-model="form.anio" type="number" min="2000" max="2100" class="form-control" required />
                </div>
              </div>

              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label required">Categoría</label>
                  <select v-model="form.categoria" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option>Juvenil</option>
                    <option>Aficionado</option>
                    <option>Semi-profesional</option>
                    <option>Profesional</option>
                    <option>Máster</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Costo de Inscripción (Bs.)</label>
                  <input v-model="form.costo_inscripcion" type="number" step="0.01" min="0" class="form-control" placeholder="0.00" />
                </div>
              </div>

              <div class="form-check form-switch">
                <input v-model="form.activa" class="form-check-input" type="checkbox" :id="'activa-check'" />
                <label class="form-check-label" :for="'activa-check'">Temporada activa</label>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-ghost-secondary me-auto" @click="cerrarModal">Cancelar</button>
              <button type="submit" class="btn btn-primary" :disabled="guardando">
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
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { IconPlus, IconEdit, IconTrash } from '@tabler/icons-vue'

const temporadas   = ref([])
const cargando     = ref(false)
const modalAbierto = ref(false)
const editando     = ref(false)
const guardando    = ref(false)
const errorModal   = ref('')

const form = ref({ nombre: '', anio: new Date().getFullYear(), categoria: '', costo_inscripcion: 0, activa: false })

function formatBs(v) {
  return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 2 }).format(v || 0) + ' Bs.'
}

async function cargar() {
  cargando.value = true
  try {
    const { data } = await api.get('/temporadas')
    temporadas.value = data
  } finally {
    cargando.value = false
  }
}

function abrirFormulario(t = null) {
  errorModal.value = ''
  if (t) {
    editando.value = true
    form.value = { ...t, activa: !!t.activa }
  } else {
    editando.value = false
    form.value = { nombre: '', anio: new Date().getFullYear(), categoria: '', costo_inscripcion: 0, activa: false }
  }
  modalAbierto.value = true
}

function cerrarModal() { modalAbierto.value = false }

async function guardar() {
  if (!(form.value.nombre || '').trim()) { alert('El nombre de la temporada es obligatorio'); return }
  const anio = Number(form.value.anio)
  if (anio < 2000 || anio > 2100) { alert('El año debe estar entre 2000 y 2100'); return }
  if (Number(form.value.costo_inscripcion) < 0) { alert('El costo de inscripción no puede ser negativo'); return }
  guardando.value = true
  errorModal.value = ''
  try {
    if (editando.value) {
      await api.put(`/temporadas/${form.value.id_temporada}`, form.value)
    } else {
      await api.post('/temporadas', form.value)
    }
    cerrarModal()
    cargar()
  } catch (e) {
    errorModal.value = e.response?.data?.error || 'Error al guardar'
  } finally {
    guardando.value = false
  }
}

async function toggleActiva(t) {
  await api.patch(`/temporadas/${t.id_temporada}/activa`, { activa: !t.activa })
  cargar()
}

async function confirmarEliminar(t) {
  if (!confirm(`¿Eliminar la temporada "${t.nombre}"? Esta acción no se puede deshacer.`)) return
  try {
    await api.delete(`/temporadas/${t.id_temporada}`)
    cargar()
  } catch (e) {
    alert(e.response?.data?.error || 'No se puede eliminar — tiene datos asociados')
  }
}

onMounted(cargar)
</script>
