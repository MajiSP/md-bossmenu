<template>
    <div class="stashes-container">
      <h2 class="text-2xl font-bold mb-6">Stashes</h2>
      <div class="flex flex-col items-center space-y-4">
        <button @click="sendInteractionToClient('click', { component: 'personalStash', page: 'stashPage' }); openStash('personal')" class="stash-button max-w-xs w-full">
          Personal Stash
        </button>
        <button @click="sendInteractionToClient('click', { component: 'sharedStash', page: 'stashPage' }); openStash('shared')" class="stash-button max-w-xs w-full">
          Shared Stash
        </button>
        <button v-if="isBoss" @click="sendInteractionToClient('click', { component: 'bossStash', page: 'stashPage' }); openStash('boss')" class="stash-button max-w-xs w-full">
          Boss Stash
        </button>
      </div>
      
      <div v-if="isBoss" class="mt-8">
        <div @click="sendInteractionToClient('click', { component: 'showLogs', page: 'stashPage' }); toggleLogs()" class="flex justify-center cursor-pointer">
            <font-awesome-icon :icon="showLogs ? 'chevron-up' : 'chevron-down'" class="text-2xl" />
        </div>
        <div v-if="showLogs" class="mt-4 space-y-2">
            <div v-for="log in currentPageLogs" :key="log.id" class="p-2 rounded flex items-center" :class="getLogClass(log.stash)">
            <div class="w-3 h-3 rounded-full mr-2" :class="getStashColor(log.stash)"></div>
            <span class="font-semibold">{{ log.user }}</span>
            <span class="mx-2">accessed</span>
            <span class="font-semibold" :class="getStashTextColor(log.stash)">{{ log.stash }}</span>
            <span class="mx-2">stash at</span>
            <span class="font-mono">{{ formatTime(log.time) }}</span>
            </div>
            <div v-if="totalPages > 1" class="flex justify-center mt-4 mb-4 space-x-2">
            <button @click="sendInteractionToClient('click', { component: 'prevPage', page: 'stashPage' }); prevPage()" :disabled="currentPage === 1" class="px-2 py-1 rounded" :class="getButtonClass()">Prev</button>
            <span>{{ currentPage }} / {{ totalPages }}</span>
            <button @click="sendInteractionToClient('click', { component: 'nextPage', page: 'stashPage' }); nextPage()" :disabled="currentPage === totalPages" class="px-2 py-1 rounded" :class="getButtonClass()">Next</button>
            </div>
        </div>
        </div>
        </div>
</template>
  
<script setup>
import { ref, defineProps, inject, computed } from 'vue'
import { useSound } from './sounds'
const { sendInteractionToClient } = useSound()
  
const props = defineProps({
    isBoss: Boolean
})
  
const currentTheme = inject('theme')

const closeUI = inject('closeUI')
  
const showLogs = ref(false)
const stashLogs = ref([])

const logsPerPage = 10
const currentPage = ref(1)

const totalPages = computed(() => Math.ceil(stashLogs.value.length / logsPerPage))

const currentPageLogs = computed(() => {
  const start = (currentPage.value - 1) * logsPerPage
  const end = start + logsPerPage
  return stashLogs.value.slice(start, end)
})

const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++
}

const getButtonClass = () => {
  return currentTheme.value === 'light-theme'
    ? 'bg-blue-500 text-white hover:bg-blue-600'
    : 'bg-blue-600 text-white hover:bg-blue-700'
}

  const getLogClass = (stashType) => {
  return currentTheme.value === 'light-theme' 
    ? 'bg-gray-100 text-gray-800' 
    : 'bg-gray-700 text-white'
}

const getStashColor = (stashType) => {
  switch (stashType.toLowerCase()) {
    case 'personal': return 'bg-green-500'
    case 'shared': return 'bg-blue-500'
    case 'boss': return 'bg-purple-500'
    default: return 'bg-gray-500'
  }
}

const getStashTextColor = (stashType) => {
  switch (stashType.toLowerCase()) {
    case 'personal': return 'text-green-500'
    case 'shared': return 'text-blue-500'
    case 'boss': return 'text-purple-500'
    default: return 'text-gray-500'
  }
}

const formatTime = (time) => {
  return new Date(time).toLocaleString('en-US', { 
    hour: 'numeric', 
    minute: 'numeric', 
    hour12: true 
  })
}

const openStash = (type) => {
  closeUI()
  setTimeout(() => {
    fetch(`https://${GetParentResourceName()}/openStash`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type })
    })
  }, 100)
}

const updateLogs = (logs) => {
  stashLogs.value = logs
  currentPage.value = 1
}

const toggleLogs = () => {
  showLogs.value = !showLogs.value
}

window.addEventListener('message', (event) => {
  if (event.data.action === 'updateStashLogs') {
    updateLogs(event.data.logs)
  }
})

</script>
  