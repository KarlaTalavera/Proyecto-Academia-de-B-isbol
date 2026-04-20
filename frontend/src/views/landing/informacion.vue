<template>
  <div class="ig-page">
    <LandingHeader />

    <!-- ── HERO ── -->
    <section class="ig-hero">
      <div class="ig-hero__glow" />
      <div class="ig-hero__content">
        <p class="ig-hero__kicker">TEMPORADA CLAUSURA · FEB – ABR 2026</p>
        <h1 class="ig-hero__title">
          LIGA<br />
          <span class="ig-hero__title--accent">DIAMANTE</span>
        </h1>
        <p class="ig-hero__sub">
          Béisbol semiprofesional venezolano.<br />
          8 equipos. Una temporada. Un campeón.
        </p>
      </div>
      <div class="ig-hero__deco">◆</div>
    </section>

    <!-- ── STRIP DE DATOS REALES ── -->
    <div class="ig-strip">
      <div class="ig-strip__inner">
        <div class="ig-strip__item">
          <span class="ig-strip__val">8</span>
          <span class="ig-strip__lbl">EQUIPOS INSCRITOS</span>
        </div>
        <div class="ig-strip__sep">◆</div>
        <div class="ig-strip__item">
          <span class="ig-strip__val">80</span>
          <span class="ig-strip__lbl">JUGADORES ACTIVOS</span>
        </div>
        <div class="ig-strip__sep">◆</div>
        <div class="ig-strip__item">
          <span class="ig-strip__val">Bs. 5.500</span>
          <span class="ig-strip__lbl">COSTO INSCRIPCIÓN</span>
        </div>
        <div class="ig-strip__sep">◆</div>
        <div class="ig-strip__item">
          <span class="ig-strip__val">Semi-Pro</span>
          <span class="ig-strip__lbl">CATEGORÍA</span>
        </div>
      </div>
    </div>

    <!-- ── SOBRE LA TEMPORADA ── -->
    <section class="ig-section">
      <div class="ig-container ig-about">
        <div class="ig-about__text">
          <span class="ig-eyebrow">TEMPORADA CLAUSURA 2026</span>
          <h2 class="ig-title">La temporada<br /><em>más grande</em></h2>
          <p>
            La Liga Diamante de Béisbol inició su <strong>Temporada Clausura 2026</strong>
            el 1 de febrero de 2026, reuniendo por primera vez a los 8 equipos más
            representativos del béisbol semiprofesional venezolano en una misma competencia.
          </p>
          <p>
            Con un costo de inscripción de <strong>Bs. 5.500 por equipo</strong> y
            80 peloteros registrados, esta temporada marca el nivel más alto de
            organización y competencia en la historia de nuestra liga.
            Cada juego es anotado en tiempo real por nuestros anotadores oficiales,
            garantizando estadísticas precisas para cada jugador.
          </p>
        </div>
        <div class="ig-about__card">
          <div class="ig-about__card-inner">
            <div class="ig-about__logo">◆</div>
            <div class="ig-about__card-title">CLAUSURA<br />2026</div>
            <div class="ig-about__dates">
              <div class="ig-about__date-row">
                <span class="ig-about__date-lbl">Inscripciones</span>
                <span class="ig-about__date-val">01 FEB 2026</span>
              </div>
              <div class="ig-about__divline" />
              <div class="ig-about__date-row">
                <span class="ig-about__date-lbl">Temporada Regular</span>
                <span class="ig-about__date-val">MAR 2026</span>
              </div>
              <div class="ig-about__divline" />
              <div class="ig-about__date-row">
                <span class="ig-about__date-lbl">Serie Final</span>
                <span class="ig-about__date-val">ABR 2026</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ── LOS 8 EQUIPOS ── -->
    <section class="ig-section ig-section--dark">
      <div class="ig-container">
        <span class="ig-eyebrow ig-eyebrow--center">CLAUSURA 2026</span>
        <h2 class="ig-title ig-title--center">Los <em>8 equipos</em><br />de la temporada</h2>
        <div class="ig-teams">
          <div class="ig-team" v-for="team in teams" :key="team.name">
            <div class="ig-team__icon">⚾</div>
            <div class="ig-team__info">
              <span class="ig-team__name">{{ team.name }}</span>
              <span class="ig-team__coach">DT: {{ team.coach }}</span>
            </div>
            <span class="ig-team__badge ig-team__badge--paid">PARTICIPANTE</span>
          </div>
        </div>
      </div>
    </section>


    <!-- ── REGLAMENTO REAL ── -->
    <section class="ig-section ig-section--dark">
      <div class="ig-container">
        <span class="ig-eyebrow ig-eyebrow--center">REGLAMENTO OFICIAL</span>
        <h2 class="ig-title ig-title--center">Las reglas de la<br /><em>Liga Diamante</em></h2>
        <div class="ig-rules">
          <div class="ig-rule" v-for="rule in rules" :key="rule.title">
            <div class="ig-rule__icon">{{ rule.icon }}</div>
            <div>
              <h4 class="ig-rule__title">{{ rule.title }}</h4>
              <p class="ig-rule__text">{{ rule.text }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>



    <!-- ── SANCIONES ── -->
    <section class="ig-section ig-section--dark">
      <div class="ig-container">
        <span class="ig-eyebrow ig-eyebrow--center">DISCIPLINA</span>
        <h2 class="ig-title ig-title--center">Control<br /><em>disciplinario</em></h2>
        <div class="ig-sanctions">
          <div class="ig-sanction" v-for="s in sanctions" :key="s.type">
            <div class="ig-sanction__icon">{{ s.icon }}</div>
            <h4 class="ig-sanction__type">{{ s.type }}</h4>
            <p class="ig-sanction__text">{{ s.text }}</p>
          </div>
        </div>
        <p class="ig-sanctions__note">
          Todas las sanciones son registradas por temporada y pueden afectar a jugadores
          individuales o al equipo completo. El estado de cada sanción puede ser:
          <strong>activa</strong>, <strong>cumplida</strong>, <strong>apelada</strong> o <strong>revocada</strong>.
        </p>
      </div>
    </section>

    <!-- ── CTA ── -->
    <section class="ig-cta">
      <div class="ig-cta__deco">◆</div>
      <div class="ig-cta__content">
        <h2 class="ig-cta__title">Vive la<br /><em>temporada</em></h2>
        <p class="ig-cta__sub">
          Sigue las últimas noticias de la liga o explora los equipos
          que hacen posible esta temporada histórica.
        </p>
        <div class="ig-cta__btns">
          <router-link to="/noticias" class="ig-cta__btn ig-cta__btn--gold">
            VER NOTICIAS
          </router-link>
          <router-link to="/equipos" class="ig-cta__btn ig-cta__btn--outline">
            LOS EQUIPOS
          </router-link>
        </div>
      </div>
    </section>

  </div>
</template>

<script setup>
import LandingHeader from '@/components/landing/LandingHeader.vue'

// Datos reales del test-data.sql
const teams = [
  { name: 'Leones de Caracas',         coach: 'Carlos Mendoza'   },
  { name: 'Tigres de Aragua',           coach: 'José Rodríguez'   },
  { name: 'Águilas del Zulia',          coach: 'Miguel Hernández' },
  { name: 'Navegantes del Magallanes',  coach: 'Roberto Silva'    },
  { name: 'Caribes de Anzoátegui',      coach: 'Fernando Torres'  },
  { name: 'Bravos de Margarita',        coach: 'Andrés Morales'   },
  { name: 'Cardenales de Lara',         coach: 'Ricardo Vargas'   },
  { name: 'Tiburones de La Guaira',     coach: 'Daniel Castillo'  },
]

// Posiciones del ENUM en la BD
const positions = [
  { code: 'P',  name: 'Pitcher' },
  { code: 'C',  name: 'Cátcher' },
  { code: '1B', name: 'Primera Base' },
  { code: '2B', name: 'Segunda Base' },
  { code: '3B', name: 'Tercera Base' },
  { code: 'SS', name: 'Shortstop' },
  { code: 'LF', name: 'Left Field' },
  { code: 'CF', name: 'Center Field' },
  { code: 'RF', name: 'Right Field' },
  { code: 'DH', name: 'Bateador Designado' },
  { code: 'UT', name: 'Utilidad' },
]

// Reglas basadas en la estructura real de la BD
const rules = [
  {
    icon: '📋',
    title: 'Inscripción por temporada',
    text: 'Cada equipo debe inscribirse y cancelar Bs. 5.500 para participar en la temporada. Sin pago confirmado, el equipo no puede disputar juegos oficiales.',
  },
  {
    icon: '👥',
    title: 'Roster de jugadores',
    text: 'Cada equipo registra hasta 10 jugadores por nómina activa. Cada jugador debe tener cédula de identidad, fecha de nacimiento, posición y rol registrados.',
  },
  {
    icon: '⚾',
    title: 'Innings programados',
    text: 'Los partidos se programan a 9 innings. El sistema registra la cantidad de innings jugados en el resultado final de cada partido.',
  },
  {
    icon: '📝',
    title: 'Anotación oficial',
    text: 'Cada partido es anotado por un anotador oficial de la liga, que registra el desempeño individual de bateadores y pitchers en tiempo real.',
  },
  {
    icon: '🏆',
    title: 'Pitcher ganador y perdedor',
    text: 'Al finalizar cada juego se designa oficialmente un pitcher ganador, un pitcher perdedor y, si aplica, un pitcher salvador. Estos datos quedan en el resultado.',
  },
  {
    icon: '🔄',
    title: 'Estados del partido',
    text: 'Un partido puede estar: programado, en curso, finalizado o suspendido. Solo los partidos finalizados cuentan para el standing de la temporada.',
  },
  {
    icon: '🚫',
    title: 'Suspensión de jugadores',
    text: 'El comité disciplinario puede suspender jugadores por conducta antideportiva. La suspensión especifica la cantidad exacta de partidos que no puede jugar.',
  },
  {
    icon: '💰',
    title: 'Multas a equipos',
    text: 'Los equipos pueden recibir multas económicas por incumplimientos como retrasos al estadio o infracciones al reglamento. El monto queda registrado en el sistema.',
  },
]

// Stats del schema desempeno_bateador
const batStats = [
  'Turnos al bate (AB)',
  'Hits',
  'Dobles',
  'Triples',
  'Jonrones (HR)',
  'Carreras anotadas',
  'Carreras impulsadas (RBI)',
  'Bases por bolas (BB)',
  'Ponches recibidos (K)',
  'Fouls',
  'Outs',
  'Asistencias',
]

// Stats del schema desempeno_pitcher
const pitchStats = [
  'Innings pitcheados (IP)',
  'Hits permitidos',
  'Carreras permitidas',
  'Carreras limpias (ER)',
  'Jonrones permitidos',
  'Golpes al bateador (HBP)',
  'Bases por bolas dadas (BB)',
  'Ponches (K)',
  'Ganado / Perdido / Salvado',
]

// Stats del schema resultado
const gameStats = [
  'Carreras por equipo',
  'Hits por equipo',
  'Errores por equipo',
  'Innings totales jugados',
  'Pitcher ganador',
  'Pitcher perdedor',
  'Pitcher salvador',
]

// Tipos de sanción del ENUM en BD
const sanctions = [
  {
    icon: '⚠️',
    type: 'Amonestación',
    text: 'Advertencia oficial registrada en el historial del jugador o equipo. No implica suspensión de juegos pero queda en el expediente de la temporada.',
  },
  {
    icon: '🚫',
    type: 'Suspensión',
    text: 'El jugador no puede participar en la cantidad de partidos indicada. La sanción es por conductas antideportivas graves como agresiones verbales o físicas.',
  },
  {
    icon: '💸',
    type: 'Multa',
    text: 'Sanción económica aplicada al equipo por incumplimientos administrativos como retrasos, irregularidades en el roster o faltas al reglamento de la liga.',
  },
  {
    icon: '🔴',
    type: 'Expulsión',
    text: 'La sanción más severa. El jugador es expulsado de la temporada en curso. Solo se aplica en casos de faltas muy graves evaluadas por el comité disciplinario.',
  },
]
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Barlow+Condensed:wght@400;700&family=Barlow:wght@400;500&display=swap');

.ig-page {
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
.ig-hero {
  position: relative;
  min-height: 500px;
  display: flex;
  align-items: flex-end;
  padding: 140px 60px 80px;
  overflow: hidden;
  background:
    radial-gradient(ellipse 55% 65% at 85% 50%, rgba(140,9,2,0.2) 0%, transparent 70%),
    var(--bg-dark);
  border-bottom: 1px solid var(--border);
}

.ig-hero__glow {
  position: absolute;
  inset: 0;
  background: radial-gradient(ellipse 40% 40% at 20% 80%, rgba(212,175,55,0.04) 0%, transparent 60%);
  pointer-events: none;
}

.ig-hero__content {
  position: relative;
  z-index: 2;
  max-width: 680px;
}

.ig-hero__kicker {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 5px;
  color: var(--gold);
  text-transform: uppercase;
  margin: 0 0 20px;
  display: flex;
  align-items: center;
  gap: 14px;
}
.ig-hero__kicker::before {
  content: '';
  display: block;
  width: 36px;
  height: 2px;
  background: var(--red);
  flex-shrink: 0;
}

.ig-hero__title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(80px, 13vw, 152px);
  line-height: 0.9;
  margin: 0 0 24px;
  color: white;
  letter-spacing: 2px;
}
.ig-hero__title--accent { color: var(--gold); }

.ig-hero__sub {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 18px;
  color: var(--txt);
  line-height: 1.65;
  margin: 0;
}

.ig-hero__deco {
  position: absolute;
  right: 60px;
  top: 50%;
  transform: translateY(-50%);
  font-size: clamp(120px, 18vw, 260px);
  color: rgba(212,175,55,0.04);
  user-select: none;
  pointer-events: none;
  animation: spin 50s linear infinite;
}
@keyframes spin { to { transform: translateY(-50%) rotate(360deg); } }

/* ── Strip ── */
.ig-strip {
  background: var(--red);
  border-bottom: 3px solid var(--gold);
}
.ig-strip__inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 60px;
  display: flex;
  align-items: center;
}
@media (max-width: 768px) {
  .ig-strip__inner { flex-wrap: wrap; padding: 0 24px; }
}
.ig-strip__item {
  flex: 1;
  padding: 22px 0;
  display: flex;
  flex-direction: column;
  gap: 3px;
  min-width: 100px;
}
.ig-strip__sep { color: rgba(255,255,255,0.2); font-size: 10px; padding: 0 16px; }
.ig-strip__val {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 26px;
  color: var(--gold);
  line-height: 1;
  letter-spacing: 1px;
}
.ig-strip__lbl {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 3px;
  color: rgba(255,255,255,0.5);
  text-transform: uppercase;
}

