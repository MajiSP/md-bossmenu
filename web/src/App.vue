<template>
  <div id="app">
    <Main />
  </div>
</template>

<script setup>
import Main from './components/Main.vue'
import { onMounted } from 'vue'
import { userState } from './userState'

onMounted(() => {
  window.addEventListener('message', (event) => {
    if (event.data.action === 'setCurrentUser') {
      userState.setUser(event.data.username, event.data.job)
    }
  })
})
</script>
