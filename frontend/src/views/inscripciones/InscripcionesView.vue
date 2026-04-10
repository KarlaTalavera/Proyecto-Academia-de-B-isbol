<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Inscripciones</h2>
        <p class="page-subtitle">Gestión de equipos inscritos por temporada</p>
      </div>
      <button class="btn btn-primary btn-sm" @click="abrirFormulario()">+ Nueva Inscripción</button>
    </div>

    <!-- Filtro temporada -->
    <div class="d-flex gap-2 mb-3">
      <select v-model="temporadaFiltro" class="form-select form-select-sm" style="max-width:240px;" @change="cargar">
        <option value="">Todas las temporadas</option>
        <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">{{ t.nombre }} ({{ t.anio }})</option>
      </select>
    </div>

    <!-- Resumen -->
    <div class="row g-3 mb-3">
      <div class="col-sm-4">
        <div class="card card-sm">
          <div class="card-body d-flex align-items-center gap-3">
            <span class="avatar bg-primary-lt text-primary">{{ inscripciones.length }}</span>
            <div><div class="text-muted" style="font-size:0.78rem;">Inscritos</div><div class="fw-bold">Total</div></div>
          </div>
        </div>
      </div>
      <div class="col-sm-4">
        <div class="card card-sm">
          <div class="card-body d-flex align-items-center gap-3">
            <span class="avatar bg-success-lt text-success">{{ inscripciones.filter(i => i.estado_pago === 'pagado').length }}</span>
            <div><div class="text-muted" style="font-size:0.78rem;">Pagados</div><div class="fw-bold text-success">Al día</div></div>
          </div>
        </div>
      </div>
      <div class="col-sm-4">
        <div class="card card-sm">
          <div class="card-body d-flex align-items-center gap-3">
            <span class="avatar bg-warning-lt text-warning">{{ inscripciones.filter(i => i.estado_pago === 'pendiente').length }}</span>
            <div><div class="text-muted" style="font-size:0.78rem;">Pendientes</div><div class="fw-bold text-warning">Por cobrar</div></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla -->
    <div class="card">
      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>Equipo</th>
              <th>Temporada</th>
              <th>Fecha Inscripción</th>
              <th class="text-center">Estado</th>
              <th class="text-end">Monto</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando"><td colspan="6" class="text-center py-4">Cargando...</td></tr>
            <tr v-else-if="!inscripciones.length"><td colspan="6" class="text-center py-4 text-muted">No hay inscripciones registradas</td></tr>
            <tr v-for="ins in inscripciones" :key="ins.id_inscripcion">
              <td>
                <div class="d-flex align-items-center gap-2">
                  <div class="team-avatar">{{ ins.nombre_equipo?.charAt(0) }}</div>
                  <span class="fw-semibold">{{ ins.nombre_equipo }}</span>
                </div>
              </td>
              <td class="text-muted">{{ ins.temporada }}</td>
              <td>{{ formatFecha(ins.fecha_inscripcion) }}</td>
              <td class="text-center">
                <span class="badge" :class="{'bg-success-lt text-success': ins.estado_pago==='pagado','bg-warning-lt text-warning': ins.estado_pago==='pendiente','bg-danger-lt text-danger': ins.estado_pago==='rechazado'}">
                  {{ ins.estado_pago }}
                </span>
              </td>
              <td class="text-end fw-bold">{{ formatBs(ins.monto_pagado) }}</td>
              <td class="text-end">
                <button class="btn btn-sm btn-ghost-secondary me-1" @click="abrirFormulario(ins)">Editar</button>
                <button class="btn btn-sm btn-ghost-danger" @click="eliminar(ins)">✕</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="modal" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-md modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ editando ? 'Editar' : 'Nueva' }} Inscripción</h5>
            <button type="button" class="btn-close" @click="modal = false"></button>
          </div>
          <form @submit.prevent="guardar">
            <div class="modal-body">
              <div v-if="error" class="alert alert-danger mb-3">{{ error }}</div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label required">Equipo</label>
                  <select v-model="form.id_equipo" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option v-for="e in equipos" :key="e.id_equipo" :value="e.id_equipo">{{ e.nombre_equipo }}</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label required">Temporada</label>
                  <select v-model="form.id_temporada" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">{{ t.nombre }}</option>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label required">Fecha de Inscripción</label>
                  <input v-model="form.fecha_inscripcion" type="date" class="form-control" required />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Estado de Pago</label>
                  <select v-model="form.estado_pago" class="form-select">
                    <option value="pendiente">Pendiente</option>
                    <option value="pagado">Pagado</option>
                    <option value="rechazado">Rechazado</option>
                  </select>
                </div>
              </div>
              <div class="mb-3">
                <label class="form-label">Monto Pagado</label>
                <input v-model="form.monto_pagado" type="number" step="0.01" min="0" class="form-control" placeholder="0.00" />
              </div>
              <div class="mb-3">
                <label class="form-label">Observaciones</label>
                <textarea v-model="form.observaciones" class="form-control" rows="2" placeholder="Notas adicionales..."></textarea>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-ghost-secondary me-auto" @click="modal = false">Cancelar</button>
              <button type="submit" class="btn btn-primary" :disabled="guardando">{{ guardando ? 'Guardando...' : 'Guardar' }}</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="modal" class="modal-backdrop show"></div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'

const inscripciones = ref([])
const temporadas = ref([])
const equipos = ref([])
const temporadaFiltro = ref('')
const cargando = ref(false)
const modal = ref(false)
const editando = ref(false)
const guardando = ref(false)
const error = ref('')
const form = ref({})

function formatFecha(f) { return f ? new Date(f).toLocaleDateString('es-VE') : '—' }
function formatBs(v) { return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 2 }).format(v || 0) + ' Bs.' }

async function cargar() {
  cargando.value = true
  try {
    const params = temporadaFiltro.value ? { temporada: temporadaFiltro.value } : {}
    const { data } = await api.get('/inscripciones', { params })
    inscripciones.value = data
  } finally { cargando.value = false }
}

function abrirFormulario(ins = null) {
  error.value = ''
  if (ins) {
    editando.value = true
    form.value = { ...ins, fecha_inscripcion: ins.fecha_inscripcion?.substring(0, 10) }
  } else {
    editando.value = false
    form.value = { id_equipo: '', id_temporada: '', fecha_inscripcion: new Date().toISOString().substring(0, 10), estado_pago: 'pendiente', monto_pagado: 0, observaciones: '' }
  }
  modal.value = true
}

async function guardar() {
  guardando.value = true
  error.value = ''
  try {
    if (editando.value) await api.put(`/inscripciones/${form.value.id_inscripcion}`, form.value)
    else await api.post('/inscripciones', form.value)
    modal.value = false
    cargar()
  } catch (e) { error.value = e.response?.data?.error || 'Error al guardar' }
  finally { guardando.value = false }
}

async function eliminar(ins) {
  if (!confirm(`¿Eliminar inscripción de "${ins.nombre_equipo}"?`)) return
  await api.delete(`/inscripciones/${ins.id_inscripcion}`)
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
