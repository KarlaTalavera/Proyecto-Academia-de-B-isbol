<template>
  <div class="lj-page">
    <LandingHeader />

    <!-- HERO -->
    <section class="lj-hero">
      <div class="lj-hero__content">
        <p class="lj-hero__kicker">LIGA DIAMANTE · TEMPORADA ACTIVA</p>
        <h1 class="lj-hero__title">PLANTILLAS<br /><span class="lj-hero__accent">& PERFILES</span></h1>
        <p class="lj-hero__sub">Busca cualquier jugador y conoce sus estadísticas de carrera</p>
      </div>
      <div class="lj-hero__diamond">◆</div>
    </section>

    <!-- FILTROS -->
    <div class="lj-filters">
      <div class="lj-filters__inner">
        <div class="lj-search-wrap">
          <span class="lj-search-icon">⚾</span>
          <input
            v-model="busqueda"
            class="lj-search"
            placeholder="Buscar jugador por nombre..."
            @input="onBuscar"
          />
        </div>
        <select v-model="equipoFiltro" class="lj-select" @change="cargar">
          <option value="">Todos los equipos</option>
          <option v-for="eq in equipos" :key="eq.id_equipo" :value="eq.id_equipo">
            {{ eq.nombre_equipo }}
          </option>
        </select>
      </div>
    </div>

    <!-- CONTENIDO -->
    <section class="lj-section">
      <div class="lj-container">

        <div v-if="cargando" class="lj-grid">
          <div v-for="i in 12" :key="i" class="lj-skeleton" />
        </div>

        <div v-else-if="error" class="lj-empty">
          <p class="lj-empty__icon">⚠</p>
          <p class="lj-empty__msg">{{ error }}</p>
        </div>

        <div v-else-if="!jugadores.length" class="lj-empty">
          <p class="lj-empty__icon">🔍</p>
          <p class="lj-empty__msg">No se encontraron jugadores con esos filtros</p>
        </div>

        <div v-else>
          <p class="lj-count">{{ jugadores.length }} jugador(es) encontrado(s)</p>
          <div class="lj-grid">
            <div
              v-for="j in jugadores"
              :key="j.id_jugador"
              class="lj-card"
              @click="abrirPerfil(j)"
            >
              <!-- Foto / Avatar -->
              <div class="lj-card__foto-wrap">
                <img v-if="j.foto_url" :src="apiBase + j.foto_url" :alt="j.nombre"
                  class="lj-card__foto" @error="j.foto_url = null" />
                <div v-else class="lj-card__avatar">
                  {{ j.nombre?.charAt(0)?.toUpperCase() }}{{ j.apellido?.charAt(0)?.toUpperCase() }}
                </div>
              </div>
              <!-- Info -->
              <div class="lj-card__body">
                <h3 class="lj-card__name">{{ j.nombre }} {{ j.apellido }}</h3>
                <span class="lj-card__pos">{{ j.posicion }} · {{ j.rol }}</span>
                <div class="lj-card__equipo">
                  <img v-if="j.equipo_logo_url" :src="apiBase + j.equipo_logo_url"
                    style="width:16px;height:16px;object-fit:contain;border-radius:3px;" @error="j.equipo_logo_url = null" />
                  <span>{{ j.nombre_equipo }}</span>
                </div>
              </div>
              <span class="lj-card__arrow">→</span>
            </div>
          </div>
        </div>

      </div>
    </section>

    <!-- MODAL PERFIL -->
    <transition name="lj-fade">
      <div v-if="perfil" class="lj-overlay" @click.self="cerrarPerfil">
        <div class="lj-modal">
          <button class="lj-modal__close" @click="cerrarPerfil">✕</button>

          <div v-if="cargandoPerfil" class="lj-modal__loading">
            Cargando perfil...
          </div>

          <template v-else-if="perfil">
            <!-- Header -->
            <div class="lj-modal__header">
              <div class="lj-modal__foto-wrap">
                <img v-if="perfil.foto_url" :src="apiBase + perfil.foto_url"
                  class="lj-modal__foto" @error="perfil.foto_url = null" />
                <div v-else class="lj-modal__avatar">
                  {{ perfil.nombre?.charAt(0) }}{{ perfil.apellido?.charAt(0) }}
                </div>
              </div>
              <div class="lj-modal__header-info">
                <h2 class="lj-modal__nombre">{{ perfil.nombre }} {{ perfil.apellido }}</h2>
                <p class="lj-modal__sub">{{ perfil.posicion }} · {{ perfil.rol }}</p>
                <div class="lj-modal__equipo-row">
                  <img v-if="perfil.equipo_logo_url" :src="apiBase + perfil.equipo_logo_url"
                    style="width:20px;height:20px;object-fit:contain;border-radius:4px;" @error="perfil.equipo_logo_url = null" />
                  <span>{{ perfil.nombre_equipo }}</span>
                </div>
              </div>
            </div>

            <!-- Info personal -->
            <div class="lj-modal__info-grid">

              <div class="lj-modal__info-item" v-if="perfil.fecha_nacimiento">
                <span class="lj-modal__info-lbl">Fecha Nac.</span>
                <span class="lj-modal__info-val">{{ formatFecha(perfil.fecha_nacimiento) }}</span>
              </div>
              <div class="lj-modal__info-item" v-if="perfil.brazo_dominante">
                <span class="lj-modal__info-lbl">Brazo</span>
                <span class="lj-modal__info-val">{{ perfil.brazo_dominante }}</span>
              </div>
            </div>

            <!-- Estadísticas de bateo -->
            <div v-if="perfil.rol !== 'pitcher' && perfil.bateo?.AB > 0" class="lj-modal__stats-section">
              <p class="lj-modal__stats-title">ESTADÍSTICAS DE BATEO</p>
              <div class="lj-modal__stats-grid">
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.bateo.juegos_jugados }}</span>
                  <span class="lj-modal__stat-lbl">JJ</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.bateo.AB }}</span>
                  <span class="lj-modal__stat-lbl">AB</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.bateo.H }}</span>
                  <span class="lj-modal__stat-lbl">H</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.bateo.HR }}</span>
                  <span class="lj-modal__stat-lbl">HR</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.bateo.RBI }}</span>
                  <span class="lj-modal__stat-lbl">RBI</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val lj-modal__stat-val--gold">{{ formatAvg(perfil.bateo.AVG) }}</span>
                  <span class="lj-modal__stat-lbl">AVG</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.bateo.BB }}</span>
                  <span class="lj-modal__stat-lbl">BB</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.bateo.R }}</span>
                  <span class="lj-modal__stat-lbl">R</span>
                </div>
              </div>
            </div>

            <!-- Estadísticas de pitcheo -->
            <div v-if="(perfil.rol === 'pitcher' || perfil.rol === 'utilidad') && perfil.pitcheo?.IP > 0" class="lj-modal__stats-section">
              <p class="lj-modal__stats-title">ESTADÍSTICAS DE PITCHEO</p>
              <div class="lj-modal__stats-grid">
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.pitcheo.juegos_jugados }}</span>
                  <span class="lj-modal__stat-lbl">JJ</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.pitcheo.IP }}</span>
                  <span class="lj-modal__stat-lbl">IP</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.pitcheo.W }}</span>
                  <span class="lj-modal__stat-lbl">W</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.pitcheo.L }}</span>
                  <span class="lj-modal__stat-lbl">L</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.pitcheo.K }}</span>
                  <span class="lj-modal__stat-lbl">K</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val lj-modal__stat-val--gold">{{ perfil.pitcheo.ERA }}</span>
                  <span class="lj-modal__stat-lbl">ERA</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.pitcheo.BB }}</span>
                  <span class="lj-modal__stat-lbl">BB</span>
                </div>
                <div class="lj-modal__stat">
                  <span class="lj-modal__stat-val">{{ perfil.pitcheo.SV }}</span>
                  <span class="lj-modal__stat-lbl">SV</span>
                </div>
              </div>
            </div>

            <!-- Sin estadísticas -->
            <div v-if="!hayStat" class="lj-modal__no-stats">
              Aún no hay estadísticas registradas para este jugador.
            </div>
          </template>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import LandingHeader from '@/components/landing/LandingHeader.vue'