/* ── Sections ── */
.ig-section       { padding: 96px 0; }
.ig-section--dark { background: var(--bg-dark); }
.ig-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 60px;
}
@media (max-width: 768px) {
  .ig-container { padding: 0 24px; }
  .ig-section   { padding: 64px 0; }
}

/* ── Eyebrow / Title ── */
.ig-eyebrow {
  display: block;
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 5px;
  color: var(--gold);
  text-transform: uppercase;
  margin-bottom: 14px;
}
.ig-eyebrow--center { text-align: center; }

.ig-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(38px, 5vw, 60px);
  line-height: 1.0;
  color: white;
  margin: 0 0 48px;
  letter-spacing: 1px;
}
.ig-title em      { color: var(--gold); font-style: normal; }
.ig-title--center { text-align: center; }

/* ── About ── */
.ig-about {
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 80px;
  align-items: center;
}
@media (max-width: 1023px) { .ig-about { grid-template-columns: 1fr; gap: 40px; } }

.ig-about__text p {
  font-size: 15px;
  line-height: 1.85;
  color: var(--txt);
  margin: 0 0 16px;
}
.ig-about__text strong { color: white; }

.ig-about__card {
  border: 1px solid var(--border);
  border-radius: 20px;
  background: var(--bg-card);
  overflow: hidden;
}
.ig-about__card-inner {
  padding: 36px 28px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  text-align: center;
}
.ig-about__logo {
  font-size: 40px;
  color: var(--gold);
  line-height: 1;
}
.ig-about__card-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 30px;
  letter-spacing: 2px;
  color: white;
  line-height: 1.1;
}
.ig-about__dates {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 4px;
}
.ig-about__date-row { display: flex; justify-content: space-between; align-items: center; }
.ig-about__date-lbl {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 2px;
  color: var(--txt-dim);
  text-transform: uppercase;
}
.ig-about__date-val {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 15px;
  letter-spacing: 1px;
  color: var(--gold);
}
.ig-about__divline { height: 1px; background: var(--border); }

