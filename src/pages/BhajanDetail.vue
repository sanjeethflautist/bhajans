<template>
  <div class="max-w-4xl mx-auto px-2 sm:px-6">
    <!-- Loading State -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500"></div>
      <p class="mt-4 text-gray-600">Loading bhajan...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border-l-4 border-red-400 p-4 rounded-lg">
      <p class="text-red-700 mb-3">{{ error }}</p>
      <RouterLink to="/" class="btn-secondary inline-block">
        Go Back Home
      </RouterLink>
    </div>

    <!-- Bhajan Content -->
    <div v-else-if="bhajan" class="space-y-4">
      <!-- Header Card with Gradient -->
      <div class="bg-gradient-to-br from-primary-50 to-purple-50 rounded-2xl shadow-lg p-3 sm:p-6 border border-primary-100 relative">
        <!-- Favorite Button -->
        <button
          @click="handleFavoriteClick"
          class="absolute top-4 right-4 p-3 rounded-full hover:bg-white/50 transition-colors z-10"
          :class="isFavorited ? 'text-red-500' : 'text-gray-400'"
          :title="isFavorited ? 'Remove from favorites' : 'Add to favorites'"
        >
          <svg class="w-7 h-7" :fill="isFavorited ? 'currentColor' : 'none'" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
          </svg>
        </button>

        <h1 class="text-2xl sm:text-4xl font-bold bg-gradient-to-r from-primary-600 to-purple-600 bg-clip-text text-transparent mb-3 pr-14">{{ bhajan.title }}</h1>
        
        <!-- Titles in other scripts -->
        <div class="mb-3 space-y-2">
          <h2 
            v-if="preferencesStore.isScriptEnabled('kannada') && bhajan.title_kannada"
            class="text-xl sm:text-2xl font-semibold text-gray-700"
            lang="kn"
          >
            {{ bhajan.title_kannada }}
          </h2>
          <h2 
            v-if="preferencesStore.isScriptEnabled('devanagari') && bhajan.title_devanagari"
            class="text-xl sm:text-2xl font-semibold text-gray-700"
            lang="hi"
          >
            {{ bhajan.title_devanagari }}
          </h2>
        </div>
        
        <p v-if="bhajan.description" class="text-base sm:text-lg text-gray-600 mb-4">
          {{ bhajan.description }}
        </p>

        <!-- Action Buttons -->
        <div class="flex flex-wrap gap-2 mt-4 pt-4 border-t border-primary-200">
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
      <div v-if="showReportForm" class="mb-4">
        <ReportForm
          :bhajan="bhajan"
          @success="handleReportSuccess"
          @cancel="showReportForm = false"
        />
      </div>

      <!-- Tags -->
      <div v-if="bhajan.tags && bhajan.tags.length > 0" class="bg-white rounded-xl shadow-md p-3 sm:p-5 border border-gray-100">
        <h3 class="text-base sm:text-lg font-bold text-gray-800 mb-3 flex items-center">
          <svg class="w-5 h-5 mr-2 text-primary-500" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M17.707 9.293a1 1 0 010 1.414l-7 7a1 1 0 01-1.414 0l-7-7A.997.997 0 012 10V5a3 3 0 013-3h5c.256 0 .512.098.707.293l7 7zM5 6a1 1 0 100-2 1 1 0 000 2z" clip-rule="evenodd" />
          </svg>
          Tags
        </h3>
        <div class="flex flex-wrap gap-2">
          <span
            v-for="tag in bhajan.tags"
            :key="tag.id"
            class="bg-gradient-to-r from-primary-50 to-purple-50 text-primary-700 px-3 py-1.5 rounded-full text-sm font-medium border border-primary-200 hover:shadow-md transition-shadow"
          >
            {{ tag.tag_name }}
          </span>
        </div>
      </div>

      <!-- Lyrics -->
      <div class="bg-white rounded-xl shadow-md overflow-hidden border border-gray-100">
        
        <!-- Display lyrics in enabled scripts -->
        <div 
          v-for="(script, index) in preferencesStore.scriptOptions" 
          :key="script.id"
          v-show="preferencesStore.isScriptEnabled(script.id) && bhajan[script.field]"
          :class="[
            'p-2 sm:p-5',
            index > 0 && preferencesStore.scriptOptions.some((s, i) => i < index && preferencesStore.isScriptEnabled(s.id) && bhajan[s.field]) ? 'border-t border-gray-200' : ''
          ]"
        >
          <div class="flex items-center mb-2">
            <span class="text-xs sm:text-sm font-semibold text-primary-600 bg-primary-50 px-3 py-1 rounded-full">{{ script.label }}</span>
          </div>
          <pre 
            class="whitespace-pre-wrap font-serif text-gray-800 leading-relaxed text-base sm:text-lg overflow-x-auto"
            :lang="script.id === 'kannada' ? 'kn' : script.id === 'devanagari' ? 'hi' : 'en'"
          >{{ bhajan[script.field] }}</pre>
        </div>

        <!-- No lyrics available message -->
        <div 
          v-if="!hasAnyEnabledLyrics"
          class="bg-yellow-50 p-3 sm:p-6 text-center text-gray-600">
        >
          <p class="text-sm sm:text-base">No lyrics available in the selected script(s). Please select a different script from the preferences.</p>
        </div>
      </div>

      <!-- Meaning Section (if enabled and available) -->
      <div 
        v-if="preferencesStore.showMeaning && bhajan.meaning" 
        class="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-xl shadow-md p-3 sm:p-6 border-l-4 border-blue-400">
      >
        <div class="flex items-center mb-3">
          <svg class="w-5 h-5 mr-2 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
            <path d="M9 4.804A7.968 7.968 0 005.5 4c-1.255 0-2.443.29-3.5.804v10A7.969 7.969 0 015.5 14c1.669 0 3.218.51 4.5 1.385A7.962 7.962 0 0114.5 14c1.255 0 2.443.29 3.5.804v-10A7.968 7.968 0 0014.5 4c-1.255 0-2.443.29-3.5.804V12a1 1 0 11-2 0V4.804z" />
          </svg>
          <h3 class="text-base sm:text-lg font-bold text-blue-800">Meaning</h3>
        </div>
        <pre class="whitespace-pre-wrap font-sans text-gray-800 leading-relaxed text-sm sm:text-base">{{ bhajan.meaning }}</pre>
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
import { favoritesService } from '@/services/favoritesService'
import ReportForm from '@/components/ReportForm.vue'

