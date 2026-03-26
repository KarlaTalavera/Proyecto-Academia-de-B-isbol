<template>
  <footer class="lf-footer">
    <div class="lf-inner">
      <!-- Grid -->
      <div class="lf-grid">

        <!-- Col 1: Brand -->
        <div class="lf-col">
          <div class="lf-brand-row">
            <div class="lf-logo-diamond">
              <span class="lf-logo-letter">D</span>
            </div>
            <span class="lf-brand-name">LIGA DIAMANTE</span>
          </div>
          <p class="lf-brand-tagline">Tradición, esfuerzo y pasión por el béisbol venezolano.</p>
          <div class="lf-socials">
            <a href="#" class="lf-social-btn" aria-label="Facebook">f</a>
            <a href="#" class="lf-social-btn" aria-label="Instagram">ig</a>
            <a href="#" class="lf-social-btn" aria-label="X / Twitter">x</a>
            <a href="#" class="lf-social-btn" aria-label="TikTok">tk</a>
            <a href="#" class="lf-social-btn" aria-label="LinkedIn">in</a>
            <a href="#" class="lf-social-btn" aria-label="YouTube">yt</a>
          </div>
        </div>

        <!-- Col 2: Mapa del Sitio -->
        <div class="lf-col">
          <h4 class="lf-section-title">Mapa del Sitio</h4>
          <nav class="lf-nav-list">
            <RouterLink to="/" class="lf-nav-link">Inicio</RouterLink>
            <RouterLink to="/resultados" class="lf-nav-link">Resultados</RouterLink>
            <RouterLink to="/noticias" class="lf-nav-link">Noticias</RouterLink>
          </nav>
        </div>

        <!-- Col 3: La Academia -->
        <div class="lf-col">
          <h4 class="lf-section-title">La Academia</h4>
          <nav class="lf-nav-list">
            <a href="#" class="lf-nav-link">Reglamento</a>
            <a href="#" class="lf-nav-link">Inscripciones</a>
            <a href="#" class="lf-nav-link">Entrenamientos</a>
          </nav>
        </div>

        <!-- Col 4: Contacto -->
        <div class="lf-col">
          <h4 class="lf-section-title">Contacto</h4>
          <div class="lf-contact-list">
            <div class="lf-contact-item">
              <span class="lf-contact-icon">☎</span>
              <span class="lf-contact-text">+58 212 555 0100</span>
            </div>
            <div class="lf-contact-item">
              <span class="lf-contact-icon">✉</span>
              <span class="lf-contact-text">info@ligadiamante.com.ve</span>
            </div>
            <div class="lf-contact-item">
              <span class="lf-contact-icon">⚑</span>
              <span class="lf-contact-text">Caracas, Venezuela</span>
            </div>
          </div>
        </div>

      </div><!-- /grid -->

      <!-- Bottom bar -->
      <div class="lf-bottom">
        <p class="lf-copyright">© 2026 Liga Diamante de Béisbol &bull; Tradición y Pasión</p>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>

<style scoped>
.lf-footer {
  background: #210100;
  color: white;
  font-family: Arial, sans-serif;
}

.lf-inner {
  max-width: 1280px;
  margin: 0 auto;
  padding: 56px 24px 0;
}

@media (min-width: 1024px) {
  .lf-inner {
    padding: 64px 48px 0;
  }
}

/* ─── Grid ─── */
.lf-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 40px;
}

@media (min-width: 640px) {
  .lf-grid {
    grid-template-columns: 1fr 1fr;
  }
}

@media (min-width: 1024px) {
  .lf-grid {
    grid-template-columns: 2fr 1fr 1fr 1.5fr;
    gap: 48px;
  }
}

.lf-col {
  display: flex;
  flex-direction: column;
  gap: 0;
}

/* ─── Section title ─── */
.lf-section-title {
  color: #E6A341;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 3px;
  text-transform: uppercase;
  padding-bottom: 10px;
  border-bottom: 1px solid rgba(230, 163, 65, 0.3);
  margin: 0 0 16px 0;
  line-height: 1.4;
}

/* ─── Brand ─── */
.lf-brand-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.lf-logo-diamond {
  width: 40px;
  height: 40px;
  background: #8C0902;
  transform: rotate(45deg);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  border-radius: 4px;
}

.lf-logo-letter {
  display: block;
  transform: rotate(-45deg);
  color: #FECE79;
  font-size: 18px;
  font-weight: 900;
  font-style: italic;
  line-height: 1;
}

.lf-brand-name {
  color: #D4AF37;
  font-size: 16px;
  font-weight: 900;
  font-style: italic;
  letter-spacing: 2px;
  text-transform: uppercase;
  line-height: 1;
}

.lf-brand-tagline {
  color: rgba(255, 255, 255, 0.5);
  font-size: 13px;
  line-height: 1.6;
  margin: 0 0 20px 0;
  padding: 0;
}

/* ─── Socials ─── */
.lf-socials {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.lf-social-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  background: rgba(212, 175, 55, 0.1);
  border: 1px solid rgba(212, 175, 55, 0.25);
  border-radius: 8px;
  color: rgba(255, 255, 255, 0.7);
  text-decoration: none;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.5px;
  transition: background 0.2s, color 0.2s, border-color 0.2s;
}

.lf-social-btn:hover {
  background: rgba(212, 175, 55, 0.25);
  border-color: #D4AF37;
  color: #FECE79;
}

/* ─── Nav links ─── */
.lf-nav-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.lf-nav-link {
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
  font-size: 14px;
  padding: 6px 0;
  transition: color 0.2s;
  display: block;
}

.lf-nav-link:hover {
  color: #FECE79;
}

/* ─── Contact ─── */
.lf-contact-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.lf-contact-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.lf-contact-icon {
  color: #E6A341;
  font-size: 14px;
  flex-shrink: 0;
  margin-top: 1px;
  line-height: 1.5;
}

.lf-contact-text {
  color: rgba(255, 255, 255, 0.6);
  font-size: 13px;
  line-height: 1.5;
}

/* ─── Bottom bar ─── */
.lf-bottom {
  margin-top: 40px;
  border-top: 1px solid rgba(212, 175, 55, 0.15);
  padding: 20px 0;
  text-align: center;
}

.lf-copyright {
  color: rgba(255, 255, 255, 0.35);
  font-size: 12px;
  margin: 0;
  padding: 0;
  letter-spacing: 0.5px;
}
</style>
