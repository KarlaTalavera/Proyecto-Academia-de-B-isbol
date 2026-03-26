<template>
  <div class="ld-page">
    <LandingHeader />

    <!-- Main content -->
    <div class="ld-standing-wrap">
      <!-- Section heading -->
      <div class="ld-section-head">
        <div class="ld-section-bar"></div>
        <h2 class="ld-section-title">POSICIONES</h2>
      </div>

      <!-- Season tabs -->
      <div class="ld-tabs-row">
        <button
          class="ld-tab"
          :class="{ 'ld-tab--active': tabActiva === 'temporada' }"
          @click="tabActiva = 'temporada'"
        >Temporada</button>
        <button
          class="ld-tab"
          :class="{ 'ld-tab--active': tabActiva === 'playoffs' }"
          @click="tabActiva = 'playoffs'"
        >Playoffs</button>
      </div>

      <!-- Playoffs coming soon -->
      <div v-if="tabActiva === 'playoffs'" class="ld-pronto-wrap">
        <span class="ld-pronto-icon">🏆</span>
        <p class="ld-pronto-title">Próximamente</p>
        <p class="ld-pronto-sub">Los Playoffs aún no han comenzado.</p>
      </div>

      <!-- Temporada content -->
      <div v-else>
        <!-- Sub-tabs -->
        <div class="ld-subtabs-row">
          <button
            v-for="sub in subTabs"
            :key="sub"
            class="ld-subtab"
            :class="{ 'ld-subtab--active': subTabActiva === sub }"
            @click="subTabActiva = sub"
          >{{ sub }}</button>
        </div>

        <!-- Loading -->
        <div v-if="cargando" class="ld-spinner-wrap">
          <div class="ld-spinner"></div>
          <p class="ld-spinner-text">Cargando posiciones...</p>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="ld-empty">
          <p class="ld-empty-icon">⚠</p>
          <p class="ld-empty-msg">Error al cargar los datos.<br />Verifica que el servidor esté disponible.</p>
        </div>

        <!-- No data -->
        <div v-else-if="!posiciones.length" class="ld-empty">
          <p class="ld-empty-icon">📊</p>
          <p class="ld-empty-msg">No hay datos para esta temporada</p>
        </div>

        <!-- Standings table -->
        <div v-else class="ld-table-wrap">
          <table class="ld-table">
            <thead>
              <tr>
                <th class="ld-th ld-th--pos">#</th>
                <th class="ld-th ld-th--equipo">Equipo</th>
                <th class="ld-th ld-th--stat">G</th>
                <th class="ld-th ld-th--stat">P</th>
                <th class="ld-th ld-th--stat">%</th>
                <th class="ld-th ld-th--stat">JV</th>
                <th class="ld-th ld-th--pts">PTS</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(equipo, idx) in posicionesOrdenadas"
                :key="equipo.id_equipo"
                class="ld-tr"
                :class="{ 'ld-tr--top': idx < 3 }"
              >
                <td class="ld-td ld-td--pos">
                  <span class="ld-pos-badge" :class="posBadgeClass(idx + 1)">{{ idx + 1 }}</span>
                </td>
                <td class="ld-td ld-td--equipo">
                  <div class="ld-team-cell">
                    <div class="ld-team-mini-avatar">{{ equipo.nombre_equipo ? equipo.nombre_equipo.charAt(0) : '?' }}</div>
                    <span class="ld-team-cell-name">{{ equipo.nombre_equipo }}</span>
                  </div>
                </td>
                <td class="ld-td ld-td--stat">{{ equipo.ganados }}</td>
                <td class="ld-td ld-td--stat">{{ equipo.perdidos }}</td>
                <td class="ld-td ld-td--stat">{{ calcPct(equipo) }}</td>
                <td class="ld-td ld-td--stat">{{ equipo.jugados }}</td>
                <td class="ld-td ld-td--pts">{{ calcPts(equipo) }}</td>
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
import LandingHeader from '@/components/landing/LandingHeader.vue'
import api from '@/services/api'

// ── State ─────────────────────────────────────────────────────
const tabActiva    = ref('temporada')
const subTabActiva = ref('GENERAL')
const subTabs      = ['GENERAL', '1V', '2V', 'PUNTOS']
const posiciones   = ref([])
const cargando     = ref(true)
const error        = ref(false)

