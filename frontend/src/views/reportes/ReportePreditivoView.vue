<template>
  <div class="pred-root">

    <!-- ── Header (sin select de temporada) ──────────────────────────────── -->
    <div class="pred-header">
      <div class="pred-header-left">
        <div class="pred-header-icon">
          <IconChartDots3 :size="22" />
        </div>
        <div>
          <h2 class="pred-title">Reportes Predictivos</h2>
          <p class="pred-subtitle">Análisis de tendencias y proyecciones</p>
        </div>
      </div>
    </div>

    <!-- ── Sin temporada ──────────────────────────────────────────────────── -->
    <div v-if="!temporadaId" class="pred-empty">
      <IconChartDots3 :size="48" stroke-width="1" class="pred-empty-icon" />
      <p>Selecciona una temporada en el selector superior para activar los modelos predictivos</p>
    </div>

    <template v-else>
      <!-- ── Tabs ─────────────────────────────────────────────────────────── -->
      <div class="pred-tabs">
        <button v-for="t in tabs" :key="t.key"
          class="pred-tab-btn"
          :class="{ 'pred-tab-active': tab === t.key }"
          @click="tab = t.key"
        >
          <component :is="t.icon" :size="15" />
          {{ t.label }}
        </button>
      </div>

      <!-- ══════════════════════════════════════════════════════════════════
           TAB 1 — PROYECCIÓN FINANCIERA
      ════════════════════════════════════════════════════════════════════ -->
      <div v-if="tab === 'finanzas'">
        <div class="pred-controls">
          <label class="pred-control-label">
            Meses a proyectar
            <select v-model="mesesProyeccion" class="pred-select-sm" @change="cargarFinanzas">
              <option value="2">2 meses</option>
              <option value="3">3 meses</option>
              <option value="6">6 meses</option>
            </select>
          </label>
        </div>

        <div v-if="cargando.finanzas" class="pred-spinner-wrap">
          <span class="pred-spinner"></span> Calculando proyección…
        </div>

        <template v-else-if="proyFinanzas.historico?.length">
          <!-- KPI pills -->
          <div class="pred-kpi-row">
            <div class="pred-kpi" :class="proyFinanzas.tendencia?.ingresos === 'creciente' ? 'pred-kpi-green' : 'pred-kpi-red'">
              <div class="pred-kpi-label">Tendencia Ingresos</div>
              <div class="pred-kpi-val">
                {{ proyFinanzas.tendencia?.ingresos === 'creciente' ? '▲ Creciente' : '▼ Decreciente' }}
              </div>
              <div class="pred-kpi-sub">{{ proyFinanzas.tendencia?.pendiente_ingresos?.toLocaleString('es-VE') }} Bs/mes</div>
            </div>
            <div class="pred-kpi" :class="proyFinanzas.tendencia?.egresos === 'creciente' ? 'pred-kpi-red' : 'pred-kpi-green'">
              <div class="pred-kpi-label">Tendencia Egresos</div>
              <div class="pred-kpi-val">
                {{ proyFinanzas.tendencia?.egresos === 'creciente' ? '▲ Creciente' : '▼ Decreciente' }}
              </div>
              <div class="pred-kpi-sub">{{ proyFinanzas.tendencia?.pendiente_egresos?.toLocaleString('es-VE') }} Bs/mes</div>
            </div>
            <div class="pred-kpi pred-kpi-blue">
              <div class="pred-kpi-label">Cambio ingresos temporada</div>
              <div class="pred-kpi-val">{{ proyFinanzas.tendencia?.cambio_ingresos_pct }}%</div>
              <div class="pred-kpi-sub">desde el inicio</div>
            </div>
            <div class="pred-kpi pred-kpi-yellow">
              <div class="pred-kpi-label">Meses proyectados</div>
              <div class="pred-kpi-val">{{ proyFinanzas.proyeccion?.length || 0 }}</div>
              <div class="pred-kpi-sub">basado en reg. lineal</div>
            </div>
          </div>

          <!-- Tabla combinada real + proyección -->
          <div class="pred-card">
            <div class="pred-card-header">
              <IconTable :size="15" />
              Histórico + Proyección &nbsp;
              <span class="pred-badge-proyeccion">EST</span> = meses estimados por modelo
            </div>
            <div class="pred-table-wrap">
              <table class="pred-table">
                <thead>
                  <tr>
                    <th>Período</th>
                    <th class="text-end">Ingresos (Bs.)</th>
                    <th class="text-end">Egresos (Bs.)</th>
                    <th class="text-end">Balance</th>
                    <th class="text-center">Estado</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="row in tablaFinanzasCombinada" :key="row.periodo"
                      :class="row.es_proyeccion ? 'pred-row-proj' : ''">
                    <td>
                      <span class="pred-badge-proyeccion" v-if="row.es_proyeccion">EST</span>
                      {{ row.etiqueta }}
                    </td>
                    <td class="text-end text-success fw-semibold">{{ formatBs(row.total_ingresos) }}</td>
                    <td class="text-end text-danger fw-semibold">{{ formatBs(row.total_egresos) }}</td>
                    <td class="text-end fw-bold" :class="row.balance >= 0 ? 'text-success' : 'text-danger'">
                      {{ row.balance >= 0 ? '+' : '' }}{{ formatBs(row.balance) }}
                    </td>
                    <td class="text-center">
                      <span class="pred-pill" :class="row.balance >= 0 ? 'pred-pill-green' : 'pred-pill-red'">
                        {{ row.balance >= 0 ? 'Superávit' : 'Déficit' }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>

        <div v-else-if="!cargando.finanzas" class="pred-no-data">
          No hay suficientes datos financieros para proyectar. Se necesitan al menos 2 meses de registros.
        </div>
      </div>

      <!-- ══════════════════════════════════════════════════════════════════
           TAB 2 — PREDICCIÓN DE JUGADORES
      ════════════════════════════════════════════════════════════════════ -->
      <div v-if="tab === 'jugadores'">
        <div class="pred-controls">
          <div class="pred-toggle">
            <button :class="['pred-toggle-btn', tipoJugador === 'bateadores' ? 'pred-toggle-active' : '']"
              @click="tipoJugador = 'bateadores'; cargarJugadores()">
              🏏 Bateadores
            </button>
            <button :class="['pred-toggle-btn', tipoJugador === 'pitchers' ? 'pred-toggle-active' : '']"
              @click="tipoJugador = 'pitchers'; cargarJugadores()">
              ⚾ Pitchers
            </button>
          </div>
        </div>

        <div v-if="cargando.jugadores" class="pred-spinner-wrap">
          <span class="pred-spinner"></span> Analizando trayectorias…
        </div>

        <template v-else-if="predJugadores.length">
          <div class="pred-card">
            <div class="pred-card-header">
              <IconUsers :size="15" />
              {{ tipoJugador === 'bateadores' ? 'Proyección de AVE por bateador' : 'Proyección de ERA por pitcher' }}
            </div>
            <div class="pred-table-wrap">
              <table class="pred-table">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Jugador</th>
                    <th>Equipo</th>
                    <th class="text-center">Partidos</th>
                    <th class="text-center" v-if="tipoJugador === 'bateadores'">AVE Acum.</th>
                    <th class="text-center" v-if="tipoJugador === 'bateadores'">AVE Proyectado</th>
                    <th class="text-center" v-if="tipoJugador === 'pitchers'">ERA Acum.</th>
                    <th class="text-center" v-if="tipoJugador === 'pitchers'">ERA Proyectada</th>
                    <th class="text-center">Tendencia</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(jug, idx) in predJugadores" :key="jug.id_jugador">
                    <td class="pred-num">{{ idx + 1 }}</td>
                    <td class="fw-semibold">{{ jug.jugador }}</td>
                    <td class="text-muted small">{{ jug.nombre_equipo }}</td>
                    <td class="text-center">{{ jug.partidos_jugados }}</td>
                    <td class="text-center fw-bold" v-if="tipoJugador === 'bateadores'">{{ jug.ave_acumulado?.toFixed(3) }}</td>
                    <td class="text-center" v-if="tipoJugador === 'bateadores'">
                      <span class="pred-proj-val">{{ jug.ave_proyectado?.toFixed(3) }}</span>
                    </td>
                    <td class="text-center fw-bold" v-if="tipoJugador === 'pitchers'">{{ jug.era_acumulada?.toFixed(2) }}</td>
                    <td class="text-center" v-if="tipoJugador === 'pitchers'">
                      <span class="pred-proj-val">{{ jug.era_proyectada?.toFixed(2) }}</span>
                    </td>
                    <td class="text-center">
                      <span class="pred-pill pred-pill-sm"
                        :class="{
                          'pred-pill-green': jug.tendencia === 'subiendo' || jug.tendencia === 'mejorando',
                          'pred-pill-red':   jug.tendencia === 'bajando'  || jug.tendencia === 'empeorando',
                          'pred-pill-gray':  jug.tendencia === 'estable',
                        }">
                        {{ tendenciaLabel(jug.tendencia) }}
                        ({{ jug.tendencia_pct > 0 ? '+' : '' }}{{ jug.tendencia_pct }}%)
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>

        <div v-else-if="!cargando.jugadores" class="pred-no-data">
          No hay datos suficientes para generar predicciones. Se necesitan al menos 2 partidos por jugador.
        </div>
      </div>

      <!-- ══════════════════════════════════════════════════════════════════
           TAB 3 — PREDICCIÓN DE ASISTENCIA
      ════════════════════════════════════════════════════════════════════ -->
      <div v-if="tab === 'asistencia'">
        <div v-if="cargando.asistencia" class="pred-spinner-wrap">
          <span class="pred-spinner"></span> Proyectando asistencia…
        </div>

        <template v-else-if="predAsistencia.length">
          <div class="pred-card">
            <div class="pred-card-header">
              <IconUsers :size="15" />
              Proyección de asistencia por equipo local
            </div>
            <div class="pred-table-wrap">
              <table class="pred-table">
                <thead>
                  <tr>
                    <th>Equipo Local</th>
                    <th class="text-center">Partidos</th>
                    <th class="text-center">Prom. Asistencia</th>
                    <th class="text-center">Máx.</th>
                    <th class="text-center">Prom. Móvil (3)</th>
                    <th class="text-center">Próximo Partido (Est.)</th>
                    <th class="text-center">% Ocupación Est.</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="eq in predAsistencia" :key="eq.id_equipo">
                    <td class="fw-semibold">{{ eq.equipo_casa }}</td>
                    <td class="text-center">{{ eq.partidos_analizados }}</td>
                    <td class="text-center">{{ eq.asistencia_promedio?.toLocaleString('es-VE') }}</td>
                    <td class="text-center">{{ eq.asistencia_max?.toLocaleString('es-VE') }}</td>
                    <td class="text-center">{{ eq.promedio_movil_3?.toLocaleString('es-VE') }}</td>
                    <td class="text-center">
                      <span class="pred-proj-val">{{ eq.asistencia_proyectada?.toLocaleString('es-VE') }}</span>
                    </td>
                    <td class="text-center">
                      <span v-if="eq.pct_ocupacion_proyectado !== null"
                        class="pred-pill pred-pill-sm"
                        :class="eq.pct_ocupacion_proyectado >= 70 ? 'pred-pill-green' : eq.pct_ocupacion_proyectado >= 40 ? 'pred-pill-yellow' : 'pred-pill-red'">
                        {{ eq.pct_ocupacion_proyectado }}%
                      </span>
                      <span v-else class="text-muted small">—</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>

        <div v-else-if="!cargando.asistencia" class="pred-no-data">
          No hay datos de taquilla suficientes para proyectar asistencia.
        </div>
      </div>

      <!-- ══════════════════════════════════════════════════════════════════
           TAB 4 — ALERTAS DE RENDIMIENTO
      ════════════════════════════════════════════════════════════════════ -->
      <div v-if="tab === 'alertas'">
        <div class="pred-controls">
          <label class="pred-control-label">
            Umbral de cambio (%)
            <select v-model="umbralAlertas" class="pred-select-sm" @change="cargarAlertas">
              <option value="10">≥ 10%</option>
              <option value="15">≥ 15%</option>
              <option value="20">≥ 20%</option>
              <option value="30">≥ 30%</option>
            </select>
          </label>
        </div>

        <div v-if="cargando.alertas" class="pred-spinner-wrap">
          <span class="pred-spinner"></span> Detectando patrones…
        </div>

        <template v-else-if="alertas.length">
          <div class="pred-kpi-row">
            <div class="pred-kpi pred-kpi-red">
              <div class="pred-kpi-label">En declive / empeorando</div>
              <div class="pred-kpi-val">{{ alertasDeclive.length }}</div>
              <div class="pred-kpi-sub">jugadores</div>
            </div>
            <div class="pred-kpi pred-kpi-green">
              <div class="pred-kpi-label">En ascenso / mejorando</div>
              <div class="pred-kpi-val">{{ alertasAscenso.length }}</div>
              <div class="pred-kpi-sub">jugadores</div>
            </div>
          </div>

          <div class="pred-card">
            <div class="pred-card-header">
              <IconAlertTriangle :size="15" />
              Alertas automáticas de rendimiento
            </div>
            <div class="pred-table-wrap">
              <table class="pred-table">
                <thead>
                  <tr>
                    <th>Jugador</th>
                    <th>Equipo</th>
                    <th class="text-center">Tipo</th>
                    <th class="text-center">Estado</th>
                    <th class="text-center">Cambio %</th>
                    <th class="text-center">Antes</th>
                    <th class="text-center">Reciente</th>
                    <th class="text-center">Partidos</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="a in alertas" :key="`${a.tipo}-${a.id_jugador}`"
                    :class="(a.estado === 'declive' || a.estado === 'empeorando') ? 'pred-row-alert-red' : 'pred-row-alert-green'">
                    <td class="fw-semibold">{{ a.jugador }}</td>
                    <td class="text-muted small">{{ a.nombre_equipo }}</td>
                    <td class="text-center">
                      <span class="pred-pill pred-pill-sm pred-pill-gray">{{ a.tipo }}</span>
                    </td>
                    <td class="text-center">
                      <span class="pred-pill pred-pill-sm"
                        :class="(a.estado === 'ascenso' || a.estado === 'mejorando') ? 'pred-pill-green' : 'pred-pill-red'">
                        {{ a.estado }}
                      </span>
                    </td>
                    <td class="text-center fw-bold"
                      :class="(a.estado === 'ascenso' || a.estado === 'mejorando') ? 'text-success' : 'text-danger'">
                      {{ a.cambio_pct > 0 ? '+' : '' }}{{ a.cambio_pct }}%
                    </td>
                    <td class="text-center text-muted small">
                      {{ a.ave_antes !== undefined ? a.ave_antes?.toFixed(3) : a.era_antes?.toFixed(2) }}
                    </td>
                    <td class="text-center small fw-semibold">
                      {{ a.ave_reciente !== undefined ? a.ave_reciente?.toFixed(3) : a.era_reciente?.toFixed(2) }}
                    </td>
                    <td class="text-center small">{{ a.partidos_analizados }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>

        <div v-else-if="!cargando.alertas" class="pred-no-data">
          No se detectaron cambios significativos con el umbral seleccionado.
        </div>
      </div>

    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import {
  IconChartDots3,
  IconTable,
  IconUsers,
  IconAlertTriangle,
} from '@tabler/icons-vue'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'

// ── Props recibidos desde ReportesView ────────────────────────────────────
const props = defineProps({
  embedded:     { type: Boolean, default: false },
  temporadaSel: { type: [Number, String], default: '' },
})

const auth = useAuthStore()

// ── Estado ────────────────────────────────────────────────────────────────
const temporadaId     = ref(props.temporadaSel || '')
const tab             = ref(auth.esDueno ? 'jugadores' : 'finanzas')
const tipoJugador     = ref('bateadores')
const mesesProyeccion = ref('3')
const umbralAlertas   = ref('15')

const proyFinanzas   = ref({})
const predJugadores  = ref([])
const predAsistencia = ref([])
const alertas        = ref([])

const cargando = ref({ finanzas: false, jugadores: false, asistencia: false, alertas: false })

const tabs = computed(() => {
  // Dueño: solo ve predicción de jugadores
  if (auth.esDueno) return [
    { key: 'jugadores', label: 'Predicción Jugadores', icon: IconUsers },
  ]
  // Admin: ve todo
  return [
    { key: 'finanzas',   label: 'Proyección Financiera', icon: IconChartDots3   },
    { key: 'jugadores',  label: 'Predicción Jugadores',  icon: IconUsers        },
    { key: 'asistencia', label: 'Predicción Asistencia', icon: IconUsers        },
    { key: 'alertas',    label: 'Alertas Rendimiento',   icon: IconAlertTriangle },
  ]
})

// ── Cuando el padre cambia la temporada, recargar todo ────────────────────
watch(() => props.temporadaSel, (nueva) => {
  temporadaId.value = nueva
  if (nueva) cargarTodo()
})

// ── Computed ──────────────────────────────────────────────────────────────
const tablaFinanzasCombinada = computed(() =>
  [...(proyFinanzas.value.historico || []), ...(proyFinanzas.value.proyeccion || [])]
)
const alertasDeclive = computed(() =>
  alertas.value.filter(a => a.estado === 'declive' || a.estado === 'empeorando')
)
const alertasAscenso = computed(() =>
  alertas.value.filter(a => a.estado === 'ascenso' || a.estado === 'mejorando')
)

// ── Helpers ───────────────────────────────────────────────────────────────
function formatBs(val) {
  if (val == null) return '—'
  return Number(val).toLocaleString('es-VE', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' Bs.'
}

function tendenciaLabel(t) {
  const map = {
    subiendo: '▲ Subiendo', bajando: '▼ Bajando', estable: '● Estable',
    mejorando: '▲ Mejorando', empeorando: '▼ Empeorando',
  }
  return map[t] ?? t
}

// ── Cargas ────────────────────────────────────────────────────────────────
async function cargarFinanzas() {
  if (!temporadaId.value) return
  cargando.value.finanzas = true
  try {
    const { data } = await api.get('/reportes-predictivos/proyeccion-financiera', {
      params: { temporada: temporadaId.value, mesesProyeccion: mesesProyeccion.value },
    })
    proyFinanzas.value = data
  } catch (e) { console.error('Error proyección financiera:', e) }
  finally { cargando.value.finanzas = false }
}

async function cargarJugadores() {
  if (!temporadaId.value) return
  cargando.value.jugadores = true
  try {
    const { data } = await api.get('/reportes-predictivos/prediccion-jugadores', {
      params: { temporada: temporadaId.value, tipo: tipoJugador.value, limite: 30 },
    })
    predJugadores.value = data
  } catch (e) { console.error('Error predicción jugadores:', e) }
  finally { cargando.value.jugadores = false }
}

async function cargarAsistencia() {
  if (!temporadaId.value) return
  cargando.value.asistencia = true
  try {
    const { data } = await api.get('/reportes-predictivos/prediccion-asistencia', {
      params: { temporada: temporadaId.value },
    })
    predAsistencia.value = data
  } catch (e) { console.error('Error predicción asistencia:', e) }
  finally { cargando.value.asistencia = false }
}

async function cargarAlertas() {
  if (!temporadaId.value) return
  cargando.value.alertas = true
  try {
    const { data } = await api.get('/reportes-predictivos/alertas-rendimiento', {
      params: { temporada: temporadaId.value, umbral: umbralAlertas.value },
    })
    alertas.value = data
  } catch (e) { console.error('Error alertas rendimiento:', e) }
  finally { cargando.value.alertas = false }
}

async function cargarTodo() {
  if (auth.esDueno) {
    await cargarJugadores()
  } else {
    await Promise.all([cargarFinanzas(), cargarJugadores(), cargarAsistencia(), cargarAlertas()])
  }
}

// ── Al montar: si ya viene temporada del padre, cargar de inmediato ───────
onMounted(() => {
  if (temporadaId.value) cargarTodo()
})
</script>

<style scoped>
.pred-root {
  --c-bg:     #f8fafc;
  --c-card:   #ffffff;
  --c-border: #e2e8f0;
  --c-text:   #1e293b;
  --c-muted:  #64748b;
  --c-green:  #10b981;
  --c-red:    #ef4444;
  --c-blue:   #3b82f6;
  --c-yellow: #f59e0b;
  --c-proj:   #eff6ff;
  font-family: 'Inter', system-ui, sans-serif;
  color: var(--c-text);
}

/* Header */
.pred-header { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 20px; }
.pred-header-left { display: flex; align-items: center; gap: 14px; }
.pred-header-icon {
  width: 44px; height: 44px; border-radius: 12px;
  background: linear-gradient(135deg, #1e3a5f, #2563eb);
  color: #fff; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.pred-title   { margin: 0; font-size: 1.2rem; font-weight: 700; }
.pred-subtitle { margin: 0; font-size: 0.78rem; color: var(--c-muted); }

/* Empty */
.pred-empty { text-align: center; padding: 60px 20px; color: var(--c-muted); font-size: 0.9rem; }
.pred-empty-icon { opacity: 0.2; margin-bottom: 12px; }
.pred-no-data {
  text-align: center; padding: 40px; color: var(--c-muted);
  background: var(--c-card); border-radius: 12px; border: 1px dashed var(--c-border); font-size: 0.88rem;
}

/* Selects */
.pred-select-sm {
  border: 1px solid var(--c-border); border-radius: 6px; padding: 4px 10px;
  font-size: 0.82rem; background: var(--c-card); color: var(--c-text); margin-left: 8px;
}

/* Tabs */
.pred-tabs {
  display: flex; flex-wrap: wrap; gap: 4px; margin-bottom: 20px;
  padding: 4px; background: rgba(0,0,0,0.04); border-radius: 12px; width: fit-content;
}
.pred-tab-btn {
  display: flex; align-items: center; gap: 6px; padding: 6px 14px;
  border: none; border-radius: 8px; background: transparent;
  font-size: 0.82rem; color: var(--c-muted); cursor: pointer; transition: all 0.15s;
}
.pred-tab-btn:hover { background: rgba(255,255,255,0.7); color: var(--c-text); }
.pred-tab-active { background: var(--c-card) !important; color: var(--c-text) !important; font-weight: 600; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }

/* Controls */
.pred-controls { display: flex; align-items: center; gap: 16px; margin-bottom: 16px; }
.pred-control-label { font-size: 0.83rem; color: var(--c-muted); display: flex; align-items: center; }

/* Toggle */
.pred-toggle { display: flex; border: 1px solid var(--c-border); border-radius: 8px; overflow: hidden; }
.pred-toggle-btn {
  padding: 6px 16px; border: none; background: transparent;
  font-size: 0.82rem; cursor: pointer; color: var(--c-muted); transition: all 0.15s;
}
.pred-toggle-active { background: var(--c-blue); color: #fff !important; font-weight: 600; }

/* KPI */
.pred-kpi-row { display: flex; flex-wrap: wrap; gap: 12px; margin-bottom: 20px; }
.pred-kpi { flex: 1 1 160px; border-radius: 12px; padding: 16px 18px; border: 1px solid var(--c-border); }
.pred-kpi-green  { background: #f0fdf4; border-color: #bbf7d0; }
.pred-kpi-red    { background: #fef2f2; border-color: #fecaca; }
.pred-kpi-blue   { background: #eff6ff; border-color: #bfdbfe; }
.pred-kpi-yellow { background: #fffbeb; border-color: #fde68a; }
.pred-kpi-label  { font-size: 0.74rem; color: var(--c-muted); margin-bottom: 4px; font-weight: 600; text-transform: uppercase; letter-spacing: .04em; }
.pred-kpi-val    { font-size: 1.1rem; font-weight: 700; }
.pred-kpi-sub    { font-size: 0.73rem; color: var(--c-muted); margin-top: 2px; }

/* Cards */
.pred-card { background: var(--c-card); border: 1px solid var(--c-border); border-radius: 12px; overflow: hidden; margin-bottom: 20px; }
.pred-card-header {
  padding: 12px 16px; font-size: 0.82rem; font-weight: 600;
  border-bottom: 1px solid var(--c-border); background: #f8fafc;
  display: flex; align-items: center; gap: 8px; color: var(--c-muted);
}

/* Tables */
.pred-table-wrap { overflow-x: auto; }
.pred-table { width: 100%; border-collapse: collapse; font-size: 0.83rem; }
.pred-table th {
  padding: 9px 12px; text-align: left; font-size: 0.74rem; font-weight: 700;
  color: var(--c-muted); text-transform: uppercase; letter-spacing: .04em;
  background: #f8fafc; border-bottom: 1px solid var(--c-border); white-space: nowrap;
}
.pred-table td { padding: 9px 12px; border-bottom: 1px solid #f1f5f9; color: var(--c-text); }
.pred-table tbody tr:hover { background: #f8fafc; }
.pred-table tbody tr:last-child td { border-bottom: none; }

.pred-row-proj { background: var(--c-proj) !important; }
.pred-row-proj:hover { background: #dbeafe !important; }
.pred-row-alert-red   { background: #fff5f5; }
.pred-row-alert-green { background: #f0fff4; }
.pred-num { color: var(--c-muted); font-size: 0.78rem; font-weight: 700; width: 32px; }

/* Badges & pills */
.pred-badge-proyeccion {
  font-size: 0.68rem; background: #dbeafe; color: #1d4ed8;
  padding: 2px 7px; border-radius: 20px; font-weight: 700; letter-spacing: .03em;
}
.pred-pill { display: inline-block; border-radius: 20px; padding: 3px 10px; font-size: 0.78rem; font-weight: 600; white-space: nowrap; }
.pred-pill-sm { padding: 2px 8px; font-size: 0.73rem; }
.pred-pill-green  { background: #dcfce7; color: #15803d; }
.pred-pill-red    { background: #fee2e2; color: #b91c1c; }
.pred-pill-yellow { background: #fef9c3; color: #a16207; }
.pred-pill-gray   { background: #f1f5f9; color: #475569; }
.pred-proj-val { background: #dbeafe; color: #1d4ed8; font-weight: 700; padding: 2px 8px; border-radius: 6px; font-size: 0.84rem; }

/* Spinner */
.pred-spinner-wrap {
  text-align: center; padding: 40px; color: var(--c-muted); font-size: 0.88rem;
  display: flex; align-items: center; justify-content: center; gap: 10px;
}
.pred-spinner {
  display: inline-block; width: 18px; height: 18px;
  border: 2px solid var(--c-border); border-top-color: var(--c-blue);
  border-radius: 50%; animation: pred-spin 0.7s linear infinite;
}
@keyframes pred-spin { to { transform: rotate(360deg); } }

/* Utility */
.text-end    { text-align: right !important; }
.text-center { text-align: center !important; }
.text-muted  { color: var(--c-muted) !important; }
.text-success { color: var(--c-green) !important; }
.text-danger  { color: var(--c-red) !important; }
.fw-semibold  { font-weight: 600; }
.fw-bold      { font-weight: 700; }
.small        { font-size: 0.82rem; }
</style>