<template>
  <div class="estadisticas-view">

    <!-- ── Encabezado del jugador ──────────────────────────────── -->
    <div class="page-header">
      <button class="btn-back" @click="$router.back()">← Volver</button>
      <div v-if="jugador">
        <h1>{{ jugador.nombre }} {{ jugador.apellido }}</h1>
        <span class="badge" :class="jugador.rol">{{ jugador.rol }}</span>
        <span class="badge equipo">{{ jugador.nombre_equipo }}</span>
      </div>
    </div>

    <!-- ── Tabs: Por Partido / Por Temporada / Por Fecha ──────── -->
    <div class="tabs">
      <button
        v-for="tab in tabs"
        :key="tab.key"
        :class="['tab-btn', { active: activeTab === tab.key }]"
        @click="activeTab = tab.key"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- ══════════════════════════════════════════════════════════
         TAB 1 — Por Partido
    ════════════════════════════════════════════════════════════ -->
    <section v-if="activeTab === 'partidos'">
      <div v-if="loading" class="loading">Cargando…</div>

      <!-- BATEADOR -->
      <template v-if="!loading && (rol === 'bateador' || rol === 'utilidad')">
        <h2 class="section-title">Historial como Bateador</h2>
        <div class="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Rival</th>
                <th>Temporada</th>
                <th title="Turnos al Bate">TB</th>
                <th title="Hits">H</th>
                <th title="Dobles">2B</th>
                <th title="Triples">3B</th>
                <th title="Jonrones">HR</th>
                <th title="Carreras">R</th>
                <th title="Carreras Impulsadas">RBI</th>
                <th title="Bolas">BB</th>
                <th title="Outs">O</th>
                <th title="Promedio">AVG</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in partidosBateador" :key="row.id_desempeno">
                <td>{{ formatFecha(row.fecha_juego) }}</td>
                <td>{{ rival(row) }}</td>
                <td>{{ row.nombre_temporada }}</td>
                <td>{{ row.turnos_al_bate }}</td>
                <td>{{ row.hits }}</td>
                <td>{{ row.dobles }}</td>
                <td>{{ row.triples }}</td>
                <td>{{ row.jonrones }}</td>
                <td>{{ row.carreras }}</td>
                <td>{{ row.carreras_impulsadas }}</td>
                <td>{{ row.bolas }}</td>
                <td>{{ row.outs }}</td>
                <td class="stat-highlight">{{ row.promedio_bate }}</td>
              </tr>
              <tr v-if="!partidosBateador.length">
                <td colspan="13" class="empty">Sin registros</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <!-- PITCHER -->
      <template v-if="!loading && (rol === 'pitcher' || rol === 'utilidad')">
        <h2 class="section-title">Historial como Pitcher</h2>
        <div class="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Rival</th>
                <th>Temporada</th>
                <th title="Innings Pitcheados">IP</th>
                <th title="Hits Permitidos">H</th>
                <th title="Carreras Permitidas">R</th>
                <th title="Carreras Limpias">RL</th>
                <th title="Jonrones Permitidos">HR</th>
                <th title="Bases por Bolas">BB</th>
                <th title="Ponches">K</th>
                <th>G</th>
                <th>P</th>
                <th>S</th>
                <th title="Efectividad">ERA</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in partidosPitcher" :key="row.id_desempeno_pitcher">
                <td>{{ formatFecha(row.fecha_juego) }}</td>
                <td>{{ rival(row) }}</td>
                <td>{{ row.nombre_temporada }}</td>
                <td>{{ row.innings_pitcheados }}</td>
                <td>{{ row.hits_permitidos }}</td>
                <td>{{ row.carreras_permitidas }}</td>
                <td>{{ row.carreras_limpias }}</td>
                <td>{{ row.jonrones_permitidos }}</td>
                <td>{{ row.bases_por_bolas }}</td>
                <td>{{ row.ponches }}</td>
                <td :class="row.ganado ? 'win' : ''">{{ row.ganado ? 'G' : '' }}</td>
                <td :class="row.perdido ? 'loss' : ''">{{ row.perdido ? 'P' : '' }}</td>
                <td :class="row.salvado ? 'save' : ''">{{ row.salvado ? 'S' : '' }}</td>
                <td class="stat-highlight">{{ row.era }}</td>
              </tr>
              <tr v-if="!partidosPitcher.length">
                <td colspan="14" class="empty">Sin registros</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </section>

    <!-- ══════════════════════════════════════════════════════════
         TAB 2 — Por Temporada
    ════════════════════════════════════════════════════════════ -->
    <section v-if="activeTab === 'temporadas'">
      <div v-if="loading" class="loading">Cargando…</div>

      <!-- BATEADOR -->
      <template v-if="!loading && (rol === 'bateador' || rol === 'utilidad')">
        <h2 class="section-title">Estadísticas por Temporada — Bateador</h2>
        <div class="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Temporada</th>
                <th>PJ</th>
                <th>TB</th>
                <th>H</th>
                <th>2B</th>
                <th>3B</th>
                <th>HR</th>
                <th>R</th>
                <th>RBI</th>
                <th>BB</th>
                <th title="Promedio de Bateo">AVG</th>
                <th title="On Base Percentage">OBP</th>
                <th title="Slugging">SLG</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in tempBateador" :key="row.id_temporada">
                <td><strong>{{ row.nombre_temporada }}</strong></td>
                <td>{{ row.partidos_jugados }}</td>
                <td>{{ row.turnos_al_bate }}</td>
                <td>{{ row.hits }}</td>
                <td>{{ row.dobles }}</td>
                <td>{{ row.triples }}</td>
                <td>{{ row.jonrones }}</td>
                <td>{{ row.carreras }}</td>
                <td>{{ row.carreras_impulsadas }}</td>
                <td>{{ row.bolas }}</td>
                <td class="stat-highlight">{{ row.avg }}</td>
                <td class="stat-highlight">{{ row.obp }}</td>
                <td class="stat-highlight">{{ row.slg }}</td>
              </tr>
              <tr v-if="!tempBateador.length">
                <td colspan="13" class="empty">Sin registros</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <!-- PITCHER -->
      <template v-if="!loading && (rol === 'pitcher' || rol === 'utilidad')">
        <h2 class="section-title">Estadísticas por Temporada — Pitcher</h2>
        <div class="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Temporada</th>
                <th>PJ</th>
                <th>IP</th>
                <th>H</th>
                <th>R</th>
                <th>RL</th>
                <th>HR</th>
                <th>BB</th>
                <th>K</th>
                <th>G</th>
                <th>P</th>
                <th>S</th>
                <th title="Efectividad">ERA</th>
                <th title="Walks + Hits / IP">WHIP</th>
                <th title="Ponches por 9 innings">K/9</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in tempPitcher" :key="row.id_temporada">
                <td><strong>{{ row.nombre_temporada }}</strong></td>
                <td>{{ row.partidos }}</td>
                <td>{{ row.innings_pitcheados }}</td>
                <td>{{ row.hits_permitidos }}</td>
                <td>{{ row.carreras_permitidas }}</td>
                <td>{{ row.carreras_limpias }}</td>
                <td>{{ row.jonrones_permitidos }}</td>
                <td>{{ row.bases_por_bolas }}</td>
                <td>{{ row.ponches }}</td>
                <td class="win">{{ row.victorias }}</td>
                <td class="loss">{{ row.derrotas }}</td>
                <td class="save">{{ row.salvados }}</td>
                <td class="stat-highlight">{{ row.era }}</td>
                <td class="stat-highlight">{{ row.whip }}</td>
                <td class="stat-highlight">{{ row.k_por_9 }}</td>
              </tr>
              <tr v-if="!tempPitcher.length">
                <td colspan="15" class="empty">Sin registros</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </section>

    <!-- ══════════════════════════════════════════════════════════
         TAB 3 — Por Fecha
    ════════════════════════════════════════════════════════════ -->
    <section v-if="activeTab === 'fechas'">
      <div class="date-filter">
        <label>Desde <input type="date" v-model="filtro.inicio" /></label>
        <label>Hasta <input type="date" v-model="filtro.fin"   /></label>
        <button class="btn-primary" @click="buscarPorFechas" :disabled="!filtro.inicio || !filtro.fin">
          Buscar
        </button>
      </div>

      <div v-if="loading" class="loading">Cargando…</div>
      <div v-else-if="!fechasBuscadas" class="hint">Selecciona un rango de fechas y presiona Buscar.</div>

      <!-- BATEADOR -->
      <template v-if="!loading && fechasBuscadas && (rol === 'bateador' || rol === 'utilidad')">
        <h2 class="section-title">
          Bateador — {{ formatFecha(filtro.inicio) }} al {{ formatFecha(filtro.fin) }}
        </h2>
        <div v-if="fechasBateador.length" class="summary-cards">
          <div class="card">
            <span class="label">Partidos</span>
            <span class="value">{{ fechasBateador.length }}</span>
          </div>
          <div class="card">
            <span class="label">Hits</span>
            <span class="value">{{ sum(fechasBateador, 'hits') }}</span>
          </div>
          <div class="card">
            <span class="label">HR</span>
            <span class="value">{{ sum(fechasBateador, 'jonrones') }}</span>
          </div>
          <div class="card">
            <span class="label">RBI</span>
            <span class="value">{{ sum(fechasBateador, 'carreras_impulsadas') }}</span>
          </div>
          <div class="card highlight">
            <span class="label">AVG</span>
            <span class="value">{{ avgCalc(fechasBateador) }}</span>
          </div>
        </div>
        <div class="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Fecha</th><th>Rival</th><th>TB</th><th>H</th>
                <th>2B</th><th>3B</th><th>HR</th><th>R</th>
                <th>RBI</th><th>BB</th><th>AVG</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in fechasBateador" :key="row.id_desempeno">
                <td>{{ formatFecha(row.fecha_juego) }}</td>
                <td>{{ rival(row) }}</td>
                <td>{{ row.turnos_al_bate }}</td>
                <td>{{ row.hits }}</td>
                <td>{{ row.dobles }}</td>
                <td>{{ row.triples }}</td>
                <td>{{ row.jonrones }}</td>
                <td>{{ row.carreras }}</td>
                <td>{{ row.carreras_impulsadas }}</td>
                <td>{{ row.bolas }}</td>
                <td class="stat-highlight">{{ row.promedio_bate }}</td>
              </tr>
              <tr v-if="!fechasBateador.length">
                <td colspan="11" class="empty">Sin registros en ese período</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <!-- PITCHER -->
      <template v-if="!loading && fechasBuscadas && (rol === 'pitcher' || rol === 'utilidad')">
        <h2 class="section-title">
          Pitcher — {{ formatFecha(filtro.inicio) }} al {{ formatFecha(filtro.fin) }}
        </h2>
        <div v-if="fechasPitcher.length" class="summary-cards">
          <div class="card">
            <span class="label">Salidas</span>
            <span class="value">{{ fechasPitcher.length }}</span>
          </div>
          <div class="card win">
            <span class="label">G</span>
            <span class="value">{{ sum(fechasPitcher, 'ganado') }}</span>
          </div>
          <div class="card loss">
            <span class="label">P</span>
            <span class="value">{{ sum(fechasPitcher, 'perdido') }}</span>
          </div>
          <div class="card">
            <span class="label">K</span>
            <span class="value">{{ sum(fechasPitcher, 'ponches') }}</span>
          </div>
          <div class="card highlight">
            <span class="label">ERA</span>
            <span class="value">{{ eraCalc(fechasPitcher) }}</span>
          </div>
        </div>
        <div class="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Fecha</th><th>Rival</th><th>IP</th><th>H</th>
                <th>R</th><th>RL</th><th>BB</th><th>K</th>
                <th>G</th><th>P</th><th>S</th><th>ERA</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in fechasPitcher" :key="row.id_desempeno_pitcher">
                <td>{{ formatFecha(row.fecha_juego) }}</td>
                <td>{{ rival(row) }}</td>
                <td>{{ row.innings_pitcheados }}</td>
                <td>{{ row.hits_permitidos }}</td>
                <td>{{ row.carreras_permitidas }}</td>
                <td>{{ row.carreras_limpias }}</td>
                <td>{{ row.bases_por_bolas }}</td>
                <td>{{ row.ponches }}</td>
                <td :class="row.ganado ? 'win' : ''">{{ row.ganado ? 'G' : '' }}</td>
                <td :class="row.perdido ? 'loss' : ''">{{ row.perdido ? 'P' : '' }}</td>
                <td :class="row.salvado ? 'save' : ''">{{ row.salvado ? 'S' : '' }}</td>
                <td class="stat-highlight">{{ row.era }}</td>
              </tr>
              <tr v-if="!fechasPitcher.length">
                <td colspan="12" class="empty">Sin registros en ese período</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </section>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import api from '@/services/api';

