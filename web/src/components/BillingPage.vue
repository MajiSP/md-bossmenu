<template>
    <div class="billing-container">
      <h2 class="text-2xl font-bold mb-6 text-left">Billing</h2>
      <div class="billing-form flex flex-col space-y-4 max-w-md mx-auto">
        <div class="w-full">
          <label for="playerId" class="block text-sm font-medium mb-1 text-center">Player ID</label>
          <input id="playerId" v-model="playerId" placeholder="Enter player ID" class="input-field w-full" />
        </div>
        <div class="w-full">
          <label for="amount" class="block text-sm font-medium mb-1 text-center">Amount ($)</label>
          <input id="amount" v-model="amount" type="number" placeholder="Enter amount" class="input-field w-full" />
        </div>
        <div class="w-full">
          <label for="reason" class="block text-sm font-medium mb-1 text-center">Reason</label>
          <input id="reason" v-model="reason" placeholder="Enter reason for bill" class="input-field w-full" />
        </div>
        <button @click="sendBill" class="send-bill-button w-full mt-4">Send Bill</button>
      </div>
      
      <div class="mt-8">
        <div @click="toggleLogs" class="flex justify-center cursor-pointer">
          <font-awesome-icon :icon="showLogs ? 'chevron-up' : 'chevron-down'" class="text-2xl" />
        </div>
        <div v-if="showLogs" class="mt-4 space-y-2">
          <div v-for="log in currentPageLogs" :key="log.id" class="p-2 rounded flex items-center" :class="getLogClass()">
            <span class="font-semibold">{{ log.sender }}</span>
            <span class="mx-2">billed</span>
            <span class="font-semibold">{{ log.recipient }}</span>
            <span class="mx-2">for</span>
            <span class="font-mono">${{ log.amount }}</span>
            <span class="mx-2">at</span>
            <span class="font-mono">{{ formatTime(log.time) }}</span>
          </div>
          <div v-if="totalPages > 1" class="flex justify-center mt-4 mb-4 space-x-2">
            <button @click="prevPage" :disabled="currentPage === 1" class="px-2 py-1 rounded" :class="getButtonClass()">Prev</button>
            <span>{{ currentPage }} / {{ totalPages }}</span>
            <button @click="nextPage" :disabled="currentPage === totalPages" class="px-2 py-1 rounded" :class="getButtonClass()">Next</button>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, computed, inject } from 'vue'
  import { formatDistanceToNow } from 'date-fns'
  
  const playerId = ref('')
  const amount = ref('')
  const reason = ref('')
  const billingLogs = ref([])
  const showLogs = ref(false)
  const currentPage = ref(1)
  const logsPerPage = 10
  
  const currentTheme = inject('theme')
  
  const sendBill = () => {
    fetch(`https://${GetParentResourceName()}/sendBill`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ playerId: playerId.value, amount: amount.value, reason: reason.value })
    })
    .then(() => {
      billingLogs.value.unshift({
        id: Date.now(),
        sender: 'You',
        recipient: playerId.value,
        amount: amount.value,
        time: new Date()
      })
      playerId.value = ''
      amount.value = 0
      reason.value = ''
    })
  }
  
  const toggleLogs = () => {
    showLogs.value = !showLogs.value
  }
  
  const totalPages = computed(() => Math.ceil(billingLogs.value.length / logsPerPage))
  
  const currentPageLogs = computed(() => {
    const start = (currentPage.value - 1) * logsPerPage
    const end = start + logsPerPage
    return billingLogs.value.slice(start, end)
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
  
  const getLogClass = () => {
    return currentTheme.value === 'light-theme'
      ? 'bg-gray-100 text-gray-800'
      : 'bg-gray-700 text-white'
  }
  
  const formatTime = (time) => {
    return formatDistanceToNow(new Date(time), { addSuffix: true })
  }
  </script>