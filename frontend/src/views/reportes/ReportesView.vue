<template>
  <div class="container-fluid">
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Reportes</h2>
        <p class="page-subtitle text-muted">Estadísticas, finanzas y análisis de la liga</p>
      </div>
      <select v-model="temporadaId" class="form-select form-select-sm" style="max-width:220px;" @change="cargar">
        <option value="">— Seleccionar temporada —</option>
        <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">
          {{ t.nombre }} ({{ t.anio }})
        </option>
      </select>
    </div>

    <div class="d-flex gap-1 mb-4 p-1 flex-wrap tab-container">
      <button v-for="t in tabs" :key="t.key"
        class="btn btn-sm"
        :class="tab === t.key ? 'btn-white shadow-sm fw-semibold' : 'btn-ghost-secondary'"
        style="border-radius:8px; font-size:0.82rem;"
        @click="tab = t.key"
      >
        <component :is="t.icon" :size="15" class="me-1" /> {{ t.label }}
      </button>
    </div>

    <div v-if="!temporadaId" class="card shadow-sm">
      <div class="card-body text-center py-5 text-muted">
        <IconChartBar :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
        <p class="mb-0">Selecciona una temporada para visualizar los datos analíticos</p>
      </div>
    </div>

    <div v-else>

      <!-- ── Est. Bateadores ─────────────────────────────────── -->
      <ReporteBateadoresView v-if="tab === 'bateadores'" :embedded="true" :temporada-sel="temporadaId" />

      <!-- ── Ef. Pitcheo ────────────────────────────────────── -->
      <ReporteEfectividadPitcheoView v-else-if="tab === 'efectividad'" :embedded="true" :temporada-sel="temporadaId" />

      <!-- ── Finanzas ───────────────────────────────────────── -->
      <div v-else-if="tab === 'finanzas'">

        <!-- Botones exportar -->
        <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
        <div class="d-flex align-items-center gap-2" style="font-size:0.84rem; color:#475569;">
          <span class="fw-semibold">Fecha inicio:</span>
          <input v-model="fechaDesde" type="date" class="form-control form-control-sm" style="max-width:145px;" @change="cargar" />
        </div>
        <div class="d-flex align-items-center gap-2" style="font-size:0.84rem; color:#475569;">
          <span class="fw-semibold">Fecha fin:</span>
          <input v-model="fechaHasta" type="date" class="form-control form-control-sm" style="max-width:145px;" @change="cargar" />
        </div>
         <div class="mb-3">
            <label class="form-label fw-semibold text-secondary d-flex align-items-center gap-1">
              <span>Proveedores</span>
            </label>
            
            <div class="border rounded p-3 bg-light" style="max-height: 160px; overflow-y: auto;">
              <div v-if="cargandoEtiquetas" class="text-muted small text-center py-2">
                <span class="spinner-border spinner-border-sm me-2" role="status"></span>
                Cargando servicios disponibles...
              </div>

              <div v-else-if="listaServicios.length === 0" class="text-muted small text-center py-2">
                No se encontraron servicios registrados.
              </div>

              <div v-else class="row g-2">
                <div v-for="servicio in listaServicios" :key="servicio" class="col-6 col-md-4 col-lg-3">
                  <label 
                    class="form-check form-check-inline m-0 cursor-pointer w-100 p-2 border rounded text-truncate"
                    :class="serviciosSeleccionados.includes(servicio) ? 'bg-primary-soft border-primary' : 'bg-white'"
                    style="display: block;">
                    <input type="checkbox" class="form-check-input me-2" :value="servicio" v-model="serviciosSeleccionados" />
                    <span class="form-check-label small text-capitalize" :class="serviciosSeleccionados.includes(servicio) ? 'text-primary fw-semibold' : ''">
                      {{ servicio }}
                    </span>
                  </label>
                </div>
              </div>
            </div>
            
            <div class="form-hint small text-muted mt-1">
              Selecciona uno o varios servicios para filtrar la lista de egresos.
            </div>
          </div>

        <button v-if="fechaDesde || fechaHasta" class="btn btn-sm btn-ghost-secondary" @click="fechaDesde=''; fechaHasta=''; cargar()">
          Limpiar fechas
        </button>
        <div class="ms-auto d-flex justify-content-end gap-2">
          <button class="btn btn-sm btn-outline-danger" @click="exportFinanzasPDF">
            <IconFileTypePdf :size="16" class="me-1" /> Exportar PDF
          </button>
          <button class="btn btn-sm btn-outline-success" @click="exportFinanzasExcel">
            <IconFileSpreadsheet :size="16" class="me-1" /> Exportar Excel
          </button>
        </div>
      </div>

      <div v-if="cargando" class="card shadow-sm">
          <div class="card-body text-center py-5">
            <span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...
          </div>
        </div>

        <template v-else>
          <!-- Banner ganancia / pérdida -->
          <div class="card mb-4 shadow-sm border-0 resultado-banner"
               :class="finanzas.balance >= 0 ? 'resultado-ganancia' : 'resultado-perdida'">
            <div class="card-body d-flex align-items-center justify-content-between px-4 py-3">
              <div class="d-flex align-items-center gap-3">
                <span class="avatar avatar-md rounded-circle"
                      :style="finanzas.balance >= 0
                        ? 'background:#10b981; color:#fff;'
                        : 'background:#ef4444; color:#fff;'">
                  <IconTrendingUp v-if="finanzas.balance >= 0" :size="22" />
                  <IconTrendingDown v-else :size="22" />
                </span>
                <div>
                  <div class="small" :class="finanzas.balance >= 0 ? 'text-success' : 'text-danger'" style="opacity:0.8;">
                    Resultado de la temporada
                  </div>
                  <div class="fw-bold h5 mb-0"
                       :style="finanzas.balance >= 0 ? 'color:#065f46' : 'color:#991b1b'">
                    {{ finanzas.balance >= 0 ? 'Temporada con Ganancia' : 'Temporada con Pérdida' }}
                  </div>
                </div>
              </div>
              <div class="text-end">
                <div class="small text-muted">Balance neto</div>
                <div class="fw-bold h3 mb-0"
                     :style="finanzas.balance >= 0 ? 'color:#065f46' : 'color:#991b1b'">
                  {{ finanzas.balance >= 0 ? '+' : '' }}{{ formatBs(finanzas.balance) }}
                </div>
              </div>
            </div>
          </div>

          <!-- Cards ingresos / egresos -->
          <div class="row g-3 mb-4">
            <div class="col-md-6">
              <div class="card card-sm shadow-sm borde-ingreso">
                <div class="card-body d-flex align-items-center gap-3">
                  <span class="avatar bg-success-lt text-success">
                    <IconArrowUpRight :size="22" />
                  </span>
                  <div>
                    <div class="text-muted small">Total Ingresos</div>
                    <div class="fw-bold h4 mb-0 text-success">{{ formatBs(finanzas.total_ingresos) }}</div>
                    <div class="text-muted" style="font-size:0.73rem;">
                      {{ finanzas.ingresos_por_concepto?.length || 0 }} categorías registradas
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-md-6">
              <div class="card card-sm shadow-sm borde-egreso">
                <div class="card-body d-flex align-items-center gap-3">
                  <span class="avatar bg-danger-lt text-danger">
                    <IconArrowDownRight :size="22" />
                  </span>
                  <div>
                    <div class="text-muted small">Total Egresos</div>
                    <div class="fw-bold h4 mb-0 text-danger">{{ formatBs(finanzas.total_egresos) }}</div>
                    <div class="text-muted" style="font-size:0.73rem;">
                      {{ finanzas.egresos_por_proveedor?.length || 0 }} proveedores
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Comparación ingresos vs egresos -->
          <div class="card shadow-sm mb-4">
            <div class="card-body py-3">
              <div class="small text-muted fw-semibold mb-2">Distribución del flujo de caja</div>
              <div class="d-flex align-items-center gap-2">
                <span class="text-success small fw-semibold" style="min-width:40px;">{{ ingresoPct }}%</span>
                <div class="flex-grow-1" style="height:12px; border-radius:6px; overflow:hidden; background:#f1f5f9;">
                  <div class="h-100 bg-success" :style="`width:${ingresoPct}%`"></div>
                </div>
                <span class="small text-muted">Ingresos</span>
              </div>
              <div class="d-flex align-items-center gap-2 mt-2">
                <span class="text-danger small fw-semibold" style="min-width:40px;">{{ egresosPct }}%</span>
                <div class="flex-grow-1" style="height:12px; border-radius:6px; overflow:hidden; background:#f1f5f9;">
                  <div class="h-100 bg-danger" :style="`width:${egresosPct}%`"></div>
                </div>
                <span class="small text-muted">Egresos</span>
              </div>
            </div>
          </div>

         

