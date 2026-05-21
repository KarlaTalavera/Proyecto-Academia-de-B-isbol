<template>
  <div>
    <div v-if="auth.rol === 'dueno' && !auth.id_equipo" class="alert alert-danger mb-4 shadow-sm" style="border-left: 5px solid #d63939;">
      <h4 class="alert-title d-flex align-items-center gap-2">
        <IconAlertTriangle /> ¡Error en el Inicio de Sesión!
      </h4>
      <div>El sistema sabe que eres Dueño, pero el backend no envió el <strong>id_equipo</strong>. Por seguridad, se ha bloqueado la tabla. <br>
      <strong>Para arreglarlo:</strong> Necesitas modificar tu archivo <code>auth.controller.js</code> en el backend, y luego cerrar sesión y volver a entrar.</div>
    </div>

    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Jugadores</h2>
        <p class="page-subtitle">Plantillas de equipos</p>
      </div>
      <button v-if="auth.puedeEditar && (auth.rol === 'administrador' || auth.id_equipo)" 
              class="btn btn-primary d-flex align-items-center gap-2" @click="abrirFormulario()">
        <IconPlus :size="18" stroke-width="2" /> Nuevo Jugador
      </button>
    </div>

    <div class="card">
      <div class="card-header d-flex align-items-center gap-2 flex-wrap">
        <div class="input-group input-group-sm" style="max-width:260px;">
          <span class="input-group-text" style="background:transparent;">
            <IconSearch :size="14" class="text-muted" />
          </span>
          <input v-model="busqueda" class="form-control" placeholder="Buscar jugador..." style="border-left:none;" />
        </div>
        <select v-if="auth.rol === 'administrador'" v-model="filtroEquipo" class="form-select form-select-sm" style="max-width:200px;">
          <option value="">Todos los equipos</option>
          <option v-for="eq in equipos" :key="eq.id_equipo" :value="eq.id_equipo">{{ eq.nombre_equipo }}</option>
        </select>
        <span class="ms-auto text-muted" style="font-size:0.8rem;">{{ jugadoresFiltrados.length }} jugador(es)</span>
      </div>

      <div class="table-responsive">
        <table class="table table-vcenter card-table">
          <thead>
            <tr>
              <th>Jugador</th>
              <th>Equipo</th>
              <th>Posición</th>
              <th>Rol</th>
              <th>Brazo Dom.</th>
              <th>Estado</th>
              <th v-if="auth.puedeEditar" style="width:140px;" class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando">
              <td colspan="7" class="text-center py-5">
                <span class="spinner-border spinner-border-sm text-primary me-2"></span> Cargando...
              </td>
            </tr>
            <tr v-else-if="!jugadoresFiltrados.length">
              <td colspan="7" class="text-center py-5 text-muted">
                <IconUsers :size="32" stroke-width="1.2" class="mb-2 d-block mx-auto" style="opacity:0.3;" />
                No hay jugadores registrados para mostrar
              </td>
            </tr>
            <tr v-for="j in jugadoresPagina" :key="j.id_jugador">
              <td>
                <div class="d-flex align-items-center gap-2">
                  <div style="position:relative; flex-shrink:0;">
                    <img v-if="j.foto_url" :src="apiBase + j.foto_url" :alt="j.nombre"
                      style="width:36px;height:36px;border-radius:50%;object-fit:cover;border:2px solid #e2e8f0;" />
                    <div v-else class="team-avatar" style="background:linear-gradient(135deg,#6366f1,#8b5cf6);">
                      {{ j.nombre?.charAt(0)?.toUpperCase() }}
                    </div>
                    <label v-if="puedeEditarJugador(j)" :title="j.foto_url ? 'Cambiar foto' : 'Subir foto'"
                      style="position:absolute;bottom:-2px;right:-2px;width:16px;height:16px;background:#6366f1;border-radius:50%;display:flex;align-items:center;justify-content:center;cursor:pointer;border:1.5px solid white;">
                      <IconCamera :size="9" style="color:white;" />
                      <input type="file" accept=".jpg,.jpeg,.png" style="display:none;" @change="subirFoto(j, $event)" />
                    </label>
                  </div>
                  <div>
                    <div class="fw-semibold" style="font-size:0.875rem; color:#1e293b;">{{ j.nombre }} {{ j.apellido }}</div>
                    <div v-if="j.cedula" class="text-muted" style="font-size:0.75rem;">CI: {{ j.cedula }}</div>
                  </div>
                </div>
              </td>
              <td>
                <div class="d-flex align-items-center gap-1">
                  <div class="team-avatar" style="width:22px;height:22px;font-size:0.6rem;border-radius:6px;">{{ j.nombre_equipo?.charAt(0) }}</div>
                  <span class="text-muted" style="font-size:0.82rem;">{{ j.nombre_equipo }}</span>
                </div>
              </td>
              <td class="text-muted" style="font-size:0.82rem;">{{ j.posicion }}</td>
              <td>
                <span class="badge" :class="badgeRol(j.rol)">{{ j.rol }}</span>
              </td>
              <td class="text-muted" style="font-size:0.82rem;">{{ j.brazo_dominante || '—' }}</td>
              <td>
                <span class="badge" :class="j.activo ? 'bg-success-lt text-success' : 'bg-danger-lt text-danger'">
                  {{ j.activo ? 'Activo' : 'Inactivo' }}
                </span>
              </td>
              <td v-if="auth.puedeEditar" class="text-end">
                
                <button v-if="puedeTransferirJugador(j)" 
                        class="btn btn-sm btn-ghost-warning me-1" 
                        title="Transferir a otro equipo" 
                        @click="abrirModalTransferir(j)">
                  <IconArrowsRightLeft :size="15" />
                </button>
                
                <button v-if="puedeEditarJugador(j)" class="btn btn-sm btn-ghost-primary me-1" @click="abrirFormulario(j)"><IconPencil :size="15" /></button>
                <button v-if="puedeEditarJugador(j)" class="btn btn-sm btn-ghost-danger" @click="confirmarEliminar(j)"><IconTrash :size="15" /></button>
              
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-if="totalPaginas > 1" class="d-flex align-items-center justify-content-between mt-3">
      <span class="text-muted" style="font-size:0.8rem;">
        Mostrando {{ (paginaActual - 1) * porPagina + 1 }}–{{ Math.min(paginaActual * porPagina, jugadoresFiltrados.length) }}
        de {{ jugadoresFiltrados.length }} jugadores
      </span>
      <div class="d-flex gap-1">
        <button class="btn btn-sm btn-ghost-secondary" :disabled="paginaActual === 1" @click="paginaActual--">‹ Anterior</button>
        <button
          v-for="n in totalPaginas" :key="n"
          class="btn btn-sm"
          :class="n === paginaActual ? 'btn-primary' : 'btn-ghost-secondary'"
          style="min-width:34px;"
          @click="paginaActual = n"
        >{{ n }}</button>
        <button class="btn btn-sm btn-ghost-secondary" :disabled="paginaActual === totalPaginas" @click="paginaActual++">Siguiente ›</button>
      </div>
    </div>

    <div v-if="modalAbierto" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ editando ? 'Editar Jugador' : 'Nuevo Jugador' }}</h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <form @submit.prevent="guardar">
            <div class="modal-body">
              <div v-if="errorModal" class="alert alert-danger py-2 mb-3">{{ errorModal }}</div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Nombre <span class="text-danger">*</span></label>
                  <input v-model="form.nombre" class="form-control" required />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Apellido <span class="text-danger">*</span></label>
                  <input v-model="form.apellido" class="form-control" required />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3" v-if="mostrarCedula">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Cédula <span class="text-danger">*</span></label>
                  <input v-model="form.cedula" class="form-control" placeholder="V-00000000" />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Fecha de Nacimiento <span class="text-danger">*</span></label>
                  <input v-model="form.fecha_nacimiento" type="date" class="form-control" required />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Equipo <span class="text-danger">*</span></label>
                  <select v-model="form.id_equipo" class="form-select" required :disabled="auth.rol === 'dueno'">
                    <option value="">— Seleccionar —</option>
                    <option v-for="eq in equipos" :key="eq.id_equipo" :value="eq.id_equipo">{{ eq.nombre_equipo }}</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Rol <span class="text-danger">*</span></label>
                  <select v-model="form.rol" class="form-select" required>
                    <option value="bateador">Bateador</option>
                    <option value="pitcher">Pitcher</option>
                    <option value="utilidad">Utilidad</option>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Posición <span class="text-danger">*</span></label>
                  <select v-model="form.posicion" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    <option v-for="p in posiciones" :key="p">{{ p }}</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-semibold" style="font-size:0.82rem;">Brazo Dominante</label>
                  <select v-model="form.brazo_dominante" class="form-select">
                    <option value="">— Seleccionar —</option>
                    <option value="Derecho">Derecho</option>
                    <option value="Zurdo">Zurdo</option>
                    <option value="Ambidiestro">Ambidiestro</option>
                  </select>
                </div>
              </div>
              <div v-if="editando" class="mb-3">
                <label class="form-label fw-semibold" style="font-size:0.82rem;">Estado</label>
                <select v-model="form.activo" class="form-select">
                  <option :value="1">Activo</option>
                  <option :value="0">Inactivo</option>
                </select>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-ghost-secondary" @click="cerrarModal">Cancelar</button>
              <button type="submit" class="btn btn-primary d-flex align-items-center gap-2" :disabled="guardando">
                <span v-if="guardando" class="spinner-border spinner-border-sm"></span>
                <IconDeviceFloppy v-else :size="16" />
                {{ guardando ? 'Guardando...' : 'Guardar' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <div v-if="modalTransferirAbierto" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Transferir Jugador</h5>
            <button type="button" class="btn-close" @click="modalTransferirAbierto = false"></button>
          </div>
          <div class="modal-body">
            <p>Selecciona el equipo al que deseas transferir a <strong>{{ formTransfer.nombre_jugador }}</strong>:</p>
            <select v-model="formTransfer.id_equipo_destino" class="form-select">
              <option value="">— Seleccionar Equipo —</option>
              <option v-for="eq in equipos.filter(e => e.id_equipo != auth.id_equipo)" :key="eq.id_equipo" :value="eq.id_equipo">
                {{ eq.nombre_equipo }}
              </option>
            </select>
          </div>
          <div class="modal-footer">
            <button class="btn btn-ghost-secondary" @click="modalTransferirAbierto = false">Cancelar</button>
            <button class="btn btn-primary" :disabled="!formTransfer.id_equipo_destino" @click="enviarTransferencia">
              Enviar Oferta
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="modalRecepcionAbierto" class="modal modal-blur show d-block" tabindex="-1">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border: 2px solid #f59f00;">
          <div class="modal-header bg-warning-lt">
            <h5 class="modal-title fw-bold text-warning-fg">¡Ofertas de Transferencia Entrantes!</h5>
            <button type="button" class="btn-close" @click="modalRecepcionAbierto = false"></button>
          </div>
          <div class="modal-body bg-light">
            <div v-for="t in transferenciasPendientes" :key="t.id_transferencia" class="card mb-3 shadow-sm">
              <div class="card-body text-center">
                <p class="mb-1 text-muted">El equipo <strong>{{ t.equipo_origen_nombre }}</strong> te está transfiriendo a:</p>
                <h3 class="text-primary mb-3">{{ t.jugador_nombre }} {{ t.jugador_apellido }}</h3>
                <div class="d-flex justify-content-center gap-2">
                  <button class="btn btn-outline-danger" @click="resolver(t, 'rechazada')">Cancelar / Rechazar</button>
                  <button class="btn btn-success" @click="resolver(t, 'aceptada')">Aceptar Jugador</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="modalAbierto || modalTransferirAbierto || modalRecepcionAbierto" class="modal-backdrop show"></div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/store/auth'
import { useToast }   from '@/composables/useToast'
import { useConfirm } from '@/composables/useConfirm'
import { IconPlus, IconSearch, IconPencil, IconTrash, IconUsers, IconDeviceFloppy, IconCamera, IconArrowsRightLeft, IconAlertTriangle } from '@tabler/icons-vue'

const apiBase = import.meta.env.VITE_API_URL?.replace('/api', '') || 'http://localhost:3000'

const toast   = useToast()
const confirm = useConfirm()

const auth     = useAuthStore()
const jugadores  = ref([])
const equipos    = ref([])
const busqueda   = ref('')
const filtroEquipo = ref('')
const cargando   = ref(false)
const modalAbierto = ref(false)
const editando   = ref(false)
const guardando  = ref(false)
const errorModal = ref('')

const modalTransferirAbierto = ref(false)
const formTransfer = ref({ id_jugador: null, nombre_jugador: '', id_equipo_destino: '' })
const modalRecepcionAbierto = ref(false)
const transferenciasPendientes = ref([])

const posiciones = [
  'Lanzador (P)', 'Receptor (C)', 'Primera Base (1B)', 'Segunda Base (2B)',
  'Tercera Base (3B)', 'Shortstop (SS)', 'Jardinero Izquierdo (LF)',
  'Jardinero Central (CF)', 'Jardinero Derecho (RF)', 'Bateador Designado (DH)',
]

const form = ref({ id_equipo: '', cedula: '', nombre: '', apellido: '', fecha_nacimiento: '', rol: 'bateador', posicion: '', brazo_dominante: '', activo: 1 })

const paginaActual = ref(1)
const porPagina    = 10

// ─── LÓGICA REESCRITA: EL DUEÑO SOLO VE SU EQUIPO ─────────────────────────────
const jugadoresFiltrados = computed(() => {
  let lista = jugadores.value;

  // Si es dueño, obligatoriamente filtramos la lista general
  if (auth.rol === 'dueno') {
    if (auth.id_equipo) {
      lista = lista.filter(j => j.id_equipo == auth.id_equipo);
    } else {
      // Si es dueño pero NO tiene equipo en su login, no le mostramos a nadie por seguridad
      lista = [];
    }
  }

  // Luego aplicamos la búsqueda normal de la barra de texto
  return lista.filter(j => {
    const texto = `${j.nombre} ${j.apellido}`.toLowerCase()
    return texto.includes(busqueda.value.toLowerCase()) &&
      (!filtroEquipo.value || j.id_equipo == filtroEquipo.value)
  })
})

const totalPaginas    = computed(() => Math.max(1, Math.ceil(jugadoresFiltrados.value.length / porPagina)))
const jugadoresPagina = computed(() => {
  const inicio = (paginaActual.value - 1) * porPagina
  return jugadoresFiltrados.value.slice(inicio, inicio + porPagina)
})

watch([busqueda, filtroEquipo], () => { paginaActual.value = 1 })

function calcularEdad(fechaNacimiento) {
  if (!fechaNacimiento) return null
  const hoy = new Date()
  const nac = new Date(fechaNacimiento)
  let edad = hoy.getFullYear() - nac.getFullYear()
  const m = hoy.getMonth() - nac.getMonth()
  if (m < 0 || (m === 0 && hoy.getDate() < nac.getDate())) edad--
  return edad
}

const mostrarCedula = computed(() => {
  const edad = calcularEdad(form.value.fecha_nacimiento)
  return edad !== null && edad >= 9
})

function badgeRol(rol) {
  return { bateador: 'bg-blue-lt text-blue', pitcher: 'bg-purple-lt text-purple', utilidad: 'bg-orange-lt text-orange' }[rol] || 'bg-secondary-lt'
}

function puedeEditarJugador(j) {
  if (auth.rol === 'administrador') return true;
  if (auth.rol === 'dueno' && auth.id_equipo == j.id_equipo) return true;
  return false;
}

function puedeTransferirJugador(j) {
  if (auth.rol === 'dueno' && auth.id_equipo == j.id_equipo) return true;
  return false;
}

async function cargar() {
  cargando.value = true
  try {
    const [resJ, resE] = await Promise.all([api.get('/jugadores'), api.get('/equipos')])
    jugadores.value = resJ.data
    equipos.value   = resE.data

    if (auth.rol === 'dueno') {
      const resT = await api.get('/jugadores/transferencias/pendientes')
      if (resT.data && resT.data.length > 0) {
        transferenciasPendientes.value = resT.data
        modalRecepcionAbierto.value = true 
      }
    }
  } finally { cargando.value = false }
}

function abrirFormulario(jugador = null) {
  errorModal.value = ''
  if (jugador) {
    editando.value = true
    form.value = { ...jugador, fecha_nacimiento: jugador.fecha_nacimiento?.substring(0, 10) }
  } else {
    editando.value = false
    const eqPorDefecto = auth.rol === 'dueno' ? auth.id_equipo : '';
    form.value = { id_equipo: eqPorDefecto, cedula: '', nombre: '', apellido: '', fecha_nacimiento: '', rol: 'bateador', posicion: '', brazo_dominante: '', activo: 1 }
  }
  modalAbierto.value = true
}

function cerrarModal() { modalAbierto.value = false }

async function guardar() {
  const nombre = (form.value.nombre || '').trim()
  const apellido = (form.value.apellido || '').trim()
  if (nombre.length < 2) { toast.warn('El nombre debe tener al menos 2 caracteres'); return }
  if (apellido.length < 2) { toast.warn('El apellido debe tener al menos 2 caracteres'); return }
  // Validación de cédula según edad
if (mostrarCedula.value) {
    if (!form.value.cedula) {
      toast.warn('La cédula es obligatoria para jugadores de 9 años o más')
      return
    }
    const cedula = form.value.cedula.toUpperCase()
    if (!/^[VE]-\d{1,8}$/.test(cedula)) {
      toast.warn('La cédula debe tener el formato V-00000000 o E-00000000')
      return
    }
    const num = parseInt(cedula.split('-')[1], 10)
    if (num < 1 || num > 99999999) {
      toast.warn('El número de cédula debe estar entre 1 y 99.999.999')
      return
    }
    form.value.cedula = cedula
  } else {
    // Si es menor de 9 años, aseguramos que la cédula sea null
    form.value.cedula = null
  }
  if (form.value.fecha_nacimiento) {
    const hoy = new Date()
    const nacimiento = new Date(form.value.fecha_nacimiento)
    const edad = (hoy - nacimiento) / (1000 * 60 * 60 * 24 * 365.25)
    if (edad < 10 || edad > 60) { toast.warn('La edad del jugador debe estar entre 10 y 60 años'); return }
  }
  guardando.value = true
  errorModal.value = ''
  try {
    if (editando.value) await api.put(`/jugadores/${form.value.id_jugador}`, form.value)
    else await api.post('/jugadores', form.value)
    cerrarModal()
    cargar()
  } catch (e) {
    errorModal.value = e.response?.data?.error || 'Error al guardar'
  } finally { guardando.value = false }
}

async function subirFoto(jugador, event) {
  const file = event.target.files[0]
  if (!file) return
  const fd = new FormData()
  fd.append('foto', file)
  try {
    const { data } = await api.post(`/jugadores/${jugador.id_jugador}/foto`, fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    jugador.foto_url = data.foto_url
  } catch (e) {
    toast.error(e.response?.data?.error || 'Error al subir la foto')
  }
  event.target.value = ''
}

async function confirmarEliminar(j) {
  const ok = await confirm.pedir(`¿Eliminar a "${j.nombre} ${j.apellido}"?`, { titulo: '¿Estás segura?', variante: 'danger' })
  if (!ok) return
  await api.delete(`/jugadores/${j.id_jugador}`)
  cargar()
}

function abrirModalTransferir(j) {
  formTransfer.value = {
    id_jugador: j.id_jugador,
    nombre_jugador: `${j.nombre} ${j.apellido}`,
    id_equipo_destino: ''
  }
  modalTransferirAbierto.value = true
}

async function enviarTransferencia() {
  try {
    await api.post(`/jugadores/${formTransfer.value.id_jugador}/transferir`, {
      id_equipo_destino: formTransfer.value.id_equipo_destino
    })
    toast.success('Oferta de transferencia enviada al otro equipo')
    modalTransferirAbierto.value = false
  } catch (e) {
    toast.error(e.response?.data?.error || 'Error al transferir')
  }
}

async function resolver(t, estado) {
  try {
    await api.post('/jugadores/transferencias/resolver', {
      id_transferencia: t.id_transferencia,
      id_jugador: t.id_jugador,
      estado: estado
    })
    
    if(estado === 'aceptada') toast.success(`¡Has fichado a ${t.jugador_nombre}!`)
    else toast.info('Transferencia rechazada')
    
    transferenciasPendientes.value = transferenciasPendientes.value.filter(item => item.id_transferencia !== t.id_transferencia)
    
    if (transferenciasPendientes.value.length === 0) {
      modalRecepcionAbierto.value = false
    }
    cargar() 
  } catch (e) {
    toast.error('Ocurrió un error al procesar la respuesta')
  }
}

onMounted(cargar)
</script>

<style scoped>
.team-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
  font-size: 0.9rem;
}
</style>