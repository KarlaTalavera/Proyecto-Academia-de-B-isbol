<template>
  <div>
    <!-- Resumen tarjetas -->
    <div class="row row-deck row-cards mb-3">
      <div class="col-sm-6 col-lg-4">
        <div class="card card-sm">
          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-auto"><span class="bg-green text-white avatar">💵</span></div>
              <div class="col">
                <div class="font-weight-medium">Total Ingresos</div>
                <div class="text-muted">{{ formatBs(totalIngresos) }}</div>
                <div v-if="tasa.tasaDisponible" class="text-green" style="font-size:0.78rem; font-weight:600;">
                  ≈ {{ formatUsd(tasa.bsADolar(totalIngresos)) }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Indicador de tasa -->
      <div class="col-sm-6 col-lg-4">
        <div class="card card-sm">
          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-auto"><span class="bg-blue text-white avatar">📊</span></div>
              <div class="col">
                <div class="font-weight-medium">Tasa BCV del día</div>
                <div v-if="tasa.cargando" class="text-muted" style="font-size:0.8rem;">Consultando...</div>
                <div v-else-if="tasa.error" class="text-danger" style="font-size:0.78rem;">{{ tasa.error }}</div>
                <div v-else-if="tasa.tasaDisponible">
                  <div class="text-muted fw-bold">1 $ = {{ formatBs(tasa.bcv) }}</div>
                </div>
                <div v-else class="text-muted" style="font-size:0.8rem;">No disponible</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Barra de acciones -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <input v-model="busqueda" class="form-control form-control-sm" placeholder="Buscar concepto o equipo..." style="max-width:280px" />
      <button class="btn btn-primary btn-sm" @click="abrirFormulario()">+ Nuevo Ingreso</button>
    </div>

    <!-- Tabla -->
    <div class="card">
      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Concepto</th>
              <th>Equipo</th>
              <th>Tipo de Pago</th>
              <th class="text-end">Monto</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando">
              <td colspan="6" class="text-center py-4">Cargando...</td>
            </tr>
            <tr v-else-if="!ingresosFiltrados.length">
              <td colspan="6" class="text-center py-4 text-muted">No hay ingresos registrados</td>
            </tr>
            <tr v-for="ing in ingresosFiltrados" :key="ing.id_ingreso">
              <td>{{ formatFecha(ing.fecha_ingreso) }}</td>
              <td>{{ ing.concepto }}</td>
              <td>{{ ing.nombre_equipo }}</td>
              <td>
                <span v-if="ing.tipo_pago" class="badge bg-blue-lt">{{ ing.tipo_pago }}</span>
                <span v-else class="text-muted">—</span>
              </td>
              <td class="text-end">
                <div class="fw-bold text-green">{{ formatBs(ing.valor) }}</div>
                <div v-if="tasa.tasaDisponible" style="font-size:0.72rem; color:#16a34a;">
                  ≈ {{ formatUsd(tasa.bsADolar(ing.valor)) }}
                </div>
              </td>
              <td class="text-end">
                <button class="btn btn-sm btn-ghost-secondary me-1" @click="abrirFormulario(ing)">Editar</button>
                <button class="btn btn-sm btn-ghost-danger" @click="confirmarEliminar(ing)">✕</button>
              </td>
            </tr>
          </tbody>
          <tfoot v-if="ingresosFiltrados.length">
            <tr>
              <td colspan="4" class="text-end fw-bold">Total filtrado:</td>
              <td class="text-end">
                <div class="fw-bold text-green">{{ formatBs(totalFiltrado) }}</div>
                <div v-if="tasa.tasaDisponible" style="font-size:0.72rem; color:#16a34a;">
                  ≈ {{ formatUsd(tasa.bsADolar(totalFiltrado)) }}
                </div>
              </td>
              <td></td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="modalAbierto" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-md modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ editando ? 'Editar Ingreso' : 'Registrar Ingreso' }}</h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <form @submit.prevent="guardar">
            <div class="modal-body">
              <div v-if="errorModal" class="alert alert-danger mb-3">{{ errorModal }}</div>

              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label required">Equipo</label>
                  <select v-model="form.id_equipo" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option v-for="eq in equipos" :key="eq.id_equipo" :value="eq.id_equipo">
                      {{ eq.nombre_equipo }}
                    </option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label required">Fecha</label>
                  <input v-model="form.fecha_ingreso" type="date" class="form-control" required />
                </div>
              </div>

              <div class="mb-3">
                <label class="form-label required">Concepto</label>
                <input v-model="form.concepto" class="form-control" placeholder="Ej: Inscripción temporada 2026" required />
              </div>

              <!-- Conversión dual Bs ↔ $ -->
              <div class="row g-2 mb-1">
                <div class="col-6">
                  <label class="form-label required" style="font-size:0.82rem;">Monto en Bolívares</label>
                  <div class="input-group">
                    <span class="input-group-text" style="font-size:0.82rem; font-weight:600; color:#475569;">Bs.</span>
                    <input
                      v-model="form.valor"
                      type="number" step="0.01" min="0"
                      class="form-control"
                      placeholder="0.00"
                      required
                      @input="sincronizarDesdebs"
                    />
                  </div>
                </div>
                <div class="col-6">
                  <label class="form-label" style="font-size:0.82rem; color:#64748b;">
                    Equivalente en Dólares
                    <span v-if="tasa.tasaDisponible" style="font-size:0.7rem;">(BCV)</span>
                  </label>
                  <div class="input-group">
                    <span class="input-group-text" style="font-size:0.82rem; font-weight:600; color:#16a34a;">$</span>
                    <input
                      v-model="montoUsd"
                      type="number" step="0.01" min="0"
                      class="form-control"
                      placeholder="0.00"
                      :disabled="!tasa.tasaDisponible"
                      @input="sincronizarDesdeUsd"
                    />
                  </div>
                </div>
              </div>
              <div v-if="tasa.tasaDisponible" class="text-muted mb-3" style="font-size:0.72rem;">
                Tasa BCV: 1 $ = {{ formatBs(tasa.bcv) }}
              </div>
              <div v-else-if="tasa.error" class="text-warning mb-3" style="font-size:0.72rem;">
                ⚠ {{ tasa.error }} — ingresa solo el monto en Bs.
              </div>

              <div class="mb-3">
                <label class="form-label">Tipo de Pago</label>
                <select v-model="form.tipo_pago" class="form-select">
                  <option value="">— Seleccionar —</option>
                  <option>Efectivo</option>
                  <option>Transferencia</option>
                  <option>Divisas</option>
                  <option>Pago Móvil</option>
                </select>
              </div>

              <input type="hidden" v-model="form.id_temporada" />
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
import { ref, computed, onMounted, watch } from 'vue'
import api from '@/services/api'
import { useTasaStore } from '@/store/tasa'

