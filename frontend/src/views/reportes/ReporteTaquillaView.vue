<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
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
            <div class="ms-auto d-flex gap-1">
              <button class="btn btn-sm btn-outline-danger" @click="exportPDF" title="Exportar PDF">
                <IconFileTypePdf :size="16" />
              </button>
              <button class="btn btn-sm btn-outline-success" @click="exportExcel" title="Exportar Excel">
                <IconFileSpreadsheet :size="16" />
              </button>
            </div>
          </div>
          <div class="card-body" style="padding:8px 0 0 0;">
            <div v-if="!datos.length" class="text-center py-5 text-muted">Sin partidos finalizados con datos de taquilla</div>
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
                  <text :x="d.x + d.w / 2" y="276" text-anchor="middle" font-size="9" fill="#64748b" font-family="sans-serif">{{ formatFechaCorta(datos[i].fecha_juego) }}</text>
                  <text :x="d.x + d.w / 2" y="288" text-anchor="middle" font-size="8" fill="#94a3b8" font-family="sans-serif">{{ datos[i].equipo_casa.substring(0,5) }} vs {{ datos[i].equipo_visitante.substring(0,5) }}</text>
                  <text v-if="datos[i].recaudado_total > 0"
                    :x="d.x + d.w / 2" :y="260 - Math.max(d.hGeneral, d.hVip) - 4"
                    text-anchor="middle" font-size="9"
                    :fill="Number(datos[i].recaudado_total) === maxRecaudado ? '#6366f1' : '#475569'"
                    :font-weight="Number(datos[i].recaudado_total) === maxRecaudado ? 'bold' : 'normal'"
                    font-family="sans-serif">{{ formatCompacto(datos[i].recaudado_total) }}</text>
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
                </tr>
              </thead>
              <tbody>
                <tr v-if="!datos.length">
                  <td colspan="6" class="text-center py-5 text-muted">Sin datos</td>
                </tr>
                <tr v-for="d in datos" :key="d.id_partido">
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
                </tr>
              </tbody>
              <tfoot v-if="datos.length">
                <tr style="border-top:2px solid #e2e8f0;">
                  <td colspan="3" class="fw-bold">TOTAL</td>
                  <td class="text-end fw-bold text-success">{{ formatBs(totalGeneral) }}</td>
                  <td class="text-end fw-bold" style="color:#f59e0b;">{{ formatBs(totalVip) }}</td>
                  <td class="text-end fw-bold" style="color:#6366f1; font-size:1rem;">{{ formatBs(totalRecaudado) }}</td>
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
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import {
  IconTicket, IconCoin, IconStar, IconUsers, IconTrophy,
  IconChartBar, IconTable, IconFileTypePdf, IconFileSpreadsheet,
} from '@tabler/icons-vue'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

const temporadas  = ref([])
const temporadaId = ref('')
const limite      = ref(10)
const cargando    = ref(false)
const datos       = ref([])

const fechaGeneracion = computed(() =>
  new Date().toLocaleString('es-VE', { dateStyle: 'medium', timeStyle: 'short' })
)
const temporadaNombre = computed(() => {
  const t = temporadas.value.find(t => t.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})
const totalRecaudado = computed(() => datos.value.reduce((s, d) => s + Number(d.recaudado_total), 0))
const totalVip       = computed(() => datos.value.reduce((s, d) => s + Number(d.recaudado_vip), 0))
const totalGeneral   = computed(() => datos.value.reduce((s, d) => s + Number(d.recaudado_general), 0))
const maxRecaudado   = computed(() => Math.max(...datos.value.map(d => Number(d.recaudado_total)), 0))
const partidoMax     = computed(() =>
  datos.value.length
    ? datos.value.reduce((m, d) => Number(d.recaudado_total) > Number(m.recaudado_total) ? d : m, datos.value[0])
    : null
)
const maxBarra = computed(() => {
  const maxV = Math.max(...datos.value.map(d => Number(d.recaudado_vip)), 0)
  const maxG = Math.max(...datos.value.map(d => Number(d.recaudado_general)), 0)
  return Math.max(maxV, maxG) * 1.15 || 1
})
const datosGrafico = computed(() => {
  const n = datos.value.length || 1
  const bw = 810 / n
  return datos.value.map((d, i) => ({
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
  const activa = data.find(t => t.activa)
  if (activa) { temporadaId.value = activa.id_temporada; cargar() }
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

async function exportPDF() {
  const doc   = new jsPDF({ orientation: 'landscape' })
  const pageW = doc.internal.pageSize.getWidth()
  const pageH = doc.internal.pageSize.getHeight()
  const logo  = await cargarLogoBase64('/logos/logorepor.png')

  doc.setFillColor(30,41,59); doc.rect(0,0,pageW,40,'F')
  doc.setFillColor(99,102,241); doc.rect(0,40,pageW,2,'F')
  if (logo) { doc.addImage(logo,'PNG',8,6,26,26) }
  else {
    doc.setDrawColor(255,255,255); doc.setLineWidth(0.5); doc.roundedRect(8,6,26,26,3,3,'S')
    doc.setTextColor(255,255,255); doc.setFontSize(6.5); doc.setFont('helvetica','normal')
    doc.text('LOGO',21,17,{align:'center'}); doc.text('LIGA',21,23,{align:'center'})
  }
  doc.setTextColor(255,255,255); doc.setFontSize(17); doc.setFont('helvetica','bold')
  doc.text('Liga Diamante',40,16)
  doc.setFontSize(9.5); doc.setFont('helvetica','normal'); doc.setTextColor(148,163,184)
  doc.text('Reporte de Taquilla — Recaudación por Partido',40,24)
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

  doc.setFontSize(10); doc.setFont('helvetica','bold'); doc.setTextColor(30,41,59)
  doc.text('Detalle por Partido',14,cy); cy += 5

  autoTable(doc, {
    startY: cy,
    head: [['Fecha','Partido','Resultado','General (Bs.)','VIP (Bs.)','Total (Bs.)']],
    body: [
      ...datos.value.map(d => [
        formatFecha(d.fecha_juego),
        `${d.equipo_casa} vs ${d.equipo_visitante}`,
        `${d.carreras_casa} — ${d.carreras_visitante}`,
        formatBs(d.recaudado_general),
        formatBs(d.recaudado_vip),
        formatBs(d.recaudado_total),
      ]),
      ['TOTAL','','',formatBs(totalGeneral.value),formatBs(totalVip.value),formatBs(totalRecaudado.value)],
    ],
    theme: 'grid',
    headStyles: { fillColor:[30,41,59], textColor:255, fontStyle:'bold', halign:'center', fontSize:9 },
    columnStyles: {
      0:{cellWidth:28}, 1:{fontStyle:'bold',cellWidth:60},
      2:{halign:'center',cellWidth:25}, 3:{halign:'right'}, 4:{halign:'right'}, 5:{halign:'right',fontStyle:'bold'},
    },
    styles: { fontSize:9, cellPadding:3 },
    alternateRowStyles: { fillColor:[245,247,250] },
    didParseCell(h) {
      if (h.row.index === datos.value.length) { h.cell.styles.fontStyle='bold'; h.cell.styles.fillColor=[226,232,240] }
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
}

function exportExcel() {
  const filas = [
    { Fecha:'REPORTE DE TAQUILLA' },
    { Fecha:'Temporada: '+temporadaNombre.value },
    {},
    ...datos.value.map(d => ({
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
