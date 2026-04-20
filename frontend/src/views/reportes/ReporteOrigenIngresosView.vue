<template>
  <div>
    <div v-if="!props.embedded" class="page-header d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
      <div>
        <h2 class="page-title">Reporte de Origen de Ingresos</h2>
        <p class="page-subtitle">Mix comercial — distribución de fuentes de ingreso por temporada</p>
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

    <!-- Barra de filtros por fecha (siempre visible cuando hay temporada) -->
    <div v-if="temporadaId" class="d-flex align-items-center gap-3 mb-3 flex-wrap">
      <div class="d-flex align-items-center gap-2" style="font-size:0.84rem; color:#475569;">
        <span class="fw-semibold">Fecha inicio:</span>
        <input v-model="fechaDesde" type="date" class="form-control form-control-sm" style="max-width:145px;" @change="onFechaChange" />
      </div>
      <div class="d-flex align-items-center gap-2" style="font-size:0.84rem; color:#475569;">
        <span class="fw-semibold">Fecha fin:</span>
        <input v-model="fechaHasta" type="date" class="form-control form-control-sm" style="max-width:145px;" @change="onFechaChange" />
      </div>
      <button v-if="fechaDesde || fechaHasta" class="btn btn-sm btn-ghost-secondary" @click="fechaDesde=''; fechaHasta=''; onFechaChange()">
        Limpiar fechas
      </button>
    </div>

    <div v-if="!temporadaId" class="card">
      <div class="card-body text-center py-5 text-muted">
        <IconChartPie :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
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
        <div class="row g-3 mb-4">
          <div class="col-sm-6 col-lg-3" v-for="cat in categoriasPrincipales" :key="cat.categoria">
            <div class="card card-sm">
              <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                  <span class="avatar" :style="`background:${cat.color}22; color:${cat.color};`">
                    <component :is="cat.icono" :size="22" />
                  </span>
                  <div>
                    <div class="fw-medium text-muted" style="font-size:0.75rem;">{{ cat.categoria }}</div>
                    <div class="fw-bold" :style="`color:${cat.color}; font-size:1rem;`">
                      {{ formatBs(cat.total) }}
                    </div>
                    <div class="text-muted" style="font-size:0.72rem;">{{ cat.percentage }}% del total</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="card shadow-sm">
          <div class="card-header d-flex align-items-center gap-2 flex-wrap">
            <IconChartPie :size="18" class="text-primary" />
            <span class="fw-bold" style="font-size:0.9rem;">Distribución por Categoría</span>
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
              <div v-if="mostrarGrafico" class="col-md-5 text-center">
                <div ref="pieContainer" style="position:relative; display:inline-block;">
                  <canvas
                    ref="canvasPie"
                    width="300" height="300"
                    style="max-width:300px; display:block; cursor:pointer;"
                    @mousemove="onPieMouseMove"
                    @mouseleave="onPieMouseLeave"
                  ></canvas>
                  <div v-if="pieTooltip.visible" :style="`
                    position:absolute;
                    left:${pieTooltip.x}px;
                    top:${pieTooltip.y}px;
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
                    <div class="fw-bold mb-1" :style="`color:${colorPorCategoria(pieTooltip.cat.categoria)}`">
                      {{ pieTooltip.cat.categoria }}
                    </div>
                    <div>{{ formatBs(pieTooltip.cat.total) }}</div>
                    <div style="color:#94a3b8;">{{ pieTooltip.cat.porcentaje }}% del total</div>
                  </div>
                </div>
                <div class="mt-3 d-flex flex-wrap justify-content-center gap-2">
                  <div
                    v-for="cat in datos.categorias"
                    :key="cat.categoria"
                    class="d-flex align-items-center gap-1"
                    style="font-size:0.78rem;"
                  >
                    <span
                      class="rounded-circle d-inline-block"
                      :style="`width:10px;height:10px;background:${colorPorCategoria(cat.categoria)};`"
                    ></span>
                    {{ cat.categoria }} ({{ cat.porcentaje }}%)
                  </div>
                </div>
              </div>

              <div :class="mostrarGrafico ? 'col-md-7' : 'col-12'">
                <div class="table-responsive">
                  <table class="table table-vcenter card-table" id="tabla-origen-ingresos">
                    <thead>
                      <tr>
                        <th>Categoría</th>
                        <th class="text-center">Registros</th>
                        <th class="text-end">Monto (Bs.)</th>
                        <th class="text-center">% del Total</th>
                        <th class="text-center">Barra</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="!datos.categorias?.length">
                        <td colspan="5" class="text-center py-5 text-muted">Sin ingresos registrados</td>
                      </tr>
                      <tr v-for="cat in datos.categorias" :key="cat.categoria">
                        <td>
                          <div class="d-flex align-items-center gap-2">
                            <span
                              class="rounded-circle d-inline-block flex-shrink-0"
                              :style="`width:10px;height:10px;background:${colorPorCategoria(cat.categoria)};`"
                            ></span>
                            <span class="fw-semibold" style="font-size:0.875rem;">{{ cat.categoria }}</span>
                          </div>
                        </td>
                        <td class="text-center text-muted">{{ cat.cantidad }}</td>
                        <td class="text-end fw-bold" :style="`color:${colorPorCategoria(cat.categoria)};`">
                          {{ formatBs(cat.total) }}
                        </td>
                        <td class="text-center">
                          <span
                            class="badge fw-bold"
                            style="font-size:0.82rem;"
                            :style="`background:${colorPorCategoria(cat.categoria)}22; color:${colorPorCategoria(cat.categoria)};`"
                          >
                            {{ cat.porcentaje }}%
                          </span>
                        </td>
                        <td style="min-width:120px;">
                          <div class="progress" style="height:8px; border-radius:4px; background:#f1f5f9;">
                            <div
                              class="progress-bar"
                              :style="`width:${cat.porcentaje}%; background:${colorPorCategoria(cat.categoria)};`"
                            ></div>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                    <tfoot v-if="datos.categorias?.length">
                      <tr style="border-top:2px solid #e2e8f0;">
                        <td class="fw-bold">TOTAL GENERAL</td>
                        <td class="text-center fw-bold">
                          {{ datos.categorias.reduce((s, c) => s + c.cantidad, 0) }}
                        </td>
                        <td class="text-end fw-bold text-success" style="font-size:1rem;">
                          {{ formatBs(datos.total_general) }}
                        </td>
                        <td class="text-center fw-bold">100%</td>
                        <td></td>
                      </tr>
                    </tfoot>
                  </table>
                </div>
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
import {
  IconChartPie, IconFileTypePdf, IconFileSpreadsheet,
  IconCoin, IconTag, IconClipboard, IconShoppingCart, IconPackage,
} from '@tabler/icons-vue'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