<!-- Nueva sección: Detalle de Egresos Filtrados -->
<div v-if="finanzas.egresos_detalle?.length" class="card shadow-sm mt-3">
  <div class="card-header">
    <div class="card-header d-flex justify-content-between align-items-center">
  <div>
    <span class="fw-bold">📋 Detalle de Egresos</span>
    <span class="text-muted ms-2 small">({{ finanzas.egresos_detalle.length }} registros)</span>
  </div>
  <button class="btn btn-sm btn-outline-success" @click="exportDetalleExcel">
    <IconFileSpreadsheet :size="16" class="me-1" /> Exportar Excel este detalle
  </button>
</div>
  </div>
  <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
    <table class="table table-vcenter table-sm">
      <thead class="table-light sticky-top">
        <tr>
          <th style="min-width: 100px;">Fecha</th>
          <th>Concepto</th>
          <th>Proveedor</th>
          <th>Servicio</th>
          <th class="text-end" style="min-width: 120px;">Monto</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="eg in finanzas.egresos_detalle" :key="eg.id_egreso">
          <td class="text-nowrap">{{ formatFecha(eg.fecha_egreso) }}</td>
          <td>{{ eg.nota_gastos }}</td>
          <td>{{ eg.proveedor }}</td>
          <td>{{ eg.servicio }}</td>
          <td class="text-end text-danger fw-bold">{{ formatBs(eg.gasto) }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

          <!-- Tablas detalle -->
          <div class="row g-3">
            <div class="col-md-6">
              <div class="card shadow-sm">
                <div class="card-header d-flex align-items-center justify-content-between gap-2 flex-wrap">
                    <div class="d-flex align-items-center gap-2">
                      <span class="badge bg-success-lt text-success fw-bold">+</span>
                      <span class="fw-bold">Ingresos por Concepto</span>
                    </div>
                    <div class="d-flex gap-2">
                      <input v-model="busquedaIngresos" type="text" class="form-control form-control-sm" style="max-width: 200px;" placeholder="Buscar concepto..." />
                      <button class="btn btn-sm btn-outline-success" @click="exportIngresosExcel">
                        <IconFileSpreadsheet :size="16" class="me-1" /> Excel
                      </button>
                    </div>
                  </div>
                <div v-if="!finanzas.ingresos_por_concepto?.length" class="card-body text-center text-muted py-4">
                  Sin ingresos registrados
                </div>
                <div v-else class="table-responsive">
                  <table class="table table-vcenter card-table">
                    <thead>
                      <tr>
                        <th>Concepto</th>
                        <th class="text-end">Monto</th>
                        <th class="text-center" style="min-width:120px;">% del total</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="c in ingresosFiltrados":key="c.categoria">
                        <td class="fw-semibold">{{ c.categoria }}</td>
                        <td class="text-end text-success fw-bold">{{ formatBs(c.total) }}</td>
                        <td class="text-center">
                          <div class="d-flex align-items-center gap-2">
                            <div class="progress flex-grow-1" style="height:6px; border-radius:4px;">
                              <div class="progress-bar bg-success"
                                   :style="`width:${finanzas.total_ingresos ? Math.round((c.total/finanzas.total_ingresos)*100) : 0}%`">
                              </div>
                            </div>
                            <span class="text-muted small" style="min-width:30px;">
                              {{ finanzas.total_ingresos ? Math.round((c.total/finanzas.total_ingresos)*100) : 0 }}%
                            </span>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                    <tfoot>
                      <tr class="fw-bold bg-success-lt">
                        <td>TOTAL</td>
                        <td class="text-end text-success">{{ formatBs(finanzas.total_ingresos) }}</td>
                        <td class="text-center text-muted">100%</td>
                      </tr>
                    </tfoot>
                  </table>
                </div>
              </div>
            </div>

            <div class="col-md-6">
              <div class="card shadow-sm">
                <div class="card-header d-flex align-items-center gap-2">
                  <span class="badge bg-danger-lt text-danger fw-bold">−</span>
                  <span class="fw-bold">Egresos por Proveedor</span>
                </div>
                <div v-if="!finanzas.egresos_por_proveedor?.length" class="card-body text-center text-muted py-4">
                  Sin egresos registrados
                </div>
                <div v-else class="table-responsive">
                  <table class="table table-vcenter card-table">
                    <thead>
                      <tr>
                        <th>Proveedor</th>
                        <th class="text-end">Monto</th>
                        <th class="text-center" style="min-width:120px;">% del total</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="p in finanzas.egresos_por_proveedor" :key="p.proveedor">
                        <td class="fw-semibold">{{ p.proveedor }}</td>
                        <td class="text-end text-danger fw-bold">{{ formatBs(p.total) }}</td>
                        <td class="text-center">
                          <div class="d-flex align-items-center gap-2">
                            <div class="progress flex-grow-1" style="height:6px; border-radius:4px;">
                              <div class="progress-bar bg-danger"
                                   :style="`width:${finanzas.total_egresos ? Math.round((p.total/finanzas.total_egresos)*100) : 0}%`">
                              </div>
                            </div>
                            <span class="text-muted small" style="min-width:30px;">
                              {{ finanzas.total_egresos ? Math.round((p.total/finanzas.total_egresos)*100) : 0 }}%
                            </span>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                    <tfoot>
                      <tr class="fw-bold bg-danger-lt">
                        <td>TOTAL</td>
                        <td class="text-end text-danger">{{ formatBs(finanzas.total_egresos) }}</td>
                        <td class="text-center text-muted">100%</td>
                      </tr>
                    </tfoot>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </template>
      </div>



      <!-- ── Sub-reportes financieros ───────────────────────── -->
      <ReporteTaquillaView          v-else-if="tab === 'taquilla'"    :embedded="true" :temporada-sel="temporadaId" />
      <ReporteOrigenIngresosView    v-else-if="tab === 'origen'"      :embedded="true" :temporada-sel="temporadaId" />
      <ReporteHistoricoIngresosView v-else-if="tab === 'historico'"   :embedded="true" :temporada-sel="temporadaId" />

      <!-- ── Predictivo (solo admin) ───────────────────────── -->
      <ReportePreditivoView        v-else-if="tab === 'predictivo'"  :embedded="true" :temporada-sel="temporadaId" />    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import ReportePreditivoView from './ReportePreditivoView.vue'


import api from '@/services/api'
import { useAuthStore } from '@/store/auth'
import {
  IconChartBar, IconFlame, IconWallet,
  IconFileTypePdf, IconFileSpreadsheet,
  IconChartPie, IconChartLine, IconTicket, IconBallBaseball,
  IconTrendingUp, IconTrendingDown, IconArrowUpRight, IconArrowDownRight,
  IconChartDots3,   // ← agregar esto
} from '@tabler/icons-vue'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

import ReporteBateadoresView        from './ReporteBateadoresView.vue'
import ReporteEfectividadPitcheoView from './ReporteEfectividadPitcheoView.vue'
import ReporteTaquillaView          from './ReporteTaquillaView.vue'
import ReporteOrigenIngresosView    from './ReporteOrigenIngresosView.vue'
import ReporteHistoricoIngresosView from './ReporteHistoricoIngresosView.vue'

const auth = useAuthStore()



// --- ESTADO ---
const tab        = ref(auth.puedeEditar ? 'bateadores' : 'finanzas')
const temporadas = ref([])
const temporadaId = ref('')
const fechaDesde = ref('')
const fechaHasta = ref('')
const cargando   = ref(false)
const busquedaIngresos = ref('')
const finanzas   = ref({
  total_ingresos: 0,
  total_egresos: 0,
  balance: 0,
  ingresos_por_concepto: [],
  egresos_por_proveedor: [],
})
const listaServicios = ref([]) // Aquí guardaremos los servicios que traeremos de la BD
const serviciosSeleccionados = ref([]) // Aquí se guardarán los que el usuario seleccione (los checkboxes)
const cargandoEtiquetas = ref(false) // Para mostrar un estado de carga limpio

// Recargar automáticamente cuando cambien los servicios seleccionados
watch(serviciosSeleccionados, () => {
  cargar()
}, { deep: true })

// --- COMPUTED ---
const tabs = computed(() => {
  const base = []
  if (auth.puedeEditar) {
    base.push(
      { key: 'bateadores',  label: 'Est. Bateadores', icon: IconBallBaseball },
      { key: 'efectividad', label: 'Ef. Pitcheo',     icon: IconFlame },
    )
  }
  if (auth.puedeFinanzas) base.push(
    { key: 'finanzas',   label: 'Finanzas',        icon: IconWallet     },
    { key: 'taquilla',   label: 'Taquilla',         icon: IconTicket     },
    { key: 'origen',     label: 'Origen Ingresos',  icon: IconChartPie   },
    { key: 'historico',  label: 'Hist. Ingresos',   icon: IconChartLine  },
    { key: 'predictivo', label: 'Predictivo',        icon: IconChartDots3 },
  )
  // Dueño: ve predictivo solo cuando no tiene acceso a finanzas (evita duplicado)
  if (auth.esDueno && !auth.puedeFinanzas) base.push(
    { key: 'predictivo', label: 'Predictivo',        icon: IconChartDots3 },
  )
  return base
})

const temporadaNombre = computed(() => {
  const t = temporadas.value.find(x => x.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})

const totalMovimientos = computed(() =>
  Number(finanzas.value.total_ingresos || 0) + Number(finanzas.value.total_egresos || 0)
)

const ingresoPct = computed(() =>
  totalMovimientos.value
    ? Math.round((Number(finanzas.value.total_ingresos) / totalMovimientos.value) * 100)
    : 0
)

const egresosPct = computed(() =>
  totalMovimientos.value
    ? Math.round((Number(finanzas.value.total_egresos) / totalMovimientos.value) * 100)
    : 0
)

const fechaGeneracion = computed(() =>
  new Date().toLocaleString('es-VE', { dateStyle: 'medium', timeStyle: 'short' })
)

const ingresosFiltrados = computed(() => {
  if (!busquedaIngresos.value.trim()) return finanzas.value.ingresos_por_concepto
  const term = busquedaIngresos.value.toLowerCase().trim()
  return finanzas.value.ingresos_por_concepto.filter(c => 
    c.categoria.toLowerCase().includes(term)
  )
})

// --- MÉTODOS ---
function formatBs(v) {
  return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 2 }).format(v || 0) + ' Bs.'
}

