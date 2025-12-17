<template>
  <div class="max-w-7xl mx-auto">
    <div class="mb-8">
      <h1 class="text-4xl font-bold text-gray-900 mb-4">Bhajan Collection</h1>
      <p class="text-lg text-gray-600">
        Browse and search through our collection of devotional bhajans
      </p>
      
      <!-- Site Statistics -->
      <div v-if="siteStats" class="mt-4 flex flex-wrap gap-4">
        <div class="bg-blue-50 border border-blue-200 rounded-lg px-4 py-2">
          <span class="text-sm text-blue-700 font-medium">Total Bhajans:</span>
          <span class="ml-2 text-lg font-bold text-blue-900">{{ siteStats.total_bhajans || 0 }}</span>
        </div>
        <div class="bg-green-50 border border-green-200 rounded-lg px-4 py-2">
          <span class="text-sm text-green-700 font-medium">Total Views:</span>
          <span class="ml-2 text-lg font-bold text-green-900">{{ formatNumber(siteStats.total_views || 0) }}</span>
        </div>
      </div>
    </div>

    <!-- Search and Filters -->
    <div class="card mb-8">
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
        <div class="flex flex-wrap gap-4">
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

    <!-- Bhajans Table -->
    <div v-else>
      <div class="mb-4 text-gray-600">
        Found {{ bhajanStore.totalCount }} bhajan{{ bhajanStore.totalCount !== 1 ? 's' : '' }}
      </div>

      <!-- Table View -->
      <div class="card overflow-hidden">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Title
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tags
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr 
                v-for="bhajan in bhajans" 
                :key="bhajan.id"
                @click="viewBhajan(bhajan.id)"
                class="hover:bg-gray-50 cursor-pointer transition"
              >
                <td class="px-6 py-4">
                  <div class="text-sm font-medium text-gray-900">{{ bhajan.title }}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="flex flex-wrap gap-1">
                    <span 
                      v-for="tag in bhajan.tags" 
                      :key="tag.id || tag.tag_name"
                      class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800"
                    >
                      {{ tag.tag_name }}
                    </span>
                    <span v-if="!bhajan.tags || bhajan.tags.length === 0" class="text-sm text-gray-400">No tags</span>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
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
