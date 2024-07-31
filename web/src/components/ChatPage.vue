<template>
  <div class="chat-container">
    <h2 class="text-2xl font-bold mb-6">Job Chat</h2>
    <div v-if="messages.length > 0" class="chat-messages" ref="chatContainer">
      <div class="chat-messages">
        <div v-for="message in messages" :key="message.id || message.timestamp"
            class="message flex items-start space-x-2 mb-4"
            :class="{'sent': isSentByCurrentUser(message)}"
            :style="isSentByCurrentUser(message) ? 'justify-content: flex-end;' : 'justify-content: flex-start;'">
          <img v-if="!isSentByCurrentUser(message)" :src="message.userImage || userState.userImage" alt="User Avatar"
               class="w-8 h-8 rounded-full object-cover border-2 border-gray-300 shadow-md flex-shrink-0">
          <div class="message-content"
               :class="{'bg-blue-700 text-white': isSentByCurrentUser(message), 'bg-gray-200 text-gray-800': !isSentByCurrentUser(message)}">
            <span class="sender">{{ message.sender || 'Unknown' }}</span>
            <p>{{ message.content || '' }}</p>
            <span class="timestamp">{{ formatTime(message.timestamp) }}</span>
          </div>
          <img v-if="isSentByCurrentUser(message)" :src="message.userImage || userState.userImage" alt="User Avatar"
               class="w-8 h-8 rounded-full object-cover border-2 border-gray-300 shadow-md flex-shrink-0">
        </div>
      </div>
      <div class="chat-input">
        <input v-model="newMessage" @keyup.enter="sendMessage" placeholder="Type a message..." />
        <button @click="sendMessage" class="send-button">
          <font-awesome-icon icon="paper-plane" />
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { userState } from '../userState'
import { ref, onMounted, nextTick, watch } from 'vue'
import { formatDistanceToNow } from 'date-fns'
import { useSound } from './sounds'

const props = defineProps({
  isBoss: Boolean,
  chatHistoryLoaded: Boolean
})

watch(() => props.chatHistoryLoaded, (newValue) => {
  if (newValue) {
    refreshChatMessages()
    scrollToBottom()
  }
})

const refreshChatMessages = () => {
  fetch(`https://${GetParentResourceName()}/getChatHistory`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  })
  .then(response => response.json())
  .then(data => {
    userState.setChatHistory(data)
    messages.value = [...userState.chatHistory]
    scrollToBottom()
  })
  .catch(error => {
    console.error('Error refreshing chat messages:', error)
  })
}


const { sendInteractionToClient } = useSound()

const messages = ref(userState.chatHistory)
const newMessage = ref('')
const chatContainer = ref(null)

const isSentByCurrentUser = (message) => {
  return message.sender && userState.currentUser && 
         message.sender.toLowerCase() === userState.currentUser.toLowerCase()
}

const sendMessage = () => {
  if (newMessage.value.trim() === '') return
  const message = {
    sender: userState.currentUser,
    content: newMessage.value,
    timestamp: Math.floor(Date.now() / 1000),
    job: userState.currentJob,
    userImage: userState.userImage
  }
  triggerClientMessage(message)
  newMessage.value = ''
  scrollToBottom()
}

const scrollToBottom = () => {
  nextTick(() => {
    if (chatContainer.value) {
      const innerContainer = chatContainer.value.querySelector('.chat-messages')
      if (innerContainer) {
        innerContainer.scrollTop = innerContainer.scrollHeight
      }
    }
  })
}

const setChatHistory = (data) => {
  userState.setChatHistory(data)
  nextTick(() => {
    messages.value = [...userState.chatHistory]
    scrollToBottom()
  })
}

const formatTime = (timestamp) => {
  return formatDistanceToNow(new Date(timestamp * 1000), { addSuffix: true })
}

const loadChatHistory = () => {
  fetch(`https://${GetParentResourceName()}/getChatHistory`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  })
  .then(response => response.json())
  .then(data => {
    userState.setChatHistory(data)
    messages.value = userState.chatHistory
    scrollToBottom()
  })
}


const triggerClientMessage = (message) => {
  fetch(`https://${GetParentResourceName()}/sendChatMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(message)
  })
}

watch(() => messages.value, () => {
  scrollToBottom()
}, { deep: true })

onMounted(() => {
  const eventHandlers = {
    updateChat: (data) => {
      if (data.message && !messages.value.some(m => m.id === data.message.id)) {
        messages.value.push(data.message)
        scrollToBottom()
      }
    },
    setCurrentUser: (data) => {
      userState.currentUser = data.username
      userState.currentJob = data.job
    },
    openUI: (data) => {
      loadChatHistory()
    },
    setChatHistory: (data) => {
      userState.setChatHistory(data)
      messages.value = userState.chatHistory
      scrollToBottom()
    }
  }

  window.addEventListener('message', (event) => {
    const handler = eventHandlers[event.data.action]
    if (handler) {
      handler(event.data)
    }
  })
  scrollToBottom()
})
</script>
