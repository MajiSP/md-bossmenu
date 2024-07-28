<template>
  <div class="statistics-container">
    <h2 class="text-2xl font-bold mb-6 text-center">Statistics</h2>
    <div class="grid grid-cols-1 gap-6">
      <div :class="['p-6 rounded-lg flex flex-col items-center justify-center', currentTheme === 'light-theme' ? 'bg-white' : 'bg-gray-800']" style="height: 400px;">
        <h3 class="text-xl mb-4">Cost to Profit Ratio</h3>
        <div style="width: 300px; height: 300px;">
          <ChartComponent type="doughnut" :data="costProfitData" :options="chartOptions" />
        </div>
      </div>
      <div :class="['p-6 rounded-lg', currentTheme === 'light-theme' ? 'bg-white' : 'bg-gray-800']">
        <h3 class="text-xl mb-4">Income and Spending</h3>
        <ul>
          <li v-for="(item, index) in financialItems" :key="index" class="flex justify-between mb-2">
            <span>{{ item.name }}</span>
            <span :class="item.type === 'income' ? 'text-green-500' : 'text-red-500'">
              {{ item.type === 'income' ? '+' : '-' }} ${{ item.amount }}
            </span>
          </li>
        </ul>
        <div class="mt-4 pt-4 border-t border-gray-600 flex justify-between">
          <span>Total Difference:</span>
          <span :class="totalDifference >= 0 ? 'text-green-500' : 'text-red-500'">
            {{ totalDifference >= 0 ? '+' : '-' }} ${{ Math.abs(totalDifference) }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, inject } from 'vue'
import Chart from 'chart.js/auto'
import { Chart as ChartComponent } from 'vue-chartjs'
import { useSound } from './sounds'
const { sendInteractionToClient } = useSound()

const currentTheme = inject('theme')

const costProfitData = ref({
  labels: ['Cost', 'Profit'],
  datasets: [{
    data: [30, 70],
    backgroundColor: ['#FF6384', '#36A2EB'],
    hoverBackgroundColor: ['#FF6384', '#36A2EB']
  }]
})

const chartOptions = {
  responsive: true,
  maintainAspectRatio: true,
  plugins: {
    legend: {
      position: 'bottom',
    },
  },
}

const currentMoney = 10000

const financialItems = ref([
  { name: 'Sales Revenue', type: 'income', amount: 5000 },
  { name: '1of1 Servers', type: 'spending', amount: 29384 },
  { name: 'Rent', type: 'spending', amount: 1500 },
  { name: 'Salaries', type: 'spending', amount: 3000 },
  { name: 'Utilities', type: 'spending', amount: 500 },
])

const totalDifference = computed(() => {
  const spent = financialItems.value.reduce((acc, item) => {
    return item.type === 'income' ? acc + item.amount : acc - item.amount
  }, 0)
  return spent - currentMoney
})
</script>
