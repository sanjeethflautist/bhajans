<template>
  <div class="max-w-4xl mx-auto">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Create New Bhajan</h1>
      <p class="text-gray-600">
        Share a devotional bhajan with the community
      </p>
    </div>

    <div class="card">
      <BhajanForm
        :loading="loading"
        @submit="handleSubmit"
        @cancel="handleCancel"
      />
    </div>

    <!-- Success Message -->
    <div v-if="showSuccess" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-8 max-w-md">
        <div class="text-center">
          <div class="text-6xl mb-4">✓</div>
          <h3 class="text-2xl font-bold text-gray-900 mb-2">Bhajan Created!</h3>
          <p class="text-gray-600 mb-6">
            Your bhajan has been created successfully as a draft.
          </p>
          <div class="flex gap-3 justify-center">
            <button @click="goToBhajan" class="btn-primary">
              View Bhajan
            </button>
            <button @click="createAnother" class="btn-secondary">
              Create Another
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useBhajanStore } from '@/stores/bhajanStore'
import BhajanForm from '@/components/BhajanForm.vue'

const router = useRouter()
const bhajanStore = useBhajanStore()

const loading = ref(false)
const showSuccess = ref(false)
const createdBhajanId = ref(null)

async function handleSubmit(formData) {
  loading.value = true

  const { tags, ...bhajanData } = formData
  
  const result = await bhajanStore.createBhajan(bhajanData, tags)

  if (result.success) {
    createdBhajanId.value = result.data.id
    showSuccess.value = true
  } else {
    alert('Failed to create bhajan: ' + result.error)
  }

  loading.value = false
}

function handleCancel() {
  if (confirm('Are you sure you want to cancel? Your changes will be lost.')) {
    router.push('/')
  }
}

function goToBhajan() {
  router.push(`/bhajan/${createdBhajanId.value}`)
}

function createAnother() {
  showSuccess.value = false
  createdBhajanId.value = null
}
</script>
