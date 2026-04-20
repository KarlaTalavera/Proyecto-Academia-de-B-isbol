<template>
  <div>
    <!-- ── Encabezado de página ── -->
    <div v-if="!props.embedded" class="page-header d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
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
                  <div class="fw-bold stat-value" style="color:#6366f1;">{{ pitchersFiltrados.length }}</div>
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
              <FiltroMultiSelect
                v-model="equiposSeleccionados"
                :opciones="equipos"
                texto-todos="Todos los equipos"
                plural-label="equipos"
              />
              <FiltroMultiSelect
                v-model="lanzadoresSeleccionados"
                :opciones="lanzadores"
                texto-todos="Todos los lanzadores"
                plural-label="lanzadores"
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

          <div class="card-body">
            <div class="row g-4 align-items-start">

              <!-- Gráfico horizontal ERA + K -->
              <div v-show="mostrarGrafico" class="col-md-5">
                <div class="fw-semibold mb-1" style="font-size:0.82rem; color:#1e293b;">
                  Ranking de ERA — mejores lanzadores
                </div>
                <div class="d-flex justify-content-between text-muted mb-1" style="font-size:0.7rem; padding:0 4px 0 120px;">
                  <span>ERA →</span>
                  <span>K (ponches)</span>
                </div>
                <div ref="barContainer" style="position:relative;">
                  <canvas
                    ref="canvasBar"
                    style="width:100%; display:block; cursor:crosshair;"
                    @mousemove="onBarMouseMove"
                    @mouseleave="onBarMouseLeave"
                  ></canvas>
                  <div v-if="barTooltip.visible && barTooltip.pitcher" :style="`
                    position:absolute;
                    left:${barTooltip.x}px;
                    top:${barTooltip.y}px;
                    background:#1e293b;
                    color:#fff;
                    border-radius:8px;
                    padding:8px 12px;
                    font-size:0.78rem;
                    pointer-events:none;
                    white-space:nowrap;
                    box-shadow:0 4px 16px rgba(0,0,0,0.25);
                    z-index:10;
                    transform:translate(-50%,-100%);
                  `">
                    <div class="fw-bold mb-1">{{ barTooltip.pitcher.jugador }}</div>
                    <div>ERA: <span class="fw-bold" style="color:#f59e0b;">{{ Number(barTooltip.pitcher.ERA).toFixed(2) }}</span></div>
                    <div style="color:#94a3b8;">
                      {{ Number(barTooltip.pitcher.IP) }} IP &nbsp;·&nbsp;
                      {{ Number(barTooltip.pitcher.K) }} K &nbsp;·&nbsp;
                      {{ barTooltip.pitcher.W }}W – {{ barTooltip.pitcher.L }}L
                    </div>
                  </div>
                </div>
                <div class="d-flex gap-3 mt-2 flex-wrap" style="font-size:0.7rem;">
                  <span><span style="display:inline-block;width:10px;height:10px;border-radius:2px;background:#10b981;margin-right:4px;"></span>ERA &lt; 2.00</span>
                  <span><span style="display:inline-block;width:10px;height:10px;border-radius:2px;background:#3b82f6;margin-right:4px;"></span>ERA &lt; 4.00</span>
                  <span><span style="display:inline-block;width:10px;height:10px;border-radius:2px;background:#f59e0b;margin-right:4px;"></span>ERA &lt; 6.00</span>
                  <span><span style="display:inline-block;width:10px;height:10px;border-radius:2px;background:#ef4444;margin-right:4px;"></span>ERA ≥ 6.00</span>
                </div>
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
                            <th class="text-center"><AbrevTooltip ab="JJ" /></th>
                            <th class="text-center"><AbrevTooltip ab="IP" /></th>
                            <th class="text-center"><AbrevTooltip ab="ER" /></th>
                            <th class="text-center text-warning"><AbrevTooltip ab="K" /></th>
                            <th class="text-center text-success"><AbrevTooltip ab="W" /></th>
                            <th class="text-center text-danger"><AbrevTooltip ab="L" /></th>
                            <th class="text-center fw-bold"><AbrevTooltip ab="ERA" /></th>
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
import { ref, computed, watch, nextTick, onMounted, defineProps } from 'vue'
const props = defineProps({
  embedded:     { type: Boolean, default: false },
  temporadaSel: { type: [String, Number], default: '' },
})
import api from '@/services/api'
import FiltroMultiSelect from '@/components/FiltroMultiSelect.vue'
import AbrevTooltip from '@/components/AbrevTooltip.vue'
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
watch(() => props.temporadaSel, val => { if (props.embedded && val) { temporadaId.value = val; cargar() } }, { immediate: false })
const cargando      = ref(false)
const pitchers      = ref([])
const mostrarGrafico = ref(true)
const canvasBar      = ref(null)
const barContainer   = ref(null)
const hoveredBar              = ref(-1)
const barTooltip              = ref({ visible: false, x: 0, y: 0, pitcher: null })
const equiposSeleccionados    = ref([])
const lanzadoresSeleccionados = ref([])

const fechaGeneracion = computed(() =>
  new Date().toLocaleString('es-VE', { dateStyle: 'medium', timeStyle: 'short' })
)

const temporadaNombre = computed(() => {
  const t = temporadas.value.find(t => t.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})

const equipos    = computed(() => [...new Set(pitchers.value.map(p => p.nombre_equipo))].filter(Boolean).sort())
const lanzadores = computed(() => [...new Set(pitchers.value.map(p => p.jugador))].filter(Boolean).sort())

const pitchersFiltrados = computed(() => {
  const porEquipo   = equiposSeleccionados.value.length > 0
  const porLanzador = lanzadoresSeleccionados.value.length > 0

  // Sin ningún filtro → todos
  if (!porEquipo && !porLanzador) return pitchers.value

  return pitchers.value.filter(p => {
    // OR: aparece si coincide con el filtro de equipos O con el de lanzadores
    const matchEquipo   = porEquipo   && equiposSeleccionados.value.includes(p.nombre_equipo)
    const matchLanzador = porLanzador && lanzadoresSeleccionados.value.includes(p.jugador)
    return matchEquipo || matchLanzador
  })
})

const mejorERA = computed(() => {
  const vals = pitchersFiltrados.value.map(p => Number(p.ERA)).filter(v => !isNaN(v))
  return vals.length ? Math.min(...vals) : null
})

const totalK  = computed(() => pitchersFiltrados.value.reduce((s, p) => s + Number(p.K  || 0), 0))
const totalIP = computed(() => pitchersFiltrados.value.reduce((s, p) => s + Number(p.IP || 0), 0))

const pitchersPorEquipo = computed(() => {
  const mapa = {}
  for (const p of pitchersFiltrados.value) {
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
  } finally {
    cargando.value = false
  }
  // Dibujar DESPUÉS de que cargando=false actualice el DOM (canvas visible)
  if (mostrarGrafico.value && pitchers.value.length) {
    await nextTick()
    requestAnimationFrame(() => dibujarBarras())
  }
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

function _dibujarBarrasEnCanvas(canvas, W, data, hoveredIdx = -1) {
  const top = [...data]
    .filter(p => p.IP > 0 && p.ERA !== null && p.ERA !== undefined)
    .sort((a, b) => (a.ERA ?? 99) - (b.ERA ?? 99))
    .slice(0, 12)

  if (!top.length) return

  const ROW_H  = 36
  const PAD_L  = 115
  const PAD_R  = 56
  const PAD_T  = 4
  const H      = PAD_T + top.length * ROW_H + 4
  const chartW = W - PAD_L - PAD_R

  canvas.width  = W
  canvas.height = H

  const ctx    = canvas.getContext('2d')
  ctx.clearRect(0, 0, W, H)

  const maxERA = Math.max(...top.map(p => p.ERA ?? 0), 0.1) * 1.15

  top.forEach((p, i) => {
    const era       = Number(p.ERA ?? 0)
    const rowY      = PAD_T + i * ROW_H
    const isHovered = i === hoveredIdx
    const barH      = ROW_H - (isHovered ? 6 : 10)
    const barY      = rowY + (isHovered ? 3 : 5)
    const barW      = Math.max((era / maxERA) * chartW, 3)

    let color
    if (era < 2.0)      color = '#10b981'
    else if (era < 4.0) color = '#3b82f6'
    else if (era < 6.0) color = '#f59e0b'
    else                color = '#ef4444'

    // Fondo de fila — más destacado al hacer hover
    ctx.fillStyle = isHovered ? color + '14' : (i % 2 === 0 ? '#f8fafc' : '#ffffff')
    ctx.fillRect(0, rowY, W, ROW_H)

    // Borde izquierdo de fila al hacer hover
    if (isHovered) {
      ctx.fillStyle = color
      ctx.fillRect(0, rowY, 3, ROW_H)
    }

    // Nombre
    const apellido = (p.jugador ?? '').split(' ').slice(-1)[0]
    ctx.fillStyle    = isHovered ? color : '#1e293b'
    ctx.font         = isHovered ? 'bold 11px sans-serif' : '11px sans-serif'
    ctx.textAlign    = 'right'
    ctx.textBaseline = 'middle'
    ctx.fillText(apellido, PAD_L - 10, rowY + ROW_H / 2)

    // Barra — relleno suave
    ctx.fillStyle = color + (isHovered ? '55' : '28')
    ctx.fillRect(PAD_L, barY, barW, barH)

    // Acento izquierdo de la barra
    ctx.fillStyle = color
    ctx.fillRect(PAD_L, barY, isHovered ? 4 : 3, barH)

    // Valor ERA
    ctx.fillStyle    = color
    ctx.font         = isHovered ? 'bold 11px sans-serif' : 'bold 10px sans-serif'
    ctx.textAlign    = 'left'
    ctx.textBaseline = 'middle'
    ctx.fillText(era.toFixed(2), PAD_L + barW + 6, rowY + ROW_H / 2)

    // Ponches (K)
    ctx.fillStyle    = isHovered ? '#475569' : '#94a3b8'
    ctx.font         = isHovered ? 'bold 10px sans-serif' : '10px sans-serif'
    ctx.textAlign    = 'right'
    ctx.textBaseline = 'middle'
    ctx.fillText(Number(p.K) + 'K', W - 4, rowY + ROW_H / 2)
  })

  return top   // para que onBarMouseMove pueda usarlo
}

function dibujarBarras() {
  if (!canvasBar.value) return
  const W = canvasBar.value.offsetWidth || 400
  _dibujarBarrasEnCanvas(canvasBar.value, W, pitchersFiltrados.value, hoveredBar.value)
  canvasBar.value.style.width  = W + 'px'
  canvasBar.value.style.height = canvasBar.value.height + 'px'
}

function onBarMouseMove(e) {
  const canvas = canvasBar.value
  if (!canvas) return

  const rect = canvas.getBoundingClientRect()
  const my   = (e.clientY - rect.top) * (canvas.height / rect.height)

  const ROW_H  = 36
  const PAD_T  = 4
  const top    = [...pitchersFiltrados.value]
    .filter(p => p.IP > 0 && p.ERA !== null && p.ERA !== undefined)
    .sort((a, b) => (a.ERA ?? 99) - (b.ERA ?? 99))
    .slice(0, 12)

  const idx = Math.floor((my - PAD_T) / ROW_H)
  const newHovered = idx >= 0 && idx < top.length ? idx : -1

  if (newHovered !== hoveredBar.value) {
    hoveredBar.value = newHovered
    dibujarBarras()
  }

  if (newHovered >= 0 && barContainer.value) {
    const containerRect = barContainer.value.getBoundingClientRect()
    barTooltip.value = {
      visible:  true,
      x:        e.clientX - containerRect.left,
      y:        e.clientY - containerRect.top - 8,
      pitcher:  top[newHovered],
    }
  } else {
    barTooltip.value = { ...barTooltip.value, visible: false }
  }
}

function onBarMouseLeave() {
  hoveredBar.value = -1
  barTooltip.value = { ...barTooltip.value, visible: false }
  dibujarBarras()
}

watch(mostrarGrafico, async (val) => {
  if (val && pitchersFiltrados.value.length) {
    await nextTick()
    requestAnimationFrame(() => dibujarBarras())
  }
})

watch([equiposSeleccionados, lanzadoresSeleccionados], async () => {
  if (mostrarGrafico.value && pitchersFiltrados.value.length) {
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
  try {
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
    doc.addImage(logoBase64, 'PNG', 8, 6, 32, 28)
  } else {
    doc.setDrawColor(255, 255, 255)
    doc.setLineWidth(0.5)
    doc.roundedRect(8, 6, 32, 28, 3, 3, 'S')
    doc.setTextColor(255, 255, 255)
    doc.setFontSize(6.5)
    doc.setFont('helvetica', 'normal')
    doc.text('LIGA', 24, 21, { align: 'center' })
  }

  // Títulos
  doc.setTextColor(255, 255, 255)
  doc.setFontSize(17)
  doc.setFont('helvetica', 'bold')
  doc.text('Liga Diamante', 46, 16)

  doc.setFontSize(9.5)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(148, 163, 184)
  doc.text('Reporte de Efectividad de Pitcheo — Lanzadores', 46, 24)

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
    `Lanzadores: ${pitchersFiltrados.value.length}   |   Mejor ERA: ${mejorERA.value !== null ? mejorERA.value.toFixed(2) : '—'}   |   Total K: ${totalK.value}   |   Total IP: ${totalIP.value}`,
    pageW / 2, cursorY + 3, { align: 'center' }
  )
  cursorY += 18

  // Gráfico (si está visible) — ancho completo de página
  if (mostrarGrafico.value && pitchersFiltrados.value.some(p => p.IP > 0 && p.ERA !== null)) {
    const oc = document.createElement('canvas')
    _dibujarBarrasEnCanvas(oc, 1400, pitchersFiltrados.value)
    if (oc.width > 0 && oc.height > 0) {
      const imgData   = oc.toDataURL('image/png')
      const imgW      = pageW - 28
      const imgH      = imgW * (oc.height / oc.width)
      doc.setFontSize(9)
      doc.setFont('helvetica', 'bold')
      doc.setTextColor(30, 41, 59)
      doc.text('Ranking de Efectividad (ERA)', pageW / 2, cursorY, { align: 'center' })
      cursorY += 4
      doc.addImage(imgData, 'PNG', 14, cursorY, imgW, imgH)
      cursorY += imgH + 8
    }
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
        p.ERA !== null && p.ERA !== undefined ? Number(p.ERA).toFixed(2) : '—',
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
  } catch (err) {
    console.error('Error al exportar PDF de pitcheo:', err)
    alert('No se pudo generar el PDF. Asegúrate de que los datos estén cargados.')
  }
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
