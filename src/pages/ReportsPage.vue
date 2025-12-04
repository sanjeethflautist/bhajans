<template>
  <div class="max-w-7xl mx-auto">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Reports Management</h1>
      <p class="text-gray-600">
        Review and manage user-submitted reports
      </p>
    </div>

    <!-- Status Filter -->
    <div class="card mb-6">
      <div class="flex gap-4">
        <button
          v-for="status in statusFilters"
          :key="status.value"
          @click="selectedStatus = status.value"
          :class="[
            'px-4 py-2 rounded-lg font-medium transition',
            selectedStatus === status.value
              ? 'bg-primary-600 text-white'
              : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
          ]"
        >
          {{ status.label }}
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      <p class="mt-4 text-gray-600">Loading reports...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="card bg-red-50 border border-red-200 text-red-700">
      <p>{{ error }}</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="reports.length === 0" class="text-center py-12">
      <div class="text-6xl mb-4">✓</div>
      <h3 class="text-xl font-bold text-gray-900 mb-2">No Reports Found</h3>
      <p class="text-gray-600">
        {{ selectedStatus === 'all' ? 'No reports have been submitted' : `No ${selectedStatus.replace('_', ' ')} reports` }}
      </p>
      <RouterLink to="/admin" class="btn-secondary inline-block mt-4">
        Back to Dashboard
      </RouterLink>
    </div>

    <!-- Reports List -->
    <div v-else class="space-y-6">
      <div class="mb-4 text-gray-600">
        {{ reports.length }} report{{ reports.length !== 1 ? 's' : '' }}
      </div>

      <div
        v-for="report in reports"
        :key="report.id"
        class="card"
      >
        <!-- Report Header -->
        <div class="flex justify-between items-start mb-4">
          <div class="flex-1">
            <div class="flex items-center gap-3 mb-2">
              <span
                :class="statusClasses(report.status)"
                class="px-3 py-1 rounded-full text-xs font-medium"
              >
                {{ formatStatus(report.status) }}
              </span>
              <span
                :class="issueTypeClasses(report.issue_type)"
                class="px-3 py-1 rounded-full text-xs font-medium"
              >
                {{ formatIssueType(report.issue_type) }}
              </span>
            </div>
            
            <h3 class="text-lg font-bold text-gray-900 mb-1">
              Report for: {{ report.bhajan?.title || 'Unknown Bhajan' }}
            </h3>
            
            <div class="flex items-center gap-4 text-sm text-gray-500 mb-3">
              <span>Reported by {{ report.reporter?.email }}</span>
              <span>•</span>
              <span>{{ formatDate(report.created_at) }}</span>
            </div>
            
            <p class="text-gray-700">{{ report.description }}</p>
          </div>
        </div>

        <!-- Resolution Comment (if resolved/dismissed) -->
        <div
          v-if="report.resolution_comment"
          class="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg"
        >
          <p class="text-sm font-medium text-gray-700 mb-1">Resolution:</p>
          <p class="text-sm text-gray-600">{{ report.resolution_comment }}</p>
          <p v-if="report.resolver" class="text-xs text-gray-500 mt-2">
            By {{ report.resolver.email }} on {{ formatDate(report.resolved_at) }}
          </p>
        </div>

        <!-- Action Buttons -->
        <div v-if="report.status !== 'resolved' && report.status !== 'dismissed'" class="flex gap-3 mt-4 pt-4 border-t">
          <button
            v-if="report.status === 'open'"
            @click="markUnderReview(report.id)"
            class="btn-secondary text-sm"
          >
            Mark Under Review
          </button>

          <button
            @click="openResolveModal(report)"
            class="btn-primary text-sm"
          >
            Resolve Report
          </button>

          <button
            @click="openDismissModal(report)"
            class="btn-danger text-sm"
          >
            Dismiss Report
          </button>

          <RouterLink
            :to="`/bhajan/${report.bhajan_id}`"
            class="btn-secondary text-sm"
          >
            View Bhajan
          </RouterLink>
        </div>
      </div>
    </div>

    <!-- Resolve/Dismiss Modal -->
    <div
      v-if="showModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click.self="closeModal"
    >
      <div class="bg-white rounded-lg p-8 max-w-md w-full">
        <h3 class="text-xl font-bold text-gray-900 mb-4">
          {{ modalAction === 'resolve' ? 'Resolve Report' : 'Dismiss Report' }}
        </h3>

        <div class="mb-6">
          <label for="resolutionComment" class="block text-sm font-medium text-gray-700 mb-2">
            Comment <span class="text-red-500">*</span>
          </label>
          <textarea
            id="resolutionComment"
            v-model="resolutionComment"
            rows="4"
            required
            class="input-field"
            :placeholder="`Explain why you're ${modalAction === 'resolve' ? 'resolving' : 'dismissing'} this report...`"
          ></textarea>
        </div>

        <div class="flex gap-3">
          <button
            @click="confirmAction"
            :disabled="!resolutionComment.trim()"
            class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Confirm
          </button>
          <button @click="closeModal" class="btn-secondary">
            Cancel
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useReportStore } from '@/stores/reportStore'