const route  = useRoute();
const id     = computed(() => route.params.id);

// ── jugador info ─────────────────────────────────────────────────────────
const jugador = ref(null);
const rol     = computed(() => jugador.value?.rol ?? '');

// ── tabs ─────────────────────────────────────────────────────────────────
const tabs = [
  { key: 'partidos',   label: 'Por Partido'  },
  { key: 'temporadas', label: 'Por Temporada' },
  { key: 'fechas',     label: 'Por Fecha'    },
];
const activeTab = ref('partidos');

// ── data ─────────────────────────────────────────────────────────────────
const loading           = ref(false);
const partidosBateador  = ref([]);
const partidosPitcher   = ref([]);
const tempBateador      = ref([]);
const tempPitcher       = ref([]);
const fechasBateador    = ref([]);
const fechasPitcher     = ref([]);
const fechasBuscadas    = ref(false);
const filtro            = ref({ inicio: '', fin: '' });

// ── load según tab ────────────────────────────────────────────────────────
async function cargarTab(tab) {
  loading.value = true;
  try {
    if (tab === 'partidos') {
      if (rol.value === 'bateador' || rol.value === 'utilidad')
        partidosBateador.value = await api.get(`/estadisticas/jugador/${id.value}/bateador/partidos`).then(r => r.data);
      if (rol.value === 'pitcher' || rol.value === 'utilidad')
        partidosPitcher.value  = await api.get(`/estadisticas/jugador/${id.value}/pitcher/partidos`).then(r => r.data);
    }
    if (tab === 'temporadas') {
      if (rol.value === 'bateador' || rol.value === 'utilidad')
        tempBateador.value     = await api.get(`/estadisticas/jugador/${id.value}/bateador/temporadas`).then(r => r.data);
      if (rol.value === 'pitcher' || rol.value === 'utilidad')
        tempPitcher.value      = await api.get(`/estadisticas/jugador/${id.value}/pitcher/temporadas`).then(r => r.data);
    }
  } finally {
    loading.value = false;
  }
}

