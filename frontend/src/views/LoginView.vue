<template>
  <div class="login-wrapper">
    <div class="login-card">

      <!-- Logo -->
      <div class="login-logo">⚾</div>

      <div class="text-center mb-4">
        <h1 class="fw-800 mb-1" style="font-size:1.6rem; color:#1e293b; font-weight:800;">Liga Diamante</h1>
        <p class="text-muted mb-0" style="font-size:0.875rem;">Sistema de Gestión de Liga de Béisbol</p>
      </div>

      <!-- Tabs login / registro -->
      <div class="d-flex gap-1 mb-4 p-1" style="background:rgba(0,0,0,0.06); border-radius:10px;">
        <button
          class="btn btn-sm flex-fill"
          :class="modo === 'login' ? 'btn-white shadow-sm fw-semibold' : 'btn-ghost-secondary'"
          style="border-radius:8px; font-size:0.82rem;"
          @click="cambiarModo('login')"
        >
          Iniciar Sesión
        </button>
        <button
          class="btn btn-sm flex-fill"
          :class="modo === 'registro' ? 'btn-white shadow-sm fw-semibold' : 'btn-ghost-secondary'"
          style="border-radius:8px; font-size:0.82rem;"
          @click="cambiarModo('registro')"
        >
          Registrarse
        </button>
      </div>

      <div v-if="error" class="alert alert-danger d-flex align-items-center gap-2 py-2 mb-3">
        <IconAlertCircle :size="17" />
        <span>{{ error }}</span>
      </div>
      <div v-if="exito" class="alert alert-success d-flex align-items-center gap-2 py-2 mb-3">
        <IconCircleCheck :size="17" />
        <span>{{ exito }}</span>
      </div>

      <!-- Formulario LOGIN -->
      <form v-if="modo === 'login'" @submit.prevent="iniciarSesion">
        <div class="mb-3">
          <label class="form-label fw-semibold" style="font-size:0.82rem; color:#475569;">Correo electrónico</label>
          <div class="input-group">
            <span class="input-group-text" style="background:rgba(255,255,255,0.6); border-right:none;">
              <IconMail :size="16" class="text-muted" />
            </span>
            <input v-model="form.email" type="email" class="form-control" style="border-left:none;"
              placeholder="correo@ejemplo.com" required autocomplete="email" />
          </div>
        </div>
        <div class="mb-4">
          <label class="form-label fw-semibold" style="font-size:0.82rem; color:#475569;">Contraseña</label>
          <div class="input-group">
            <span class="input-group-text" style="background:rgba(255,255,255,0.6); border-right:none;">
              <IconLock :size="16" class="text-muted" />
            </span>
            <input v-model="form.password" :type="mostrarPassword ? 'text' : 'password'"
              class="form-control" style="border-left:none; border-right:none;"
              placeholder="Tu contraseña" required autocomplete="current-password" />
            <button type="button" class="input-group-text"
              style="background:rgba(255,255,255,0.6); cursor:pointer; border-left:none;"
              @click="mostrarPassword = !mostrarPassword">
              <IconEye v-if="!mostrarPassword" :size="16" class="text-muted" />
              <IconEyeOff v-else :size="16" class="text-muted" />
            </button>
          </div>
        </div>
        <button type="submit" class="btn btn-primary w-100 py-2" :disabled="cargando">
          <span v-if="cargando" class="d-flex align-items-center justify-content-center gap-2">
            <span class="spinner-border spinner-border-sm"></span> Verificando...
          </span>
          <span v-else class="d-flex align-items-center justify-content-center gap-2">
            <IconLogin :size="18" /> Iniciar Sesión
          </span>
        </button>
      </form>

      <!-- Formulario REGISTRO -->
      <form v-else @submit.prevent="registrarse">
        <div class="mb-3">
          <label class="form-label fw-semibold" style="font-size:0.82rem; color:#475569;">Nombre completo</label>
          <div class="input-group">
            <span class="input-group-text" style="background:rgba(255,255,255,0.6); border-right:none;">
              <IconUser :size="16" class="text-muted" />
            </span>
            <input v-model="regForm.nombre" type="text" class="form-control" style="border-left:none;"
              placeholder="Tu nombre completo" required />
          </div>
        </div>
        <div class="mb-3">
          <label class="form-label fw-semibold" style="font-size:0.82rem; color:#475569;">Correo electrónico</label>
          <div class="input-group">
            <span class="input-group-text" style="background:rgba(255,255,255,0.6); border-right:none;">
              <IconMail :size="16" class="text-muted" />
            </span>
            <input v-model="regForm.email" type="email" class="form-control" style="border-left:none;"
              placeholder="correo@ejemplo.com" required />
          </div>
        </div>
        <div class="mb-4">
          <label class="form-label fw-semibold" style="font-size:0.82rem; color:#475569;">Contraseña</label>
          <div class="input-group">
            <span class="input-group-text" style="background:rgba(255,255,255,0.6); border-right:none;">
              <IconLock :size="16" class="text-muted" />
            </span>
            <input v-model="regForm.password" :type="mostrarPassword ? 'text' : 'password'"
              class="form-control" style="border-left:none; border-right:none;"
              placeholder="Mínimo 6 caracteres" required />
            <button type="button" class="input-group-text"
              style="background:rgba(255,255,255,0.6); cursor:pointer; border-left:none;"
              @click="mostrarPassword = !mostrarPassword">
              <IconEye v-if="!mostrarPassword" :size="16" class="text-muted" />
              <IconEyeOff v-else :size="16" class="text-muted" />
            </button>
          </div>
        </div>
        <button type="submit" class="btn btn-primary w-100 py-2" :disabled="cargando">
          <span v-if="cargando" class="d-flex align-items-center justify-content-center gap-2">
            <span class="spinner-border spinner-border-sm"></span> Registrando...
          </span>
          <span v-else class="d-flex align-items-center justify-content-center gap-2">
            <IconUserPlus :size="18" /> Crear Cuenta
          </span>
        </button>
        <p class="text-center text-muted mt-3 mb-0" style="font-size:0.78rem;">
          Tu cuenta iniciará con acceso de <strong>Público</strong>.<br>
          El administrador asignará tu rol.
        </p>
      </form>

    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/store/auth'
