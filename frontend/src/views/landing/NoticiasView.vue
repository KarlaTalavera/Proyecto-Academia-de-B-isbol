<template>
  <div class="nv-page">
    <LandingHeader />

    <!-- Banner -->
    <div class="nv-banner">
      <h1 class="nv-banner-title">NOTICIAS</h1>
    </div>

    <!-- Skeleton loading -->
    <section v-if="loading" class="nv-section">
      <div class="nv-container">
        <div class="nv-carousel-track">
          <div v-for="i in 4" :key="i" class="nv-skeleton-card">
            <div class="nv-skeleton-img" />
            <div class="nv-skeleton-body">
              <div class="nv-skeleton-line nv-skeleton-line--long" />
              <div class="nv-skeleton-line nv-skeleton-line--short" />
              <div class="nv-skeleton-line nv-skeleton-line--medium" />
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Carousel -->
    <section v-else class="nv-section">
      <div class="nv-container">
        <div class="nv-carousel-wrapper">

          <!-- Prev arrow (desktop) -->
          <button
            class="nv-arrow nv-arrow--prev"
            @click="prev"
            :disabled="offset === 0"
            aria-label="Anterior"
          >&#8249;</button>

          <!-- Cards track (desktop: clipped window, mobile: horizontal scroll) -->
          <div class="nv-viewport" ref="viewport">
            <div
              class="nv-track"
              :style="{ transform: `translateX(-${offset * (cardWidth + gap)}px)` }"
            >
              <article
                v-for="(item, i) in noticias"
                :key="i"
                class="nv-card"
              >
                <div class="nv-card-img-wrap">
                  <img :src="item.imagen" :alt="item.titulo" class="nv-card-img" loading="lazy" />
                  <span class="nv-badge">Destacado</span>
                </div>
                <div class="nv-card-body">
                  <h3 class="nv-card-title">{{ item.titulo }}</h3>
                  <p class="nv-card-meta">{{ item.lugar }} &bull; {{ item.fuente }}</p>
                  <p class="nv-card-summary">{{ item.resumen }}</p>
                </div>
              </article>
            </div>
          </div>

          <!-- Next arrow (desktop) -->
          <button
            class="nv-arrow nv-arrow--next"
            @click="next"
            :disabled="offset >= maxOffset"
            aria-label="Siguiente"
          >&#8250;</button>
        </div>

        <!-- Dots -->
        <div class="nv-dots">
          <button
            v-for="d in dotCount"
            :key="d"
            :class="['nv-dot', { 'nv-dot--active': offset === d - 1 }]"
            @click="offset = d - 1"
          />
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import LandingHeader from '@/components/landing/LandingHeader.vue'

const loading = ref(true)
const offset = ref(0)
const viewport = ref(null)

const cardWidth = 320
const gap = 24
const visibleCards = 3