async function cargarEtiquetasProveedores() {
  cargandoEtiquetas.value = true
  try {
    console.log('--- 🌐 Frontend disparando la petición Axios... ---')
    // 💡 Ajustamos la ruta aquí para que coincida con el backend protegido
    const { data } = await api.get('/finanzas/egresos/servicios')
    console.log('--- 📥 Frontend recibió esto del servidor:', data)
    listaServicios.value = data
  } catch (error) {
    console.error('Error al conectar con la base de datos de servicios:', error)
  } finally {
    cargandoEtiquetas.value = false
  }
}

async function cargar() {
  if (!temporadaId.value) return
  cargando.value = true
  try {
    const params = {
      temporada: temporadaId.value,
    }
    if (serviciosSeleccionados.value.length) {
      params.servicios = serviciosSeleccionados.value.join(',')
    }
    if (fechaDesde.value) params.fechaDesde = fechaDesde.value
    if (fechaHasta.value) params.fechaHasta = fechaHasta.value

    const { data } = await api.get('/finanzas/balance', { params })
    
    finanzas.value = {
      total_ingresos: Number(data.total_ingresos || 0),
      total_egresos:  Number(data.total_egresos  || 0),
      balance:        Number(data.balance        || 0),
      ingresos_por_concepto: (data.ingresos_por_concepto || []).map(c => ({ ...c, total: Number(c.total || 0) })),
      egresos_por_proveedor: (data.egresos_por_proveedor || []).map(p => ({ ...p, total: Number(p.total || 0) })),
      egresos_por_servicio: (data.egresos_por_servicio || []).map(s => ({ ...s, total: Number(s.total || 0) })),
      egresos_detalle: (data.egresos_detalle || []).map(e => ({ ...e, gasto: Number(e.gasto) })),
    }
  } catch (error) {
    console.error('Error al cargar reporte:', error)
  } finally {
    cargando.value = false
  }
}

