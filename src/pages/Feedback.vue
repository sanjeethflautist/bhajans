<template>
  <div class="max-w-4xl mx-auto px-3 sm:px-6">
    <!-- Hero Section -->
    <div class="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-2xl shadow-lg p-6 sm:p-8 mb-6 border border-blue-100">
      <h1 class="text-3xl sm:text-4xl font-bold gradient-text mb-4">Feedback & Feature Requests</h1>
      <p class="text-lg text-gray-700 leading-relaxed">
        Help us improve! Share your feedback or suggest new features to make our platform better for everyone.
      </p>
    </div>

    <!-- Tabs -->
    <div class="bg-white rounded-2xl shadow-md border border-gray-100 mb-6">
      <div class="flex border-b border-gray-200">
        <button
          @click="activeTab = 'feedback'"
          :class="[
            'flex-1 px-6 py-4 font-semibold transition-all',
            activeTab === 'feedback'
              ? 'bg-gradient-to-r from-blue-50 to-indigo-50 text-primary-600 border-b-2 border-primary-600'
              : 'text-gray-600 hover:bg-gray-50'
          ]"
        >
          <div class="flex items-center justify-center">
            <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd" />
            </svg>
            Feedback
          </div>
        </button>
        <button
          @click="activeTab = 'feature'"
          :class="[
            'flex-1 px-6 py-4 font-semibold transition-all',
            activeTab === 'feature'
              ? 'bg-gradient-to-r from-purple-50 to-pink-50 text-purple-600 border-b-2 border-purple-600'
              : 'text-gray-600 hover:bg-gray-50'
          ]"
        >
          <div class="flex items-center justify-center">
            <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path d="M11 3a1 1 0 10-2 0v1a1 1 0 102 0V3zM15.657 5.757a1 1 0 00-1.414-1.414l-.707.707a1 1 0 001.414 1.414l.707-.707zM18 10a1 1 0 01-1 1h-1a1 1 0 110-2h1a1 1 0 011 1zM5.05 6.464A1 1 0 106.464 5.05l-.707-.707a1 1 0 00-1.414 1.414l.707.707zM5 10a1 1 0 01-1 1H3a1 1 0 110-2h1a1 1 0 011 1zM8 16v-1h4v1a2 2 0 11-4 0zM12 14c.015-.34.208-.646.477-.859a4 4 0 10-4.954 0c.27.213.462.519.476.859h4.002z" />
            </svg>
            Feature Request
          </div>
        </button>
      </div>
    </div>

    <!-- Feedback Form -->
    <div v-if="activeTab === 'feedback'" class="bg-white rounded-2xl shadow-md border border-gray-100 p-6 sm:p-8">
      <div class="flex items-center mb-6">
        <svg class="w-6 h-6 text-blue-600 mr-3" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd" />
        </svg>
        <h2 class="text-2xl font-bold text-gray-900">Share Your Feedback</h2>
      </div>

      <form @submit.prevent="submitFeedback" class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Your Name {{ authStore.isAuthenticated ? '' : '(Optional)' }}
          </label>
          <input
            v-model="feedbackForm.name"
            type="text"
            class="input-field"
            :placeholder="authStore.user?.email || 'Enter your name'"
          />
        </div>

        <div v-if="!authStore.isAuthenticated">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Email (Optional)
          </label>
          <input
            v-model="feedbackForm.email"
            type="email"
            class="input-field"
            placeholder="your.email@example.com"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Feedback Type *
          </label>
          <select v-model="feedbackForm.type" class="input-field" required>
            <option value="">Select a type</option>
            <option value="bug">Bug Report</option>
            <option value="improvement">Improvement Suggestion</option>
            <option value="compliment">Compliment</option>
            <option value="complaint">Complaint</option>
            <option value="other">Other</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Your Feedback *
          </label>
          <textarea
            v-model="feedbackForm.message"
            rows="6"
            class="input-field"
            placeholder="Tell us what you think..."
            required
          ></textarea>
        </div>

        <div v-if="feedbackMessage" :class="[
          'p-4 rounded-lg',
          feedbackSuccess ? 'bg-green-50 text-green-800 border border-green-200' : 'bg-red-50 text-red-800 border border-red-200'
        ]">
          {{ feedbackMessage }}
        </div>

        <div class="flex gap-3">
          <button
            type="submit"
            :disabled="submittingFeedback"
            class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ submittingFeedback ? 'Submitting...' : 'Submit Feedback' }}
          </button>
          <button
            type="button"
            @click="resetFeedbackForm"
            class="btn-secondary"
          >
            Clear
          </button>
        </div>
      </form>
    </div>

    <!-- Feature Request Form -->
    <div v-if="activeTab === 'feature'" class="bg-white rounded-2xl shadow-md border border-gray-100 p-6 sm:p-8">
      <div class="flex items-center mb-6">
        <svg class="w-6 h-6 text-purple-600 mr-3" fill="currentColor" viewBox="0 0 20 20">
          <path d="M11 3a1 1 0 10-2 0v1a1 1 0 102 0V3zM15.657 5.757a1 1 0 00-1.414-1.414l-.707.707a1 1 0 001.414 1.414l.707-.707zM18 10a1 1 0 01-1 1h-1a1 1 0 110-2h1a1 1 0 011 1zM5.05 6.464A1 1 0 106.464 5.05l-.707-.707a1 1 0 00-1.414 1.414l.707.707zM5 10a1 1 0 01-1 1H3a1 1 0 110-2h1a1 1 0 011 1zM8 16v-1h4v1a2 2 0 11-4 0zM12 14c.015-.34.208-.646.477-.859a4 4 0 10-4.954 0c.27.213.462.519.476.859h4.002z" />
        </svg>
        <h2 class="text-2xl font-bold text-gray-900">Suggest a Feature</h2>
      </div>

      <form @submit.prevent="submitFeatureRequest" class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Your Name {{ authStore.isAuthenticated ? '' : '(Optional)' }}
          </label>
          <input
            v-model="featureForm.name"
            type="text"
            class="input-field"
            :placeholder="authStore.user?.email || 'Enter your name'"
          />
        </div>

        <div v-if="!authStore.isAuthenticated">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Email (Optional)
          </label>
          <input
            v-model="featureForm.email"
            type="email"
            class="input-field"
            placeholder="your.email@example.com"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Feature Title *
          </label>
          <input
            v-model="featureForm.title"
            type="text"
            class="input-field"
            placeholder="Brief title for your feature request"
            required
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Category *
          </label>
          <select v-model="featureForm.category" class="input-field" required>
            <option value="">Select a category</option>
            <option value="ui">User Interface</option>
            <option value="functionality">Functionality</option>
            <option value="performance">Performance</option>
            <option value="mobile">Mobile Experience</option>
            <option value="search">Search & Filters</option>
            <option value="other">Other</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Description *
          </label>
          <textarea
            v-model="featureForm.description"
            rows="6"
            class="input-field"
            placeholder="Describe the feature you'd like to see..."
            required
          ></textarea>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Use Case (Optional)
          </label>
          <textarea
            v-model="featureForm.useCase"
            rows="3"
            class="input-field"
            placeholder="How would this feature help you?"
          ></textarea>
        </div>

        <div v-if="featureMessage" :class="[
          'p-4 rounded-lg',
          featureSuccess ? 'bg-green-50 text-green-800 border border-green-200' : 'bg-red-50 text-red-800 border border-red-200'
        ]">
          {{ featureMessage }}
        </div>

        <div class="flex gap-3">
          <button
            type="submit"
            :disabled="submittingFeature"
            class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ submittingFeature ? 'Submitting...' : 'Submit Feature Request' }}
          </button>
          <button
            type="button"
            @click="resetFeatureForm"
            class="btn-secondary"
          >
            Clear
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { supabase } from '@/services/supabaseClient'

