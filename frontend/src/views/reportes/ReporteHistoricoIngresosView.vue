<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
      <div>
        <h2 class="page-title">Reporte Histórico de Ingresos</h2>
        <p class="page-subtitle">Evolución de ingresos a lo largo de la temporada</p>
      </div>
      <div class="d-flex align-items-center gap-2 flex-wrap">
        <select v-model="agrupacion" class="form-select form-select-sm" style="max-width:140px;" @change="cargar">
          <option value="mes">Por mes</option>
          <option value="semana">Por semana</option>
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
        <IconChartLine :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
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
                  <span class="avatar" style="background:#6366f122; color:#6366f1;">
                    <IconCoin :size="22" />
                  </span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Total temporada</div>
                    <div class="fw-bold" style="color:#6366f1; font-size:1rem;">{{ formatBs(totalGeneral) }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#10b98122; color:#10b981;">
                    <IconTrendingUp :size="22" />
                  </span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Período más alto</div>
                    <div class="fw-bold" style="color:#10b981; font-size:0.9rem;">{{ periodoMax?.periodo || '—' }}</div>
                    <div class="text-muted" style="font-size:0.72rem;">{{ periodoMax ? formatBs(periodoMax.total) : '' }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#f59e0b22; color:#f59e0b;">
                    <IconChartLine :size="22" />
                  </span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Promedio por período</div>
                    <div class="fw-bold" style="color:#f59e0b; font-size:1rem;">{{ formatBs(promedio) }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#f9731622; color:#f97316;">
                    <IconCalendar :size="22" />
                  </span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Períodos registrados</div>
                    <div class="fw-bold" style="color:#f97316; font-size:1rem;">{{ datos.length }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Gráfico principal -->
        <div class="card shadow-sm mb-4">
          <div class="card-header d-flex align-items-center gap-2 flex-wrap">
            <IconChartLine :size="18" class="text-primary" />
            <span class="fw-bold" style="font-size:0.9rem;">Tendencia de Ingresos</span>
            <span v-if="temporadaNombre" class="text-muted" style="font-size:0.78rem;">{{ temporadaNombre }}</span>
            <div class="ms-auto d-flex gap-1">
              <button class="btn btn-sm btn-outline-danger" @click="exportPDF" title="Exportar PDF">
                <IconFileTypePdf :size="16" />
              </button>
              <button class="btn btn-sm btn-outline-success" @click="exportExcel" title="Exportar Excel">
                <IconFileSpreadsheet :size="16" />
              </button>
            </div>
          </div>
          <div class="card-body" style="padding: 8px 0 0 0;">
            <div v-if="!datos.length" class="text-center py-5 text-muted">
              Sin ingresos registrados para esta temporada
            </div>
            <div v-else style="width:100%; overflow:hidden;">
              <svg :viewBox="`0 0 900 320`" style="width:100%; height:320px; display:block;" xmlns="http://www.w3.org/2000/svg">
                <!-- Fondo -->
                <rect x="0" y="0" width="900" height="320" fill="transparent"/>
                <!-- Líneas guía horizontales -->
                <g v-for="i in 6" :key="'g'+i">
                  <line
                    :x1="72" :y1="24 + (248/5)*(5-(i-1))"
                    :x2="876" :y2="24 + (248/5)*(5-(i-1))"
                    stroke="#e2e8f0" stroke-width="1"
                  />
                  <text
                    :x="66" :y="24 + (248/5)*(5-(i-1)) + 4"
                    text-anchor="end" font-size="11" fill="#94a3b8" font-family="sans-serif"
                  >{{ formatCompacto(maxValor * (i-1) / 5) }}</text>
                </g>
                <!-- Área bajo la curva -->
                <defs>
                  <linearGradient id="areaGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stop-color="#6366f1" stop-opacity="0.22"/>
                    <stop offset="100%" stop-color="#6366f1" stop-opacity="0.02"/>
                  </linearGradient>
                </defs>
                <polygon v-if="puntosGrafico.length > 1"
                  :points="areaPoligono"
                  fill="url(#areaGrad)"
                />
                <!-- Línea principal -->
                <polyline v-if="puntosGrafico.length > 1"
                  :points="puntosGrafico.map(p => p.x+','+p.y).join(' ')"
                  fill="none" stroke="#6366f1" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"
                />
                <!-- Puntos, valores y etiquetas X -->
                <g v-for="(p, i) in puntosGrafico" :key="'p'+i">
                  <!-- Valor encima del punto -->
                  <text
                    :x="p.x" :y="p.y - 12"
                    text-anchor="middle"
                    :font-size="p.isMax ? 12 : 10"
                    :font-weight="p.isMax ? 'bold' : 'normal'"
                    :fill="p.isMax ? '#10b981' : '#475569'"
                    font-family="sans-serif"
                  >{{ formatCompacto(p.valor) }}</text>
                  <!-- Círculo -->
                  <circle
                    :cx="p.x" :cy="p.y"
                    :r="p.isMax ? 7 : 5"
                    :fill="p.isMax ? '#10b981' : '#6366f1'"
                    stroke="white" stroke-width="2"
                  />
                  <!-- Etiqueta eje X -->
                  <text
                    :x="p.x" :y="288"
                    text-anchor="middle" font-size="11" fill="#64748b" font-family="sans-serif"
                  >{{ datos[i].periodo }}</text>
                </g>
              </svg>
            </div>
          </div>
        </div>

        <!-- Tabla detalle -->
        <div class="card shadow-sm">
          <div class="card-header d-flex align-items-center gap-2">
            <IconTable :size="18" class="text-primary" />
            <span class="fw-bold" style="font-size:0.9rem;">Detalle por Período</span>
          </div>
          <div class="table-responsive">
            <table class="table table-vcenter card-table">
              <thead>
                <tr>
                  <th>Período</th>
                  <th class="text-center">Registros</th>
                  <th class="text-end">Monto (Bs.)</th>
                  <th class="text-center">% del Total</th>
                  <th class="text-center">Tendencia</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="!datos.length">
                  <td colspan="5" class="text-center py-5 text-muted">Sin datos</td>
                </tr>
                <tr v-for="(row, i) in datos" :key="row.periodo_key">
                  <td class="fw-semibold" style="font-size:0.875rem;">{{ row.periodo }}</td>
                  <td class="text-center text-muted">{{ row.cantidad }}</td>
                  <td class="text-end fw-bold" style="color:#6366f1;">{{ formatBs(row.total) }}</td>
                  <td class="text-center">
                    <span class="badge fw-bold" style="font-size:0.82rem; background:#6366f122; color:#6366f1;">
                      {{ porcentajePeriodo(row.total) }}%
                    </span>
                  </td>
                  <td class="text-center">
                    <span v-if="i === 0" class="text-muted" style="font-size:0.78rem;">—</span>
                    <span v-else-if="row.total > datos[i-1].total" style="color:#10b981; font-size:0.82rem;">▲ {{ diferenciaStr(row.total, datos[i-1].total) }}</span>
                    <span v-else-if="row.total < datos[i-1].total" style="color:#ef4444; font-size:0.82rem;">▼ {{ diferenciaStr(datos[i-1].total, row.total) }}</span>
                    <span v-else class="text-muted" style="font-size:0.82rem;">= igual</span>
                  </td>
                </tr>
              </tbody>
              <tfoot v-if="datos.length">
                <tr style="border-top:2px solid #e2e8f0;">
                  <td class="fw-bold">TOTAL GENERAL</td>
                  <td class="text-center fw-bold">{{ datos.reduce((s, r) => s + r.cantidad, 0) }}</td>
                  <td class="text-end fw-bold text-success" style="font-size:1rem;">{{ formatBs(totalGeneral) }}</td>
                  <td class="text-center fw-bold">100%</td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>
          <div class="card-footer text-muted text-end" style="font-size:0.72rem;">
            Generado el {{ fechaGeneracion }}
          </div>
        </div>
      </template>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import api from '@/services/api'
import {
  IconChartLine, IconFileTypePdf, IconFileSpreadsheet,
  IconCoin, IconTrendingUp, IconCalendar, IconTable,
} from '@tabler/icons-vue'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

// ── Estado ───────────────────────────────────────────────
const temporadas   = ref([])
const temporadaId  = ref('')
const agrupacion   = ref('mes')
const cargando     = ref(false)
const datos        = ref([])

const fechaGeneracion = computed(() =>
  new Date().toLocaleString('es-VE', { dateStyle: 'medium', timeStyle: 'short' })
)

const temporadaNombre = computed(() => {
  const t = temporadas.value.find(t => t.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})

const totalGeneral = computed(() =>
  datos.value.reduce((s, r) => s + Number(r.total), 0)
)

const promedio = computed(() =>
  datos.value.length ? totalGeneral.value / datos.value.length : 0
)

const periodoMax = computed(() =>
  datos.value.length
    ? datos.value.reduce((max, r) => Number(r.total) > Number(max.total) ? r : max, datos.value[0])
    : null
)

// ── Computed para el gráfico SVG ─────────────────────────
const PL = 72, PR = 24, PT = 28, PB = 52
const GW = 900 - PL - PR   // 804
const GH = 320 - PT - PB   // 240

const maxValor = computed(() => {
  if (!datos.value.length) return 1
  return Math.max(...datos.value.map(r => Number(r.total))) * 1.12 || 1
})

const puntosGrafico = computed(() => {
  const vals = datos.value.map(r => Number(r.total))
  const maxV = maxValor.value
  const n    = vals.length
  const maxVal2 = Math.max(...vals)
  return vals.map((v, i) => ({
    x:     PL + (n === 1 ? GW / 2 : (i / (n - 1)) * GW),
    y:     PT + GH - (v / maxV) * GH,
    valor: v,
    isMax: v === maxVal2,
  }))
})

const areaPoligono = computed(() => {
  if (!puntosGrafico.value.length) return ''
  const pts  = puntosGrafico.value
  const base = PT + GH
  const left = pts[0].x
  const right = pts[pts.length - 1].x
  const top   = pts.map(p => `${p.x},${p.y}`).join(' ')
  return `${left},${base} ${top} ${right},${base}`
})

function formatCompacto(v) {
  return new Intl.NumberFormat('es-VE', { notation: 'compact', maximumFractionDigits: 1 }).format(v || 0)
}

// ── Helpers ──────────────────────────────────────────────
function formatBs(v) {
  return new Intl.NumberFormat('es-VE', {
    minimumFractionDigits: 2, maximumFractionDigits: 2,
  }).format(v || 0) + ' Bs.'
}

function porcentajePeriodo(total) {
  if (!totalGeneral.value) return '0.00'
  return ((Number(total) / totalGeneral.value) * 100).toFixed(2)
}

function diferenciaStr(mayor, menor) {
  const diff = Number(mayor) - Number(menor)
  return new Intl.NumberFormat('es-VE', { maximumFractionDigits: 0 }).format(diff) + ' Bs.'
}

// ── Carga de datos ────────────────────────────────────────
async function cargar() {
  if (!temporadaId.value) return
  cargando.value = true
  try {
    const { data } = await api.get('/reportes/historico-ingresos', {
      params: { temporada: temporadaId.value, agrupacion: agrupacion.value },
    })
    datos.value = data
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





// ── Logo helper ───────────────────────────────────────────
async function cargarLogoBase64(url) {
  return new Promise((resolve) => {
    const img = new Image()
    img.crossOrigin = 'anonymous'
    img.onload = () => {
      const c = document.createElement('canvas')
      c.width  = img.naturalWidth
      c.height = img.naturalHeight
      c.getContext('2d').drawImage(img, 0, 0)
      resolve(c.toDataURL('image/png'))
    }
    img.onerror = () => resolve(null)
    img.src = url
  })
}

// ── Exportar PDF ──────────────────────────────────────────
async function exportPDF() {
  const doc   = new jsPDF({ orientation: 'portrait' })
  const pageW = doc.internal.pageSize.getWidth()
  const pageH = doc.internal.pageSize.getHeight()

  // Cargar logo
  const logoBase64 = await cargarLogoBase64('/logos/logorepor.png')

  // ── Franja superior azul oscuro ──────────────────────
  doc.setFillColor(30, 41, 59)
  doc.rect(0, 0, pageW, 40, 'F')

  // ── Línea de acento indigo ────────────────────────────
  doc.setFillColor(99, 102, 241)
  doc.rect(0, 40, pageW, 2, 'F')

  // ── Logo ──────────────────────────────────────────────
  if (logoBase64) {
    doc.addImage(logoBase64, 'PNG', 8, 6, 26, 26)
  } else {
    doc.setDrawColor(255, 255, 255)
    doc.setLineWidth(0.5)
    doc.roundedRect(8, 6, 26, 26, 3, 3, 'S')
    doc.setTextColor(255, 255, 255)
    doc.setFontSize(6.5)
    doc.setFont('helvetica', 'normal')
    doc.text('LOGO', 21, 17, { align: 'center' })
    doc.text('LIGA', 21, 23, { align: 'center' })
  }

  // ── Nombre del sistema ────────────────────────────────
  doc.setTextColor(255, 255, 255)
  doc.setFontSize(17)
  doc.setFont('helvetica', 'bold')
  doc.text('Liga Diamante', 40, 16)

  // ── Nombre del reporte ────────────────────────────────
  doc.setFontSize(9.5)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(148, 163, 184)
  doc.text('Reporte Histórico de Ingresos — Tendencia por ' + (agrupacion.value === 'mes' ? 'Mes' : 'Semana'), 40, 24)

  // ── Temporada (derecha) ───────────────────────────────
  doc.setFontSize(9)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(255, 255, 255)
  doc.text(temporadaNombre.value, pageW - 14, 16, { align: 'right' })

  // ── Fecha generación (derecha) ────────────────────────
  doc.setFontSize(7.5)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(148, 163, 184)
  doc.text('Generado: ' + fechaGeneracion.value, pageW - 14, 24, { align: 'right' })

  doc.setTextColor(0, 0, 0)

  // ── Resumen destacado ─────────────────────────────────
  let cursorY = 52
  doc.setFillColor(240, 253, 244)
  doc.roundedRect(14, cursorY - 5, pageW - 28, 14, 2, 2, 'F')
  doc.setFontSize(9)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(71, 85, 105)
  doc.text('Total General de Ingresos:', 18, cursorY + 3)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(22, 163, 74)
  doc.setFontSize(11)
  doc.text(formatBs(totalGeneral.value), pageW - 18, cursorY + 3, { align: 'right' })
  cursorY += 18

  // ── Gráfico lineal — canvas offscreen de tamaño fijo ─
  if (datos.value.length) {
    const OW = 900
    const OH = 280
    const oc  = document.createElement('canvas')
    oc.width  = OW
    oc.height = OH
    const octx = oc.getContext('2d')

    const pl = 80, pr = 24, pt = 30, pb = 50
    const gW = OW - pl - pr
    const gH = OH - pt - pb
    const values = datos.value.map(r => Number(r.total))
    const maxVal = Math.max(...values) * 1.1 || 1

    octx.clearRect(0, 0, OW, OH)
    octx.fillStyle = '#ffffff'
    octx.fillRect(0, 0, OW, OH)

    // Líneas guía
    octx.strokeStyle = '#e2e8f0'
    octx.lineWidth = 1
    for (let i = 0; i <= 5; i++) {
      const y = pt + gH - (i / 5) * gH
      octx.beginPath(); octx.moveTo(pl, y); octx.lineTo(pl + gW, y); octx.stroke()
      octx.fillStyle = '#94a3b8'; octx.font = '13px sans-serif'; octx.textAlign = 'right'
      octx.fillText(
        new Intl.NumberFormat('es-VE', { notation: 'compact', maximumFractionDigits: 1 }).format((maxVal * i) / 5),
        pl - 8, y + 5
      )
    }

    const pts = values.map((v, i) => ({
      x: pl + (i / (values.length - 1 || 1)) * gW,
      y: pt + gH - (v / maxVal) * gH,
    }))

    // Área degradada
    const grad = octx.createLinearGradient(0, pt, 0, pt + gH)
    grad.addColorStop(0, 'rgba(99,102,241,0.22)')
    grad.addColorStop(1, 'rgba(99,102,241,0.02)')
    octx.beginPath(); octx.moveTo(pts[0].x, pt + gH)
    pts.forEach(p => octx.lineTo(p.x, p.y))
    octx.lineTo(pts[pts.length - 1].x, pt + gH)
    octx.closePath(); octx.fillStyle = grad; octx.fill()

    // Línea
    octx.beginPath(); octx.strokeStyle = '#6366f1'; octx.lineWidth = 3; octx.lineJoin = 'round'
    pts.forEach((p, i) => i === 0 ? octx.moveTo(p.x, p.y) : octx.lineTo(p.x, p.y))
    octx.stroke()

    // Puntos y valores
    pts.forEach((p, i) => {
      const isMax = values[i] === Math.max(...values)
      octx.beginPath(); octx.arc(p.x, p.y, isMax ? 8 : 5, 0, 2 * Math.PI)
      octx.fillStyle = isMax ? '#10b981' : '#6366f1'; octx.fill()
      octx.strokeStyle = '#fff'; octx.lineWidth = 2; octx.stroke()
      octx.fillStyle = isMax ? '#10b981' : '#475569'
      octx.font = isMax ? 'bold 13px sans-serif' : '12px sans-serif'
      octx.textAlign = 'center'
      octx.fillText(
        new Intl.NumberFormat('es-VE', { notation: 'compact', maximumFractionDigits: 1 }).format(values[i]),
        p.x, p.y - 14
      )
    })

    // Etiquetas eje X
    octx.fillStyle = '#64748b'; octx.font = '13px sans-serif'; octx.textAlign = 'center'
    pts.forEach((p, i) => octx.fillText(datos.value[i].periodo, p.x, pt + gH + 22))

    const imgData = oc.toDataURL('image/png')
    const imgW    = pageW - 28
    const imgH    = 70
    doc.setFontSize(10)
    doc.setFont('helvetica', 'bold')
    doc.setTextColor(30, 41, 59)
    doc.text('Tendencia de Ingresos', 14, cursorY)
    cursorY += 4
    doc.addImage(imgData, 'PNG', 14, cursorY, imgW, imgH)
    cursorY += imgH + 8
  }

  // ── Tabla de datos ────────────────────────────────────
  doc.setFontSize(10)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(30, 41, 59)
  doc.text('Detalle por Período', 14, cursorY)
  cursorY += 5

  autoTable(doc, {
    startY: cursorY,
    head: [['Período', 'N° Registros', 'Monto (Bs.)', '% del Total']],
    body: [
      ...datos.value.map(r => [
        r.periodo,
        r.cantidad,
        formatBs(r.total),
        porcentajePeriodo(r.total) + '%',
      ]),
      [
        'TOTAL GENERAL',
        datos.value.reduce((s, r) => s + r.cantidad, 0),
        formatBs(totalGeneral.value),
        '100%',
      ],
    ],
    theme: 'grid',
    headStyles: { fillColor: [30, 41, 59], textColor: 255, fontStyle: 'bold', halign: 'center', fontSize: 9 },
    columnStyles: {
      0: { fontStyle: 'bold', cellWidth: 55 },
      1: { halign: 'center' },
      2: { halign: 'right' },
      3: { halign: 'center' },
    },
    styles: { fontSize: 9, cellPadding: 3.5 },
    alternateRowStyles: { fillColor: [245, 247, 250] },
    didParseCell(hookData) {
      if (hookData.row.index === datos.value.length) {
        hookData.cell.styles.fontStyle = 'bold'
        hookData.cell.styles.fillColor = [226, 232, 240]
      }
    },
  })

  // ── Pie de página ─────────────────────────────────────
  const totalPages = doc.internal.getNumberOfPages()
  for (let i = 1; i <= totalPages; i++) {
    doc.setPage(i)
    doc.setDrawColor(226, 232, 240)
    doc.setLineWidth(0.4)
    doc.line(14, pageH - 14, pageW - 14, pageH - 14)
    doc.setFontSize(7.5)
    doc.setFont('helvetica', 'normal')
    doc.setTextColor(148, 163, 184)
    doc.text('Liga Diamante  ·  Sistema de Gestión', 14, pageH - 8)
    doc.text(temporadaNombre.value, pageW / 2, pageH - 8, { align: 'center' })
    doc.text(`Página ${i} de ${totalPages}`, pageW - 14, pageH - 8, { align: 'right' })
  }

  doc.save(`reporte-historico-ingresos-${temporadaNombre.value.replace(/\s+/g, '_')}.pdf`)
}

// ── Exportar Excel ────────────────────────────────────────
function exportExcel() {
  const filas = [
    { 'Período': 'REPORTE HISTÓRICO DE INGRESOS' },
    { 'Período': 'Temporada: ' + temporadaNombre.value },
    { 'Período': 'Agrupación: ' + (agrupacion.value === 'mes' ? 'Por Mes' : 'Por Semana') },
    {},
    ...datos.value.map(r => ({
      'Período':      r.periodo,
      'Registros':    r.cantidad,
      'Monto (Bs.)':  Number(r.total),
      '% del Total':  porcentajePeriodo(r.total) + '%',
    })),
    {
      'Período':     'TOTAL GENERAL',
      'Registros':   datos.value.reduce((s, r) => s + r.cantidad, 0),
      'Monto (Bs.)': totalGeneral.value,
      '% del Total': '100%',
    },
  ]

  const ws = XLSX.utils.json_to_sheet(filas)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Histórico')
  const buf = XLSX.write(wb, { type: 'array', bookType: 'xlsx' })
  saveAs(new Blob([buf]), `reporte-historico-ingresos.xlsx`)
}

onMounted(cargarTemporadas)
</script>