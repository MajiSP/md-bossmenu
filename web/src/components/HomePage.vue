<template>
    <div class="home-page">
      <h2 class="text-3xl font-bold mb-6">Employee of the Month</h2>
      <div v-if="employeeOfTheMonth" class="employee-of-month">
        <img :src="employeeOfTheMonth.image" alt="Employee of the Month" class="rounded-lg shadow-lg" />
        <h3 class="employee-name mt-4">{{ employeeOfTheMonth.name }}</h3>
      </div>
      <button v-if="isBoss" @click="toggleEmployeeSelection" class="select-employee-btn">
        {{ isSelectionExpanded ? 'Hide Selection' : 'Select Employee of the Month' }}
        <font-awesome-icon :icon="isSelectionExpanded ? 'chevron-up' : 'chevron-down'" class="ml-2" />
      </button>
      <transition name="expand">
        <div v-if="isSelectionExpanded" class="employee-selection">
          <select v-model="selectedEmployee" class="employee-select">
            <option v-for="employee in employees" :key="employee.id" :value="employee">
              {{ employee.name }}
            </option>
          </select>
          <button @click="uploadImage" class="upload-btn">Upload Image</button>
          <button @click="confirmSelection" class="confirm-btn">Confirm</button>
        </div>
      </transition>
    </div>
  </template>
  
  <script setup>
  import { ref } from 'vue'
  
  const props = defineProps(['isBoss', 'employees'])
  
  const employeeOfTheMonth = ref(null)
  const selectedEmployee = ref(null)
  const isSelectionExpanded = ref(false)
  
  const toggleEmployeeSelection = () => {
    isSelectionExpanded.value = !isSelectionExpanded.value
  }
  
  const uploadImage = () => {
    fetch(`https://${GetParentResourceName()}/captureScreenshot`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    })
    .then(response => response.text())
    .then(text => {
      try {
        const data = JSON.parse(text);
        if (data.url) {
          employeeOfTheMonth.value = {
            ...employeeOfTheMonth.value,
            image: data.url
          };
        }
      } catch (error) {
        console.error('Error parsing response:', text);
      }
    })
    .catch(error => {
      console.error('Error uploading image:', error);
    });
  }
  
  const confirmSelection = () => {
    if (selectedEmployee.value) {
      employeeOfTheMonth.value = {
        name: selectedEmployee.value.name,
        image: employeeOfTheMonth.value?.image || 'default_image_path'
      }
      isSelectionExpanded.value = false
    }
  }
  </script>
  