<template>
  <div>
    <div v-if="!props.embedded" class="page-header d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
      <div>
        <h2 class="page-title">Estadísticas Ofensivas</h2>
        <p class="page-subtitle">Rendimiento de bateadores por temporada</p>
      </div>
      <div class="d-flex align-items-center gap-2 flex-wrap">
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
            <div class="ms-auto d-flex align-items-center gap-2 flex-wrap">
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

        <!-- Tabla estadísticas agrupada por equipo -->
        <div class="card shadow-sm">
          <div class="card-header d-flex align-items-center gap-2 flex-wrap">
            <IconTable :size="18" class="text-primary" />
            <span class="fw-bold" style="font-size:0.9rem;">Estadísticas por Jugador</span>
            <div class="ms-auto d-flex align-items-center gap-2 flex-wrap">
              <FiltroMultiSelect
                v-model="jugadoresSeleccionados"
                :opciones="jugadores"
                texto-todos="Todos los jugadores"
                plural-label="jugadores"
              />
            </div>
          </div>
          <div class="card-body">
            <div v-if="!datosFiltrados.length" class="text-center py-5 text-muted">Sin datos</div>
            <template v-else>
              <div class="grupos-scroll">
                <div v-for="grupo in bateadoresPorEquipo" :key="grupo.equipo" class="mb-4">
                  <div class="d-flex align-items-center gap-2 mb-2">
                    <div class="team-avatar">{{ grupo.equipo?.charAt(0) }}</div>
                    <span class="fw-bold" style="font-size:0.9rem;">{{ grupo.equipo }}</span>
                    <span class="badge bg-blue-lt text-blue ms-1">{{ grupo.jugadores.length }} jugador(es)</span>
                  </div>
                  <div class="table-responsive">
                    <table class="table table-vcenter card-table table-sm table-hover">
                      <thead>
                        <tr>
                          <th>Jugador</th>
                          <th class="text-center"><AbrevTooltip ab="JJ" /></th>
                          <th class="text-center"><AbrevTooltip ab="AB" /></th>
                          <th class="text-center"><AbrevTooltip ab="H" /></th>
                          <th class="text-center"><AbrevTooltip ab="2B" /></th>
                          <th class="text-center"><AbrevTooltip ab="3B" /></th>
                          <th class="text-center" style="color:#f97316;"><AbrevTooltip ab="HR" /></th>
                          <th class="text-center"><AbrevTooltip ab="RBI" /></th>
                          <th class="text-center"><AbrevTooltip ab="R" /></th>
                          <th class="text-center fw-bold"><AbrevTooltip ab="AVE" /></th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="j in grupo.jugadores" :key="j.id_jugador">
                          <td><span class="fw-semibold">{{ j.jugador }}</span></td>
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
                </div>
              </div>
            </template>
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
import AbrevTooltip from '@/components/AbrevTooltip.vue'
import {
  IconChartBar, IconBallBaseball, IconTrophy, IconUsers, IconTable,
  IconFileTypePdf, IconFileSpreadsheet,
} from '@tabler/icons-vue'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

const temporadas             = ref([])
const temporadaId            = ref('')
watch(() => props.temporadaSel, val => { if (props.embedded && val) { temporadaId.value = val; cargar() } }, { immediate: false })
const cargando               = ref(false)
const datos                  = ref([])
const equiposSeleccionados   = ref([])
const jugadoresSeleccionados = ref([])
const mostrarGrafico         = ref(true)

