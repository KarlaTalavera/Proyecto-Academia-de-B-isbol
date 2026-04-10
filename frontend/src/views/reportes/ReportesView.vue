<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Reportes</h2>
        <p class="page-subtitle">Estadísticas, finanzas y análisis de la liga</p>
      </div>
      <select v-model="temporadaId" class="form-select form-select-sm" style="max-width:220px;" @change="cargar">
        <option value="">— Seleccionar temporada —</option>
        <option v-for="t in temporadas" :key="t.id_temporada" :value="t.id_temporada">
          {{ t.nombre }} ({{ t.anio }})
        </option>
      </select>
    </div>

    <!-- Tabs -->
    <div class="d-flex gap-1 mb-4 p-1 flex-wrap" style="background:rgba(0,0,0,0.06); border-radius:10px; display:inline-flex!important;">
      <button v-for="t in tabs" :key="t.key"
        class="btn btn-sm"
        :class="tab === t.key ? 'btn-white shadow-sm fw-semibold' : 'btn-ghost-secondary'"
        style="border-radius:8px; font-size:0.82rem;"
        @click="tab = t.key"
      >
        <component :is="t.icon" :size="15" class="me-1" /> {{ t.label }}
      </button>
    </div>

    <!-- Sin temporada -->
    <div v-if="!temporadaId" class="card">
      <div class="card-body text-center py-5 text-muted">
        <IconChartBar :size="40" stroke-width="1.2" class="mb-2" style="opacity:0.3;" />
        <p class="mb-0">Selecciona una temporada para ver los reportes</p>
      </div>
    </div>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- 1. TABLA DE POSICIONES                                 -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <div v-else-if="tab === 'posiciones'">
      <div class="card">
        <div class="card-header d-flex align-items-center gap-2">
          <IconTrophy :size="18" class="text-warning" />
          <span class="fw-bold" style="font-size:0.9rem;">Tabla de Posiciones</span>
          <span v-if="temporadaNombre" class="ms-auto text-muted" style="font-size:0.78rem;">{{ temporadaNombre }}</span>
          <div class="ms-2 d-flex gap-1">
            <button class="btn btn-sm btn-outline-danger" @click="exportPDF('posiciones')" title="Exportar PDF"><IconFileTypePdf :size="16" /></button>
            <button class="btn btn-sm btn-outline-success" @click="exportExcel('posiciones')" title="Exportar Excel"><IconFileSpreadsheet :size="16" /></button>
          </div>
        </div>
        <div v-if="cargando" class="text-center py-5"><span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...</div>
        <div v-else class="table-responsive">
          <table class="table table-vcenter card-table">
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
              <tr v-if="!posiciones.length"><td colspan="10" class="text-center py-5 text-muted">Sin datos</td></tr>
              <tr v-for="(eq, i) in posiciones" :key="eq.id_equipo" :class="i === 0 ? 'table-success-lt' : ''">
                <td>
                  <IconTrophy v-if="i === 0" :size="16" class="text-warning" />
                  <span v-else class="text-muted fw-bold" style="font-size:0.82rem;">{{ i + 1 }}</span>
                </td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <div class="team-avatar" :style="i === 0 ? 'background:linear-gradient(135deg,#f59e0b,#f97316);' : ''">{{ eq.nombre_equipo?.charAt(0) }}</div>
                    <span class="fw-semibold" style="font-size:0.875rem;">{{ eq.nombre_equipo }}</span>
                  </div>
                </td>
                <td class="text-center fw-bold">{{ eq.jugados }}</td>
                <td class="text-center text-success fw-bold">{{ eq.ganados }}</td>
                <td class="text-center text-danger">{{ eq.perdidos }}</td>
                <td class="text-center"><span class="fw-bold" :style="eq.ganados > eq.perdidos ? 'color:#16a34a;' : ''">{{ pct(eq.ganados, eq.jugados) }}</span></td>
                <td class="text-center">{{ eq.carreras_favor }}</td>
                <td class="text-center">{{ eq.carreras_contra }}</td>
                <td class="text-center" :class="(eq.carreras_favor - eq.carreras_contra) > 0 ? 'text-success' : 'text-danger'">{{ eq.carreras_favor - eq.carreras_contra > 0 ? '+' : '' }}{{ eq.carreras_favor - eq.carreras_contra }}</td>
                <td class="text-center text-muted">{{ i === 0 ? '—' : (posiciones[0].ganados - eq.ganados).toFixed(1) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- 2. LÍDERES DE BATEO                                    -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <div v-else-if="tab === 'bateo'">
      <div class="card">
        <div class="card-header d-flex align-items-center gap-2">
          <IconChartBar :size="18" class="text-primary" />
          <span class="fw-bold" style="font-size:0.9rem;">Líderes de Bateo</span>
          <span v-if="temporadaNombre" class="ms-auto text-muted" style="font-size:0.78rem;">{{ temporadaNombre }}</span>
          <div class="ms-2 d-flex gap-1">
            <button class="btn btn-sm btn-outline-danger" @click="exportPDF('bateo')" title="PDF"><IconFileTypePdf :size="16" /></button>
            <button class="btn btn-sm btn-outline-success" @click="exportExcel('bateo')" title="Excel"><IconFileSpreadsheet :size="16" /></button>
          </div>
        </div>
        <div class="card-header"><div class="input-group input-group-sm" style="max-width:240px;"><span class="input-group-text" style="background:transparent;"><IconSearch :size="14" class="text-muted" /></span><input v-model="busquedaBateo" class="form-control" placeholder="Buscar jugador..." style="border-left:none;" /></div></div>
        <div v-if="cargando" class="text-center py-5"><span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...</div>
        <div v-else class="table-responsive">
          <table class="table table-vcenter card-table">
            <thead>
              <tr>
                <th>#</th><th>Jugador</th><th>Equipo</th>
                <th class="text-center">AB</th><th class="text-center">H</th>
                <th class="text-center">2B</th><th class="text-center">3B</th>
                <th class="text-center">HR</th><th class="text-center">R</th>
                <th class="text-center">RBI</th><th class="text-center fw-bold">AVG</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!bateoFiltrado.length"><td colspan="11" class="text-center py-5 text-muted">Sin estadísticas de bateo</td></tr>
              <tr v-for="(j, i) in bateoFiltrado" :key="j.id_jugador">
                <td class="text-muted" style="font-size:0.8rem;">{{ i + 1 }}</td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <div class="team-avatar" style="width:28px;height:28px;font-size:0.7rem;background:linear-gradient(135deg,#6366f1,#8b5cf6);">{{ j.jugador?.charAt(0) }}</div>
                    <span class="fw-semibold" style="font-size:0.875rem;">{{ j.jugador }}</span>
                  </div>
                </td>
                <td class="text-muted" style="font-size:0.82rem;">{{ j.nombre_equipo }}</td>
                <td class="text-center">{{ j.AB }}</td>
                <td class="text-center">{{ j.H }}</td>
                <td class="text-center">{{ j.X2B }}</td>
                <td class="text-center">{{ j.X3B }}</td>
                <td class="text-center fw-semibold text-primary">{{ j.HR }}</td>
                <td class="text-center">{{ j.R }}</td>
                <td class="text-center">{{ j.RBI }}</td>
                <td class="text-center">
                  <span class="badge fw-bold" style="font-size:0.82rem;"
                    :style="j.AVG >= 0.300 ? 'background:rgba(34,197,94,0.15);color:#16a34a;' : j.AVG >= 0.250 ? 'background:rgba(59,130,246,0.12);color:#3b82f6;' : 'background:rgba(100,116,139,0.1);color:#64748b;'">
                    .{{ avgStr(j.AVG) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- 3. LÍDERES DE PITCHEO                                  -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <div v-else-if="tab === 'pitcheo'">
      <div class="card">
        <div class="card-header d-flex align-items-center gap-2">
          <IconFlame :size="18" class="text-orange" />
          <span class="fw-bold" style="font-size:0.9rem;">Líderes de Pitcheo</span>
          <span class="ms-auto text-muted" style="font-size:0.78rem;">{{ temporadaNombre }}</span>
          <div class="ms-2 d-flex gap-1">
            <button class="btn btn-sm btn-outline-danger" @click="exportPDF('pitcheo')" title="PDF"><IconFileTypePdf :size="16" /></button>
            <button class="btn btn-sm btn-outline-success" @click="exportExcel('pitcheo')" title="Excel"><IconFileSpreadsheet :size="16" /></button>
          </div>
        </div>
        <div v-if="cargando" class="text-center py-5"><span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...</div>
        <div v-else class="table-responsive">
          <table class="table table-vcenter card-table">
            <thead>
              <tr>
                <th>#</th><th>Pitcher</th><th>Equipo</th>
                <th class="text-center">JJ</th><th class="text-center">IP</th>
                <th class="text-center">W</th><th class="text-center">L</th>
                <th class="text-center">SV</th><th class="text-center">K</th>
                <th class="text-center">BB</th><th class="text-center">H</th>
                <th class="text-center fw-bold">ERA</th><th class="text-center">WHIP</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!pitchers.length"><td colspan="13" class="text-center py-5 text-muted">Sin estadísticas de pitcheo</td></tr>
              <tr v-for="(p, i) in pitchers" :key="p.id_jugador">
                <td class="text-muted" style="font-size:0.8rem;">{{ i + 1 }}</td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <div class="team-avatar" style="width:28px;height:28px;font-size:0.7rem;background:linear-gradient(135deg,#f97316,#ef4444);">{{ p.jugador?.charAt(0) }}</div>
                    <span class="fw-semibold" style="font-size:0.875rem;">{{ p.jugador }}</span>
                  </div>
                </td>
                <td class="text-muted" style="font-size:0.82rem;">{{ p.nombre_equipo }}</td>
                <td class="text-center">{{ p.JJ }}</td>
                <td class="text-center">{{ p.IP }}</td>
                <td class="text-center text-success fw-bold">{{ p.W }}</td>
                <td class="text-center text-danger">{{ p.L }}</td>
                <td class="text-center fw-semibold text-primary">{{ p.SV }}</td>
                <td class="text-center">{{ p.K }}</td>
                <td class="text-center">{{ p.BB }}</td>
                <td class="text-center">{{ p.H }}</td>
                <td class="text-center">
                  <span class="badge fw-bold" style="font-size:0.82rem;"
                    :style="p.ERA <= 2.50 ? 'background:rgba(34,197,94,0.15);color:#16a34a;' : p.ERA <= 4.00 ? 'background:rgba(59,130,246,0.12);color:#3b82f6;' : 'background:rgba(239,68,68,0.12);color:#ef4444;'">
                    {{ Number(p.ERA).toFixed(2) }}
                  </span>
                </td>
                <td class="text-center">{{ Number(p.WHIP).toFixed(2) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- 4. BALANCE FINANCIERO                                  -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <div v-else-if="tab === 'finanzas'">
      <!-- KPI Cards -->
      <div class="row g-3 mb-4">
        <div class="col-sm-4">
          <div class="card card-sm">
            <div class="card-body">
              <div class="d-flex align-items-center gap-3">
                <span class="avatar bg-success-lt text-success" style="font-size:1.2rem;">📥</span>
                <div>
                  <div class="fw-medium text-muted" style="font-size:0.78rem;">Total Ingresos</div>
                  <div class="fw-bold text-success" style="font-size:1.1rem;">{{ formatBs(finanzas.total_ingresos) }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="col-sm-4">
          <div class="card card-sm">
            <div class="card-body">
              <div class="d-flex align-items-center gap-3">
                <span class="avatar bg-danger-lt text-danger" style="font-size:1.2rem;">📤</span>
                <div>
                  <div class="fw-medium text-muted" style="font-size:0.78rem;">Total Egresos</div>
                  <div class="fw-bold text-danger" style="font-size:1.1rem;">{{ formatBs(finanzas.total_egresos) }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="col-sm-4">
          <div class="card card-sm">
            <div class="card-body">
              <div class="d-flex align-items-center gap-3">
                <span class="avatar" :class="finanzas.balance >= 0 ? 'bg-blue-lt text-blue' : 'bg-red-lt text-red'" style="font-size:1.2rem;">💰</span>
                <div>
                  <div class="fw-medium text-muted" style="font-size:0.78rem;">Balance Neto</div>
                  <div class="fw-bold" :class="finanzas.balance >= 0 ? 'text-blue' : 'text-danger'" style="font-size:1.1rem;">{{ formatBs(finanzas.balance) }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="row g-3">
        <!-- Ingresos por concepto -->
        <div class="col-md-6">
          <div class="card">
            <div class="card-header d-flex align-items-center gap-2">
              <IconArrowUpRight :size="16" class="text-success" />
              <span class="fw-bold" style="font-size:0.9rem;">Ingresos por Concepto</span>
              <div class="ms-auto d-flex gap-1">
                <button class="btn btn-sm btn-outline-danger" @click="exportPDF('finanzas')" title="PDF"><IconFileTypePdf :size="16" /></button>
                <button class="btn btn-sm btn-outline-success" @click="exportExcel('finanzas')" title="Excel"><IconFileSpreadsheet :size="16" /></button>
              </div>
            </div>
            <div class="card-body p-0">
              <div v-if="!finanzas.ingresos_por_concepto?.length" class="text-center py-4 text-muted">Sin datos</div>
              <div v-else class="list-group list-group-flush">
                <div v-for="(c, i) in finanzas.ingresos_por_concepto" :key="i" class="list-group-item d-flex justify-content-between align-items-center px-4">
                  <span>{{ c.categoria }}</span>
                  <span class="fw-bold text-success">{{ formatBs(c.total) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- Egresos por proveedor -->
        <div class="col-md-6">
          <div class="card">
            <div class="card-header d-flex align-items-center gap-2">
              <IconArrowDownRight :size="16" class="text-danger" />
              <span class="fw-bold" style="font-size:0.9rem;">Egresos por Proveedor</span>
            </div>
            <div class="card-body p-0">
              <div v-if="!finanzas.egresos_por_proveedor?.length" class="text-center py-4 text-muted">Sin datos</div>
              <div v-else class="list-group list-group-flush">
                <div v-for="(p, i) in finanzas.egresos_por_proveedor" :key="i" class="list-group-item d-flex justify-content-between align-items-center px-4">
                  <span>{{ p.proveedor }}</span>
                  <span class="fw-bold text-danger">{{ formatBs(p.total) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- 5. RENDIMIENTO POR EQUIPO                              -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <div v-else-if="tab === 'rendimiento'">
      <div class="card">
        <div class="card-header d-flex align-items-center gap-2">
          <IconChartDots :size="18" class="text-indigo" />
          <span class="fw-bold" style="font-size:0.9rem;">Rendimiento Comparativo por Equipo</span>
          <span class="ms-auto text-muted" style="font-size:0.78rem;">{{ temporadaNombre }}</span>
          <div class="ms-2 d-flex gap-1">
            <button class="btn btn-sm btn-outline-danger" @click="exportPDF('rendimiento')" title="PDF"><IconFileTypePdf :size="16" /></button>
            <button class="btn btn-sm btn-outline-success" @click="exportExcel('rendimiento')" title="Excel"><IconFileSpreadsheet :size="16" /></button>
          </div>
        </div>
        <div v-if="cargando" class="text-center py-5"><span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...</div>
        <div v-else class="table-responsive">
          <table class="table table-vcenter card-table">
            <thead>
              <tr>
                <th>#</th><th>Equipo</th><th class="text-center">PJ</th>
                <th class="text-center">AB</th><th class="text-center">H</th>
                <th class="text-center">HR</th><th class="text-center">R</th>
                <th class="text-center">RBI</th><th class="text-center fw-bold">AVG</th>
                <th class="text-center">E</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!rendimiento.length"><td colspan="10" class="text-center py-5 text-muted">Sin datos</td></tr>
              <tr v-for="(r, i) in rendimiento" :key="r.id_equipo">
                <td class="text-muted">{{ i + 1 }}</td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <div class="team-avatar">{{ r.nombre_equipo?.charAt(0) }}</div>
                    <span class="fw-semibold">{{ r.nombre_equipo }}</span>
                  </div>
                </td>
                <td class="text-center">{{ r.partidos }}</td>
                <td class="text-center">{{ r.AB }}</td>
                <td class="text-center">{{ r.H }}</td>
                <td class="text-center fw-semibold text-primary">{{ r.HR }}</td>
                <td class="text-center">{{ r.R }}</td>
                <td class="text-center">{{ r.RBI }}</td>
                <td class="text-center">
                  <span class="badge fw-bold" style="font-size:0.82rem;"
                    :style="r.AVG_equipo >= 0.280 ? 'background:rgba(34,197,94,0.15);color:#16a34a;' : 'background:rgba(100,116,139,0.1);color:#64748b;'">
                    .{{ avgStr(r.AVG_equipo) }}
                  </span>
                </td>
                <td class="text-center text-danger">{{ r.errores_totales }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- 6. HISTORIAL DE JUGADORES                              -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <div v-else-if="tab === 'historial'">
      <div class="card">
        <div class="card-header d-flex align-items-center gap-2">
          <IconUsers :size="18" class="text-teal" />
          <span class="fw-bold" style="font-size:0.9rem;">Historial y Asistencia de Jugadores</span>
          <span class="ms-auto text-muted" style="font-size:0.78rem;">{{ temporadaNombre }}</span>
          <div class="ms-2 d-flex gap-1">
            <button class="btn btn-sm btn-outline-danger" @click="exportPDF('historial')" title="PDF"><IconFileTypePdf :size="16" /></button>
            <button class="btn btn-sm btn-outline-success" @click="exportExcel('historial')" title="Excel"><IconFileSpreadsheet :size="16" /></button>
          </div>
        </div>
        <div v-if="cargando" class="text-center py-5"><span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...</div>
        <div v-else class="table-responsive">
          <table class="table table-vcenter card-table">
            <thead>
              <tr>
                <th>#</th><th>Equipo</th>
                <th class="text-center">Total Jugadores</th>
                <th class="text-center">Activos</th>
                <th class="text-center">Inactivos</th>
                <th class="text-center">Edad Promedio</th>
                <th class="text-center">Con Participación</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!historial.length"><td colspan="7" class="text-center py-5 text-muted">Sin datos</td></tr>
              <tr v-for="(h, i) in historial" :key="h.id_equipo">
                <td class="text-muted">{{ i + 1 }}</td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <div class="team-avatar">{{ h.nombre_equipo?.charAt(0) }}</div>
                    <span class="fw-semibold">{{ h.nombre_equipo }}</span>
                  </div>
                </td>
                <td class="text-center fw-bold">{{ h.total_jugadores }}</td>
                <td class="text-center text-success">{{ h.activos }}</td>
                <td class="text-center text-danger">{{ h.inactivos }}</td>
                <td class="text-center">{{ h.edad_promedio }} años</td>
                <td class="text-center">
                  <span class="badge" :style="h.jugadores_con_participacion >= h.total_jugadores * 0.7 ? 'background:rgba(34,197,94,0.15);color:#16a34a;' : 'background:rgba(245,158,11,0.15);color:#f59e0b;'">
                    {{ h.jugadores_con_participacion }} / {{ h.total_jugadores }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
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
  IconTrophy, IconChartBar, IconSearch, IconFlame, IconChartDots, IconUsers,
  IconFileTypePdf, IconFileSpreadsheet, IconArrowUpRight, IconArrowDownRight, IconWallet,
} from '@tabler/icons-vue'
import { jsPDF } from 'jspdf'
import autoTable from 'jspdf-autotable'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

const auth = useAuthStore()

const tabs = computed(() => {
  const base = [
    { key: 'posiciones',  label: 'Posiciones',  icon: IconTrophy },
    { key: 'bateo',       label: 'Bateo',       icon: IconChartBar },
    { key: 'pitcheo',     label: 'Pitcheo',     icon: IconFlame },
  ]
  if (auth.puedeFinanzas) base.push({ key: 'finanzas', label: 'Finanzas', icon: IconWallet })
  base.push(
    { key: 'rendimiento', label: 'Rendimiento', icon: IconChartDots },
    { key: 'historial',   label: 'Jugadores',   icon: IconUsers },
  )
  return base
})

const tab           = ref('posiciones')
const temporadas    = ref([])
const temporadaId   = ref('')
const cargando      = ref(false)
const posiciones    = ref([])
const bateadores    = ref([])
const pitchers      = ref([])
const finanzas      = ref({})
const rendimiento   = ref([])
const historial     = ref([])
const busquedaBateo = ref('')

const temporadaNombre = computed(() => {
  const t = temporadas.value.find(t => t.id_temporada == temporadaId.value)
  return t ? `${t.nombre} (${t.anio})` : ''
})

const bateoFiltrado = computed(() =>
  bateadores.value.filter(j =>
    j.jugador?.toLowerCase().includes(busquedaBateo.value.toLowerCase()) ||
    j.nombre_equipo?.toLowerCase().includes(busquedaBateo.value.toLowerCase())
  )
)

function pct(g, j) { return !j ? '.000' : (g / j).toFixed(3).replace('0.', '.') }
function avgStr(avg) { return avg == null ? '000' : Number(avg).toFixed(3).replace('0.', '').padStart(3, '0') }
function formatBs(v) { return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(v || 0) + ' Bs.' }

async function cargar() {
  if (!temporadaId.value) return
  cargando.value = true
  try {
    const params = { temporada: temporadaId.value }
    const fallback = (v = []) => () => ({ data: v })
    const [resPos, resBat, resPit, resFin, resRend, resHist] = await Promise.all([
      api.get('/reportes/posiciones', { params }).catch(fallback()),
      api.get('/reportes/promedios-bateo', { params }).catch(fallback()),
      api.get('/reportes/promedios-pitcheo', { params }).catch(fallback()),
      api.get('/reportes/finanzas', { params }).catch(fallback({})),
      api.get('/reportes/rendimiento-equipos', { params }).catch(fallback()),
      api.get('/reportes/historial-jugadores', { params }).catch(fallback()),
    ])
    posiciones.value  = resPos.data
    bateadores.value  = resBat.data
    pitchers.value    = resPit.data
    finanzas.value    = resFin.data
    rendimiento.value = resRend.data
    historial.value   = resHist.data
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

// ═══════════════════════════════════════════════════════════
// EXPORT PDF
// ═══════════════════════════════════════════════════════════
function exportPDF(tipo) {
  const doc = new jsPDF({ orientation: tipo === 'finanzas' ? 'portrait' : 'landscape' })
  const pageW = doc.internal.pageSize.getWidth()

  // Header
  doc.setFillColor(30, 41, 59)
  doc.rect(0, 0, pageW, 28, 'F')
  doc.setTextColor(255, 255, 255)
  doc.setFontSize(16)
  doc.setFont('helvetica', 'bold')
  doc.text('Liga Diamante', 14, 12)
  doc.setFontSize(10)
  doc.setFont('helvetica', 'normal')
  doc.text(temporadaNombre.value, 14, 20)
  doc.setTextColor(0, 0, 0)

  const startY = 36

  if (tipo === 'posiciones') {
    doc.setFontSize(13)
    doc.setFont('helvetica', 'bold')
    doc.text('Tabla de Posiciones', 14, startY)
    autoTable(doc, {
      startY: startY + 4,
      head: [['#', 'Equipo', 'JJ', 'G', 'P', 'PCT', 'CF', 'CC', 'DIF', 'JD']],
      body: posiciones.value.map((eq, i) => [
        i + 1, eq.nombre_equipo, eq.jugados, eq.ganados, eq.perdidos,
        pct(eq.ganados, eq.jugados),
        eq.carreras_favor, eq.carreras_contra,
        eq.carreras_favor - eq.carreras_contra,
        i === 0 ? '—' : (posiciones.value[0].ganados - eq.ganados).toFixed(1),
      ]),
      theme: 'grid',
      headStyles: { fillColor: [30, 41, 59], textColor: 255, fontStyle: 'bold', halign: 'center' },
      columnStyles: { 0: { halign: 'center' }, 2: { halign: 'center' }, 3: { halign: 'center' }, 4: { halign: 'center' }, 5: { halign: 'center' }, 6: { halign: 'center' }, 7: { halign: 'center' }, 8: { halign: 'center' }, 9: { halign: 'center' } },
      styles: { fontSize: 9, cellPadding: 3 },
      alternateRowStyles: { fillColor: [245, 247, 250] },
    })
  }

  if (tipo === 'bateo') {
    doc.setFontSize(13)
    doc.setFont('helvetica', 'bold')
    doc.text('Líderes de Bateo', 14, startY)
    autoTable(doc, {
      startY: startY + 4,
      head: [['#', 'Jugador', 'Equipo', 'AB', 'H', '2B', '3B', 'HR', 'R', 'RBI', 'AVG']],
      body: bateoFiltrado.value.map((j, i) => [
        i + 1, j.jugador, j.nombre_equipo, j.AB, j.H, j.X2B, j.X3B, j.HR, j.R, j.RBI,
        '.' + avgStr(j.AVG),
      ]),
      theme: 'grid',
      headStyles: { fillColor: [30, 41, 59], textColor: 255, fontStyle: 'bold', halign: 'center' },
      styles: { fontSize: 9, cellPadding: 3 },
      alternateRowStyles: { fillColor: [245, 247, 250] },
    })
  }

  if (tipo === 'pitcheo') {
    doc.setFontSize(13)
    doc.setFont('helvetica', 'bold')
    doc.text('Líderes de Pitcheo', 14, startY)
    autoTable(doc, {
      startY: startY + 4,
      head: [['#', 'Pitcher', 'Equipo', 'JJ', 'IP', 'W', 'L', 'SV', 'K', 'BB', 'H', 'ERA', 'WHIP']],
      body: pitchers.value.map((p, i) => [
        i + 1, p.jugador, p.nombre_equipo, p.JJ, p.IP, p.W, p.L, p.SV, p.K, p.BB, p.H,
        Number(p.ERA).toFixed(2), Number(p.WHIP).toFixed(2),
      ]),
      theme: 'grid',
      headStyles: { fillColor: [30, 41, 59], textColor: 255, fontStyle: 'bold', halign: 'center' },
      styles: { fontSize: 9, cellPadding: 3 },
      alternateRowStyles: { fillColor: [245, 247, 250] },
    })
  }

  if (tipo === 'finanzas') {
    doc.setFontSize(13)
    doc.setFont('helvetica', 'bold')
    doc.text('Balance Financiero', 14, startY)

    doc.setFontSize(10)
    doc.setFont('helvetica', 'normal')
    const y = startY + 10
    doc.text(`Total Ingresos: ${formatBs(finanzas.value.total_ingresos)}`, 14, y)
    doc.text(`Total Egresos:  ${formatBs(finanzas.value.total_egresos)}`, 14, y + 6)
    doc.setFont('helvetica', 'bold')
    doc.text(`Balance Neto:   ${formatBs(finanzas.value.balance)}`, 14, y + 12)

    if (finanzas.value.ingresos_por_concepto?.length) {
      autoTable(doc, {
        startY: y + 20,
        head: [['Concepto', 'Monto (Bs.)']],
        body: finanzas.value.ingresos_por_concepto.map(c => [c.categoria, formatBs(c.total)]),
        theme: 'grid',
        headStyles: { fillColor: [34, 197, 94], textColor: 255, fontStyle: 'bold' },
        styles: { fontSize: 9, cellPadding: 3 },
      })
    }
    if (finanzas.value.egresos_por_proveedor?.length) {
      autoTable(doc, {
        head: [['Proveedor', 'Monto (Bs.)']],
        body: finanzas.value.egresos_por_proveedor.map(p => [p.proveedor, formatBs(p.total)]),
        theme: 'grid',
        headStyles: { fillColor: [239, 68, 68], textColor: 255, fontStyle: 'bold' },
        styles: { fontSize: 9, cellPadding: 3 },
      })
    }
  }

  if (tipo === 'rendimiento') {
    doc.setFontSize(13)
    doc.setFont('helvetica', 'bold')
    doc.text('Rendimiento Comparativo por Equipo', 14, startY)
    autoTable(doc, {
      startY: startY + 4,
      head: [['#', 'Equipo', 'PJ', 'AB', 'H', 'HR', 'R', 'RBI', 'AVG', 'E']],
      body: rendimiento.value.map((r, i) => [
        i + 1, r.nombre_equipo, r.partidos, r.AB, r.H, r.HR, r.R, r.RBI,
        '.' + avgStr(r.AVG_equipo), r.errores_totales,
      ]),
      theme: 'grid',
      headStyles: { fillColor: [30, 41, 59], textColor: 255, fontStyle: 'bold', halign: 'center' },
      styles: { fontSize: 9, cellPadding: 3 },
      alternateRowStyles: { fillColor: [245, 247, 250] },
    })
  }

  if (tipo === 'historial') {
    doc.setFontSize(13)
    doc.setFont('helvetica', 'bold')
    doc.text('Historial y Asistencia de Jugadores', 14, startY)
    autoTable(doc, {
      startY: startY + 4,
      head: [['#', 'Equipo', 'Total', 'Activos', 'Inactivos', 'Edad Prom.', 'Con Participación']],
      body: historial.value.map((h, i) => [
        i + 1, h.nombre_equipo, h.total_jugadores, h.activos, h.inactivos,
        h.edad_promedio + ' años', `${h.jugadores_con_participacion} / ${h.total_jugadores}`,
      ]),
      theme: 'grid',
      headStyles: { fillColor: [30, 41, 59], textColor: 255, fontStyle: 'bold', halign: 'center' },
      styles: { fontSize: 9, cellPadding: 3 },
      alternateRowStyles: { fillColor: [245, 247, 250] },
    })
  }

  // Footer
  const pageCount = doc.internal.getNumberOfPages()
  for (let i = 1; i <= pageCount; i++) {
    doc.setPage(i)
    const pageH = doc.internal.pageSize.getHeight()
    doc.setFontSize(8)
    doc.setTextColor(150)
    doc.text(`Liga Diamante — ${temporadaNombre.value}`, 14, pageH - 8)
    doc.text(`Página ${i} de ${pageCount}`, pageW - 40, pageH - 8)
  }

  doc.save(`reporte-${tipo}-${temporadaNombre.value.replace(/\s+/g, '_')}.pdf`)
}

// ════════════════════════════════════════════════════════���══
// EXPORT EXCEL
// ═══════════════════════════════════════════════════════════
function exportExcel(tipo) {
  let data = []
  let sheetName = ''

  if (tipo === 'posiciones') {
    sheetName = 'Posiciones'
    data = posiciones.value.map((eq, i) => ({
      '#': i + 1, 'Equipo': eq.nombre_equipo, 'JJ': eq.jugados,
      'G': eq.ganados, 'P': eq.perdidos, 'PCT': pct(eq.ganados, eq.jugados),
      'CF': eq.carreras_favor, 'CC': eq.carreras_contra,
      'DIF': eq.carreras_favor - eq.carreras_contra,
      'JD': i === 0 ? '—' : (posiciones.value[0].ganados - eq.ganados).toFixed(1),
    }))
  }

  if (tipo === 'bateo') {
    sheetName = 'Bateo'
    data = bateoFiltrado.value.map((j, i) => ({
      '#': i + 1, 'Jugador': j.jugador, 'Equipo': j.nombre_equipo,
      'AB': j.AB, 'H': j.H, '2B': j.X2B, '3B': j.X3B, 'HR': j.HR,
      'R': j.R, 'RBI': j.RBI, 'AVG': Number(j.AVG).toFixed(3),
    }))
  }

  if (tipo === 'pitcheo') {
    sheetName = 'Pitcheo'
    data = pitchers.value.map((p, i) => ({
      '#': i + 1, 'Pitcher': p.jugador, 'Equipo': p.nombre_equipo,
      'JJ': p.JJ, 'IP': p.IP, 'W': p.W, 'L': p.L, 'SV': p.SV,
      'K': p.K, 'BB': p.BB, 'H': p.H,
      'ERA': Number(p.ERA).toFixed(2), 'WHIP': Number(p.WHIP).toFixed(2),
    }))
  }

  if (tipo === 'finanzas') {
    sheetName = 'Finanzas'
    const resumen = [
      { 'Concepto': 'Total Ingresos', 'Monto (Bs.)': finanzas.value.total_ingresos },
      { 'Concepto': 'Total Egresos', 'Monto (Bs.)': finanzas.value.total_egresos },
      { 'Concepto': 'Balance Neto', 'Monto (Bs.)': finanzas.value.balance },
      { 'Concepto': '', 'Monto (Bs.)': '' },
      { 'Concepto': '--- INGRESOS POR CONCEPTO ---', 'Monto (Bs.)': '' },
    ]
    ;(finanzas.value.ingresos_por_concepto || []).forEach(c => {
      resumen.push({ 'Concepto': c.categoria, 'Monto (Bs.)': c.total })
    })
    resumen.push({ 'Concepto': '', 'Monto (Bs.)': '' })
    resumen.push({ 'Concepto': '--- EGRESOS POR PROVEEDOR ---', 'Monto (Bs.)': '' })
    ;(finanzas.value.egresos_por_proveedor || []).forEach(p => {
      resumen.push({ 'Concepto': p.proveedor, 'Monto (Bs.)': p.total })
    })
    data = resumen
  }

  if (tipo === 'rendimiento') {
    sheetName = 'Rendimiento'
    data = rendimiento.value.map((r, i) => ({
      '#': i + 1, 'Equipo': r.nombre_equipo, 'PJ': r.partidos,
      'AB': r.AB, 'H': r.H, 'HR': r.HR, 'R': r.R, 'RBI': r.RBI,
      'AVG': Number(r.AVG_equipo).toFixed(3), 'Errores': r.errores_totales,
    }))
  }

  if (tipo === 'historial') {
    sheetName = 'Jugadores'
    data = historial.value.map((h, i) => ({
      '#': i + 1, 'Equipo': h.nombre_equipo,
      'Total Jugadores': h.total_jugadores, 'Activos': h.activos,
      'Inactivos': h.inactivos, 'Edad Promedio': h.edad_promedio,
      'Con Participación': h.jugadores_con_participacion,
    }))
  }

  const ws = XLSX.utils.json_to_sheet(data)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, sheetName)
  const buf = XLSX.write(wb, { type: 'array', bookType: 'xlsx' })
  saveAs(new Blob([buf]), `reporte-${tipo}-${temporadaNombre.value.replace(/\s+/g, '_')}.xlsx`)
}

onMounted(cargarTemporadas)
</script>
