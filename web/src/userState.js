import { reactive } from 'vue'

export const userState = reactive({
  currentUser: '',
  currentJob: '',
  chatHistory: [],
  userImage: 'https://cdn.discordapp.com/attachments/1175646486478999613/1268103587083452448/egg.jpg?ex=66ab34ff&is=66a9e37f&hm=e3ccee44799163098c6ff50b65c8a987441660f9fc8dcf1713ad1caec3e7fc94&', // Default

  setUser(username, job) {
    this.currentUser = username
    this.currentJob = job
  },

  setChatHistory(history) {
    if (history && history.messages) {
      this.chatHistory = history.messages
    } else if (Array.isArray(history)) {
      this.chatHistory = history
    } else {
      this.chatHistory = []
    }
  },

  setUserImage(imageUrl) {
    this.userImage = imageUrl
  }
})
