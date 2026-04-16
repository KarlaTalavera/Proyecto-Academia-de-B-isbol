<template>
  <div class="jd-page">
    <LandingHeader />

    <!-- HERO -->
    <section class="jd-hero">
      <div class="jd-hero__noise" />
      <div class="jd-hero__lines" />
      <div class="jd-hero__content">
        <p class="jd-hero__kicker">VENEZUELA · BÉISBOL · HISTORIA</p>
        <h1 class="jd-hero__title">JUGADORES<br /><span class="jd-hero__accent">DESTACADOS</span></h1>
        <p class="jd-hero__sub">Los venezolanos que dejaron huella en las Grandes Ligas</p>
      </div>
      <div class="jd-hero__diamond">◆</div>
    </section>

    <!-- GRID DE LEYENDAS -->
    <section class="jd-section">
      <div class="jd-container">
        <div class="jd-eyebrow-row">
          <span class="jd-eyebrow">GRANDES LIGAS · ORGULLO NACIONAL</span>
          <div class="jd-eyebrow-line" />
        </div>
        <h2 class="jd-title">Leyendas <em>venezolanas</em></h2>
        <p class="jd-subtitle">Toca cualquier carta para ver su historia completa</p>

        <div class="jd-grid">
          <article
            v-for="(jugador, i) in leyendas"
            :key="jugador.nombre"
            class="jd-card"
            :class="{ 'jd-card--wide': i === 0 }"
            @click="abrir(jugador)"
          >
            <div class="jd-card__color-bar" :style="{ background: jugador.color }" />

            <div class="jd-card__foto-wrap">
              <img
                v-if="jugador.foto"
                :src="jugador.foto"
                :alt="jugador.nombre"
                class="jd-card__foto"
                @error="jugador.foto = null"
              />
              <div v-else class="jd-card__avatar" :style="{ background: jugador.color + '22', borderColor: jugador.color + '66' }">
                <span :style="{ color: jugador.color }">{{ iniciales(jugador.nombre) }}</span>
              </div>
            </div>

            <div class="jd-card__body">
              <div class="jd-card__num">{{ String(i + 1).padStart(2, '0') }}</div>
              <h3 class="jd-card__name">{{ jugador.nombre }}</h3>
              <span class="jd-card__pos" :style="{ color: jugador.color }">{{ jugador.posicion }}</span>
              <p class="jd-card__logro">{{ jugador.logro_corto }}</p>
              <div class="jd-card__chips">
                <span v-for="stat in jugador.stats" :key="stat.label" class="jd-chip">
                  <b>{{ stat.val }}</b> {{ stat.label }}
                </span>
              </div>
            </div>

            <div class="jd-card__arrow" :style="{ color: jugador.color }">→</div>
          </article>
        </div>
      </div>
    </section>

    <!-- MODAL -->
    <transition name="jd-fade">
      <div v-if="modal" class="jd-overlay" @click.self="cerrar">
        <div class="jd-modal">
          <button class="jd-modal__close" @click="cerrar">✕</button>

          <div class="jd-modal__header">
            <div class="jd-modal__foto-wrap">
              <img
                v-if="modal.foto"
                :src="modal.foto"
                :alt="modal.nombre"
                class="jd-modal__foto"
                @error="modal.foto = null"
              />
              <div v-else class="jd-modal__avatar" :style="{ background: modal.color + '22', borderColor: modal.color }">
                <span :style="{ color: modal.color }">{{ iniciales(modal.nombre) }}</span>
              </div>
            </div>
            <div>
              <h2 class="jd-modal__nombre">{{ modal.nombre }}</h2>
              <p class="jd-modal__sub" :style="{ color: modal.color }">{{ modal.posicion }} · {{ modal.equipos }}</p>
            </div>
          </div>

          <div class="jd-modal__stats">
            <div v-for="stat in modal.stats" :key="stat.label" class="jd-modal__stat">
              <span class="jd-modal__stat-val" :style="{ color: modal.color }">{{ stat.val }}</span>
              <span class="jd-modal__stat-lbl">{{ stat.label }}</span>
            </div>
          </div>

          <div class="jd-modal__body">
            <div class="jd-modal__section">
              <h4 class="jd-modal__section-title">POR QUE ES LEYENDA</h4>
              <p>{{ modal.por_que }}</p>
            </div>
            <div class="jd-modal__section">
              <h4 class="jd-modal__section-title">LOGROS PRINCIPALES</h4>
              <ul class="jd-modal__list">
                <li v-for="logro in modal.logros" :key="logro">{{ logro }}</li>
              </ul>
            </div>
            <div class="jd-modal__section">
              <h4 class="jd-modal__section-title">DATO CURIOSO</h4>
              <p class="jd-modal__curious" :style="{ borderLeftColor: modal.color }">{{ modal.dato_curioso }}</p>
            </div>
            <div class="jd-modal__section">
              <h4 class="jd-modal__section-title">RUTINA Y MENTALIDAD</h4>
              <p>{{ modal.rutina }}</p>
            </div>
          </div>
        </div>
      </div>
    </transition>

  </div>