/* ── Teams ── */
.ig-teams {
  display: flex;
  flex-direction: column;
  gap: 2px;
  border-radius: 16px;
  overflow: hidden;
  background: rgba(255,255,255,0.03);
}
.ig-team {
  background: var(--bg-card);
  padding: 18px 28px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: background 0.2s;
}
.ig-team:hover { background: rgba(212,175,55,0.06); }
.ig-team__icon { font-size: 20px; flex-shrink: 0; }
.ig-team__info { flex: 1; display: flex; flex-direction: column; gap: 2px; }
.ig-team__name {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 0.5px;
  color: white;
  text-transform: uppercase;
}
.ig-team__coach {
  font-size: 12px;
  color: var(--txt-dim);
}
.ig-team__badge {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 2px;
  padding: 4px 12px;
  border-radius: 999px;
}
.ig-team__badge--paid    { background: rgba(212,175,55,0.15); color: var(--gold); }
.ig-team__badge--pending { background: rgba(255,255,255,0.06); color: var(--txt-dim); }

/* ── Positions ── */
.ig-positions-layout {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 64px;
  align-items: start;
}
@media (max-width: 768px) { .ig-positions-layout { grid-template-columns: 1fr; gap: 40px; } }

.ig-positions-text p {
  font-size: 15px;
  line-height: 1.85;
  color: var(--txt);
  margin: 0 0 16px;
}
.ig-positions-text strong { color: white; }

