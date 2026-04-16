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

    <!-- Accesos rápidos a reportes individuales -->
    <div v-if="auth.puedeVerReportes" class="d-flex gap-2 mb-4 flex-wrap">
      <RouterLink
        to="/app/reportes/origen-ingresos"
        class="btn btn-sm btn-outline-primary d-flex align-items-center gap-1"
        style="border-radius:8px; font-size:0.82rem; text-decoration:none;"
      >
        <IconChartPie :size="15" />
        Origen de Ingresos
      </RouterLink>

      <RouterLink
        v-if="auth.puedeFinanzas"
        to="/app/reportes/historico-ingresos"
        class="btn btn-sm btn-outline-primary d-flex align-items-center gap-1"
        style="border-radius:8px; font-size:0.82rem; text-decoration:none;"
      >
        <IconChartLine :size="15" />
        Histórico de Ingresos
      </RouterLink>

      <RouterLink
        to="/app/reportes/efectividad-pitcheo"
        class="btn btn-sm btn-outline-warning d-flex align-items-center gap-1"
        style="border-radius:8px; font-size:0.82rem; text-decoration:none;"
      >
        <IconFlame :size="15" />
        Efectividad de Pitcheo
      </RouterLink>

    </div>

    <div v-if="!temporadaId" class="card shadow-sm">
      <div class="card-body text-center py-5 text-muted">
        <IconChartBar :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
        <p class="mb-0">Selecciona una temporada para visualizar los datos analíticos</p>
      </div>
    </div>

    <div v-else>
      <div v-if="tab === 'posiciones'">
        <div class="card shadow-sm">
          <div class="card-header d-flex align-items-center gap-2">
            <IconTrophy :size="18" class="text-warning" />
            <span class="fw-bold">Tabla de Posiciones</span>
            <span class="ms-auto text-muted small">{{ temporadaNombre }}</span>
            <div class="ms-2 d-flex gap-1">
              <button class="btn btn-icon btn-sm btn-outline-danger" @click="exportPDF('posiciones')"><IconFileTypePdf :size="16" /></button>
              <button class="btn btn-icon btn-sm btn-outline-success" @click="exportExcel('posiciones')"><IconFileSpreadsheet :size="16" /></button>
            </div>
          </div>
          <div v-if="cargando" class="text-center py-5"><span class="spinner-border spinner-border-sm text-primary"></span></div>
          <div v-else class="table-responsive">
            <table class="table table-vcenter card-table table-hover">
              <thead>
                <tr>
                  <th style="width:40px;">#</th>
                  <th>Equipo</th>
                  <th class="text-center">JJ</th>
                  <th class="text-center">G</th>
                  <th class="text-center">P</th>
                  <th class="text-center">PCT</th>
                  <th class="text-center">CF</th>
                  <th class="text-center">CC</th>
                  <th class="text-center">DIF</th>
                  <th class="text-center">JD</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(eq, i) in posiciones" :key="eq.id_equipo" :class="i === 0 ? 'table-success-lt' : ''">
                  <td>
                    <IconTrophy v-if="i === 0" :size="16" class="text-warning" />
                    <span v-else class="text-muted fw-bold small">{{ i + 1 }}</span>
                  </td>
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <div class="team-avatar" :style="i === 0 ? 'background:linear-gradient(135deg,#f59e0b,#f97316); color:white;' : ''">
                        {{ eq.nombre_equipo?.charAt(0) }}
                      </div>
                      <span class="fw-semibold">{{ eq.nombre_equipo }}</span>
                    </div>
                  </td>
                  <td class="text-center fw-bold">{{ eq.jugados }}</td>
                  <td class="text-center text-success fw-bold">{{ eq.ganados }}</td>
                  <td class="text-center text-danger">{{ eq.perdidos }}</td>
                  <td class="text-center fw-bold">{{ pct(eq.ganados, eq.jugados) }}</td>
                  <td class="text-center">{{ eq.carreras_favor }}</td>
                  <td class="text-center">{{ eq.carreras_contra }}</td>
                  <td class="text-center" :class="(eq.carreras_favor - eq.carreras_contra) >= 0 ? 'text-success' : 'text-danger'">
                    {{ eq.carreras_favor - eq.carreras_contra }}
                  </td>
                  <td class="text-center text-muted">{{ i === 0 ? '—' : (posiciones[0].ganados - eq.ganados).toFixed(1) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-else-if="tab === 'bateo'">
        <div class="card shadow-sm">
          <div class="card-header d-flex align-items-center gap-2">
            <IconChartBar :size="18" class="text-primary" />
            <span class="fw-bold">Líderes de Bateo</span>
            <div class="ms-auto d-flex gap-2">
              <div class="input-group input-group-sm" style="max-width:200px;">
                <input v-model="busquedaBateo" class="form-control" placeholder="Buscar..." />
              </div>
              <button class="btn btn-icon btn-sm btn-outline-danger" @click="exportPDF('bateo')"><IconFileTypePdf :size="16" /></button>
              <button class="btn btn-icon btn-sm btn-outline-success" @click="exportExcel('bateo')"><IconFileSpreadsheet :size="16" /></button>
            </div>
          </div>
          <div class="table-responsive">
            <table class="table table-vcenter card-table">
              <thead>
                <tr>
                  <th>#</th><th>Jugador</th><th>Equipo</th>
                  <th class="text-center">AB</th><th class="text-center">H</th>
                  <th class="text-center">HR</th><th class="text-center">RBI</th>
                  <th class="text-center fw-bold">AVG</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(j, i) in bateoFiltrado" :key="j.id_jugador">
                  <td class="text-muted small">{{ i + 1 }}</td>
                  <td><span class="fw-semibold">{{ j.jugador }}</span></td>
                  <td class="text-muted small">{{ j.nombre_equipo }}</td>
                  <td class="text-center">{{ j.AB }}</td>
                  <td class="text-center">{{ j.H }}</td>
                  <td class="text-center text-primary">{{ j.HR }}</td>
                  <td class="text-center">{{ j.RBI }}</td>
                  <td class="text-center">
                    <span class="badge" :class="j.AVG >= 0.300 ? 'bg-success-lt' : 'bg-blue-lt'">.{{ avgStr(j.AVG) }}</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-else-if="tab === 'pitcheo'">
        <div class="card shadow-sm">
          <div class="card-header d-flex align-items-center gap-2">
            <IconFlame :size="18" class="text-warning" />
            <span class="fw-bold">Efectividad de Lanzadores</span>
            <span class="ms-auto text-muted small">{{ temporadaNombre }}</span>
            <div class="ms-2 d-flex gap-1">
              <button class="btn btn-icon btn-sm btn-outline-danger" @click="exportPDF('pitcheo')"><IconFileTypePdf :size="16" /></button>
              <button class="btn btn-icon btn-sm btn-outline-success" @click="exportExcel('pitcheo')"><IconFileSpreadsheet :size="16" /></button>
            </div>
          </div>
          <div v-if="cargando" class="text-center py-5"><span class="spinner-border spinner-border-sm text-primary"></span></div>
          <template v-else>
            <div v-if="!pitchers.length" class="text-center py-5 text-muted">
              Sin datos de pitcheo para esta temporada
            </div>
            <template v-else>
              <div v-for="grupo in pitchersPorEquipo" :key="grupo.equipo">
                <div class="px-3 pt-3 pb-1 d-flex align-items-center gap-2">
                  <div class="team-avatar">{{ grupo.equipo?.charAt(0) }}</div>
                  <span class="fw-bold" style="font-size:0.9rem;">{{ grupo.equipo }}</span>
                  <span class="badge bg-blue-lt text-blue ms-1">{{ grupo.jugadores.length }} lanzador(es)</span>
                </div>
                <div class="table-responsive">
                  <table class="table table-vcenter card-table table-sm table-hover">
                    <thead>
                      <tr>
                        <th>#</th>
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
                      <tr v-for="(p, i) in grupo.jugadores" :key="p.id_jugador">
                        <td class="text-muted small">{{ i + 1 }}</td>
                        <td><span class="fw-semibold">{{ p.jugador }}</span></td>
                        <td class="text-center">{{ p.JJ }}</td>
                        <td class="text-center">{{ p.IP }}</td>
                        <td class="text-center">{{ p.ER }}</td>
                        <td class="text-center text-warning fw-bold">{{ p.K }}</td>
                        <td class="text-center text-success fw-bold">{{ p.W }}</td>
                        <td class="text-center text-danger">{{ p.L }}</td>
                        <td class="text-center">
                          <span class="badge fw-bold" :class="eraClass(p.ERA)">{{ p.ERA ?? '—' }}</span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </template>
          </template>
        </div>
      </div>

      <div v-else-if="tab === 'finanzas'">
        <div class="row g-3 mb-4">
          <div class="col-sm-4" v-for="item in summaryFinanzas" :key="item.label">
            <div class="card card-sm shadow-sm">
              <div class="card-body d-flex align-items-center gap-3">
                <span :class="['avatar', item.class]">{{ item.icon }}</span>
                <div>
                  <div class="text-muted small">{{ item.label }}</div>
                  <div class="fw-bold h4 mb-0">{{ formatBs(item.value) }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="row g-3">
          <div class="col-md-6">
            <div class="card shadow-sm">
              <div class="card-header fw-bold">Ingresos por Concepto</div>
              <div class="list-group list-group-flush">
                <div v-for="c in finanzas.ingresos_por_concepto" :key="c.categoria" class="list-group-item d-flex justify-content-between">
                  <span>{{ c.categoria }}</span>
                  <span class="text-success fw-bold">{{ formatBs(c.total) }}</span>
                </div>
              </div>
            </div>
          </div>
          <div class="col-md-6">
            <div class="card shadow-sm">
              <div class="card-header fw-bold">Egresos por Proveedor</div>
              <div class="list-group list-group-flush">
                <div v-for="p in finanzas.egresos_por_proveedor" :key="p.proveedor" class="list-group-item d-flex justify-content-between">
                  <span>{{ p.proveedor }}</span>
                  <span class="text-danger fw-bold">{{ formatBs(p.total) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-else-if="tab === 'rendimiento'">
        <div class="card shadow-sm">
          <div class="card-header d-flex align-items-center gap-2">
            <IconChartDots :size="18" class="text-indigo" />
            <span class="fw-bold">Rendimiento Comparativo</span>
          </div>
          <div class="table-responsive">
            <table class="table table-vcenter card-table">
              <thead>
                <tr>
                  <th>Equipo</th><th class="text-center">PJ</th>
                  <th class="text-center">AVG Colectivo</th><th class="text-center">Errores</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in rendimiento" :key="r.id_equipo">
                  <td><span class="fw-bold">{{ r.nombre_equipo }}</span></td>
                  <td class="text-center">{{ r.partidos }}</td>
                  <td class="text-center">.{{ avgStr(r.AVG_equipo) }}</td>
                  <td class="text-center text-danger">{{ r.errores_totales }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-else-if="tab === 'historial'">
        <div class="card shadow-sm">
          <div class="card-header fw-bold">Censo de Jugadores por Equipo</div>
          <div class="table-responsive">
            <table class="table table-vcenter card-table">
              <thead>
                <tr>
                  <th>Equipo</th><th class="text-center">Total</th>
                  <th class="text-center">Activos</th><th class="text-center">Edad Prom.</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="h in historial" :key="h.id_equipo">
                  <td class="fw-semibold">{{ h.nombre_equipo }}</td>
                  <td class="text-center">{{ h.total_jugadores }}</td>
                  <td class="text-center text-success">{{ h.activos }}</td>
                  <td class="text-center">{{ h.edad_promedio }} años</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'
import {
  IconTrophy, IconChartBar, IconFlame, IconWallet, IconChartDots, IconUsers,
  IconFileTypePdf, IconFileSpreadsheet, IconChartPie, IconChartLine
} from '@tabler/icons-vue'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

const auth = useAuthStore()

// --- ESTADO ---
const tab = ref('posiciones')
const temporadas = ref([])
const temporadaId = ref('')
const cargando = ref(false)
const posiciones = ref([])
const bateadores = ref([])
const pitchers = ref([])
const finanzas = ref({ total_ingresos: 0, total_egresos: 0, balance: 0, ingresos_por_concepto: [], egresos_por_proveedor: [] })
const rendimiento = ref([])
const historial = ref([])
const busquedaBateo = ref('')

// --- COMPUTED ---
const tabs = computed(() => {
  const base = [
    { key: 'posiciones', label: 'Posiciones', icon: IconTrophy },
    { key: 'bateo', label: 'Bateo', icon: IconChartBar },
    { key: 'pitcheo', label: 'Pitcheo', icon: IconFlame },
  ]
  if (auth.puedeFinanzas) base.push({ key: 'finanzas', label: 'Finanzas', icon: IconWallet })
  base.push(
    { key: 'rendimiento', label: 'Rendimiento', icon: IconChartDots },
    { key: 'historial', label: 'Jugadores', icon: IconUsers },
  )
  return base
})

const temporadaNombre = computed(() => {
  const t = temporadas.value.find(x => x.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})

const bateoFiltrado = computed(() =>
  bateadores.value.filter(j =>
    j.jugador?.toLowerCase().includes(busquedaBateo.value.toLowerCase()) ||
    j.nombre_equipo?.toLowerCase().includes(busquedaBateo.value.toLowerCase())
  )
)

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

const summaryFinanzas = computed(() => [
  { label: 'Ingresos', value: finanzas.value.total_ingresos, icon: '📥', class: 'bg-success-lt text-success' },
  { label: 'Egresos', value: finanzas.value.total_egresos, icon: '📤', class: 'bg-danger-lt text-danger' },
  { label: 'Balance', value: finanzas.value.balance, icon: '💰', class: finanzas.value.balance >= 0 ? 'bg-blue-lt text-blue' : 'bg-red-lt text-red' }
])

// --- MÉTODOS ---
function pct(g, j) { return !j ? '.000' : (g / j).toFixed(3).replace('0.', '.') }
function avgStr(avg) { return avg == null ? '000' : Number(avg).toFixed(3).replace('0.', '').padStart(3, '0') }
function formatBs(v) { return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 2 }).format(v || 0) + ' Bs.' }

async function cargar() {
  if (!temporadaId.value) return
  cargando.value = true
  try {
    const params = { temporada: temporadaId.value }
    const [resPos, resBat, resPit, resFin, resRend, resHist] = await Promise.all([
      api.get('/reportes/posiciones', { params }).catch(() => ({ data: [] })),
      api.get('/reportes/promedios-bateo', { params }).catch(() => ({ data: [] })),
      api.get('/reportes/promedios-pitcheo', { params }).catch(() => ({ data: [] })),
      api.get('/reportes/finanzas', { params }).catch(() => ({ data: {} })),
      api.get('/reportes/rendimiento-equipos', { params }).catch(() => ({ data: [] })),
      api.get('/reportes/historial-jugadores', { params }).catch(() => ({ data: [] })),
    ])
    posiciones.value = resPos.data
    bateadores.value = resBat.data
    pitchers.value = resPit.data
    finanzas.value = resFin.data
    rendimiento.value = resRend.data
    historial.value = resHist.data
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

// --- EXPORTACIÓN ---
function exportPDF(tipo) {
  const doc = new jsPDF({ orientation: 'landscape' })
  doc.setFontSize(18); doc.text(`Reporte de ${tipo.toUpperCase()} - Liga Diamante`, 14, 15)
  doc.setFontSize(10); doc.text(temporadaNombre.value, 14, 22)

  if (tipo === 'posiciones') {
    const headers = [['#', 'Equipo', 'JJ', 'G', 'P', 'PCT', 'DIF']]
    const body = posiciones.value.map((e, i) => [i+1, e.nombre_equipo, e.jugados, e.ganados, e.perdidos, pct(e.ganados, e.jugados), e.carreras_favor - e.carreras_contra])
    autoTable(doc, { head: headers, body: body, startY: 30, theme: 'striped' })
  } else if (tipo === 'bateo') {
    const headers = [['Jugador', 'Equipo', 'AB', 'H', 'HR', 'RBI', 'AVG']]
    const body = bateoFiltrado.value.map(j => [j.jugador, j.nombre_equipo, j.AB, j.H, j.HR, j.RBI, '.' + avgStr(j.AVG)])
    autoTable(doc, { head: headers, body: body, startY: 30, theme: 'striped' })
  } else if (tipo === 'pitcheo') {
    let y = 30
    for (const grupo of pitchersPorEquipo.value) {
      doc.setFontSize(10)
      doc.setFont('helvetica', 'bold')
      doc.setTextColor(30, 41, 59)
      doc.text(grupo.equipo, 14, y)
      y += 4
      autoTable(doc, {
        startY: y,
        head: [['Lanzador', 'JJ', 'IP', 'ER', 'K', 'W', 'L', 'ERA']],
        body: grupo.jugadores.map(p => [
          p.jugador, p.JJ, p.IP, p.ER, p.K, p.W, p.L,
          p.ERA !== null && p.ERA !== undefined ? p.ERA.toFixed(2) : '—',
        ]),
        theme: 'striped',
        headStyles: { fillColor: [30, 41, 59], textColor: 255, fontSize: 8 },
        styles: { fontSize: 8 },
        columnStyles: {
          0: { cellWidth: 55 },
          1: { halign: 'center' }, 2: { halign: 'center' }, 3: { halign: 'center' },
          4: { halign: 'center' }, 5: { halign: 'center' }, 6: { halign: 'center' },
          7: { halign: 'center', fontStyle: 'bold' },
        },
      })
      y = doc.lastAutoTable.finalY + 8
    }
  }

  doc.save(`LigaDiamante_${tipo}.pdf`)
}

function exportExcel(tipo) {
  let data = []
  if (tipo === 'posiciones') {
    data = posiciones.value.map(e => ({ Equipo: e.nombre_equipo, JJ: e.jugados, G: e.ganados, P: e.perdidos, PCT: pct(e.ganados, e.jugados) }))
  } else if (tipo === 'bateo') {
    data = bateoFiltrado.value.map(j => ({ Jugador: j.jugador, Equipo: j.nombre_equipo, AVG: '.' + avgStr(j.AVG), HR: j.HR }))
  } else if (tipo === 'pitcheo') {
    for (const grupo of pitchersPorEquipo.value) {
      data.push({ Lanzador: `EQUIPO: ${grupo.equipo}` })
      for (const p of grupo.jugadores) {
        data.push({
          Lanzador: p.jugador, Equipo: p.nombre_equipo,
          JJ: p.JJ, IP: p.IP, ER: p.ER, K: p.K, W: p.W, L: p.L,
          ERA: p.ERA !== null && p.ERA !== undefined ? p.ERA : '',
        })
      }
      data.push({})
    }
  }

  const ws = XLSX.utils.json_to_sheet(data)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, "Datos")
  const buffer = XLSX.write(wb, { bookType: 'xlsx', type: 'array' })
  saveAs(new Blob([buffer]), `LigaDiamante_${tipo}.xlsx`)
}

onMounted(cargarTemporadas)
</script>

<style scoped>
.tab-container {
  background: rgba(0,0,0,0.05);
  border-radius: 12px;
  display: inline-flex !important;
}
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
.table-success-lt {
  background-color: rgba(40, 167, 69, 0.05) !important;
}
</style>