import api from '@/services/api'

const apiBase = import.meta.env.VITE_API_URL?.replace('/api', '') || 'http://localhost:3000'

const jugadores    = ref([])
const equipos      = ref([])
const busqueda     = ref('')
const equipoFiltro = ref('')
const cargando     = ref(false)
const error        = ref(null)

const perfil          = ref(null)
const cargandoPerfil  = ref(false)

const hayStat = computed(() => {
  if (!perfil.value) return false
  return perfil.value.bateo?.AB > 0 || perfil.value.pitcheo?.IP > 0
})

let buscarTimeout = null
function onBuscar() {
  clearTimeout(buscarTimeout)
  buscarTimeout = setTimeout(cargar, 350)
}

async function cargar() {
  cargando.value = true
  error.value    = null
  try {
    const params = {}
    if (busqueda.value)   params.busqueda = busqueda.value
    if (equipoFiltro.value) params.equipo = equipoFiltro.value
    const [resJ, resE] = await Promise.all([
      api.get('/pub/jugadores-liga', { params }),
      equipos.value.length ? Promise.resolve({ data: equipos.value }) : api.get('/pub/equipos'),
    ])
    jugadores.value = resJ.data
    if (!equipos.value.length) equipos.value = resE.data
  } catch {
    error.value = 'No se pudieron cargar los jugadores. Verifica la conexión.'
  } finally {
    cargando.value = false
  }
}

