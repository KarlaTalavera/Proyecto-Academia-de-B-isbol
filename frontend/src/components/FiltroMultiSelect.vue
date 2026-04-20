<template>
  <div ref="rootEl" style="position:relative; display:inline-block;">
    <!-- Botón disparador -->
    <button
      type="button"
      class="btn btn-sm d-flex align-items-center gap-1"
      :class="esTodos ? 'btn-outline-secondary' : 'btn-primary'"
      @click.stop="abierto = !abierto"
      :title="esTodos ? textoTodos : modelValue.join(', ')"
    >
      <span style="max-width:160px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
        {{ etiqueta }}
      </span>
      <span style="font-size:10px; flex-shrink:0; margin-left:2px;">▾</span>
    </button>

    <!-- Panel desplegable -->
    <div
      v-if="abierto"
      class="card shadow border"
      style="position:absolute; top:calc(100% + 4px); left:0; z-index:400; min-width:210px; max-height:280px; overflow-y:auto; border-color:#e2e8f0 !important; border-radius:8px;"
      @click.stop
    >
      <div class="p-2">
        <!-- Opción "Todos" -->
        <label
          class="d-flex align-items-center gap-2 py-1 px-1 rounded mb-1"
          style="cursor:pointer; font-size:0.84rem; font-weight:600;"
          :style="esTodos ? 'background:#eff6ff; color:#3b82f6;' : ''"
        >
          <input
            type="checkbox"
            class="form-check-input mt-0"
            :checked="esTodos"
            @change="onTodos"
          />
          {{ textoTodos }}
        </label>

        <div style="border-top:1px solid #e2e8f0; margin:4px 0;"></div>

        <!-- Opciones específicas -->
        <label
          v-for="op in opciones"
          :key="op"
          class="d-flex align-items-center gap-2 py-1 px-1 rounded mb-1"
          style="cursor:pointer; font-size:0.84rem;"
          :style="modelValue.includes(op) ? 'background:#eff6ff;' : ''"
        >
          <input
            type="checkbox"
            class="form-check-input mt-0"
            :checked="modelValue.includes(op)"
            @change="onToggle(op)"
          />
          <span>{{ op }}</span>
        </label>

        <div v-if="!opciones.length" class="text-muted text-center py-2" style="font-size:0.8rem;">
          Sin opciones disponibles
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'

const props = defineProps({
  modelValue:  { type: Array,  default: () => [] },  // [] = todos, [x,y] = específicos
  opciones:    { type: Array,  default: () => [] },
  textoTodos:  { type: String, default: 'Todos' },
  pluralLabel: { type: String, default: 'seleccionados' },
})

const emit = defineEmits(['update:modelValue'])

const abierto = ref(false)
const rootEl  = ref(null)

// [] → todos; [x,...] → específicos. Nunca queda vacío en modo específico
const esTodos = computed(() => props.modelValue.length === 0)

const etiqueta = computed(() => {
  if (esTodos.value) return props.textoTodos
  if (props.modelValue.length === 1) return props.modelValue[0]
  return `${props.modelValue.length} ${props.pluralLabel}`
})

function onTodos() {
  // Solo actuar si estamos en modo específico
  if (!esTodos.value) emit('update:modelValue', [])
}

function onToggle(op) {
  const arr = [...props.modelValue]
  const idx = arr.indexOf(op)
  if (idx === -1) {
    arr.push(op)
  } else {
    arr.splice(idx, 1)
    // Si se deselecciona el último → volver automáticamente a "Todos"
    // (arr ya es [] en ese caso — el padre lo interpreta como todos)
  }
  emit('update:modelValue', arr)
}

function onClickFuera(e) {
  if (rootEl.value && !rootEl.value.contains(e.target)) {
    abierto.value = false
  }
}

onMounted(()        => document.addEventListener('click', onClickFuera, true))
onBeforeUnmount(()  => document.removeEventListener('click', onClickFuera, true))
</script>
