<template>
  <div class="iv-page">
    <LandingHeader />


    <!-- Section 01 – Información General -->
    <section class="iv-section">
      <div class="iv-container">
        <div class="iv-row">
          <!-- Text -->
          <div class="iv-text-col">
            <span class="iv-section-num">01.</span>
            <div class="iv-divider" />
            <div class="iv-title-block">
              <h2 class="iv-title-main">INFORMACIÓN</h2>
              <h2 class="iv-title-ghost">GENERAL</h2>
            </div>
            <p class="iv-subtitle">
              Conoce todos los detalles de la Liga Diamante de Béisbol: nuestros torneos,
              equipos participantes, reglamento oficial y toda la información que necesitas
              para seguir de cerca cada temporada.
            </p>
            <router-link to="/informacion" class="iv-btn">LEER MÁS</router-link>
          </div>
          <!-- Image -->
          <div class="iv-img-col">
            <div class="iv-img-wrapper">
              <div class="iv-dot-pattern iv-dot-pattern--tl" />
              <img src="/recursos/4.jpg" alt="Información General" class="iv-img" />
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Section 02 – Equipos -->
    <section class="iv-section iv-section--alt">
      <div class="iv-container">
        <div class="iv-row iv-row--reversed">
          <!-- Image -->
          <div class="iv-img-col">
            <div class="iv-img-wrapper">
              <img src="/recursos/5.jpg" alt="Equipos" class="iv-img" />
            </div>
          </div>
          <!-- Text -->
          <div class="iv-text-col">
            <span class="iv-section-num">02.</span>
            <div class="iv-divider" />
            <div class="iv-title-block">
              <h2 class="iv-title-main">EQUIPOS</h2>
              <h2 class="iv-title-ghost">VARIADOS</h2>
            </div>
            <p class="iv-subtitle">
              Descubre los equipos que forman parte de la Liga Diamante. Desde sus uniformes
              y escudos hasta sus plantillas completas y trayectoria histórica en el torneo.
            </p>
             <router-link to="/equipos" class="iv-btn">LEER MÁS</router-link>
          </div>
        </div>
      </div>
    </section>

    <!-- Section 03 – Alineación -->
    <section class="iv-section">
      <div class="iv-container">
        <div class="iv-row iv-row--reversed">
          <!-- Image -->
          <div class="iv-img-col">
            <div class="iv-img-wrapper">
              <img src="/recursos/6.jpg" alt="Alineación" class="iv-img" />
            </div>
          </div>
          <!-- Text -->
          <div class="iv-text-col">
            <span class="iv-section-num">03.</span>
            <div class="iv-divider" />
            <div class="iv-title-block">
              <h2 class="iv-title-main">ALINEACIÓN</h2>
              <h2 class="iv-title-ghost">LINE-UP</h2>
            </div>
            <p class="iv-subtitle">
              Consulta las alineaciones de cada equipo para los próximos encuentros.
              Conoce quién lanzará, quiénes bateean y cómo se estructura cada novena.
            </p>
            <router-link to="/alineacion" class="iv-btn">LEER MÁS</router-link>
          </div>
        </div>
      </div>
    </section>

    <!-- Section 04 – Jugadores -->
    <section class="iv-section iv-section--alt">
      <div class="iv-container">
        <div class="iv-row">
          <!-- Text -->
          <div class="iv-text-col">
            <span class="iv-section-num">04.</span>
            <div class="iv-divider" />
            <div class="iv-title-block">
              <h2 class="iv-title-main">JUGADORES</h2>
              <h2 class="iv-title-ghost">DESTACADOS</h2>
            </div>
            <p class="iv-subtitle">
              Sigue el desempeño de los mejores peloteros de la liga. Estadísticas,
              promedios al bate, efectividad en el montículo y mucho más de tus favoritos.
            </p>
            <router-link to="/jugadores" class="iv-btn">LEER MÁS</router-link>
          </div>
          <!-- Image -->
          <div class="iv-img-col">
            <div class="iv-img-wrapper">
              <div class="iv-dot-pattern iv-dot-pattern--br" />
              <img src="/recursos/7.jpg" alt="Jugadores" class="iv-img" />
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import LandingHeader from '@/components/landing/LandingHeader.vue'
</script>

