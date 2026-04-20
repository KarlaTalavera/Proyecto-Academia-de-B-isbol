<template>
  <span ref="el" class="abrev-tip" @mouseenter="mostrar" @mouseleave="ocultar">{{ ab }}</span>

  <Teleport to="body">
    <div v-if="visible" class="abrev-tip-popup" :style="estiloPopup">
      {{ descripcion }}
      <span class="abrev-tip-arrow"></span>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, computed } from 'vue'

const ABREVIATURAS = {
  /* ── Posiciones / Standing ─────────────────── */
  'JJ':   'Juegos Jugados',
  'JV':   'Juegos Jugados (Visitante)',
  'G':    'Ganados (Victorias)',
  'P':    'Perdidos (Derrotas)',
  'CF':   'Carreras a Favor',
  'CC':   'Carreras en Contra',
  'DIF':  'Diferencial de Carreras (CF − CC)',
  'PCT':  'Porcentaje de Victorias',
  'PTS':  'Puntos',
  '%':    'Porcentaje de Victorias',
  'GB':   'Juegos Atrás del líder (Games Behind)',

  /* ── Bateo / Ofensiva ───────────────────────── */
  'AB':   'Turnos al Bate (At Bats)',
  'H':    'Hits (Batazos buenos)',
  '2B':   'Dobles',
  '3B':   'Triples',
  'HR':   'Jonrones (Home Runs)',
  'R':    'Carreras Anotadas (Runs)',
  'RBI':  'Carreras Impulsadas (Runs Batted In)',
  'AVE':  'Promedio de Bateo — Hits ÷ Turnos al Bate',
  'AVG':  'Promedio de Bateo — Hits ÷ Turnos al Bate',
  'BB':   'Bases por Bolas (Walks)',
  'K':    'Ponches (Strikeouts)',
  'SO':   'Ponches (Strikeouts)',
  'SB':   'Bases Robadas (Stolen Bases)',

  /* ── Pitcheo / Lanzamiento ─────────────────── */
  'IP':   'Innings Pitcheados',
  'ER':   'Carreras Limpias (Earned Runs)',
  'ERA':  'Efectividad — (CR × 9) ÷ Innings Pitcheados',
  'WHIP': 'Bases por Bolas + Hits por Inning Pitcheado',
  'W':    'Victorias del Lanzador',
  'L':    'Derrotas del Lanzador',
  'SV':   'Salvados (Saves)',
  'S':    'Salvados (Saves)',
  'HB':   'Bateadores Golpeados (Hit by Pitch)',

  /* ── Finanzas ───────────────────────────────── */
  'Bs.':  'Bolívares Soberanos',
}

const props = defineProps({
  ab: { type: String, required: true },
})

const descripcion = computed(() => ABREVIATURAS[props.ab] || props.ab)

const el      = ref(null)
const visible = ref(false)
const top     = ref(0)
const left    = ref(0)

function mostrar() {
  if (!el.value) return
  const rect = el.value.getBoundingClientRect()
  top.value  = rect.top + window.scrollY - 8   // 8px gap above element
  left.value = rect.left + rect.width / 2
  visible.value = true
}

function ocultar() {
  visible.value = false
}

const estiloPopup = computed(() => ({
  top:  top.value + 'px',
  left: left.value + 'px',
}))
</script>

<style scoped>
.abrev-tip {
  display: inline-block;
  cursor: help;
  border-bottom: 1px dashed #94a3b8;
}
</style>

<style>
/* Global — tooltip rendered in <body> via Teleport */
.abrev-tip-popup {
  position: absolute;
  transform: translate(-50%, -100%);
  background: #1e293b;
  color: #f8fafc;
  font-size: 0.72rem;
  font-weight: 400;
  line-height: 1.4;
  padding: 5px 10px;
  border-radius: 6px;
  white-space: nowrap;
  pointer-events: none;
  z-index: 99999;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

/* Arrow pointing down toward the element */
.abrev-tip-arrow {
  position: absolute;
  bottom: -5px;
  left: 50%;
  transform: translateX(-50%);
  border: 5px solid transparent;
  border-top-color: #1e293b;
  display: block;
  width: 0;
  height: 0;
}
</style>
