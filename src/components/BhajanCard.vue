<template>
  <div class="card hover:shadow-lg transition-shadow cursor-pointer" @click="navigateToBhajan">
    <!-- Status Badge -->
    <div class="flex justify-between items-start mb-3">
      <div class="flex-1">
        <h3 class="text-xl font-bold text-gray-900">{{ bhajan.title }}</h3>
        <!-- Additional titles in other scripts -->
        <div class="mt-1 space-y-1">
          <p 
            v-if="preferencesStore.isScriptEnabled('kannada') && bhajan.title_kannada"
            class="text-sm text-gray-600"
            lang="kn"
          >
            {{ bhajan.title_kannada }}
          </p>
          <p 
            v-if="preferencesStore.isScriptEnabled('devanagari') && bhajan.title_devanagari"
            class="text-sm text-gray-600"
            lang="hi"
          >
            {{ bhajan.title_devanagari }}
          </p>
        </div>
      </div>
      <span
        :class="statusClasses"
        class="px-3 py-1 rounded-full text-xs font-medium ml-2"
      >
        {{ statusText }}
      </span>
    </div>

    <!-- Description -->
    <p v-if="bhajan.description" class="text-gray-600 mb-4 line-clamp-2">
      {{ bhajan.description }}
    </p>

    <!-- Lyrics Preview -->
    <div class="text-gray-500 text-sm mb-4 space-y-2">
      <div v-for="script in preferencesStore.scriptOptions" :key="script.id">
        <div 
          v-if="preferencesStore.isScriptEnabled(script.id) && bhajan[script.field]"
          class="line-clamp-2 italic"
          :lang="script.id === 'kannada' ? 'kn' : script.id === 'devanagari' ? 'hi' : 'en'"
        >
          <span class="font-semibold text-xs text-gray-400">{{ script.label }}:</span>
          {{ bhajan[script.field] }}
        </div>
      </div>
    </div>

    <!-- Meaning Preview (if enabled) -->
    <div v-if="preferencesStore.showMeaning && bhajan.meaning" class="text-gray-600 text-sm mb-4 p-3 bg-blue-50 rounded border-l-4 border-blue-300">
      <span class="font-semibold text-xs text-blue-600">Meaning:</span>
      <p class="line-clamp-2 mt-1">{{ bhajan.meaning }}</p>
    </div>

    <!-- Tags -->
    <div v-if="bhajan.tags && bhajan.tags.length > 0" class="flex flex-wrap gap-2 mb-4">
      <span
        v-for="tag in bhajan.tags"
        :key="tag.id || tag.tag_name"
        class="bg-primary-100 text-primary-700 px-2 py-1 rounded text-xs"
      >
        {{ tag.tag_name }}
      </span>
    </div>

    <!-- Metadata -->
    <div class="flex justify-between items-center text-sm text-gray-500 pt-4 border-t">
      <span v-if="bhajan.creator">
        By {{ bhajan.creator.email }}
      </span>
      <span>
        {{ formatDate(bhajan.created_at) }}
      </span>
    </div>

    <!-- Action Buttons (for editors/admins) -->
    <div v-if="showActions" class="flex gap-2 mt-4 pt-4 border-t">
      <button
        v-if="canEdit"
        @click.stop="$emit('edit', bhajan.id)"
        class="btn-secondary text-sm"
      >
        Edit
      </button>
      <button
        v-if="canDelete"
        @click.stop="$emit('delete', bhajan.id)"
        class="btn-danger text-sm"
      >
        Delete
      </button>
      <button
        v-if="canSubmitReview && bhajan.status === 'draft'"
        @click.stop="$emit('submit-review', bhajan.id)"
        class="btn-primary text-sm"
      >
        Submit for Review
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { usePreferencesStore } from '@/stores/preferencesStore'

const props = defineProps({
  bhajan: {
    type: Object,
    required: true
  },
  showActions: {
    type: Boolean,
    default: false
  }
})

defineEmits(['edit', 'delete', 'submit-review'])

const router = useRouter()
const authStore = useAuthStore()
const preferencesStore = usePreferencesStore()

const statusClasses = computed(() => {
  const classes = {
    draft: 'bg-gray-200 text-gray-700',
    pending_review: 'bg-yellow-200 text-yellow-800',
    approved: 'bg-green-200 text-green-800',
    rejected: 'bg-red-200 text-red-800'
  }
  return classes[props.bhajan.status] || classes.draft
})

const statusText = computed(() => {
  const texts = {
    draft: 'Draft',
    pending_review: 'Pending Review',
    approved: 'Approved',
    rejected: 'Rejected'
  }
  return texts[props.bhajan.status] || props.bhajan.status
})

const canEdit = computed(() => {
  return authStore.isEditor && 
    (authStore.isAdmin || authStore.user?.id === props.bhajan.created_by)
})

const canDelete = computed(() => {
  return authStore.isAdmin
})

const canSubmitReview = computed(() => {
  return authStore.isEditor && authStore.user?.id === props.bhajan.created_by
})

function navigateToBhajan() {
  router.push(`/bhajan/${props.bhajan.id}`)
}

function formatDate(dateString) {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  })
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
