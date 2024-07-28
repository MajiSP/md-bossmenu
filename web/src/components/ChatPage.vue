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
      <div v-if="isTyping" class="typing-indicator">
        <span></span>
        <span></span>
        <span></span>
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
  const currentUser = 'Maji'
  const isTyping = ref(false)

  const addMessageWithDelay = (message, delay) => {
  setTimeout(() => {
    messages.value.push(message)
    scrollToBottom()
  }, delay)
}
  
  const sendMessage = () => {
  if (newMessage.value.trim() === '') return
  const message = {
    id: Date.now(),
    sender: currentUser,
    content: newMessage.value,
    timestamp: new Date()
  }
  addMessageWithDelay(message, 500)
  newMessage.value = ''
  simulateResponse()
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

const simulateResponse = () => {
  isTyping.value = true
  setTimeout(() => {
    const response = {
      id: Date.now(),
      sender: 'Mustache',
      content: getRandomResponse(),
      timestamp: new Date()
    }
    isTyping.value = false
    addMessageWithDelay(response, 500)
  }, 3000)
}

  
  const getRandomResponse = () => {
    const responses = [
      "That's a great point! I'll implement that in the backend.",
      "I've just pushed an update to the server. Can you test it?",
      "We might need to optimize the database queries for that feature.",
      "The API endpoint for that is now ready. Let me know if you need any changes.",
      "I'm working on improving the server's response time. Should be done soon.",
    ]
    return responses[Math.floor(Math.random() * responses.length)]
  }
  
  onMounted(() => {
    const initialConversation = [
      { sender: 'Maji', content: "Hey, I've just finished the new UI for the user dashboard. Can you update the API to include user activity data?" },
      { sender: 'Mustache', content: "Sure thing! I'll work on that right away. Any specific data points you need?" },
      { sender: 'Maji', content: "We'll need login times, feature usage stats, and maybe some performance metrics if possible." },
      { sender: 'Mustache', content: "Got it. I'll set up new endpoints for those. Should be ready for testing in a couple of hours." },
      { sender: 'Maji', content: "Awesome! I'll prepare the frontend to integrate with the new endpoints. Let's touch base again once they're ready." },
    ]
  
    const showTypingAndMessage = (msg, index) => {
    setTimeout(() => {
      if (msg.sender !== currentUser) {
        isTyping.value = true
        setTimeout(() => {
          isTyping.value = false
          addMessageWithDelay({
            id: Date.now() + index,
            sender: msg.sender,
            content: msg.content,
            timestamp: new Date(Date.now() - (initialConversation.length - index) * 60000)
          }, 500)
        }, 2000)
      } else {
        addMessageWithDelay({
          id: Date.now() + index,
          sender: msg.sender,
          content: msg.content,
          timestamp: new Date(Date.now() - (initialConversation.length - index) * 60000)
        }, 500)
      }
    }, index * 5000)
  }

  initialConversation.forEach((msg, index) => {
    showTypingAndMessage(msg, index)
  })
})
  </script>
  