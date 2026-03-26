<template>
  <div class="ld-page">
    <LandingHeader />

    <!-- Banner -->
    <div class="ld-banner">
      <div class="ld-banner-bar"></div>
      <h2 class="ld-banner-title">CALENDARIO</h2>
    </div>

    <!-- Week navigation -->
    <div class="ld-week-nav">
      <button class="ld-week-btn" @click="semanaOffset--" title="Semana anterior">◄</button>
      <span class="ld-week-label">{{ weekLabel }}</span>
      <button class="ld-week-btn" @click="semanaOffset++" title="Semana siguiente">►</button>
    </div>

    <!-- Week content -->
    <div class="ld-content">
      <!-- Loading -->
      <div v-if="cargando" class="ld-spinner-wrap">
        <div class="ld-spinner"></div>
        <p class="ld-spinner-text">Cargando calendario...</p>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="ld-empty">
        <p class="ld-empty-icon">⚠</p>
        <p class="ld-empty-msg">Error al cargar el calendario.<br />Verifica que el servidor esté disponible.</p>
      </div>

      <!-- Days -->
      <div v-else class="ld-days-list">
        <div
          v-for="day in diasSemana"
          :key="day.iso"
          class="ld-day-block"
        >
          <!-- Day header -->
          <div class="ld-day-header">
            <div class="ld-day-header-bar"></div>
            <span class="ld-day-header-text">{{ day.label }}</span>
          </div>

          <!-- Games for this day -->
          <div v-if="!juegosPorDia(day.iso).length" class="ld-day-empty">
            {{ esPasado(day.iso) ? 'No hubo juegos programados para esta fecha' : 'No hay juegos programados para esta fecha' }}
          </div>

          <div v-else class="ld-day-games">
            <div
              v-for="juego in juegosPorDia(day.iso)"
              :key="juego.id_partido"
              class="ld-cal-card"
            >
              <!-- Time & venue -->
              <div class="ld-cal-card-top">
                <span v-if="juego.hora_juego" class="ld-cal-hora">⏰ {{ formatHora(juego.hora_juego) }}</span>
                <span v-if="juego.lugar" class="ld-cal-lugar">📍 {{ juego.lugar }}</span>
                <span v-if="juego.temporada" class="ld-cal-temporada">T{{ juego.temporada }}</span>
              </div>

              <!-- Matchup -->
              <div class="ld-cal-matchup">
                <div class="ld-cal-team">
                  <div class="ld-cal-avatar">{{ juego.equipo_casa ? juego.equipo_casa.charAt(0) : '?' }}</div>
                  <span class="ld-cal-team-name">{{ juego.equipo_casa }}</span>
                </div>
                <div class="ld-cal-vs">VS</div>
                <div class="ld-cal-team ld-cal-team--right">
                  <span class="ld-cal-team-name">{{ juego.equipo_visitante }}</span>
                  <div class="ld-cal-avatar">{{ juego.equipo_visitante ? juego.equipo_visitante.charAt(0) : '?' }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import LandingHeader from '@/components/landing/LandingHeader.vue'
import api from '@/services/api'

// ── Date/locale constants ──────────────────────────────────────
const DAYS_ES_FULL   = ['DOMINGO', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO']
const MONTHS_ES_FULL = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
                        'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE']
const MONTHS_ES_SHORT = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                         'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']

// ── State ─────────────────────────────────────────────────────
const semanaOffset = ref(0)   // 0 = current week, -1 = prev, +1 = next
const partidos     = ref([])
const cargando     = ref(true)
const error        = ref(false)

// ── Computed: week days based on offset ──────────────────────
const diasSemana = computed(() => {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  // Get Monday of current week
  const dayOfWeek = today.getDay()
  const monday    = new Date(today)
  monday.setDate(today.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1) + semanaOffset.value * 7)

  return Array.from({ length: 7 }, (_, i) => {
    const d = new Date(monday)
    d.setDate(monday.getDate() + i)
    const y = d.getFullYear()
    const m = String(d.getMonth() + 1).padStart(2, '0')
    const dd = String(d.getDate()).padStart(2, '0')
    const iso = `${y}-${m}-${dd}`
    const label = `${DAYS_ES_FULL[d.getDay()]} ${d.getDate()} DE ${MONTHS_ES_FULL[d.getMonth()]} DE ${d.getFullYear()}`
    return { iso, label, date: d }
  })
})

// ── Computed: week range label ────────────────────────────────
const weekLabel = computed(() => {
  const first = diasSemana.value[0].date
  const last  = diasSemana.value[6].date
  const sameMonth = first.getMonth() === last.getMonth()
  if (sameMonth) {
    return `Semana del ${first.getDate()} al ${last.getDate()} de ${MONTHS_ES_FULL[first.getMonth()].charAt(0) + MONTHS_ES_FULL[first.getMonth()].slice(1).toLowerCase()}`
  }
  return `Semana del ${first.getDate()} ${MONTHS_ES_SHORT[first.getMonth()]} al ${last.getDate()} ${MONTHS_ES_SHORT[last.getMonth()]}`
})

// ── Filter games by date & status ────────────────────────────
function juegosPorDia(iso) {
  return partidos.value.filter(p => p.fecha_juego && p.fecha_juego.slice(0, 10) === iso)
}

function esPasado(iso) {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return new Date(iso + 'T00:00:00') < today
}