// ── Computed: sort by ganados desc ────────────────────────────
const posicionesOrdenadas = computed(() =>
  [...posiciones.value].sort((a, b) => b.ganados - a.ganados || a.perdidos - b.perdidos)
)

// ── Helpers ───────────────────────────────────────────────────
function calcPct(e) {
  const j = e.jugados || (e.ganados + e.perdidos)
  if (!j || j === 0) return '.000'
  return (e.ganados / j).toFixed(3)
}

function calcPts(e) {
  return e.ganados * 2
}

function posBadgeClass(pos) {
  if (pos === 1) return 'ld-pos-badge--gold'
  if (pos === 2) return 'ld-pos-badge--silver'
  if (pos === 3) return 'ld-pos-badge--bronze'
  return ''
}

// ── Fetch data ────────────────────────────────────────────────
async function cargar() {
  cargando.value = true
  error.value    = false
  try {
    const res       = await api.get('/pub/posiciones')
    posiciones.value = res.data
  } catch {
    error.value = true
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)
</script>

<style scoped>
/* ── Normalize Bootstrap interference ────────────────────── */
.ld-page *, .ld-page *::before, .ld-page *::after { box-sizing: border-box; }
.ld-page p  { margin: 0; padding: 0; }
.ld-page h2 { margin: 0; padding: 0; }
.ld-page button { font-family: inherit; }
.ld-page table  { border-collapse: collapse; }

/* ── Page shell ──────────────────────────────────────────── */
.ld-page {
  min-height: 100vh;
  background: #210100;
  font-family: 'Arial Black', 'Segoe UI', Arial, sans-serif;
  color: #fff;
}

/* ── Wrapper ─────────────────────────────────────────────── */
.ld-standing-wrap {
  max-width: 900px;
  margin: 0 auto;
  padding: 2.5rem 1.25rem 5rem;
}

/* ── Section heading ─────────────────────────────────────── */
.ld-section-head {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 2rem;
}

.ld-section-bar {
  width: 5px;
  height: 2.2rem;
  background: #8C0902;
  border-radius: 3px;
  flex-shrink: 0;
}

.ld-section-title {
  font-size: clamp(1.8rem, 5vw, 2.6rem);
  font-weight: 900;
  font-style: italic;
  text-transform: uppercase;
  color: #D4AF37;
  letter-spacing: 0.04em;
  line-height: 1;
}

/* ── Main tabs ───────────────────────────────────────────── */
.ld-tabs-row {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  border-bottom: 2px solid rgba(212, 175, 55, 0.15);
  padding-bottom: 0;
}

.ld-tab {
  padding: 0.6rem 1.75rem;
  font-size: 0.9rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  background: transparent;
  border: none;
  border-bottom: 3px solid transparent;
  color: rgba(255, 255, 255, 0.45);
  cursor: pointer;
  margin-bottom: -2px;
  transition: color 0.2s, border-color 0.2s, background 0.2s;
  border-radius: 0.5rem 0.5rem 0 0;
}

.ld-tab:hover {
  color: #FECE79;
  background: rgba(212, 175, 55, 0.06);
}

.ld-tab--active {
  color: #FECE79;
  background: #8C0902;
  border-bottom-color: #D4AF37;
}

/* ── Playoffs placeholder ────────────────────────────────── */
.ld-pronto-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  padding: 4rem 1rem;
  text-align: center;
}

.ld-pronto-icon {
  font-size: 3.5rem;
  line-height: 1;
  display: block;
  margin-bottom: 0.5rem;
}

.ld-pronto-title {
  font-size: 1.5rem;
  font-weight: 900;
  font-style: italic;
  color: #D4AF37;
  letter-spacing: 0.05em;
}

.ld-pronto-sub {
  font-size: 0.9rem;
  color: rgba(255, 255, 255, 0.4);
  font-weight: 600;
}

/* ── Sub-tabs ────────────────────────────────────────────── */
.ld-subtabs-row {
  display: flex;
  gap: 0.375rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}

.ld-subtab {
  padding: 0.4rem 1.1rem;
  font-size: 0.78rem;
  font-weight: 800;
  letter-spacing: 0.07em;
  text-transform: uppercase;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 0.5rem;
  color: rgba(255, 255, 255, 0.5);
  cursor: pointer;
  transition: background 0.2s, color 0.2s, border-color 0.2s;
}

