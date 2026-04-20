<template>
  <div class="al-page">
    <LandingHeader />

    <!-- ── HERO ── -->
    <section class="al-hero">
      <div class="al-hero__glow" />
      <div class="al-hero__content">
        <p class="al-hero__kicker">CLAUSURA 2026 · PIZARRÓN TÁCTICO</p>
        <h1 class="al-hero__title">
          LINE<span class="al-hero__title--accent">UP</span>
        </h1>
        <p class="al-hero__sub">
          Selecciona un partido y mueve los jugadores<br />
          por el diamante como quieras. ¡Es tu pizarrón!
        </p>
      </div>
      <div class="al-hero__deco">◆</div>
    </section>

    <!-- ── SELECTOR DE PARTIDO ── -->
    <section class="al-section al-section--dark">
      <div class="al-container">
        <span class="al-eyebrow al-eyebrow--center">PASO 1 — ELIGE UN PARTIDO</span>
        <h2 class="al-title al-title--center">¿Qué partido<br /><em>quieres analizar?</em></h2>

        <div v-if="cargandoPartidos" class="al-partidos-grid">
          <div v-for="i in 6" :key="i" class="al-skeleton" style="height:90px" />
        </div>

        <div v-else-if="!partidos.length" class="al-empty">
          <p>Aún no hay alineaciones publicadas.</p>
          <span class="al-empty__sub">El anotador las cargará antes del inicio de cada juego.</span>
        </div>

        <div v-else class="al-partidos-grid">
          <button
            v-for="p in partidos" :key="p.id_partido"
            :class="['al-partido-btn', { 'al-partido-btn--active': partidoActivo?.id_partido === p.id_partido }]"
            @click="abrirDetalle(p)"
          >
            <div class="al-partido-btn__teams">
              <span class="al-partido-btn__team">{{ p.equipo_casa }}</span>
              <span class="al-partido-btn__vs">VS</span>
              <span class="al-partido-btn__team">{{ p.equipo_visitante }}</span>
            </div>
            <div class="al-partido-btn__meta">
              <span>{{ formatFecha(p.fecha_juego) }} · {{ formatHora(p.hora_juego) }}</span>
              <span :class="['al-estado', `al-estado--${p.estado}`]">{{ p.estado }}</span>
            </div>
          </button>
        </div>
      </div>
    </section>

    <!-- ── LINEUP ── -->
    <section v-if="partidoActivo" class="al-section">
      <div class="al-container">
        <h2 class="al-title al-title--center">
          <em>{{ partidoActivo.equipo_casa }}</em>
          <span style="color:var(--red);font-size:0.6em;padding:0 0.3em">VS</span>
          {{ partidoActivo.equipo_visitante }}
        </h2>

        <!-- Cargando -->
        <div v-if="cargandoLineup" class="al-loading">
          <div class="al-loading__spinner" />
          <span>Cargando alineación...</span>
        </div>

        <!-- Sin titulares -->
        <div v-else-if="!lineupData.length" class="al-empty al-empty--big">
          <p>El anotador aún no cargó la alineación para este partido.</p>
          <span class="al-empty__sub">Se publica antes del inicio del juego.</span>
        </div>

        <!-- Dos columnas: equipo casa | equipo visitante -->
        <div v-else class="al-lineup-cols">

          <div v-for="lado in ['casa', 'visitante']" :key="lado" class="al-lineup-equipo">
            <div class="al-lineup-equipo__header">
              <span class="al-lineup-equipo__badge">{{ lado === 'casa' ? 'LOCAL' : 'VISITANTE' }}</span>
              <h3 class="al-lineup-equipo__nombre">
                {{ lado === 'casa' ? partidoActivo.equipo_casa : partidoActivo.equipo_visitante }}
              </h3>
            </div>

            <div class="al-player-grid">
              <div
                v-for="j in jugadoresPorLado(lado)"
                :key="jugadorKey(j)"
                class="al-player-card"
              >
                <!-- Foto o avatar -->
                <div class="al-player-card__foto-wrap">
                  <img
                    v-if="j.foto_url"
                    :src="apiBase + j.foto_url"
                    :alt="j.nombre"
                    class="al-player-card__foto"
                  />
                  <div v-else class="al-player-card__avatar">
                    {{ j.nombre?.charAt(0) }}{{ j.apellido?.charAt(0) }}
                  </div>
                  <!-- Badge de posición -->
                  <span class="al-player-card__pos-badge">{{ j.posicion_juego || j.posicion }}</span>
                  <!-- Número de orden al bate -->
                  <span v-if="j.orden_bateo" class="al-player-card__orden">#{{ j.orden_bateo }}</span>
                </div>
                <div class="al-player-card__info">
                  <span class="al-player-card__nombre">{{ j.nombre }} {{ j.apellido }}</span>
                  <span class="al-player-card__pos-txt">{{ posicionCompleta(j.posicion_juego || j.posicion) }}</span>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>

    <!-- ── CTA ── -->
    <section class="al-cta">
      <div class="al-cta__deco">◆</div>
      <div class="al-cta__content">
        <h2 class="al-cta__title">¿Quieres más<br /><em>béisbol?</em></h2>
        <div class="al-cta__btns">
          <router-link to="/resultados" class="al-cta__btn al-cta__btn--gold">RESULTADOS</router-link>
          <router-link to="/equipos" class="al-cta__btn al-cta__btn--outline">EQUIPOS</router-link>
        </div>
      </div>
    </section>

    <!-- ── MODAL DETALLE ── -->
    <transition name="al-fade">
      <div v-if="modalPartido" class="al-modal-overlay" @click.self="cerrarModal">
        <div class="al-modal">
          <button class="al-modal__close" @click="cerrarModal">✕</button>
          <div class="al-modal__header">
            <div class="al-modal__teams">
              <span class="al-modal__team">{{ modalPartido.equipo_casa }}</span>
              <span class="al-modal__vs">VS</span>
              <span class="al-modal__team">{{ modalPartido.equipo_visitante }}</span>
            </div>
            <span :class="['al-estado', `al-estado--${modalPartido.estado}`]">{{ modalPartido.estado }}</span>
          </div>
          <div class="al-modal__body">
            <div class="al-modal__grid">
              <div class="al-modal__item">
                <span class="al-modal__lbl">Fecha</span>
                <span class="al-modal__val">{{ formatFechaLarga(modalPartido.fecha_juego) }}</span>
              </div>
              <div class="al-modal__item">
                <span class="al-modal__lbl">Hora</span>
                <span class="al-modal__val">{{ formatHora(modalPartido.hora_juego) }}</span>
              </div>
              <div class="al-modal__item">
                <span class="al-modal__lbl">Lugar</span>
                <span class="al-modal__val">{{ modalPartido.lugar || 'Por confirmar' }}</span>
              </div>
              <div class="al-modal__item">
                <span class="al-modal__lbl">Temporada</span>
                <span class="al-modal__val">{{ modalPartido.temporada || 'Clausura 2026' }}</span>
              </div>
              <template v-if="modalPartido.carreras_casa !== null && modalPartido.carreras_casa !== undefined">
                <div class="al-modal__item">
                  <span class="al-modal__lbl">Marcador</span>
                  <span class="al-modal__val al-modal__val--score">
                    {{ modalPartido.carreras_casa }} – {{ modalPartido.carreras_visitante }}
                  </span>
                </div>
              </template>
            </div>
          </div>
          <div class="al-modal__footer">
            <button class="al-modal__btn al-modal__btn--outline" @click="cerrarModal">Cerrar</button>
            <button class="al-modal__btn al-modal__btn--gold" @click="cargarLineup">
              Ver Alineación
            </button>
          </div>
        </div>
      </div>
    </transition>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import LandingHeader from '@/components/landing/LandingHeader.vue'

