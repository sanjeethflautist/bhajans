<template>
  <div class="max-w-7xl mx-auto">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Admin Dashboard</h1>
      <p class="text-gray-600">
        Overview and management tools
      </p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      <p class="mt-4 text-gray-600">Loading dashboard...</p>
    </div>

    <!-- Dashboard Content -->
    <div v-else>
      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <!-- Approved Bhajans -->
        <div class="card bg-green-50 border border-green-200">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-green-700 mb-1">Approved</p>
              <p class="text-3xl font-bold text-green-900">{{ stats.approved_count || 0 }}</p>
            </div>
            <div class="text-4xl">✓</div>
          </div>
        </div>

        <!-- Pending Reviews -->
        <div class="card bg-yellow-50 border border-yellow-200">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-yellow-700 mb-1">Pending Review</p>
              <p class="text-3xl font-bold text-yellow-900">{{ stats.pending_review_count || 0 }}</p>
            </div>
            <div class="text-4xl">⏳</div>
          </div>
        </div>

        <!-- Open Reports -->
        <div class="card bg-red-50 border border-red-200">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-red-700 mb-1">Open Reports</p>
              <p class="text-3xl font-bold text-red-900">{{ stats.open_reports_count || 0 }}</p>
            </div>
            <div class="text-4xl">⚠️</div>
          </div>
        </div>

        <!-- Total Users -->
        <div class="card bg-blue-50 border border-blue-200">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-blue-700 mb-1">Total Users</p>
              <p class="text-3xl font-bold text-blue-900">{{ stats.total_users || 0 }}</p>
            </div>
            <div class="text-4xl">👥</div>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <!-- Review Queue -->
        <div class="card hover:shadow-lg transition-shadow cursor-pointer" @click="goToReviewQueue">
          <h3 class="text-xl font-bold text-gray-900 mb-2">Review Queue</h3>
          <p class="text-gray-600 mb-4">
            {{ stats.pending_review_count || 0 }} bhajan(s) waiting for review
          </p>
          <button class="btn-primary">
            Go to Review Queue →
          </button>
        </div>

        <!-- Reports Management -->
        <div class="card hover:shadow-lg transition-shadow cursor-pointer" @click="goToReports">
          <h3 class="text-xl font-bold text-gray-900 mb-2">Reports Management</h3>
          <p class="text-gray-600 mb-4">
            {{ stats.open_reports_count || 0 }} open report(s) need attention
          </p>
          <button class="btn-primary">
            Manage Reports →
          </button>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="card">
        <h3 class="text-xl font-bold text-gray-900 mb-4">Recent Activity</h3>
        
        <div v-if="loadingActivity" class="text-center py-8 text-gray-500">
          Loading activity...
        </div>

        <div v-else-if="recentActivity.length === 0" class="text-center py-8 text-gray-500">
          No recent activity
        </div>

        <div v-else class="space-y-3">
          <div
            v-for="activity in recentActivity"
            :key="activity.id"
            class="flex items-start gap-4 p-3 bg-gray-50 rounded-lg"
          >
            <div class="flex-1">
              <p class="text-sm font-medium text-gray-900">
                {{ activity.user?.email || 'Unknown' }}
                <span class="text-gray-600">{{ formatAction(activity.action) }}</span>
                <span class="font-medium">{{ activity.entity_type }}</span>
              </p>
              <p class="text-xs text-gray-500 mt-1">
                {{ formatDate(activity.created_at) }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- User Management Section -->
      <div class="card mt-6">
        <h3 class="text-xl font-bold text-gray-900 mb-4">User Management</h3>
        
        <div v-if="loadingUsers" class="text-center py-8 text-gray-500">
          Loading users...
        </div>

        <div v-else-if="users.length === 0" class="text-center py-8 text-gray-500">
          No users found
        </div>

        <div v-else class="overflow-x-auto">
          <table class="w-full">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Joined</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <tr v-for="user in users" :key="user.id">
                <td class="px-4 py-3 text-sm text-gray-900">{{ user.email }}</td>
                <td class="px-4 py-3 text-sm">
                  <span
                    :class="[
                      'px-2 py-1 rounded-full text-xs font-medium',
                      user.role === 'admin' ? 'bg-purple-100 text-purple-700' :
                      user.role === 'editor' ? 'bg-blue-100 text-blue-700' :
                      'bg-gray-100 text-gray-700'
                    ]"
                  >
                    {{ user.role }}
                  </span>
                </td>
                <td class="px-4 py-3 text-sm text-gray-500">
                  {{ formatDate(user.created_at) }}
                </td>
                <td class="px-4 py-3 text-sm">
                  <select
                    v-if="user.id !== authStore.user?.id"
                    :value="user.role"
                    @change="updateUserRole(user.id, $event.target.value)"
                    class="text-sm border-gray-300 rounded"
                  >
                    <option value="user">User</option>
                    <option value="editor">Editor</option>
                    <option value="admin">Admin</option>
                  </select>
                  <span v-else class="text-gray-500 text-xs">You</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { adminService } from '@/services/adminService'
import { useAuthStore } from '@/stores/authStore'

const router = useRouter()
const authStore = useAuthStore()

const loading = ref(true)
const loadingActivity = ref(true)
const loadingUsers = ref(true)
const stats = ref({})
const recentActivity = ref([])
const users = ref([])

function goToReviewQueue() {
  router.push('/admin/review-queue')
}

function goToReports() {
  router.push('/admin/reports')
}

async function updateUserRole(userId, newRole) {
  if (!confirm(`Change user role to ${newRole}?`)) {
    return
  }

  const result = await authStore.updateUserRole(userId, newRole)
  
  if (result.success) {
    await fetchUsers()
    alert('User role updated successfully')
  } else {
    alert('Failed to update user role: ' + result.error)
  }
}

function formatAction(action) {
  const actions = {
    create: 'created a',
    update: 'updated a',
    delete: 'deleted a',
    approve: 'approved a',
    reject: 'rejected a',
    create_report: 'reported a'
  }
  return actions[action] || action
}

function formatDate(dateString) {
  if (!dateString) return ''
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now - date
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)

  if (diffMins < 1) return 'Just now'
  if (diffMins < 60) return `${diffMins}m ago`
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays < 7) return `${diffDays}d ago`
  
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  })
}

async function fetchStats() {
  const { data, error } = await adminService.getDashboardStats()
  if (!error && data) {
    stats.value = data
  }
}

async function fetchActivity() {
  loadingActivity.value = true
  const { data, error } = await adminService.getRecentActivity(10)
  if (!error && data) {
    recentActivity.value = data
  }
  loadingActivity.value = false
}

async function fetchUsers() {
  loadingUsers.value = true
  const { data, error } = await adminService.getAllUsers({ limit: 50 })
  if (!error && data) {
    users.value = data
  }
  loadingUsers.value = false
}

onMounted(async () => {
  await Promise.all([
    fetchStats(),
    fetchActivity(),
    fetchUsers()
  ])
  loading.value = false
})
</script>
