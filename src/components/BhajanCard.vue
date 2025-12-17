<template>
  <div class="card hover:shadow-lg transition-shadow cursor-pointer relative" @click="navigateToBhajan">
    <!-- Favorite Button (Top Right) -->
    <button
      @click.stop="handleFavoriteClick"
      class="absolute top-3 right-3 p-2 rounded-full hover:bg-gray-100 transition-colors z-10"
      :class="authStore.isAuthenticated ? (isFavorited ? 'text-red-500' : 'text-gray-400') : 'text-gray-300'"
      :title="authStore.isAuthenticated ? (isFavorited ? 'Remove from favorites' : 'Add to favorites') : 'Login to add favorites'"
    >
      <svg class="w-6 h-6" :fill="isFavorited ? 'currentColor' : 'none'" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
      </svg>
    </button>

    <!-- Status Badge and Title -->
    <div class="flex justify-between items-start gap-2 mb-3 pr-12">
      <div class="flex-1 min-w-0">
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
        v-if="showActions && bhajan.status !== 'approved'"
        :class="statusClasses"
        class="px-3 py-1 rounded-full text-xs font-medium whitespace-nowrap flex-shrink-0"
      >
        {{ statusText }}
      </span>
    </div>

    <!-- Tags -->
    <div v-if="bhajan.tags && bhajan.tags.length > 0" class="flex flex-wrap gap-2">
      <span
        v-for="tag in bhajan.tags"
        :key="tag.id || tag.tag_name"
        class="bg-gradient-to-r from-primary-50 to-purple-50 text-primary-700 border border-primary-200 px-2.5 py-1 rounded-full text-xs font-medium"
      >
        {{ tag.tag_name }}
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
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { usePreferencesStore } from '@/stores/preferencesStore'
import { favoritesService } from '@/services/favoritesService'

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
const isFavorited = ref(false)
const isTogglingFavorite = ref(false)

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
  return authStore.isAuthenticated && 
    (authStore.isAdmin || authStore.user?.id === props.bhajan.created_by)
})

const canDelete = computed(() => {
  return authStore.isAdmin
})

const canSubmitReview = computed(() => {
  return authStore.isAuthenticated && authStore.user?.id === props.bhajan.created_by
})

async function checkIfFavorited() {
  if (!authStore.isAuthenticated) {
    isFavorited.value = false
    return
  }
  
  const { data } = await favoritesService.isFavorited(props.bhajan.id)
  isFavorited.value = data || false
}

async function handleFavoriteClick() {
  if (!authStore.isAuthenticated) {
    if (confirm('You need to be logged in to add favorites. Would you like to log in now?')) {
      router.push('/login')
    }
    return
  }
  
  await toggleFavorite()
}

async function toggleFavorite() {
  if (isTogglingFavorite.value) return
  
  isTogglingFavorite.value = true
  try {
    const result = await favoritesService.toggleFavorite(props.bhajan.id)
    if (result.success) {
      isFavorited.value = result.isFavorited
    } else {
      console.error('Error toggling favorite:', result.error)
    }
  } finally {
    isTogglingFavorite.value = false
  }
}

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

onMounted(() => {
  checkIfFavorited()
})
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