const tasa = useTasaStore()

const ingresos   = ref([])
const equipos    = ref([])
const busqueda   = ref('')
const cargando   = ref(false)
const modalAbierto = ref(false)
const editando     = ref(false)
const guardando    = ref(false)
const errorModal   = ref('')
const temporadaActiva = ref(null)
const montoUsd     = ref('')

const form = ref({
  id_equipo: '', id_temporada: '', concepto: '',
  valor: '', fecha_ingreso: '', tipo_pago: '',
})

const ingresosFiltrados = computed(() =>
  ingresos.value.filter(i =>
    i.concepto.toLowerCase().includes(busqueda.value.toLowerCase()) ||
    i.nombre_equipo?.toLowerCase().includes(busqueda.value.toLowerCase())
  )
)
const totalIngresos = computed(() => ingresos.value.reduce((s, i) => s + Number(i.valor), 0))
const totalFiltrado = computed(() => ingresosFiltrados.value.reduce((s, i) => s + Number(i.valor), 0))

function formatBs(v) {
  return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(v || 0) + ' Bs.'
}
function formatUsd(v) {
  if (v == null) return ''
  return '$ ' + new Intl.NumberFormat('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(v)
}
function formatFecha(f) {
  if (!f) return '—'
  return new Date(f).toLocaleDateString('es-VE')
}

// Cuando el usuario escribe en Bs → actualiza el campo USD
function sincronizarDesdebs() {
  if (!tasa.tasaDisponible || !form.value.valor) { montoUsd.value = ''; return }
  montoUsd.value = (Number(form.value.valor) / tasa.bcv).toFixed(2)
}
// Cuando el usuario escribe en USD → actualiza el campo Bs
function sincronizarDesdeUsd() {
  if (!tasa.tasaDisponible || !montoUsd.value) { form.value.valor = ''; return }
  form.value.valor = (Number(montoUsd.value) * tasa.bcv).toFixed(2)
}

async function cargar() {
  cargando.value = true
  try {
    const [resIngresos, resEquipos, resTemp] = await Promise.all([
      api.get('/finanzas/ingresos'),
      api.get('/equipos'),
      api.get('/temporadas').catch(() => ({ data: [] })),
    ])
    ingresos.value = resIngresos.data
    equipos.value  = resEquipos.data
    temporadaActiva.value = resTemp.data.find(t => t.activa)?.id_temporada || 1
  } finally {
    cargando.value = false
  }
}

function abrirFormulario(ingreso = null) {
  errorModal.value = ''
  montoUsd.value   = ''
  if (ingreso) {
    editando.value = true
    form.value = { ...ingreso, fecha_ingreso: ingreso.fecha_ingreso?.substring(0, 10) }
    if (tasa.tasaDisponible && ingreso.valor) {
      montoUsd.value = (Number(ingreso.valor) / tasa.bcv).toFixed(2)
    }
  } else {
    editando.value = false
    form.value = {
      id_equipo: '', id_temporada: temporadaActiva.value || 1,
      concepto: '', valor: '',
      fecha_ingreso: new Date().toISOString().substring(0, 10),
      tipo_pago: '',
    }
  }
  modalAbierto.value = true
}

function cerrarModal() { modalAbierto.value = false }

async function guardar() {
  if (!(form.value.concepto || '').trim()) { alert('El concepto es obligatorio'); return }
  if (!(Number(form.value.valor) > 0)) { alert('El valor debe ser mayor a 0'); return }
  guardando.value = true
  errorModal.value = ''
  try {
    if (editando.value) {
      await api.put(`/finanzas/ingresos/${form.value.id_ingreso}`, form.value)
    } else {
      await api.post('/finanzas/ingresos', form.value)
    }
    cerrarModal()
    cargar()
  } catch (e) {
    errorModal.value = e.response?.data?.error || 'Error al guardar'
  } finally {
    guardando.value = false
  }
}

async function confirmarEliminar(ing) {
  if (!confirm(`¿Eliminar ingreso "${ing.concepto}"?`)) return
  await api.delete(`/finanzas/ingresos/${ing.id_ingreso}`)
  cargar()
}

// Si la tasa llega después de que el usuario ya escribió el monto, recalcular
watch(() => tasa.bcv, (nuevaTasa) => {
  if (nuevaTasa && form.value.valor) sincronizarDesdebs()
})

onMounted(() => {
  cargar()
  tasa.cargar()
})
</script>
