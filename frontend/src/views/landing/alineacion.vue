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
          <p>No hay partidos en la temporada activa.</p>
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

    <!-- ── PIZARRÓN ── -->
    <section v-if="partidoActivo" class="al-section">
      <div class="al-container">
        <span class="al-eyebrow al-eyebrow--center">PASO 2 — MUEVE LOS JUGADORES</span>
        <h2 class="al-title al-title--center">
          <em>{{ partidoActivo.equipo_casa }}</em> vs {{ partidoActivo.equipo_visitante }}
        </h2>

        <!-- Tabs equipo -->
        <div class="al-tabs">
          <button
            :class="['al-tab', { 'al-tab--active': equipoActivo === 'casa' }]"
            @click="cambiarEquipo('casa')"
          >
            {{ partidoActivo.equipo_casa }}
          </button>
          <button
            :class="['al-tab', { 'al-tab--active': equipoActivo === 'visitante' }]"
            @click="cambiarEquipo('visitante')"
          >
            {{ partidoActivo.equipo_visitante }}
          </button>
          <button class="al-tab al-tab--reset" @click="resetear">Reiniciar</button>
        </div>

        <!-- Cargando -->
        <div v-if="cargandoLineup" class="al-loading">
          <div class="al-loading__spinner" />
          <span>Cargando alineación...</span>
        </div>

        <!-- Sin lineup -->
        <div v-else-if="jugadoresActivos.length === 0" class="al-empty al-empty--big">
          <p>El anotador aún no cargó la alineación para este partido.</p>
          <span class="al-empty__sub">Se publica antes del inicio del juego.</span>
        </div>

        <!-- PIZARRÓN INTERACTIVO -->
        <div v-else class="al-pizarron-wrap">

          <!-- Campo de béisbol -->
          <div
            class="al-campo"
            ref="campoRef"
            @mousemove="onMouseMove"
            @mouseup="onMouseUp"
            @touchmove.prevent="onTouchMove"
            @touchend="onTouchEnd"
          >
            <!-- SVG del campo -->
            <svg class="al-campo__svg" viewBox="0 0 600 560" xmlns="http://www.w3.org/2000/svg">
              <!-- Fondo pasto -->
              <rect width="600" height="560" fill="#1a3d1a" />
              <!-- Pasto jardines -->
              <path d="M300 460 L60 160 A280 280 0 0 1 540 160 Z" fill="#1f4d1f" />
              <!-- Pasto infield -->
              <polygon points="300,460 420,340 300,220 180,340" fill="#2d5a1b" />
              <!-- Diamante tierra -->
              <polygon points="300,460 420,340 300,220 180,340" fill="#8B6914" opacity="0.3"/>
              <!-- Líneas de foul -->
              <line x1="300" y1="460" x2="60" y2="160" stroke="white" stroke-width="1.5" opacity="0.6"/>
              <line x1="300" y1="460" x2="540" y2="160" stroke="white" stroke-width="1.5" opacity="0.6"/>
              <!-- Línea base paths -->
              <polygon points="300,460 420,340 300,220 180,340"
                fill="none" stroke="white" stroke-width="1.5" opacity="0.5"/>
              <!-- Montículo -->
              <circle cx="300" cy="340" r="18" fill="#8B6914" opacity="0.6"/>
              <circle cx="300" cy="340" r="4" fill="white" opacity="0.8"/>
              <!-- Home plate -->
              <polygon points="300,466 292,474 292,482 308,482 308,474"
                fill="white" opacity="0.9"/>
              <!-- Bases -->
              <rect x="290" y="212" width="20" height="16" rx="2" fill="white" opacity="0.9"/> <!-- 2B -->
              <rect x="412" y="332" width="20" height="16" rx="2" fill="white" opacity="0.9"/> <!-- 1B -->
              <rect x="168" y="332" width="20" height="16" rx="2" fill="white" opacity="0.9"/> <!-- 3B -->
              <!-- Etiquetas bases -->
              <text x="300" y="204" text-anchor="middle" fill="rgba(255,255,255,0.7)" font-size="11" font-family="sans-serif" font-weight="bold">2B</text>
              <text x="444" y="344" text-anchor="middle" fill="rgba(255,255,255,0.7)" font-size="11" font-family="sans-serif" font-weight="bold">1B</text>
              <text x="156" y="344" text-anchor="middle" fill="rgba(255,255,255,0.7)" font-size="11" font-family="sans-serif" font-weight="bold">3B</text>
              <text x="300" y="498" text-anchor="middle" fill="rgba(255,255,255,0.7)" font-size="11" font-family="sans-serif" font-weight="bold">HOME</text>
              <text x="300" y="336" text-anchor="middle" fill="rgba(255,255,255,0.5)" font-size="10" font-family="sans-serif" font-weight="bold">P</text>
              <!-- Jardines labels -->
              <text x="300" y="110" text-anchor="middle" fill="rgba(255,255,255,0.4)" font-size="11" font-family="sans-serif">CF</text>
              <text x="130" y="190" text-anchor="middle" fill="rgba(255,255,255,0.4)" font-size="11" font-family="sans-serif">LF</text>
              <text x="470" y="190" text-anchor="middle" fill="rgba(255,255,255,0.4)" font-size="11" font-family="sans-serif">RF</text>
              <text x="370" y="274" text-anchor="middle" fill="rgba(255,255,255,0.3)" font-size="10" font-family="sans-serif">SS</text>
              <text x="230" y="274" text-anchor="middle" fill="rgba(255,255,255,0.3)" font-size="10" font-family="sans-serif">2B</text>
              <!-- Instrucción -->
              <text x="300" y="540" text-anchor="middle" fill="rgba(255,255,255,0.25)" font-size="10" font-family="sans-serif">Arrastra los jugadores</text>
            </svg>

            <!-- Jugadores arrastrables -->
            <div
              v-for="jugador in jugadoresActivos"
              :key="jugador.id_jugador || jugador.nombre"
              class="al-jugador-token"
              :class="{ 'al-jugador-token--dragging': dragging?.key === jugadorKey(jugador) }"
              :style="tokenStyle(jugador)"
              @mousedown.prevent="startDrag($event, jugador)"
              @touchstart.prevent="startDragTouch($event, jugador)"
            >
              <div class="al-jugador-token__pos">{{ jugador.posicion_juego || jugador.posicion }}</div>
              <div class="al-jugador-token__nombre">{{ jugador.nombre?.charAt(0) }}. {{ jugador.apellido }}</div>
              <div v-if="jugador.orden_bateo" class="al-jugador-token__num">{{ jugador.orden_bateo }}</div>
            </div>
          </div>

          <!-- Lista lateral -->
          <div class="al-sidebar">
            <div class="al-sidebar__title">ORDEN AL BATE</div>
            <div class="al-sidebar__list">
              <div
                v-for="j in jugadoresActivos.filter(x => x.orden_bateo).sort((a,b) => a.orden_bateo - b.orden_bateo)"
                :key="jugadorKey(j)"
                class="al-sidebar__item"
              >
                <span class="al-sidebar__num">{{ j.orden_bateo }}</span>
                <div class="al-sidebar__info">
                  <span class="al-sidebar__nombre">{{ j.nombre }} {{ j.apellido }}</span>
                  <span class="al-sidebar__pos">{{ j.posicion_juego || j.posicion }}</span>
                </div>
              </div>
            </div>

            <!-- Pitcher -->
            <div v-if="pitcher" class="al-sidebar__pitcher">
              <div class="al-sidebar__title" style="margin-top:16px">PITCHER</div>
              <div class="al-sidebar__item al-sidebar__item--pitcher">
                <span class="al-sidebar__num" style="color:#ff6b6b">P</span>
                <div class="al-sidebar__info">
                  <span class="al-sidebar__nombre">{{ pitcher.nombre }} {{ pitcher.apellido }}</span>
                  <span class="al-sidebar__pos">Lanzador</span>
                </div>
              </div>
            </div>

            <button class="al-sidebar__reset" @click="resetear">Reiniciar posiciones</button>
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
            <button class="al-modal__btn al-modal__btn--gold" @click="cargarPizarron">
              Ver en el Diamante
            </button>
          </div>
        </div>
      </div>
    </transition>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import api from '@/services/api'
