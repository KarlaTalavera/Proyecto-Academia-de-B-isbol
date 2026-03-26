<template>
  <div class="login-bg">
    <!-- Dot pattern -->
    <div class="login-dots"></div>

    <!-- Baseball circle card -->
    <div class="login-ball">
      <!-- Decorative stitches -->
      <div class="login-stitch login-stitch--top"></div>
      <div class="login-stitch login-stitch--bottom"></div>

      <div class="login-inner">

        <!-- Header -->
        <div class="login-heading">
          <h1 class="login-title">LIGA<br><span class="login-title-ghost">DIAMANTE</span></h1>
          <p class="login-subtitle">PANEL DE ADMINISTRACIÓN</p>
        </div>

        <!-- Tabs -->
        <div class="login-tabs">
          <button :class="['login-tab', { 'login-tab--active': modo === 'login' }]" @click="cambiarModo('login')">
            INGRESAR
          </button>
          <button :class="['login-tab', { 'login-tab--active': modo === 'registro' }]" @click="cambiarModo('registro')">
            REGISTRARSE
          </button>
        </div>

        <!-- Alerts -->
        <div v-if="error" class="login-alert login-alert--error">{{ error }}</div>
        <div v-if="exito" class="login-alert login-alert--success">{{ exito }}</div>

        <!-- LOGIN -->
        <form v-if="modo === 'login'" @submit.prevent="iniciarSesion" class="login-form">
          <div class="login-field">
            <span class="login-field-icon">✉</span>
            <input v-model="form.email" type="email" placeholder="CORREO" class="login-input" required autocomplete="email" />
          </div>
          <div class="login-field">
            <span class="login-field-icon">🔒</span>
            <input v-model="form.password" :type="mostrarPassword ? 'text' : 'password'" placeholder="CONTRASEÑA" class="login-input" required autocomplete="current-password" />
            <button type="button" class="login-eye" @click="mostrarPassword = !mostrarPassword">
              {{ mostrarPassword ? '🙈' : '👁' }}
            </button>
          </div>
          <button type="submit" class="login-submit" :disabled="cargando">
            {{ cargando ? 'VERIFICANDO...' : 'ENTRAR AL CAMPO' }}
          </button>
        </form>

        <!-- REGISTRO -->
        <form v-else @submit.prevent="registrarse" class="login-form">
          <div class="login-field">
            <span class="login-field-icon">👤</span>
            <input v-model="regForm.nombre" type="text" placeholder="NOMBRE COMPLETO" class="login-input" required />
          </div>
          <div class="login-field">
            <span class="login-field-icon">✉</span>
            <input v-model="regForm.email" type="email" placeholder="CORREO" class="login-input" required />
          </div>
          <div class="login-field">
            <span class="login-field-icon">🔒</span>
            <input v-model="regForm.password" :type="mostrarPassword ? 'text' : 'password'" placeholder="CONTRASEÑA" class="login-input" required />
            <button type="button" class="login-eye" @click="mostrarPassword = !mostrarPassword">
              {{ mostrarPassword ? '🙈' : '👁' }}
            </button>
          </div>
          <button type="submit" class="login-submit" :disabled="cargando">
            {{ cargando ? 'REGISTRANDO...' : 'CREAR CUENTA' }}
          </button>
          <p class="login-note">Tu cuenta iniciará con acceso de fanático.</p>
        </form>

        <!-- Back link -->
        <RouterLink to="/" class="login-back">← Volver al Inicio</RouterLink>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { useAuthStore } from '@/store/auth'
import api from '@/services/api'

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
    if (auth.rol === 'publico') {
      router.push({ name: 'FanInicio' })
    } else if (auth.rol === 'caja') {
    router.push({ name: 'Ingresos' }) 
  } else {
    router.push({ name: 'Dashboard' })
  }
  } catch (e) {
    error.value = e.response?.data?.error || 'Correo o contraseña incorrectos'
  } finally {
    cargando.value = false
  }
}

