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
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6 mb-8">
        <!-- Approved Bhajans -->
        <div 
          @click="goToApprovedBhajans"
          class="card bg-green-50 border border-green-200 cursor-pointer hover:shadow-lg transition-shadow"
        >
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-green-700 mb-1">Approved</p>
              <p class="text-3xl font-bold text-green-900">{{ stats.approved_count || 0 }}</p>
            </div>
            <div class="text-4xl">✓</div>
          </div>
        </div>

        <!-- Pending Reviews -->
        <div 
          @click="goToReviewQueue"
          class="card bg-yellow-50 border border-yellow-200 cursor-pointer hover:shadow-lg transition-shadow"
        >
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-yellow-700 mb-1">Pending Review</p>
              <p class="text-3xl font-bold text-yellow-900">{{ stats.pending_review_count || 0 }}</p>
            </div>
            <div class="text-4xl">⏳</div>
          </div>
        </div>

        <!-- Archived Bhajans -->
        <div 
          @click="showArchivedBhajans = !showArchivedBhajans"
          class="card bg-gray-50 border border-gray-200 cursor-pointer hover:shadow-lg transition-shadow"
        >
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-gray-700 mb-1">Archived</p>
              <p class="text-3xl font-bold text-gray-900">{{ archivedBhajansCount }}</p>
            </div>
            <div class="text-4xl">📦</div>
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

      <!-- Archived Bhajans Section (Collapsible) -->
      <div v-if="showArchivedBhajans" class="card mb-8">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-xl font-bold text-gray-900">Archived Bhajans</h3>
          <button @click="showArchivedBhajans = false" class="text-gray-500 hover:text-gray-700">
            ✕ Close
          </button>
        </div>
        
        <div v-if="loadingArchivedBhajans" class="text-center py-8 text-gray-500">
          Loading archived bhajans...
        </div>

        <div v-else-if="archivedBhajans.length === 0" class="text-center py-8 text-gray-500">
          No archived bhajans
        </div>

        <div v-else class="space-y-3">
          <div
            v-for="bhajan in archivedBhajans"
            :key="bhajan.id"
            class="p-4 bg-gray-50 rounded-lg border border-gray-200"
          >
            <div class="flex items-start justify-between mb-2">
              <div>
                <p class="text-sm font-bold text-gray-900">{{ bhajan.title }}</p>
                <p class="text-xs text-gray-500">Archived {{ formatDate(bhajan.updated_at) }}</p>
              </div>
              <span class="px-2 py-1 rounded text-xs font-medium bg-gray-200 text-gray-700">
                {{ bhajan.status }}
              </span>
            </div>
            <p class="text-sm text-gray-700 mb-3 line-clamp-2">{{ bhajan.lyrics }}</p>
            <div class="flex gap-2">
              <button
                @click="restoreBhajan(bhajan.id)"
                class="text-xs px-2 py-1 bg-green-100 text-green-700 rounded hover:bg-green-200"
              >
                Restore to Draft
              </button>
              <button
                @click="permanentlyDeleteBhajan(bhajan.id)"
                class="text-xs px-2 py-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
              >
                Delete Permanently
              </button>
            </div>
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

      <!-- Reviewer Applications Tabs -->
      <div class="card mb-8">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-xl font-bold text-gray-900">Reviewer Applications</h3>
          <div class="flex gap-2">
            <button
              @click="applicationTab = 'pending'"
              :class="[
                'px-3 py-1 text-sm rounded',
                applicationTab === 'pending' 
                  ? 'bg-yellow-100 text-yellow-700 font-medium' 
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              ]"
            >
              Pending ({{ pendingApplications.length }})
            </button>
            <button
              @click="applicationTab = 'approved'"
              :class="[
                'px-3 py-1 text-sm rounded',
                applicationTab === 'approved' 
                  ? 'bg-green-100 text-green-700 font-medium' 
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              ]"
            >
              Approved ({{ approvedApplications.length }})
            </button>
            <button
              @click="applicationTab = 'rejected'"
              :class="[
                'px-3 py-1 text-sm rounded',
                applicationTab === 'rejected' 
                  ? 'bg-red-100 text-red-700 font-medium' 
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              ]"
            >
              Rejected ({{ rejectedApplications.length }})
            </button>
          </div>
        </div>
        
        <div v-if="loadingApplications" class="text-center py-8 text-gray-500">
          Loading applications...
        </div>

        <div v-else-if="currentApplications.length === 0" class="text-center py-8 text-gray-500">
          No {{ applicationTab }} applications
        </div>

        <div v-else class="space-y-4">
          <div
            v-for="app in currentApplications"
            :key="app.id"
            class="p-4 bg-gray-50 rounded-lg border border-gray-200"
          >
            <div class="flex items-start justify-between mb-3">
              <div>
                <p class="text-sm font-bold text-gray-900">{{ app.email }}</p>
                <p class="text-xs text-gray-500">Applied {{ formatDate(app.created_at) }}</p>
              </div>
              <span :class="[
                'px-2 py-1 rounded text-xs font-medium',
                app.status === 'pending' ? 'bg-yellow-100 text-yellow-700' :
                app.status === 'approved' ? 'bg-green-100 text-green-700' :
                'bg-red-100 text-red-700'
              ]">
                {{ app.status }}
              </span>
            </div>
            
            <div class="space-y-2 mb-3">
              <div>
                <p class="text-xs font-medium text-gray-700">Languages:</p>
                <p class="text-sm text-gray-900">{{ app.languages }}</p>
              </div>
              <div>
                <p class="text-xs font-medium text-gray-700">Motivation:</p>
                <p class="text-sm text-gray-900">{{ app.motivation }}</p>
              </div>
              <div>
                <p class="text-xs font-medium text-gray-700">Experience:</p>
                <p class="text-sm text-gray-900">{{ app.experience }}</p>
              </div>
              <div v-if="app.comments">
                <p class="text-xs font-medium text-gray-700">Comments:</p>
                <p class="text-sm text-gray-900">{{ app.comments }}</p>
              </div>
            </div>

            <div v-if="app.status === 'pending'" class="flex gap-2">
              <button
                @click="handleReviewerApplication(app.id, app.user_id, 'approved')"
                class="text-sm px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700"
              >
                Approve
              </button>
              <button
                @click="handleReviewerApplication(app.id, app.user_id, 'rejected')"
                class="text-sm px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700"
              >
                Reject
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Feedback & Feature Requests Tabs -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- Feedback -->
        <div class="card">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-xl font-bold text-gray-900">Feedback</h3>
            <div class="flex gap-2">
              <button
                @click="feedbackTab = 'active'"
                :class="[
                  'px-2 py-1 text-xs rounded',
                  feedbackTab === 'active' 
                    ? 'bg-blue-100 text-blue-700 font-medium' 
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                ]"
              >
                Active ({{ activeFeedback.length }})
              </button>
              <button
                @click="feedbackTab = 'archived'"
                :class="[
                  'px-2 py-1 text-xs rounded',
                  feedbackTab === 'archived' 
                    ? 'bg-gray-200 text-gray-700 font-medium' 
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                ]"
              >
                Archived ({{ archivedFeedback.length }})
              </button>
            </div>
          </div>
          
          <div v-if="loadingFeedback" class="text-center py-8 text-gray-500">
            Loading feedback...
          </div>

          <div v-else-if="currentFeedback.length === 0" class="text-center py-8 text-gray-500">
            No {{ feedbackTab }} feedback
          </div>

          <div v-else class="space-y-3 max-h-96 overflow-y-auto">
            <div
              v-for="item in currentFeedback"
              :key="item.id"
              class="p-3 bg-gray-50 rounded-lg border border-gray-200"
            >
              <div class="flex items-start justify-between mb-2">
                <div>
                  <p class="text-sm font-medium text-gray-900">{{ item.name || 'Anonymous' }}</p>
                  <p class="text-xs text-gray-500">{{ formatDate(item.created_at) }}</p>
                </div>
                <span :class="[
                  'px-2 py-1 rounded text-xs font-medium',
                  item.type === 'bug' ? 'bg-red-100 text-red-700' :
                  item.type === 'improvement' ? 'bg-blue-100 text-blue-700' :
                  item.type === 'compliment' ? 'bg-green-100 text-green-700' :
                  'bg-gray-100 text-gray-700'
                ]">
                  {{ item.type }}
                </span>
              </div>
              <p class="text-sm text-gray-700">{{ item.message }}</p>
              <div class="mt-2 flex gap-2">
                <button
                  v-if="item.status === 'new'"
                  @click="updateFeedbackStatus(item.id, 'reviewed')"
                  class="text-xs px-2 py-1 bg-primary-100 text-primary-700 rounded hover:bg-primary-200"
                >
                  Mark Reviewed
                </button>
                <button
                  v-if="item.status !== 'archived'"
                  @click="updateFeedbackStatus(item.id, 'archived')"
                  class="text-xs px-2 py-1 bg-gray-100 text-gray-700 rounded hover:bg-gray-200"
                >
                  Archive
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Feature Requests -->
        <div class="card">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-xl font-bold text-gray-900">Feature Requests</h3>
            <div class="flex gap-2">
              <button
                @click="featureTab = 'active'"
                :class="[
                  'px-2 py-1 text-xs rounded',
                  featureTab === 'active' 
                    ? 'bg-purple-100 text-purple-700 font-medium' 
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                ]"
              >
                Active ({{ activeFeatures.length }})
              </button>
              <button
                @click="featureTab = 'archived'"
                :class="[
                  'px-2 py-1 text-xs rounded',
                  featureTab === 'archived' 
                    ? 'bg-gray-200 text-gray-700 font-medium' 
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                ]"
              >
                Archived ({{ archivedFeatures.length }})
              </button>
            </div>
          </div>
          
          <div v-if="loadingFeatures" class="text-center py-8 text-gray-500">
            Loading feature requests...
          </div>

          <div v-else-if="currentFeatures.length === 0" class="text-center py-8 text-gray-500">
            No {{ featureTab }} feature requests
          </div>

          <div v-else class="space-y-3 max-h-96 overflow-y-auto">
            <div
              v-for="item in currentFeatures"
              :key="item.id"
              class="p-3 bg-purple-50 rounded-lg border border-purple-200"
            >
              <div class="flex items-start justify-between mb-2">
                <div>
                  <p class="text-sm font-bold text-gray-900">{{ item.title }}</p>
                  <p class="text-xs text-gray-500">by {{ item.name || 'Anonymous' }} • {{ formatDate(item.created_at) }}</p>
                </div>
                <span :class="[
                  'px-2 py-1 rounded text-xs font-medium',
                  item.category === 'ui' ? 'bg-blue-100 text-blue-700' :
                  item.category === 'functionality' ? 'bg-green-100 text-green-700' :
                  item.category === 'performance' ? 'bg-yellow-100 text-yellow-700' :
                  'bg-gray-100 text-gray-700'
                ]">
                  {{ item.category }}
                </span>
              </div>
              <p class="text-sm text-gray-700 mb-2">{{ item.description }}</p>
              <div class="flex items-center gap-2 text-xs text-gray-600 mb-2">
                <span>👍 {{ item.votes || 0 }} votes</span>
              </div>
              <div class="flex gap-2">
                <button
                  v-if="item.status === 'new'"
                  @click="updateFeatureStatus(item.id, 'under_review')"
                  class="text-xs px-2 py-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200"
                >
                  Review
                </button>
                <button
                  v-if="item.status !== 'planned'"
                  @click="updateFeatureStatus(item.id, 'planned')"
                  class="text-xs px-2 py-1 bg-green-100 text-green-700 rounded hover:bg-green-200"
                >
                  Plan
                </button>
                <button
                  v-if="item.status !== 'rejected'"
                  @click="updateFeatureStatus(item.id, 'rejected')"
                  class="text-xs px-2 py-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
                >
                  Reject
                </button>
                <button
                  v-if="item.status !== 'archived'"
                  @click="updateFeatureStatus(item.id, 'archived')"
                  class="text-xs px-2 py-1 bg-gray-100 text-gray-700 rounded hover:bg-gray-200"
                >
                  Archive
                </button>
              </div>
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
                      user.role === 'reviewer' ? 'bg-blue-100 text-blue-700' :
                      'bg-green-100 text-green-700'
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
                    <option value="contributor">Contributor</option>
                    <option value="reviewer">Reviewer</option>
                    <option value="admin">Admin</option>
                  </select>
                  <span v-else class="text-gray-500 text-xs">You</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Recent Activity (at bottom) -->
      <div class="card mt-6">
        <h3 class="text-xl font-bold text-gray-900 mb-4">📋 Recent Activity</h3>
        
        <div v-if="loadingActivity" class="text-center py-8 text-gray-500">
          Loading activity...
        </div>

        <div v-else-if="recentActivity.length === 0" class="text-center py-8 text-gray-500">
          No recent activity
        </div>

        <div v-else class="space-y-2">
          <div
            v-for="activity in recentActivity"
            :key="activity.id"
            class="border border-gray-200 rounded-lg overflow-hidden"
          >
            <div 
              @click="toggleActivityDetails(activity.id)"
              class="flex items-start justify-between gap-4 p-3 bg-gray-50 hover:bg-gray-100 cursor-pointer transition-colors"
            >
              <div class="flex-1">
                <p class="text-sm font-medium text-gray-900">
                  <span class="text-primary-600">{{ activity.user?.email || 'Unknown' }}</span>
                  <span class="text-gray-600 mx-1">{{ formatAction(activity.action) }}</span>
                  <span class="font-medium text-gray-900">{{ activity.entity_type }}</span>
                  <span v-if="activity.entity_id" class="text-gray-500 text-xs">#{{ activity.entity_id.slice(0, 8) }}</span>
                </p>
                <p class="text-xs text-gray-500 mt-1">
                  {{ formatDate(activity.created_at) }}
                </p>
              </div>
              <button class="text-gray-400 hover:text-gray-600">
                <svg 
                  class="w-5 h-5 transition-transform" 
                  :class="expandedActivities.has(activity.id) ? 'rotate-180' : ''"
                  fill="none" 
                  stroke="currentColor" 
                  viewBox="0 0 24 24"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
            </div>
            
            <!-- Expanded Details -->
            <div v-if="expandedActivities.has(activity.id)" class="p-4 bg-white border-t border-gray-200">
              <div v-if="activity.changes" class="space-y-2">
                <h4 class="text-xs font-semibold text-gray-700 uppercase mb-2">Changes:</h4>
                <pre class="text-xs bg-gray-900 text-green-400 p-3 rounded overflow-x-auto font-mono">{{ JSON.stringify(activity.changes, null, 2) }}</pre>
              </div>
              <div v-else class="text-sm text-gray-500 italic">
                No change details available
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { adminService } from '@/services/adminService'
import { useAuthStore } from '@/stores/authStore'
import { supabase } from '@/services/supabaseClient'

