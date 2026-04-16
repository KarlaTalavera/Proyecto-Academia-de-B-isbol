<template>
  <div>
    <!-- ── Encabezado de página ── -->
    <div class="page-header d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
      <div>
        <h2 class="page-title">Reporte de Efectividad de Pitcheo</h2>
        <p class="page-subtitle">Estadísticas individuales de lanzadores agrupadas por equipo</p>
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

    <!-- Sin temporada -->
    <div v-if="!temporadaId" class="card">
      <div class="card-body text-center py-5 text-muted">
        <IconFlame :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
        <p class="mb-0">Selecciona una temporada para ver el reporte</p>
      </div>
    </div>

    <template v-else>
      <!-- Cargando -->
      <div v-if="cargando" class="card">
        <div class="card-body text-center py-5">
          <span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...
        </div>
      </div>

      <template v-else>
        <!-- ── Tarjetas resumen ── -->
        <div class="row g-3 mb-4">
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body d-flex align-items-center gap-3">
                <span class="avatar flex-shrink-0" style="background:#6366f122; color:#6366f1;">
                  <IconUsers :size="22" />
                </span>
                <div class="stat-text">
                  <div class="fw-medium text-muted stat-label">Total Lanzadores</div>
                  <div class="fw-bold stat-value" style="color:#6366f1;">{{ pitchers.length }}</div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body d-flex align-items-center gap-3">
                <span class="avatar flex-shrink-0" style="background:#10b98122; color:#10b981;">
                  <IconTrophy :size="22" />
                </span>
                <div class="stat-text">
                  <div class="fw-medium text-muted stat-label">Mejor ERA</div>
                  <div class="fw-bold stat-value" style="color:#10b981;">
                    {{ mejorERA !== null ? mejorERA.toFixed(2) : '—' }}
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body d-flex align-items-center gap-3">
                <span class="avatar flex-shrink-0" style="background:#f59e0b22; color:#f59e0b;">
                  <IconFlame :size="22" />
                </span>
                <div class="stat-text">
                  <div class="fw-medium text-muted stat-label">Total Ponches (K)</div>
                  <div class="fw-bold stat-value" style="color:#f59e0b;">{{ totalK }}</div>
                </div>
              </div>
            </div>
          </div>
          <div class="col-sm-6 col-lg-3">
            <div class="card card-sm">
              <div class="card-body d-flex align-items-center gap-3">
                <span class="avatar flex-shrink-0" style="background:#3b82f622; color:#3b82f6;">
                  <IconChartBar :size="22" />
                </span>
                <div class="stat-text">
                  <div class="fw-medium text-muted stat-label">Total Innings (IP)</div>
                  <div class="fw-bold stat-value" style="color:#3b82f6;">{{ totalIP }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- ── Tabla principal ── -->
        <div class="card shadow-sm">
          <div class="card-header d-flex align-items-center gap-2 flex-wrap">
            <IconFlame :size="18" class="text-warning" />
            <span class="fw-bold" style="font-size:0.9rem;">Efectividad de Lanzadores</span>
            <span v-if="temporadaNombre" class="text-muted" style="font-size:0.78rem;">
              {{ temporadaNombre }}
            </span>

            <div class="ms-auto d-flex align-items-center gap-2 flex-wrap">
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

          <div class="card-body">
            <div class="row g-4 align-items-start">

              <!-- Gráfico de barras ERA -->
              <div v-show="mostrarGrafico" class="col-md-5 text-center">
                <div class="fw-semibold mb-2" style="font-size:0.82rem; color:#1e293b;">
                  Ranking de Efectividad (ERA) — menor es mejor
                </div>
                <canvas ref="canvasBar" style="width:100%; max-height:340px;"></canvas>
                <div class="text-muted mt-1" style="font-size:0.72rem;">Top 10 lanzadores con más innings</div>
              </div>

              <!-- Tabla agrupada por equipo -->
              <div :class="mostrarGrafico ? 'col-md-7' : 'col-12'">
                <div v-if="!pitchers.length" class="text-center py-5 text-muted">
                  Sin datos de pitcheo para esta temporada
                </div>
                <template v-else>
                  <div class="grupos-scroll">
                  <div v-for="grupo in pitchersPorEquipo" :key="grupo.equipo" class="mb-4">
                    <div class="d-flex align-items-center gap-2 mb-2">
                      <div class="team-avatar">{{ grupo.equipo?.charAt(0) }}</div>
                      <span class="fw-bold" style="font-size:0.9rem;">{{ grupo.equipo }}</span>
                      <span class="badge bg-blue-lt text-blue ms-1">{{ grupo.jugadores.length }} lanzador(es)</span>
                    </div>
                    <div class="table-responsive">
                      <table class="table table-vcenter card-table table-sm table-hover">
                        <thead>
                          <tr>
                            <th>Lanzador</th>
                            <th class="text-center">JJ</th>
                            <th class="text-center">IP</th>
                            <th class="text-center">ER</th>
                            <th class="text-center">K</th>
                            <th class="text-center">W</th>
                            <th class="text-center">L</th>
                            <th class="text-center fw-bold">ERA</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr v-for="p in grupo.jugadores" :key="p.id_jugador">
                            <td><span class="fw-semibold">{{ p.jugador }}</span></td>
                            <td class="text-center">{{ p.JJ }}</td>
                            <td class="text-center">{{ p.IP }}</td>
                            <td class="text-center">{{ p.ER }}</td>
                            <td class="text-center text-warning fw-bold">{{ p.K }}</td>
                            <td class="text-center text-success fw-bold">{{ p.W }}</td>
                            <td class="text-center text-danger">{{ p.L }}</td>
                            <td class="text-center">
                              <span
                                class="badge fw-bold"
                                :class="eraClass(p.ERA)"
                              >{{ p.ERA ?? '—' }}</span>
                            </td>
                          </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>
                  </div><!-- /grupos-scroll -->
                </template>

                <div class="text-muted text-end mt-2" style="font-size:0.72rem;">
                  Generado el {{ fechaGeneracion }}
                </div>
              </div>

            </div>
          </div>
        </div>
      </template>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, watch, nextTick, onMounted } from 'vue'
