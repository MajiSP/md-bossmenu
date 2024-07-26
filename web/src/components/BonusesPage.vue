<template>
  <div class="bonuses-container">
    <h2 class="text-2xl font-bold mb-6">Employee Bonuses</h2>
    <table class="w-full border-collapse">
      <thead>
        <tr>
          <th class="text-left p-2">Employee</th>
          <th class="text-left p-2">Current Salary</th>
          <th class="text-left p-2">Bonus Amount</th>
          <th class="text-center p-2">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="employee in employees" :key="employee.id" class="border-t border-gray-700">
          <td class="p-2">{{ employee.name }}</td>
          <td class="p-2">${{ employee.salary }}</td>
          <td class="p-2">
            <input 
              v-model="employee.bonusAmount" 
              :id="'bonus-' + employee.id" 
              type="number" 
              class="bg-gray-700 rounded p-1 w-24 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none" 
              min="0"
            >
          </td>
          <td class="p-2 text-center">
            <button @click="confirmBonus(employee)" class="px-2 py-1 rounded" :class="[employee.bonusAmount > 0 ? 'bg-green-500 text-white hover:bg-green-600' : 'bg-gray-400 text-gray-600 cursor-not-allowed']" :disabled="employee.bonusAmount <= 0">Pay Bonus</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="showConfirmation" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div :class="['p-6 rounded', currentTheme === 'light-theme' ? 'bg-white text-gray-800' : 'bg-gray-800 text-white']">
        <p>Are you sure you want to pay a bonus of ${{ selectedEmployee?.bonusAmount }} to {{ selectedEmployee?.name }}?</p>
        <div class="mt-4 flex justify-end">
          <button @click="payBonus" class="bg-green-500 text-white px-4 py-2 rounded mr-2">Yes</button>
          <button @click="showConfirmation = false" class="bg-gray-500 text-white px-4 py-2 rounded">No</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, inject } from 'vue'

const employees = inject('employees')
const currentTheme = inject('theme')

const showConfirmation = ref(false)
const selectedEmployee = ref(null)

const confirmBonus = (employee) => {
  if (employee.bonusAmount > 0) {
    selectedEmployee.value = employee
    showConfirmation.value = true
  }
}

const payBonus = () => {
  fetch(`https://${GetParentResourceName()}/payBonus`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify({
      employeeId: selectedEmployee.value.id,
      amount: selectedEmployee.value.bonusAmount
    }),
  }).then(() => {
    showConfirmation.value = false
    selectedEmployee.value.bonusAmount = 0
    selectedEmployee.value = null
  })
}
</script>