const router = useRouter()
const authStore = useAuthStore()

const loading = ref(true)
const loadingActivity = ref(true)
const loadingUsers = ref(true)
const loadingFeedback = ref(true)
const loadingFeatures = ref(true)
const loadingApplications = ref(true)
const loadingArchivedBhajans = ref(false)
const stats = ref({})
const recentActivity = ref([])
const users = ref([])
const feedback = ref([])
const featureRequests = ref([])
const reviewerApplications = ref([])
const archivedBhajans = ref([])
const showArchivedBhajans = ref(false)

// Tab states
const applicationTab = ref('pending')
const feedbackTab = ref('active')
const featureTab = ref('active')
const expandedActivities = ref(new Set())

function toggleActivityDetails(activityId) {
  if (expandedActivities.value.has(activityId)) {
    expandedActivities.value.delete(activityId)
  } else {
    expandedActivities.value.add(activityId)
  }
  // Trigger reactivity
  expandedActivities.value = new Set(expandedActivities.value)
}

// Computed filtered lists
const archivedBhajansCount = computed(() => archivedBhajans.value.length)
const pendingApplications = computed(() => 
  reviewerApplications.value.filter(app => app.status === 'pending')
)
const approvedApplications = computed(() => 
  reviewerApplications.value.filter(app => app.status === 'approved')
)
const rejectedApplications = computed(() => 
  reviewerApplications.value.filter(app => app.status === 'rejected')
)
const currentApplications = computed(() => {
  if (applicationTab.value === 'pending') return pendingApplications.value
  if (applicationTab.value === 'approved') return approvedApplications.value
  return rejectedApplications.value
})

