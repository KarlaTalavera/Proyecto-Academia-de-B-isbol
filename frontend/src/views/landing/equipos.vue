<template>
  <div class="eq-page">
    <LandingHeader />

    <!-- ── HERO ── -->
    <section class="eq-hero">
      <div class="eq-hero__glow" />
      <div class="eq-hero__content">
        <p class="eq-hero__kicker">CLAUSURA 2026 · TEMPORADA ACTIVA</p>
        <h1 class="eq-hero__title">
          LOS<br />
          <span class="eq-hero__title--accent">EQUIPOS</span>
        </h1>
        <p class="eq-hero__sub">
          Conoce a los clubes que compiten por el título<br />
          de campeón de la Liga Diamante 2026.
        </p>
      </div>
      <div class="eq-hero__deco">◆</div>
    </section>

    <!-- ── STRIP ── -->
    <div class="eq-strip">
      <div class="eq-strip__inner">
        <div class="eq-strip__item">
          <span class="eq-strip__val">{{ equipos.length }}</span>
          <span class="eq-strip__lbl">EQUIPOS</span>
        </div>
        <div class="eq-strip__sep">◆</div>
        <div class="eq-strip__item">
          <span class="eq-strip__val">{{ equipos.length * 10 }}</span>
          <span class="eq-strip__lbl">JUGADORES</span>
        </div>
        <div class="eq-strip__sep">◆</div>
        <div class="eq-strip__item">
          <span class="eq-strip__val">Semi-Pro</span>
          <span class="eq-strip__lbl">CATEGORÍA</span>
        </div>
        <div class="eq-strip__sep">◆</div>
        <div class="eq-strip__item">
          <span class="eq-strip__val">2026</span>
          <span class="eq-strip__lbl">TEMPORADA</span>
        </div>
      </div>
    </div>

    <!-- ── SKELETON ── -->
    <section v-if="cargando" class="eq-section">
      <div class="eq-container">
        <div class="eq-grid">
          <div v-for="i in 8" :key="i" class="eq-skeleton" />
        </div>
      </div>
    </section>

    <!-- ── ERROR ── -->
    <section v-else-if="error" class="eq-section">
      <div class="eq-container eq-error">
        <span class="eq-error__icon">⚠️</span>
        <p class="eq-error__text">{{ error }}</p>
        <button class="eq-error__btn" @click="cargarEquipos">Reintentar</button>
      </div>
    </section>

    <!-- ── GRID DE EQUIPOS ── -->
    <section v-else class="eq-section">
      <div class="eq-container">
        <span class="eq-eyebrow eq-eyebrow--center">CLAUSURA 2026</span>
        <h2 class="eq-title eq-title--center">
          Los <em>{{ equipos.length }} equipos</em><br />de la temporada
        </h2>

        <div class="eq-grid">
          <div
            v-for="(team, i) in equipos"
            :key="team.id_equipo"
            class="eq-card"
            :style="{ '--team-color': teamColor(i) }"
            @click="openModal(team, i)"
          >
            <!-- Logo -->
            <div class="eq-card__logo-wrap">
              <div class="eq-card__logo-bg" />

              <!-- Si existe el logo lo muestra, si no muestra iniciales SVG -->
              <img
                v-if="logoExists(team.id_equipo)"
                :src="logoSrc(team.id_equipo)"
                :alt="team.nombre_equipo"
                class="eq-card__logo-img"
                @error="onLogoError(team.id_equipo)"
              />
              <svg v-else class="eq-card__logo-svg" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                <path d="M50 8 L82 20 L82 55 Q82 75 50 92 Q18 75 18 55 L18 20 Z"
                  :fill="teamColor(i)" opacity="0.15" />
                <path d="M50 8 L82 20 L82 55 Q82 75 50 92 Q18 75 18 55 L18 20 Z"
                  fill="none" :stroke="teamColor(i)" stroke-width="2" />
                <text x="50" y="58" text-anchor="middle" dominant-baseline="middle"
                  :fill="teamColor(i)" font-family="'Bebas Neue', sans-serif"
                  font-size="26" letter-spacing="2">
                  {{ initials(team.nombre_equipo) }}
                </text>
              </svg>
            </div>

            <!-- Info -->
            <div class="eq-card__body">
              <h3 class="eq-card__name">{{ team.nombre_equipo }}</h3>
              <div class="eq-card__meta">
                <div class="eq-card__meta-item">
                  <span class="eq-card__meta-lbl">Director Técnico</span>
                  <span class="eq-card__meta-val">{{ team.entrenador }}</span>
                </div>
                <div class="eq-card__meta-item">
                  <span class="eq-card__meta-lbl">Jugadores</span>
                  <span class="eq-card__meta-val">10</span>
                </div>
              </div>
              <button class="eq-card__btn">VER DETALLE →</button>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ── CTA ── -->
    <section class="eq-cta">
      <div class="eq-cta__deco">◆</div>
      <div class="eq-cta__content">
        <h2 class="eq-cta__title">¿Ya viste<br /><em>los equipo?</em></h2>
        <p class="eq-cta__sub">Sigue las noticias y no te pierdas ningún juego de la temporada.</p>
        <div class="eq-cta__btns">
          <router-link to="/noticias" class="eq-cta__btn eq-cta__btn--gold">NOTICIAS</router-link>
          <router-link to="/standing" class="eq-cta__btn eq-cta__btn--outline">STANDING</router-link>
        </div>
      </div>
    </section>

    <!-- ── MODAL ── -->
    <transition name="eq-fade">
      <div v-if="selected" class="eq-modal-overlay" @click.self="closeModal">
        <div class="eq-modal" :style="{ '--team-color': selectedColor }">
          <button class="eq-modal__close" @click="closeModal">✕</button>

          <div class="eq-modal__header">
            <!-- Logo modal -->
            <div class="eq-modal__logo-wrap">
              <img
                v-if="logoExists(selected.id_equipo)"
                :src="logoSrc(selected.id_equipo)"
                :alt="selected.nombre_equipo"
                class="eq-modal__logo-img"
                @error="onLogoError(selected.id_equipo)"
              />
              <svg v-else class="eq-modal__logo-svg" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                <path d="M50 8 L82 20 L82 55 Q82 75 50 92 Q18 75 18 55 L18 20 Z"
                  :fill="selectedColor" opacity="0.2" />
                <path d="M50 8 L82 20 L82 55 Q82 75 50 92 Q18 75 18 55 L18 20 Z"
                  fill="none" :stroke="selectedColor" stroke-width="2" />
                <text x="50" y="58" text-anchor="middle" dominant-baseline="middle"
                  :fill="selectedColor" font-family="'Bebas Neue', sans-serif"
                  font-size="26" letter-spacing="2">
                  {{ initials(selected.nombre_equipo) }}
                </text>
              </svg>
            </div>

            <div class="eq-modal__header-info">
              <h2 class="eq-modal__name">{{ selected.nombre_equipo }}</h2>
            </div>
          </div>

          <div class="eq-modal__body">
            <div class="eq-modal__grid">
              <div class="eq-modal__item">
                <span class="eq-modal__lbl">Director Técnico</span>
                <span class="eq-modal__val">{{ selected.entrenador }}</span>
              </div>
              <div class="eq-modal__item">
                <span class="eq-modal__lbl">Responsable</span>
                <span class="eq-modal__val">{{ selected.responsable }}</span>
              </div>
              <div class="eq-modal__item">
                <span class="eq-modal__lbl">Correo</span>
                <span class="eq-modal__val">{{ selected.email || '—' }}</span>
              </div>
              <div class="eq-modal__item">
                <span class="eq-modal__lbl">Teléfono</span>
                <span class="eq-modal__val">{{ selected.telefono || '—' }}</span>
              </div>
              <div class="eq-modal__item">
                <span class="eq-modal__lbl">Jugadores</span>
                <span class="eq-modal__val">10 registrados</span>
              </div>
              <div class="eq-modal__item">
                <span class="eq-modal__lbl">Temporada</span>
                <span class="eq-modal__val">Clausura 2026</span>
              </div>
            </div>

            <div v-if="!logoExists(selected.id_equipo)" class="eq-modal__logo-note">
              📁 No se encontró el logo para este equipo en <strong>/public/logos/</strong>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import LandingHeader from '@/components/landing/LandingHeader.vue'

