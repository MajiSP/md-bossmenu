<template>
  <div class="employees-container relative">
    <button @click="openHireModal" class="absolute top-0 right-0 bg-blue-500 text-white px-4 py-2 rounded">
      Hire New Employee
    </button>
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
            <th @click="sort('onDuty')" class="text-left p-2 cursor-pointer min-w-[100px]">
              <div class="flex items-center">
                <span class="mr-2">On Duty</span>
                <span class="w-4">
                  <font-awesome-icon v-if="sortKey === 'onDuty'" :icon="sortOrder === 'asc' ? 'arrow-up' : 'arrow-down'" />
                </span>
              </div>
            </th>
            <th @click="sort('dutyTime')" class="text-left p-2 cursor-pointer min-w-[100px]">
              <div class="flex items-center">
                <span class="mr-2">Duty Time</span>
                <span class="w-4">
                  <font-awesome-icon v-if="sortKey === 'dutyTime'" :icon="sortOrder === 'asc' ? 'arrow-up' : 'arrow-down'" />
                </span>
              </div>
            </th>
            <th @click="sort('recentActivity')" class="text-left p-2 cursor-pointer min-w-[150px]">
              <div class="flex items-center">
                <span class="mr-2">Recent Activity</span>
                <span class="w-4">
                  <font-awesome-icon v-if="sortKey === 'recentActivity'" :icon="sortOrder === 'asc' ? 'arrow-up' : 'arrow-down'" />
                </span>
              </div>
            </th>
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
              <td class="p-2">{{ getMostRecentDutyLog(employee) }}</td>
              <td class="p-2 text-center">
                <button @click.stop="confirmFire(employee)" class="text-red-500">
                  <font-awesome-icon icon="trash" />
                </button>
              </td>
            </tr>
            <tr v-if="employee.showDetails" class="border-t border-gray-700" :data-employee-id="employee.id">
              <td colspan="7" class="p-4">
                <div class="duty-history-content overflow-hidden transition-all duration-300" :style="{ maxHeight: employee.showDetails ? historyHeight + 'px' : '0' }">
                  <div>
                    <h4 class="font-bold mb-3">Duty History</h4>
                    <ul v-if="employee.dutyHistory && employee.dutyHistory.length > 0" class="space-y-2">
                      <li v-for="(entry, index) in employee.dutyHistory" :key="index" class="flex items-center">
                        <span :class="['w-4 h-4 rounded-full mr-3', entry.action === 'Clocked In' ? 'bg-green-500' : 'bg-red-500']"></span>
                        <span class="font-medium mr-2">{{ entry.action }}:</span>
                        <span class="text-gray-400">{{ formatHistoryEntry(entry) }}</span>
                      </li>
                    </ul>
                    <p v-else class="text-gray-500">No duty history available.</p>
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
    <div v-if="showHireModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div :class="['hire-modal p-6 rounded-lg w-96', currentTheme]">
        <h3 class="text-xl font-bold mb-4">Hire New Employee</h3>
        <input v-model="hireSearchQuery" placeholder="Search players..." class="w-full p-2 border rounded mb-4">
        <ul class="max-h-60 overflow-y-auto">
          <li v-for="player in filteredPlayers" :key="player.citizenid" class="p-2 hover:bg-opacity-10 cursor-pointer" @click="hirePlayer(player)">
            {{ player.firstname }} {{ player.lastname }}
          </li>
        </ul>
        <button @click="closeHireModal" class="mt-4 bg-gray-500 text-white px-4 py-2 rounded">Close</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, inject, nextTick, onMounted } from 'vue'
import { formatDistanceToNow } from 'date-fns'

const currentTheme = inject('theme')

const employees = inject('employees')
const grades = inject('grades')
const salaries = inject('salaries')

const searchQuery = ref('')
const sortKey = ref('grade')
const sortOrder = ref('asc')
const showConfirmation = ref(false)
const employeeToFire = ref(null)
const historyRef = ref(null)
const historyHeight = ref(0)

const hireSearchQuery = ref('')
const showHireModal = ref(false)
const players = ref([])

