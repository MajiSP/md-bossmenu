<template>
  <div class="employees-container">
    <h2 class="text-2xl font-bold mb-6">Employees</h2>
    <input 
      v-model="searchQuery" 
      placeholder="Search employees..." 
      :class="['mb-4 p-2 rounded max-w-md', currentTheme === 'light-theme' ? 'bg-white border border-gray-300 text-gray-700' : 'bg-gray-700']"
    >
    <div class="h-[385px] overflow-y-auto">
      <table class="w-full border-collapse">
        <thead>
          <tr>
            <th @click="sort('grade')" class="text-left p-2 cursor-pointer min-w-[100px]">
              <div class="flex items-center">
                <span class="mr-2">Grade</span>
                <span class="w-4">
                  <font-awesome-icon v-if="sortKey === 'grade'" :icon="sortOrder === 'asc' ? 'arrow-up' : 'arrow-down'" />
                </span>
              </div>
            </th>
            <th @click="sort('name')" class="text-left p-2 cursor-pointer min-w-[150px]">
              <div class="flex items-center">
                <span class="mr-2">Name</span>
                <span class="w-4">
                  <font-awesome-icon v-if="sortKey === 'name'" :icon="sortOrder === 'asc' ? 'arrow-up' : 'arrow-down'" />
                </span>
              </div>
            </th>
            <th @click="sort('salary')" class="text-left p-2 cursor-pointer min-w-[100px]">
              <div class="flex items-center">
                <span class="mr-2">Salary</span>
                <span class="w-4">
                  <font-awesome-icon v-if="sortKey === 'salary'" :icon="sortOrder === 'asc' ? 'arrow-up' : 'arrow-down'" />
                </span>
              </div>
            </th>
            <th class="text-center p-2 min-w-[80px]">Actions</th>
          </tr>
        </thead>
          <tbody class="min-h-[350px]">
            <tr v-for="employee in filteredEmployees" :key="employee.id" class="border-t border-gray-700">
              <td class="p-2">
                <select v-model="employee.grade" class="bg-gray-700 rounded p-1 appearance-none focus:outline-none select-none focus:ring-0 focus:border-gray-700">
                  <option v-for="grade in sortedGrades" :key="grade.level" :value="grade.name">{{ grade.name }}</option>
                </select>
              </td>
              <td class="p-2">{{ employee.name }}</td>
              <td class="p-2">${{ salaries[employee.grade] ? salaries[employee.grade].toLocaleString() : 'N/A' }}</td>
              <td class="p-2 text-center">
                <button @click="confirmFire(employee)" class="text-red-500">
                  <font-awesome-icon icon="trash" />
                </button>
              </td>
            </tr>
          </tbody>
      </table>
    </div>
    <div v-if="showConfirmation" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div :class="['p-6 rounded', currentTheme === 'light-theme' ? 'bg-white text-gray-800' : 'bg-gray-800 text-white']">
        <p>Are you sure you want to fire this employee?</p>
        <div class="mt-4 flex justify-end">
          <button @click="fireEmployee" class="bg-red-500 text-white px-4 py-2 rounded mr-2">Yes</button>
          <button @click="showConfirmation = false" class="bg-gray-500 text-white px-4 py-2 rounded">No</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, inject, computed } from 'vue'

const employees = inject('employees')
const grades = inject('grades')
const salaries = inject('salaries')
const currentTheme = inject('theme')

const searchQuery = ref('')
const sortKey = ref('grade')
const sortOrder = ref('asc')
const showConfirmation = ref(false)
const employeeToFire = ref(null)

const sortedGrades = computed(() => {
  return [...grades.value].sort((a, b) => a.level - b.level)
})

const filteredEmployees = computed(() => {
  return employees.value
    .filter(emp => emp.name.toLowerCase().includes(searchQuery.value.toLowerCase()))
    .sort((a, b) => {
      let modifier = sortOrder.value === 'asc' ? 1 : -1
      if (a[sortKey.value] < b[sortKey.value]) return -1 * modifier
      if (a[sortKey.value] > b[sortKey.value]) return 1 * modifier
      return 0
    })
})

const sort = (key) => {
  if (key === sortKey.value) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortKey.value = key
    sortOrder.value = 'asc'
  }
}

const confirmFire = (employee) => {
  employeeToFire.value = employee
  showConfirmation.value = true
}

const fireEmployee = () => {
  fetch(`https://${GetParentResourceName()}/fireEmployee`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify({
      employeeId: employeeToFire.value.id
    }),
  }).then(() => {
    employees.value = employees.value.filter(emp => emp.id !== employeeToFire.value.id)
    showConfirmation.value = false
  })
}
</script>
