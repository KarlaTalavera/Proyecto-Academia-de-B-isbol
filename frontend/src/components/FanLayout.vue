<template>
  <div class="page">

    <!-- ===== SIDEBAR FAN ===== -->
    <aside class="navbar navbar-vertical navbar-expand-lg">
      <div class="container-fluid flex-column h-100" style="padding: 0;">

        <!-- Brand -->
        <RouterLink class="navbar-brand d-flex align-items-center gap-2 text-decoration-none" to="/fan">
          <div class="brand-logo">⚾</div>
          <div class="brand-text">
            <strong>Liga Diamante</strong>
            <span>Zona del Fanático</span>
          </div>
        </RouterLink>

        <!-- Nav -->
        <div class="navbar-collapse collapse show flex-column flex-grow-1 overflow-auto" id="sidebar-menu">
          <ul class="navbar-nav w-100">

            <li class="nav-section-label">Mi Zona</li>

            <li class="nav-item">
              <RouterLink class="nav-link" :to="{ name: 'FanInicio' }">
                <span class="nav-link-icon"><IconHome :size="20" stroke-width="1.7" /></span>
                <span class="nav-link-title">Mi Inicio</span>
              </RouterLink>
            </li>

            <li class="nav-item">
              <RouterLink class="nav-link" :to="{ name: 'MisEquipos' }">
                <span class="nav-link-icon"><IconHeart :size="20" stroke-width="1.7" /></span>
                <span class="nav-link-title">Mis Equipos</span>
                <span v-if="totalSeguidos > 0" class="ms-auto badge" style="background:rgba(239,68,68,0.15); color:#ef4444; font-size:0.65rem;">{{ totalSeguidos }}</span>
              </RouterLink>
            </li>

            <li class="nav-section-label mt-1">La Liga</li>

            <li class="nav-item">
              <RouterLink class="nav-link" :to="{ name: 'FanPartidos' }">
                <span class="nav-link-icon"><IconCalendarEvent :size="20" stroke-width="1.7" /></span>
                <span class="nav-link-title">Próximos Juegos</span>
              </RouterLink>
            </li>

            <li class="nav-item">
              <RouterLink class="nav-link" :to="{ name: 'FanPosiciones' }">
                <span class="nav-link-icon"><IconTrophy :size="20" stroke-width="1.7" /></span>
                <span class="nav-link-title">Tabla de Posiciones</span>
              </RouterLink>
            </li>

            <li class="nav-item">
              <RouterLink class="nav-link" :to="{ name: 'FanEstadisticas' }">
                <span class="nav-link-icon"><IconChartBar :size="20" stroke-width="1.7" /></span>
                <span class="nav-link-title">Estadísticas</span>
              </RouterLink>
            </li>

          </ul>
        </div>

        <!-- User card bottom -->
        <div class="w-100 pb-2">
          <div class="sidebar-user">
            <div class="user-avatar" style="background: linear-gradient(135deg, #ef4444, #f97316);">{{ inicialNombre }}</div>
            <div class="user-info">
              <div class="user-name">{{ auth.nombre }}</div>
              <div class="user-role">Fanático ⚾</div>
            </div>
            <button class="btn-logout" @click="cerrarSesion" title="Cerrar sesión">
              <IconLogout :size="18" stroke-width="1.7" />
            </button>
          </div>
        </div>

      </div>
    </aside>

    <!-- ===== PAGE WRAPPER ===== -->
    <div class="page-wrapper">

      <!-- Top header -->
      <div class="top-header d-none d-lg-flex">
        <div class="top-greeting">
          ¡Hola, <strong>{{ auth.nombre }}</strong>! Bienvenido a tu zona de béisbol.
        </div>
        <div class="top-user-avatar" style="background: linear-gradient(135deg, #ef4444, #f97316);">{{ inicialNombre }}</div>
      </div>

      <!-- Page body -->
      <div class="page-body">
        <div class="container-xl py-3">
          <RouterView />
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { RouterLink, RouterView, useRouter } from 'vue-router'
import { useAuthStore } from '@/store/auth'
import api from '@/services/api'
import {
  IconHome, IconHeart, IconCalendarEvent, IconTrophy,
  IconChartBar, IconLogout,
} from '@tabler/icons-vue'

const auth   = useAuthStore()
const router = useRouter()

const inicialNombre  = computed(() => auth.nombre?.charAt(0)?.toUpperCase() || '?')
const totalSeguidos  = ref(0)

async function cargarConteo() {
  try {
    const { data } = await api.get('/fan/mis-equipos')
    totalSeguidos.value = data.length
  } catch {}
}

onMounted(cargarConteo)

function cerrarSesion() {
  auth.logout()
  router.push({ name: 'Login' })
}
</script>