const noticias = [
  {
    titulo: 'Leones del Caracas se corona campeón de la LVBP 2025-2026',
    imagen: '/recursos/1.jpg',
    lugar: 'Caracas, Venezuela',
    fuente: 'LVBP Oficial',
    resumen: 'Los Leones del Caracas conquistaron su título número 18 en la Liga Venezolana de Béisbol Profesional tras vencer a los Navegantes del Magallanes en una serie final de siete juegos que mantuvo al país en vilo.',
  },
  {
    titulo: 'Tigres de Aragua refuerzan su rotación para el round robin',
    imagen: '/recursos/2.jpg',
    lugar: 'Maracay, Venezuela',
    fuente: 'Beisbol de Venezuela',
    resumen: 'La directiva de los Tigres de Aragua anunció la firma de dos serpentineros nacionales procedentes de la academia, buscando consolidar su plantel previo a la fase decisiva del torneo.',
  },
  {
    titulo: 'Cardenales de Lara celebran 60 años de historia peloteril',
    imagen: '/recursos/3.jpeg',
    lugar: 'Barquisimeto, Venezuela',
    fuente: 'El Informador',
    resumen: 'El equipo barquisimetano conmemoró seis décadas de béisbol con un acto en el estadio Antonio Herrera Gutiérrez, donde leyendas del club compartieron con los aficionados larenses.',
  },
  {
    titulo: 'Venezuela clasifica al Clásico Mundial con récord invicto',
    imagen: '/recursos/4.jpg',
    lugar: 'Caracas, Venezuela',
    fuente: 'LVBP Oficial',
    resumen: 'La selección nacional de béisbol cerró su fase clasificatoria con marca perfecta de seis victorias y cero derrotas, generando gran expectativa entre la fanaticada criolla de cara al torneo internacional.',
  },
  {
    titulo: 'Navegantes del Magallanes anuncian nueva directiva técnica',
    imagen: '/recursos/5.jpg',
    lugar: 'Valencia, Venezuela',
    fuente: 'Meridiano',
    resumen: 'Los Navegantes del Magallanes presentaron a su nuevo cuerpo técnico encabezado por un reconocido estratega venezolano con experiencia en ligas del Caribe y torneos internacionales.',
  },
  {
    titulo: 'Estadio de Barquisimeto completará remodelación para la próxima temporada',
    imagen: '/recursos/6.jpg',
    lugar: 'Barquisimeto, Venezuela',
    fuente: 'El Impulso',
    resumen: 'Las obras de mejora del estadio Antonio Herrera Gutiérrez avanzan a buen ritmo y se espera que estén listas para el inicio de la próxima temporada de la LVBP, ofreciendo mayor comodidad a los fanáticos.',
  },
  {
    titulo: 'Jóvenes peloteros venezolanos destacan en torneos juveniles del Caribe',
    imagen: '/recursos/7.jpg',
    lugar: 'Caracas, Venezuela',
    fuente: 'Béisbol de Venezuela',
    resumen: 'Varios prospectos venezolanos menores de 18 años se robaron los reflectores en el torneo juvenil del Caribe, despertando el interés de academias de béisbol de la región.',
    resumen: 'Las Estrellas Orientales sellaron su clasificación a la final de la Serie del Caribe tras derrotar a las Águilas Cibaeñas en un duelo que se extendió hasta el décimo inning.',
  },
  {
    titulo: 'Nuevas reglas de tiempo buscan agilizar los juegos',
    imagen: '/recursos/3.jpeg',
    lugar: 'Nueva York, EUA',
    fuente: 'MLB Oficina del Comisionado',
    resumen: 'Las Grandes Ligas anunciaron ajustes al reloj de lanzamiento y normas de pickoff para la temporada 2026, con el objetivo de mantener la duración promedio de juego por debajo de las 2 horas y 45 minutos.',
  },
]

const maxOffset = computed(() => Math.max(0, noticias.length - visibleCards))
const dotCount = computed(() => maxOffset.value + 1)

function prev() {
  if (offset.value > 0) offset.value--
}

function next() {
  if (offset.value < maxOffset.value) offset.value++
}

onMounted(() => {
  setTimeout(() => {
    loading.value = false
  }, 600)
})
</script>

<style scoped>
/* ─── Page ─── */
.nv-page {
  background: #1a0d0a;
  min-height: 100vh;
  font-family: Arial, sans-serif;
  color: white;
}

/* ─── Banner ─── */
.nv-banner {
  padding: 48px 24px 32px;
  text-align: center;
}

@media (min-width: 1024px) {
  .nv-banner {
    padding: 64px 48px 40px;
  }
}

.nv-banner-title {
  font-size: 64px;
  font-weight: 900;
  font-style: italic;
  text-transform: uppercase;
  letter-spacing: 6px;
  color: white;
  margin: 0;
  padding: 0;
  line-height: 1;
}

@media (min-width: 1024px) {
  .nv-banner-title {
    font-size: 100px;
  }
}

/* ─── Section ─── */
.nv-section {
  padding: 16px 0 72px;
}

.nv-container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 24px;
}

@media (min-width: 1024px) {
  .nv-container {
    padding: 0 48px;
  }
}

/* ─── Carousel wrapper ─── */
.nv-carousel-wrapper {
  display: flex;
  align-items: stretch;
  gap: 0;
  position: relative;
}

