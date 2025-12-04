<template>
  <div class="card">
    <h3 class="text-lg font-bold text-gray-900 mb-4">Report an Issue</h3>

    <form @submit.prevent="handleSubmit" class="space-y-6">
      <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
        {{ error }}
      </div>

      <div v-if="success" class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg">
        Report submitted successfully! Our team will review it soon.
      </div>

      <!-- Bhajan Info -->
      <div class="p-4 bg-gray-50 rounded-lg">
        <p class="text-sm font-medium text-gray-700">Reporting issue for:</p>
        <p class="font-bold text-gray-900">{{ bhajan.title }}</p>
      </div>

      <!-- Issue Type -->
      <div>
        <label for="issueType" class="block text-sm font-medium text-gray-700 mb-2">
          Issue Type <span class="text-red-500">*</span>
        </label>
        <select
          id="issueType"
          v-model="formData.issue_type"
          required
          class="input-field"
        >
          <option value="">Select an issue type</option>
          <option value="incorrect_lyrics">Incorrect Lyrics</option>
          <option value="offensive_content">Offensive Content</option>
          <option value="copyright">Copyright Issue</option>
          <option value="other">Other</option>
        </select>
      </div>

      <!-- Description -->
      <div>
        <label for="description" class="block text-sm font-medium text-gray-700 mb-2">
          Description <span class="text-red-500">*</span>
        </label>
        <textarea
          id="description"
          v-model="formData.description"
          rows="5"
          required
          class="input-field"
          placeholder="Please provide details about the issue..."
        ></textarea>
        <p class="text-sm text-gray-500 mt-1">
          {{ formData.description.length }} / 1000 characters
        </p>
      </div>

      <!-- Action Buttons -->
      <div class="flex gap-3">
        <button
          type="submit"
          :disabled="loading || success"
          class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ loading ? 'Submitting...' : 'Submit Report' }}
        </button>
        
        <button
          type="button"
          @click="$emit('cancel')"
          class="btn-secondary"
        >
          Cancel
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useReportStore } from '@/stores/reportStore'

const props = defineProps({
  bhajan: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['success', 'cancel'])

const reportStore = useReportStore()

const formData = reactive({
  bhajan_id: props.bhajan.id,
  issue_type: '',
  description: ''
})

const loading = ref(false)
const error = ref('')
const success = ref(false)

async function handleSubmit() {
  error.value = ''
  loading.value = true

  if (!formData.issue_type) {
    error.value = 'Please select an issue type'
    loading.value = false
    return
  }

  if (!formData.description.trim()) {
    error.value = 'Please provide a description'
    loading.value = false
    return
  }

  if (formData.description.length > 1000) {
    error.value = 'Description is too long (max 1000 characters)'
    loading.value = false
    return
  }

  const result = await reportStore.createReport(formData)

  if (result.success) {
    success.value = true
    setTimeout(() => {
      emit('success')
    }, 2000)
  } else {
    error.value = result.error || 'Failed to submit report. Please try again.'
  }

  loading.value = false
}
</script>
