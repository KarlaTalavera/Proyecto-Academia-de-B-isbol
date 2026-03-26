<template>
  <header class="ld-hero">
    <!-- Background carousel -->
    <div class="ld-hero-bg">
      <img
        v-for="(img, i) in heroImages"
        :key="i"
        :src="img"
        :class="['ld-hero-slide', { 'ld-hero-slide--active': currentSlide === i }]"
        alt=""
      />
      <div class="ld-hero-gradient" />
    </div>

    <!-- Navbar -->
    <nav class="ld-nav">
      <RouterLink :to="{ name: 'LandingInicio' }" class="ld-nav-logo">LIGA DIAMANTE</RouterLink>

      <!-- Desktop links -->
      <div class="ld-nav-links">
        <RouterLink :to="{ name: 'LandingInicio' }" :class="['ld-nav-link', { 'ld-nav-link--active': route.name === 'LandingInicio' }]">Inicio</RouterLink>
        <RouterLink :to="{ name: 'LandingResultados' }" :class="['ld-nav-link', { 'ld-nav-link--active': route.name === 'LandingResultados' }]">Resultados</RouterLink>
        <RouterLink :to="{ name: 'LandingNoticias' }" :class="['ld-nav-link', { 'ld-nav-link--active': route.name === 'LandingNoticias' }]">Noticias</RouterLink>
        <RouterLink :to="{ name: 'LandingStanding' }" :class="['ld-nav-link', { 'ld-nav-link--active': route.name === 'LandingStanding' }]">Standing</RouterLink>
        <RouterLink :to="{ name: 'LandingCalendario' }" :class="['ld-nav-link', { 'ld-nav-link--active': route.name === 'LandingCalendario' }]">Calendario</RouterLink>
        <RouterLink :to="{ name: 'Login' }" class="ld-nav-btn">INICIAR SESIÓN</RouterLink>
      </div>

      <!-- Hamburger -->
      <button class="ld-hamburger" @click="mobileOpen = true" aria-label="Abrir menú">
        <span /><span /><span />
      </button>
    </nav>

    <!-- Hero title -->
    <div class="ld-hero-title">
      <div class="ld-hero-title-bar" />
      <p class="ld-hero-title-top">DONDE NACEN</p>
      <p class="ld-hero-title-bottom">LAS LEYENDAS</p>
    </div>

    <!-- Mobile menu (teleported) -->
    <Teleport to="body">
      <transition name="ld-overlay-fade">
        <div v-if="mobileOpen" class="ld-mobile-overlay" @click.self="mobileOpen = false">
          <div class="ld-mobile-panel">
            <button class="ld-mobile-close" @click="mobileOpen = false">✕</button>
            <div class="ld-mobile-links">
              <RouterLink :to="{ name: 'LandingInicio' }" class="ld-mobile-link" @click="mobileOpen = false">Inicio</RouterLink>
              <RouterLink :to="{ name: 'LandingResultados' }" class="ld-mobile-link" @click="mobileOpen = false">Resultados</RouterLink>
              <RouterLink :to="{ name: 'LandingNoticias' }" class="ld-mobile-link" @click="mobileOpen = false">Noticias</RouterLink>
              <RouterLink :to="{ name: 'LandingStanding' }" class="ld-mobile-link" @click="mobileOpen = false">Standing</RouterLink>
              <RouterLink :to="{ name: 'LandingCalendario' }" class="ld-mobile-link" @click="mobileOpen = false">Calendario</RouterLink>
              <RouterLink :to="{ name: 'Login' }" class="ld-mobile-btn" @click="mobileOpen = false">INICIAR SESIÓN</RouterLink>
            </div>
          </div>
        </div>
      </transition>
    </Teleport>
  </header>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute, RouterLink } from 'vue-router'

const route = useRoute()
const currentSlide = ref(0)
const estadOpen = ref(false)
const mobileOpen = ref(false)

const heroImages = [
  '/recursos/31231.jpg_1239977223.webp',
  '/recursos/1.jpg',
  '/recursos/2.jpg',
  '/recursos/3.jpeg',
]

let slideTimer = null

onMounted(() => {
  slideTimer = setInterval(() => {
    currentSlide.value = (currentSlide.value + 1) % heroImages.length
  }, 3000)
})

onUnmounted(() => {
  clearInterval(slideTimer)
})
</script>

<style scoped>
/* ─── Hero container ─── */
.ld-hero {
  position: relative;
  width: 100%;
  height: 400px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  font-family: 'Arial Black', Arial, sans-serif;
}

@media (min-width: 768px) {
  .ld-hero {
    height: 550px;
  }
}

/* ─── Background slides ─── */
.ld-hero-bg {
  position: absolute;
  inset: 0;
  z-index: 0;
}

.ld-hero-slide {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  filter: brightness(0.25);
  opacity: 0;
  transition: opacity 1.2s ease-in-out;
}

.ld-hero-slide--active {
  opacity: 1;
}

