import { getCurrentInstance } from 'vue'

export function useSound() {
  const instance = getCurrentInstance()
  
  const sendInteractionToClient = (interactionType, data) => {
    console.log('UI Interaction:', interactionType, data)
    if (instance) {
      instance.emit('interaction', { type: interactionType, data })
    }
  }

  return { sendInteractionToClient }
}