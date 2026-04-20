<template>
  <div>
    <div class="page-header d-flex align-items-center justify-content-between mb-4">
      <div>
        <h2 class="page-title">Noticias</h2>
        <p class="page-subtitle">Gestión de noticias de la página pública</p>
      </div>
      <button class="btn btn-primary d-flex align-items-center gap-2" @click="abrirNueva">
        <IconPlus :size="18" stroke-width="2" />
        Nueva Noticia
      </button>
    </div>

    <!-- Grid de cards -->
    <div v-if="cargando" class="text-center py-5 text-muted">Cargando noticias...</div>

    <div v-else-if="!noticias.length" class="text-center py-5 text-muted">
      No hay noticias registradas.
    </div>

    <div v-else class="row g-3">
      <div v-for="n in noticias" :key="n.id_noticia" class="col-12 col-md-6 col-xl-4">
        <div class="card h-100" :class="{ 'opacity-50': !n.activa }">
          <!-- Foto -->
          <div class="nc-foto-wrap">
            <img v-if="n.foto_url" :src="apiBase + n.foto_url" class="nc-foto" :alt="n.titulo" />
            <div v-else class="nc-foto-placeholder">
              <IconPhoto :size="36" stroke-width="1.2" class="text-muted" />
            </div>
            <span :class="['nc-badge', n.activa ? 'nc-badge--activa' : 'nc-badge--inactiva']">
              {{ n.activa ? 'Publicada' : 'Oculta' }}
            </span>
          </div>

          <div class="card-body d-flex flex-column gap-2">
            <p class="nc-fecha text-muted mb-0">{{ formatFecha(n.fecha_publicacion) }}</p>
            <h5 class="nc-titulo mb-0">{{ n.titulo }}</h5>
            <p class="nc-contenido text-muted mb-0">{{ n.contenido }}</p>

            <div class="d-flex gap-2 mt-auto pt-2">
              <!-- Cambiar foto -->
              <label class="btn btn-sm btn-ghost-secondary" title="Cambiar foto">
                <IconCamera :size="15" />
                <input type="file" accept=".jpg,.jpeg,.png" style="display:none" @change="cambiarFoto(n, $event)" />
              </label>
              <button class="btn btn-sm btn-ghost-primary" @click="abrirEditar(n)">
                <IconEdit :size="15" /> Editar
              </button>
              <button class="btn btn-sm" :class="n.activa ? 'btn-ghost-warning' : 'btn-ghost-success'"
                @click="toggleActiva(n)">
                {{ n.activa ? 'Ocultar' : 'Publicar' }}
              </button>
              <button class="btn btn-sm btn-ghost-danger ms-auto" @click="eliminar(n)">
                <IconTrash :size="15" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal crear / editar -->
    <div v-if="modalAbierto" class="modal-overlay" @click.self="cerrarModal">
      <div class="modal-box">
        <div class="modal-box__header">
          <h5 class="mb-0">{{ editando ? 'Editar Noticia' : 'Nueva Noticia' }}</h5>
          <button class="btn-close" @click="cerrarModal" />
        </div>

        <div class="modal-box__body d-flex flex-column gap-3">
          <div>
            <label class="form-label">Título <span class="text-danger">*</span></label>
            <input v-model="form.titulo" class="form-control" placeholder="Título de la noticia" />
          </div>

          <div>
            <label class="form-label">Contenido / Resumen</label>
            <textarea v-model="form.contenido" class="form-control" rows="4"
              placeholder="Descripción o resumen de la noticia..." />
          </div>

          <div>
            <label class="form-label">Fecha de publicación</label>
            <input v-model="form.fecha_publicacion" type="date" class="form-control" />
          </div>

          <div v-if="!editando">
            <label class="form-label">Foto</label>
            <input type="file" accept=".jpg,.jpeg,.png" class="form-control" @change="onFotoNueva" />
            <div v-if="previewFoto" class="mt-2">
              <img :src="previewFoto" style="max-height:140px;border-radius:8px;object-fit:cover;" />
            </div>
          </div>

          <div class="form-check">
            <input v-model="form.activa" class="form-check-input" type="checkbox" id="chkActiva" />
            <label class="form-check-label" for="chkActiva">Publicada (visible en la página)</label>
          </div>
        </div>

        <div class="modal-box__footer d-flex justify-content-end gap-2">
          <button class="btn btn-ghost-secondary" @click="cerrarModal">Cancelar</button>
          <button class="btn btn-primary" :disabled="guardando" @click="guardar">
            {{ guardando ? 'Guardando...' : 'Guardar' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import {
  IconPlus, IconEdit, IconTrash, IconCamera, IconPhoto,
} from '@tabler/icons-vue'

const apiBase = import.meta.env.VITE_API_URL?.replace('/api', '') || 'http://localhost:3000'

const noticias    = ref([])
const cargando    = ref(true)
const modalAbierto = ref(false)
const editando    = ref(null)   // null = nueva, objeto = editar
const guardando   = ref(false)
const previewFoto = ref(null)
const fotoArchivo = ref(null)

const form = ref({ titulo: '', contenido: '', fecha_publicacion: '', activa: true })

async function cargar() {
  cargando.value = true
  try {
    const { data } = await api.get('/noticias')
    noticias.value = data
  } finally {
    cargando.value = false
  }
}

function abrirNueva() {
  editando.value    = null
  previewFoto.value = null
  fotoArchivo.value = null
  form.value = { titulo: '', contenido: '', fecha_publicacion: '', activa: true }
  modalAbierto.value = true
}

function abrirEditar(n) {
  editando.value = n
  form.value = {
    titulo:             n.titulo,
    contenido:          n.contenido || '',
    fecha_publicacion:  n.fecha_publicacion?.slice(0, 10) || '',
    activa:             !!n.activa,
  }
  modalAbierto.value = true
}

function cerrarModal() {
  modalAbierto.value = false
  editando.value = null
  previewFoto.value = null
  fotoArchivo.value = null
}

function onFotoNueva(e) {
  const file = e.target.files[0]
  if (!file) return
  fotoArchivo.value = file
  previewFoto.value = URL.createObjectURL(file)
}

async function guardar() {
  if (!form.value.titulo.trim()) { alert('El título es obligatorio'); return }
  guardando.value = true
  try {
    if (editando.value) {
      // Actualizar texto
      await api.put(`/noticias/${editando.value.id_noticia}`, {
        titulo:            form.value.titulo,
        contenido:         form.value.contenido,
        fecha_publicacion: form.value.fecha_publicacion || null,
        activa:            form.value.activa ? 1 : 0,
      })
    } else {
      // Crear con FormData (incluye foto opcional)
      const fd = new FormData()
      fd.append('titulo',            form.value.titulo)
      fd.append('contenido',         form.value.contenido)
      fd.append('fecha_publicacion', form.value.fecha_publicacion || '')
      fd.append('activa',            form.value.activa ? '1' : '0')
      if (fotoArchivo.value) fd.append('foto', fotoArchivo.value)
      await api.post('/noticias', fd)
    }
    cerrarModal()
    await cargar()
  } catch (e) {
    alert(e.response?.data?.error || 'Error al guardar')
  } finally {
    guardando.value = false
  }
}

async function cambiarFoto(noticia, e) {
  const file = e.target.files[0]
  if (!file) return
  const fd = new FormData()
  fd.append('foto', file)
  try {
    const { data } = await api.patch(`/noticias/${noticia.id_noticia}/foto`, fd)
    noticia.foto_url = data.foto_url
  } catch {
    alert('Error al subir la foto')
  }
}

async function toggleActiva(noticia) {
  await api.put(`/noticias/${noticia.id_noticia}`, {
    titulo:            noticia.titulo,
    contenido:         noticia.contenido,
    fecha_publicacion: noticia.fecha_publicacion?.slice(0, 10) || null,
    activa:            noticia.activa ? 0 : 1,
  })
  noticia.activa = noticia.activa ? 0 : 1
}

async function eliminar(noticia) {
  if (!confirm(`¿Eliminar "${noticia.titulo}"?`)) return
  await api.delete(`/noticias/${noticia.id_noticia}`)
  noticias.value = noticias.value.filter(n => n.id_noticia !== noticia.id_noticia)
}

function formatFecha(f) {
  if (!f) return ''
  return new Date(f).toLocaleDateString('es-VE', { day: 'numeric', month: 'short', year: 'numeric' })
}

onMounted(cargar)
</script>

<style scoped>
.nc-foto-wrap {
  position: relative;
  height: 180px;
  overflow: hidden;
  border-radius: 0.5rem 0.5rem 0 0;
  background: #f1f5f9;
}
.nc-foto {
  width: 100%; height: 100%; object-fit: cover; display: block;
}
.nc-foto-placeholder {
  width: 100%; height: 100%;
  display: flex; align-items: center; justify-content: center;
  background: #f8fafc;
}
.nc-badge {
  position: absolute; top: 10px; right: 10px;
  font-size: 10px; font-weight: 700; letter-spacing: 1px;
  text-transform: uppercase; padding: 3px 10px; border-radius: 999px;
}
.nc-badge--activa   { background: #dcfce7; color: #16a34a; }
.nc-badge--inactiva { background: #fee2e2; color: #dc2626; }

.nc-fecha   { font-size: 11px; }
.nc-titulo  { font-size: 15px; font-weight: 700; color: #1e293b; line-height: 1.3; }
.nc-contenido {
  font-size: 13px; line-height: 1.55;
  display: -webkit-box; -webkit-line-clamp: 3;
  -webkit-box-orient: vertical; overflow: hidden;
}

/* Modal */
.modal-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.45);
  display: flex; align-items: center; justify-content: center;
  z-index: 1050; padding: 16px;
}
.modal-box {
  background: white; border-radius: 12px;
  width: 100%; max-width: 560px;
  max-height: 90vh; display: flex; flex-direction: column;
  box-shadow: 0 20px 60px rgba(0,0,0,0.2);
}
.modal-box__header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 20px 24px 16px;
  border-bottom: 1px solid #e2e8f0;
}
.modal-box__body {
  padding: 20px 24px;
  overflow-y: auto; flex: 1;
}
.modal-box__footer {
  padding: 16px 24px;
  border-top: 1px solid #e2e8f0;
}
</style>
