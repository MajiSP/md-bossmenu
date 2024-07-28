<template>
  <div v-if="isUIOpen" :key="forceRender" :class="['boss-menu-container', theme]">
    <div class="boss-menu-content">
      <button @click="closeUI" class="absolute top-2 right-2 p-2 rounded-full transition-colors duration-200" :class="theme === 'light-theme' ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-300 hover:bg-gray-700'">
        <font-awesome-icon icon="times" class="w-5 h-5" />
      </button>
      <div :class="['sidebar', { 'expanded': isExpanded }]">
        <button @click="toggleSidebar" class="expand-btn">
          <font-awesome-icon icon="bars" />
        </button>
        <div 
          v-for="item in getVisibleMenuItems()" 
          :key="item.icon" 
          class="sidebar-item" 
          :class="{ 'active': activePage === item.name }"
          @click="setActivePage(item.name)"
        >
          <font-awesome-icon :icon="item.icon" />
          <span v-if="isExpanded">{{ item.name }}</span>
        </div>
      </div>
      <div class="main-content flex flex-col">
        <h1 class="text-3xl font-bold px-4 mb-4">Boss Menu</h1>
        <div :class="['flex-grow pl-4 pr-4', { 'overflow-y-auto': activePage !== 'Home', 'overflow-hidden': activePage === 'Home' }]">
          <HomePage v-if="activePage === 'Home'" :isBoss="isBoss" :employees="employees" />
          <StatisticsPage v-if="activePage === 'Statistics' && isBoss" />
          <EmployeesPage v-if="activePage === 'Employees' && isBoss" class="h-full" />
          <BonusesPage v-if="activePage === 'Bonuses' && isBoss" />
          <StashesPage v-if="activePage === 'Stashes'" :isBoss="isBoss" />
          <ChatPage v-if="activePage === 'Chat'" :isBoss="isBoss" />
          <SettingsPage v-if="activePage === 'Settings'" @theme-changed="updateTheme" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, provide, shallowRef } from 'vue'
import StatisticsPage from './StatisticsPage.vue'
import EmployeesPage from './EmployeesPage.vue'
import BonusesPage from './BonusesPage.vue'
import SettingsPage from './SettingsPage.vue'
import HomePage from './HomePage.vue'
import StashesPage from './StashesPage.vue'
import ChatPage from './ChatPage.vue'

const isExpanded = ref(false)
const theme = ref('dark-theme')
const isUIOpen = ref(false)
const isBoss = ref(false)

const activePage = shallowRef('Home')

const forceRender = ref(0)

const menuItems = [
  { icon: 'home', name: 'Home', bossOnly: false },
  { icon: 'users', name: 'Employees', bossOnly: true },
  { icon: 'chart-bar', name: 'Statistics', bossOnly: true },
  { icon: 'gift', name: 'Bonuses', bossOnly: true },
  { icon: 'box', name: 'Stashes', bossOnly: false },
  { icon: 'comments', name: 'Chat', bossOnly: false },
  { icon: 'cog', name: 'Settings', bossOnly: false }
]

const employees = ref([])
const grades = ref([])
const salaries = ref({})

const toggleSidebar = () => {
  isExpanded.value = !isExpanded.value
}

const setActivePage = (pageName) => {
  activePage.value = pageName
  if (pageName === 'Employees') {
    fetch(`https://${GetParentResourceName()}/refreshEmployees`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    })
  }
}

const updateTheme = (newTheme) => {
  theme.value = newTheme
}

const closeUI = () => {
  fetch(`https://${GetParentResourceName()}/closeUI`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify({}),
  }).then(() => {
    isUIOpen.value = false
  })
}

const handleCloseUI = () => {
  closeUI()
}

provide('closeUI', handleCloseUI)

function getVisibleMenuItems() {
  return menuItems.filter(item => !item.bossOnly || isBoss.value)
}

window.addEventListener('message', (event) => {
  if (event.data.action === 'openUI') {
    isUIOpen.value = true
    isBoss.value = event.data.isBoss
    activePage.value = isBoss.value ? 'Home' : 'Home'
    if (Array.isArray(event.data.menuItems) && event.data.menuItems.length > 0) {
      menuItems.value = event.data.menuItems.map((item, index) => ({
        ...menuItems.value[index],
        icon: item.icon,
        bossOnly: item.bossOnly
      }))
    }
  } else if (event.data.action === 'refreshEmployees') {
    employees.value = event.data.employees
    grades.value = event.data.grades
    salaries.value = event.data.salaries
  }
})

provide('employees', employees)
provide('grades', grades)
provide('salaries', salaries)
provide('theme', theme)

</script>
