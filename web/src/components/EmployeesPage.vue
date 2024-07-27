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
            <th class="text-left p-2 min-w-[100px]">On Duty</th>
            <th class="text-left p-2 min-w-[100px]">Duty Time</th>
            <th class="text-center p-2 min-w-[80px]">Actions</th>
          </tr>
        </thead>
        <tbody class="min-h-[350px]">
          <template v-for="employee in filteredEmployees" :key="employee.id">
            <tr @click="toggleEmployeeDetails(employee)" class="border-t border-gray-700 cursor-pointer">
              <td class="p-2">
                <select v-model="employee.grade" class="bg-gray-700 rounded p-1 appearance-none focus:outline-none select-none focus:ring-0 focus:border-gray-700">
                  <option v-for="grade in sortedGrades" :key="grade.level" :value="grade.name">{{ grade.name }}</option>
                </select>
              </td>
              <td class="p-2">{{ employee.name }}</td>
              <td class="p-2">${{ salaries[employee.grade] ? salaries[employee.grade].toLocaleString() : 'N/A' }}</td>
              <td class="p-2">
                <font-awesome-icon v-if="employee.onDuty" icon="check-circle" class="text-green-500" />
                <font-awesome-icon v-else icon="times-circle" class="text-red-500" />
              </td>
              <td class="p-2">{{ formatDutyTime(employee.dutyTime) }}</td>
              <td class="p-2 text-center">
                <button @click="confirmFire(employee)" class="text-red-500">
                  <font-awesome-icon icon="trash" />
                </button>
              </td>
            </tr>
            <tr v-if="employee.showDetails" class="border-t border-gray-700">
              <td colspan="6" class="p-4">
                <div ref="historyRef" :style="{ maxHeight: employee.showDetails ? historyHeight + 'px' : '0' }" class="overflow-hidden transition-all duration-300">
                  <div>
                    <h4 class="font-bold mb-3">Duty History</h4>
                    <ul class="space-y-2">
                      <li v-for="(entry, index) in employee.dutyHistory" :key="index" class="flex items-center">
                        <span :class="['w-4 h-4 rounded-full mr-3', entry.action === 'Clocked In' ? 'bg-green-500' : 'bg-red-500']"></span>
                        <span class="font-medium mr-2">{{ entry.action }}:</span>
                        <span class="text-gray-400">{{ formatHistoryEntry(entry) }}</span>
                      </li>
                    </ul>
                  </div>
                </div>
              </td>
            </tr>
          </template>
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
import { ref, computed, nextTick } from 'vue'
import { formatDistanceToNow } from 'date-fns'

const currentTheme = ref('dark-theme')

const employees = ref([])
const grades = ref([])
const salaries = ref({})

const searchQuery = ref('')
const sortKey = ref('grade')
const sortOrder = ref('asc')
const showConfirmation = ref(false)
const employeeToFire = ref(null)
const historyRef = ref(null)
const historyHeight = ref(0)

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

const toggleEmployeeDetails = async (employee) => {
  employee.showDetails = !employee.showDetails
  await nextTick()
  if (employee.showDetails) {
    historyHeight.value = historyRef.value.scrollHeight
  } else {
    historyHeight.value = 0
  }
}

const formatDutyTime = (dutyTime) => {
  return formatDistanceToNow(new Date(dutyTime), { addSuffix: true })
}

const formatHistoryEntry = (entry) => {
  return `${entry.action} at ${new Date(entry.timestamp).toLocaleString()}`
}

const confirmFire = (employee) => {
  employeeToFire.value = employee
  showConfirmation.value = true
}

const fireEmployee = () => {
  showConfirmation.value = false
}
</script>
