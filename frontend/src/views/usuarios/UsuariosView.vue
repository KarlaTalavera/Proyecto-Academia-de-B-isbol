<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Gestión de Usuarios</h2>
        <p class="page-subtitle">Control de acceso y roles del sistema</p>
      </div>
      <button class="btn btn-primary d-flex align-items-center gap-2" @click="abrirCrear">
        <IconUserPlus :size="18" stroke-width="2" /> Nuevo Usuario
      </button>
    </div>

    <!-- Leyenda de roles -->
    <div class="row g-2 mb-4">
      <div v-for="r in rolesInfo" :key="r.rol" class="col-sm-6 col-xl">
        <div class="card py-2 px-3">
          <div class="d-flex align-items-center gap-2">
            <span class="badge" :style="r.style">{{ r.etiqueta }}</span>
            <span class="text-muted" style="font-size:0.75rem;">{{ r.desc }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla usuarios -->
    <div class="card">
      <div class="card-header d-flex align-items-center gap-2">
        <div class="input-group input-group-sm" style="max-width:260px;">
          <span class="input-group-text" style="background:transparent;">
            <IconSearch :size="14" class="text-muted" />
          </span>
          <input v-model="busqueda" class="form-control" placeholder="Buscar usuario..." style="border-left:none;" />
        </div>
        <span class="ms-auto text-muted" style="font-size:0.8rem;">{{ usuariosFiltrados.length }} usuario(s)</span>
      </div>
      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>Usuario</th>
              <th>Correo</th>
              <th>Rol actual</th>
              <th>Estado</th>
              <th>Registro</th>
              <th style="width:220px;">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando">
              <td colspan="6" class="text-center py-5">
                <span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...
              </td>
            </tr>
            <tr v-else-if="!usuariosFiltrados.length">
              <td colspan="6" class="text-center py-5 text-muted">No hay usuarios</td>
            </tr>
            <tr v-for="u in usuariosFiltrados" :key="u.id_usuario">
              <td>
                <div class="d-flex align-items-center gap-2">
                  <div class="user-avatar" style="width:32px;height:32px;font-size:0.8rem;">
                    {{ u.nombre?.charAt(0)?.toUpperCase() }}
                  </div>
                  <span class="fw-semibold" style="font-size:0.875rem; color:#1e293b;">{{ u.nombre }}</span>
                </div>
              </td>
              <td class="text-muted" style="font-size:0.82rem;">{{ u.email }}</td>
              <td>
                <select
                  class="form-select form-select-sm"
                  style="min-width:130px; font-size:0.8rem;"
                  :value="u.rol"
                  :disabled="u.id_usuario === miId"
                  @change="cambiarRol(u, $event.target.value)"
                >
                  <option v-for="r in rolesDisponibles" :key="r.value" :value="r.value">{{ r.label }}</option>
                </select>
              </td>
              <td>
                <span class="badge" :class="u.activo ? 'bg-success-lt text-success' : 'bg-danger-lt text-danger'">
                  {{ u.activo ? 'Activo' : 'Inactivo' }}
                </span>
              </td>
              <td class="text-muted" style="font-size:0.78rem;">{{ formatFecha(u.created_at) }}</td>
              <td>
                <div class="d-flex gap-1 flex-wrap">
                  <button
                    class="btn btn-sm btn-ghost-secondary"
                    style="font-size:0.75rem; padding:3px 8px;"
                    :disabled="u.id_usuario === miId"
                    @click="toggleActivo(u)"
                    :title="u.activo ? 'Desactivar' : 'Activar'"
                  >
                    <IconToggleLeft v-if="u.activo" :size="14" /> <IconToggleRight v-else :size="14" />
                    {{ u.activo ? 'Desactivar' : 'Activar' }}
                  </button>
                  <button
                    class="btn btn-sm btn-ghost-primary"
                    style="font-size:0.75rem; padding:3px 8px;"
                    @click="abrirResetPassword(u)"
                    title="Restablecer contraseña"
                  >
                    <IconKey :size="14" /> Clave
                  </button>
                  <button
                    class="btn btn-sm btn-ghost-danger"
                    style="font-size:0.75rem; padding:3px 8px;"
                    :disabled="u.id_usuario === miId"
                    @click="confirmarEliminar(u)"
                    title="Eliminar usuario"
                  >
                    <IconTrash :size="14" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal crear usuario -->
    <div v-if="modalCrear" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-md modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Nuevo Usuario</h5>
            <button type="button" class="btn-close" @click="modalCrear = false"></button>
          </div>
          <form @submit.prevent="crearUsuario">
            <div class="modal-body">
              <div v-if="errorCrear" class="alert alert-danger py-2 mb-3">{{ errorCrear }}</div>
              <div class="mb-3">
                <label class="form-label required">Nombre completo</label>
                <input v-model="crearForm.nombre" class="form-control" placeholder="Nombre del usuario" required />
              </div>
              <div class="mb-3">
                <label class="form-label required">Correo electrónico</label>
                <input v-model="crearForm.email" type="email" class="form-control" placeholder="correo@ejemplo.com" required />
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label required">Contraseña</label>
                  <input v-model="crearForm.password" type="password" class="form-control" placeholder="Mínimo 6 caracteres" required />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label required">Rol</label>
                  <select v-model="crearForm.rol" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option v-for="r in rolesDisponibles" :key="r.value" :value="r.value">{{ r.label }}</option>
                  </select>
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-ghost-secondary me-auto" @click="modalCrear = false">Cancelar</button>
              <button type="submit" class="btn btn-primary" :disabled="guardando">
                {{ guardando ? 'Creando...' : 'Crear Usuario' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="modalCrear" class="modal-backdrop show"></div>

    <!-- Modal reset password -->
    <div v-if="modalPassword" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Restablecer Contraseña</h5>
            <button type="button" class="btn-close" @click="modalPassword = false"></button>
          </div>
          <form @submit.prevent="resetPassword">
            <div class="modal-body">
              <p class="text-muted mb-3" style="font-size:0.82rem;">
                Nueva contraseña para <strong>{{ usuarioSeleccionado?.nombre }}</strong>
              </p>
              <div v-if="errorModal" class="alert alert-danger py-2 mb-3">{{ errorModal }}</div>
              <input
                v-model="nuevaPassword"
                type="password"
                class="form-control"
                placeholder="Mínimo 6 caracteres"
                required
              />
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-ghost-secondary" @click="modalPassword = false">Cancelar</button>
              <button type="submit" class="btn btn-primary" :disabled="guardando">
                <span v-if="guardando" class="spinner-border spinner-border-sm me-1"></span>
                Guardar
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="modalPassword" class="modal-backdrop show"></div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'
import { IconSearch, IconTrash, IconToggleLeft, IconToggleRight, IconKey, IconUserPlus } from '@tabler/icons-vue'

const auth    = useAuthStore()
const miId    = computed(() => {
  // Decodifica el id del token JWT (sin verificar)
  try {
    return JSON.parse(atob(auth.token.split('.')[1])).id
  } catch { return null }
})

const usuarios    = ref([])
const busqueda    = ref('')
const cargando    = ref(false)
const guardando   = ref(false)
const modalPassword = ref(false)
const errorModal  = ref('')
const nuevaPassword = ref('')
const usuarioSeleccionado = ref(null)

const modalCrear  = ref(false)
const errorCrear  = ref('')
const crearForm   = ref({ nombre: '', email: '', password: '', rol: '' })

function abrirCrear() {
  crearForm.value = { nombre: '', email: '', password: '', rol: '' }
  errorCrear.value = ''
  modalCrear.value = true
}

async function crearUsuario() {
  errorCrear.value = ''
  if ((crearForm.value.nombre || '').trim().length < 3) {
    errorCrear.value = 'El nombre debe tener al menos 3 caracteres'
    return
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(crearForm.value.email || '')) {
    errorCrear.value = 'El formato del correo electrónico no es válido'
    return
  }
  if (crearForm.value.password.length < 6) {
    errorCrear.value = 'La contraseña debe tener al menos 6 caracteres'
    return
  }
  guardando.value = true
  try {
    await api.post('/usuarios', crearForm.value)
    modalCrear.value = false
    await cargar()
  } catch (e) {
    errorCrear.value = e.response?.data?.error || 'Error al crear usuario'
  } finally {
    guardando.value = false
  }
}

const rolesDisponibles = [
  { value: 'administrador', label: 'Administrador' },
  { value: 'dueno',         label: 'Dueño' },
  { value: 'caja',          label: 'Caja' },
  { value: 'anotador',      label: 'Anotador' },
]

const rolesInfo = [
  { rol: 'administrador', etiqueta: 'Administrador', desc: 'Acceso total al sistema', style: 'background:rgba(59,130,246,0.15);color:#3b82f6;' },
  { rol: 'dueno',         etiqueta: 'Dueño',         desc: 'Equipos, jugadores y partidos', style: 'background:rgba(249,115,22,0.15);color:#f97316;' },
  { rol: 'caja',          etiqueta: 'Caja',           desc: 'Gestión de ingresos y egresos', style: 'background:rgba(34,197,94,0.15);color:#16a34a;' },
  { rol: 'anotador',      etiqueta: 'Anotador',       desc: 'Lineup, resultados y estadísticas', style: 'background:rgba(99,102,241,0.15);color:#6366f1;' },
]

const usuariosFiltrados = computed(() =>
  usuarios.value.filter(u =>
    u.nombre.toLowerCase().includes(busqueda.value.toLowerCase()) ||
    u.email.toLowerCase().includes(busqueda.value.toLowerCase())
  )
)

function formatFecha(f) {
  if (!f) return '—'
  return new Date(f).toLocaleDateString('es-VE')
}

async function cargar() {
  cargando.value = true
  try {
    const { data } = await api.get('/usuarios')
    usuarios.value = data
  } finally {
    cargando.value = false
  }
}

async function cambiarRol(usuario, rol) {
  try {
    await api.patch(`/usuarios/${usuario.id_usuario}/rol`, { rol })
    usuario.rol = rol
  } catch (e) {
    alert(e.response?.data?.error || 'Error al cambiar rol')
    await cargar()
  }
}

async function toggleActivo(usuario) {
  try {
    const { data } = await api.patch(`/usuarios/${usuario.id_usuario}/activo`)
    usuario.activo = data.activo ? 1 : 0
  } catch (e) {
    alert(e.response?.data?.error || 'Error')
  }
}

function abrirResetPassword(usuario) {
  usuarioSeleccionado.value = usuario
  nuevaPassword.value = ''
  errorModal.value = ''
  modalPassword.value = true
}

async function resetPassword() {
  errorModal.value = ''
  if (nuevaPassword.value.length < 6) {
    errorModal.value = 'La contraseña debe tener al menos 6 caracteres'
    return
  }
  guardando.value = true
  try {
    await api.patch(`/usuarios/${usuarioSeleccionado.value.id_usuario}/password`, { password: nuevaPassword.value })
    modalPassword.value = false
  } catch (e) {
    errorModal.value = e.response?.data?.error || 'Error al cambiar contraseña'
  } finally {
    guardando.value = false
  }
}

async function confirmarEliminar(usuario) {
  if (!confirm(`¿Eliminar al usuario "${usuario.nombre}"? Esta acción no se puede deshacer.`)) return
  try {
    await api.delete(`/usuarios/${usuario.id_usuario}`)
    await cargar()
  } catch (e) {
    alert(e.response?.data?.error || 'Error al eliminar')
  }
}

onMounted(cargar)
</script>
