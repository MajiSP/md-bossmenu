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
    <div class="setting-section">
      <h3 class="text-xl mb-4">Profile Image</h3>
      <div class="flex flex-col space-y-4">
        <img :src="currentUserImage" alt="User Avatar" class="w-16 h-16 rounded-full object-cover mx-auto">
        <input v-model="newImageUrl" placeholder="Paste image URL here"
              class="input-field w-full p-2 rounded transition-colors duration-200 text-center">
        <button @click="updateUserImage"
                class="setting-button px-4 py-2 rounded transition-colors duration-200 font-medium">
          Update
        </button>
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
import { ref, inject, onMounted, watch, computed } from 'vue'
import { userState } from '../userState'
const newImageUrl = ref('')

const props = defineProps({
  activePage: String
})

const updateUserImage = () => {
if (newImageUrl.value) {
  if (newImageUrl.value.includes('tenor.com')) {
    alert('Tenor GIFs are not supported. Please use a different image hosting service.');
    return;
  }

  fetch(`https://${GetParentResourceName()}/updateUserImage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ imageUrl: newImageUrl.value })
  })
  .then(response => response.json())
  .then(data => {
    userState.setUserImage(newImageUrl.value);
    newImageUrl.value = '';
  })
  .catch(error => {
    console.error('Error updating image:', error);
  });
}
};

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

const currentTheme = inject('theme')

const settings = ref({
emailNotifications: true,
language: 'en'
})

const currentUserImage = computed(() => userState.userImage)

const contributors = [
{ name: 'Mustache Dom', logo: './img/md.png', github: 'https://github.com/mustachedom', details: 'Backend Developer' },
{ name: 'Maji', logo: './img/maji.png', github: 'https://github.com/majisp', details: 'Frontend Developer' },
{ name: 'Alex Skies', logo: './img/alex.png', github: 'https://github.com/alexskiesrp', details: 'Graphic Designer' },
]

const changeTheme = (newTheme) => {
currentTheme.value = newTheme
}

watch(() => userState.userImage, (newImage) => {
  if (newImage) {
    forceRender.value += 1
  }
})

const isSettingsActive = computed(() => props.activePage === 'Settings')

watch(isSettingsActive, (newValue) => {
  if (newValue) {
    fetchUserImage()
  }
}, { immediate: true })
</script>