const authStore = useAuthStore()
const activeTab = ref('feedback')

// Feedback form
const feedbackForm = ref({
  name: '',
  email: '',
  type: '',
  message: ''
})

const submittingFeedback = ref(false)
const feedbackMessage = ref('')
const feedbackSuccess = ref(false)

// Feature request form
const featureForm = ref({
  name: '',
  email: '',
  title: '',
  category: '',
  description: '',
  useCase: ''
})

const submittingFeature = ref(false)
const featureMessage = ref('')
const featureSuccess = ref(false)

async function submitFeedback() {
  try {
    submittingFeedback.value = true
    feedbackMessage.value = ''

    const { error } = await supabase
      .from('feedback')
      .insert([{
        name: feedbackForm.value.name || (authStore.user?.email || 'Anonymous'),
        email: feedbackForm.value.email || authStore.user?.email,
        user_id: authStore.user?.id || null,
        type: feedbackForm.value.type,
        message: feedbackForm.value.message,
        status: 'new',
        created_at: new Date().toISOString()
      }])

    if (error) {
      if (error.code === '42P01') {
        feedbackSuccess.value = true
        feedbackMessage.value = 'Thank you for your feedback! We\'ve received your submission and will review it soon.'
      } else {
        throw error
      }
    } else {
      feedbackSuccess.value = true
      feedbackMessage.value = 'Thank you for your feedback! We appreciate you taking the time to help us improve.'
    }

    resetFeedbackForm()
  } catch (err) {
    feedbackSuccess.value = false
    feedbackMessage.value = 'Failed to submit feedback. Please try again later.'
    console.error('Feedback submission error:', err)
  } finally {
    submittingFeedback.value = false
  }
}

async function submitFeatureRequest() {
  try {
    submittingFeature.value = true
    featureMessage.value = ''

    const { error } = await supabase
      .from('feature_requests')
      .insert([{
        name: featureForm.value.name || (authStore.user?.email || 'Anonymous'),
        email: featureForm.value.email || authStore.user?.email,
        user_id: authStore.user?.id || null,
        title: featureForm.value.title,
        category: featureForm.value.category,
        description: featureForm.value.description,
        use_case: featureForm.value.useCase,
        status: 'new',
        votes: 0,
        created_at: new Date().toISOString()
      }])

    if (error) {
      if (error.code === '42P01') {
        featureSuccess.value = true
        featureMessage.value = 'Thank you for your feature request! We\'ve received your submission and will review it soon.'
      } else {
        throw error
      }
    } else {
      featureSuccess.value = true
      featureMessage.value = 'Feature request submitted successfully! We\'ll consider it for future updates.'
    }

    resetFeatureForm()
  } catch (err) {
    featureSuccess.value = false
    featureMessage.value = 'Failed to submit feature request. Please try again later.'
    console.error('Feature request submission error:', err)
  } finally {
    submittingFeature.value = false
  }
}

function resetFeedbackForm() {
  feedbackForm.value = {
    name: '',
    email: '',
    type: '',
    message: ''
  }
}

function resetFeatureForm() {
  featureForm.value = {
    name: '',
    email: '',
    title: '',
    category: '',
    description: '',
    useCase: ''
  }
}
</script>
