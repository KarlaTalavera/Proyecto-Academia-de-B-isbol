<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Proveedores</h2>
        <p class="page-subtitle">Gestión de proveedores de servicios</p>
      </div>
      <button class="btn btn-primary btn-sm" @click="abrirFormulario()">+ Nuevo Proveedor</button>
    </div>

    <div class="d-flex mb-3">
      <input v-model="busqueda" class="form-control form-control-sm" placeholder="Buscar por nombre o RIF..." style="max-width:280px" />
    </div>

    <div class="card">
      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>RIF</th>
              <th>Nombre</th>
              <th>Servicio</th>
              <th>Contacto</th>
              <th class="text-center">Estado</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando"><td colspan="6" class="text-center py-4">Cargando...</td></tr>
            <tr v-else-if="!filtrados.length"><td colspan="6" class="text-center py-4 text-muted">No hay proveedores</td></tr>
            <tr v-for="p in filtrados" :key="p.id_proveedor">
              <td><span class="badge bg-blue-lt">{{ p.rif }}</span></td>
              <td class="fw-semibold">{{ p.nombre_proveedor }}</td>
              <td class="text-muted" style="font-size:0.85rem;">{{ p.servicio }}</td>
              <td>
                <div v-if="p.telefono" style="font-size:0.82rem;">{{ p.telefono }}</div>
                <div v-if="p.email" class="text-muted" style="font-size:0.78rem;">{{ p.email }}</div>
              </td>
              <td class="text-center">
                <span class="badge" :class="p.activo ? 'bg-success-lt text-success' : 'bg-secondary-lt'">{{ p.activo ? 'Activo' : 'Inactivo' }}</span>
              </td>
              <td class="text-end">
                <button class="btn btn-sm btn-ghost-secondary me-1" @click="abrirFormulario(p)">Editar</button>
                <button class="btn btn-sm btn-ghost-danger" @click="eliminar(p)">✕</button>
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
            <h5 class="modal-title">{{ editando ? 'Editar' : 'Nuevo' }} Proveedor</h5>
            <button type="button" class="btn-close" @click="modal = false"></button>
          </div>
          <form @submit.prevent="guardar">
            <div class="modal-body">
              <div v-if="error" class="alert alert-danger mb-3">{{ error }}</div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label required">RIF</label>
                  <input v-model="form.rif" type="text" class="form-control" placeholder="J-12345678-9" required />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label required">Nombre</label>
                  <input v-model="form.nombre_proveedor" type="text" class="form-control" required />
                </div>
              </div>
              <div class="mb-3">
                <label class="form-label required">Servicio que ofrece</label>
                <textarea v-model="form.servicio" class="form-control" rows="2" required></textarea>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Teléfono</label>
                  <input v-model="form.telefono" type="text" class="form-control" placeholder="0412-1234567" />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Email</label>
                  <input v-model="form.email" type="email" class="form-control" placeholder="correo@ejemplo.com" />
                </div>
              </div>
              <div v-if="editando" class="mb-3">
                <label class="form-check form-switch">
                  <input v-model="form.activo" class="form-check-input" type="checkbox" :true-value="1" :false-value="0" />
                  <span class="form-check-label">Proveedor activo</span>
                </label>
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
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'

const proveedores = ref([])
const busqueda = ref('')
const cargando = ref(false)
const modal = ref(false)
const editando = ref(false)
const guardando = ref(false)
const error = ref('')
const form = ref({})

const filtrados = computed(() =>
  proveedores.value.filter(p =>
    p.nombre_proveedor.toLowerCase().includes(busqueda.value.toLowerCase()) ||
    p.rif.toLowerCase().includes(busqueda.value.toLowerCase())
  )
)

async function cargar() {
  cargando.value = true
  try { proveedores.value = (await api.get('/proveedores')).data }
  finally { cargando.value = false }
}

function abrirFormulario(p = null) {
  error.value = ''
  if (p) {
    editando.value = true
    form.value = { ...p }
  } else {
    editando.value = false
    form.value = { rif: '', nombre_proveedor: '', servicio: '', telefono: '', email: '', activo: 1 }
  }
  modal.value = true
}

async function guardar() {
  guardando.value = true
  error.value = ''
  try {
    if (editando.value) await api.put(`/proveedores/${form.value.id_proveedor}`, form.value)
    else await api.post('/proveedores', form.value)
    modal.value = false
    cargar()
  } catch (e) { error.value = e.response?.data?.error || 'Error al guardar' }
  finally { guardando.value = false }
}

async function eliminar(p) {
  if (!confirm(`¿Eliminar proveedor "${p.nombre_proveedor}"?`)) return
  await api.delete(`/proveedores/${p.id_proveedor}`)
  cargar()
}

onMounted(cargar)
</script>
