<template>
  <div class="max-w-7xl mx-auto px-3 sm:px-6">
    <div class="mb-6 sm:mb-8">
      <p class="text-base sm:text-lg text-gray-600">
        Browse and search through our collection of devotional bhajans
      </p>
      
      <!-- Site Statistics -->
      <div v-if="siteStats" class="mt-4 flex flex-wrap gap-3">
        <div class="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200/50 rounded-xl px-4 py-2 shadow-sm hover:shadow-md transition-shadow">
          <span class="text-sm text-blue-700 font-medium">Total Bhajans:</span>
          <span class="ml-2 text-lg font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">{{ siteStats.total_bhajans || 0 }}</span>
        </div>
        <div class="bg-gradient-to-r from-green-50 to-emerald-50 border border-green-200/50 rounded-xl px-4 py-2 shadow-sm hover:shadow-md transition-shadow">
          <span class="text-sm text-green-700 font-medium">Total Views:</span>
          <span class="ml-2 text-lg font-bold bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">{{ formatNumber(siteStats.total_bhajan_views || 0) }}</span>
        </div>
      </div>
    </div>

    <!-- Search and Filters -->
    <div class="bg-white rounded-2xl shadow-md border border-gray-100 p-4 sm:p-6 mb-6">
      <div class="space-y-4">
        <!-- Search Bar -->
        <div>
          <input
            v-model="searchQuery"
            type="text"
            class="input-field"
            placeholder="Search by title, lyrics, or description..."
            @input="debouncedSearch"
          />
        </div>

        <!-- Filters Row -->
        <div class="flex flex-wrap gap-3">
          <!-- Tag Filter -->
          <div class="flex-1 min-w-[200px]">
            <select v-model="selectedTag" class="input-field" @change="fetchBhajansData">
              <option value="">All Tags</option>
              <option v-for="tag in tagStore.allTags" :key="tag" :value="tag">
                {{ tag }}
              </option>
            </select>
          </div>

          <!-- Sort By -->
          <div class="flex-1 min-w-[200px]">
            <select v-model="sortBy" class="input-field" @change="fetchBhajansData">
              <option value="created_at">Latest First</option>
              <option value="title">Title (A-Z)</option>
            </select>
          </div>

          <!-- Clear Filters -->
          <button
            v-if="hasFilters"
            @click="clearFilters"
            class="btn-secondary whitespace-nowrap"
          >
            Clear Filters
          </button>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      <p class="mt-4 text-gray-600">Loading bhajans...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="card bg-red-50 border border-red-200 text-red-700">
      <p>{{ error }}</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="bhajans.length === 0" class="text-center py-12">
      <div class="text-6xl mb-4">🎵</div>
      <h3 class="text-xl font-bold text-gray-900 mb-2">No Bhajans Found</h3>
      <p class="text-gray-600 mb-4">
        {{ searchQuery || selectedTag ? 'Try adjusting your filters' : 'Be the first to add a bhajan!' }}
      </p>
      <RouterLink
        v-if="authStore.canCreateBhajan"
        to="/bhajan/create"
        class="btn-primary inline-block"
      >
        Create Bhajan
      </RouterLink>
    </div>

    <!-- Bhajans Grid -->
    <div v-else>
      <div class="mb-4 text-gray-600 font-medium">
        Found {{ bhajanStore.totalCount }} bhajan{{ bhajanStore.totalCount !== 1 ? 's' : '' }}
      </div>

      <!-- Grid View -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
        <div
          v-for="bhajan in bhajans"
          :key="bhajan.id"
          @click="viewBhajan(bhajan.id)"
          class="bg-white rounded-2xl shadow-md hover:shadow-2xl border border-gray-100 hover:border-primary-200 p-4 sm:p-5 cursor-pointer transform hover:-translate-y-2 transition-all duration-300 group"
        >
          <div class="mb-3">
            <h3 class="text-lg sm:text-xl font-bold text-gray-900 group-hover:text-primary-600 transition-colors line-clamp-2">{{ bhajan.title }}</h3>
          </div>
          <div v-if="bhajan.tags && bhajan.tags.length > 0" class="flex flex-wrap gap-1.5">
            <span
              v-for="tag in bhajan.tags.slice(0, 3)"
              :key="tag.id || tag.tag_name"
              class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-gradient-to-r from-primary-50 to-purple-50 text-primary-700 border border-primary-200"
            >
              {{ tag.tag_name }}
            </span>
            <span v-if="bhajan.tags.length > 3" class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium text-gray-500">
              +{{ bhajan.tags.length - 3 }}
            </span>
          </div>
          <div v-else class="text-sm text-gray-400 italic">No tags</div>
          
          <!-- Hover indicator -->
          <div class="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between opacity-0 group-hover:opacity-100 transition-opacity">
            <span class="text-sm text-primary-600 font-medium">View details</span>
            <svg class="w-4 h-4 text-primary-600 transform group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="mt-8 flex justify-center gap-2">
        <button
          @click="goToPage(currentPage - 1)"
          :disabled="currentPage === 1"
          class="btn-secondary disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Previous
        </button>
        
        <div class="flex items-center gap-2">
          <button
            v-for="page in visiblePages"
            :key="page"
            @click="goToPage(page)"
            :class="[
              'px-4 py-2 rounded-lg font-medium transition',
              page === currentPage
                ? 'bg-primary-600 text-white'
                : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
            ]"
          >
            {{ page }}
          </button>
        </div>

        <button
          @click="goToPage(currentPage + 1)"
          :disabled="currentPage === totalPages"
          class="btn-secondary disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Next
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink, useRouter, useRoute } from 'vue-router'
import { useBhajanStore } from '@/stores/bhajanStore'
import { useTagStore } from '@/stores/tagStore'
import { useAuthStore } from '@/stores/authStore'
import { analyticsService } from '@/services/analyticsService'
import BhajanCard from '@/components/BhajanCard.vue'

