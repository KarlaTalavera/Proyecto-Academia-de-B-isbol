import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

// Tabler UI — CSS base
import '@tabler/core/dist/css/tabler.min.css'
// Tabler UI — JS (dropdowns, collapse, etc.)
import '@tabler/core/dist/js/tabler.min.js'
// Glassmorphism custom styles
import './assets/style.css'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')
