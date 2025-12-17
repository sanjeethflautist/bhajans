<template>
  <div class="max-w-7xl mx-auto">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">My Favorites</h1>
      <p class="text-gray-600">
        Bhajans you've saved for quick access
      </p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      <p class="mt-4 text-gray-600">Loading your favorites...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="favorites.length === 0" class="text-center py-12">
      <svg class="mx-auto h-24 w-24 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
      </svg>
      <h3 class="mt-4 text-lg font-medium text-gray-900">No favorites yet</h3>
      <p class="mt-2 text-gray-600">Start adding bhajans to your favorites by clicking the heart icon</p>
      <div class="mt-6">
        <RouterLink to="/" class="btn-primary">
          Browse Bhajans
        </RouterLink>
      </div>
    </div>

    <!-- Favorites Grid -->
    <div v-else>
      <div class="mb-4 text-sm text-gray-600">
        {{ totalCount }} favorite{{ totalCount !== 1 ? 's' : '' }}
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <BhajanCard
          v-for="bhajan in favorites"
          :key="bhajan.id"
          :bhajan="bhajan"
        />
      </div>

      <!-- Load More -->
      <div v-if="hasMore" class="text-center mt-8">
        <button
          @click="loadMore"
          :disabled="loadingMore"
          class="btn-secondary disabled:opacity-50"
        >
          {{ loadingMore ? 'Loading...' : 'Load More' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import BhajanCard from '@/components/BhajanCard.vue'
import { favoritesService } from '@/services/favoritesService'

const favorites = ref([])
const loading = ref(true)
const loadingMore = ref(false)
const totalCount = ref(0)
const offset = ref(0)
const limit = 12
const hasMore = ref(false)

async function loadFavorites() {
  try {
    const { data, error, count } = await favoritesService.getUserFavorites({
      limit,
      offset: offset.value
    })

    if (error) {
      console.error('Error loading favorites:', error)
      return
    }

    if (offset.value === 0) {
      favorites.value = data || []
    } else {
      favorites.value.push(...(data || []))
    }

    totalCount.value = count || 0
    hasMore.value = favorites.value.length < totalCount.value
  } catch (err) {
    console.error('Error loading favorites:', err)
  } finally {
    loading.value = false
    loadingMore.value = false
  }
}

async function loadMore() {
  loadingMore.value = true
  offset.value += limit
  await loadFavorites()
}

onMounted(() => {
  loadFavorites()
})
</script>