const router = useRouter()
const route = useRoute()
const bhajanStore = useBhajanStore()
const tagStore = useTagStore()
const authStore = useAuthStore()

const searchQuery = ref('')
const selectedTag = ref('')
const sortBy = ref('created_at')
const currentPage = ref(1)
const itemsPerPage = 12
const statusFilter = ref('')
const siteStats = ref(null)

const loading = computed(() => bhajanStore.loading)
const error = computed(() => bhajanStore.error)
const bhajans = computed(() => bhajanStore.bhajans)

const hasFilters = computed(() => {
  return searchQuery.value || selectedTag.value
})

const totalPages = computed(() => {
  return Math.ceil(bhajanStore.totalCount / itemsPerPage)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages.value, start + maxVisible - 1)
  
  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }
  
  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  
  return pages
})

let searchTimeout = null
function debouncedSearch() {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    currentPage.value = 1
    fetchBhajansData()
  }, 500)
}

async function fetchBhajansData() {
  const filters = {
    status: statusFilter.value || (!authStore.isReviewer ? 'approved' : undefined),
    searchQuery: searchQuery.value,
    tags: selectedTag.value ? [selectedTag.value] : undefined,
    sortBy: sortBy.value,
    sortOrder: 'desc',
    limit: itemsPerPage,
    offset: (currentPage.value - 1) * itemsPerPage
  }

  console.log('Fetching bhajans with filters:', filters)
  console.log('Auth store state:', { 
    isReviewer: authStore.isReviewer, 
    isAuthenticated: authStore.isAuthenticated,
    user: authStore.user 
  })

  await bhajanStore.fetchBhajans(filters)
  
  console.log('Bhajans fetched:', {
    count: bhajanStore.totalCount,
    data: bhajanStore.bhajans
  })
}

function clearFilters() {
  searchQuery.value = ''
  selectedTag.value = ''
  statusFilter.value = ''
  currentPage.value = 1
  router.push('/')
  fetchBhajansData()
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    fetchBhajansData()
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}

function viewBhajan(id) {
  router.push(`/bhajan/${id}`)
}

function formatNumber(num) {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M'
  } else if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K'
  }
  return num.toString()
}

onMounted(async () => {
  // Check for status filter from query params
  if (route.query.status) {
    statusFilter.value = route.query.status
  }
  
  // Track home page visit
  await analyticsService.trackHomeVisit()
  
  // Fetch site statistics
  const statsResult = await analyticsService.getSiteStatistics()
  if (statsResult.data) {
    siteStats.value = statsResult.data
  }
  
  await tagStore.fetchAllTags()
  await fetchBhajansData()
})
</script>