async function abrirPerfil(jugador) {
  perfil.value         = { ...jugador }
  cargandoPerfil.value = true
  document.body.style.overflow = 'hidden'
  try {
    const { data } = await api.get(`/pub/jugadores-liga/${jugador.id_jugador}`)
    perfil.value = data
  } catch {
    // mantener datos básicos si falla
  } finally {
    cargandoPerfil.value = false
  }
}

function cerrarPerfil() {
  perfil.value = null
  document.body.style.overflow = ''
}

function formatFecha(f) {
  if (!f) return ''
  const d = new Date(f)
  return d.toLocaleDateString('es-VE', { day: 'numeric', month: 'long', year: 'numeric' })
}

function formatAvg(val) {
  if (!val) return '.000'
  return '.' + String(Math.round(val * 1000)).padStart(3, '0')
}

// Cargar al montar
cargar()
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Barlow+Condensed:wght@400;700&family=Barlow:wght@400;500&display=swap');

.lj-page {
  --gold:    #D4AF37;
  --red:     #8C0902;
  --bg:      #0d0908;
  --bg-dark: #080504;
  --bg-card: #160c0a;
  --border:  rgba(212,175,55,0.12);
  --txt:     rgba(255,255,255,0.7);
  --txt-dim: rgba(255,255,255,0.35);
  background: var(--bg);
  color: white;
  font-family: 'Barlow', sans-serif;
  min-height: 100vh;
  overflow-x: hidden;
}

