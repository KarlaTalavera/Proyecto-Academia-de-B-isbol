<template>
  <div class="page">

    <!-- ===== SIDEBAR ===== -->
    <aside class="navbar navbar-vertical navbar-expand-lg">
      <div class="container-fluid flex-column h-100" style="padding: 0;">

        <!-- Brand -->
        <RouterLink class="navbar-brand d-flex align-items-center gap-2 text-decoration-none" to="/">
          <div class="brand-logo">⚾</div>
          <div class="brand-text">
            <strong>Liga Diamante</strong>
            <span>Sistema de Gestión</span>
          </div>
        </RouterLink>

        <!-- Nav -->
        <div class="navbar-collapse collapse show flex-column flex-grow-1 overflow-auto" id="sidebar-menu">
          <ul class="navbar-nav w-100">

            <li class="nav-section-label">Principal</li>

            <li class="nav-item">
              <RouterLink class="nav-link" :to="{ name: 'Dashboard' }" active-class="">
                <span class="nav-link-icon"><IconLayoutDashboard :size="20" stroke-width="1.7" /></span>
                <span class="nav-link-title">Dashboard</span>
              </RouterLink>
            </li>

            <li class="nav-item">
              <RouterLink class="nav-link" :to="{ name: 'Equipos' }">
                <span class="nav-link-icon"><IconShield :size="20" stroke-width="1.7" /></span>
                <span class="nav-link-title">Equipos</span>
              </RouterLink>
            </li>

            <li class="nav-item">
              <RouterLink class="nav-link" :to="{ name: 'Jugadores' }">
                <span class="nav-link-icon"><IconUsers :size="20" stroke-width="1.7" /></span>
                <span class="nav-link-title">Jugadores</span>
              </RouterLink>
            </li>

            <li class="nav-item">
              <RouterLink class="nav-link" :to="{ name: 'Partidos' }">
                <span class="nav-link-icon"><IconCalendarEvent :size="20" stroke-width="1.7" /></span>
                <span class="nav-link-title">Partidos</span>
              </RouterLink>
            </li>

            <li class="nav-item">
              <RouterLink class="nav-link" :to="{ name: 'Reportes' }">
                <span class="nav-link-icon"><IconChartBar :size="20" stroke-width="1.7" /></span>
                <span class="nav-link-title">Reportes</span>
              </RouterLink>
            </li>

            <!-- Finanzas: solo caja y admin -->
            <template v-if="auth.puedeFinanzas">
              <li class="nav-section-label mt-1">Administración</li>
              <li class="nav-item">
                <RouterLink class="nav-link" :to="{ name: 'Ingresos' }">
                  <span class="nav-link-icon"><IconWallet :size="20" stroke-width="1.7" /></span>
                  <span class="nav-link-title">Finanzas</span>
                </RouterLink>
              </li>
            </template>

            <!-- Usuarios y Temporadas: solo administrador -->
            <template v-if="auth.esAdmin">
              <li v-if="!auth.puedeFinanzas" class="nav-section-label mt-1">Administración</li>
              <li class="nav-item">
                <RouterLink class="nav-link" :to="{ name: 'Temporadas' }">
                  <span class="nav-link-icon"><IconCalendar :size="20" stroke-width="1.7" /></span>
                  <span class="nav-link-title">Temporadas</span>
                </RouterLink>
              </li>
              <li class="nav-item">
                <RouterLink class="nav-link" :to="{ name: 'Usuarios' }">
                  <span class="nav-link-icon"><IconUsersGroup :size="20" stroke-width="1.7" /></span>
                  <span class="nav-link-title">Usuarios</span>
                </RouterLink>
              </li>
            </template>

          </ul>
        </div>

        <!-- User card bottom -->
        <div class="w-100 pb-2">
          <div class="sidebar-user">
            <div class="user-avatar">{{ inicialNombre }}</div>
            <div class="user-info">
              <div class="user-name">{{ auth.nombre }}</div>
              <div class="user-role">{{ etiquetaRol }}</div>
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
          Bienvenido de vuelta, <strong>{{ auth.nombre }}</strong> 👋
        </div>
        <div class="top-user-info">
          <span class="ms-2 badge" :class="badgeRol">{{ etiquetaRol }}</span>
          <span class="top-user-name">{{ auth.nombre }}</span>
          <div class="top-user-avatar">{{ inicialNombre }}</div>
        </div>
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
import { computed } from 'vue'
import { RouterLink, RouterView, useRouter } from 'vue-router'
import { useAuthStore } from '@/store/auth'
import {
  IconLayoutDashboard, IconShield, IconUsers, IconCalendarEvent,
  IconWallet, IconChartBar, IconLogout, IconUsersGroup, IconCalendar,
} from '@tabler/icons-vue'

const auth   = useAuthStore()
const router = useRouter()

const inicialNombre = computed(() => auth.nombre?.charAt(0)?.toUpperCase() || '?')

const ETIQUETAS = {
  administrador: 'Administrador',
  dueno:         'Dueño',
  caja:          'Caja',
  anotador:      'Anotador',
  publico:       'Público',
}
const etiquetaRol = computed(() => ETIQUETAS[auth.rol] || auth.rol)

const badgeRol = computed(() => ({
  'bg-blue-lt text-blue':     auth.rol === 'administrador',
  'bg-indigo-lt text-indigo': auth.rol === 'anotador',
  'bg-green-lt text-green':   auth.rol === 'caja',
  'bg-orange-lt text-orange': auth.rol === 'dueno',
  'bg-secondary-lt':          auth.rol === 'publico',
}))

function cerrarSesion() {
  auth.logout()
  router.push({ name: 'Login' })
}
</script>