import api from '@/services/api'
import {
  IconMail, IconLock, IconLogin, IconEye, IconEyeOff,
  IconAlertCircle, IconCircleCheck, IconUser, IconUserPlus,
} from '@tabler/icons-vue'

const router          = useRouter()
const auth            = useAuthStore()
const cargando        = ref(false)
const error           = ref('')
const exito           = ref('')
const mostrarPassword = ref(false)
const modo            = ref('login')

const form    = ref({ email: '', password: '' })
const regForm = ref({ nombre: '', email: '', password: '' })

function cambiarModo(m) {
  modo.value  = m
  error.value = ''
  exito.value = ''
}

async function iniciarSesion() {
  error.value = ''
  cargando.value = true
  try {
    await auth.login(form.value.email, form.value.password)
    router.push('/')
  } catch (e) {
    error.value = e.response?.data?.error || 'Correo o contraseña incorrectos'
  } finally {
    cargando.value = false
  }
}

async function registrarse() {
  error.value = ''
  exito.value = ''
  if (regForm.value.password.length < 6) {
    error.value = 'La contraseña debe tener al menos 6 caracteres'
    return
  }
  cargando.value = true
  try {
    await api.post('/auth/registro', regForm.value)
    exito.value = '¡Cuenta creada! Ya puedes iniciar sesión.'
    regForm.value = { nombre: '', email: '', password: '' }
    setTimeout(() => cambiarModo('login'), 2000)
  } catch (e) {
    error.value = e.response?.data?.error || 'Error al registrar. Intenta con otro correo.'
  } finally {
    cargando.value = false
  }
}
</script>
