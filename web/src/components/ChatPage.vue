<template>
  <div class="chat-container">
    <h2 class="text-2xl font-bold mb-6">Job Chat</h2>
    <div class="chat-messages" ref="chatContainer">
      <div v-for="message in messages" :key="message.id" class="message" :class="{ 'sent': message.sender === currentUser }">
        <div class="message-content">
          <span class="sender">{{ message.sender }}</span>
          <p>{{ message.content }}</p>
          <span class="timestamp">{{ formatTime(message.timestamp) }}</span>
        </div>
      </div>
    </div>
    <div class="chat-input">
      <input v-model="newMessage" @keyup.enter="sendMessage" placeholder="Type a message..." />
      <button @click="sendMessage" class="send-button">
        <font-awesome-icon icon="paper-plane" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { formatDistanceToNow } from 'date-fns'

const messages = ref([])
const newMessage = ref('')
const chatContainer = ref(null)
const currentUser = ref('')
const currentJob = ref('')

const sendMessage = () => {
  if (newMessage.value.trim() === '') return
  const message = {
    id: Date.now(),
    sender: currentUser.value,
    content: newMessage.value,
    timestamp: new Date(),
    job: currentJob.value
  }
  triggerClientMessage(message)
  newMessage.value = ''
}

const triggerClientMessage = (message) => {
  fetch(`https://${GetParentResourceName()}/sendChatMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(message)
  })
}

const scrollToBottom = () => {
  nextTick(() => {
    if (chatContainer.value) {
      chatContainer.value.scrollTop = chatContainer.value.scrollHeight
    }
  })
}

const formatTime = (timestamp) => {
  return formatDistanceToNow(new Date(timestamp), { addSuffix: true })
}

const loadMessagesFromDatabase = () => {
  fetch(`https://${GetParentResourceName()}/getChatHistory`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ job: currentJob.value })
  })
  .then(response => response.json())
  .then(data => {
    messages.value = data.messages
    scrollToBottom()
  })
}

onMounted(() => {
  loadMessagesFromDatabase()
  
  window.addEventListener('message', (event) => {
    if (event.data.action === 'updateChat') {
      messages.value.push(event.data.message)
      scrollToBottom()
    } else if (event.data.action === 'setCurrentUser') {
      currentUser.value = event.data.username
      currentJob.value = event.data.job
      loadMessagesFromDatabase()
    }
  })
})
</script>