const route = useRoute()
const router = useRouter()
const bhajanStore = useBhajanStore()
const authStore = useAuthStore()
const preferencesStore = usePreferencesStore()

const showReportForm = ref(false)
const isFavorited = ref(false)

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
  return authStore.isAdmin || authStore.user.id === bhajan.value.created_by
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

async function handleFavoriteClick() {
  if (!authStore.isAuthenticated) {
    if (confirm('You need to be logged in to add favorites.\n\nClick OK to log in now.')) {
      router.push('/login')
    }
    return
  }

  if (!bhajan.value) return

  const result = await favoritesService.toggleFavorite(bhajan.value.id)
  if (result.success) {
    isFavorited.value = result.isFavorited
  } else {
    alert('Failed to update favorites: ' + result.error)
  }
}

async function checkFavoriteStatus() {
  if (authStore.isAuthenticated && bhajan.value) {
    const { data } = await favoritesService.isFavorited(bhajan.value.id)
    isFavorited.value = data || false
  } else {
    isFavorited.value = false
  }
}

onMounted(async () => {
  await bhajanStore.fetchBhajanById(route.params.id)
  
  // Track view after successfully loading bhajan
  if (bhajanStore.currentBhajan) {
    await analyticsService.trackBhajanView(route.params.id)
    await checkFavoriteStatus()
  }
})
</script>
