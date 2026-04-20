<template>
  <div>
    <div v-if="!props.embedded" class="page-header d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
      <div>
        <h2 class="page-title">Reporte de Taquilla</h2>
        <p class="page-subtitle">Recaudación por partido — General y VIP</p>
      </div>
      <div class="d-flex align-items-center gap-2 flex-wrap">
        <select v-model="limite" class="form-select form-select-sm" style="max-width:130px;" @change="cargar">
          <option value="5">Últimos 5</option>
          <option value="10">Últimos 10</option>
          <option value="20">Últimos 20</option>
        </select>
        <select v-model="temporadaId" class="form-select form-select-sm" style="max-width:220px;" @change="cargar">
          <option value="">— Seleccionar temporada —</option>
          <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">
            {{ t.nombre }} ({{ t.anio }})
          </option>
        </select>
      </div>
    </div>

    <div v-if="!temporadaId" class="card">
      <div class="card-body text-center py-5 text-muted">
        <IconTicket :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
        <p class="mb-0">Selecciona una temporada para ver el reporte</p>
      </div>
    </div>

    <template v-else>
      <div v-if="cargando" class="card">
        <div class="card-body text-center py-5">
          <span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...
        </div>
      </div>

      <template v-else>
        <!-- Tarjetas resumen -->
        <div class="row g-3 mb-4">
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#6366f122; color:#6366f1;"><IconCoin :size="22" /></span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Total recaudado</div>
                    <div class="fw-bold" style="color:#6366f1; font-size:1rem;">{{ formatBs(totalRecaudado) }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#f59e0b22; color:#f59e0b;"><IconStar :size="22" /></span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Total VIP</div>
                    <div class="fw-bold" style="color:#f59e0b; font-size:1rem;">{{ formatBs(totalVip) }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#10b98122; color:#10b981;"><IconUsers :size="22" /></span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Total General</div>
                    <div class="fw-bold" style="color:#10b981; font-size:1rem;">{{ formatBs(totalGeneral) }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#f9731622; color:#f97316;"><IconTrophy :size="22" /></span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Partido más taquillero</div>
                    <div class="fw-bold" style="color:#f97316; font-size:0.78rem;">{{ partidoMax?.equipo_casa || '—' }}</div>
                    <div class="text-muted" style="font-size:0.72rem;">{{ partidoMax ? formatBs(partidoMax.recaudado_total) : '' }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Gráfico barras -->
        <div class="card shadow-sm mb-4">
          <div class="card-header d-flex align-items-center gap-2 flex-wrap">
            <IconChartBar :size="18" class="text-primary" />
            <span class="fw-bold" style="font-size:0.9rem;">Comparativo de Recaudación por Partido</span>
            <span v-if="temporadaNombre" class="text-muted" style="font-size:0.78rem;">{{ temporadaNombre }}</span>
            <div class="ms-auto d-flex align-items-center gap-2 flex-wrap">
              <div class="d-flex align-items-center gap-1" style="font-size:0.82rem; color:#64748b;">
                <span>Inicio:</span>
                <input
                  v-model="fechaDesde"
                  type="date"
                  class="form-control form-control-sm"
                  style="max-width:135px;"
                />
              </div>
              <div class="d-flex align-items-center gap-1" style="font-size:0.82rem; color:#64748b;">
                <span>Fin:</span>
                <input
                  v-model="fechaHasta"
                  type="date"
                  class="form-control form-control-sm"
                  style="max-width:135px;"
                />
              </div>
              <FiltroMultiSelect
                v-model="equiposSeleccionados"
                :opciones="equipos"
                texto-todos="Todos los equipos"
                plural-label="equipos"
              />
              <label class="d-flex align-items-center gap-1 mb-0" style="font-size:0.82rem; cursor:pointer;">
                <input type="checkbox" v-model="mostrarGrafico" class="form-check-input mt-0" />
                <span class="text-muted">Mostrar gráfico</span>
              </label>
              <div class="d-flex gap-1">
                <button class="btn btn-sm btn-outline-danger" @click="exportPDF" title="Exportar PDF">
                  <IconFileTypePdf :size="16" />
                </button>
                <button class="btn btn-sm btn-outline-success" @click="exportExcel" title="Exportar Excel">
                  <IconFileSpreadsheet :size="16" />
                </button>
              </div>
            </div>
          </div>
          <div v-if="mostrarGrafico" class="card-body" style="padding:8px 0 0 0;">
            <div v-if="!datosFiltrados.length" class="text-center py-5 text-muted">Sin partidos finalizados con datos de taquilla</div>
            <div v-else style="width:100%; overflow:hidden;">
              <svg viewBox="0 0 900 320" style="width:100%; height:320px; display:block;" xmlns="http://www.w3.org/2000/svg">
                <rect x="0" y="0" width="900" height="320" fill="transparent"/>
                <g v-for="i in 5" :key="'g'+i">
                  <line :x1="70" :y1="20 + (240/4)*(4-(i-1))" :x2="880" :y2="20 + (240/4)*(4-(i-1))" stroke="#e2e8f0" stroke-width="1"/>
                  <text :x="64" :y="20 + (240/4)*(4-(i-1)) + 4" text-anchor="end" font-size="10" fill="#94a3b8" font-family="sans-serif">{{ formatCompacto(maxBarra * (i-1) / 4) }}</text>
                </g>
                <g v-for="(d, i) in datosGrafico" :key="'b'+i">
                  <rect :x="d.x" :y="260 - d.hGeneral" :width="d.w * 0.45" :height="d.hGeneral" fill="#10b981" rx="2"/>
                  <rect :x="d.x + d.w * 0.48" :y="260 - d.hVip" :width="d.w * 0.45" :height="d.hVip" fill="#f59e0b" rx="2"/>
                  <text :x="d.x + d.w / 2" y="276" text-anchor="middle" font-size="9" fill="#64748b" font-family="sans-serif">{{ formatFechaCorta(datosFiltrados[i].fecha_juego) }}</text>
                  <text :x="d.x + d.w / 2" y="288" text-anchor="middle" font-size="8" fill="#94a3b8" font-family="sans-serif">{{ datosFiltrados[i].equipo_casa.substring(0,5) }} vs {{ datosFiltrados[i].equipo_visitante.substring(0,5) }}</text>
                  <text v-if="datosFiltrados[i].recaudado_total > 0"
                    :x="d.x + d.w / 2" :y="260 - Math.max(d.hGeneral, d.hVip) - 4"
                    text-anchor="middle" font-size="9"
                    :fill="Number(datosFiltrados[i].recaudado_total) === maxRecaudado ? '#6366f1' : '#475569'"
                    :font-weight="Number(datosFiltrados[i].recaudado_total) === maxRecaudado ? 'bold' : 'normal'"
                    font-family="sans-serif">{{ formatCompacto(datosFiltrados[i].recaudado_total) }}</text>
                </g>
                <rect x="680" y="8" width="12" height="10" fill="#10b981" rx="2"/>
                <text x="696" y="17" font-size="10" fill="#64748b" font-family="sans-serif">General</text>
                <rect x="748" y="8" width="12" height="10" fill="#f59e0b" rx="2"/>
                <text x="764" y="17" font-size="10" fill="#64748b" font-family="sans-serif">VIP</text>
              </svg>
            </div>
          </div>
        </div>

        <!-- Tabla detalle -->
        <div class="card shadow-sm">
          <div class="card-header d-flex align-items-center gap-2">
            <IconTable :size="18" class="text-primary" />
            <span class="fw-bold" style="font-size:0.9rem;">Detalle por Partido</span>
          </div>
          <div class="table-responsive">
            <table class="table table-vcenter card-table">
              <thead>
                <tr>
                  <th>Fecha</th>
                  <th>Partido</th>
                  <th class="text-center">Resultado</th>
                  <th class="text-end">General (Bs.)</th>
                  <th class="text-end">VIP (Bs.)</th>
                  <th class="text-end">Total (Bs.)</th>
                  <th class="text-center">Cap. Ocupada</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="!datosFiltrados.length">
                  <td colspan="7" class="text-center py-5 text-muted">Sin datos</td>
                </tr>
                <tr v-for="d in datosFiltrados" :key="d.id_partido">
                  <td class="text-muted" style="font-size:0.82rem;">{{ formatFecha(d.fecha_juego) }}</td>
                  <td>
                    <div class="fw-semibold" style="font-size:0.85rem;">{{ d.equipo_casa }}</div>
                    <div class="text-muted" style="font-size:0.75rem;">vs {{ d.equipo_visitante }}</div>
                  </td>
                  <td class="text-center">
                    <span class="badge bg-secondary-lt" style="font-size:0.78rem;">{{ d.carreras_casa }} — {{ d.carreras_visitante }}</span>
                  </td>
                  <td class="text-end text-success">{{ formatBs(d.recaudado_general) }}</td>
                  <td class="text-end" style="color:#f59e0b;">{{ formatBs(d.recaudado_vip) }}</td>
                  <td class="text-end fw-bold" style="color:#6366f1;">{{ formatBs(d.recaudado_total) }}</td>
                  <td class="text-center">
                    <span v-if="d.capacidad_ocupada !== null"
                      class="badge fw-bold"
                      :style="d.capacidad_ocupada >= 80 ? 'background:#10b98122;color:#10b981;' : d.capacidad_ocupada >= 50 ? 'background:#f59e0b22;color:#f59e0b;' : 'background:#6366f122;color:#6366f1;'">
                      {{ d.capacidad_ocupada }}%
                    </span>
                    <span v-else class="text-muted small">—</span>
                  </td>
                </tr>
              </tbody>
              <tfoot v-if="datosFiltrados.length">
                <tr style="border-top:2px solid #e2e8f0;">
                  <td colspan="3" class="fw-bold">TOTAL</td>
                  <td class="text-end fw-bold text-success">{{ formatBs(totalGeneral) }}</td>
                  <td class="text-end fw-bold" style="color:#f59e0b;">{{ formatBs(totalVip) }}</td>
                  <td class="text-end fw-bold" style="color:#6366f1; font-size:1rem;">{{ formatBs(totalRecaudado) }}</td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>
          <div class="card-footer text-muted text-end" style="font-size:0.72rem;">Generado el {{ fechaGeneracion }}</div>
        </div>
      </template>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, defineProps } from 'vue'
const props = defineProps({
  embedded:     { type: Boolean, default: false },
  temporadaSel: { type: [String, Number], default: '' },
})
import api from '@/services/api'
import FiltroMultiSelect from '@/components/FiltroMultiSelect.vue'
import {
  IconTicket, IconCoin, IconStar, IconUsers, IconTrophy,
  IconChartBar, IconTable, IconFileTypePdf, IconFileSpreadsheet,
} from '@tabler/icons-vue'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

const temporadas     = ref([])
const temporadaId    = ref('')
watch(() => props.temporadaSel, val => { if (props.embedded && val) { temporadaId.value = val; cargar() } }, { immediate: false })
const limite         = ref(10)
const cargando       = ref(false)
const datos          = ref([])
const mostrarGrafico = ref(true)
const fechaDesde           = ref('')
const fechaHasta           = ref('')
const equiposSeleccionados = ref([])

const fechaGeneracion = computed(() =>
  new Date().toLocaleString('es-VE', { dateStyle: 'medium', timeStyle: 'short' })
)
const temporadaNombre = computed(() => {
  const t = temporadas.value.find(t => t.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})

const equipos = computed(() => {
  const set = new Set()
  for (const d of datos.value) {
    if (d.equipo_casa)      set.add(d.equipo_casa)
    if (d.equipo_visitante) set.add(d.equipo_visitante)
  }
  return [...set].sort()
})

const datosFiltrados = computed(() =>
  datos.value.filter(d => {
    const fecha = d.fecha_juego ? String(d.fecha_juego).substring(0, 10) : ''
    const matchDesde  = !fechaDesde.value  || fecha >= fechaDesde.value
    const matchHasta  = !fechaHasta.value  || fecha <= fechaHasta.value
    const matchEquipo = !equiposSeleccionados.value.length ||
      equiposSeleccionados.value.includes(d.equipo_casa) ||
      equiposSeleccionados.value.includes(d.equipo_visitante)
    return matchDesde && matchHasta && matchEquipo
  })
)

const totalRecaudado = computed(() => datosFiltrados.value.reduce((s, d) => s + Number(d.recaudado_total), 0))
const totalVip       = computed(() => datosFiltrados.value.reduce((s, d) => s + Number(d.recaudado_vip), 0))
const totalGeneral   = computed(() => datosFiltrados.value.reduce((s, d) => s + Number(d.recaudado_general), 0))
const maxRecaudado   = computed(() => Math.max(...datosFiltrados.value.map(d => Number(d.recaudado_total)), 0))
const partidoMax     = computed(() =>
  datosFiltrados.value.length
    ? datosFiltrados.value.reduce((m, d) => Number(d.recaudado_total) > Number(m.recaudado_total) ? d : m, datosFiltrados.value[0])
    : null
)
const maxBarra = computed(() => {
  const maxV = Math.max(...datosFiltrados.value.map(d => Number(d.recaudado_vip)), 0)
  const maxG = Math.max(...datosFiltrados.value.map(d => Number(d.recaudado_general)), 0)
  return Math.max(maxV, maxG) * 1.15 || 1
})
const datosGrafico = computed(() => {
  const n = datosFiltrados.value.length || 1
  const bw = 810 / n
  return datosFiltrados.value.map((d, i) => ({
    x:        70 + i * bw,
    w:        bw - 4,
    hGeneral: Math.max((Number(d.recaudado_general) / maxBarra.value) * 240, 2),
    hVip:     Math.max((Number(d.recaudado_vip)     / maxBarra.value) * 240, 2),
  }))
})

function formatBs(v) {
  return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(v || 0) + ' Bs.'
}
function formatCompacto(v) {
  return new Intl.NumberFormat('es-VE', { notation: 'compact', maximumFractionDigits: 1 }).format(v || 0)
}
function formatFecha(f) {
  return f ? new Date(f).toLocaleDateString('es-VE', { day: '2-digit', month: 'short', year: 'numeric' }) : '—'
}
function formatFechaCorta(f) {
  return f ? new Date(f).toLocaleDateString('es-VE', { day: '2-digit', month: 'short' }) : '—'
}

async function cargar() {
  if (!temporadaId.value) return
  cargando.value = true
  try {
    const { data } = await api.get('/reportes/taquilla', {
      params: { temporada: temporadaId.value, limite: limite.value },
    })
    datos.value = data
  } finally { cargando.value = false }
}

async function cargarTemporadas() {
  const { data } = await api.get('/temporadas')
  temporadas.value = data
  if (props.embedded && props.temporadaSel) {
    temporadaId.value = props.temporadaSel; cargar()
  } else {
    const activa = data.find(t => t.activa)
    if (activa) { temporadaId.value = activa.id_temporada; cargar() }
  }
}

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

function generarGraficoCanvas() {
  if (!datosFiltrados.value.length) return null
  const maxG = Math.max(...datosFiltrados.value.map(d => Number(d.recaudado_general)), 0)
  const maxV = Math.max(...datosFiltrados.value.map(d => Number(d.recaudado_vip)), 0)
  const maxB = Math.max(maxG, maxV) * 1.15 || 1
  const maxR = Math.max(...datosFiltrados.value.map(d => Number(d.recaudado_total)), 0)

  const W = 1400, H = 320
  const oc = document.createElement('canvas')
  oc.width = W; oc.height = H
  const ctx = oc.getContext('2d')

  ctx.fillStyle = '#ffffff'
  ctx.fillRect(0, 0, W, H)

  // Líneas guía
  for (let i = 0; i < 5; i++) {
    const y = 20 + (240 / 4) * (4 - i)
    ctx.strokeStyle = '#e2e8f0'; ctx.lineWidth = 1
    ctx.beginPath(); ctx.moveTo(70, y); ctx.lineTo(W - 20, y); ctx.stroke()
    ctx.fillStyle = '#94a3b8'; ctx.font = '11px sans-serif'
    ctx.textAlign = 'right'; ctx.textBaseline = 'middle'
    ctx.fillText(formatCompacto(maxB * i / 4), 64, y)
  }

  // Barras
  const n  = datosFiltrados.value.length || 1
  const bw = (W - 90) / n
  datosFiltrados.value.forEach((d, i) => {
    const x        = 70 + i * bw
    const w        = bw - 6
    const hGeneral = Math.max((Number(d.recaudado_general) / maxB) * 240, 2)
    const hVip     = Math.max((Number(d.recaudado_vip)     / maxB) * 240, 2)

    ctx.fillStyle = '#10b981'
    ctx.fillRect(x, 260 - hGeneral, w * 0.45, hGeneral)
    ctx.fillStyle = '#f59e0b'
    ctx.fillRect(x + w * 0.48, 260 - hVip, w * 0.45, hVip)

    // Fecha
    ctx.fillStyle = '#64748b'; ctx.font = '10px sans-serif'
    ctx.textAlign = 'center'; ctx.textBaseline = 'top'
    ctx.fillText(formatFechaCorta(d.fecha_juego), x + w / 2, 264)
    // Equipos
    ctx.fillStyle = '#94a3b8'; ctx.font = '9px sans-serif'
    ctx.fillText(`${(d.equipo_casa || '').substring(0,5)} vs ${(d.equipo_visitante || '').substring(0,5)}`, x + w / 2, 277)

    // Total encima
    if (Number(d.recaudado_total) > 0) {
      const esMax = Number(d.recaudado_total) === maxR
      ctx.fillStyle  = esMax ? '#6366f1' : '#475569'
      ctx.font       = esMax ? 'bold 10px sans-serif' : '10px sans-serif'
      ctx.textBaseline = 'bottom'
      ctx.fillText(formatCompacto(d.recaudado_total), x + w / 2, 260 - Math.max(hGeneral, hVip) - 3)
    }
  })

  // Leyenda
  ctx.fillStyle = '#10b981'; ctx.fillRect(W - 220, 8, 14, 11)
  ctx.fillStyle = '#64748b'; ctx.font = '11px sans-serif'
  ctx.textAlign = 'left'; ctx.textBaseline = 'top'
  ctx.fillText('General', W - 202, 9)
  ctx.fillStyle = '#f59e0b'; ctx.fillRect(W - 120, 8, 14, 11)
  ctx.fillStyle = '#64748b'; ctx.fillText('VIP', W - 102, 9)

  return oc
}

async function exportPDF() {
  try {
  const doc   = new jsPDF({ orientation: 'landscape' })
  const pageW = doc.internal.pageSize.getWidth()
  const pageH = doc.internal.pageSize.getHeight()
  const logo  = await cargarLogoBase64('/logos/logorepor.png')

  doc.setFillColor(30,41,59); doc.rect(0,0,pageW,40,'F')
  doc.setFillColor(99,102,241); doc.rect(0,40,pageW,2,'F')
  if (logo) { doc.addImage(logo,'PNG',8,6,32,28) }
  else {
    doc.setDrawColor(255,255,255); doc.setLineWidth(0.5); doc.roundedRect(8,6,32,28,3,3,'S')
    doc.setTextColor(255,255,255); doc.setFontSize(6.5); doc.setFont('helvetica','normal')
    doc.text('LOGO',24,17,{align:'center'}); doc.text('LIGA',24,23,{align:'center'})
  }
  doc.setTextColor(255,255,255); doc.setFontSize(17); doc.setFont('helvetica','bold')
  doc.text('Liga Diamante',46,16)
  doc.setFontSize(9.5); doc.setFont('helvetica','normal'); doc.setTextColor(148,163,184)
  doc.text('Reporte de Taquilla — Recaudación por Partido',46,24)
  doc.setFontSize(9); doc.setFont('helvetica','bold'); doc.setTextColor(255,255,255)
  doc.text(temporadaNombre.value,pageW-14,16,{align:'right'})
  doc.setFontSize(7.5); doc.setFont('helvetica','normal'); doc.setTextColor(148,163,184)
  doc.text('Generado: '+fechaGeneracion.value,pageW-14,24,{align:'right'})
  doc.setTextColor(0,0,0)

  let cy = 52
  doc.setFillColor(240,253,244); doc.roundedRect(14,cy-5,pageW-28,14,2,2,'F')
  doc.setFontSize(9); doc.setFont('helvetica','normal'); doc.setTextColor(71,85,105)
  doc.text('Total Recaudado:',18,cy+3)
  doc.setFont('helvetica','bold'); doc.setTextColor(22,163,74); doc.setFontSize(11)
  doc.text(formatBs(totalRecaudado.value),pageW-18,cy+3,{align:'right'})
  cy += 18

  // Gráfico recaudación por partido
  if (mostrarGrafico.value && datosFiltrados.value.length) {
    const oc = generarGraficoCanvas()
    if (oc) {
      const imgData = oc.toDataURL('image/png')
      const imgW    = pageW - 28
      const imgH    = imgW * (oc.height / oc.width)
      doc.setFontSize(9); doc.setFont('helvetica','bold'); doc.setTextColor(30,41,59)
      doc.text('Recaudación por Partido — General vs VIP', pageW / 2, cy, { align: 'center' })
      cy += 4
      doc.addImage(imgData, 'PNG', 14, cy, imgW, imgH)
      cy += imgH + 8
    }
  }

  doc.setFontSize(10); doc.setFont('helvetica','bold'); doc.setTextColor(30,41,59)
  doc.text('Detalle por Partido',14,cy); cy += 5

  autoTable(doc, {
    startY: cy,
    head: [['Fecha','Partido','Resultado','General (Bs.)','VIP (Bs.)','Total (Bs.)','Cap. Ocupada']],
    body: [
      ...datosFiltrados.value.map(d => [
        formatFecha(d.fecha_juego),
        `${d.equipo_casa} vs ${d.equipo_visitante}`,
        `${d.carreras_casa} — ${d.carreras_visitante}`,
        formatBs(d.recaudado_general),
        formatBs(d.recaudado_vip),
        formatBs(d.recaudado_total),
        d.capacidad_ocupada !== null ? `${d.capacidad_ocupada}%` : '—',
      ]),
      ['TOTAL','','',formatBs(totalGeneral.value),formatBs(totalVip.value),formatBs(totalRecaudado.value),''],
    ],
    theme: 'grid',
    headStyles: { fillColor:[30,41,59], textColor:255, fontStyle:'bold', halign:'center', fontSize:9 },
    columnStyles: {
      0:{cellWidth:26}, 1:{fontStyle:'bold',cellWidth:55},
      2:{halign:'center',cellWidth:22}, 3:{halign:'right'}, 4:{halign:'right'},
      5:{halign:'right',fontStyle:'bold'}, 6:{halign:'center',cellWidth:22},
    },
    styles: { fontSize:9, cellPadding:3 },
    alternateRowStyles: { fillColor:[245,247,250] },
    didParseCell(h) {
      if (h.row.index === datosFiltrados.value.length) { h.cell.styles.fontStyle='bold'; h.cell.styles.fillColor=[226,232,240] }
    },
  })

  const total = doc.internal.getNumberOfPages()
  for (let i = 1; i <= total; i++) {
    doc.setPage(i)
    doc.setDrawColor(226,232,240); doc.setLineWidth(0.4)
    doc.line(14,pageH-14,pageW-14,pageH-14)
    doc.setFontSize(7.5); doc.setFont('helvetica','normal'); doc.setTextColor(148,163,184)
    doc.text('Liga Diamante  ·  Sistema de Gestión',14,pageH-8)
    doc.text(temporadaNombre.value,pageW/2,pageH-8,{align:'center'})
    doc.text(`Página ${i} de ${total}`,pageW-14,pageH-8,{align:'right'})
  }
  doc.save(`reporte-taquilla-${temporadaNombre.value.replace(/\s+/g,'_')}.pdf`)
  } catch (err) {
    console.error('Error al exportar PDF de taquilla:', err)
    alert('No se pudo generar el PDF. Asegúrate de que los datos estén cargados.')
  }
}

function exportExcel() {
  const filas = [
    { Fecha:'REPORTE DE TAQUILLA' },
    { Fecha:'Temporada: '+temporadaNombre.value },
    {},
    ...datosFiltrados.value.map(d => ({
      Fecha: formatFecha(d.fecha_juego),
      Partido: `${d.equipo_casa} vs ${d.equipo_visitante}`,
      Resultado: `${d.carreras_casa}-${d.carreras_visitante}`,
      'General (Bs.)': Number(d.recaudado_general),
      'VIP (Bs.)': Number(d.recaudado_vip),
      'Total (Bs.)': Number(d.recaudado_total),
    })),
    { Fecha:'TOTAL', 'General (Bs.)':totalGeneral.value, 'VIP (Bs.)':totalVip.value, 'Total (Bs.)':totalRecaudado.value },
  ]
  const ws = XLSX.utils.json_to_sheet(filas)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Taquilla')
  saveAs(new Blob([XLSX.write(wb,{type:'array',bookType:'xlsx'})]), 'reporte-taquilla.xlsx')
}

onMounted(cargarTemporadas)
</script>