const sortedGrades = computed(() => {
  return [...grades.value].sort((a, b) => a.level - b.level)
})

const openHireModal = async () => {
  showHireModal.value = true
  await fetch(`https://${GetParentResourceName()}/getPlayers`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  })
}

const closeHireModal = () => {
  showHireModal.value = false
  searchQuery.value = ''
}

const filteredPlayers = computed(() => {
  if (!Array.isArray(players.value)) return []
  return players.value.filter(player => {
    const fullName = `${player.firstname} ${player.lastname}`.toLowerCase()
    return fullName.includes(hireSearchQuery.value.toLowerCase())
  })
})

const hirePlayer = async (player) => {
  const response = await fetch(`https://${GetParentResourceName()}/hireEmployee`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ citizenid: player.citizenid })
  })
}

const filteredEmployees = computed(() => {
  return employees.value
    .filter(emp => emp.name.toLowerCase().includes(searchQuery.value.toLowerCase()))
    .sort((a, b) => {
      let modifier = sortOrder.value === 'asc' ? 1 : -1
      switch (sortKey.value) {
        case 'onDuty':
          return (a.onDuty === b.onDuty) ? 0 : a.onDuty ? -1 * modifier : 1 * modifier
        case 'dutyTime':
          return (a.dutyTime - b.dutyTime) * modifier
        case 'recentActivity':
          const aRecent = a.dutyHistory[a.dutyHistory.length - 1]
          const bRecent = b.dutyHistory[b.dutyHistory.length - 1]
          return (aRecent.timestamp - bRecent.timestamp) * modifier
        default:
          if (a[sortKey.value] < b[sortKey.value]) return -1 * modifier
          if (a[sortKey.value] > b[sortKey.value]) return 1 * modifier
          return 0
      }
    })
})

const getMostRecentDutyLog = computed(() => {
  return (employee) => {
    if (employee.dutyHistory && employee.dutyHistory.length > 0) {
      const mostRecent = employee.dutyHistory[employee.dutyHistory.length - 1];
      return `${mostRecent.action} ${formatDistanceToNow(new Date(mostRecent.timestamp * 1000), { addSuffix: true })}`;
    }
    return 'No recent duty log';
  };
});

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
    const historyElement = document.querySelector(`[data-employee-id="${employee.id}"] .duty-history-content`)
    historyHeight.value = historyElement ? historyElement.scrollHeight : 0
  } else {
    historyHeight.value = 0
  }
}

const updateDutyStatus = (employeeId, onDuty) => {
  const employee = employees.value.find(emp => emp.id === employeeId)
  if (employee) {
    employee.onDuty = onDuty
  }
}

const formatDutyTime = (dutyTime) => {
  if (!dutyTime || isNaN(dutyTime)) return 'N/A'
  return formatDistanceToNow(new Date(dutyTime * 1000), { addSuffix: true })
}

const formatHistoryEntry = (entry) => {
  if (!entry || !entry.timestamp || isNaN(entry.timestamp)) return 'Invalid entry'
  return `${entry.action} at ${new Date(entry.timestamp * 1000).toLocaleString()}`
}

const confirmFire = (employee) => {
  employeeToFire.value = employee
  showConfirmation.value = true
}

const fireEmployee = () => {
  showConfirmation.value = false
}

const refreshEmployees = async () => {
  try {
    const response = await fetch(`https://${GetParentResourceName()}/refreshEmployees`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    })
    const text = await response.text()
    if (text) {
      const updatedEmployees = JSON.parse(text)
      employees.value = updatedEmployees
    } else {
    }
  } catch (error) {
    console.error('Error refreshing employees:', error)
  }
}


onMounted(() => {
  window.addEventListener('message', (event) => {
    if (event.data.action === "setPlayers") {
      players.value = event.data.players
    } else if (event.data.action === "updateDutyStatus") {
      updateDutyStatus(event.data.employeeId, event.data.onduty)
    } else if (event.data.action === "hireResult") {
      if (event.data.result.success) {
        refreshEmployees()
        closeHireModal()
      } else {
        console.error('Failed to hire employee:', event.data.result.error)
      }
    }
  })
})

</script>