async function cargarTemporadas() {
  const { data } = await api.get('/temporadas')
  temporadas.value = data
  const activa = data.find(t => t.activa)
  if (activa) {
    temporadaId.value = activa.id_temporada
    cargar()
  }
}



function formatFecha(f) {
  if (!f) return '—'
  const date = new Date(f)
  return date.toLocaleDateString('es-VE', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

// --- LOGO BASE64 ---
async function cargarLogoBase64(url) {
  return new Promise((resolve) => {
    const img = new Image()
    img.crossOrigin = 'anonymous'
    img.onload = () => {
      const c = document.createElement('canvas')
      c.width = img.naturalWidth; c.height = img.naturalHeight
      c.getContext('2d').drawImage(img, 0, 0)
      resolve(c.toDataURL('image/png'))
    }
    img.onerror = () => resolve(null)
    img.src = url
  })
}

// --- EXPORTAR PDF FINANZAS ---
async function exportFinanzasPDF() {
  try {
    const doc   = new jsPDF({ orientation: 'portrait' })
    const pageW = doc.internal.pageSize.getWidth()
    const pageH = doc.internal.pageSize.getHeight()
    const esGanancia = finanzas.value.balance >= 0

    // Logo
    let logo = null
    for (const url of ['/logos/logorepor.png', '/logos/logo diamante.png', '/logos/logo.png']) {
      logo = await cargarLogoBase64(url)
      if (logo) break
    }

    // Franja superior
    doc.setFillColor(30, 41, 59)
    doc.rect(0, 0, pageW, 40, 'F')
    doc.setFillColor(esGanancia ? 16 : 239, esGanancia ? 185 : 68, esGanancia ? 129 : 68)
    doc.rect(0, 40, pageW, 2, 'F')

    if (logo) {
      doc.addImage(logo, 'PNG', 8, 6, 32, 28)
    } else {
      doc.setDrawColor(255, 255, 255); doc.setLineWidth(0.5)
      doc.roundedRect(8, 6, 26, 26, 3, 3, 'S')
      doc.setTextColor(255, 255, 255); doc.setFontSize(6.5); doc.setFont('helvetica', 'normal')
      doc.text('LOGO', 21, 17, { align: 'center' }); doc.text('LIGA', 21, 23, { align: 'center' })
    }

    doc.setTextColor(255, 255, 255)
    doc.setFontSize(17); doc.setFont('helvetica', 'bold')
    doc.text('Liga Diamante', 46, 16)
    doc.setFontSize(9.5); doc.setFont('helvetica', 'normal'); doc.setTextColor(148, 163, 184)
    doc.text('Reporte Financiero de Temporada', 46, 24)
    doc.setFontSize(9); doc.setFont('helvetica', 'bold'); doc.setTextColor(255, 255, 255)
    doc.text(temporadaNombre.value, pageW - 14, 16, { align: 'right' })
    doc.setFontSize(7.5); doc.setFont('helvetica', 'normal'); doc.setTextColor(148, 163, 184)
    doc.text('Generado: ' + fechaGeneracion.value, pageW - 14, 24, { align: 'right' })

    doc.setTextColor(0, 0, 0)
    let cy = 52

    // Banner resultado
    const bannerColor = esGanancia ? [209, 250, 229] : [254, 226, 226]
    const textColor   = esGanancia ? [6, 95, 70]     : [153, 27, 27]
    doc.setFillColor(...bannerColor)
    doc.roundedRect(14, cy - 4, pageW - 28, 22, 3, 3, 'F')
    doc.setFontSize(11); doc.setFont('helvetica', 'bold')
    doc.setTextColor(...textColor)
    doc.text(
      `${esGanancia ? 'GANANCIA' : 'PÉRDIDA'}: ${esGanancia ? '+' : ''}${formatBs(finanzas.value.balance)}`,
      pageW / 2, cy + 7, { align: 'center' }
    )
    cy += 30

    // Resumen ingresos / egresos
    doc.setFontSize(9); doc.setFont('helvetica', 'normal'); doc.setTextColor(71, 85, 105)
    doc.setFillColor(240, 253, 244)
    doc.roundedRect(14, cy - 3, (pageW - 32) / 2, 14, 2, 2, 'F')
    doc.text('Total Ingresos', 18, cy + 4)
    doc.setFont('helvetica', 'bold'); doc.setTextColor(22, 163, 74)
    doc.text(formatBs(finanzas.value.total_ingresos), 14 + (pageW - 32) / 2 - 4, cy + 4, { align: 'right' })

    const x2 = 14 + (pageW - 32) / 2 + 4
    doc.setFillColor(254, 242, 242)
    doc.roundedRect(x2, cy - 3, (pageW - 32) / 2, 14, 2, 2, 'F')
    doc.setFont('helvetica', 'normal'); doc.setTextColor(71, 85, 105)
    doc.text('Total Egresos', x2 + 4, cy + 4)
    doc.setFont('helvetica', 'bold'); doc.setTextColor(220, 38, 38)
    doc.text(formatBs(finanzas.value.total_egresos), pageW - 14, cy + 4, { align: 'right' })
    cy += 22

    // Tabla ingresos
    doc.setFontSize(10); doc.setFont('helvetica', 'bold'); doc.setTextColor(30, 41, 59)
    doc.text('Ingresos por Concepto', 14, cy)
    cy += 4
    autoTable(doc, {
      startY: cy,
      head: [['Concepto', 'Monto (Bs.)', '% del total']],
      body: [
        ...(finanzas.value.ingresos_por_concepto || []).map(c => [
          c.categoria,
          formatBs(c.total),
          (finanzas.value.total_ingresos ? Math.round((c.total / finanzas.value.total_ingresos) * 100) : 0) + '%',
        ]),
        ['TOTAL', formatBs(finanzas.value.total_ingresos), '100%'],
      ],
      theme: 'grid',
      headStyles: { fillColor: [22, 163, 74], textColor: 255, fontStyle: 'bold', halign: 'center', fontSize: 8.5 },
      columnStyles: { 1: { halign: 'right' }, 2: { halign: 'center' } },
      styles: { fontSize: 8.5, cellPadding: 3 },
      alternateRowStyles: { fillColor: [240, 253, 244] },
      didParseCell(h) {
        if (h.row.index === (finanzas.value.ingresos_por_concepto?.length || 0)) {
          h.cell.styles.fontStyle = 'bold'
          h.cell.styles.fillColor = [209, 250, 229]
          h.cell.styles.textColor = [6, 95, 70]
        }
      },
    })
    cy = doc.lastAutoTable.finalY + 10

    // Tabla egresos
    doc.setFontSize(10); doc.setFont('helvetica', 'bold'); doc.setTextColor(30, 41, 59)
    doc.text('Egresos por Proveedor', 14, cy)
    cy += 4
    autoTable(doc, {
      startY: cy,
      head: [['Proveedor', 'Monto (Bs.)', '% del total']],
      body: [
        ...(finanzas.value.egresos_por_proveedor || []).map(p => [
          p.proveedor,
          formatBs(p.total),
          (finanzas.value.total_egresos ? Math.round((p.total / finanzas.value.total_egresos) * 100) : 0) + '%',
        ]),
        ['TOTAL', formatBs(finanzas.value.total_egresos), '100%'],
      ],
      theme: 'grid',
      headStyles: { fillColor: [220, 38, 38], textColor: 255, fontStyle: 'bold', halign: 'center', fontSize: 8.5 },
      columnStyles: { 1: { halign: 'right' }, 2: { halign: 'center' } },
      styles: { fontSize: 8.5, cellPadding: 3 },
      alternateRowStyles: { fillColor: [254, 242, 242] },
      didParseCell(h) {
        if (h.row.index === (finanzas.value.egresos_por_proveedor?.length || 0)) {
          h.cell.styles.fontStyle = 'bold'
          h.cell.styles.fillColor = [254, 226, 226]
          h.cell.styles.textColor = [153, 27, 27]
        }
      },
    })

    // Pie de página
    const total = doc.internal.getNumberOfPages()
    for (let i = 1; i <= total; i++) {
      doc.setPage(i)
      doc.setDrawColor(226, 232, 240); doc.setLineWidth(0.4)
      doc.line(14, pageH - 14, pageW - 14, pageH - 14)
      doc.setFontSize(7.5); doc.setFont('helvetica', 'normal'); doc.setTextColor(148, 163, 184)
      doc.text('Liga Diamante  ·  Sistema de Gestión', 14, pageH - 8)
      doc.text(temporadaNombre.value, pageW / 2, pageH - 8, { align: 'center' })
      doc.text(`Página ${i} de ${total}`, pageW - 14, pageH - 8, { align: 'right' })
    }

    doc.save(`reporte-finanzas-${temporadaNombre.value.replace(/\s+/g, '_')}.pdf`)
  } catch (err) {
    console.error('Error al exportar PDF de finanzas:', err)
    alert('No se pudo generar el PDF. Asegúrate de que los datos estén cargados.')
  }
}

// --- EXPORTAR EXCEL FINANZAS ---
function exportFinanzasExcel() {
  const filas = [
    { Concepto: 'REPORTE FINANCIERO — LIGA DIAMANTE' },
    { Concepto: 'Temporada: ' + temporadaNombre.value },
    { Concepto: 'Generado: ' + fechaGeneracion.value },
    {},
    { Concepto: 'RESULTADO: ' + (finanzas.value.balance >= 0 ? 'GANANCIA' : 'PÉRDIDA'), Monto: finanzas.value.balance },
    {},
    { Concepto: '--- INGRESOS POR CONCEPTO ---' },
    ...(finanzas.value.ingresos_por_concepto || []).map(c => ({
      Concepto: c.categoria, Monto: c.total,
    })),
    { Concepto: 'TOTAL INGRESOS', Monto: finanzas.value.total_ingresos },
    {},
    { Concepto: '--- EGRESOS POR PROVEEDOR ---' },
    ...(finanzas.value.egresos_por_proveedor || []).map(p => ({
      Concepto: p.proveedor, Monto: p.total,
    })),
    { Concepto: 'TOTAL EGRESOS', Monto: finanzas.value.total_egresos },
  ]
  const ws = XLSX.utils.json_to_sheet(filas)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Finanzas')
  saveAs(
    new Blob([XLSX.write(wb, { type: 'array', bookType: 'xlsx' })]),
    `reporte-finanzas-${temporadaNombre.value.replace(/\s+/g, '_')}.xlsx`
  )
}

// --- EXPORTAR EXCEL SOLO DE LA TABLA DE INGRESOS POR CONCEPTO ---
function exportIngresosExcel() {
  const datosFiltrados = ingresosFiltrados.value;
  if (!datosFiltrados.length) {
    alert('No hay datos para exportar');
    return;
  }

  // Preparar filas para el Excel (Concepto, Monto, % del total)
  const filas = datosFiltrados.map(c => ({
    Concepto: c.categoria,
    'Monto (Bs.)': c.total,
    '% del total': finanzas.value.total_ingresos 
      ? ((c.total / finanzas.value.total_ingresos) * 100).toFixed(2) + '%'
      : '0%'
  }));

  // Agregar fila de total
  filas.push({
    Concepto: 'TOTAL',
    'Monto (Bs.)': finanzas.value.total_ingresos,
    '% del total': '100%'
  });

  const ws = XLSX.utils.json_to_sheet(filas);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Ingresos_por_Concepto');
  saveAs(
    new Blob([XLSX.write(wb, { type: 'array', bookType: 'xlsx' })]),
    `ingresos-por-concepto-${temporadaNombre.value.replace(/\s+/g, '_')}.xlsx`
  );
}

// --- EXPORTAR EXCEL SOLO DEL DETALLE DE EGRESOS ---
function exportDetalleExcel() {
  if (!finanzas.value.egresos_detalle?.length) {
    alert('No hay datos para exportar');
    return;
  }

  // Preparar los datos para el Excel (las mismas columnas que la tabla)
  const datos = finanzas.value.egresos_detalle.map(eg => ({
    Fecha: formatFecha(eg.fecha_egreso),
    Concepto: eg.nota_gastos,
    Proveedor: eg.proveedor,
    Servicio: eg.servicio,
    Monto_Bs: eg.gasto,
  }));

  // Agregar fila de total
  const total = finanzas.value.egresos_detalle.reduce((sum, eg) => sum + eg.gasto, 0);
  datos.push({
    Fecha: '',
    Concepto: 'TOTAL',
    Proveedor: '',
    Servicio: '',
    Monto_Bs: total,
  });

  const ws = XLSX.utils.json_to_sheet(datos);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Detalle_Egresos');
  saveAs(
    new Blob([XLSX.write(wb, { type: 'array', bookType: 'xlsx' })]),
    `detalle-egresos-${temporadaNombre.value.replace(/\s+/g, '_')}.xlsx`
  );
}


onMounted(async () => {
  // 1. Cargamos las temporadas primero
  try {
    await cargarTemporadas()
  } catch (error) {
    console.error("Error al cargar temporadas:", error)
  }

  // 2. Solo cargar etiquetas de proveedores si tiene acceso a finanzas
  //    (evita 403 que cierra sesión del dueño)
  if (auth.puedeFinanzas) {
    try {
      await cargarEtiquetasProveedores()
    } catch (error) {
      console.error("Error al cargar etiquetas de proveedores:", error)
    }
  }
})
</script>

<style scoped>
.tab-container {
  background: rgba(0,0,0,0.05);
  border-radius: 12px;
  display: inline-flex !important;
}
.resultado-banner {
  border-radius: 12px;
}
.resultado-ganancia {
  background: linear-gradient(135deg, #d1fae5, #a7f3d0);
}
.resultado-perdida {
  background: linear-gradient(135deg, #fee2e2, #fecaca);
}
.borde-ingreso {
  border-left: 4px solid #10b981 !important;
}
.borde-egreso {
  border-left: 4px solid #ef4444 !important;
}
</style>

/* Resaltado para servicios seleccionados */
.bg-primary-soft {
  background-color: #e0f2fe !important;  /* azul muy claro */
}
.border-primary {
  border-color: #0ea5e9 !important;
}