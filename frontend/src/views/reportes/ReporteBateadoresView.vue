<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
      <div>
        <h2 class="page-title">Estadísticas Ofensivas</h2>
        <p class="page-subtitle">Rendimiento de bateadores por temporada</p>
      </div>
      <div class="d-flex align-items-center gap-2 flex-wrap">
        <select v-model="filtroEquipo" class="form-select form-select-sm" style="max-width:180px;">
          <option value="">Todos los equipos</option>
          <option v-for="eq in equipos" :key="eq" :value="eq">{{ eq }}</option>
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
        <IconChartBar :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
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
        <!-- Tarjetas líderes -->
        <div class="row g-3 mb-4">
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#6366f122; color:#6366f1;"><IconChartBar :size="22" /></span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Líder de bateo (AVE)</div>
                    <div class="fw-bold" style="color:#6366f1; font-size:0.9rem;">{{ liderAve?.jugador || '—' }}</div>
                    <div class="text-muted" style="font-size:0.72rem;">{{ liderAve ? '.'+aveStr(liderAve.AVE) : '' }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#f97316 22; color:#f97316;"><IconBallBaseball :size="22" /></span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Líder en HR</div>
                    <div class="fw-bold" style="color:#f97316; font-size:0.9rem;">{{ liderHR?.jugador || '—' }}</div>
                    <div class="text-muted" style="font-size:0.72rem;">{{ liderHR ? liderHR.HR+' jonrones' : '' }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#10b98122; color:#10b981;"><IconTrophy :size="22" /></span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Líder en RBI</div>
                    <div class="fw-bold" style="color:#10b981; font-size:0.9rem;">{{ liderRBI?.jugador || '—' }}</div>
                    <div class="text-muted" style="font-size:0.72rem;">{{ liderRBI ? liderRBI.RBI+' impulsadas' : '' }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" style="background:#f59e0b22; color:#f59e0b;"><IconUsers :size="22" /></span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">Bateadores registrados</div>
                    <div class="fw-bold" style="color:#f59e0b; font-size:1rem;">{{ datosFiltrados.length }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Gráfico Top 5 HR -->
        <div class="card shadow-sm mb-4">
          <div class="card-header d-flex align-items-center gap-2 flex-wrap">
            <IconChartBar :size="18" class="text-primary" />
            <span class="fw-bold" style="font-size:0.9rem;">Top 5 — Home Runs e Impulsadas</span>
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
            <div v-if="!datos.length" class="text-center py-5 text-muted">Sin estadísticas registradas</div>
            <div v-else style="width:100%; overflow:hidden;">
              <svg viewBox="0 0 900 300" style="width:100%; height:300px; display:block;" xmlns="http://www.w3.org/2000/svg">
                <rect x="0" y="0" width="900" height="300" fill="transparent"/>
                <!-- Líneas guía -->
                <g v-for="i in 5" :key="'g'+i">
                  <line :x1="70" :y1="20 + (220/4)*(4-(i-1))" :x2="880" :y2="20 + (220/4)*(4-(i-1))" stroke="#e2e8f0" stroke-width="1"/>
                  <text :x="64" :y="20 + (220/4)*(4-(i-1)) + 4" text-anchor="end" font-size="10" fill="#94a3b8" font-family="sans-serif">
                    {{ Math.round(maxTop5 * (i-1) / 4) }}
                  </text>
                </g>
                <!-- Barras top 5 -->
                <g v-for="(d, i) in top5Grafico" :key="'t'+i">
                  <!-- HR -->
                  <rect :x="d.x" :y="240 - d.hHR" :width="d.w * 0.45" :height="d.hHR" fill="#f97316" rx="2"/>
                  <!-- RBI -->
                  <rect :x="d.x + d.w * 0.48" :y="240 - d.hRBI" :width="d.w * 0.45" :height="d.hRBI" fill="#6366f1" rx="2"/>
                  <!-- Nombre jugador -->
                  <text :x="d.x + d.w / 2" y="256" text-anchor="middle" font-size="9" fill="#475569" font-family="sans-serif">
                    {{ top5HR[i].jugador.split(' ')[0] }}
                  </text>
                  <text :x="d.x + d.w / 2" y="268" text-anchor="middle" font-size="8" fill="#94a3b8" font-family="sans-serif">
                    {{ top5HR[i].nombre_equipo.substring(0,8) }}
                  </text>
                  <!-- Valor HR -->
                  <text v-if="top5HR[i].HR > 0" :x="d.x + d.w * 0.22" :y="240 - d.hHR - 4"
                    text-anchor="middle" font-size="9" fill="#f97316" font-weight="bold" font-family="sans-serif">
                    {{ top5HR[i].HR }}
                  </text>
                  <!-- Valor RBI -->
                  <text v-if="top5HR[i].RBI > 0" :x="d.x + d.w * 0.71" :y="240 - d.hRBI - 4"
                    text-anchor="middle" font-size="9" fill="#6366f1" font-weight="bold" font-family="sans-serif">
                    {{ top5HR[i].RBI }}
                  </text>
                </g>
                <!-- Leyenda -->
                <rect x="680" y="8" width="12" height="10" fill="#f97316" rx="2"/>
                <text x="696" y="17" font-size="10" fill="#64748b" font-family="sans-serif">HR</text>
                <rect x="720" y="8" width="12" height="10" fill="#6366f1" rx="2"/>
                <text x="736" y="17" font-size="10" fill="#64748b" font-family="sans-serif">RBI</text>
              </svg>
            </div>
          </div>
        </div>

        <!-- Tabla estadísticas -->
        <div class="card shadow-sm">
          <div class="card-header d-flex align-items-center gap-2">
            <IconTable :size="18" class="text-primary" />
            <span class="fw-bold" style="font-size:0.9rem;">Estadísticas por Jugador</span>
            <div class="ms-auto">
              <input v-model="busqueda" class="form-control form-control-sm" placeholder="Buscar jugador..." style="max-width:180px;" />
            </div>
          </div>
          <div class="table-responsive">
            <table class="table table-vcenter card-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Jugador</th>
                  <th>Equipo</th>
                  <th class="text-center">JJ</th>
                  <th class="text-center">AB</th>
                  <th class="text-center">H</th>
                  <th class="text-center">2B</th>
                  <th class="text-center">3B</th>
                  <th class="text-center" style="color:#f97316;">HR</th>
                  <th class="text-center">RBI</th>
                  <th class="text-center">R</th>
                  <th class="text-center fw-bold">AVE</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="!datosFiltrados.length">
                  <td colspan="12" class="text-center py-5 text-muted">Sin datos</td>
                </tr>
                <tr v-for="(j, i) in datosFiltrados" :key="j.id_jugador">
                  <td class="text-muted small">{{ i + 1 }}</td>
                  <td><span class="fw-semibold">{{ j.jugador }}</span></td>
                  <td class="text-muted small">{{ j.nombre_equipo }}</td>
                  <td class="text-center">{{ j.juegos }}</td>
                  <td class="text-center">{{ j.AB }}</td>
                  <td class="text-center">{{ j.H }}</td>
                  <td class="text-center text-muted">{{ j.dobles }}</td>
                  <td class="text-center text-muted">{{ j.triples }}</td>
                  <td class="text-center fw-bold" style="color:#f97316;">{{ j.HR }}</td>
                  <td class="text-center">{{ j.RBI }}</td>
                  <td class="text-center">{{ j.R }}</td>
                  <td class="text-center">
                    <span class="badge fw-bold" style="font-size:0.82rem;"
                      :style="j.AVE >= 0.300 ? 'background:#10b98122;color:#10b981;' : 'background:#6366f122;color:#6366f1;'">
                      .{{ aveStr(j.AVE) }}
                    </span>
                  </td>
                </tr>
              </tbody>
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
  IconChartBar, IconBallBaseball, IconTrophy, IconUsers, IconTable,
  IconFileTypePdf, IconFileSpreadsheet,
} from '@tabler/icons-vue'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

const temporadas   = ref([])
const temporadaId  = ref('')
const cargando     = ref(false)
const datos        = ref([])
const busqueda     = ref('')
const filtroEquipo = ref('')

const fechaGeneracion = computed(() =>
  new Date().toLocaleString('es-VE', { dateStyle: 'medium', timeStyle: 'short' })
)
const temporadaNombre = computed(() => {
  const t = temporadas.value.find(t => t.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})

const equipos = computed(() => [...new Set(datos.value.map(j => j.nombre_equipo))].sort())

const datosFiltrados = computed(() => {
  return datos.value.filter(j => {
    const matchBusqueda = !busqueda.value ||
      j.jugador.toLowerCase().includes(busqueda.value.toLowerCase()) ||
      j.nombre_equipo.toLowerCase().includes(busqueda.value.toLowerCase())
    const matchEquipo = !filtroEquipo.value || j.nombre_equipo === filtroEquipo.value
    return matchBusqueda && matchEquipo
  })
})

const top5HR  = computed(() => [...datos.value].sort((a,b) => b.HR - a.HR).slice(0,5))
const liderAve = computed(() => datos.value.length ? datos.value[0] : null)
const liderHR  = computed(() => datos.value.length ? [...datos.value].sort((a,b) => b.HR - a.HR)[0] : null)
const liderRBI = computed(() => datos.value.length ? [...datos.value].sort((a,b) => b.RBI - a.RBI)[0] : null)

const maxTop5 = computed(() => {
  if (!top5HR.value.length) return 1
  return Math.max(...top5HR.value.map(j => Math.max(Number(j.HR), Number(j.RBI)))) * 1.2 || 1
})

const top5Grafico = computed(() => {
  const n  = top5HR.value.length || 1
  const bw = 810 / n
  return top5HR.value.map((j, i) => ({
    x:    70 + i * bw,
    w:    bw - 8,
    hHR:  Math.max((Number(j.HR)  / maxTop5.value) * 220, 2),
    hRBI: Math.max((Number(j.RBI) / maxTop5.value) * 220, 2),
  }))
})

function aveStr(ave) {
  return ave == null ? '000' : Number(ave).toFixed(3).replace('0.','').padStart(3,'0')
}

async function cargar() {
  if (!temporadaId.value) return
  cargando.value = true
  try {
    const { data } = await api.get('/reportes/estadisticas-bateadores', {
      params: { temporada: temporadaId.value },
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
  doc.text('Reporte de Estadísticas Ofensivas — Bateadores',40,24)
  doc.setFontSize(9); doc.setFont('helvetica','bold'); doc.setTextColor(255,255,255)
  doc.text(temporadaNombre.value,pageW-14,16,{align:'right'})
  doc.setFontSize(7.5); doc.setFont('helvetica','normal'); doc.setTextColor(148,163,184)
  doc.text('Generado: '+fechaGeneracion.value,pageW-14,24,{align:'right'})
  doc.setTextColor(0,0,0)

  let cy = 52
  doc.setFontSize(10); doc.setFont('helvetica','bold'); doc.setTextColor(30,41,59)
  doc.text('Estadísticas por Jugador',14,cy); cy += 5

  autoTable(doc, {
    startY: cy,
    head: [['Jugador','Equipo','JJ','AB','H','2B','3B','HR','RBI','R','AVE']],
    body: datosFiltrados.value.map(j => [
      j.jugador, j.nombre_equipo, j.juegos,
      j.AB, j.H, j.dobles, j.triples, j.HR, j.RBI, j.R,
      '.'+aveStr(j.AVE),
    ]),
    theme: 'grid',
    headStyles: { fillColor:[30,41,59], textColor:255, fontStyle:'bold', halign:'center', fontSize:8 },
    columnStyles: {
      0:{fontStyle:'bold', cellWidth:40},
      1:{cellWidth:35},
      2:{halign:'center'}, 3:{halign:'center'}, 4:{halign:'center'},
      5:{halign:'center'}, 6:{halign:'center'}, 7:{halign:'center',fontStyle:'bold'},
      8:{halign:'center'}, 9:{halign:'center'}, 10:{halign:'center',fontStyle:'bold'},
    },
    styles: { fontSize:8, cellPadding:2.5 },
    alternateRowStyles: { fillColor:[245,247,250] },
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
  doc.save(`reporte-bateadores-${temporadaNombre.value.replace(/\s+/g,'_')}.pdf`)
}

function exportExcel() {
  const filas = [
    { Jugador:'ESTADÍSTICAS OFENSIVAS — BATEADORES' },
    { Jugador:'Temporada: '+temporadaNombre.value },
    {},
    ...datosFiltrados.value.map(j => ({
      Jugador: j.jugador, Equipo: j.nombre_equipo,
      JJ: j.juegos, AB: j.AB, H: j.H,
      '2B': j.dobles, '3B': j.triples, HR: j.HR, RBI: j.RBI, R: j.R,
      AVE: '.'+aveStr(j.AVE),
    })),
  ]
  const ws = XLSX.utils.json_to_sheet(filas)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Bateadores')
  saveAs(new Blob([XLSX.write(wb,{type:'array',bookType:'xlsx'})]), 'reporte-bateadores.xlsx')
}

onMounted(cargarTemporadas)
</script>
