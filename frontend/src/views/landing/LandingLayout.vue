<template>
  <div>
    <RouterView />
    <LandingFooter />
  </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'
import { RouterView } from 'vue-router'
import LandingFooter from '@/components/landing/LandingFooter.vue'

onMounted(() => {
  document.documentElement.style.setProperty('background', '#1a0d0a', 'important')
  document.body.style.setProperty('background', '#1a0d0a', 'important')
})

onUnmounted(() => {
  document.documentElement.style.removeProperty('background')
  document.body.style.removeProperty('background')
})
</script>