import LandingHeader from '@/components/landing/LandingHeader.vue'

// ── Estado principal ──
const partidos          = ref([])
const cargandoPartidos  = ref(true)
const partidoActivo     = ref(null)
const lineupData        = ref([])
const cargandoLineup    = ref(false)
const equipoActivo      = ref('casa')
const modalPartido      = ref(null)
const campoRef          = ref(null)

// ── Posiciones de los tokens en el campo ──
// { key: { x: %, y: % } }
const posiciones = ref({})

// ── Drag state ──
const dragging = ref(null) // { key, offsetX, offsetY }

// ── Posiciones por defecto según posicion del jugador ──
const defaultPos = {
  'P':  { x: 50, y: 62 },
  'C':  { x: 50, y: 84 },
  '1B': { x: 71, y: 62 },
  '2B': { x: 61, y: 47 },
  '3B': { x: 29, y: 62 },
  'SS': { x: 39, y: 47 },
  'LF': { x: 20, y: 32 },
  'CF': { x: 50, y: 18 },
  'RF': { x: 80, y: 32 },
  'DH': { x: 50, y: 92 },
  'UT': { x: 15, y: 75 },
}

// ── Jugadores del equipo activo ──
const jugadoresActivos = computed(() => {
  if (!lineupData.value.length || !partidoActivo.value) return []
  const idEquipo = equipoActivo.value === 'casa'
    ? partidoActivo.value.id_equipo_casa
    : partidoActivo.value.id_equipo_visitante
  return lineupData.value.filter(j => j.id_equipo === idEquipo && j.es_titular)
})