<style scoped>
/* ─── Page wrapper ─── */
.iv-page {
  background: #1a0d0a;
  min-height: 100vh;
  font-family: Arial, sans-serif;
  color: white;
}

/* ─── Container ─── */
.iv-container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 24px;
}

@media (min-width: 1024px) {
  .iv-container {
    padding: 0 48px;
  }
}

/* ─── Section ─── */
.iv-section {
  padding: 80px 0;
}

@media (min-width: 1024px) {
  .iv-section {
    padding: 100px 0;
  }
}

.iv-section--alt {
  background: rgba(0, 0, 0, 0.2);
}

/* ─── Row ─── */
.iv-row {
  display: grid;
  grid-template-columns: 1fr;
  gap: 48px;
  align-items: center;
}

@media (min-width: 1024px) {
  .iv-row {
    grid-template-columns: 1fr 1fr;
    gap: 64px;
  }

  .iv-row--reversed .iv-img-col {
    order: -1;
  }
}

/* ─── Text column ─── */
.iv-text-col {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.iv-section-num {
  color: #E6A341;
  font-size: 14px;
  font-weight: 900;
  letter-spacing: 3px;
  margin-bottom: 8px;
  display: block;
}

.iv-divider {
  width: 48px;
  height: 3px;
  background: #8C0902;
  margin-bottom: 20px;
  border-radius: 2px;
}

.iv-title-block {
  margin-bottom: 20px;
  line-height: 1;
}

.iv-title-main {
  color: #D4AF37;
  font-size: 40px;
  font-weight: 900;
  font-style: italic;
  text-transform: uppercase;
  letter-spacing: 2px;
  margin: 0;
  padding: 0;
  line-height: 1;
}

.iv-title-ghost {
  color: white;
  opacity: 0.06;
  font-size: 52px;
  font-weight: 900;
  font-style: italic;
  text-transform: uppercase;
  letter-spacing: 2px;
  margin: -6px 0 0 0;
  padding: 0;
  line-height: 1;
  user-select: none;
}

@media (min-width: 768px) {
  .iv-title-main {
    font-size: 52px;
  }
  .iv-title-ghost {
    font-size: 68px;
  }
}

.iv-subtitle {
  color: rgba(255, 255, 255, 0.6);
  font-size: 15px;
  line-height: 1.75;
  margin: 0 0 28px 0;
  padding: 0;
  max-width: 480px;
}

.iv-btn {
  display: inline-flex;
  align-items: center;
  align-self: flex-start;
  color: #D4AF37;
  border: 2px solid #D4AF37;
  text-decoration: none;
  font-size: 13px;
  font-weight: 900;
  letter-spacing: 2px;
  padding: 12px 28px;
  border-radius: 999px;
  transition: background 0.2s, color 0.2s;
}

.iv-btn:hover {
  background: #D4AF37;
  color: #1a0d0a;
}

/* ─── Image column ─── */
.iv-img-col {
  position: relative;
}

.iv-img-wrapper {
  position: relative;
}

.iv-img {
  width: 100%;
  height: 320px;
  object-fit: cover;
  border-radius: 4rem;
  display: block;
}

@media (min-width: 1024px) {
  .iv-img {
    height: 420px;
  }
}

/* ─── Dot pattern decoration ─── */
.iv-dot-pattern {
  position: absolute;
  width: 120px;
  height: 120px;
  background-image: radial-gradient(circle, rgba(212, 175, 55, 0.4) 1.5px, transparent 1.5px);
  background-size: 14px 14px;
  z-index: 0;
  pointer-events: none;
}

.iv-dot-pattern--tl {
  top: -20px;
  left: -20px;
}

.iv-dot-pattern--br {
  bottom: -20px;
  right: -20px;
}

.iv-img-wrapper .iv-img {
  position: relative;
  z-index: 1;
}
</style>
