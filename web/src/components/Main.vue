<template>
    <div v-if="isUIOpen" :key="forceRender" :class="['boss-menu-container', theme]">
      <div class="boss-menu-content">
        <button 
          @click="closeUI(); sendInteractionToClient('click', { component: 'closeButton' })" 
          @mouseenter="sendInteractionToClient('hover', { component: 'closeButton' })" 
          class="absolute top-2 right-2 p-2 rounded-full transition-colors duration-200 z-10" 
          :class="theme === 'light-theme' ? 'text-gray-600 hover:bg-gray-200' : 'text-gray-300 hover:bg-gray-700'"
        >
          <font-awesome-icon icon="times" class="w-5 h-5" />
        </button>
        <div :class="['sidebar', { 'expanded': isExpanded }]">
          <button 
            @click="toggleSidebar(); sendInteractionToClient('click', { component: 'sidebarToggle' })" 
            @mouseenter="sendInteractionToClient('hover', { component: 'sidebarToggle' })" 
            class="expand-btn"
          >
            <font-awesome-icon icon="bars" />
          </button>
          <div
            v-for="item in getVisibleMenuItems()"
            :key="item.icon"
            class="sidebar-item"
            :class="{ 'active': activePage === item.name }"
            @click="setActivePage(item.name); sendInteractionToClient('click', { component: 'sidebarItem', item: item.name })"
            @mouseenter="sendInteractionToClient('hover', { component: 'sidebarItem', item: item.name })"
          >
            <font-awesome-icon 
              :icon="item.icon" 
              :class="{'file-invoice-dollar-icon': item.icon === 'file-invoice-dollar'}"
            />
            <span v-if="isExpanded">{{ item.name }}</span>
          </div>
        </div>
        <div :class="['main-content flex flex-col', { 'chat-page-active': activePage === 'Chat' }]">
          <h1 class="text-3xl font-bold px-4 mb-4">Boss Menu</h1>
          <div :class="['flex-grow pl-4 pr-4', { 'overflow-y-auto': activePage !== 'Home', 'overflow-hidden': activePage === 'Home' }]">
            <HomePage v-if="activePage === 'Home'" :isBoss="isBoss" :employees="employees" />
            <BillingPage v-if="activePage === 'Billing'" />
            <StatisticsPage v-if="activePage === 'Statistics' && isBoss" />
            <EmployeesPage v-if="activePage === 'Employees' && isBoss" class="h-full" />
            <BonusesPage v-if="activePage === 'Bonuses' && isBoss" />
            <StashesPage v-if="activePage === 'Stashes'" :isBoss="isBoss" />
            <ChatPage v-if="activePage === 'Chat'" :isBoss="isBoss" :chatHistoryLoaded="chatHistoryLoaded" />
            <SettingsPage v-if="activePage === 'Settings'" @theme-changed="updateTheme" :activePage="activePage" />
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
import BillingPage from './BillingPage.vue'

const isExpanded = ref(false)
const theme = ref('dark-theme')
const isUIOpen = ref(false)
const isBoss = ref(false)
const activePage = shallowRef('Home')
const forceRender = ref(0)

const menuItems = [
  { icon: 'home', name: 'Home', bossOnly: false },
  { icon: 'users', name: 'Employees', bossOnly: true },
  { icon: 'file-invoice-dollar', name: 'Billing', bossOnly: false },
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

const chatHistoryLoaded = ref(false)

const setActivePage = (pageName) => {
  activePage.value = pageName
  if (pageName === 'Employees') {
    fetch(`https://${GetParentResourceName()}/SetActivePage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    })
  } else if (pageName === 'Chat' && !chatHistoryLoaded.value) {
    loadChatHistory()
  }
}

const fetchUserImage = () => {
  fetch(`https://${GetParentResourceName()}/getUserImage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  })
  .then(response => response.json())
  .then(data => {
    userState.setUserImage(data.imageUrl)
  })
  .catch(error => {
    console.error('Error fetching user image:', error)
  })
}

const loadChatHistory = () => {
  fetch(`https://${GetParentResourceName()}/getChatHistory`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  })
  .then(() => {
    chatHistoryLoaded.value = true
  })
}


const updateTheme = (newTheme) => {
  theme.value = newTheme
}

const sendInteractionToClient = () => {
  //fetch(`https://${GetParentResourceName()}/PlaySound`, {
    //method: 'POST',
    //headers: { 'Content-Type': 'application/json' },
    //body: JSON.stringify({ type: interactionType, data: data })
  //})
}

const closeUI = () => {
  isUIOpen.value = false
  fetch(`https://${GetParentResourceName()}/closeUI`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
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
    activePage.value = 'Home'
    fetchUserImage()
    if (Array.isArray(event.data.menuItems) && event.data.menuItems.length > 0) {
      menuItems.value = event.data.menuItems.map((item, index) => ({
        ...menuItems[index],
        icon: item.icon,
        bossOnly: item.bossOnly
      }))
    }
  } else if (event.data.action === 'refreshEmployees') {
    employees.value = event.data.employees
    grades.value = event.data.grades
    salaries.value = event.data.salaries
    activePage.value = 'Employees'
  }
})

provide('employees', employees)
provide('grades', grades)
provide('salaries', salaries)
provide('theme', theme)
provide('isUIOpen', isUIOpen)
provide('closeUI', closeUI)
</script>