const pitcher = computed(() =>
  jugadoresActivos.value.find(j => j.rol === 'pitcher' || (j.posicion_juego || j.posicion) === 'P')
)

// ── Key única por jugador ──
function jugadorKey(j) {
  return `${j.id_equipo}-${j.nombre}-${j.apellido}`
}

// ── Posición del token ──
function tokenStyle(jugador) {
  const key = jugadorKey(jugador)
  const pos = posiciones.value[key] || defaultPos[jugador.posicion_juego || jugador.posicion] || { x: 50, y: 50 }
  return {
    left: pos.x + '%',
    top:  pos.y + '%',
    transform: 'translate(-50%, -50%)',
    cursor: dragging.value?.key === key ? 'grabbing' : 'grab',
    zIndex: dragging.value?.key === key ? 100 : 10,
  }
}

// ── Inicializar posiciones ──
function inicializarPosiciones() {
  const nuevas = {}
  jugadoresActivos.value.forEach(j => {
    const key = jugadorKey(j)
    const pos = j.posicion_juego || j.posicion
    nuevas[key] = defaultPos[pos] || { x: 50, y: 50 }
  })
  posiciones.value = nuevas
}

function resetear() {
  inicializarPosiciones()
}

// ── Drag mouse ──
function startDrag(e, jugador) {
  dragging.value = { key: jugadorKey(jugador) }
}

function onMouseMove(e) {
  if (!dragging.value || !campoRef.value) return
  const rect = campoRef.value.getBoundingClientRect()
  const x = ((e.clientX - rect.left) / rect.width) * 100
  const y = ((e.clientY - rect.top)  / rect.height) * 100
  posiciones.value = {
    ...posiciones.value,
    [dragging.value.key]: {
      x: Math.max(5, Math.min(95, x)),
      y: Math.max(5, Math.min(97, y)),
    }
  }
}

function onMouseUp() {
  dragging.value = null
}

// ── Drag touch ──
function startDragTouch(e, jugador) {
  dragging.value = { key: jugadorKey(jugador) }
}

function onTouchMove(e) {
  if (!dragging.value || !campoRef.value) return
  const touch = e.touches[0]
  const rect = campoRef.value.getBoundingClientRect()
  const x = ((touch.clientX - rect.left) / rect.width) * 100
  const y = ((touch.clientY - rect.top)  / rect.height) * 100
  posiciones.value = {
    ...posiciones.value,
    [dragging.value.key]: {
      x: Math.max(5, Math.min(95, x)),
      y: Math.max(5, Math.min(97, y)),
    }
  }
}

function onTouchEnd() {
  dragging.value = null
}

