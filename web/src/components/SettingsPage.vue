<template>
    <div class="settings-container">
      <h2 class="text-2xl font-bold mb-6">Settings</h2>
      
      <div class="grid grid-cols-2 gap-6">
        <div class="setting-section">
          <h3 class="text-xl mb-4">Theme</h3>
          <div class="flex space-x-4">
            <button 
                @click="changeTheme('light-theme')"
                :class="['setting-button px-4 py-2 rounded', currentTheme === 'light-theme' ? 'active' : '']"
                >
                Light
                </button>
                <button 
                @click="changeTheme('dark-theme')"
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
    </div>
  </template>
  
  <script setup>
  import { ref, inject } from 'vue'
  
  const currentTheme = inject('theme')
  
  const settings = ref({
    emailNotifications: true,
    language: 'en'
  })
  
  const changeTheme = (newTheme) => {
    currentTheme.value = newTheme
  }
  </script>
  