// ── Estado ──
const equipos   = ref([])
const cargando  = ref(true)
const error     = ref(null)
const selected  = ref(null)
const selectedIndex = ref(0)

// IDs de logos que fallaron al cargar
const logosFallidos = ref(new Set())

// ── Mapa de logos por id_equipo ──
const logoMap = {
  1: '/logos/leones.jpg',
  2: '/logos/tigres-de-aragua-l.png',
  3: '/logos/aguilas-del-zulia.png',
  4: '/logos/Magallanes_B.B.C.png',
  5: '/logos/CaribesBBC_Anzoátegui.png',
  6: '/logos/bravos-de-margarita.png',
  7: '/logos/cardenales.JPG',
  8: '/logos/tiburones-de-la-guaira-.png',
}

// ── Colores por índice ──
const colores = [
  '#E8B84B', '#E85D1A', '#5B9BD5', '#4ECDC4',
  '#A8E063', '#FF6B9D', '#E84545', '#7B8CE4',
]
const teamColor = (i) => colores[i % colores.length]
const selectedColor = computed(() => teamColor(selectedIndex.value))

// ── Helpers ──
function initials(name) {
  return name
    .split(' ')
    .filter(w => w.length > 2)
    .slice(0, 2)
    .map(w => w[0])
    .join('')
    .toUpperCase()
}

