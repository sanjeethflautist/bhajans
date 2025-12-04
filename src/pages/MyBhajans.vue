<template>
  <div class="max-w-7xl mx-auto">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">My Bhajans</h1>
      <p class="text-gray-600">
        Manage your submitted bhajans
      </p>
    </div>

    <!-- Create Button -->
    <div class="mb-6">
      <RouterLink to="/bhajan/create" class="btn-primary">
        + Create New Bhajan
      </RouterLink>
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
      <p class="mt-4 text-gray-600">Loading your bhajans...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="card bg-red-50 border border-red-200 text-red-700">
      <p>{{ error }}</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredBhajans.length === 0" class="text-center py-12">
      <div class="text-6xl mb-4">📝</div>
      <h3 class="text-xl font-bold text-gray-900 mb-2">No Bhajans Found</h3>
      <p class="text-gray-600 mb-4">
        You haven't created any bhajans yet. Start sharing your devotional songs!
      </p>
      <RouterLink to="/bhajan/create" class="btn-primary inline-block">
        Create Your First Bhajan
      </RouterLink>
    </div>

    <!-- Bhajans Grid -->
    <div v-else>
      <div class="mb-4 text-gray-600">
        {{ filteredBhajans.length }} bhajan{{ filteredBhajans.length !== 1 ? 's' : '' }}
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <BhajanCard
          v-for="bhajan in filteredBhajans"
          :key="bhajan.id"
          :bhajan="bhajan"
          :show-actions="true"
          @edit="editBhajan"
          @delete="deleteBhajan"
          @submit-review="submitForReview"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { useBhajanStore } from '@/stores/bhajanStore'
import { useAuthStore } from '@/stores/authStore'
import BhajanCard from '@/components/BhajanCard.vue'

const router = useRouter()
const bhajanStore = useBhajanStore()
const authStore = useAuthStore()

const selectedStatus = ref('all')

const statusFilters = [
  { label: 'All', value: 'all' },
  { label: 'Draft', value: 'draft' },
  { label: 'Pending Review', value: 'pending_review' },
  { label: 'Approved', value: 'approved' },
  { label: 'Rejected', value: 'rejected' }
]

const loading = computed(() => bhajanStore.loading)
const error = computed(() => bhajanStore.error)

const myBhajans = computed(() => {
  return bhajanStore.bhajans.filter(
    bhajan => bhajan.created_by === authStore.user?.id
  )
})

const filteredBhajans = computed(() => {
  if (selectedStatus.value === 'all') {
    return myBhajans.value
  }
  return myBhajans.value.filter(bhajan => bhajan.status === selectedStatus.value)
})

function editBhajan(id) {
  router.push(`/bhajan/${id}/edit`)
}

async function deleteBhajan(id) {
  const bhajan = myBhajans.value.find(b => b.id === id)
  
  if (!confirm(`Are you sure you want to delete "${bhajan.title}"? This action cannot be undone.`)) {
    return
  }

  const result = await bhajanStore.deleteBhajan(id)
  
  if (result.success) {
    await fetchMyBhajans()
  } else {
    alert('Failed to delete bhajan: ' + result.error)
  }
}

async function submitForReview(id) {
  if (!confirm('Submit this bhajan for review? You won\'t be able to edit it until it\'s reviewed.')) {
    return
  }

  const result = await bhajanStore.submitForReview(id)
  
  if (result.success) {
    await fetchMyBhajans()
    alert('Bhajan submitted for review!')
  } else {
    alert('Failed to submit for review: ' + result.error)
  }
}

async function fetchMyBhajans() {
  await bhajanStore.fetchBhajans({})
}

onMounted(async () => {
  await fetchMyBhajans()
})
</script>