// ── Cambiar equipo ──
function cambiarEquipo(equipo) {
  equipoActivo.value = equipo
  setTimeout(inicializarPosiciones, 50)
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

async function cargarPizarron() {
  const partido = modalPartido.value
  cerrarModal()
  partidoActivo.value = partido
  equipoActivo.value = 'casa'
  cargandoLineup.value = true
  lineupData.value = []
  posiciones.value = {}
  try {
    const { data } = await api.get(`/pub/lineup/${partido.id_partido}`)
    lineupData.value = data
    setTimeout(inicializarPosiciones, 100)
  } catch {
    lineupData.value = []
  } finally {
    cargandoLineup.value = false
  }
  setTimeout(() => {
    document.querySelector('.al-tabs')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }, 300)
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

// ── Limpiar drag si el mouse sale de la ventana ──
onMounted(async () => {
  window.addEventListener('mouseup', onMouseUp)
  try {
    const { data } = await api.get('/pub/partidos')
    partidos.value = data
  } catch {
    partidos.value = []
  } finally {
    cargandoPartidos.value = false
  }
})

onUnmounted(() => {
  window.removeEventListener('mouseup', onMouseUp)
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

/* ── Tabs ── */
.al-tabs {
  display: flex; gap: 8px; margin-bottom: 28px; flex-wrap: wrap;
}
.al-tab {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 13px; font-weight: 700; letter-spacing: 1px;
  text-transform: uppercase; padding: 10px 24px; border-radius: 999px;
  border: 1px solid rgba(255,255,255,0.1); background: transparent;
  color: var(--txt); cursor: pointer; transition: all 0.2s;
}
.al-tab:hover { border-color: var(--gold); color: var(--gold); }
.al-tab--active { background: var(--gold); color: var(--bg); border-color: var(--gold); }
.al-tab--reset {
  margin-left: auto; border-color: rgba(255,255,255,0.06); color: var(--txt-dim);
}
.al-tab--reset:hover { border-color: white; color: white; }

/* ── Pizarrón layout ── */
.al-pizarron-wrap {
  display: grid; grid-template-columns: 1fr 260px; gap: 24px; align-items: start;
}
@media (max-width: 900px) { .al-pizarron-wrap { grid-template-columns: 1fr; } }

/* ── Campo ── */
.al-campo {
  position: relative; width: 100%;
  aspect-ratio: 600/560;
  border-radius: 16px; overflow: hidden;
  box-shadow: 0 8px 40px rgba(0,0,0,0.6);
  user-select: none;
}
.al-campo__svg { width: 100%; height: 100%; display: block; }

/* ── Token jugador ── */
.al-jugador-token {
  position: absolute;
  display: flex; flex-direction: column; align-items: center; gap: 1px;
  transition: transform 0.05s;
}
.al-jugador-token--dragging { transition: none; }

.al-jugador-token__pos {
  width: 32px; height: 32px; border-radius: 50%;
  background: var(--gold); color: #1a0d0a;
  font-family: 'Bebas Neue', sans-serif; font-size: 13px; letter-spacing: 1px;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.5);
  border: 2px solid rgba(255,255,255,0.3);
}
.al-jugador-token--dragging .al-jugador-token__pos {
  background: white; transform: scale(1.15);
  box-shadow: 0 4px 16px rgba(0,0,0,0.7);
}
.al-jugador-token__nombre {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 9px; font-weight: 700; color: white;
  text-transform: uppercase; white-space: nowrap;
  background: rgba(0,0,0,0.6); padding: 1px 5px; border-radius: 4px;
  letter-spacing: 0.3px;
}
.al-jugador-token__num {
  font-family: 'Bebas Neue', sans-serif; font-size: 10px;
  color: var(--gold); line-height: 1;
}

/* ── Sidebar ── */
.al-sidebar {
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: 16px; padding: 20px 18px; display: flex; flex-direction: column; gap: 0;
}
.al-sidebar__title {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px; font-weight: 700; letter-spacing: 3px;
  color: var(--txt-dim); text-transform: uppercase; margin-bottom: 12px;
}
.al-sidebar__list { display: flex; flex-direction: column; gap: 2px; }
.al-sidebar__item {
  display: flex; align-items: center; gap: 10px;
  padding: 7px 8px; border-radius: 8px; transition: background 0.15s;
}
.al-sidebar__item:hover { background: rgba(255,255,255,0.04); }
.al-sidebar__item--pitcher { background: rgba(140,9,2,0.1); border: 1px solid rgba(140,9,2,0.2); }
.al-sidebar__num {
  font-family: 'Bebas Neue', sans-serif; font-size: 18px;
  color: var(--gold); width: 20px; text-align: center; flex-shrink: 0;
}
.al-sidebar__info { display: flex; flex-direction: column; gap: 1px; }
.al-sidebar__nombre {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 13px; font-weight: 700; color: white; text-transform: uppercase;
}
.al-sidebar__pos { font-size: 11px; color: var(--txt-dim); }

.al-sidebar__pitcher { display: flex; flex-direction: column; }
.al-sidebar__reset {
  margin-top: 16px; background: transparent;
  border: 1px solid rgba(255,255,255,0.08); color: var(--txt-dim);
  font-family: 'Barlow Condensed', sans-serif; font-size: 12px; font-weight: 700;
  letter-spacing: 1px; text-transform: uppercase; padding: 8px;
  border-radius: 8px; cursor: pointer; transition: all 0.2s;
}
.al-sidebar__reset:hover { border-color: var(--gold); color: var(--gold); }

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