async function registrarse() {
  error.value = ''
  exito.value = ''
  if ((regForm.value.nombre || '').trim().length < 2) {
    error.value = 'El nombre debe tener al menos 2 caracteres'
    return
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(regForm.value.email || '')) {
    error.value = 'El formato del correo electrónico no es válido'
    return
  }
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

<style scoped>
.login-bg {
  min-height: 100vh;
  background: #1a0d0a;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  position: relative;
  overflow: hidden;
  font-family: 'Arial Black', Arial, sans-serif;
}

.login-dots {
  position: absolute;
  inset: 0;
  opacity: 0.15;
  background-image: radial-gradient(#D4AF37 1px, transparent 1px);
  background-size: 30px 30px;
  pointer-events: none;
}

/* Baseball circle */
.login-ball {
  position: relative;
  width: 100%;
  max-width: 480px;
  aspect-ratio: 1;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.45);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 2px solid rgba(212, 175, 55, 0.2);
  box-shadow: 0 0 80px rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

/* Stitches decoration */
.login-stitch {
  position: absolute;
  border-radius: 50%;
  border: 5px dashed rgba(140, 9, 2, 0.12);
  pointer-events: none;
}
.login-stitch--top {
  width: 110%; height: 110%;
  top: -30%; left: -30%;
}
.login-stitch--bottom {
  width: 110%; height: 110%;
  bottom: -30%; right: -30%;
}

.login-inner {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 300px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0;
  padding: 0 16px;
}

/* Heading */
.login-heading {
  text-align: center;
  margin-bottom: 20px;
}

.login-title {
  color: white;
  font-size: 32px;
  font-weight: 900;
  font-style: italic;
  text-transform: uppercase;
  letter-spacing: -1px;
  line-height: 1;
  margin: 0;
  padding: 0;
}

.login-title-ghost {
  color: rgba(255, 255, 255, 0.08);
  font-size: 40px;
}

.login-subtitle {
  color: #D4AF37;
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 4px;
  text-transform: uppercase;
  margin: 10px 0 0;
  opacity: 0.85;
}

/* Tabs */
.login-tabs {
  display: flex;
  gap: 4px;
  background: rgba(255, 255, 255, 0.06);
  border-radius: 999px;
  padding: 4px;
  margin-bottom: 16px;
  width: 100%;
}

.login-tab {
  flex: 1;
  background: none;
  border: none;
  color: rgba(255, 255, 255, 0.4);
  font-size: 9px;
  font-weight: 900;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  padding: 8px;
  border-radius: 999px;
  cursor: pointer;
  transition: all 0.2s;
}

.login-tab--active {
  background: #D4AF37;
  color: #1a0d0a;
}

/* Alerts */
.login-alert {
  width: 100%;
  padding: 8px 12px;
  border-radius: 8px;
  font-size: 11px;
  font-weight: 600;
  margin-bottom: 10px;
  text-align: center;
}
.login-alert--error {
  background: rgba(220, 38, 38, 0.2);
  border: 1px solid rgba(220, 38, 38, 0.4);
  color: #fca5a5;
}
.login-alert--success {
  background: rgba(34, 197, 94, 0.15);
  border: 1px solid rgba(34, 197, 94, 0.3);
  color: #86efac;
}

/* Form */
.login-form {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.login-field {
  position: relative;
  display: flex;
  align-items: center;
}

.login-field-icon {
  position: absolute;
  left: 14px;
  font-size: 13px;
  opacity: 0.5;
  pointer-events: none;
  z-index: 1;
}

.login-input {
  width: 100%;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 999px;
  padding: 12px 40px 12px 38px;
  color: white;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  outline: none;
  transition: border-color 0.2s, background 0.2s;
}

.login-input::placeholder {
  color: rgba(255, 255, 255, 0.2);
  font-weight: 700;
}

.login-input:focus {
  border-color: #D4AF37;
  background: rgba(255, 255, 255, 0.08);
}

.login-eye {
  position: absolute;
  right: 14px;
  background: none;
  border: none;
  cursor: pointer;
  font-size: 14px;
  opacity: 0.5;
  padding: 0;
  transition: opacity 0.2s;
}
.login-eye:hover { opacity: 1; }

.login-submit {
  width: 100%;
  background: #D4AF37;
  color: #1a0d0a;
  border: none;
  border-radius: 999px;
  padding: 14px;
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 3px;
  text-transform: uppercase;
  cursor: pointer;
  margin-top: 6px;
  transition: background 0.3s, transform 0.15s;
  box-shadow: 0 4px 20px rgba(212, 175, 55, 0.2);
}
.login-submit:hover:not(:disabled) {
  background: #FECE79;
  transform: scale(1.02);
}
.login-submit:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.login-note {
  text-align: center;
  color: rgba(255, 255, 255, 0.3);
  font-size: 9px;
  font-weight: 600;
  letter-spacing: 1px;
  margin: 4px 0 0;
}

.login-back {
  display: block;
  margin-top: 16px;
  color: rgba(255, 255, 255, 0.25);
  text-decoration: none;
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  text-align: center;
  transition: color 0.2s;
}
.login-back:hover { color: #D4AF37; }

@media (max-width: 480px) {
  .login-ball {
    aspect-ratio: auto;
    border-radius: 24px;
    padding: 40px 20px;
  }
  .login-stitch { display: none; }
}
</style>