.ld-subtab:hover {
  background: rgba(212, 175, 55, 0.1);
  color: #FECE79;
  border-color: rgba(212, 175, 55, 0.3);
}

.ld-subtab--active {
  background: rgba(140, 9, 2, 0.55);
  color: #FECE79;
  border-color: #8C0902;
}

/* ── Loading spinner ─────────────────────────────────────── */
.ld-spinner-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 4rem 0;
}

.ld-spinner {
  width: 44px;
  height: 44px;
  border: 3px solid rgba(212, 175, 55, 0.15);
  border-top-color: #D4AF37;
  border-radius: 50%;
  animation: ld-spin 0.8s linear infinite;
}

@keyframes ld-spin { to { transform: rotate(360deg); } }

.ld-spinner-text {
  color: rgba(255, 255, 255, 0.5);
  font-size: 0.9rem;
  font-weight: 600;
}

/* ── Empty state ─────────────────────────────────────────── */
.ld-empty { text-align: center; padding: 4rem 1rem; }

.ld-empty-icon {
  font-size: 3rem;
  display: block;
  margin-bottom: 0.75rem;
}

.ld-empty-msg {
  color: rgba(255, 255, 255, 0.45);
  font-size: 1rem;
  font-weight: 600;
  line-height: 1.6;
}

/* ── Table wrapper ───────────────────────────────────────── */
.ld-table-wrap {
  border-radius: 1rem;
  overflow: hidden;
  border: 1px solid rgba(212, 175, 55, 0.12);
  overflow-x: auto;
}

/* ── Table ───────────────────────────────────────────────── */
.ld-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 480px;
}

/* ── Table header ────────────────────────────────────────── */
.ld-th {
  background: #E6A341;
  color: #210100;
  font-size: 0.78rem;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  padding: 0.8rem 0.75rem;
  text-align: center;
  white-space: nowrap;
  border: none;
}

.ld-th--equipo { text-align: left; padding-left: 1.25rem; }
.ld-th--pos    { width: 48px; }
.ld-th--stat   { width: 56px; }
.ld-th--pts    { width: 64px; color: #210100; font-size: 0.85rem; }

/* ── Table rows ──────────────────────────────────────────── */
.ld-tr {
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  transition: background 0.18s;
}

.ld-tr:last-child { border-bottom: none; }

.ld-tr:hover {
  background: rgba(140, 9, 2, 0.18);
}

.ld-tr--top {
  background: rgba(212, 175, 55, 0.04);
}

/* ── Table cells ─────────────────────────────────────────── */
.ld-td {
  padding: 0.85rem 0.75rem;
  text-align: center;
  font-size: 0.875rem;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.75);
  border: none;
  background: transparent;
}

.ld-td--equipo { text-align: left; padding-left: 1.25rem; }

.ld-td--pts {
  font-size: 1rem;
  font-weight: 900;
  color: #E6A341;
}

/* ── Position badge ──────────────────────────────────────── */
.ld-pos-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  font-size: 0.78rem;
  font-weight: 900;
  color: rgba(255, 255, 255, 0.6);
  background: rgba(255, 255, 255, 0.08);
}

.ld-pos-badge--gold   { background: rgba(212, 175, 55, 0.25); color: #D4AF37; }
.ld-pos-badge--silver { background: rgba(192, 192, 192, 0.2); color: #c0c0c0; }
.ld-pos-badge--bronze { background: rgba(176, 116, 64, 0.25); color: #cd7f32; }

/* ── Team cell ───────────────────────────────────────────── */
.ld-team-cell {
  display: flex;
  align-items: center;
  gap: 0.625rem;
}

.ld-team-mini-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: linear-gradient(135deg, #8C0902, #B14A36);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.85rem;
  font-weight: 900;
  color: #FECE79;
  text-transform: uppercase;
  flex-shrink: 0;
}

.ld-team-cell-name {
  font-size: 0.9rem;
  font-weight: 700;
  font-style: italic;
  text-transform: uppercase;
  color: #FECE79;
  letter-spacing: 0.03em;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
}

@media (max-width: 480px) {
  .ld-team-cell-name { max-width: 120px; font-size: 0.78rem; }
  .ld-td { padding: 0.65rem 0.5rem; }
}
</style>