.ig-positions-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2px;
  border-radius: 16px;
  overflow: hidden;
  background: rgba(255,255,255,0.03);
}
.ig-pos {
  background: var(--bg-card);
  padding: 16px 18px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  transition: background 0.2s;
}
.ig-pos:hover { background: rgba(212,175,55,0.07); }
.ig-pos__code {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 22px;
  color: var(--gold);
  letter-spacing: 1px;
  line-height: 1;
}
.ig-pos__name {
  font-size: 11px;
  color: var(--txt-dim);
  line-height: 1.3;
}

/* ── Rules ── */
.ig-rules {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 2px;
  border-radius: 20px;
  overflow: hidden;
  background: rgba(255,255,255,0.03);
}
@media (max-width: 768px) { .ig-rules { grid-template-columns: 1fr; } }

.ig-rule {
  background: var(--bg-card);
  padding: 28px;
  display: flex;
  gap: 18px;
  align-items: flex-start;
  transition: background 0.2s;
}
.ig-rule:hover { background: rgba(212,175,55,0.05); }
.ig-rule__icon { font-size: 24px; flex-shrink: 0; margin-top: 2px; }
.ig-rule__title {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
  color: white;
  margin: 0 0 6px;
}
.ig-rule__text { font-size: 13px; line-height: 1.7; color: var(--txt); margin: 0; }