const activeFeedback = computed(() => 
  feedback.value.filter(item => item.status !== 'archived')
)
const archivedFeedback = computed(() => 
  feedback.value.filter(item => item.status === 'archived')
)
const currentFeedback = computed(() => 
  feedbackTab.value === 'active' ? activeFeedback.value : archivedFeedback.value
)

const activeFeatures = computed(() => 
  featureRequests.value.filter(item => item.status !== 'archived')
)
const archivedFeatures = computed(() => 
  featureRequests.value.filter(item => item.status === 'archived')
)
const currentFeatures = computed(() => 
  featureTab.value === 'active' ? activeFeatures.value : archivedFeatures.value
)

function goToReviewQueue() {
  router.push('/admin/review-queue')
}

function goToApprovedBhajans() {
  router.push('/?status=approved')
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

async function fetchFeedback() {
  loadingFeedback.value = true
  try {
    const { data, error } = await supabase
      .from('feedback')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(20)
    
    if (!error && data) {
      feedback.value = data
    }
  } catch (err) {
    console.error('Error fetching feedback:', err)
  }
  loadingFeedback.value = false
}

async function fetchFeatureRequests() {
  loadingFeatures.value = true
  try {
    const { data, error } = await supabase
      .from('feature_requests')
      .select('*')
      .order('votes', { ascending: false })
      .limit(20)
    
    if (!error && data) {
      featureRequests.value = data
    }
  } catch (err) {
    console.error('Error fetching feature requests:', err)
  }
  loadingFeatures.value = false
}

async function updateFeedbackStatus(id, status) {
  try {
    const { error } = await supabase
      .from('feedback')
      .update({ status, updated_at: new Date().toISOString() })
      .eq('id', id)
    
    if (!error) {
      await fetchFeedback()
    }
  } catch (err) {
    console.error('Error updating feedback:', err)
    alert('Failed to update feedback status')
  }
}

async function updateFeatureStatus(id, status) {
  try {
    const { error } = await supabase
      .from('feature_requests')
      .update({ status, updated_at: new Date().toISOString() })
      .eq('id', id)
    
    if (!error) {
      await fetchFeatureRequests()
    }
  } catch (err) {
    console.error('Error updating feature request:', err)
    alert('Failed to update feature request status')
  }
}

async function fetchReviewerApplications() {
  loadingApplications.value = true
  try {
    const { data, error } = await supabase
      .from('reviewer_applications')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (!error && data) {
      reviewerApplications.value = data
    }
  } catch (err) {
    console.error('Error fetching reviewer applications:', err)
  }
  loadingApplications.value = false
}

async function handleReviewerApplication(applicationId, userId, status) {
  const action = status === 'approved' ? 'approve' : 'reject'
  if (!confirm(`Are you sure you want to ${action} this application?`)) {
    return
  }

  try {
    // Update application status
    const { error: appError } = await supabase
      .from('reviewer_applications')
      .update({ 
        status,
        reviewed_by: authStore.user.id,
        reviewed_at: new Date().toISOString()
      })
      .eq('id', applicationId)
    
    if (appError) throw appError

    // If approved, update user role to reviewer
    if (status === 'approved' && userId) {
      const result = await authStore.updateUserRole(userId, 'reviewer')
      if (!result.success) {
        alert('Application approved but failed to update user role. Please update manually.')
      }
    }

    await fetchReviewerApplications()
    alert(`Application ${status} successfully`)
  } catch (err) {
    console.error('Error handling application:', err)
    alert('Failed to update application')
  }
}

async function fetchArchivedBhajans() {
  loadingArchivedBhajans.value = true
  try {
    const { data, error } = await supabase
      .from('bhajans')
      .select('*')
      .in('status', ['archived', 'rejected'])
      .order('updated_at', { ascending: false })
    
    if (!error && data) {
      archivedBhajans.value = data
    }
  } catch (err) {
    console.error('Error fetching archived bhajans:', err)
  }
  loadingArchivedBhajans.value = false
}

async function restoreBhajan(bhajanId) {
  if (!confirm('Restore this bhajan to draft status?')) {
    return
  }

  try {
    const { error } = await supabase
      .from('bhajans')
      .update({ status: 'draft', updated_at: new Date().toISOString() })
      .eq('id', bhajanId)
    
    if (!error) {
      await fetchArchivedBhajans()
      await fetchStats()
      alert('Bhajan restored to draft')
    } else {
      throw error
    }
  } catch (err) {
    console.error('Error restoring bhajan:', err)
    alert('Failed to restore bhajan')
  }
}

async function permanentlyDeleteBhajan(bhajanId) {
  if (!confirm('PERMANENTLY delete this bhajan? This action cannot be undone!')) {
    return
  }

  try {
    const { error } = await supabase
      .from('bhajans')
      .delete()
      .eq('id', bhajanId)
    
    if (!error) {
      await fetchArchivedBhajans()
      await fetchStats()
      alert('Bhajan permanently deleted')
    } else {
      throw error
    }
  } catch (err) {
    console.error('Error deleting bhajan:', err)
    alert('Failed to delete bhajan')
  }
}

// Watch for showArchivedBhajans and fetch when opened
watch(showArchivedBhajans, (newValue) => {
  if (newValue && archivedBhajans.value.length === 0) {
    fetchArchivedBhajans()
  }
})

onMounted(async () => {
  await Promise.all([
    fetchStats(),
    fetchActivity(),
    fetchUsers(),
    fetchFeedback(),
    fetchFeatureRequests(),
    fetchReviewerApplications()
  ])
  loading.value = false
})
</script>