async function buscarPorFechas() {
  loading.value = true;
  fechasBuscadas.value = false;
  try {
    const params = `inicio=${filtro.value.inicio}&fin=${filtro.value.fin}`;
    if (rol.value === 'bateador' || rol.value === 'utilidad')
      fechasBateador.value = await api.get(`/estadisticas/jugador/${id.value}/bateador/fechas?${params}`).then(r => r.data);
    if (rol.value === 'pitcher' || rol.value === 'utilidad')
      fechasPitcher.value  = await api.get(`/estadisticas/jugador/${id.value}/pitcher/fechas?${params}`).then(r => r.data);
    fechasBuscadas.value = true;
  } finally {
    loading.value = false;
  }
}

// ── helpers ───────────────────────────────────────────────────────────────
const formatFecha = d => d ? new Date(d).toLocaleDateString('es-VE', { day:'2-digit', month:'short', year:'numeric' }) : '';

// Identifica el equipo rival comparando contra id_equipo_casa e id_equipo_visitante
const rival = row => {
  const eq = Number(jugador.value?.id_equipo);
  if (!eq) return '—';
  if (Number(row.id_equipo_casa) === eq)       return row.equipo_visitante ?? '—';
  if (Number(row.id_equipo_visitante) === eq)  return row.equipo_casa      ?? '—';
  return row.equipo_visitante ?? row.equipo_casa ?? '—';
};