const apiBase = import.meta.env.VITE_API_URL?.replace('/api', '') || 'http://localhost:3000'

// ── Estado principal ──
const partidos         = ref([])
const cargandoPartidos = ref(true)
const partidoActivo    = ref(null)
const lineupData       = ref([])
const cargandoLineup   = ref(false)
const modalPartido     = ref(null)

// ── Jugadores por lado ──
function jugadoresPorLado(lado) {
  if (!lineupData.value.length || !partidoActivo.value) return []
  const idEquipo = lado === 'casa'
    ? partidoActivo.value.id_equipo_casa
    : partidoActivo.value.id_equipo_visitante
  return lineupData.value
    .filter(j => j.id_equipo === idEquipo && j.es_titular)
    .sort((a, b) => (a.orden_bateo || 99) - (b.orden_bateo || 99))
}

function jugadorKey(j) {
  return `${j.id_equipo}-${j.nombre}-${j.apellido}`
}

const POSICIONES = {
  'P':  'Pitcher',    'C':  'Catcher',   '1B': 'Primera Base',
  '2B': 'Segunda Base','3B': 'Tercera Base','SS': 'Shortstop',
  'LF': 'Left Field', 'CF': 'Center Field','RF': 'Right Field',
  'DH': 'Bateador Designado','UT': 'Utility',
}
function posicionCompleta(pos) {
  return POSICIONES[pos] || pos || ''
}