function logoSrc(id) {
  return logoMap[id] || null
}

function logoExists(id) {
  return !!logoMap[id] && !logosFallidos.value.has(id)
}

function onLogoError(id) {
  logosFallidos.value = new Set([...logosFallidos.value, id])
}

// ── Modal ──
function openModal(team, index) {
  selected.value      = team
  selectedIndex.value = index
  document.body.style.overflow = 'hidden'
}
function closeModal() {
  selected.value = null
  document.body.style.overflow = ''
}

// ── API ──
async function cargarEquipos() {
  cargando.value = true
  error.value    = null
  try {
    const { data } = await api.get('/pub/equipos')
    equipos.value  = data
  } catch (e) {
    error.value = 'No se pudieron cargar los equipos. Intenta de nuevo.'
  } finally {
    cargando.value = false
  }
}

onMounted(cargarEquipos)
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Barlow+Condensed:wght@400;700&family=Barlow:wght@400;500&display=swap');

.eq-page {
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
.eq-hero {
  position: relative;
  min-height: 460px;
  display: flex;
  align-items: flex-end;
  padding: 140px 60px 80px;
  overflow: hidden;
  background:
    radial-gradient(ellipse 55% 65% at 85% 50%, rgba(140,9,2,0.2) 0%, transparent 70%),
    var(--bg-dark);
  border-bottom: 1px solid var(--border);
}
.eq-hero__glow {
  position: absolute; inset: 0;
  background: radial-gradient(ellipse 40% 40% at 15% 80%, rgba(212,175,55,0.04) 0%, transparent 60%);
  pointer-events: none;
}
.eq-hero__content { position: relative; z-index: 2; max-width: 680px; }
.eq-hero__kicker {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px; font-weight: 700; letter-spacing: 5px;
  color: var(--gold); text-transform: uppercase;
  margin: 0 0 20px;
  display: flex; align-items: center; gap: 14px;
}
.eq-hero__kicker::before {
  content: ''; display: block;
  width: 36px; height: 2px; background: var(--red); flex-shrink: 0;
}
.eq-hero__title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(80px, 13vw, 152px);
  line-height: 0.9; margin: 0 0 24px; color: white; letter-spacing: 2px;
}
.eq-hero__title--accent { color: var(--gold); }
.eq-hero__sub {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 18px; color: var(--txt); line-height: 1.65; margin: 0;
}
.eq-hero__deco {
  position: absolute; right: 60px; top: 50%;
  transform: translateY(-50%);
  font-size: clamp(120px, 18vw, 260px);
  color: rgba(212,175,55,0.04);
  user-select: none; pointer-events: none;
  animation: spin 50s linear infinite;
}
@keyframes spin { to { transform: translateY(-50%) rotate(360deg); } }

/* ── Strip ── */
.eq-strip { background: var(--red); border-bottom: 3px solid var(--gold); }
.eq-strip__inner {
  max-width: 1200px; margin: 0 auto; padding: 0 60px;
  display: flex; align-items: center;
}
@media (max-width: 768px) { .eq-strip__inner { flex-wrap: wrap; padding: 0 24px; } }
.eq-strip__item {
  flex: 1; padding: 20px 0;
  display: flex; flex-direction: column; gap: 3px; min-width: 80px;
}
.eq-strip__sep { color: rgba(255,255,255,0.2); font-size: 10px; padding: 0 16px; }
.eq-strip__val {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 26px; color: var(--gold); line-height: 1;
}
.eq-strip__lbl {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px; font-weight: 700; letter-spacing: 3px;
  color: rgba(255,255,255,0.5); text-transform: uppercase;
}

/* ── Sections ── */
.eq-section       { padding: 96px 0; }
.eq-section--dark { background: var(--bg-dark); }
.eq-container {
  max-width: 1200px; margin: 0 auto; padding: 0 60px;
}
@media (max-width: 768px) {
  .eq-container { padding: 0 24px; }
  .eq-section   { padding: 64px 0; }
}

