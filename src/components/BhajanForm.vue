<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
      {{ error }}
    </div>

    <!-- Title -->
    <div>
      <label for="title" class="block text-sm font-medium text-gray-700 mb-2">
        Title <span class="text-red-500">*</span>
      </label>
      <input
        id="title"
        v-model="formData.title"
        type="text"
        required
        class="input-field"
        placeholder="Enter bhajan title"
      />
    </div>

    <!-- Description -->
    <div>
      <label for="description" class="block text-sm font-medium text-gray-700 mb-2">
        Description
      </label>
      <textarea
        id="description"
        v-model="formData.description"
        rows="3"
        class="input-field"
        placeholder="Brief description of the bhajan"
      ></textarea>
    </div>

    <!-- Lyrics -->
    <div>
      <label for="lyrics" class="block text-sm font-medium text-gray-700 mb-2">
        Lyrics <span class="text-red-500">*</span>
      </label>
      <textarea
        id="lyrics"
        v-model="formData.lyrics"
        rows="10"
        required
        class="input-field font-mono"
        placeholder="Enter the full lyrics of the bhajan"
      ></textarea>
      <p class="text-sm text-gray-500 mt-1">
        {{ formData.lyrics.length }} characters
      </p>
    </div>

    <!-- Tags -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">
        Tags
      </label>
      <TagSelector v-model="formData.tags" />
    </div>

    <!-- Status (for edit mode) -->
    <div v-if="isEditMode && authStore.isAdmin">
      <label for="status" class="block text-sm font-medium text-gray-700 mb-2">
        Status
      </label>
      <select
        id="status"
        v-model="formData.status"
        class="input-field"
      >
        <option value="draft">Draft</option>
        <option value="pending_review">Pending Review</option>
        <option value="approved">Approved</option>
        <option value="rejected">Rejected</option>
      </select>
    </div>

    <!-- Action Buttons -->
    <div class="flex gap-3">
      <button
        type="submit"
        :disabled="loading"
        class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {{ loading ? 'Saving...' : (isEditMode ? 'Update Bhajan' : 'Create Bhajan') }}
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
</template>

<script setup>
import { ref, watch } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import TagSelector from './TagSelector.vue'

const props = defineProps({
  bhajan: {
    type: Object,
    default: null
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['submit', 'cancel'])

const authStore = useAuthStore()
const error = ref('')

const isEditMode = ref(!!props.bhajan)

const formData = ref({
  title: props.bhajan?.title || '',
  description: props.bhajan?.description || '',
  lyrics: props.bhajan?.lyrics || '',
  tags: props.bhajan?.tags?.map(t => t.tag_name) || [],
  status: props.bhajan?.status || 'draft'
})

// Watch for changes in bhajan prop (for edit mode)
watch(() => props.bhajan, (newBhajan) => {
  if (newBhajan) {
    formData.value = {
      title: newBhajan.title || '',
      description: newBhajan.description || '',
      lyrics: newBhajan.lyrics || '',
      tags: newBhajan.tags?.map(t => t.tag_name) || [],
      status: newBhajan.status || 'draft'
    }
    isEditMode.value = true
  }
})

function handleSubmit() {
  error.value = ''

  if (!formData.value.title.trim()) {
    error.value = 'Title is required'
    return
  }

  if (!formData.value.lyrics.trim()) {
    error.value = 'Lyrics are required'
    return
  }

  emit('submit', formData.value)
}
</script>
