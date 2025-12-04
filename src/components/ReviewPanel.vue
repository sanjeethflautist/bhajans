<template>
  <div class="card">
    <h3 class="text-lg font-bold text-gray-900 mb-4">Review Bhajan</h3>

    <!-- Bhajan Info -->
    <div class="mb-6 p-4 bg-gray-50 rounded-lg">
      <h4 class="font-bold text-gray-900 mb-2">{{ bhajan.title }}</h4>
      <p v-if="bhajan.description" class="text-sm text-gray-600 mb-2">
        {{ bhajan.description }}
      </p>
      <div class="flex items-center gap-4 text-sm text-gray-500">
        <span>By {{ bhajan.creator?.email }}</span>
        <span>•</span>
        <span>{{ formatDate(bhajan.created_at) }}</span>
      </div>
    </div>

    <!-- Review Comment -->
    <div class="mb-6">
      <label for="reviewComment" class="block text-sm font-medium text-gray-700 mb-2">
        Review Comment
      </label>
      <textarea
        id="reviewComment"
        v-model="reviewComment"
        rows="4"
        class="input-field"
        placeholder="Provide feedback for the submitter..."
      ></textarea>
    </div>

    <!-- Previous Review (if any) -->
    <div v-if="bhajan.review_comment" class="mb-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
      <p class="text-sm font-medium text-gray-700 mb-1">Previous Review:</p>
      <p class="text-sm text-gray-600">{{ bhajan.review_comment }}</p>
      <p v-if="bhajan.reviewer" class="text-xs text-gray-500 mt-2">
        By {{ bhajan.reviewer.email }} on {{ formatDate(bhajan.reviewed_at) }}
      </p>
    </div>

    <!-- Action Buttons -->
    <div class="flex gap-3">
      <button
        @click="handleApprove"
        :disabled="loading"
        class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {{ loading === 'approve' ? 'Approving...' : '✓ Approve' }}
      </button>
      
      <button
        @click="handleReject"
        :disabled="loading"
        class="btn-danger disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {{ loading === 'reject' ? 'Rejecting...' : '✗ Reject' }}
      </button>

      <button
        @click="$emit('cancel')"
        class="btn-secondary"
      >
        Cancel
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  bhajan: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['approve', 'reject', 'cancel'])

const reviewComment = ref('')
const loading = ref(null)

async function handleApprove() {
  if (!reviewComment.value.trim() && !confirm('Approve without a comment?')) {
    return
  }
  
  loading.value = 'approve'
  emit('approve', reviewComment.value)
  // Reset loading in parent component after action completes
}

async function handleReject() {
  if (!reviewComment.value.trim()) {
    alert('Please provide a reason for rejection')
    return
  }
  
  loading.value = 'reject'
  emit('reject', reviewComment.value)
  // Reset loading in parent component after action completes
}

function formatDate(dateString) {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>