.ld-hero-gradient {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 60%;
  background: linear-gradient(to top, #1a0a0a, transparent);
  z-index: 1;
}

/* ─── Navbar ─── */
.ld-nav {
  position: relative;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 24px;
}

@media (min-width: 1024px) {
  .ld-nav {
    padding: 20px 48px;
  }
}

.ld-nav-logo {
  font-size: 20px;
  font-weight: 900;
  font-style: italic;
  text-transform: uppercase;
  color: #D4AF37;
  text-decoration: none;
  letter-spacing: 2px;
  line-height: 1;
}

@media (min-width: 1024px) {
  .ld-nav-logo {
    font-size: 24px;
  }
}

/* ─── Desktop nav links ─── */
.ld-nav-links {
  display: none;
  align-items: center;
  gap: 4px;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(8px);
  border-radius: 999px;
  padding: 8px 16px;
}

@media (min-width: 1024px) {
  .ld-nav-links {
    display: flex;
  }
}

.ld-nav-link {
  color: rgba(255, 255, 255, 0.85);
  text-decoration: none;
  font-size: 13px;
  font-weight: 600;
  padding: 6px 12px;
  border-radius: 999px;
  transition: color 0.2s, background 0.2s;
  white-space: nowrap;
  cursor: pointer;
}

.ld-nav-link:hover {
  color: #FECE79;
  background: rgba(255, 255, 255, 0.08);
}

.ld-nav-link--active {
  color: #FECE79 !important;
}

.ld-nav-btn {
  color: #1a0d0a;
  background: #D4AF37;
  text-decoration: none;
  font-size: 12px;
  font-weight: 900;
  padding: 7px 16px;
  border-radius: 999px;
  margin-left: 8px;
  transition: background 0.2s, color 0.2s;
  white-space: nowrap;
  letter-spacing: 0.5px;
}

.ld-nav-btn:hover {
  background: #FECE79;
}

/* ─── Estadísticas dropdown ─── */
.ld-nav-dropdown {
  position: relative;
}

.ld-nav-link--drop {
  user-select: none;
}

.ld-caret {
  font-size: 10px;
  margin-left: 2px;
}

.ld-dropdown-menu {
  position: absolute;
  top: calc(100% + 8px);
  left: 50%;
  transform: translateX(-50%);
  background: rgba(10, 4, 4, 0.95);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(212, 175, 55, 0.3);
  border-radius: 12px;
  padding: 8px 4px;
  min-width: 140px;
  z-index: 100;
}

.ld-dropdown-item {
  display: block;
  color: rgba(255, 255, 255, 0.85);
  text-decoration: none;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 1px;
  padding: 8px 16px;
  border-radius: 8px;
  transition: color 0.2s, background 0.2s;
}

.ld-dropdown-item:hover {
  color: #FECE79;
  background: rgba(212, 175, 55, 0.12);
}

/* ─── Hamburger ─── */
.ld-hamburger {
  display: flex;
  flex-direction: column;
  gap: 5px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
}

@media (min-width: 1024px) {
  .ld-hamburger {
    display: none;
  }
}

.ld-hamburger span {
  display: block;
  width: 24px;
  height: 2px;
  background: #D4AF37;
  border-radius: 2px;
}

/* ─── Hero title ─── */
.ld-hero-title {
  position: relative;
  z-index: 10;
  padding: 0 24px 28px;
}

@media (min-width: 1024px) {
  .ld-hero-title {
    padding: 0 48px 40px;
  }
}

.ld-hero-title-bar {
  width: 40px;
  height: 4px;
  background: #8C0902;
  margin-bottom: 10px;
  border-radius: 2px;
}

.ld-hero-title-top {
  color: #D4AF37;
  font-size: 28px;
  font-weight: 900;
  font-style: italic;
  text-transform: uppercase;
  letter-spacing: 3px;
  line-height: 1;
  margin: 0;
  padding: 0;
}

.ld-hero-title-bottom {
  color: #FECE79;
  font-size: 36px;
  font-weight: 900;
  font-style: italic;
  text-transform: uppercase;
  letter-spacing: 3px;
  line-height: 1.1;
  margin: 0;
  padding: 0;
}

@media (min-width: 768px) {
  .ld-hero-title-top {
    font-size: 42px;
  }
  .ld-hero-title-bottom {
    font-size: 56px;
  }
}

/* ─── Mobile overlay ─── */
.ld-mobile-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  z-index: 99999;
  display: flex;
  justify-content: flex-end;
}

.ld-mobile-panel {
  width: 280px;
  max-width: 85vw;
  height: 100%;
  background: #120604;
  border-left: 1px solid rgba(212, 175, 55, 0.2);
  display: flex;
  flex-direction: column;
  padding: 24px 0;
  overflow-y: auto;
}

.ld-mobile-close {
  align-self: flex-end;
  margin-right: 20px;
  margin-bottom: 20px;
  background: none;
  border: 1px solid rgba(212, 175, 55, 0.4);
  color: #D4AF37;
  font-size: 18px;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

.ld-mobile-links {
  display: flex;
  flex-direction: column;
  padding: 0 20px;
  gap: 4px;
}

.ld-mobile-link {
  color: rgba(255, 255, 255, 0.85);
  text-decoration: none;
  font-size: 15px;
  font-weight: 600;
  padding: 12px 16px;
  border-radius: 10px;
  transition: color 0.2s, background 0.2s;
}

.ld-mobile-link:hover {
  color: #FECE79;
  background: rgba(212, 175, 55, 0.1);
}

.ld-mobile-link--sub {
  font-size: 13px;
  padding-left: 28px;
  color: rgba(255, 255, 255, 0.6);
  letter-spacing: 1px;
  font-weight: 700;
}

.ld-mobile-section-label {
  color: #E6A341;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  padding: 12px 16px 4px;
}

.ld-mobile-btn {
  display: block;
  text-align: center;
  color: #1a0d0a;
  background: #D4AF37;
  text-decoration: none;
  font-size: 13px;
  font-weight: 900;
  padding: 12px 16px;
  border-radius: 10px;
  margin-top: 12px;
  letter-spacing: 1px;
}

/* ─── Transition ─── */
.ld-overlay-fade-enter-active,
.ld-overlay-fade-leave-active {
  transition: opacity 0.25s ease;
}
.ld-overlay-fade-enter-from,
.ld-overlay-fade-leave-to {
  opacity: 0;
}
</style>
