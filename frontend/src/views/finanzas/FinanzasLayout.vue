<template>
  <div>
    <div class="page-header mb-4">
      <h2 class="page-title">Control Financiero</h2>
      <p class="page-subtitle">Registro de ingresos y egresos de la liga</p>
    </div>

    <!-- Tabs pill estilo consistente con el resto del sistema -->
    <div class="d-flex gap-1 mb-4 p-1" style="background:rgba(0,0,0,0.06); border-radius:14px; max-width:280px;">
      <RouterLink
        :to="{ name: 'Ingresos' }"
        class="btn btn-sm flex-fill tab-finanzas"
        :class="esIngresos ? 'btn-white shadow-sm fw-semibold' : 'btn-ghost-secondary'"
        style="border-radius:10px; font-size:0.85rem;"
      >
        💰 Ingresos
      </RouterLink>
      <RouterLink
        :to="{ name: 'Egresos' }"
        class="btn btn-sm flex-fill tab-finanzas"
        :class="esEgresos ? 'btn-white shadow-sm fw-semibold' : 'btn-ghost-secondary'"
        style="border-radius:10px; font-size:0.85rem;"
      >
        📤 Egresos
      </RouterLink>
    </div>

    <RouterView />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { RouterLink, RouterView, useRoute } from 'vue-router'

const route     = useRoute()
const esIngresos = computed(() => route.name === 'Ingresos')
const esEgresos  = computed(() => route.name === 'Egresos')
</script>