const sum = (arr, key) => arr.reduce((a, r) => a + (Number(r[key]) || 0), 0);

const avgCalc = arr => {
  const h  = sum(arr, 'hits');
  const tb = sum(arr, 'turnos_al_bate');
  return tb ? (h / tb).toFixed(3) : '.000';
};

const eraCalc = arr => {
  const rl = sum(arr, 'carreras_limpias');
  const ip = sum(arr, 'innings_pitcheados');
  return ip ? ((rl * 9) / ip).toFixed(2) : '0.00';
};

// ── init ──────────────────────────────────────────────────────────────────
onMounted(async () => {
  const { data } = await api.get(`/jugadores/${id.value}`);
  jugador.value = data;
  await cargarTab('partidos');

  // Fallback: si el endpoint /jugadores/:id no devuelve id_equipo, tomarlo del primer registro
  if (!jugador.value?.id_equipo) {
    const fallback = partidosBateador.value[0] ?? partidosPitcher.value[0];
    if (fallback?.id_equipo) {
      jugador.value = { ...jugador.value, id_equipo: fallback.id_equipo };
    }
  }
});

watch(activeTab, tab => {
  if (tab !== 'fechas') cargarTab(tab);
});
</script>

<style scoped>
.estadisticas-view {
  padding: 1.5rem;
  font-family: inherit;
}