</template>

<script setup>
import { ref } from 'vue'
import LandingHeader from '@/components/landing/LandingHeader.vue'

function iniciales(nombre) {
  return nombre.split(' ').slice(0, 2).map(p => p[0]).join('')
}

// Para agregar foto: reemplaza null con la URL de la imagen
// Ejemplo: foto: 'https://upload.wikimedia.org/...'
const leyendas = ref([
  {
    nombre: 'Miguel Cabrera',
    posicion: '1B / 3B',
    equipos: 'Marlins · Tigers (2003–2023)',
    color: '#D4AF37',
    foto: null,
    logro_corto: 'Triple Corona 2012 · 2× MVP · 3,000 hits · 500 HR',
    por_que: 'Miggy es el bateador más completo en la historia del béisbol venezolano. En 2012 logró la Triple Corona — liderando la Liga Americana en promedio (.330), jonrones (44) e impulsadas (139) — algo que no se veía desde 1967. Es el único venezolano con más de 3,000 hits y 500 jonrones.',
    logros: [
      '2× MVP de la Liga Americana (2012 y 2013)',
      'Triple Corona de Bateo 2012 — única desde 1967',
      '3,081 hits — récord absoluto entre venezolanos en MLB',
      '506 jonrones — líder venezolano histórico',
      '12× seleccionado al Juego de Estrellas',
      'Campeón Serie Mundial 2003 con los Marlins',
    ],
    dato_curioso: 'Cabrera llegó a los Marlins a los 20 años y fue pieza clave en el título de la Serie Mundial de 2003. El día que ganaron, ni siquiera tenía edad legal para beber en EE.UU.',
    rutina: 'Famoso por llegar horas antes que cualquier otro jugador para trabajo de bateo privado. Su secreto: repetición obsesiva de la mecánica y lectura de pitchers — podía anticipar el lanzamiento antes de que el pitcher soltara la bola.',
    stats: [
      { val: '3,081', label: 'Hits' },
      { val: '506', label: 'Jonrones' },
      { val: '.307', label: 'Promedio' },
      { val: '2× MVP', label: 'Premios' },
    ],
  },
  {
    nombre: 'Luis Aparicio',
    posicion: 'Campocorto',
    equipos: 'White Sox · Orioles · Red Sox (1956–1973)',
    color: '#A8A8A8',
    foto: null,
    logro_corto: 'Salón de la Fama · Único venezolano en Cooperstown',
    por_que: 'El "Pequeño Lucho" es el único venezolano exaltado al Salón de la Fama de Cooperstown (1984). Fue el campocorto más ágil de su era, liderando la Liga Americana en robos durante 9 temporadas consecutivas — hazaña que nadie ha igualado.',
    logros: [
      'Salón de la Fama de Cooperstown (1984)',
      '9 años consecutivos líder en robos en la Liga Americana',
      '506 bases robadas en carrera',
      '2,677 hits en carrera',
      '13× seleccionado al Juego de Estrellas',
      'Campeón Serie Mundial 1959 con los White Sox',
    ],
    dato_curioso: 'Cuando debutó en 1956, Aparicio fue tan dominante que desplazó a Nellie Fox — su propio compañero — como figura central del equipo. Abrió las puertas del béisbol venezolano para todas las generaciones siguientes.',
    rutina: 'Obsesivo con el trabajo de pies: practicaba 200 movimientos laterales de defensa antes de cada juego. Decía: "El campocorto que no trabaja sus pies, ya perdió antes de empezar."',
    stats: [
      { val: '506', label: 'Robos' },
      { val: '2,677', label: 'Hits' },
      { val: '9×', label: 'Líder robos' },
      { val: 'HOF 1984', label: 'Cooperstown' },
    ],
  },
  {
    nombre: 'Omar Vizquel',
    posicion: 'Campocorto',
    equipos: 'Mariners · Indians · Giants (1989–2012)',
    color: '#4A90D9',
    foto: null,
    logro_corto: '11 Guantes de Oro · 2,877 hits · 24 temporadas',
    por_que: 'Considerado el mejor campocorto defensivo de todos los tiempos. Sus 11 Guantes de Oro son récord en la posición. Jugó 24 temporadas — más que cualquier otro venezolano en las Grandes Ligas.',
    logros: [
      '11 Guantes de Oro — récord histórico para campocortos',
      '2,877 hits en carrera',
      '24 temporadas activo en MLB',
      '3× seleccionado al Juego de Estrellas',
      'Serie Mundial 1997 con los Indians',
    ],
    dato_curioso: 'Vizquel escribió una autobiografía que describía con detalle las debilidades mentales de varios pitchers de su era. La MLB tuvo que actualizar sus normas de privacidad después de eso.',
    rutina: 'Llegaba al estadio con un guante de repuesto idéntico al principal. Practicaba primero roletazos, luego bolas aéreas, finalmente situaciones de juego. Filosofía: "Nada puede sorprenderte si ya lo practicaste."',
    stats: [
      { val: '11', label: 'Guantes Oro' },
      { val: '2,877', label: 'Hits' },
      { val: '24', label: 'Temporadas' },
      { val: '404', label: 'Robos' },
    ],
  },
  {
    nombre: 'Ronald Acuña Jr.',
    posicion: 'Jardinero',
    equipos: 'Atlanta Braves (2018–presente)',
    color: '#CE1141',
    foto: null,
    logro_corto: 'MVP unánime 2023 · Club 40-70 · La Fiera',
    por_que: 'En 2023 se convirtió en el único jugador en la historia de la MLB en unir 40 jonrones y 70 robos en una misma temporada, ganando el MVP de la Liga Nacional por unanimidad.',
    logros: [
      'MVP Liga Nacional 2023 — por unanimidad',
      'Primer jugador MLB con 40+ HR y 70+ SB en una temporada',
      '.337 / 41 HR / 73 SB / 106 RBI en temporada MVP',
      'Campeón Serie Mundial 2021 con los Braves',
    ],
    dato_curioso: 'El día que robó su base número 71 en 2023, su padre — Ronald Acuña Sr., quien también jugó béisbol — lo vio desde las gradas llorando. El hijo superó en un solo año todo lo que el padre hizo en su carrera.',
    rutina: 'Trabaja las cinco herramientas todos los días: sprint corto, lectura de pitchers en video 45 min, y trabajo defensivo 3 horas antes del juego que pocos fans llegan a ver.',
    stats: [
      { val: '40-70', label: 'HR-SB 2023' },
      { val: '1.012', label: 'OPS 2023' },
      { val: 'MVP', label: 'LN 2023' },
      { val: '.337', label: 'AVG 2023' },
    ],
  },
  {
    nombre: 'José Altuve',
    posicion: 'Segunda Base',
    equipos: 'Houston Astros (2011–presente)',
    color: '#EB6E1F',
    foto: null,
    logro_corto: 'MVP 2017 · 9× All-Star · 2,000+ hits',
    por_que: 'Con 1.65m demostró que el tamaño no importa. Su MVP de 2017 fue el corazón de la franquicia que ganó la Serie Mundial ese año. Quinto jugador en historia MLB con 2,000 hits, 400 dobles, 200 HR y 300 robos bateando sobre .300.',
    logros: [
      'MVP Liga Americana 2017',
      'Campeón Serie Mundial 2017 y 2022',
      '9× All-Star · 3× campeón de bateo',
      '2,000+ hits, 400+ dobles, 200+ HR, 300+ robos',
    ],
    dato_curioso: 'Cuando llegó a los entrenamientos de los Astros, los entrenadores casi lo mandan a casa pensando que era demasiado pequeño. Regresó al día siguiente y bateó tan bien que no tuvieron otra opción que firmarlo.',
    rutina: 'Trabaja el contacto limpio — nunca intenta jonrones, sino bateazos perfectos. Ve mínimo 4 lanzamientos por turno antes de ser agresivo. Complementa con sprints cortos para compensar la estatura.',
    stats: [
      { val: '2,000+', label: 'Hits' },
      { val: 'MVP', label: 'LA 2017' },
      { val: '9×', label: 'All-Star' },
      { val: '.307', label: 'Promedio' },
    ],
  },
  {
    nombre: 'Félix Hernández',
    posicion: 'Lanzador',
    equipos: 'Seattle Mariners (2005–2019)',
    color: '#00897B',
    foto: null,
    logro_corto: 'Juego Perfecto 2012 · Cy Young 2010 · El Rey',
    por_que: 'Durante casi una década fue el mejor lanzador del mundo. Ganó el Cy Young 2010 con un equipo de récord perdedor. El 15 de agosto de 2012 lanzó el juego perfecto: 27 bateadores, 27 outs.',
    logros: [
      'Juego Perfecto el 15 agosto 2012 contra los Rays',
      'Premio Cy Young 2010 — Liga Americana',
      '6× seleccionado al Juego de Estrellas',
      '169 victorias en carrera, todas con los Mariners',
    ],
    dato_curioso: 'Los fans que vieron el juego perfecto en vivo formaron "The King\'s Court" — sección vestida de amarillo que coreaba "K" cada vez que Félix ponchaba. Se convirtió en tradición permanente del estadio.',
    rutina: 'Entrenaba su cambio de velocidad durante horas para que luciera idéntico al fastball hasta el último segundo. Comenzaba cada bullpen con 15 min de mecánica frente a espejo.',
    stats: [
      { val: '27-0', label: 'Juego Perfecto' },
      { val: 'Cy Young', label: '2010' },
      { val: '169', label: 'Victorias' },
      { val: '3.18', label: 'EFE carrera' },
    ],
  },
  {
    nombre: 'Andrés Galarraga',
    posicion: 'Primera Base',
    equipos: 'Expos · Rockies · Braves (1985–2004)',
    color: '#7B4FBF',
    foto: null,
    logro_corto: 'El Gato · 399 HR · Sobreviviente de cáncer',
    por_que: 'El "Gato" fue uno de los primera base más completos de su era. En 1996 lideró la Liga Nacional en jonrones (47) e impulsadas (150). Sobrevivió un cáncer de linfoma en 1999 y regresó a jugar en 2000.',
    logros: [
      'Campeón de bateo Liga Nacional 1993',
      'Líder en HR (47) e impulsadas (150) en 1996',
      '399 jonrones en carrera · 1,425 impulsadas',
      '2× Guante de Oro (1989, 1990)',
      '5× seleccionado al Juego de Estrellas',
      'Regresó al béisbol tras superar cáncer de linfoma en 1999',
    ],
    dato_curioso: 'Cuando le diagnosticaron cáncer a los 37 años, los médicos dijeron que su carrera había terminado. Un año después estaba de vuelta en el campo, conectando jonrones como si nada.',
    rutina: 'Su trabajo defensivo en primera base era obsesivo — practicaba recepciones difíciles durante media hora antes de cada práctica. Decía que la primera base "tiene que ser el mejor receptor del infield".',
    stats: [
      { val: '399', label: 'Jonrones' },
      { val: '1,425', label: 'Impulsadas' },
      { val: '.288', label: 'Promedio' },
      { val: '2× GG', label: 'Guante Oro' },
    ],
  },
])

