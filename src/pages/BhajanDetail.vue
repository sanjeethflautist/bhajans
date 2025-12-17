<template>
  <div class="max-w-4xl mx-auto">
    <!-- Loading State -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      <p class="mt-4 text-gray-600">Loading bhajan...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="card bg-red-50 border border-red-200 text-red-700">
      <p>{{ error }}</p>
      <RouterLink to="/" class="btn-secondary inline-block mt-4">
        Go Back Home
      </RouterLink>
    </div>

    <!-- Bhajan Content -->
    <div v-else-if="bhajan">
      <!-- Header -->
      <div class="card mb-6">
        <h1 class="text-3xl font-bold text-gray-900 mb-4">{{ bhajan.title }}</h1>
        
        <p v-if="bhajan.description" class="text-lg text-gray-600 mb-6">
          {{ bhajan.description }}
        </p>

        <!-- Action Buttons -->
        <div class="flex flex-wrap gap-3 mt-4 pt-4 border-t">
          <RouterLink
            v-if="canEdit"
            :to="`/bhajan/${bhajan.id}/edit`"
            class="btn-primary"
          >
            Edit
          </RouterLink>
          
          <button
            v-if="canDelete"
            @click="confirmDelete"
            class="btn-danger"
          >
            Delete
          </button>

          <button
            v-if="authStore.isAuthenticated && !showReportForm"
            @click="showReportForm = true"
            class="btn-secondary"
          >
            Report Issue
          </button>

          <RouterLink to="/" class="btn-secondary">
            Back to Browse
          </RouterLink>
        </div>
      </div>

      <!-- Report Form -->
      <div v-if="showReportForm" class="mb-6">
        <ReportForm
          :bhajan="bhajan"
          @success="handleReportSuccess"
          @cancel="showReportForm = false"
        />
      </div>

      <!-- Tags -->
      <div v-if="bhajan.tags && bhajan.tags.length > 0" class="card mb-6">
        <h3 class="text-lg font-bold text-gray-900 mb-3">Tags</h3>
        <div class="flex flex-wrap gap-2">
          <span
            v-for="tag in bhajan.tags"
            :key="tag.id"
            class="bg-primary-100 text-primary-700 px-3 py-2 rounded-full text-sm font-medium"
          >
            {{ tag.tag_name }}
          </span>
        </div>
      </div>

      <!-- Lyrics -->
      <div class="card space-y-6">
        <h3 class="text-xl font-bold text-gray-900 mb-4">Lyrics</h3>
        
        <!-- Display lyrics in enabled scripts -->
        <div 
          v-for="script in preferencesStore.scriptOptions" 
          :key="script.id"
          v-show="preferencesStore.isScriptEnabled(script.id) && bhajan[script.field]"
          class="bg-gray-50 p-6 rounded-lg"
        >
          <h4 class="text-sm font-semibold text-gray-600 mb-3">{{ script.label }}</h4>
          <pre 
            class="whitespace-pre-wrap font-serif text-gray-800 leading-relaxed text-lg"
            :lang="script.id === 'kannada' ? 'kn' : script.id === 'devanagari' ? 'hi' : 'en'"
          >{{ bhajan[script.field] }}</pre>
        </div>

        <!-- No lyrics available message -->
        <div 
          v-if="!hasAnyEnabledLyrics"
          class="bg-yellow-50 p-6 rounded-lg text-center text-gray-600"
        >
          <p>No lyrics available in the selected script(s). Please select a different script from the preferences.</p>
        </div>
      </div>

      <!-- Meaning Section (if enabled and available) -->
      <div 
        v-if="preferencesStore.showMeaning && bhajan.meaning" 
        class="card bg-blue-50 border-l-4 border-blue-400"
      >
        <h3 class="text-xl font-bold text-blue-900 mb-4">Meaning</h3>
        <div class="prose prose-blue max-w-none">
          <pre class="whitespace-pre-wrap font-sans text-gray-800 leading-relaxed">{{ bhajan.meaning }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { useBhajanStore } from '@/stores/bhajanStore'
import { useAuthStore } from '@/stores/authStore'
import { usePreferencesStore } from '@/stores/preferencesStore'
import { analyticsService } from '@/services/analyticsService'
import ReportForm from '@/components/ReportForm.vue'

const route = useRoute()
const router = useRouter()
const bhajanStore = useBhajanStore()
const authStore = useAuthStore()
const preferencesStore = usePreferencesStore()

const showReportForm = ref(false)

const loading = computed(() => bhajanStore.loading)
const error = computed(() => bhajanStore.error)
const bhajan = computed(() => bhajanStore.currentBhajan)

// Check if any enabled scripts have lyrics
const hasAnyEnabledLyrics = computed(() => {
  if (!bhajan.value) return false
  return preferencesStore.scriptOptions.some(script => 
    preferencesStore.isScriptEnabled(script.id) && bhajan.value[script.field]
  )
})

const statusClasses = computed(() => {
  const classes = {
    draft: 'bg-gray-200 text-gray-700',
    pending_review: 'bg-yellow-200 text-yellow-800',
    approved: 'bg-green-200 text-green-800',
    rejected: 'bg-red-200 text-red-800'
  }
  return classes[bhajan.value?.status] || classes.draft
})

const statusText = computed(() => {
  const texts = {
    draft: 'Draft',
    pending_review: 'Pending Review',
    approved: 'Approved',
    rejected: 'Rejected'
  }
  return texts[bhajan.value?.status] || bhajan.value?.status
})

const canEdit = computed(() => {
  if (!authStore.isAuthenticated || !bhajan.value) return false
  return authStore.isAdmin || 
    (authStore.isEditor && authStore.user.id === bhajan.value.created_by)
})

const canDelete = computed(() => {
  return authStore.isAdmin
})

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

async function confirmDelete() {
  if (!confirm(`Are you sure you want to delete "${bhajan.value.title}"? This action cannot be undone.`)) {
    return
  }

  const result = await bhajanStore.deleteBhajan(bhajan.value.id)
  
  if (result.success) {
    router.push('/')
  } else {
    alert('Failed to delete bhajan: ' + result.error)
  }
}

function handleReportSuccess() {
  showReportForm.value = false
  alert('Report submitted successfully!')
}

onMounted(async () => {
  await bhajanStore.fetchBhajanById(route.params.id)
  
  // Track view after successfully loading bhajan
  if (bhajanStore.currentBhajan) {
    await analyticsService.trackBhajanView(route.params.id)
  }
})
</script>