const fechaGeneracion = computed(() =>
  new Date().toLocaleString('es-VE', { dateStyle: 'medium', timeStyle: 'short' })
)
const temporadaNombre = computed(() => {
  const t = temporadas.value.find(t => t.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})

const equipos   = computed(() => [...new Set(datos.value.map(j => j.nombre_equipo))].filter(Boolean).sort())
const jugadores = computed(() => [...new Set(datos.value.map(j => j.jugador))].filter(Boolean).sort())

const datosFiltrados = computed(() => {
  const porEquipo  = equiposSeleccionados.value.length > 0
  const porJugador = jugadoresSeleccionados.value.length > 0

  // Sin ningún filtro → todos
  if (!porEquipo && !porJugador) return datos.value

  return datos.value.filter(j => {
    // OR: aparece si coincide con el filtro de equipos O con el de jugadores
    const matchEquipo  = porEquipo  && equiposSeleccionados.value.includes(j.nombre_equipo)
    const matchJugador = porJugador && jugadoresSeleccionados.value.includes(j.jugador)
    return matchEquipo || matchJugador
  })
})

const top5HR  = computed(() => [...datos.value].sort((a,b) => b.HR - a.HR).slice(0,5))
const liderAve = computed(() => datos.value.length ? datos.value[0] : null)
const liderHR  = computed(() => datos.value.length ? [...datos.value].sort((a,b) => b.HR - a.HR)[0] : null)
const liderRBI = computed(() => datos.value.length ? [...datos.value].sort((a,b) => b.RBI - a.RBI)[0] : null)

const bateadoresPorEquipo = computed(() => {
  const mapa = {}
  for (const j of datosFiltrados.value) {
    const eq = j.nombre_equipo || 'Sin equipo'
    if (!mapa[eq]) mapa[eq] = []
    mapa[eq].push(j)
  }
  return Object.entries(mapa)
    .map(([equipo, jugadores]) => ({ equipo, jugadores: jugadores.sort((a, b) => (b.AVE ?? 0) - (a.AVE ?? 0)) }))
    .sort((a, b) => a.equipo.localeCompare(b.equipo))
})

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
  const top5 = [...datos.value].sort((a, b) => Number(b.HR) - Number(a.HR)).slice(0, 5)
  if (!top5.length) return null

  const maxV = Math.max(...top5.map(j => Math.max(Number(j.HR), Number(j.RBI)))) * 1.2 || 1
  const W = 900, H = 300
  const oc  = document.createElement('canvas')
  oc.width  = W; oc.height = H
  const ctx = oc.getContext('2d')

  ctx.fillStyle = '#ffffff'
  ctx.fillRect(0, 0, W, H)

  // Líneas guía
  for (let i = 0; i < 5; i++) {
    const y = 20 + (220 / 4) * (4 - i)
    ctx.strokeStyle = '#e2e8f0'; ctx.lineWidth = 1
    ctx.beginPath(); ctx.moveTo(70, y); ctx.lineTo(880, y); ctx.stroke()
    ctx.fillStyle = '#94a3b8'; ctx.font = '10px sans-serif'
    ctx.textAlign = 'right'; ctx.textBaseline = 'middle'
    ctx.fillText(Math.round(maxV * i / 4), 64, y)
  }

  // Barras
  const bw = 810 / top5.length
  top5.forEach((j, i) => {
    const x    = 70 + i * bw
    const w    = bw - 8
    const hHR  = Math.max((Number(j.HR)  / maxV) * 220, 2)
    const hRBI = Math.max((Number(j.RBI) / maxV) * 220, 2)

    ctx.fillStyle = '#f97316'
    ctx.fillRect(x, 240 - hHR,  w * 0.45, hHR)
    ctx.fillStyle = '#6366f1'
    ctx.fillRect(x + w * 0.48, 240 - hRBI, w * 0.45, hRBI)

    ctx.fillStyle = '#475569'; ctx.font = '9px sans-serif'
    ctx.textAlign = 'center'; ctx.textBaseline = 'top'
    ctx.fillText(j.jugador.split(' ')[0], x + w / 2, 244)
    ctx.fillStyle = '#94a3b8'; ctx.font = '8px sans-serif'
    ctx.fillText((j.nombre_equipo || '').substring(0, 10), x + w / 2, 256)

    if (Number(j.HR) > 0) {
      ctx.fillStyle = '#f97316'; ctx.font = 'bold 9px sans-serif'
      ctx.textBaseline = 'bottom'
      ctx.fillText(j.HR, x + w * 0.22, 240 - hHR - 2)
    }
    if (Number(j.RBI) > 0) {
      ctx.fillStyle = '#6366f1'; ctx.font = 'bold 9px sans-serif'
      ctx.textBaseline = 'bottom'
      ctx.fillText(j.RBI, x + w * 0.71, 240 - hRBI - 2)
    }
  })

  // Leyenda
  ctx.fillStyle = '#f97316'; ctx.fillRect(680, 8, 12, 10)
  ctx.fillStyle = '#64748b'; ctx.font = '10px sans-serif'
  ctx.textAlign = 'left'; ctx.textBaseline = 'top'
  ctx.fillText('HR', 696, 9)
  ctx.fillStyle = '#6366f1'; ctx.fillRect(720, 8, 12, 10)
  ctx.fillStyle = '#64748b'; ctx.fillText('RBI', 736, 9)

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
  doc.text('Reporte de Estadísticas Ofensivas — Bateadores',46,24)
  doc.setFontSize(9); doc.setFont('helvetica','bold'); doc.setTextColor(255,255,255)
  doc.text(temporadaNombre.value,pageW-14,16,{align:'right'})
  doc.setFontSize(7.5); doc.setFont('helvetica','normal'); doc.setTextColor(148,163,184)
  doc.text('Generado: '+fechaGeneracion.value,pageW-14,24,{align:'right'})
  doc.setTextColor(0,0,0)

  let cy = 52

  // Gráfico Top 5 HR y RBI
  if (mostrarGrafico.value && datos.value.length) {
    const oc = generarGraficoCanvas()
    if (oc) {
      const imgData = oc.toDataURL('image/png')
      const imgW    = pageW - 28
      const imgH    = imgW * (300 / 900)
      doc.setFontSize(9); doc.setFont('helvetica','bold'); doc.setTextColor(30,41,59)
      doc.text('Top 5 — Home Runs y RBI por Jugador', pageW / 2, cy, { align: 'center' })
      cy += 4
      doc.addImage(imgData, 'PNG', 14, cy, imgW, imgH)
      cy += imgH + 8
    }
  }

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
  } catch (err) {
    console.error('Error al exportar PDF de bateadores:', err)
    alert('No se pudo generar el PDF. Asegúrate de que los datos estén cargados.')
  }
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

<style scoped>
.team-avatar {
  width: 30px;
  height: 30px;
  border-radius: 8px;
  background: #eee;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 0.8rem;
  flex-shrink: 0;
}

.grupos-scroll {
  max-height: 600px;
  overflow-y: auto;
  overflow-x: hidden;
  padding-right: 4px;
}
.grupos-scroll::-webkit-scrollbar { width: 6px; }
.grupos-scroll::-webkit-scrollbar-track { background: #f1f5f9; border-radius: 3px; }
.grupos-scroll::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
.grupos-scroll::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
</style>
