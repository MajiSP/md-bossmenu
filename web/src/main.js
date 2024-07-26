import { createApp } from 'vue'
import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { faUsers, faCog, faChartBar, faBars, faTrash, faArrowDown, faArrowUp, faGift, faDollar, faBank, faPiggyBank, faHandHoldingDollar, faTimes } from '@fortawesome/free-solid-svg-icons'
import { Chart, ArcElement, Tooltip, Legend } from 'chart.js'
import './style.css'
import App from './App.vue'

Chart.register(ArcElement, Tooltip, Legend)

library.add(faUsers, faCog, faChartBar, faBars, faTrash, faArrowUp, faArrowDown, faGift, faDollar, faBank, faPiggyBank, faHandHoldingDollar, faTimes)

createApp(App)
  .component('font-awesome-icon', FontAwesomeIcon)
  .mount('#app')
