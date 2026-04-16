<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
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
                <canvas ref="canvasPie" width="300" height="300" style="max-width:300px; margin: 0 auto;"></canvas>
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
import { ref, computed, watch, nextTick, onMounted } from 'vue'
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
const cargando      = ref(false)
const mostrarGrafico = ref(true)
const datos          = ref({ total_general: 0, categorias: [] })
const canvasPie     = ref(null)

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
    const { data } = await api.get('/reportes/origen-ingresos', {
      params: { temporada: temporadaId.value },
    })
    datos.value = data
    if (mostrarGrafico.value) {
      await nextTick()
      dibujarPie()
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
  const r  = Math.min(W, H) / 2 - 20

  ctx.clearRect(0, 0, W, H)

  const total = cats.reduce((s, c) => s + c.total, 0)
  let angulo  = -Math.PI / 2

  for (const cat of cats) {
    const slice = (cat.total / total) * 2 * Math.PI
    ctx.beginPath()
    ctx.moveTo(cx, cy)
    ctx.arc(cx, cy, r, angulo, angulo + slice)
    ctx.closePath()
    ctx.fillStyle = colorPorCategoria(cat.categoria)
    ctx.fill()
    ctx.strokeStyle = '#fff'
    ctx.lineWidth = 2
    ctx.stroke()

    if (slice > 0.3) {
      const midAngle = angulo + slice / 2
      const lx = cx + (r * 0.65) * Math.cos(midAngle)
      const ly = cy + (r * 0.65) * Math.sin(midAngle)
      ctx.fillStyle = '#fff'
      ctx.font      = 'bold 11px sans-serif'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillText(cat.porcentaje + '%', lx, ly)
    }
    angulo += slice
  }

  ctx.beginPath()
  ctx.arc(cx, cy, r * 0.45, 0, 2 * Math.PI)
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

watch(mostrarGrafico, async (val) => {
  if (val && datos.value.categorias?.length) {
    await nextTick()
    dibujarPie()
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

  // ── Nombre del sistema ───────────────────────────────────
  doc.setTextColor(255, 255, 255)
  doc.setFontSize(17)
  doc.setFont('helvetica', 'bold')
  doc.text('Liga Diamante', 40, 16)

  // ── Nombre del reporte ───────────────────────────────────
  doc.setFontSize(9.5)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(148, 163, 184)
  doc.text('Reporte de Origen de Ingresos — Mix Comercial', 40, 24)

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
  if (mostrarGrafico.value && canvasPie.value) {
    const imgData = canvasPie.value.toDataURL('image/png')
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