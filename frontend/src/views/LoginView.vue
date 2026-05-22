<template>
  <div class="login-bg">
    <div class="login-dots"></div>

    <div class="login-ball">
      <div class="login-stitch login-stitch--top"></div>
      <div class="login-stitch login-stitch--bottom"></div>

      <div class="login-inner">

        <div class="login-heading">
          <h1 class="login-title">LIGA<br><span class="login-title-ghost">DIAMANTE</span></h1>
          <p class="login-subtitle">PANEL DE ADMINISTRACIÓN</p>
        </div>

        <div class="login-tabs">
          <button :class="['login-tab', { 'login-tab--active': modo === 'login' }]" @click="cambiarModo('login')">
            INGRESAR
          </button>
          <button :class="['login-tab', { 'login-tab--active': modo === 'registro' }]" @click="cambiarModo('registro')">
            REGISTRARSE
          </button>
        </div>

        <div v-if="error" class="login-alert login-alert--error">{{ error }}</div>
        <div v-if="exito" class="login-alert login-alert--success">{{ exito }}</div>

        <form v-if="modo === 'login'" @submit.prevent="iniciarSesion" class="login-form">
          <div class="login-field">
            <div class="login-field-icon">
              <IconMail :size="18" stroke-width="1.8" />
            </div>
            <input v-model="form.email" type="email" placeholder="CORREO" class="login-input" required autocomplete="email" />
          </div>
          <div class="login-field">
            <div class="login-field-icon">
              <IconLock :size="18" stroke-width="1.8" />
            </div>
            <input v-model="form.password" :type="mostrarPassword ? 'text' : 'password'" placeholder="CONTRASEÑA" class="login-input" required autocomplete="current-password" />
            <button type="button" class="login-eye" @click="mostrarPassword = !mostrarPassword" aria-label="Mostrar/Ocultar contraseña">
              <IconEyeOff v-if="mostrarPassword" :size="18" stroke-width="1.8" />
              <IconEye v-else :size="18" stroke-width="1.8" />
            </button>
          </div>
          <button type="submit" class="login-submit" :disabled="cargando">
            {{ cargando ? 'VERIFICANDO...' : 'ENTRAR AL CAMPO' }}
          </button>
        </form>

        <form v-else @submit.prevent="registrarse" class="login-form">
          <div class="login-field">
            <div class="login-field-icon">
              <IconUser :size="18" stroke-width="1.8" />
            </div>
            <input v-model="regForm.nombre" type="text" placeholder="NOMBRE COMPLETO" class="login-input" required />
          </div>
          <div class="login-field">
            <div class="login-field-icon">
              <IconMail :size="18" stroke-width="1.8" />
            </div>
            <input v-model="regForm.email" type="email" placeholder="CORREO" class="login-input" required />
          </div>
          <div class="login-field">
            <div class="login-field-icon">
              <IconLock :size="18" stroke-width="1.8" />
            </div>
            <input v-model="regForm.password" :type="mostrarPassword ? 'text' : 'password'" placeholder="CONTRASEÑA" class="login-input" required />
            <button type="button" class="login-eye" @click="mostrarPassword = !mostrarPassword" aria-label="Mostrar/Ocultar contraseña">
              <IconEyeOff v-if="mostrarPassword" :size="18" stroke-width="1.8" />
              <IconEye v-else :size="18" stroke-width="1.8" />
            </button>
          </div>
          <button type="submit" class="login-submit" :disabled="cargando">
            {{ cargando ? 'REGISTRANDO...' : 'CREAR CUENTA' }}
          </button>
          <p class="login-note">Tu cuenta iniciará con acceso de fanático.</p>
        </form>

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

import { IconMail, IconLock, IconUser, IconEye, IconEyeOff } from '@tabler/icons-vue'

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
    router.push({ name: 'Ingresos' }) // o 'Egresos
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
  background: #1B2431;
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
  background-image: radial-gradient(#87B0D4 1px, transparent 1px);
  background-size: 30px 30px;
  pointer-events: none;
}

.login-ball {
  position: relative;
  width: 100%;
  max-width: 480px;
  aspect-ratio: 1;
  border-radius: 50%;
  background: rgba(59, 66, 105, 0.45);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 2px solid rgba(200, 116, 196, 0.2);
  box-shadow: 0 0 80px rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.login-stitch {
  position: absolute;
  border-radius: 50%;
  border: 5px dashed rgba(135, 176, 212, 0.2);
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
  color: rgba(135, 176, 212, 0.15); 
  font-size: 40px;
}

.login-subtitle {
  color: #C874C4; 
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 4px;
  text-transform: uppercase;
  margin: 10px 0 0;
  opacity: 0.85;
}

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
  color: rgba(228, 227, 241, 0.6); 
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
  background: #C874C4; 
  color: #1B2431; 
}

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
  left: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.5;
  pointer-events: none;
  z-index: 1;
  color: #E4E3F1; 
}

.login-input {
  width: 100%;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(135, 176, 212, 0.15); 
  border-radius: 999px;
  padding: 12px 40px 12px 42px;
  color: white;
  /* Fuente genérica limpia para que los puntos de contraseña no se vean raros */
  font-family: Arial, Helvetica, sans-serif;
  font-size: 13px;
  font-weight: 600;
  outline: none;
  transition: border-color 0.2s, background 0.2s;
}

/* Solo el texto gris de fondo tendrá mayúsculas y espacio */
.login-input::placeholder {
  color: rgba(228, 227, 241, 0.4); 
  font-family: 'Arial Black', Arial, sans-serif;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
}

.login-input:focus {
  border-color: #C874C4; 
  background: rgba(255, 255, 255, 0.08);
}


.login-input:-webkit-autofill,
.login-input:-webkit-autofill:hover, 
.login-input:-webkit-autofill:focus, 
.login-input:-webkit-autofill:active {
    -webkit-box-shadow: 0 0 0 30px #212c3d inset !important;
    -webkit-text-fill-color: white !important;
    transition: background-color 5000s ease-in-out 0s;
    border-radius: 999px;
}

.login-eye {
  position: absolute;
  right: 14px;
  background: none;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.5;
  padding: 0;
  transition: opacity 0.2s;
  color: #E4E3F1;
}
.login-eye:hover { opacity: 1; }

.login-submit {
  width: 100%;
  background: #C874C4; 
  color: #1B2431; 
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
  box-shadow: 0 4px 20px rgba(200, 116, 196, 0.2);
}
.login-submit:hover:not(:disabled) {
  background: #d98ad5; 
  transform: scale(1.02);
}
.login-submit:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.login-note {
  text-align: center;
  color: rgba(228, 227, 241, 0.4);
  font-size: 9px;
  font-weight: 600;
  letter-spacing: 1px;
  margin: 4px 0 0;
}

.login-back {
  display: block;
  margin-top: 16px;
  color: rgba(228, 227, 241, 0.4);
  text-decoration: none;
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 2px;
  text-transform: uppercase;
  text-align: center;
  transition: color 0.2s;
}
.login-back:hover { color: #C874C4; } 

@media (max-width: 480px) {
  .login-ball {
    aspect-ratio: auto;
    border-radius: 24px;
    padding: 40px 20px;
  }
  .login-stitch { display: none; }
}
</style>