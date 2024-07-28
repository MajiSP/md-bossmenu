import { createApp } from 'vue'
import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { fas } from '@fortawesome/free-solid-svg-icons'
import Chart from 'chart.js/auto'
import './style.css'
import App from './App.vue'

library.add(fas)

createApp(App)
  .component('font-awesome-icon', FontAwesomeIcon)
  .mount('#app')