/* ── Stats ── */
.ig-stats-layout {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2px;
  border-radius: 20px;
  overflow: hidden;
  background: rgba(255,255,255,0.03);
}
@media (max-width: 1023px) { .ig-stats-layout { grid-template-columns: 1fr; } }

.ig-stat-group {
  background: var(--bg-card);
  padding: 32px 28px;
}
.ig-stat-group__title {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 1px;
  color: var(--gold);
  text-transform: uppercase;
  margin: 0 0 20px;
}
.ig-stat-list { display: flex; flex-direction: column; gap: 10px; }
.ig-stat-item {
  font-size: 13px;
  color: var(--txt);
  display: flex;
  align-items: center;
  gap: 10px;
}
.ig-stat-item__dot { color: var(--red); font-size: 8px; flex-shrink: 0; }

/* ── Sanctions ── */
.ig-sanctions {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 2px;
  border-radius: 20px;
  overflow: hidden;
  background: rgba(255,255,255,0.03);
  margin-bottom: 28px;
}
@media (max-width: 1023px) { .ig-sanctions { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 640px)  { .ig-sanctions { grid-template-columns: 1fr; } }

.ig-sanction {
  background: var(--bg-card);
  padding: 32px 24px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  transition: background 0.2s;
}
.ig-sanction:hover { background: rgba(140,9,2,0.12); }
.ig-sanction__icon { font-size: 28px; line-height: 1; }
.ig-sanction__type {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 20px;
  color: var(--gold);
  letter-spacing: 1px;
  margin: 0;
}
.ig-sanction__text { font-size: 13px; line-height: 1.7; color: var(--txt); margin: 0; }

.ig-sanctions__note {
  font-size: 13px;
  color: var(--txt-dim);
  line-height: 1.7;
  text-align: center;
  max-width: 720px;
  margin: 0 auto;
}
.ig-sanctions__note strong { color: var(--gold); }

/* ── CTA ── */
.ig-cta {
  position: relative;
  overflow: hidden;
  padding: 120px 60px;
  text-align: center;
  background:
    radial-gradient(ellipse 50% 70% at 50% 50%, rgba(140,9,2,0.22) 0%, transparent 70%),
    var(--bg-dark);
  border-top: 1px solid var(--border);
}
.ig-cta__deco {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: clamp(180px, 30vw, 380px);
  color: rgba(212,175,55,0.03);
  user-select: none;
  pointer-events: none;
  animation: spin 70s linear infinite reverse;
}
.ig-cta__content {
  position: relative;
  z-index: 2;
  max-width: 560px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}
.ig-cta__title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(52px, 9vw, 96px);
  line-height: 1;
  margin: 0;
  letter-spacing: 2px;
}
.ig-cta__title em { color: var(--gold); font-style: normal; }
.ig-cta__sub {
  font-size: 15px;
  line-height: 1.8;
  color: var(--txt);
  margin: 0;
}
.ig-cta__btns {
  display: flex;
  gap: 14px;
  flex-wrap: wrap;
  justify-content: center;
  margin-top: 8px;
}
.ig-cta__btn {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 3px;
  text-transform: uppercase;
  text-decoration: none;
  padding: 14px 38px;
  border-radius: 999px;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
}
.ig-cta__btn--gold {
  background: var(--gold);
  color: var(--bg-dark);
  border: 2px solid var(--gold);
}
.ig-cta__btn--gold:hover {
  background: var(--gold-lt);
  border-color: var(--gold-lt);
}
.ig-cta__btn--outline {
  background: transparent;
  color: var(--gold);
  border: 2px solid var(--gold);
}
.ig-cta__btn--outline:hover {
  background: var(--gold);
  color: var(--bg-dark);
}
</style>