const reportStore = useReportStore()

const selectedStatus = ref('open')
const showModal = ref(false)
const modalAction = ref('resolve')
const selectedReport = ref(null)
const resolutionComment = ref('')

const statusFilters = [
  { label: 'All', value: 'all' },
  { label: 'Open', value: 'open' },
  { label: 'Under Review', value: 'under_review' },
  { label: 'Resolved', value: 'resolved' },
  { label: 'Dismissed', value: 'dismissed' }
]

const loading = computed(() => reportStore.loading)
const error = computed(() => reportStore.error)
const reports = computed(() => reportStore.reports)

function statusClasses(status) {
  const classes = {
    open: 'bg-red-100 text-red-700',
    under_review: 'bg-yellow-100 text-yellow-700',
    resolved: 'bg-green-100 text-green-700',
    dismissed: 'bg-gray-100 text-gray-700'
  }
  return classes[status] || classes.open
}

function issueTypeClasses(issueType) {
  const classes = {
    incorrect_lyrics: 'bg-blue-100 text-blue-700',
    offensive_content: 'bg-red-100 text-red-700',
    copyright: 'bg-purple-100 text-purple-700',
    other: 'bg-gray-100 text-gray-700'
  }
  return classes[issueType] || classes.other
}

function formatStatus(status) {
  return status.split('_').map(word => 
    word.charAt(0).toUpperCase() + word.slice(1)
  ).join(' ')
}

function formatIssueType(issueType) {
  return issueType.split('_').map(word => 
    word.charAt(0).toUpperCase() + word.slice(1)
  ).join(' ')
}

function formatDate(dateString) {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

async function markUnderReview(reportId) {
  const result = await reportStore.markAsUnderReview(reportId)
  
  if (result.success) {
    await fetchReports()
  } else {
    alert('Failed to update report: ' + result.error)
  }
}

function openResolveModal(report) {
  selectedReport.value = report
  modalAction.value = 'resolve'
  resolutionComment.value = ''
  showModal.value = true
}

function openDismissModal(report) {
  selectedReport.value = report
  modalAction.value = 'dismiss'
  resolutionComment.value = ''
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedReport.value = null
  resolutionComment.value = ''
}

async function confirmAction() {
  if (!resolutionComment.value.trim()) {
    alert('Please provide a comment')
    return
  }

  let result
  if (modalAction.value === 'resolve') {
    result = await reportStore.resolveReport(selectedReport.value.id, resolutionComment.value)
  } else {
    result = await reportStore.dismissReport(selectedReport.value.id, resolutionComment.value)
  }

  if (result.success) {
    closeModal()
    await fetchReports()
  } else {
    alert(`Failed to ${modalAction.value} report: ` + result.error)
  }
}

async function fetchReports() {
  const filters = selectedStatus.value === 'all' ? {} : { status: selectedStatus.value }
  await reportStore.fetchAllReports(filters)
}

onMounted(async () => {
  await fetchReports()
})

// Watch for status filter changes
const unwatchStatus = computed(() => selectedStatus.value)
unwatchStatus.value // Trigger initial computation
;(async () => {
  await fetchReports()
})()
</script>
