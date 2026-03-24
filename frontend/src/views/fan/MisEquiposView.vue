<template>
  <div>
    <div class="page-header mb-4">
      <h2 class="page-title">Mis Equipos</h2>
      <p class="page-subtitle">Sigue los equipos que más te apasionan</p>
    </div>

    <div v-if="cargando" class="text-center py-5 text-muted">Cargando equipos...</div>

    <template v-else>
      <!-- Sin equipos en la liga -->
      <div v-if="!equipos.length" class="text-center py-5 text-muted">
        Aún no hay equipos registrados en la liga.
      </div>

      <!-- Grid de equipos -->
      <div v-else>
        <!-- Banner si aún no sigue ninguno -->
        <div v-if="!equiposSeguidos.length" class="alert d-flex align-items-center gap-3 mb-4" style="background:rgba(99,102,241,0.08); border:1px solid rgba(99,102,241,0.2); border-radius:14px;">
          <IconHeart :size="22" style="color:#6366f1; flex-shrink:0;" />
          <div>
            <strong style="color:#4f46e5;">¡Sigue tu primer equipo!</strong>
            <span class="text-muted ms-1" style="font-size:0.875rem;">Presiona el corazón para recibir sus novedades en tu inicio.</span>
          </div>
        </div>

        <div class="row g-3">
          <div v-for="eq in equipos" :key="eq.id_equipo" class="col-sm-6 col-lg-4">
            <div class="card h-100" style="transition: transform 0.15s;" @mouseenter="e => e.currentTarget.style.transform='translateY(-3px)'" @mouseleave="e => e.currentTarget.style.transform=''">
              <div class="card-body d-flex align-items-center gap-3 p-4">
                <div class="team-avatar" style="width:52px; height:52px; font-size:1.3rem; flex-shrink:0;">
                  {{ eq.nombre_equipo?.charAt(0)?.toUpperCase() }}
                </div>
                <div class="flex-grow-1 min-width-0">
                  <div class="fw-bold" style="font-size:0.95rem; color:#1e293b;">{{ eq.nombre_equipo }}</div>
                  <div class="text-muted" style="font-size:0.78rem;">{{ eq.entrenador || 'Sin entrenador asignado' }}</div>
                </div>
                <button
                  class="btn-heart"
                  :class="{ 'activo': eq.siguiendo }"
                  :disabled="procesando[eq.id_equipo]"
                  @click="toggleSeguir(eq)"
                  :title="eq.siguiendo ? 'Dejar de seguir' : 'Seguir este equipo'"
                >
                  <IconHeartFilled v-if="eq.siguiendo" :size="22" />
                  <IconHeart v-else :size="22" stroke-width="1.7" />
                </button>
              </div>
              <div v-if="eq.siguiendo" class="px-4 pb-3">
                <span class="badge" style="background:rgba(239,68,68,0.12); color:#ef4444; font-size:0.68rem;">Siguiendo ⚾</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { IconHeart, IconHeartFilled } from '@tabler/icons-vue'

const cargando  = ref(true)
const equipos   = ref([])
const procesando = ref({})

const equiposSeguidos = computed(() => equipos.value.filter(e => e.siguiendo))

async function cargar() {
  cargando.value = true
  try {
    const { data } = await api.get('/fan/equipos')
    equipos.value = data
  } finally {
    cargando.value = false
  }
}

async function toggleSeguir(eq) {
  procesando.value[eq.id_equipo] = true
  try {
    if (eq.siguiendo) {
      await api.delete(`/fan/seguir/${eq.id_equipo}`)
      eq.siguiendo = 0
    } else {
      await api.post(`/fan/seguir/${eq.id_equipo}`)
      eq.siguiendo = 1
    }
  } catch {
    // revertir en error
  } finally {
    procesando.value[eq.id_equipo] = false
  }
}

onMounted(cargar)
</script>

<style scoped>
.btn-heart {
  background: none;
  border: none;
  cursor: pointer;
  color: #cbd5e1;
  padding: 6px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: color 0.15s, background 0.15s, transform 0.1s;
  flex-shrink: 0;
}
.btn-heart:hover {
  color: #ef4444;
  background: rgba(239, 68, 68, 0.1);
  transform: scale(1.15);
}
.btn-heart.activo {
  color: #ef4444;
}
.btn-heart:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