/* ─── Viewport (desktop: clip, mobile: scroll) ─── */
.nv-viewport {
  flex: 1;
  overflow: hidden;
}

@media (max-width: 1023px) {
  .nv-viewport {
    overflow-x: auto;
    scrollbar-width: none;
  }
  .nv-viewport::-webkit-scrollbar {
    display: none;
  }
}

/* ─── Track ─── */
.nv-track {
  display: flex;
  gap: 24px;
  transition: transform 0.4s ease;
}

@media (max-width: 1023px) {
  .nv-track {
    transform: none !important;
  }
}

/* ─── Card ─── */
.nv-card {
  flex: 0 0 320px;
  width: 320px;
  background: white;
  border-radius: 2rem;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.nv-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.5);
}

/* ─── Card image ─── */
.nv-card-img-wrap {
  position: relative;
  height: 200px;
  overflow: hidden;
  flex-shrink: 0;
}

.nv-card-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transition: transform 0.4s ease;
}

.nv-card:hover .nv-card-img {
  transform: scale(1.05);
}

.nv-badge {
  position: absolute;
  top: 12px;
  left: 12px;
  background: #8C0902;
  color: white;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  padding: 4px 10px;
  border-radius: 999px;
}

/* ─── Card body ─── */
.nv-card-body {
  padding: 20px;
  display: flex;
  flex-direction: column;
  flex: 1;
}

.nv-card-title {
  color: #8C0902;
  font-size: 15px;
  font-weight: 700;
  font-style: italic;
  line-height: 1.4;
  margin: 0 0 8px 0;
  padding: 0;
}

.nv-card-meta {
  color: rgba(0, 0, 0, 0.45);
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  margin: 0 0 10px 0;
  padding: 0;
}

.nv-card-summary {
  color: rgba(0, 0, 0, 0.65);
  font-size: 13px;
  line-height: 1.65;
  margin: 0;
  padding: 0;
  flex: 1;
  display: -webkit-box;
  -webkit-line-clamp: 4;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* ─── Arrows ─── */
.nv-arrow {
  display: none;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  background: rgba(212, 175, 55, 0.15);
  border: 1px solid rgba(212, 175, 55, 0.35);
  border-radius: 50%;
  color: #D4AF37;
  font-size: 28px;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
  flex-shrink: 0;
  align-self: center;
  line-height: 1;
  padding: 0;
  margin: 0 8px;
}

@media (min-width: 1024px) {
  .nv-arrow {
    display: flex;
  }
}

.nv-arrow:hover:not(:disabled) {
  background: rgba(212, 175, 55, 0.3);
  color: #FECE79;
}

.nv-arrow:disabled {
  opacity: 0.3;
  cursor: default;
}

/* ─── Dots ─── */
.nv-dots {
  display: none;
  justify-content: center;
  gap: 8px;
  margin-top: 28px;
}

@media (min-width: 1024px) {
  .nv-dots {
    display: flex;
  }
}

.nv-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: rgba(212, 175, 55, 0.25);
  border: none;
  cursor: pointer;
  padding: 0;
  transition: background 0.2s, transform 0.2s;
}

.nv-dot--active {
  background: #D4AF37;
  transform: scale(1.3);
}

/* ─── Skeleton ─── */
.nv-carousel-track {
  display: flex;
  gap: 24px;
  overflow: hidden;
}

.nv-skeleton-card {
  flex: 0 0 320px;
  width: 320px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 2rem;
  overflow: hidden;
}

.nv-skeleton-img {
  width: 100%;
  height: 200px;
  background: rgba(255, 255, 255, 0.08);
  animation: nv-pulse 1.5s ease-in-out infinite;
}

.nv-skeleton-body {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.nv-skeleton-line {
  height: 12px;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.08);
  animation: nv-pulse 1.5s ease-in-out infinite;
}

.nv-skeleton-line--long { width: 90%; }
.nv-skeleton-line--medium { width: 70%; }
.nv-skeleton-line--short { width: 50%; }

@keyframes nv-pulse {
  0%, 100% { opacity: 0.5; }
  50% { opacity: 1; }
}
</style>