/* header */
.page-header {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}
.page-header h1 { font-size: 1.6rem; margin: 0; }
.btn-back {
  background: none;
  border: 1px solid #ccc;
  border-radius: 6px;
  padding: .4rem .8rem;
  cursor: pointer;
  font-size: .9rem;
}
.btn-back:hover { background: #f0f0f0; }

/* badges */
.badge {
  display: inline-block;
  padding: .2rem .7rem;
  border-radius: 999px;
  font-size: .75rem;
  font-weight: 600;
  text-transform: capitalize;
  margin-left: .4rem;
}
.badge.bateador  { background: #dbeafe; color: #1d4ed8; }
.badge.pitcher   { background: #fef3c7; color: #92400e; }
.badge.utilidad  { background: #e0e7ff; color: #3730a3; }
.badge.equipo    { background: #f0fdf4; color: #166534; }

/* tabs */
.tabs { display: flex; gap: .5rem; margin-bottom: 1.5rem; border-bottom: 2px solid #e5e7eb; }
.tab-btn {
  padding: .6rem 1.2rem;
  border: none;
  background: none;
  cursor: pointer;
  font-size: .95rem;
  color: #6b7280;
  border-bottom: 3px solid transparent;
  margin-bottom: -2px;
  transition: color .15s, border-color .15s;
}
.tab-btn:hover  { color: #111827; }
.tab-btn.active { color: #1d4ed8; border-bottom-color: #1d4ed8; font-weight: 600; }

/* section title */
.section-title {
  font-size: 1.05rem;
  font-weight: 700;
  color: #374151;
  margin: 1.5rem 0 .6rem;
  padding-bottom: .3rem;
  border-bottom: 1px solid #e5e7eb;
}

/* table */
.table-wrapper { overflow-x: auto; margin-bottom: 2rem; }
table { width: 100%; border-collapse: collapse; font-size: .88rem; }
thead tr { background: #f9fafb; }
th { padding: .55rem .7rem; text-align: center; font-weight: 700; color: #374151;
     border-bottom: 2px solid #e5e7eb; white-space: nowrap; }
td { padding: .45rem .7rem; text-align: center; border-bottom: 1px solid #f3f4f6; }
tbody tr:hover { background: #f9fafb; }
td:first-child, th:first-child { text-align: left; }

.stat-highlight { font-weight: 700; color: #1d4ed8; }
.win  { color: #16a34a; font-weight: 700; }
.loss { color: #dc2626; font-weight: 700; }
.save { color: #7c3aed; font-weight: 700; }
.empty { color: #9ca3af; font-style: italic; text-align: center; padding: 1.5rem; }

/* date filter */
.date-filter {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}
.date-filter label { display: flex; align-items: center; gap: .4rem; font-size: .9rem; }
.date-filter input[type="date"] {
  border: 1px solid #d1d5db;
  border-radius: 6px;
  padding: .35rem .7rem;
  font-size: .9rem;
}
.btn-primary {
  background: #1d4ed8;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: .45rem 1.1rem;
  cursor: pointer;
  font-size: .9rem;
  font-weight: 600;
  transition: background .15s;
}
.btn-primary:hover:not(:disabled) { background: #1e40af; }
.btn-primary:disabled { opacity: .5; cursor: not-allowed; }

/* summary cards */
.summary-cards {
  display: flex;
  gap: .75rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
}
.card {
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 10px;
  padding: .8rem 1.2rem;
  min-width: 80px;
  text-align: center;
}
.card .label { display: block; font-size: .75rem; color: #6b7280; margin-bottom: .2rem; }
.card .value { display: block; font-size: 1.4rem; font-weight: 800; color: #111827; }
.card.highlight { border-color: #1d4ed8; background: #eff6ff; }
.card.highlight .value { color: #1d4ed8; }
.card.win  .value { color: #16a34a; }
.card.loss .value { color: #dc2626; }

.loading { color: #6b7280; padding: 2rem 0; text-align: center; }
.hint    { color: #9ca3af; font-style: italic; padding: 1rem 0; }
</style>