import api from '@/services/api'
import {
  IconFlame, IconUsers, IconTrophy, IconChartBar,
  IconFileTypePdf, IconFileSpreadsheet,
} from '@tabler/icons-vue'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

const temporadas    = ref([])
const temporadaId   = ref('')
const cargando      = ref(false)
const pitchers      = ref([])
const mostrarGrafico = ref(true)
const canvasBar     = ref(null)

const fechaGeneracion = computed(() =>
  new Date().toLocaleString('es-VE', { dateStyle: 'medium', timeStyle: 'short' })
)

const temporadaNombre = computed(() => {
  const t = temporadas.value.find(t => t.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})

const mejorERA = computed(() => {
  const vals = pitchers.value.map(p => p.ERA).filter(v => v !== null && v !== undefined)
  return vals.length ? Math.min(...vals) : null
})

const totalK = computed(() => pitchers.value.reduce((s, p) => s + (p.K || 0), 0))
const totalIP = computed(() => pitchers.value.reduce((s, p) => s + (p.IP || 0), 0))

const pitchersPorEquipo = computed(() => {
  const mapa = {}
  for (const p of pitchers.value) {
    const eq = p.nombre_equipo || 'Sin equipo'
    if (!mapa[eq]) mapa[eq] = []
    mapa[eq].push(p)
  }
  return Object.entries(mapa)
    .map(([equipo, jugadores]) => ({ equipo, jugadores: jugadores.sort((a, b) => (a.ERA ?? 99) - (b.ERA ?? 99)) }))
    .sort((a, b) => a.equipo.localeCompare(b.equipo))
})

function eraClass(era) {
  if (era === null || era === undefined) return 'bg-secondary-lt text-secondary'
  if (era < 2.00) return 'bg-success-lt text-success'
  if (era < 4.00) return 'bg-blue-lt text-blue'
  if (era < 6.00) return 'bg-warning-lt text-warning'
  return 'bg-danger-lt text-danger'
}

async function cargar() {
  if (!temporadaId.value) return
  cargando.value = true
  try {
    const { data } = await api.get('/reportes/promedios-pitcheo', {
      params: { temporada: temporadaId.value },
    })
    pitchers.value = data
    if (mostrarGrafico.value) {
      await nextTick()
      dibujarBarras()
    }
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

function dibujarBarras() {
  if (!canvasBar.value) return

  // Top 10 con más innings lanzados
  const top = [...pitchers.value]
    .filter(p => p.IP > 0)
    .sort((a, b) => (b.IP || 0) - (a.IP || 0))
    .slice(0, 10)
    .sort((a, b) => (a.ERA ?? 99) - (b.ERA ?? 99))

  if (!top.length) return

  const canvas = canvasBar.value
  const dpr    = window.devicePixelRatio || 1
  const W      = canvas.offsetWidth || 360
  const H      = 320

  canvas.width  = W * dpr
  canvas.height = H * dpr

  const ctx = canvas.getContext('2d')
  ctx.scale(dpr, dpr)
  ctx.clearRect(0, 0, W, H)

  const padL = 40
  const padR = 12
  const padT = 16
  const padB = 64
  const chartW = W - padL - padR
  const chartH = H - padT - padB

  const maxERA = Math.max(...top.map(p => p.ERA ?? 0), 6) * 1.1
  const barW   = chartW / top.length
  const gap    = barW * 0.25

  // Cuadrícula
  ctx.strokeStyle = '#e2e8f0'
  ctx.lineWidth   = 0.8
  for (let i = 0; i <= 5; i++) {
    const y = padT + chartH - (i / 5) * chartH
    ctx.beginPath()
    ctx.moveTo(padL, y)
    ctx.lineTo(padL + chartW, y)
    ctx.stroke()
    ctx.fillStyle    = '#94a3b8'
    ctx.font         = '9px sans-serif'
    ctx.textAlign    = 'right'
    ctx.textBaseline = 'middle'
    ctx.fillText(((maxERA * i) / 5).toFixed(1), padL - 4, y)
  }

  // Barras
  top.forEach((p, i) => {
    const era  = p.ERA ?? 0
    const h    = (era / maxERA) * chartH
    const x    = padL + i * barW + gap / 2
    const w    = barW - gap
    const y    = padT + chartH - h

    // Color según ERA
    let color
    if (era < 2.0)       color = '#10b981'
    else if (era < 4.0)  color = '#3b82f6'
    else if (era < 6.0)  color = '#f59e0b'
    else                 color = '#ef4444'

    ctx.fillStyle = color + '33'
    ctx.fillRect(x, y, w, h)
    ctx.fillStyle = color
    ctx.fillRect(x, y, w, 3)

    // Valor ERA encima
    ctx.fillStyle    = '#1e293b'
    ctx.font         = 'bold 9px sans-serif'
    ctx.textAlign    = 'center'
    ctx.textBaseline = 'bottom'
    ctx.fillText(era.toFixed(2), x + w / 2, y - 2)

    // Nombre del pitcher (rotado)
    ctx.save()
    ctx.translate(x + w / 2, padT + chartH + 6)
    ctx.rotate(-Math.PI / 4)
    ctx.fillStyle    = '#475569'
    ctx.font         = '9px sans-serif'
    ctx.textAlign    = 'right'
    ctx.textBaseline = 'middle'
    const nombre = p.jugador?.split(' ').slice(-1)[0] || p.jugador
    ctx.fillText(nombre, 0, 0)
    ctx.restore()
  })

  // Eje X
  ctx.strokeStyle = '#cbd5e1'
  ctx.lineWidth   = 1
  ctx.beginPath()
  ctx.moveTo(padL, padT + chartH)
  ctx.lineTo(padL + chartW, padT + chartH)
  ctx.stroke()
}

watch(mostrarGrafico, async (val) => {
  if (val && pitchers.value.length) {
    await nextTick()
    requestAnimationFrame(() => dibujarBarras())
  }
})

// ── Helpers PDF ──────────────────────────────────────────
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

async function exportPDF() {
  const doc   = new jsPDF({ orientation: 'landscape' })
  const pageW = doc.internal.pageSize.getWidth()
  const pageH = doc.internal.pageSize.getHeight()

  // Logo
  const logoCandidatos = [
    '/logos/logorepor.png',
    '/logos/logo diamante.png',
    '/logos/logo-reporte.png',
    '/logos/logo.png',
  ]
  let logoBase64 = null
  for (const url of logoCandidatos) {
    logoBase64 = await cargarLogoBase64(url)
    if (logoBase64) break
  }

  // Franja superior
  doc.setFillColor(30, 41, 59)
  doc.rect(0, 0, pageW, 40, 'F')
  doc.setFillColor(245, 158, 11)
  doc.rect(0, 40, pageW, 2, 'F')

  // Logo
  if (logoBase64) {
    doc.addImage(logoBase64, 'PNG', 8, 6, 26, 26)
  } else {
    doc.setDrawColor(255, 255, 255)
    doc.setLineWidth(0.5)
    doc.roundedRect(8, 6, 26, 26, 3, 3, 'S')
    doc.setTextColor(255, 255, 255)
    doc.setFontSize(6.5)
    doc.setFont('helvetica', 'normal')
    doc.text('LIGA', 21, 21, { align: 'center' })
  }

  // Títulos
  doc.setTextColor(255, 255, 255)
  doc.setFontSize(17)
  doc.setFont('helvetica', 'bold')
  doc.text('Liga Diamante', 40, 16)

  doc.setFontSize(9.5)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(148, 163, 184)
  doc.text('Reporte de Efectividad de Pitcheo — Lanzadores', 40, 24)

  doc.setFontSize(9)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(255, 255, 255)
  doc.text(temporadaNombre.value, pageW - 14, 16, { align: 'right' })

  doc.setFontSize(7.5)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(148, 163, 184)
  doc.text('Generado: ' + fechaGeneracion.value, pageW - 14, 24, { align: 'right' })

  doc.setTextColor(0, 0, 0)

  // Resumen
  let cursorY = 52
  doc.setFillColor(255, 251, 235)
  doc.roundedRect(14, cursorY - 5, pageW - 28, 14, 2, 2, 'F')
  doc.setFontSize(8.5)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(71, 85, 105)
  doc.text(
    `Lanzadores: ${pitchers.value.length}   |   Mejor ERA: ${mejorERA.value !== null ? mejorERA.value.toFixed(2) : '—'}   |   Total K: ${totalK.value}   |   Total IP: ${totalIP.value}`,
    pageW / 2, cursorY + 3, { align: 'center' }
  )
  cursorY += 18

  // Gráfico (si está visible)
  if (mostrarGrafico.value && canvasBar.value) {
    const imgData = canvasBar.value.toDataURL('image/png')
    const imgH    = 52
    const imgW    = imgH * (canvasBar.value.width / canvasBar.value.height)
    doc.setFontSize(9)
    doc.setFont('helvetica', 'bold')
    doc.setTextColor(30, 41, 59)
    doc.text('Ranking de Efectividad (ERA)', pageW / 2, cursorY, { align: 'center' })
    cursorY += 4
    doc.addImage(imgData, 'PNG', (pageW - imgW) / 2, cursorY, imgW, imgH)
    cursorY += imgH + 8
  }

  // Tabla por equipo
  for (const grupo of pitchersPorEquipo.value) {
    doc.setFontSize(10)
    doc.setFont('helvetica', 'bold')
    doc.setTextColor(30, 41, 59)
    doc.text(grupo.equipo, 14, cursorY)
    cursorY += 4

    autoTable(doc, {
      startY: cursorY,
      head: [['Lanzador', 'JJ', 'IP', 'ER', 'K', 'W', 'L', 'ERA']],
      body: grupo.jugadores.map(p => [
        p.jugador, p.JJ, p.IP, p.ER, p.K, p.W, p.L,
        p.ERA !== null && p.ERA !== undefined ? p.ERA.toFixed(2) : '—',
      ]),
      theme: 'grid',
      headStyles: { fillColor: [30, 41, 59], textColor: 255, fontStyle: 'bold', halign: 'center', fontSize: 8 },
      columnStyles: {
        0: { fontStyle: 'bold', cellWidth: 55 },
        1: { halign: 'center' },
        2: { halign: 'center' },
        3: { halign: 'center' },
        4: { halign: 'center', fontStyle: 'bold' },
        5: { halign: 'center', textColor: [22, 163, 74] },
        6: { halign: 'center', textColor: [220, 38, 38] },
        7: { halign: 'center', fontStyle: 'bold' },
      },
      styles: { fontSize: 8, cellPadding: 3 },
      alternateRowStyles: { fillColor: [245, 247, 250] },
    })

    cursorY = doc.lastAutoTable.finalY + 8
  }

  // Pie de página
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

  doc.save(`reporte-pitcheo-${temporadaNombre.value.replace(/\s+/g, '_')}.pdf`)
}

function exportExcel() {
  const filas = [
    { 'Reporte': 'EFECTIVIDAD DE PITCHEO — LIGA DIAMANTE' },
    { 'Reporte': 'Temporada: ' + temporadaNombre.value },
    { 'Reporte': 'Generado: ' + fechaGeneracion.value },
    {},
  ]

  for (const grupo of pitchersPorEquipo.value) {
    filas.push({ 'Reporte': `EQUIPO: ${grupo.equipo}` })
    for (const p of grupo.jugadores) {
      filas.push({
        'Reporte':  p.jugador,
        'Equipo':   p.nombre_equipo,
        'JJ':       p.JJ,
        'IP':       p.IP,
        'ER':       p.ER,
        'K':        p.K,
        'W':        p.W,
        'L':        p.L,
        'ERA':      p.ERA !== null && p.ERA !== undefined ? p.ERA : '',
        'WHIP':     p.WHIP !== null && p.WHIP !== undefined ? p.WHIP : '',
      })
    }
    filas.push({})
  }

  const ws = XLSX.utils.json_to_sheet(filas)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Pitcheo')
  const buf = XLSX.write(wb, { type: 'array', bookType: 'xlsx' })
  saveAs(new Blob([buf]), `reporte-pitcheo-${temporadaNombre.value.replace(/\s+/g, '_')}.xlsx`)
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

/* Tarjetas resumen: evita que el texto desborde */
.stat-text {
  min-width: 0;
  overflow: hidden;
}
.stat-label {
  font-size: 0.75rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.stat-value {
  font-size: 1rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Sección de grupos con scroll */
.grupos-scroll {
  max-height: 520px;
  overflow-y: auto;
  overflow-x: hidden;
  padding-right: 4px;
}
.grupos-scroll::-webkit-scrollbar {
  width: 6px;
}
.grupos-scroll::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 3px;
}
.grupos-scroll::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}
.grupos-scroll::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
</style>
