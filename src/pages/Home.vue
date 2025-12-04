<template>
  <div class="max-w-7xl mx-auto">
    <div class="mb-8">
      <h1 class="text-4xl font-bold text-gray-900 mb-4">Bhajan Collection</h1>
      <p class="text-lg text-gray-600">
        Browse and search through our collection of devotional bhajans
      </p>
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

    <!-- Bhajans Grid -->
    <div v-else>
      <div class="mb-4 text-gray-600">
        Found {{ bhajanStore.totalCount }} bhajan{{ bhajanStore.totalCount !== 1 ? 's' : '' }}
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <BhajanCard
          v-for="bhajan in bhajans"
          :key="bhajan.id"
          :bhajan="bhajan"
        />
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
import { RouterLink } from 'vue-router'
import { useBhajanStore } from '@/stores/bhajanStore'
import { useTagStore } from '@/stores/tagStore'
import { useAuthStore } from '@/stores/authStore'
import BhajanCard from '@/components/BhajanCard.vue'

const bhajanStore = useBhajanStore()
const tagStore = useTagStore()
const authStore = useAuthStore()

const searchQuery = ref('')
const selectedTag = ref('')
const sortBy = ref('created_at')
const currentPage = ref(1)
const itemsPerPage = 12

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
    status: authStore.isEditor ? undefined : 'approved',
    searchQuery: searchQuery.value,
    tags: selectedTag.value ? [selectedTag.value] : undefined,
    sortBy: sortBy.value,
    sortOrder: 'desc',
    limit: itemsPerPage,
    offset: (currentPage.value - 1) * itemsPerPage
  }

  await bhajanStore.fetchBhajans(filters)
}

function clearFilters() {
  searchQuery.value = ''
  selectedTag.value = ''
  currentPage.value = 1
  fetchBhajansData()
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    fetchBhajansData()
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}

onMounted(async () => {
  await tagStore.fetchAllTags()
  await fetchBhajansData()
})
</script>
