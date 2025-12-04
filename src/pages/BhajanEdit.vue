<template>
  <div class="max-w-4xl mx-auto">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Edit Bhajan</h1>
      <p class="text-gray-600">
        Update the bhajan details
      </p>
    </div>

    <!-- Loading State -->
    <div v-if="loadingBhajan" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      <p class="mt-4 text-gray-600">Loading bhajan...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="card bg-red-50 border border-red-200 text-red-700">
      <p>{{ error }}</p>
      <RouterLink to="/" class="btn-secondary inline-block mt-4">
        Go Back Home
      </RouterLink>
    </div>

    <!-- Edit Form -->
    <div v-else-if="bhajan" class="card">
      <BhajanForm
        :bhajan="bhajan"
        :loading="saving"
        @submit="handleSubmit"
        @cancel="handleCancel"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { useBhajanStore } from '@/stores/bhajanStore'
import { useAuthStore } from '@/stores/authStore'
import BhajanForm from '@/components/BhajanForm.vue'

const route = useRoute()
const router = useRouter()
const bhajanStore = useBhajanStore()
const authStore = useAuthStore()

const saving = ref(false)

const loadingBhajan = computed(() => bhajanStore.loading)
const error = computed(() => bhajanStore.error)
const bhajan = computed(() => bhajanStore.currentBhajan)

async function handleSubmit(formData) {
  saving.value = true

  const { tags, ...updates } = formData
  
  const result = await bhajanStore.updateBhajan(
    route.params.id,
    updates,
    tags
  )

  if (result.success) {
    router.push(`/bhajan/${route.params.id}`)
  } else {
    alert('Failed to update bhajan: ' + result.error)
  }

  saving.value = false
}

function handleCancel() {
  router.push(`/bhajan/${route.params.id}`)
}

onMounted(async () => {
  await bhajanStore.fetchBhajanById(route.params.id)
  
  // Check permissions
  if (bhajan.value) {
    const canEdit = authStore.isAdmin || 
      (authStore.isEditor && authStore.user.id === bhajan.value.created_by)
    
    if (!canEdit) {
      alert('You do not have permission to edit this bhajan')
      router.push(`/bhajan/${route.params.id}`)
    }
  }
})
</script>
