<template>
  <div>
    <!-- Resumen -->
    <div class="row row-deck row-cards mb-3">
      <div class="col-sm-6 col-lg-4">
        <div class="card card-sm">
          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-auto"><span class="bg-red text-white avatar">📤</span></div>
              <div class="col">
                <div class="font-weight-medium">Total Egresos</div>
                <div class="text-muted">{{ formatBs(totalEgresos) }}</div>
                <div v-if="tasa.tasaDisponible" class="text-danger" style="font-size:0.78rem; font-weight:600;">
                  ≈ {{ formatUsd(tasa.bsADolar(totalEgresos)) }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Indicador tasa -->
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

    <!-- Acciones -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <input v-model="busqueda" class="form-control form-control-sm" placeholder="Buscar gasto..." style="max-width:280px" />
      <button class="btn btn-danger btn-sm" @click="abrirFormulario()">+ Nuevo Egreso</button>
    </div>

    <!-- Tabla -->
    <div class="card">
      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Descripción del Gasto</th>
              <th>Tipo de Pago</th>
              <th class="text-end">Monto</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando">
              <td colspan="5" class="text-center py-4">Cargando...</td>
            </tr>
            <tr v-else-if="!egresosFiltrados.length">
              <td colspan="5" class="text-center py-4 text-muted">No hay egresos registrados</td>
            </tr>
            <tr v-for="eg in egresosFiltrados" :key="eg.id_egreso">
              <td>{{ formatFecha(eg.fecha_egreso) }}</td>
              <td>{{ eg.nota_gastos }}</td>
              <td>
                <span v-if="eg.tipo_pago" class="badge bg-orange-lt">{{ eg.tipo_pago }}</span>
                <span v-else class="text-muted">—</span>
              </td>
              <td class="text-end">
                <div class="fw-bold text-red">{{ formatBs(eg.gasto) }}</div>
                <div v-if="tasa.tasaDisponible" style="font-size:0.72rem; color:#ef4444;">
                  ≈ {{ formatUsd(tasa.bsADolar(eg.gasto)) }}
                </div>
              </td>
              <td class="text-end">
                <button class="btn btn-sm btn-ghost-secondary me-1" @click="abrirFormulario(eg)">Editar</button>
                <button class="btn btn-sm btn-ghost-danger" @click="confirmarEliminar(eg)">✕</button>
              </td>
            </tr>
          </tbody>
          <tfoot v-if="egresosFiltrados.length">
            <tr>
              <td colspan="3" class="text-end fw-bold">Total filtrado:</td>
              <td class="text-end">
                <div class="fw-bold text-red">{{ formatBs(totalFiltrado) }}</div>
                <div v-if="tasa.tasaDisponible" style="font-size:0.72rem; color:#ef4444;">
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
            <h5 class="modal-title">{{ editando ? 'Editar Egreso' : 'Registrar Egreso' }}</h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <form @submit.prevent="guardar">
            <div class="modal-body">
              <div v-if="errorModal" class="alert alert-danger mb-3">{{ errorModal }}</div>

              <div class="mb-3">
                <label class="form-label required">Descripción del Gasto</label>
                <textarea v-model="form.nota_gastos" class="form-control" rows="2"
                  placeholder="Ej: Honorarios árbitros — Partido 12 vs 13" required></textarea>
              </div>

              <!-- Conversión dual Bs ↔ $ -->
              <div class="row g-2 mb-1">
                <div class="col-6">
                  <label class="form-label required" style="font-size:0.82rem;">Monto en Bolívares</label>
                  <div class="input-group">
                    <span class="input-group-text" style="font-size:0.82rem; font-weight:600; color:#475569;">Bs.</span>
                    <input
                      v-model="form.gasto"
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
                    <span class="input-group-text" style="font-size:0.82rem; font-weight:600; color:#ef4444;">$</span>
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

              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label required">Fecha</label>
                  <input v-model="form.fecha_egreso" type="date" class="form-control" required />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Tipo de Pago</label>
                  <select v-model="form.tipo_pago" class="form-select">
                    <option value="">— Seleccionar —</option>
                    <option>Efectivo</option>
                    <option>Transferencia</option>
                    <option>Divisas</option>
                    <option>Pago Móvil</option>
                    <option>Cheque</option>
                  </select>
                </div>
              </div>

              <input type="hidden" v-model="form.id_temporada" />
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-ghost-secondary me-auto" @click="cerrarModal">Cancelar</button>
              <button type="submit" class="btn btn-danger" :disabled="guardando">
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

const egresos  = ref([])
const busqueda = ref('')
const cargando = ref(false)
const modalAbierto = ref(false)
const editando     = ref(false)
const guardando    = ref(false)
const errorModal   = ref('')
const temporadaActiva = ref(1)
const montoUsd     = ref('')

const form = ref({ id_temporada: 1, nota_gastos: '', gasto: '', fecha_egreso: '', tipo_pago: '' })

const egresosFiltrados = computed(() =>
  egresos.value.filter(e => e.nota_gastos.toLowerCase().includes(busqueda.value.toLowerCase()))
)
const totalEgresos  = computed(() => egresos.value.reduce((s, e) => s + Number(e.gasto), 0))
const totalFiltrado = computed(() => egresosFiltrados.value.reduce((s, e) => s + Number(e.gasto), 0))

function formatBs(v) {
  return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(v || 0) + ' Bs.'
}
function formatUsd(v) {
  if (v == null) return ''
  return '$ ' + new Intl.NumberFormat('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(v)
}
function formatFecha(f) {
  return f ? new Date(f).toLocaleDateString('es-VE') : '—'
}

function sincronizarDesdebs() {
  if (!tasa.tasaDisponible || !form.value.gasto) { montoUsd.value = ''; return }
  montoUsd.value = (Number(form.value.gasto) / tasa.bcv).toFixed(2)
}
function sincronizarDesdeUsd() {
  if (!tasa.tasaDisponible || !montoUsd.value) { form.value.gasto = ''; return }
  form.value.gasto = (Number(montoUsd.value) * tasa.bcv).toFixed(2)
}

async function cargar() {
  cargando.value = true
  try {
    const [resEgresos, resTemp] = await Promise.all([
      api.get('/finanzas/egresos'),
      api.get('/temporadas').catch(() => ({ data: [] })),
    ])
    egresos.value = resEgresos.data
    temporadaActiva.value = resTemp.data.find(t => t.activa)?.id_temporada || 1
  } finally {
    cargando.value = false
  }
}

function abrirFormulario(egreso = null) {
  errorModal.value = ''
  montoUsd.value   = ''
  if (egreso) {
    editando.value = true
    form.value = { ...egreso, fecha_egreso: egreso.fecha_egreso?.substring(0, 10) }
    if (tasa.tasaDisponible && egreso.gasto) {
      montoUsd.value = (Number(egreso.gasto) / tasa.bcv).toFixed(2)
    }
  } else {
    editando.value = false
    form.value = {
      id_temporada: temporadaActiva.value,
      nota_gastos: '', gasto: '',
      fecha_egreso: new Date().toISOString().substring(0, 10),
      tipo_pago: '',
    }
  }
  modalAbierto.value = true
}

function cerrarModal() { modalAbierto.value = false }

async function guardar() {
  guardando.value = true
  errorModal.value = ''
  try {
    if (editando.value) {
      await api.put(`/finanzas/egresos/${form.value.id_egreso}`, form.value)
    } else {
      await api.post('/finanzas/egresos', form.value)
    }
    cerrarModal()
    cargar()
  } catch (e) {
    errorModal.value = e.response?.data?.error || 'Error al guardar'
  } finally {
    guardando.value = false
  }
}

async function confirmarEliminar(eg) {
  if (!confirm(`¿Eliminar egreso "${eg.nota_gastos}"?`)) return
  await api.delete(`/finanzas/egresos/${eg.id_egreso}`)
  cargar()
}

watch(() => tasa.bcv, (nuevaTasa) => {
  if (nuevaTasa && form.value.gasto) sincronizarDesdebs()
})

onMounted(() => {
  cargar()
  tasa.cargar()
})
</script>