// ── Format hour to 12h ────────────────────────────────────────
function formatHora(hora) {
  if (!hora) return ''
  const [h, m] = hora.split(':')
  const hh   = parseInt(h)
  const ampm = hh >= 12 ? 'PM' : 'AM'
  const h12  = hh > 12 ? hh - 12 : (hh === 0 ? 12 : hh)
  return `${h12}:${m} ${ampm}`
}

// ── Fetch ─────────────────────────────────────────────────────
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
.ld-page p  { margin: 0; padding: 0; }
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
  display: flex;
  align-items: center;
  gap: 1.25rem;
  padding: 3rem 2rem 2rem;
  background: linear-gradient(180deg, #0d0404 0%, #1a0a0a 100%);
}

.ld-banner-bar {
  width: 6px;
  height: 4.5rem;
  background: #8C0902;
  border-radius: 3px;
  flex-shrink: 0;
}

.ld-banner-title {
  font-size: clamp(3rem, 10vw, 6rem);
  font-weight: 900;
  font-style: italic;
  text-transform: uppercase;
  color: #D4AF37;
  letter-spacing: 0.04em;
  line-height: 1;
  text-shadow: 0 4px 24px rgba(140, 9, 2, 0.4);
}

/* ── Week navigation ─────────────────────────────────────── */
.ld-week-nav {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  padding: 1rem 1.25rem;
  background: rgba(0, 0, 0, 0.3);
  border-top: 1px solid rgba(212, 175, 55, 0.1);
  border-bottom: 1px solid rgba(212, 175, 55, 0.1);
}

.ld-week-btn {
  padding: 0.45rem 1rem;
  background: rgba(140, 9, 2, 0.4);
  border: 1px solid rgba(140, 9, 2, 0.6);
  border-radius: 0.5rem;
  color: #FECE79;
  font-size: 0.85rem;
  font-weight: 900;
  cursor: pointer;
  transition: background 0.2s, border-color 0.2s;
  line-height: 1;
}

.ld-week-btn:hover {
  background: #8C0902;
  border-color: #B14A36;
}

.ld-week-label {
  font-size: 0.9rem;
  font-weight: 700;
  color: #FECE79;
  text-align: center;
  min-width: 240px;
  letter-spacing: 0.02em;
}

/* ── Content area ────────────────────────────────────────── */
.ld-content {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1.25rem 5rem;
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

/* ── Days list ───────────────────────────────────────────── */
.ld-days-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

/* ── Day block ───────────────────────────────────────────── */
.ld-day-block {
  margin-bottom: 1.5rem;
}

/* ── Day header ──────────────────────────────────────────── */
.ld-day-header {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  margin-bottom: 0.75rem;
  padding-bottom: 0.4rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.ld-day-header-bar {
  width: 4px;
  height: 1.1rem;
  background: #8C0902;
  border-radius: 2px;
  flex-shrink: 0;
}

.ld-day-header-text {
  font-size: 0.72rem;
  font-weight: 900;
  letter-spacing: 0.12em;
  color: #D4AF37;
  text-transform: uppercase;
}

/* ── Day empty message ───────────────────────────────────── */
.ld-day-empty {
  font-size: 0.8rem;
  color: rgba(255, 255, 255, 0.25);
  font-weight: 600;
  padding: 0.5rem 0 0.5rem 1rem;
  font-style: italic;
}

/* ── Day games list ──────────────────────────────────────── */
.ld-day-games {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

/* ── Calendar game card ──────────────────────────────────── */
.ld-cal-card {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(212, 175, 55, 0.1);
  border-radius: 1.25rem;
  padding: 1rem 1.25rem;
  transition: background 0.2s, border-color 0.2s, transform 0.2s;
}

.ld-cal-card:hover {
  background: rgba(140, 9, 2, 0.1);
  border-color: rgba(212, 175, 55, 0.22);
  transform: translateY(-1px);
}

/* ── Card top row ────────────────────────────────────────── */
.ld-cal-card-top {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 0.75rem;
  flex-wrap: wrap;
}

.ld-cal-hora {
  font-size: 0.78rem;
  font-weight: 700;
  color: rgba(255, 255, 255, 0.55);
  letter-spacing: 0.04em;
}

.ld-cal-lugar {
  font-size: 0.76rem;
  color: rgba(255, 255, 255, 0.4);
}

.ld-cal-temporada {
  font-size: 0.7rem;
  font-weight: 900;
  color: rgba(212, 175, 55, 0.5);
  letter-spacing: 0.08em;
  margin-left: auto;
}

/* ── Matchup row ─────────────────────────────────────────── */
.ld-cal-matchup {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.ld-cal-team {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  flex: 1;
  min-width: 0;
}

.ld-cal-team--right {
  flex-direction: row-reverse;
  text-align: right;
}

.ld-cal-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, #8C0902, #B14A36);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.95rem;
  font-weight: 900;
  color: #FECE79;
  text-transform: uppercase;
  flex-shrink: 0;
}

.ld-cal-team-name {
  font-size: clamp(0.78rem, 2vw, 0.9rem);
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

.ld-cal-vs {
  font-size: 0.75rem;
  font-weight: 900;
  color: rgba(255, 255, 255, 0.3);
  letter-spacing: 0.1em;
  flex-shrink: 0;
  min-width: 32px;
  text-align: center;
}

@media (max-width: 480px) {
  .ld-banner { padding: 2rem 1rem 1.5rem; gap: 0.875rem; }
  .ld-banner-bar { height: 3rem; }
  .ld-week-label { min-width: 0; font-size: 0.78rem; }
  .ld-cal-card { padding: 0.875rem 1rem; }
}
</style>
