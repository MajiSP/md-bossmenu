<template>
    <div class="settings-container">
      <h2 class="text-2xl font-bold mb-6">Settings</h2>
      
      <div class="grid grid-cols-2 gap-6">
        <div class="setting-section">
          <h3 class="text-xl mb-4">Theme</h3>
          <div class="flex space-x-4">
            <button 
                @click="sendInteractionToClient('click', { component: 'changeThemeLight', page: 'SettingsPage' }); changeTheme('light-theme')"
                :class="['setting-button px-4 py-2 rounded', currentTheme === 'light-theme' ? 'active' : '']"
                >
                Light
                </button>
                <button 
                @click="sendInteractionToClient('click', { component: 'changeThemeDark', page: 'SettingsPage' }); changeTheme('dark-theme')"
                :class="['setting-button px-4 py-2 rounded', currentTheme === 'dark-theme' ? 'active' : '']"
                >
                Dark
            </button>
          </div>
        </div>
        <div class="setting-section">
          <h3 class="text-xl mb-4">Notifications</h3>
          <label class="flex items-center">
            <input type="checkbox" v-model="settings.emailNotifications" class="mr-2">
            Email Notifications
          </label>
        </div>
  
        <div class="setting-section">
          <h3 class="text-xl mb-4">Language</h3>
          <select v-model="settings.language" class="bg-gray-700 rounded p-2">
            <option value="en">English</option>
            <option value="es">Español</option>
            <option value="fr">Français</option>
          </select>
        </div>
      </div>
      <div class="contributors-container mt-8 p-4 rounded-lg" :class="currentTheme === 'light-theme' ? 'bg-gray-100' : 'bg-gray-800'">
        <h3 class="text-xl font-bold mb-4">Contributors</h3>
        <div class="grid grid-cols-3 gap-4">
          <div v-for="contributor in contributors" :key="contributor.name" class="flex flex-col items-center">
            <a :href="contributor.github" target="_blank" rel="noopener noreferrer">
              <img :src="contributor.logo" :alt="contributor.name" class="w-16 h-16 rounded-full mb-2">
            </a>
            <span class="font-semibold">{{ contributor.name }}</span>
            <span class="text-sm text-gray-500 mt-1">{{ contributor.details }}</span>
          </div>
        </div>
      </div>
    </div>
</template>
  
  <script setup>
  import { ref, inject } from 'vue'
  import { useSound } from './sounds'
  const { sendInteractionToClient } = useSound()
  
  const currentTheme = inject('theme')
  
  const settings = ref({
    emailNotifications: true,
    language: 'en'
  })

  const contributors = [
  { name: 'Mustache Dom', logo: '/public/img/md.png', github: 'https://github.com/mustachedom', details: 'Backend Developer' },
  { name: 'Maji', logo: '/public/img/maji.png', github: 'https://github.com/majisp', details: 'Frontend Developer' },
]
  
  const changeTheme = (newTheme) => {
    currentTheme.value = newTheme
  }
  </script>
  