const modal = ref(null)

function abrir(jugador) {
  modal.value = jugador
  document.body.style.overflow = 'hidden'
}

function cerrar() {
  modal.value = null
  document.body.style.overflow = ''
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Barlow+Condensed:ital,wght@0,400;0,700;1,400&family=Barlow:wght@400;500&display=swap');

.jd-page {
  --gold:    #D4AF37;
  --red:     #8C0902;
  --bg:      #0d0908;
  --bg-dark: #080504;
  --bg-card: #160c0a;
  --border:  rgba(212,175,55,0.12);
  --txt:     rgba(255,255,255,0.7);
  --txt-dim: rgba(255,255,255,0.35);
  background: var(--bg); color: white;
  font-family: 'Barlow', sans-serif;
  min-height: 100vh; overflow-x: hidden;
}

.jd-hero {
  position: relative; min-height: 440px;
  display: flex; align-items: flex-end;
  padding: 140px 60px 72px; overflow: hidden;
  background:
    radial-gradient(ellipse 60% 70% at 80% 40%, rgba(140,9,2,0.22) 0%, transparent 60%),
    var(--bg-dark);
  border-bottom: 1px solid var(--border);
}
.jd-hero__noise {
  position: absolute; inset: 0; pointer-events: none; opacity: 0.35;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.04'/%3E%3C/svg%3E");
}
.jd-hero__lines {
  position: absolute; inset: 0; pointer-events: none;
  background: repeating-linear-gradient(-45deg, transparent, transparent 40px, rgba(212,175,55,0.012) 40px, rgba(212,175,55,0.012) 41px);
}
.jd-hero__content { position: relative; z-index: 2; }
.jd-hero__kicker {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px; font-weight: 700; letter-spacing: 5px;
  color: var(--gold); text-transform: uppercase; margin: 0 0 14px;
}
.jd-hero__title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(60px, 10vw, 116px); line-height: 0.88; margin: 0; letter-spacing: 2px;
}
.jd-hero__accent { color: var(--gold); }
.jd-hero__sub {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 15px; color: var(--txt); margin: 18px 0 0; letter-spacing: 1px;
}
.jd-hero__diamond {
  position: absolute; right: 7%; bottom: -50px;
  font-size: clamp(180px, 28vw, 360px);
  color: rgba(212,175,55,0.03);
  user-select: none; pointer-events: none;
  animation: spin 90s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

.jd-section { padding: 80px 0; }
.jd-container { max-width: 1100px; margin: 0 auto; padding: 0 32px; }
.jd-eyebrow-row { display: flex; align-items: center; gap: 16px; margin-bottom: 14px; }
.jd-eyebrow {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px; font-weight: 700; letter-spacing: 4px;
  color: var(--gold); text-transform: uppercase; white-space: nowrap;
}
.jd-eyebrow-line { flex: 1; height: 1px; background: var(--border); }
.jd-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(38px, 6vw, 68px); line-height: 1; margin: 0 0 10px;
}
.jd-title em { color: var(--gold); font-style: normal; }
.jd-subtitle {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 14px; color: var(--txt-dim); margin: 0 0 44px;
}