// ── Modal ──
function abrirDetalle(partido) {
  modalPartido.value = partido
  document.body.style.overflow = 'hidden'
}

function cerrarModal() {
  modalPartido.value = null
  document.body.style.overflow = ''
}

async function cargarLineup() {
  const partido = modalPartido.value
  cerrarModal()
  partidoActivo.value = partido
  cargandoLineup.value = true
  lineupData.value = []
  try {
    const { data } = await api.get(`/pub/lineup/${partido.id_partido}`)
    lineupData.value = data
  } catch {
    lineupData.value = []
  } finally {
    cargandoLineup.value = false
  }
  setTimeout(() => {
    document.querySelector('.al-lineup-cols')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }, 200)
}

// ── Helpers fecha ──
function formatFecha(fecha) {
  if (!fecha) return ''
  return new Date(fecha).toLocaleDateString('es-VE', { weekday: 'short', day: 'numeric', month: 'short' })
}

function formatFechaLarga(fecha) {
  if (!fecha) return ''
  return new Date(fecha).toLocaleDateString('es-VE', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
}

function formatHora(hora) {
  if (!hora) return ''
  return hora.slice(0, 5)
}

onMounted(async () => {
  try {
    const { data } = await api.get('/pub/partidos')
    const campoDisponible = data.length > 0 && data[0].tiene_lineup !== undefined
    partidos.value = campoDisponible ? data.filter(p => p.tiene_lineup == 1) : data
  } catch {
    partidos.value = []
  } finally {
    cargandoPartidos.value = false
  }
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Barlow+Condensed:wght@400;700&family=Barlow:wght@400;500&display=swap');

.al-page {
  --gold:    #D4AF37;
  --gold-lt: #F5D76E;
  --red:     #8C0902;
  --bg:      #120908;
  --bg-dark: #0d0605;
  --bg-card: #1c0f0c;
  --border:  rgba(212,175,55,0.15);
  --txt:     rgba(255,255,255,0.68);
  --txt-dim: rgba(255,255,255,0.3);

  background: var(--bg);
  color: white;
  font-family: 'Barlow', sans-serif;
  min-height: 100vh;
  overflow-x: hidden;
}

/* ── Hero ── */
.al-hero {
  position: relative; min-height: 400px;
  display: flex; align-items: flex-end;
  padding: 140px 60px 72px; overflow: hidden;
  background:
    radial-gradient(ellipse 55% 65% at 85% 50%, rgba(140,9,2,0.2) 0%, transparent 70%),
    var(--bg-dark);
  border-bottom: 1px solid var(--border);
}
.al-hero__glow {
  position: absolute; inset: 0;
  background: radial-gradient(ellipse 40% 40% at 15% 80%, rgba(212,175,55,0.04) 0%, transparent 60%);
  pointer-events: none;
}
.al-hero__content { position: relative; z-index: 2; max-width: 680px; }
.al-hero__kicker {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px; font-weight: 700; letter-spacing: 5px;
  color: var(--gold); text-transform: uppercase; margin: 0 0 20px;
  display: flex; align-items: center; gap: 14px;
}
.al-hero__kicker::before {
  content: ''; display: block; width: 36px; height: 2px;
  background: var(--red); flex-shrink: 0;
}
.al-hero__title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(80px, 13vw, 152px); line-height: 0.9;
  margin: 0 0 20px; color: white; letter-spacing: 2px;
}
.al-hero__title--accent { color: var(--gold); }
.al-hero__sub {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 17px; color: var(--txt); line-height: 1.65; margin: 0;
}
.al-hero__deco {
  position: absolute; right: 60px; top: 50%; transform: translateY(-50%);
  font-size: clamp(100px, 16vw, 220px); opacity: 0.04;
  user-select: none; pointer-events: none;
  animation: spin 30s linear infinite;
}
@keyframes spin { to { transform: translateY(-50%) rotate(360deg); } }

/* ── Sections ── */
.al-section { padding: 72px 0; }
.al-section--dark { background: var(--bg-dark); }
.al-container { max-width: 1280px; margin: 0 auto; padding: 0 60px; }
@media (max-width: 768px) {
  .al-container { padding: 0 20px; }
  .al-section { padding: 48px 0; }
}

/* ── Eyebrow / Title ── */
.al-eyebrow {
  display: block; font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px; font-weight: 700; letter-spacing: 5px;
  color: var(--gold); text-transform: uppercase; margin-bottom: 12px;
}
.al-eyebrow--center { text-align: center; }
.al-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(34px, 5vw, 54px); line-height: 1.0;
  color: white; margin: 0 0 40px; letter-spacing: 1px;
}
.al-title em { color: var(--gold); font-style: normal; }
.al-title--center { text-align: center; }

/* ── Estado badge ── */
.al-estado {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; padding: 2px 8px; border-radius: 999px;
}
.al-estado--programado { background: rgba(100,100,255,0.15); color: #8888ff; }
.al-estado--en_curso   { background: rgba(80,200,80,0.15);  color: #80e080; }
.al-estado--finalizado { background: rgba(255,255,255,0.06); color: var(--txt-dim); }
.al-estado--suspendido { background: rgba(255,150,0,0.15);  color: #ffaa00; }

/* ── Partidos grid ── */
.al-partidos-grid {
  display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px;
}
@media (max-width: 1023px) { .al-partidos-grid { grid-template-columns: repeat(2,1fr); } }
@media (max-width: 640px)  { .al-partidos-grid { grid-template-columns: 1fr; } }

.al-partido-btn {
  background: var(--bg-card); border: 1px solid rgba(255,255,255,0.06);
  border-radius: 14px; padding: 16px 18px; cursor: pointer;
  transition: all 0.2s; text-align: left; display: flex; flex-direction: column; gap: 8px;
}
.al-partido-btn:hover { border-color: var(--gold); background: rgba(212,175,55,0.05); }
.al-partido-btn--active { border-color: var(--gold); box-shadow: 0 0 0 1px var(--gold); }

.al-partido-btn__teams { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.al-partido-btn__team {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 14px; font-weight: 700; color: white; text-transform: uppercase;
}
.al-partido-btn__vs {
  font-family: 'Bebas Neue', sans-serif; font-size: 12px; color: var(--red);
}
.al-partido-btn__meta {
  display: flex; justify-content: space-between; align-items: center;
  font-size: 11px; color: var(--txt-dim);
}

/* ── Lineup dos columnas ── */
.al-lineup-cols {
  display: grid; grid-template-columns: 1fr 1fr; gap: 32px;
}
@media (max-width: 860px) { .al-lineup-cols { grid-template-columns: 1fr; } }

.al-lineup-equipo__header {
  display: flex; align-items: center; gap: 12px; margin-bottom: 20px;
}
.al-lineup-equipo__badge {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px; font-weight: 700; letter-spacing: 3px;
  text-transform: uppercase; padding: 3px 10px; border-radius: 999px;
  background: rgba(140,9,2,0.4); color: var(--gold); border: 1px solid rgba(212,175,55,0.2);
}
.al-lineup-equipo__nombre {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 22px; color: white; margin: 0; letter-spacing: 1px;
}

/* ── Grid de cards ── */
.al-player-grid {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); gap: 12px;
}

.al-player-card {
  background: var(--bg-card);
  border: 1px solid rgba(255,255,255,0.06);
  border-radius: 14px; overflow: hidden;
  display: flex; flex-direction: column;
  transition: border-color 0.2s, transform 0.2s;
}
.al-player-card:hover {
  border-color: rgba(212,175,55,0.35);
  transform: translateY(-3px);
}

.al-player-card__foto-wrap {
  position: relative; width: 100%; aspect-ratio: 1;
  background: linear-gradient(135deg, #1c0f0c, #2a1510);
  display: flex; align-items: center; justify-content: center;
}
.al-player-card__foto {
  width: 100%; height: 100%; object-fit: cover; display: block;
}
.al-player-card__avatar {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 36px; color: rgba(212,175,55,0.4); letter-spacing: 2px;
}
.al-player-card__pos-badge {
  position: absolute; top: 7px; left: 7px;
  background: rgba(0,0,0,0.75); color: var(--gold);
  font-family: 'Bebas Neue', sans-serif; font-size: 13px;
  padding: 2px 7px; border-radius: 6px; backdrop-filter: blur(4px);
  border: 1px solid rgba(212,175,55,0.25);
}
.al-player-card__orden {
  position: absolute; bottom: 7px; right: 7px;
  background: rgba(140,9,2,0.85); color: white;
  font-family: 'Bebas Neue', sans-serif; font-size: 12px;
  padding: 1px 6px; border-radius: 6px;
}

.al-player-card__info {
  padding: 10px 10px 12px;
  display: flex; flex-direction: column; gap: 3px;
}
.al-player-card__nombre {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 13px; font-weight: 700; color: white;
  text-transform: uppercase; letter-spacing: 0.5px;
  line-height: 1.2;
}
.al-player-card__pos-txt {
  font-size: 10px; color: var(--txt-dim);
  font-family: 'Barlow Condensed', sans-serif; letter-spacing: 0.5px;
}

/* ── Loading ── */
.al-loading {
  display: flex; flex-direction: column; align-items: center; gap: 16px; padding: 60px 0;
}
.al-loading__spinner {
  width: 36px; height: 36px; border-radius: 50%;
  border: 3px solid rgba(212,175,55,0.2);
  border-top-color: var(--gold); animation: rotate 0.8s linear infinite;
}
@keyframes rotate { to { transform: rotate(360deg); } }
.al-loading span { font-family: 'Barlow Condensed', sans-serif; font-size: 14px; color: var(--txt-dim); letter-spacing: 2px; }

/* ── Skeleton ── */
.al-skeleton {
  border-radius: 14px;
  background: linear-gradient(90deg,
    rgba(255,255,255,0.04) 25%, rgba(255,255,255,0.08) 50%, rgba(255,255,255,0.04) 75%);
  background-size: 200% 100%; animation: shimmer 1.5s infinite;
}
@keyframes shimmer { to { background-position: -200% 0; } }

/* ── Empty ── */
.al-empty {
  display: flex; flex-direction: column; align-items: center; gap: 12px;
  padding: 60px 0; text-align: center;
}
.al-empty span:first-child { font-size: 40px; }
.al-empty p { color: var(--txt); font-size: 15px; margin: 0; }
.al-empty--big { padding: 80px 0; }
.al-empty__sub { font-size: 13px; color: var(--txt-dim); }

/* ── CTA ── */
.al-cta {
  position: relative; overflow: hidden; padding: 96px 60px; text-align: center;
  background: radial-gradient(ellipse 50% 70% at 50% 50%, rgba(140,9,2,0.2) 0%, transparent 70%), var(--bg-dark);
  border-top: 1px solid var(--border);
}
.al-cta__deco {
  position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;
  font-size: clamp(160px,28vw,340px); opacity: 0.03;
  user-select: none; pointer-events: none; animation: spin 60s linear infinite reverse;
}
.al-cta__content {
  position: relative; z-index: 2; max-width: 480px; margin: 0 auto;
  display: flex; flex-direction: column; align-items: center; gap: 24px;
}
.al-cta__title {
  font-family: 'Bebas Neue', sans-serif; font-size: clamp(44px,7vw,80px);
  line-height: 1; margin: 0; letter-spacing: 2px;
}
.al-cta__title em { color: var(--gold); font-style: normal; }
.al-cta__btns { display: flex; gap: 14px; flex-wrap: wrap; justify-content: center; }
.al-cta__btn {
  font-family: 'Barlow Condensed', sans-serif; font-size: 13px; font-weight: 700;
  letter-spacing: 3px; text-transform: uppercase; text-decoration: none;
  padding: 14px 36px; border-radius: 999px; transition: all 0.2s; display: inline-flex; align-items: center;
}
.al-cta__btn--gold    { background: var(--gold); color: var(--bg-dark); border: 2px solid var(--gold); }
.al-cta__btn--gold:hover { background: var(--gold-lt); }
.al-cta__btn--outline { background: transparent; color: var(--gold); border: 2px solid var(--gold); }
.al-cta__btn--outline:hover { background: var(--gold); color: var(--bg-dark); }

/* ── Modal ── */
.al-modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.82);
  display: flex; align-items: center; justify-content: center;
  z-index: 1000; padding: 24px; backdrop-filter: blur(6px);
}
.al-modal {
  background: #1a0e0b; border: 1px solid var(--border);
  border-radius: 24px; max-width: 460px; width: 100%; position: relative; overflow: hidden;
}
.al-modal__close {
  position: absolute; top: 14px; right: 16px;
  background: rgba(255,255,255,0.07); border: none; color: white;
  font-size: 15px; width: 32px; height: 32px; border-radius: 50%;
  cursor: pointer; display: flex; align-items: center; justify-content: center;
  transition: background 0.2s; z-index: 10;
}
.al-modal__close:hover { background: var(--red); }
.al-modal__header {
  padding: 28px 28px 20px; border-bottom: 1px solid rgba(255,255,255,0.06);
  background: rgba(212,175,55,0.04); display: flex; flex-direction: column; gap: 10px;
}
.al-modal__teams { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.al-modal__team { font-family: 'Bebas Neue', sans-serif; font-size: 20px; color: white; }
.al-modal__vs { font-family: 'Bebas Neue', sans-serif; font-size: 14px; color: var(--red); }
.al-modal__body { padding: 20px 28px; }
.al-modal__grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
@media (max-width: 480px) { .al-modal__grid { grid-template-columns: 1fr; } }
.al-modal__item { display: flex; flex-direction: column; gap: 3px; }
.al-modal__lbl {
  font-family: 'Barlow Condensed', sans-serif; font-size: 10px; font-weight: 700;
  letter-spacing: 2px; color: var(--txt-dim); text-transform: uppercase;
}
.al-modal__val { font-size: 14px; color: white; text-transform: capitalize; }
.al-modal__val--score {
  font-family: 'Bebas Neue', sans-serif; font-size: 28px; color: var(--gold); line-height: 1;
}
.al-modal__footer {
  padding: 0 28px 24px; display: flex; gap: 10px; justify-content: flex-end;
}
.al-modal__btn {
  font-family: 'Barlow Condensed', sans-serif; font-size: 13px; font-weight: 700;
  letter-spacing: 2px; text-transform: uppercase; padding: 11px 24px; border-radius: 999px;
  cursor: pointer; transition: all 0.2s;
}
.al-modal__btn--gold { background: var(--gold); color: var(--bg-dark); border: 2px solid var(--gold); }
.al-modal__btn--gold:hover { background: var(--gold-lt); }
.al-modal__btn--outline { background: transparent; color: var(--txt-dim); border: 2px solid rgba(255,255,255,0.1); }
.al-modal__btn--outline:hover { color: white; border-color: white; }

/* ── Transition ── */
.al-fade-enter-active, .al-fade-leave-active { transition: opacity 0.25s ease; }
.al-fade-enter-from, .al-fade-leave-to { opacity: 0; }
</style>