/* ── Eyebrow / Title ── */
.eq-eyebrow {
  display: block;
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px; font-weight: 700; letter-spacing: 5px;
  color: var(--gold); text-transform: uppercase; margin-bottom: 14px;
}
.eq-eyebrow--center { text-align: center; }
.eq-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(38px, 5vw, 60px);
  line-height: 1.0; color: white; margin: 0 0 56px; letter-spacing: 1px;
}
.eq-title em      { color: var(--gold); font-style: normal; }
.eq-title--center { text-align: center; }

/* ── Skeleton ── */
.eq-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}
@media (max-width: 1100px) { .eq-grid { grid-template-columns: repeat(3, 1fr); } }
@media (max-width: 768px)  { .eq-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 480px)  { .eq-grid { grid-template-columns: 1fr; } }

.eq-skeleton {
  height: 280px;
  border-radius: 20px;
  background: linear-gradient(90deg,
    rgba(255,255,255,0.04) 25%,
    rgba(255,255,255,0.08) 50%,
    rgba(255,255,255,0.04) 75%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
}
@keyframes shimmer { to { background-position: -200% 0; } }

/* ── Error ── */
.eq-error {
  display: flex; flex-direction: column;
  align-items: center; gap: 16px; padding: 80px 0; text-align: center;
}
.eq-error__icon { font-size: 48px; }
.eq-error__text { color: var(--txt); font-size: 15px; }
.eq-error__btn {
  background: transparent; border: 1px solid var(--gold);
  color: var(--gold); font-family: 'Barlow Condensed', sans-serif;
  font-size: 13px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; padding: 10px 28px; border-radius: 999px;
  cursor: pointer; transition: all 0.2s;
}
.eq-error__btn:hover { background: var(--gold); color: var(--bg); }

/* ── Cards ── */
.eq-card {
  background: var(--bg-card);
  border: 1px solid rgba(255,255,255,0.06);
  border-radius: 20px; overflow: hidden;
  cursor: pointer;
  transition: transform 0.25s ease, border-color 0.25s ease, box-shadow 0.25s ease;
  display: flex; flex-direction: column;
}
.eq-card:hover {
  transform: translateY(-6px);
  border-color: var(--team-color, var(--gold));
  box-shadow: 0 16px 40px rgba(0,0,0,0.5), 0 0 0 1px var(--team-color, var(--gold));
}

/* Logo area */
.eq-card__logo-wrap {
  position: relative;
  height: 150px;
  display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg,
    rgba(0,0,0,0.4) 0%,
    rgba(0,0,0,0.2) 100%
  );
  border-bottom: 1px solid rgba(255,255,255,0.05);
}
.eq-card__logo-bg {
  position: absolute; inset: 0;
  background: radial-gradient(ellipse 60% 60% at 50% 50%,
    color-mix(in srgb, var(--team-color, #D4AF37) 10%, transparent) 0%,
    transparent 70%
  );
}
.eq-card__logo-img {
  width: 90px; height: 90px;
  object-fit: contain;
  position: relative; z-index: 1;
  filter: drop-shadow(0 4px 12px rgba(0,0,0,0.5));
}
.eq-card__logo-svg {
  width: 80px; height: 80px;
  position: relative; z-index: 1;
  filter: drop-shadow(0 4px 12px rgba(0,0,0,0.4));
}

/* Body */
.eq-card__body {
  padding: 20px 18px 18px;
  display: flex; flex-direction: column; gap: 12px; flex: 1;
}
.eq-card__name {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 18px; letter-spacing: 1px; color: white;
  margin: 0; line-height: 1.1;
}
.eq-card__meta { display: flex; flex-direction: column; gap: 6px; }
.eq-card__meta-item { display: flex; justify-content: space-between; align-items: center; }
.eq-card__meta-lbl {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px; font-weight: 700; letter-spacing: 2px;
  color: var(--txt-dim); text-transform: uppercase;
}
.eq-card__meta-val { font-size: 12px; color: var(--txt); }
.eq-card__btn {
  margin-top: auto;
  background: transparent;
  border: 1px solid rgba(255,255,255,0.08);
  color: var(--txt-dim);
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px; font-weight: 700; letter-spacing: 2px;
  text-transform: uppercase; padding: 8px 0;
  border-radius: 8px; cursor: pointer;
  transition: all 0.2s; width: 100%;
}
.eq-card:hover .eq-card__btn {
  border-color: var(--team-color, var(--gold));
  color: var(--team-color, var(--gold));
}

/* ── CTA ── */
.eq-cta {
  position: relative; overflow: hidden;
  padding: 120px 60px; text-align: center;
  background:
    radial-gradient(ellipse 50% 70% at 50% 50%, rgba(140,9,2,0.22) 0%, transparent 70%),
    var(--bg-dark);
  border-top: 1px solid var(--border);
}
.eq-cta__deco {
  position: absolute; inset: 0;
  display: flex; align-items: center; justify-content: center;
  font-size: clamp(180px, 30vw, 380px);
  color: rgba(212,175,55,0.03);
  user-select: none; pointer-events: none;
  animation: spin 70s linear infinite reverse;
}
.eq-cta__content {
  position: relative; z-index: 2;
  max-width: 520px; margin: 0 auto;
  display: flex; flex-direction: column; align-items: center; gap: 20px;
}
.eq-cta__title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(52px, 9vw, 90px); line-height: 1; margin: 0; letter-spacing: 2px;
}
.eq-cta__title em { color: var(--gold); font-style: normal; }
.eq-cta__sub { font-size: 15px; line-height: 1.8; color: var(--txt); margin: 0; }
.eq-cta__btns {
  display: flex; gap: 14px; flex-wrap: wrap;
  justify-content: center; margin-top: 8px;
}
.eq-cta__btn {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 13px; font-weight: 700; letter-spacing: 3px;
  text-transform: uppercase; text-decoration: none;
  padding: 14px 38px; border-radius: 999px;
  transition: all 0.2s; display: inline-flex; align-items: center;
}
.eq-cta__btn--gold    { background: var(--gold); color: var(--bg-dark); border: 2px solid var(--gold); }
.eq-cta__btn--gold:hover { background: var(--gold-lt); border-color: var(--gold-lt); }
.eq-cta__btn--outline { background: transparent; color: var(--gold); border: 2px solid var(--gold); }
.eq-cta__btn--outline:hover { background: var(--gold); color: var(--bg-dark); }

/* ── Modal ── */
.eq-modal-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.8);
  display: flex; align-items: center; justify-content: center;
  z-index: 1000; padding: 24px;
  backdrop-filter: blur(4px);
}
.eq-modal {
  background: #1a0e0b;
  border: 1px solid color-mix(in srgb, var(--team-color, #D4AF37) 30%, transparent);
  border-radius: 24px;
  max-width: 520px; width: 100%;
  position: relative;
  max-height: 90vh; overflow-y: auto;
}
.eq-modal__close {
  position: absolute; top: 16px; right: 16px;
  background: rgba(255,255,255,0.08); border: none; color: white;
  font-size: 16px; width: 34px; height: 34px; border-radius: 50%;
  cursor: pointer; display: flex; align-items: center; justify-content: center;
  z-index: 10; transition: background 0.2s;
}
.eq-modal__close:hover { background: var(--red); }

.eq-modal__header {
  display: flex; align-items: center; gap: 24px;
  padding: 36px 36px 24px;
  border-bottom: 1px solid rgba(255,255,255,0.06);
  background: color-mix(in srgb, var(--team-color, #D4AF37) 6%, transparent);
}
.eq-modal__logo-wrap {
  width: 80px; height: 80px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
}
.eq-modal__logo-img {
  width: 80px; height: 80px; object-fit: contain;
  filter: drop-shadow(0 4px 16px rgba(0,0,0,0.6));
}
.eq-modal__logo-svg { width: 80px; height: 80px; }
.eq-modal__name {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 26px; letter-spacing: 1px; color: white;
  margin: 0; line-height: 1.1;
}

.eq-modal__body { padding: 28px 36px 36px; }
.eq-modal__grid {
  display: grid; grid-template-columns: 1fr 1fr;
  gap: 18px; margin-bottom: 24px;
}
@media (max-width: 480px) { .eq-modal__grid { grid-template-columns: 1fr; } }
.eq-modal__item { display: flex; flex-direction: column; gap: 3px; }
.eq-modal__lbl {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px; font-weight: 700; letter-spacing: 2px;
  color: var(--txt-dim); text-transform: uppercase;
}
.eq-modal__val { font-size: 14px; color: white; }

.eq-modal__logo-note {
  background: rgba(212,175,55,0.06);
  border: 1px solid rgba(212,175,55,0.15);
  border-radius: 10px; padding: 14px 16px;
  font-size: 12px; color: var(--txt-dim); line-height: 1.6;
}
.eq-modal__logo-note strong { color: var(--gold); }

/* ── Transitions ── */
.eq-fade-enter-active, .eq-fade-leave-active { transition: opacity 0.25s ease; }
.eq-fade-enter-from,   .eq-fade-leave-to    { opacity: 0; }
</style>