.jd-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 14px;
}
.jd-card--wide { grid-column: span 2; }
@media (max-width: 680px) { .jd-card--wide { grid-column: span 1; } }

.jd-card {
  position: relative; overflow: hidden;
  background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px;
  padding: 18px 18px 18px 20px; cursor: pointer;
  display: flex; align-items: center; gap: 14px;
  transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s;
}
.jd-card:hover { transform: translateY(-3px); border-color: rgba(212,175,55,0.35); box-shadow: 0 10px 36px rgba(0,0,0,0.45); }
.jd-card__color-bar { position: absolute; top: 0; left: 0; width: 3px; height: 100%; }

.jd-card__foto-wrap { flex-shrink: 0; }
.jd-card__foto { width: 56px; height: 56px; border-radius: 50%; object-fit: cover; object-position: top; border: 2px solid rgba(255,255,255,0.12); }
.jd-card__avatar { width: 56px; height: 56px; border-radius: 50%; border: 2px solid; display: flex; align-items: center; justify-content: center; font-family: 'Bebas Neue', sans-serif; font-size: 18px; }

.jd-card__body { flex: 1; min-width: 0; }
.jd-card__num { font-family: 'Bebas Neue', sans-serif; font-size: 10px; color: var(--txt-dim); margin-bottom: 1px; }
.jd-card__name { font-family: 'Bebas Neue', sans-serif; font-size: 20px; margin: 0 0 1px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.jd-card__pos { font-family: 'Barlow Condensed', sans-serif; font-size: 11px; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; display: block; margin-bottom: 5px; }
.jd-card__logro { font-size: 12px; color: var(--txt); margin: 0 0 8px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.jd-card__chips { display: flex; flex-wrap: wrap; gap: 4px; }
.jd-chip { font-family: 'Barlow Condensed', sans-serif; font-size: 11px; color: var(--txt-dim); background: rgba(255,255,255,0.04); border: 1px solid var(--border); border-radius: 5px; padding: 2px 7px; }
.jd-chip b { color: var(--gold); font-weight: 700; }
.jd-card__arrow { font-size: 16px; flex-shrink: 0; align-self: center; opacity: 0.4; transition: transform 0.2s, opacity 0.2s; }
.jd-card:hover .jd-card__arrow { transform: translateX(4px); opacity: 1; }

.jd-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.88); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 20px; backdrop-filter: blur(8px); }

