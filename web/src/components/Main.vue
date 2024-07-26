<template>
  <div v-if="isUIOpen" :class="['boss-menu-container', theme]">
    <div class="boss-menu-content">
      <button @click="closeUI" class="absolute top-2 right-2 p-2 rounded-full transition-colors duration-200" :class="theme === 'light-theme' ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-300 hover:bg-gray-700'">
        <font-awesome-icon icon="times" class="w-5 h-5" />
      </button>
      <div :class="['sidebar', { 'expanded': isExpanded }]">
        <button @click="toggleSidebar" class="expand-btn">
          <font-awesome-icon icon="bars" />
        </button>
        <div 
          v-for="item in menuItems" 
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
        <div :class="['flex-grow pl-4 pr-4', { 'overflow-y-auto': activePage !== 'Employees', 'overflow-hidden': activePage === 'Employees' }]">
          <StatisticsPage v-if="activePage === 'Statistics'" />
          <EmployeesPage v-if="activePage === 'Employees'" class="h-full" />
          <BonusesPage v-if="activePage === 'Bonuses'" />
          <SettingsPage v-if="activePage === 'Settings'" @theme-changed="updateTheme" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, provide } from 'vue'
import StatisticsPage from './StatisticsPage.vue'
import EmployeesPage from './EmployeesPage.vue'
import BonusesPage from './BonusesPage.vue'
import SettingsPage from './SettingsPage.vue'

const isExpanded = ref(false)
const activePage = ref('Employees')
const theme = ref('dark-theme')

const isUIOpen = ref(false)

const menuItems = [
  { icon: 'users', name: 'Employees' },
  { icon: 'chart-bar', name: 'Statistics' },
  { icon: 'gift', name: 'Bonuses' },
  { icon: 'cog', name: 'Settings' },
]

const employees = ref([])
const grades = ref([])
const salaries = ref({})

provide('employees', employees)
provide('grades', grades)
provide('salaries', salaries)
provide('theme', theme)

const toggleSidebar = () => {
  isExpanded.value = !isExpanded.value
}

const setActivePage = (pageName) => {
  activePage.value = pageName
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

window.addEventListener('message', (event) => {
  if (event.data.action === 'openUI') {
    isUIOpen.value = true
  } else if (event.data.action === 'closeUI') {
    isUIOpen.value = false
  } else if (event.data.action === 'refreshEmployees') {
    employees.value = event.data.employees
    grades.value = event.data.grades
    salaries.value = event.data.salaries
  }
})
</script>
