<template>
    <div class="home-page overflow-y-auto h-full">
      <h2 class="text-3xl font-bold mb-6">Employee of the Month</h2>
      <div v-if="employeeOfTheMonth" class="employee-of-month">
      <img :src="employeeOfTheMonth.image" alt="Employee of the Month" class="rounded-lg shadow-lg" />
      <h3 class="employee-name mt-4">{{ employeeOfTheMonth.name }}</h3>
      </div>
      <button v-if="isBoss" @click="toggleEmployeeSelection()" class="select-employee-btn">
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
          <input v-model="imageUrl" placeholder="Enter image URL" class="image-url-input input-field mb-2" />
          <button @click="setImageUrl()" class="set-image-btn setting-button w-full mb-2">Set Image</button>
          <button @click="confirmSelection(); toggleEmployeeSelection()" class="confirm-btn">Confirm</button>
        </div>
      </transition>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
  
const props = defineProps(['isBoss', 'employees'])
  
const employeeOfTheMonth = ref(null)
const selectedEmployee = ref(null)
const isSelectionExpanded = ref(false)
const imageUrl = ref('')
  
const toggleEmployeeSelection = () => {
  isSelectionExpanded.value = !isSelectionExpanded.value
}

const setImageUrl = () => {
  if (imageUrl.value) {
    employeeOfTheMonth.value = {
      ...employeeOfTheMonth.value,
      image: imageUrl.value
    }
  }
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
  if (selectedEmployee.value && employeeOfTheMonth.value?.image) {
    fetch(`https://${GetParentResourceName()}/setEmployeeOfTheMonth`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: selectedEmployee.value.name,
        image: employeeOfTheMonth.value.image
      })
    })
  }
}

onMounted(() => {
  window.addEventListener('message', (event) => {
    if (event.data.action === 'setEmployeeOfTheMonth') {
      console.log("Received employee of the month data:", event.data.data);
      if (event.data.data && event.data.data.name && event.data.data.image) {
        employeeOfTheMonth.value = {
          name: event.data.data.name,
          image: event.data.data.image
        };
      } else {
        console.log("No valid employee of the month data received");
      }
    }
  });

  fetch(`https://${GetParentResourceName()}/getEmployeeOfTheMonth`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  });
});
</script>