.jd-modal { background: #130a08; border: 1px solid var(--border); border-radius: 22px; max-width: 520px; width: 100%; max-height: 88vh; overflow-y: auto; position: relative; scrollbar-width: thin; scrollbar-color: var(--border) transparent; }
.jd-modal__close { position: sticky; top: 12px; float: right; margin: 12px 14px 0 0; background: rgba(255,255,255,0.07); border: none; color: white; width: 30px; height: 30px; border-radius: 50%; font-size: 13px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: background 0.2s; z-index: 10; }
.jd-modal__close:hover { background: var(--red); }

.jd-modal__header { padding: 28px 24px 20px; clear: both; display: flex; align-items: center; gap: 16px; flex-wrap: wrap; border-bottom: 1px solid var(--border); }
.jd-modal__foto-wrap { flex-shrink: 0; }
.jd-modal__foto { width: 80px; height: 80px; border-radius: 50%; object-fit: cover; object-position: top; border: 3px solid rgba(255,255,255,0.12); }
.jd-modal__avatar { width: 80px; height: 80px; border-radius: 50%; border: 3px solid; display: flex; align-items: center; justify-content: center; font-family: 'Bebas Neue', sans-serif; font-size: 26px; }
.jd-modal__nombre { font-family: 'Bebas Neue', sans-serif; font-size: 26px; margin: 0 0 4px; }
.jd-modal__sub { font-family: 'Barlow Condensed', sans-serif; font-size: 11px; letter-spacing: 2px; text-transform: uppercase; margin: 0; }

.jd-modal__stats { display: flex; flex-wrap: wrap; gap: 8px; padding: 14px 24px; border-bottom: 1px solid var(--border); }
.jd-modal__stat { flex: 1; min-width: 70px; background: rgba(255,255,255,0.03); border: 1px solid var(--border); border-radius: 10px; padding: 10px 8px; display: flex; flex-direction: column; align-items: center; gap: 2px; }
.jd-modal__stat-val { font-family: 'Bebas Neue', sans-serif; font-size: 18px; line-height: 1; }
.jd-modal__stat-lbl { font-size: 9px; color: var(--txt-dim); letter-spacing: 1px; text-transform: uppercase; text-align: center; }

.jd-modal__body { padding: 20px 24px 28px; }
.jd-modal__section { margin-bottom: 20px; }
.jd-modal__section-title { font-family: 'Barlow Condensed', sans-serif; font-size: 10px; font-weight: 700; letter-spacing: 3px; color: var(--gold); text-transform: uppercase; margin: 0 0 8px; }
.jd-modal__section p { font-size: 14px; color: var(--txt); line-height: 1.65; margin: 0; }
.jd-modal__curious { font-size: 14px; color: var(--txt); line-height: 1.65; border-left: 3px solid var(--gold); background: rgba(212,175,55,0.04); padding: 10px 14px; border-radius: 0 8px 8px 0; }
.jd-modal__list { padding-left: 18px; margin: 0; }
.jd-modal__list li { font-size: 14px; color: var(--txt); margin-bottom: 7px; line-height: 1.5; }

.jd-fade-enter-active, .jd-fade-leave-active { transition: opacity 0.22s ease; }
.jd-fade-enter-from, .jd-fade-leave-to { opacity: 0; }

@media (max-width: 600px) {
  .jd-hero { padding: 110px 20px 56px; }
  .jd-container { padding: 0 14px; }
  .jd-modal__body, .jd-modal__header, .jd-modal__stats { padding-left: 16px; padding-right: 16px; }
}
</style>