// Reactividad y estado local
const temporadas    = ref([])
const temporadaId   = ref('')
watch(() => props.temporadaSel, val => { if (props.embedded && val) { temporadaId.value = val; cargar() } }, { immediate: false })
const cargando      = ref(false)
const mostrarGrafico = ref(true)
const datos          = ref({ total_general: 0, categorias: [] })
const canvasPie      = ref(null)
const pieContainer   = ref(null)
const hoveredSlice   = ref(-1)
const pieTooltip     = ref({ visible: false, x: 0, y: 0, cat: null })
const fechaDesde     = ref('')
const fechaHasta     = ref('')

const fechaGeneracion = computed(() =>
  new Date().toLocaleString('es-VE', { dateStyle: 'medium', timeStyle: 'short' })
)

const temporadaNombre = computed(() => {
  const t = temporadas.value.find(t => t.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})

const COLORES = {
  'Patrocinios':             '#6366f1',
  'Taquilla':                '#f59e0b',
  'Inscripciones de Equipos':'#10b981',
  'Concesiones':             '#f97316',
  'Otros':                   '#94a3b8',
}

function colorPorCategoria(cat) {
  return COLORES[cat] || '#94a3b8'
}

const ICONOS = {
  'Patrocinios':             IconCoin,
  'Taquilla':                IconTag,
  'Inscripciones de Equipos': IconClipboard,
  'Concesiones':             IconShoppingCart,
  'Otros':                   IconPackage,
}

const categoriasPrincipales = computed(() => {
  const orden = ['Patrocinios', 'Taquilla', 'Inscripciones de Equipos', 'Concesiones']
  return orden.map(nombre => {
    const found = datos.value.categorias?.find(c => c.categoria === nombre)
    return {
      categoria: nombre,
      total: found?.total || 0,
      percentage: found?.porcentaje || 0,
      icono: ICONOS[nombre],
      color: COLORES[nombre],
    }
  })
})

function formatBs(v) {
  return new Intl.NumberFormat('es-VE', {
    minimumFractionDigits: 2, maximumFractionDigits: 2,
  }).format(v || 0) + ' Bs.'
}

async function cargar() {
  if (!temporadaId.value) return
  cargando.value = true
  try {
    const params = { temporada: temporadaId.value }
    if (fechaDesde.value) params.fechaDesde = fechaDesde.value
    if (fechaHasta.value) params.fechaHasta = fechaHasta.value
    const { data } = await api.get('/reportes/origen-ingresos', { params })
    datos.value = data
  } finally {
    cargando.value = false
  }
  // Dibujar DESPUÉS de que cargando=false actualice el DOM (canvas visible)
  if (mostrarGrafico.value && datos.value.categorias?.length) {
    await nextTick()
    requestAnimationFrame(() => dibujarPie())
  }
}

function onFechaChange() {
  if (temporadaId.value) cargar()
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

function dibujarPie() {
  if (!canvasPie.value) return
  const cats = datos.value.categorias?.filter(c => c.total > 0) || []
  if (!cats.length) return

  const canvas = canvasPie.value
  const ctx    = canvas.getContext('2d')
  const W = canvas.width
  const H = canvas.height
  const cx = W / 2
  const cy = H / 2
  const rBase = Math.min(W, H) / 2 - 22

  ctx.clearRect(0, 0, W, H)

  const total  = cats.reduce((s, c) => s + c.total, 0)
  let angulo   = -Math.PI / 2

  cats.forEach((cat, idx) => {
    const slice     = (cat.total / total) * 2 * Math.PI
    const isHovered = idx === hoveredSlice.value
    const r         = isHovered ? rBase + 10 : rBase
    const midAngle  = angulo + slice / 2

    // Offset de explosión al hacer hover
    const ox = isHovered ? Math.cos(midAngle) * 6 : 0
    const oy = isHovered ? Math.sin(midAngle) * 6 : 0

    if (isHovered) {
      ctx.shadowColor = colorPorCategoria(cat.categoria)
      ctx.shadowBlur  = 14
    } else {
      ctx.shadowBlur = 0
    }

    ctx.beginPath()
    ctx.moveTo(cx + ox, cy + oy)
    ctx.arc(cx + ox, cy + oy, r, angulo, angulo + slice)
    ctx.closePath()
    ctx.fillStyle = colorPorCategoria(cat.categoria)
    ctx.fill()

    ctx.shadowBlur  = 0
    ctx.strokeStyle = '#fff'
    ctx.lineWidth   = isHovered ? 3 : 2
    ctx.stroke()

    if (slice > 0.25) {
      const lx = cx + ox + (r * 0.65) * Math.cos(midAngle)
      const ly = cy + oy + (r * 0.65) * Math.sin(midAngle)
      ctx.fillStyle    = '#fff'
      ctx.font         = isHovered ? 'bold 13px sans-serif' : 'bold 11px sans-serif'
      ctx.textAlign    = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillText(cat.porcentaje + '%', lx, ly)
    }
    angulo += slice
  })

  ctx.beginPath()
  ctx.arc(cx, cy, rBase * 0.45, 0, 2 * Math.PI)
  ctx.fillStyle = '#fff'
  ctx.fill()

  ctx.fillStyle = '#1e293b'
  ctx.font = 'bold 11px sans-serif'
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText('TOTAL', cx, cy - 9)
  ctx.font = 'bold 13px sans-serif'
  ctx.fillStyle = '#10b981'
  const totalStr = new Intl.NumberFormat('es-VE', {
    notation: 'compact', maximumFractionDigits: 1,
  }).format(datos.value.total_general || 0)
  ctx.fillText(totalStr + ' Bs.', cx, cy + 9)
}

function onPieMouseMove(e) {
  const canvas = canvasPie.value
  if (!canvas) return

  const rect   = canvas.getBoundingClientRect()
  const scaleX = canvas.width  / rect.width
  const scaleY = canvas.height / rect.height
  const mx     = (e.clientX - rect.left) * scaleX
  const my     = (e.clientY - rect.top)  * scaleY

  const cats   = datos.value.categorias?.filter(c => c.total > 0) || []
  const W = canvas.width, H = canvas.height
  const cx = W / 2, cy = H / 2
  const rBase = Math.min(W, H) / 2 - 22
  const dx = mx - cx, dy = my - cy
  const dist = Math.sqrt(dx * dx + dy * dy)

  let newHovered = -1
  if (dist >= rBase * 0.45 && dist <= rBase + 12) {
    const total = cats.reduce((s, c) => s + c.total, 0)
    let mouseAngle = Math.atan2(dy, dx)
    if (mouseAngle < -Math.PI / 2) mouseAngle += 2 * Math.PI

    let startAngle = -Math.PI / 2
    for (let i = 0; i < cats.length; i++) {
      const slice = (cats[i].total / total) * 2 * Math.PI
      if (mouseAngle >= startAngle && mouseAngle < startAngle + slice) {
        newHovered = i
        break
      }
      startAngle += slice
    }
  }

  if (newHovered !== hoveredSlice.value) {
    hoveredSlice.value = newHovered
    dibujarPie()
  }

  if (newHovered >= 0 && pieContainer.value) {
    const containerRect = pieContainer.value.getBoundingClientRect()
    pieTooltip.value = {
      visible: true,
      x: e.clientX - containerRect.left,
      y: e.clientY - containerRect.top - 8,
      cat: cats[newHovered],
    }
  } else {
    pieTooltip.value = { ...pieTooltip.value, visible: false }
  }
}

function onPieMouseLeave() {
  hoveredSlice.value = -1
  pieTooltip.value   = { ...pieTooltip.value, visible: false }
  dibujarPie()
}

watch(mostrarGrafico, async (val) => {
  if (val && datos.value.categorias?.length) {
    await nextTick()
    requestAnimationFrame(() => dibujarPie())
  }
})

async function cargarLogoBase64(url) {
  return new Promise((resolve) => {
    const img = new Image()
    img.crossOrigin = 'anonymous'
    img.onload = () => {
      const canvas = document.createElement('canvas')
      canvas.width  = img.naturalWidth
      canvas.height = img.naturalHeight
      canvas.getContext('2d').drawImage(img, 0, 0)
      resolve(canvas.toDataURL('image/png'))
    }
    img.onerror = () => resolve(null)
    img.src = url
  })
}

async function exportPDF() {
  try {
  const doc   = new jsPDF({ orientation: 'portrait' })
  const pageW = doc.internal.pageSize.getWidth()
  const pageH = doc.internal.pageSize.getHeight()

  // Cargar logo
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

  // ── Franja superior azul oscuro ──────────────────────────
  doc.setFillColor(30, 41, 59)
  doc.rect(0, 0, pageW, 40, 'F')

  // ── Línea de acento indigo ───────────────────────────────
  doc.setFillColor(99, 102, 241)
  doc.rect(0, 40, pageW, 2, 'F')

  // ── Logo (esquina superior izquierda) ────────────────────
  if (logoBase64) {
    doc.addImage(logoBase64, 'PNG', 8, 6, 32, 28)
  } else {
    doc.setDrawColor(255, 255, 255)
    doc.setLineWidth(0.5)
    doc.roundedRect(8, 6, 32, 28, 3, 3, 'S')
    doc.setTextColor(255, 255, 255)
    doc.setFontSize(6.5)
    doc.setFont('helvetica', 'normal')
    doc.text('LOGO', 24, 17, { align: 'center' })
    doc.text('LIGA', 24, 23, { align: 'center' })
  }

  // ── Nombre del sistema ───────────────────────────────────
  doc.setTextColor(255, 255, 255)
  doc.setFontSize(17)
  doc.setFont('helvetica', 'bold')
  doc.text('Liga Diamante', 46, 16)

  // ── Nombre del reporte ───────────────────────────────────
  doc.setFontSize(9.5)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(148, 163, 184)
  doc.text('Reporte de Origen de Ingresos — Mix Comercial', 46, 24)

  // ── Temporada (derecha) ──────────────────────────────────
  doc.setFontSize(9)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(255, 255, 255)
  doc.text(temporadaNombre.value, pageW - 14, 16, { align: 'right' })

  // ── Fecha y hora de generación (derecha) ─────────────────
  doc.setFontSize(7.5)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(148, 163, 184)
  doc.text('Generado: ' + fechaGeneracion.value, pageW - 14, 24, { align: 'right' })

  doc.setTextColor(0, 0, 0)

  // ── Total general destacado ──────────────────────────────
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
  doc.text(formatBs(datos.value.total_general), pageW - 18, cursorY + 3, { align: 'right' })
  cursorY += 18

  // ── Gráfico de pastel (si está activado) ─────────────────
  const cats = datos.value.categorias?.filter(c => c.total > 0) || []
  if (mostrarGrafico.value && cats.length) {
    // Dibujar en canvas offscreen de tamaño fijo para garantizar imagen válida
    const oc  = document.createElement('canvas')
    oc.width  = 300
    oc.height = 300
    const octx = oc.getContext('2d')
    const W = 300, H = 300, cx = 150, cy = 150, r = 125
    octx.clearRect(0, 0, W, H)
    const total = cats.reduce((s, c) => s + c.total, 0)
    let ang = -Math.PI / 2
    for (const cat of cats) {
      const slice = (cat.total / total) * 2 * Math.PI
      octx.beginPath(); octx.moveTo(cx, cy)
      octx.arc(cx, cy, r, ang, ang + slice); octx.closePath()
      octx.fillStyle = colorPorCategoria(cat.categoria); octx.fill()
      octx.strokeStyle = '#fff'; octx.lineWidth = 2; octx.stroke()
      if (slice > 0.3) {
        const mid = ang + slice / 2
        octx.fillStyle = '#fff'; octx.font = 'bold 12px sans-serif'
        octx.textAlign = 'center'; octx.textBaseline = 'middle'
        octx.fillText(cat.porcentaje + '%', cx + r * 0.65 * Math.cos(mid), cy + r * 0.65 * Math.sin(mid))
      }
      ang += slice
    }
    octx.beginPath(); octx.arc(cx, cy, r * 0.45, 0, 2 * Math.PI)
    octx.fillStyle = '#fff'; octx.fill()
    octx.fillStyle = '#1e293b'; octx.font = 'bold 12px sans-serif'
    octx.textAlign = 'center'; octx.textBaseline = 'middle'
    octx.fillText('TOTAL', cx, cy - 10)
    octx.font = 'bold 14px sans-serif'; octx.fillStyle = '#10b981'
    const totalStr = new Intl.NumberFormat('es-VE', { notation: 'compact', maximumFractionDigits: 1 }).format(datos.value.total_general || 0)
    octx.fillText(totalStr + ' Bs.', cx, cy + 10)
    const imgData = oc.toDataURL('image/png')
    const imgSize = 72
    doc.setFontSize(9)
    doc.setFont('helvetica', 'bold')
    doc.setTextColor(30, 41, 59)
    doc.text('Distribución Porcentual', pageW / 2, cursorY, { align: 'center' })
    cursorY += 4
    doc.addImage(imgData, 'PNG', (pageW - imgSize) / 2, cursorY, imgSize, imgSize)
    cursorY += imgSize + 6
  }

  // ── Título de tabla ──────────────────────────────────────
  doc.setFontSize(10)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(30, 41, 59)
  doc.text('Detalle por Categoría', 14, cursorY)
  cursorY += 5

  // ── Tabla de datos ───────────────────────────────────────
  autoTable(doc, {
    startY: cursorY,
    head: [['Categoría', 'N° Registros', 'Monto (Bs.)', '% del Total']],
    body: [
      ...(datos.value.categorias || []).map(c => [
        c.categoria,
        c.cantidad,
        formatBs(c.total),
        c.porcentaje + '%',
      ]),
      [
        'TOTAL GENERAL',
        datos.value.categorias?.reduce((s, c) => s + c.cantidad, 0) || 0,
        formatBs(datos.value.total_general),
        '100%',
      ],
    ],
    theme: 'grid',
    headStyles: { fillColor: [30, 41, 59], textColor: 255, fontStyle: 'bold', halign: 'center', fontSize: 9 },
    columnStyles: {
      0: { fontStyle: 'bold', cellWidth: 70 },
      1: { halign: 'center' },
      2: { halign: 'right' },
      3: { halign: 'center' },
    },
    styles: { fontSize: 9, cellPadding: 3.5 },
    alternateRowStyles: { fillColor: [245, 247, 250] },
    didParseCell(hookData) {
      if (hookData.row.index === (datos.value.categorias?.length || 0)) {
        hookData.cell.styles.fontStyle = 'bold'
        hookData.cell.styles.fillColor = [226, 232, 240]
      }
    },
  })

  // ── Pie de página ────────────────────────────────────────
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

  doc.save(`reporte-origen-ingresos-${temporadaNombre.value.replace(/\s+/g, '_')}.pdf`)
  } catch (err) {
    console.error('Error al exportar PDF de origen de ingresos:', err)
    alert('No se pudo generar el PDF. Asegúrate de que los datos estén cargados.')
  }
}

function exportExcel() {
  const filas = [
    { 'Categoría': 'REPORTE DE ORIGEN DE INGRESOS' },
    { 'Categoría': 'Temporada: ' + temporadaNombre.value },
    {},
    ...(datos.value.categorias || []).map(c => ({
      'Categoría':    c.categoria,
      'Registros':    c.cantidad,
      'Monto (Bs.)':  c.total,
      '% del Total':  c.porcentaje + '%',
    })),
  ]

  const ws = XLSX.utils.json_to_sheet(filas)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Ingresos')
  const buf = XLSX.write(wb, { type: 'array', bookType: 'xlsx' })
  saveAs(new Blob([buf]), `reporte-ingresos.xlsx`)
}

onMounted(cargarTemporadas)
</script>