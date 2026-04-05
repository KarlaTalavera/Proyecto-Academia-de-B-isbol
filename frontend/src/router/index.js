import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/store/auth'

const routes = [
  { path: '/login', name: 'Login', component: () => import('@/views/LoginView.vue'), meta: { publico: true } },

  // ── Landing pública ───────────────────────────────────────
  {
    path: '/',
    component: () => import('@/views/landing/LandingLayout.vue'),
    meta: { publico: true },
    children: [
      { path: '',           name: 'LandingInicio',     component: () => import('@/views/landing/InicioView.vue') },
      { path: 'resultados', name: 'LandingResultados', component: () => import('@/views/landing/ResultadosView.vue') },
      { path: 'noticias',   name: 'LandingNoticias',   component: () => import('@/views/landing/NoticiasView.vue') },
      { path: 'standing',   name: 'LandingStanding',   component: () => import('@/views/landing/StandingView.vue') },
      { path: 'calendario', name: 'LandingCalendario', component: () => import('@/views/landing/CalendarioView.vue') },
    ],
  },

  // ── Zona Fanático (rol: publico) ────────────────────────────
  {
    path: '/fan',
    component: () => import('@/components/FanLayout.vue'),
    meta: { requiereAuth: true, soloPublico: true },
    children: [
      { path: '',          name: 'FanInicio',      component: () => import('@/views/fan/FanDashboardView.vue') },
      { path: 'equipos',  name: 'MisEquipos',      component: () => import('@/views/fan/MisEquiposView.vue') },
      { path: 'partidos', name: 'FanPartidos',     component: () => import('@/views/fan/FanPartidosView.vue') },
      { path: 'posiciones', name: 'FanPosiciones', component: () => import('@/views/fan/FanPosicionesView.vue') },
      { path: 'estadisticas', name: 'FanEstadisticas', component: () => import('@/views/fan/FanEstadisticasView.vue') },
    ],
  },

  // ── Zona Administrativa (todos los roles excepto publico) ───
  {
    path: '/app',
    component: () => import('@/components/AppLayout.vue'),
    meta: { requiereAuth: true, bloqueaPublico: true },
    children: [
      { path: '',          name: 'Dashboard', component: () => import('@/views/DashboardView.vue') },
      { path: 'equipos',   name: 'Equipos',   component: () => import('@/views/equipos/EquiposView.vue') },
      { path: 'jugadores', name: 'Jugadores', component: () => import('@/views/jugadores/JugadoresView.vue') },
      { path: 'partidos',  name: 'Partidos',  component: () => import('@/views/partidos/PartidosView.vue') },
      { path: 'reportes',       name: 'Reportes',       component: () => import('@/views/reportes/ReportesView.vue') },
      { path: 'sanciones',     name: 'Sanciones',     component: () => import('@/views/sanciones/SancionesView.vue') },
      { path: 'inscripciones', name: 'Inscripciones', component: () => import('@/views/inscripciones/InscripcionesView.vue') },
      { path: 'proveedores',   name: 'Proveedores',   component: () => import('@/views/proveedores/ProveedoresView.vue') },
      { path: 'temporadas',    name: 'Temporadas',    component: () => import('@/views/temporadas/TemporadasView.vue'), meta: { soloAdmin: true } },
      { path: 'usuarios',      name: 'Usuarios',      component: () => import('@/views/usuarios/UsuariosView.vue'), meta: { soloAdmin: true } },
      {
        path: 'finanzas',
        component: () => import('@/views/finanzas/FinanzasLayout.vue'),
        children: [
          { path: '',         redirect: 'ingresos' },
          { path: 'ingresos', name: 'Ingresos', component: () => import('@/views/finanzas/IngresosView.vue') },
          { path: 'egresos',  name: 'Egresos',  component: () => import('@/views/finanzas/EgresosView.vue') },
        ],
      },
    ],
  },

  { path: '/:pathMatch(.*)*', redirect: { name: 'LandingInicio' } },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  const auth = useAuthStore()

  // Sin sesión intentando acceder a zona protegida → landing
  if (!to.meta.publico && !auth.token) return { name: 'LandingInicio' }

  // Ya autenticado intenta ir al login → redirigir a su zona
  if (auth.token && to.name === 'Login') {
    return auth.rol === 'publico' ? { name: 'FanInicio' } : { name: 'Dashboard' }
  }

  // Usuario público intenta acceder a zona administrativa → zona fan
  if (auth.token && auth.rol === 'publico' && to.meta.bloqueaPublico) {
    return { name: 'FanInicio' }
  }

  // Usuario no-público intenta acceder a zona fan → dashboard admin
  if (auth.token && auth.rol !== 'publico' && to.meta.soloPublico) {
    return { name: 'Dashboard' }
  }

  // Solo admin puede ver ciertas vistas
  if (to.meta.soloAdmin && auth.rol !== 'administrador') return { name: 'Dashboard' }
})

export default router