/* ── Hero ── */
.lj-hero {
  position: relative;
  min-height: 360px;
  display: flex;
  align-items: flex-end;
  padding: 130px 60px 64px;
  overflow: hidden;
  background:
    radial-gradient(ellipse 55% 65% at 80% 50%, rgba(140,9,2,0.2) 0%, transparent 70%),
    var(--bg-dark);
  border-bottom: 1px solid var(--border);
}
.lj-hero__content { position: relative; z-index: 2; }
.lj-hero__kicker {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px; font-weight: 700; letter-spacing: 5px;
  color: var(--gold); text-transform: uppercase; margin: 0 0 16px;
}
.lj-hero__title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(56px, 10vw, 112px);
  line-height: 0.9; margin: 0; letter-spacing: 2px;
}
.lj-hero__accent { color: var(--gold); }
.lj-hero__sub {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 15px; color: var(--txt); margin: 16px 0 0;
}
.lj-hero__diamond {
  position: absolute; right: 6%; bottom: -40px;
  font-size: clamp(160px, 24vw, 320px);
  color: rgba(212,175,55,0.03);
  user-select: none; pointer-events: none;
  animation: spin 80s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ── Filters ── */
.lj-filters {
  background: rgba(255,255,255,0.03);
  border-bottom: 1px solid var(--border);
  padding: 16px 0;
}
.lj-filters__inner {
  max-width: 1100px; margin: 0 auto; padding: 0 32px;
  display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
}
.lj-search-wrap {
  display: flex; align-items: center; gap: 10px;
  background: rgba(255,255,255,0.05);
  border: 1px solid var(--border); border-radius: 10px;
  padding: 8px 14px; flex: 1; min-width: 220px; max-width: 380px;
}
.lj-search-icon { font-size: 14px; opacity: 0.5; }
.lj-search {
  background: transparent; border: none; outline: none;
  color: white; font-family: 'Barlow', sans-serif; font-size: 14px;
  width: 100%;
}
.lj-search::placeholder { color: var(--txt-dim); }
.lj-select {
  background: rgba(255,255,255,0.05);
  border: 1px solid var(--border); border-radius: 10px;
  color: white; font-family: 'Barlow Condensed', sans-serif;
  font-size: 13px; font-weight: 700; letter-spacing: 1px;
  padding: 8px 14px; cursor: pointer; outline: none;
}
.lj-select option { background: #1a0e0b; }

/* ── Section ── */
.lj-section { padding: 60px 0 100px; }
.lj-container { max-width: 1100px; margin: 0 auto; padding: 0 32px; }
.lj-count {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px; font-weight: 700; letter-spacing: 3px;
  color: var(--txt-dim); text-transform: uppercase;
  margin-bottom: 20px;
}

/* ── Grid ── */
.lj-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 12px;
}

/* ── Skeleton ── */
.lj-skeleton {
  height: 140px; border-radius: 16px;
  background: linear-gradient(90deg, rgba(255,255,255,0.04) 25%, rgba(255,255,255,0.08) 50%, rgba(255,255,255,0.04) 75%);
  background-size: 200% 100%;
  animation: shimmer 1.4s infinite;
}
@keyframes shimmer { to { background-position: -200% 0; } }

/* ── Card ── */
.lj-card {
  background: var(--bg-card);
  border: 1px solid var(--border); border-radius: 16px;
  padding: 16px; cursor: pointer;
  display: flex; align-items: center; gap: 12px;
  transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s;
}
.lj-card:hover {
  transform: translateY(-3px);
  border-color: rgba(212,175,55,0.4);
  box-shadow: 0 8px 28px rgba(0,0,0,0.4);
}
.lj-card__foto-wrap { flex-shrink: 0; }
.lj-card__foto {
  width: 52px; height: 52px; border-radius: 50%;
  object-fit: cover; object-position: top;
  border: 2px solid rgba(255,255,255,0.1);
}
.lj-card__avatar {
  width: 52px; height: 52px; border-radius: 50%;
  background: linear-gradient(135deg, rgba(140,9,2,0.5), rgba(212,175,55,0.2));
  border: 2px solid rgba(212,175,55,0.2);
  display: flex; align-items: center; justify-content: center;
  font-family: 'Bebas Neue', sans-serif; font-size: 17px; color: var(--gold);
}
.lj-card__body { flex: 1; min-width: 0; }
.lj-card__name {
  font-family: 'Bebas Neue', sans-serif; font-size: 16px;
  margin: 0 0 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.lj-card__pos {
  display: block;
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px; font-weight: 700; letter-spacing: 2px;
  color: var(--gold); text-transform: uppercase; margin-bottom: 4px;
}
.lj-card__equipo {
  display: flex; align-items: center; gap: 5px;
  font-size: 11px; color: var(--txt-dim);
}
.lj-card__arrow { font-size: 14px; color: var(--txt-dim); opacity: 0.4; transition: opacity 0.2s; }
.lj-card:hover .lj-card__arrow { opacity: 1; color: var(--gold); }

/* ── Empty ── */
.lj-empty { text-align: center; padding: 60px 0; }
.lj-empty__icon { font-size: 40px; display: block; margin-bottom: 12px; }
.lj-empty__msg { color: var(--txt-dim); font-size: 15px; }

/* ── Modal overlay ── */
.lj-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.88);
  display: flex; align-items: center; justify-content: center;
  z-index: 1000; padding: 20px;
  backdrop-filter: blur(8px);
}

