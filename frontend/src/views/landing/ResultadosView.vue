<template>
  <div class="ld-page">
    <LandingHeader />

    <!-- Banner -->
    <div class="ld-banner">
      <h2 class="ld-banner-title">RESULTADOS</h2>
    </div>

    <!-- Date navigation bar -->
    <div class="ld-date-nav-wrap">
      <div class="ld-date-nav">
        <button
          v-for="day in days"
          :key="day.iso"
          class="ld-date-btn"
          :class="{ 'ld-date-btn--active': day.iso === selectedDate }"
          @click="selectedDate = day.iso"
        >
          <span class="ld-date-btn-dow">{{ day.dow }}</span>
          <span class="ld-date-btn-num">{{ day.num }}</span>
          <span class="ld-date-btn-mon">{{ day.mon }}</span>
        </button>
      </div>
    </div>

    <!-- Content -->
    <div class="ld-content">
      <!-- Loading -->
      <div v-if="cargando" class="ld-spinner-wrap">
        <div class="ld-spinner"></div>
        <p class="ld-spinner-text">Cargando partidos...</p>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="ld-empty">
        <p class="ld-empty-icon">⚠</p>
        <p class="ld-empty-msg">Error al cargar los partidos.<br />Verifica que el servidor esté disponible.</p>
      </div>

      <!-- No games for date -->
      <div v-else-if="!juegosDia.length" class="ld-empty">
        <p class="ld-empty-icon">📅</p>
        <p class="ld-empty-msg">No hay juegos para esta fecha</p>
      </div>

      <!-- Game cards -->
      <div v-else class="ld-games-list">
        <div
          v-for="juego in juegosDia"
          :key="juego.id_partido"
          class="ld-game-card"
          :class="{ 'ld-game-card--live': juego.estado === 'en_juego' }"
        >
          <!-- Card top row: hora, lugar, badge -->
          <div class="ld-game-header">
            <div class="ld-game-meta">
              <span v-if="juego.hora_juego" class="ld-game-hora">{{ formatHora(juego.hora_juego) }}</span>
              <span v-if="juego.lugar" class="ld-game-lugar">📍 {{ juego.lugar }}</span>
            </div>
            <div class="ld-badge-wrap">
              <span v-if="juego.estado === 'en_juego'" class="ld-dot-live"></span>
              <span
                class="ld-status-badge"
                :class="{
                  'ld-status-badge--final': juego.estado === 'finalizado',
                  'ld-status-badge--live':  juego.estado === 'en_juego',
                  'ld-status-badge--next':  juego.estado === 'programado',
                }"
              >{{ estadoLabel(juego.estado) }}</span>
            </div>
          </div>

          <!-- Matchup row -->
          <div class="ld-matchup">
            <div class="ld-team ld-team--casa">
              <div class="ld-team-avatar">{{ juego.equipo_casa ? juego.equipo_casa.charAt(0) : '?' }}</div>
              <span class="ld-team-name">{{ juego.equipo_casa }}</span>
            </div>

            <div class="ld-score">
              <span class="ld-score-num">{{ juego.estado !== 'programado' ? (juego.carreras_casa ?? '-') : '-' }}</span>
              <span class="ld-score-sep">:</span>
              <span class="ld-score-num">{{ juego.estado !== 'programado' ? (juego.carreras_visitante ?? '-') : '-' }}</span>
            </div>

            <div class="ld-team ld-team--visitante">
              <span class="ld-team-name">{{ juego.equipo_visitante }}</span>
              <div class="ld-team-avatar">{{ juego.equipo_visitante ? juego.equipo_visitante.charAt(0) : '?' }}</div>
            </div>
          </div>

          <div v-if="juego.temporada" class="ld-game-temporada">Temporada {{ juego.temporada }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import LandingHeader from '@/components/landing/LandingHeader.vue'
import api from '@/services/api'

// ── Date utilities ────────────────────────────────────────────
const DAYS_ES   = ['DOM', 'LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB']
const MONTHS_ES = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC']

function toIso(date) {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

function buildDays() {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return Array.from({ length: 7 }, (_, i) => {
    const d = new Date(today)
    d.setDate(today.getDate() + (i - 3))
    return {
      iso: toIso(d),
      dow: DAYS_ES[d.getDay()],
      num: String(d.getDate()).padStart(2, '0'),
      mon: MONTHS_ES[d.getMonth()],
    }
  })
}

// ── State ─────────────────────────────────────────────────────
const days         = buildDays()
const todayIso     = toIso(new Date())
const selectedDate = ref(todayIso)
const partidos     = ref([])
const cargando     = ref(true)
const error        = ref(false)

// ── Computed: filter by selected date ─────────────────────────
const juegosDia = computed(() =>
  partidos.value.filter(p => p.fecha_juego && p.fecha_juego.slice(0, 10) === selectedDate.value)
)

// ── Helpers ───────────────────────────────────────────────────
function estadoLabel(estado) {
  if (estado === 'finalizado') return 'FINAL'
  if (estado === 'en_juego')   return 'EN VIVO'
  return 'PRÓXIMO'
}

function formatHora(hora) {
  if (!hora) return ''
  const [h, m] = hora.split(':')
  const hh   = parseInt(h)
  const ampm = hh >= 12 ? 'PM' : 'AM'
  const h12  = hh > 12 ? hh - 12 : (hh === 0 ? 12 : hh)
  return `${h12}:${m} ${ampm}`
}

// ── Fetch data on mount ────────────────────────────────────────
async function cargar() {
  cargando.value = true
  error.value    = false
  try {
    const res      = await api.get('/pub/partidos')
    partidos.value = res.data
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
.ld-page p { margin: 0; padding: 0; }
.ld-page h2 { margin: 0; padding: 0; }
.ld-page button { font-family: inherit; }

/* ── Page shell ──────────────────────────────────────────── */
.ld-page {
  min-height: 100vh;
  background: #1a0a0a;
  font-family: 'Arial Black', 'Segoe UI', Arial, sans-serif;
  color: #fff;
}

/* ── Banner ──────────────────────────────────────────────── */
.ld-banner {
  padding: 3rem 1.5rem 2rem;
  text-align: center;
  background: linear-gradient(180deg, #0d0404 0%, #1a0a0a 100%);
}

.ld-banner-title {
  font-size: clamp(3rem, 10vw, 6rem);
  font-weight: 900;
  font-style: italic;
  text-transform: uppercase;
  color: #ffffff;
  letter-spacing: 0.04em;
  line-height: 1;
  text-shadow: 0 4px 24px rgba(140, 9, 2, 0.5);
}

/* ── Date navigation bar ─────────────────────────────────── */
.ld-date-nav-wrap {
  position: sticky;
  top: 0;
  z-index: 50;
  background: #001d3d;
  border-top: 1px solid rgba(212, 175, 55, 0.15);
  border-bottom: 1px solid rgba(212, 175, 55, 0.15);
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
}

.ld-date-nav-wrap::-webkit-scrollbar { display: none; }

.ld-date-nav {
  display: flex;
  min-width: max-content;
  padding: 0.5rem 1rem;
  gap: 0.375rem;
  justify-content: center;
}

.ld-date-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  padding: 0.5rem 1.1rem;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 0.625rem;
  cursor: pointer;
  transition: background 0.2s, border-color 0.2s;
  min-width: 64px;
}

.ld-date-btn:hover {
  background: rgba(254, 206, 121, 0.08);
  border-color: rgba(254, 206, 121, 0.25);
}

.ld-date-btn--active {
  background: rgba(254, 206, 121, 0.12);
  border-color: #FECE79;
}

.ld-date-btn-dow {
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: rgba(255, 255, 255, 0.5);
  text-transform: uppercase;
}
.ld-date-btn--active .ld-date-btn-dow { color: #FECE79; }

.ld-date-btn-num {
  font-size: 1.35rem;
  font-weight: 900;
  color: rgba(255, 255, 255, 0.8);
  line-height: 1;
}
.ld-date-btn--active .ld-date-btn-num { color: #FECE79; }

.ld-date-btn-mon {
  font-size: 0.65rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: rgba(255, 255, 255, 0.45);
  text-transform: uppercase;
}
.ld-date-btn--active .ld-date-btn-mon { color: #FECE79; }

/* ── Content area ────────────────────────────────────────── */
.ld-content {
  max-width: 820px;
  margin: 0 auto;
  padding: 2rem 1.25rem 4rem;
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
  margin-bottom: 0.75rem;
  display: block;
}

.ld-empty-msg {
  color: rgba(255, 255, 255, 0.45);
  font-size: 1rem;
  font-weight: 600;
  line-height: 1.6;
}

/* ── Games list ──────────────────────────────────────────── */
.ld-games-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

/* ── Game card ───────────────────────────────────────────── */
.ld-game-card {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(212, 175, 55, 0.1);
  border-radius: 1.5rem;
  padding: 1.25rem 1.5rem;
  transition: background 0.2s, border-color 0.2s, transform 0.2s;
}

.ld-game-card:hover {
  background: rgba(255, 255, 255, 0.07);
  border-color: rgba(212, 175, 55, 0.25);
  transform: translateY(-1px);
}

.ld-game-card--live {
  border-color: rgba(177, 74, 54, 0.5);
  background: rgba(140, 9, 2, 0.08);
}

/* ── Card header row ─────────────────────────────────────── */
.ld-game-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.ld-game-meta {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.ld-game-hora {
  font-size: 0.8rem;
  font-weight: 700;
  color: rgba(255, 255, 255, 0.5);
  letter-spacing: 0.04em;
}

.ld-game-lugar {
  font-size: 0.78rem;
  color: rgba(255, 255, 255, 0.4);
}

.ld-badge-wrap {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

/* ── Live pulsing dot ────────────────────────────────────── */
.ld-dot-live {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #e53e3e;
  animation: ld-pulse 1.4s ease-in-out infinite;
  flex-shrink: 0;
}

@keyframes ld-pulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50%       { opacity: 0.5; transform: scale(1.4); }
}

/* ── Status badge ────────────────────────────────────────── */
.ld-status-badge {
  display: inline-block;
  font-size: 0.7rem;
  font-weight: 900;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  padding: 0.25rem 0.7rem;
  border-radius: 999px;
  border: 1px solid transparent;
}

.ld-status-badge--final {
  background: rgba(52, 168, 83, 0.15);
  color: #68d391;
  border-color: rgba(52, 168, 83, 0.35);
}

.ld-status-badge--live {
  background: rgba(229, 62, 62, 0.2);
  color: #fc8181;
  border-color: rgba(229, 62, 62, 0.4);
}

.ld-status-badge--next {
  background: rgba(212, 175, 55, 0.12);
  color: #FECE79;
  border-color: rgba(212, 175, 55, 0.3);
}

/* ── Matchup ─────────────────────────────────────────────── */
.ld-matchup {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.ld-team {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex: 1;
  min-width: 0;
}

.ld-team--visitante {
  flex-direction: row-reverse;
  text-align: right;
}

.ld-team-avatar {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  background: linear-gradient(135deg, #8C0902, #B14A36);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.1rem;
  font-weight: 900;
  color: #FECE79;
  text-transform: uppercase;
  flex-shrink: 0;
}

.ld-team-name {
  font-size: clamp(0.78rem, 2vw, 0.95rem);
  font-weight: 800;
  font-style: italic;
  text-transform: uppercase;
  color: #ffffff;
  letter-spacing: 0.03em;
  line-height: 1.2;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* ── Score display ───────────────────────────────────────── */
.ld-score {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  flex-shrink: 0;
  min-width: 90px;
  justify-content: center;
}

.ld-score-num {
  font-size: 2rem;
  font-weight: 900;
  color: #ffffff;
  line-height: 1;
  min-width: 2ch;
  text-align: center;
}

.ld-score-sep {
  font-size: 1.5rem;
  font-weight: 700;
  color: rgba(255, 255, 255, 0.35);
  line-height: 1;
  padding-bottom: 2px;
}

/* ── Footer label ────────────────────────────────────────── */
.ld-game-temporada {
  margin-top: 0.75rem;
  font-size: 0.7rem;
  color: rgba(255, 255, 255, 0.3);
  font-weight: 600;
  letter-spacing: 0.08em;
  text-align: right;
  text-transform: uppercase;
}

@media (max-width: 480px) {
  .ld-game-card { padding: 1rem; }
  .ld-score-num { font-size: 1.6rem; }
  .ld-score     { min-width: 72px; }
}
</style>
