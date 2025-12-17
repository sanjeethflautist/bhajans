<template>
  <div class="max-w-7xl mx-auto">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Review Queue</h1>
      <p class="text-gray-600">
        Review and approve bhajans submitted by editors
      </p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      <p class="mt-4 text-gray-600">Loading pending reviews...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="card bg-red-50 border border-red-200 text-red-700">
      <p>{{ error }}</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="pendingBhajans.length === 0" class="text-center py-12">
      <div class="text-6xl mb-4">✓</div>
      <h3 class="text-xl font-bold text-gray-900 mb-2">All Caught Up!</h3>
      <p class="text-gray-600">
        No bhajans pending review at the moment
      </p>
      <RouterLink to="/admin" class="btn-secondary inline-block mt-4">
        Back to Dashboard
      </RouterLink>
    </div>

    <!-- Review Queue -->
    <div v-else class="space-y-6">
      <div class="mb-4 text-gray-600">
        {{ pendingBhajans.length }} bhajan{{ pendingBhajans.length !== 1 ? 's' : '' }} pending review
      </div>

      <div
        v-for="bhajan in pendingBhajans"
        :key="bhajan.id"
        class="card"
      >
        <!-- Bhajan Header -->
        <div class="flex justify-between items-start mb-4">
          <div class="flex-1">
            <h3 class="text-xl font-bold text-gray-900 mb-2">{{ bhajan.title }}</h3>
            <p v-if="bhajan.description" class="text-gray-600 mb-2">
              {{ bhajan.description }}
            </p>
            <div class="flex items-center gap-4 text-sm text-gray-500">
              <span>By {{ bhajan.creator?.email }}</span>
              <span>•</span>
              <span>{{ formatDate(bhajan.created_at) }}</span>
            </div>
          </div>
          <button
            @click="toggleExpanded(bhajan.id)"
            class="btn-secondary text-sm"
          >
            {{ expandedBhajanId === bhajan.id ? 'Hide Details' : 'Show Details' }}
          </button>
        </div>

        <!-- Expanded Details -->
        <div v-if="expandedBhajanId === bhajan.id" class="mt-6 pt-6 border-t">
          <!-- Tags -->
          <div v-if="bhajan.tags && bhajan.tags.length > 0" class="mb-4">
            <p class="text-sm font-medium text-gray-700 mb-2">Tags:</p>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="tag in bhajan.tags"
                :key="tag.id"
                class="bg-primary-100 text-primary-700 px-2 py-1 rounded text-sm"
              >
                {{ tag.tag_name }}
              </span>
            </div>
          </div>

          <!-- Lyrics in multiple scripts -->
          <div class="mb-6 space-y-4">
            <p class="text-sm font-medium text-gray-700 mb-2">Lyrics:</p>
            
            <!-- English/Roman Script -->
            <div v-if="bhajan.lyrics" class="bg-gray-50 p-4 rounded-lg">
              <p class="text-xs font-semibold text-gray-600 mb-2">English/Roman Script</p>
              <div class="max-h-64 overflow-y-auto">
                <pre class="whitespace-pre-wrap font-serif text-gray-800 text-sm">{{ bhajan.lyrics }}</pre>
              </div>
            </div>

            <!-- Kannada Script -->
            <div v-if="bhajan.lyrics_kannada" class="bg-gray-50 p-4 rounded-lg">
              <p class="text-xs font-semibold text-gray-600 mb-2">Kannada Script</p>
              <div class="max-h-64 overflow-y-auto">
                <pre class="whitespace-pre-wrap font-serif text-gray-800 text-sm" lang="kn">{{ bhajan.lyrics_kannada }}</pre>
              </div>
            </div>

            <!-- Devanagari Script -->
            <div v-if="bhajan.lyrics_devanagari" class="bg-gray-50 p-4 rounded-lg">
              <p class="text-xs font-semibold text-gray-600 mb-2">Devanagari Script</p>
              <div class="max-h-64 overflow-y-auto">
                <pre class="whitespace-pre-wrap font-serif text-gray-800 text-sm" lang="hi">{{ bhajan.lyrics_devanagari }}</pre>
              </div>
            </div>

            <!-- Meaning -->
            <div v-if="bhajan.meaning" class="bg-blue-50 p-4 rounded-lg border-l-4 border-blue-400">
              <p class="text-xs font-semibold text-blue-800 mb-2">Meaning/Translation</p>
              <div class="max-h-64 overflow-y-auto">
                <pre class="whitespace-pre-wrap font-sans text-gray-800 text-sm">{{ bhajan.meaning }}</pre>
              </div>
            </div>
          </div>

          <!-- Review Panel -->
          <ReviewPanel
            :bhajan="bhajan"
            @approve="handleApprove(bhajan.id, $event)"
            @reject="handleReject(bhajan.id, $event)"
            @cancel="expandedBhajanId = null"
          />
        </div>

        <!-- Quick Actions (when collapsed) -->
        <div v-else class="flex gap-3 mt-4 pt-4 border-t">
          <button
            @click="quickApprove(bhajan.id)"
            class="btn-primary text-sm"
          >
            ✓ Quick Approve
          </button>
          <button
            @click="toggleExpanded(bhajan.id)"
            class="btn-secondary text-sm"
          >
            Review in Detail
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useBhajanStore } from '@/stores/bhajanStore'
import ReviewPanel from '@/components/ReviewPanel.vue'

const bhajanStore = useBhajanStore()

const expandedBhajanId = ref(null)

const loading = computed(() => bhajanStore.loading)
const error = computed(() => bhajanStore.error)
const pendingBhajans = computed(() => bhajanStore.bhajans)

function toggleExpanded(id) {
  expandedBhajanId.value = expandedBhajanId.value === id ? null : id
}

async function quickApprove(id) {
  if (!confirm('Approve this bhajan without a comment?')) {
    return
  }

  await handleApprove(id, '')
}

async function handleApprove(id, comment) {
  const result = await bhajanStore.approveBhajan(id, comment)
  
  if (result.success) {
    expandedBhajanId.value = null
    await fetchPendingBhajans()
  } else {
    alert('Failed to approve bhajan: ' + result.error)
  }
}

async function handleReject(id, comment) {
  const result = await bhajanStore.rejectBhajan(id, comment)
  
  if (result.success) {
    expandedBhajanId.value = null
    await fetchPendingBhajans()
  } else {
    alert('Failed to reject bhajan: ' + result.error)
  }
}

function formatDate(dateString) {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

async function fetchPendingBhajans() {
  await bhajanStore.fetchPendingReviews()
}

onMounted(async () => {
  await fetchPendingBhajans()
})
</script>