/* ── Modal ── */
.lj-modal {
  background: #130a08;
  border: 1px solid var(--border); border-radius: 22px;
  max-width: 500px; width: 100%; max-height: 90vh;
  overflow-y: auto; position: relative;
  scrollbar-width: thin; scrollbar-color: var(--border) transparent;
}
.lj-modal__close {
  position: sticky; top: 12px; float: right; margin: 12px 14px 0 0;
  background: rgba(255,255,255,0.07); border: none; color: white;
  width: 30px; height: 30px; border-radius: 50%;
  font-size: 13px; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: background 0.2s; z-index: 10;
}
.lj-modal__close:hover { background: var(--red); }

.lj-modal__loading {
  text-align: center; color: var(--txt-dim); padding: 60px 20px;
  font-size: 14px; clear: both;
}

/* ── Header del modal ── */
.lj-modal__header {
  padding: 28px 24px 20px; clear: both;
  display: flex; align-items: center; gap: 16px;
  border-bottom: 1px solid var(--border);
}
.lj-modal__foto-wrap { flex-shrink: 0; }
.lj-modal__foto {
  width: 80px; height: 80px; border-radius: 50%;
  object-fit: cover; object-position: top;
  border: 3px solid rgba(212,175,55,0.2);
}
.lj-modal__avatar {
  width: 80px; height: 80px; border-radius: 50%;
  background: linear-gradient(135deg, rgba(140,9,2,0.6), rgba(212,175,55,0.15));
  border: 3px solid rgba(212,175,55,0.2);
  display: flex; align-items: center; justify-content: center;
  font-family: 'Bebas Neue', sans-serif; font-size: 28px; color: var(--gold);
}
.lj-modal__nombre {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 24px; margin: 0 0 4px; letter-spacing: 1px;
}
.lj-modal__sub {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; color: var(--gold); margin: 0 0 6px;
}
.lj-modal__equipo-row {
  display: flex; align-items: center; gap: 6px;
  font-size: 12px; color: var(--txt-dim);
}

/* ── Info grid ── */
.lj-modal__info-grid {
  display: flex; flex-wrap: wrap; gap: 16px;
  padding: 16px 24px;
  border-bottom: 1px solid var(--border);
}
.lj-modal__info-item { display: flex; flex-direction: column; gap: 2px; }
.lj-modal__info-lbl {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 9px; font-weight: 700; letter-spacing: 2px;
  color: var(--txt-dim); text-transform: uppercase;
}
.lj-modal__info-val { font-size: 13px; color: rgba(255,255,255,0.85); }

/* ── Stats ── */
.lj-modal__stats-section { padding: 18px 24px; border-bottom: 1px solid var(--border); }
.lj-modal__stats-section:last-child { border-bottom: none; }
.lj-modal__stats-title {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px; font-weight: 700; letter-spacing: 3px;
  color: var(--gold); text-transform: uppercase; margin: 0 0 12px;
}
.lj-modal__stats-grid {
  display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px;
}
.lj-modal__stat {
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border); border-radius: 10px;
  padding: 10px 6px;
  display: flex; flex-direction: column; align-items: center; gap: 3px;
}
.lj-modal__stat-val {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 20px; line-height: 1; color: white;
}
.lj-modal__stat-val--gold { color: var(--gold); }
.lj-modal__stat-lbl {
  font-size: 8px; color: var(--txt-dim);
  letter-spacing: 1px; text-transform: uppercase; text-align: center;
}
.lj-modal__no-stats {
  padding: 24px; text-align: center;
  color: var(--txt-dim); font-size: 13px; line-height: 1.6;
}

/* ── Transitions ── */
.lj-fade-enter-active, .lj-fade-leave-active { transition: opacity 0.22s ease; }
.lj-fade-enter-from, .lj-fade-leave-to { opacity: 0; }

@media (max-width: 600px) {
  .lj-hero { padding: 110px 20px 52px; }
  .lj-container { padding: 0 16px; }
  .lj-modal__stats-grid { grid-template-columns: repeat(4, 1fr); }
}
</style>
