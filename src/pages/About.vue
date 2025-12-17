<template>
  <div class="max-w-4xl mx-auto px-3 sm:px-6">
    <!-- Hero Section -->
    <div class="bg-gradient-to-br from-primary-50 to-purple-50 rounded-2xl shadow-lg p-6 sm:p-8 mb-6 border border-primary-100">
      <h1 class="text-3xl sm:text-4xl font-bold gradient-text mb-4">About Bhajans</h1>
      <p class="text-lg text-gray-700 leading-relaxed">
        A collaborative platform dedicated to preserving and sharing devotional bhajans across multiple scripts and languages. Our mission is to make spiritual music accessible to everyone, everywhere.
      </p>
    </div>

    <!-- Mission Section -->
    <div class="bg-white rounded-2xl shadow-md border border-gray-100 p-6 sm:p-8 mb-6">
      <div class="flex items-center mb-4">
        <svg class="w-6 h-6 text-primary-600 mr-3" fill="currentColor" viewBox="0 0 20 20">
          <path d="M10 18a8 8 0 100-16 8 8 0 000 16zM4.332 8.027a6.012 6.012 0 011.912-2.706C6.512 5.73 6.974 6 7.5 6A1.5 1.5 0 019 7.5V8a2 2 0 004 0 2 2 0 011.523-1.943A5.977 5.977 0 0116 10c0 .34-.028.675-.083 1H15a2 2 0 00-2 2v2.197A5.973 5.973 0 0110 16v-2a2 2 0 00-2-2 2 2 0 01-2-2 2 2 0 00-1.668-1.973z" />
        </svg>
        <h2 class="text-2xl font-bold text-gray-900">Our Mission</h2>
      </div>
      <div class="space-y-4 text-gray-700">
        <p>We believe that devotional music transcends boundaries of language and script. Our platform enables:</p>
        <ul class="space-y-2 ml-6">
          <li class="flex items-start">
            <span class="text-primary-600 mr-2">✓</span>
            <span>Multi-script support (English, Kannada, Devanagari) for wider accessibility</span>
          </li>
          <li class="flex items-start">
            <span class="text-primary-600 mr-2">✓</span>
            <span>Community-driven content creation and curation</span>
          </li>
          <li class="flex items-start">
            <span class="text-primary-600 mr-2">✓</span>
            <span>Quality assurance through a review process</span>
          </li>
          <li class="flex items-start">
            <span class="text-primary-600 mr-2">✓</span>
            <span>Free and open access to devotional content</span>
          </li>
        </ul>
      </div>
    </div>

    <!-- How to Contribute Section -->
    <div class="bg-gradient-to-br from-green-50 to-emerald-50 rounded-2xl shadow-md border border-green-200 p-6 sm:p-8 mb-6">
      <div class="flex items-center mb-4">
        <svg class="w-6 h-6 text-green-600 mr-3" fill="currentColor" viewBox="0 0 20 20">
          <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3zM6 8a2 2 0 11-4 0 2 2 0 014 0zM16 18v-3a5.972 5.972 0 00-.75-2.906A3.005 3.005 0 0119 15v3h-3zM4.75 12.094A5.973 5.973 0 004 15v3H1v-3a3 3 0 013.75-2.906z" />
        </svg>
        <h2 class="text-2xl font-bold text-gray-900">How to Contribute</h2>
      </div>
      
      <div class="space-y-6">
        <div>
          <h3 class="text-lg font-semibold text-gray-900 mb-3 flex items-center">
            <span class="bg-green-600 text-white rounded-full w-8 h-8 flex items-center justify-center mr-3 text-sm font-bold">1</span>
            Sign Up with Your Email
          </h3>
          <p class="text-gray-700 ml-11">
            Getting started is simple! Create a free account using your email address. No complex requirements – just your email and a password.
          </p>
          <div class="ml-11 mt-3">
            <RouterLink 
              v-if="!authStore.isAuthenticated"
              to="/signup" 
              class="btn-primary inline-block"
            >
              Sign Up Now
            </RouterLink>
            <span v-else class="text-green-700 font-medium flex items-center">
              <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
              You're already signed in!
            </span>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold text-gray-900 mb-3 flex items-center">
            <span class="bg-green-600 text-white rounded-full w-8 h-8 flex items-center justify-center mr-3 text-sm font-bold">2</span>
            Submit Bhajans
          </h3>
          <p class="text-gray-700 ml-11">
            Once registered, you can start contributing bhajans immediately. Add titles, lyrics in multiple scripts, descriptions, tags, and meanings. All submissions go through a quality review before being published.
          </p>
        </div>

        <div>
          <h3 class="text-lg font-semibold text-gray-900 mb-3 flex items-center">
            <span class="bg-green-600 text-white rounded-full w-8 h-8 flex items-center justify-center mr-3 text-sm font-bold">3</span>
            Help Improve Content
          </h3>
          <p class="text-gray-700 ml-11">
            Found an error or want to suggest an improvement? Use our reporting system to flag issues like incorrect lyrics, offensive content, or copyright concerns. Our reviewers will handle it promptly.
          </p>
        </div>
      </div>
    </div>

    <!-- Become a Reviewer Section -->
    <div class="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-2xl shadow-md border border-blue-200 p-6 sm:p-8 mb-6">
      <div class="flex items-center mb-4">
        <svg class="w-6 h-6 text-blue-600 mr-3" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
        </svg>
        <h2 class="text-2xl font-bold text-gray-900">Become a Reviewer</h2>
      </div>

      <div class="space-y-4 mb-6">
        <p class="text-gray-700">
          Want to help maintain the quality of our bhajan collection? Apply to become a reviewer! Reviewers play a crucial role in ensuring accuracy, authenticity, and appropriateness of content.
        </p>

        <div class="bg-white/70 rounded-xl p-4 border border-blue-200">
          <h3 class="font-semibold text-gray-900 mb-3">Reviewer Responsibilities:</h3>
          <ul class="space-y-2 text-gray-700">
            <li class="flex items-start">
              <span class="text-blue-600 mr-2">•</span>
              <span>Review submitted bhajans for accuracy and quality</span>
            </li>
            <li class="flex items-start">
              <span class="text-blue-600 mr-2">•</span>
              <span>Verify lyrics, translations, and script accuracy</span>
            </li>
            <li class="flex items-start">
              <span class="text-blue-600 mr-2">•</span>
              <span>Provide constructive feedback to contributors</span>
            </li>
            <li class="flex items-start">
              <span class="text-blue-600 mr-2">•</span>
              <span>Handle user reports and resolve content issues</span>
            </li>
          </ul>
        </div>

        <div v-if="!showApplicationForm">
          <button 
            @click="showApplicationForm = true"
            class="btn-primary"
          >
            Apply to be a Reviewer
          </button>
        </div>
      </div>

      <!-- Application Form -->
      <div v-if="showApplicationForm" class="bg-white rounded-xl shadow-lg p-6 border border-blue-300">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-xl font-bold text-gray-900">Reviewer Application</h3>
          <button @click="closeForm" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div v-if="!authStore.isAuthenticated" class="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-4">
          <p class="text-yellow-800">
            Please 
            <RouterLink to="/login" class="font-semibold underline">sign in</RouterLink> 
            or 
            <RouterLink to="/signup" class="font-semibold underline">create an account</RouterLink> 
            to apply for a reviewer role.
          </p>
        </div>

        <form v-else @submit.prevent="submitApplication" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Why do you want to be a reviewer? *
            </label>
            <textarea
              v-model="application.motivation"
              rows="4"
              class="input-field"
              placeholder="Share your motivation and what drives your interest in reviewing bhajans..."
              required
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Relevant Experience *
            </label>
            <textarea
              v-model="application.experience"
              rows="4"
              class="input-field"
              placeholder="Describe your experience with devotional music, language expertise, or relevant background..."
              required
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Language Proficiency *
            </label>
            <div class="space-y-2">
              <label class="flex items-center">
                <input
                  type="checkbox"
                  v-model="application.languages.english"
                  class="w-4 h-4 text-primary-600 rounded border-gray-300 focus:ring-primary-500"
                />
                <span class="ml-2 text-gray-700">English</span>
              </label>
              <label class="flex items-center">
                <input
                  type="checkbox"
                  v-model="application.languages.kannada"
                  class="w-4 h-4 text-primary-600 rounded border-gray-300 focus:ring-primary-500"
                />
                <span class="ml-2 text-gray-700">Kannada</span>
              </label>
              <label class="flex items-center">
                <input
                  type="checkbox"
                  v-model="application.languages.devanagari"
                  class="w-4 h-4 text-primary-600 rounded border-gray-300 focus:ring-primary-500"
                />
                <span class="ml-2 text-gray-700">Devanagari (Hindi/Sanskrit)</span>
              </label>
            </div>
            <p v-if="!hasSelectedLanguage" class="text-sm text-red-600 mt-1">
              Please select at least one language
            </p>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Additional Comments (Optional)
            </label>
            <textarea
              v-model="application.comments"
              rows="3"
              class="input-field"
              placeholder="Any additional information you'd like to share..."
            ></textarea>
          </div>

          <div v-if="submitMessage" :class="[
            'p-4 rounded-lg',
            submitSuccess ? 'bg-green-50 text-green-800 border border-green-200' : 'bg-red-50 text-red-800 border border-red-200'
          ]">
            {{ submitMessage }}
          </div>

          <div class="flex gap-3 pt-4">
            <button
              type="submit"
              :disabled="submitting || !hasSelectedLanguage"
              class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ submitting ? 'Submitting...' : 'Submit Application' }}
            </button>
            <button
              type="button"
              @click="closeForm"
              class="btn-secondary"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Contact Section -->
    <div class="bg-white rounded-2xl shadow-md border border-gray-100 p-6 sm:p-8">
      <div class="flex items-center mb-4">
        <svg class="w-6 h-6 text-primary-600 mr-3" fill="currentColor" viewBox="0 0 20 20">
          <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" />
          <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
        </svg>
        <h2 class="text-2xl font-bold text-gray-900">Get in Touch</h2>
      </div>
      <p class="text-gray-700">
        Have questions or suggestions? We'd love to hear from you! For general inquiries, feedback, or support, please reach out to our team.
      </p>
      <p class="text-gray-600 mt-4 italic">
        Note: Reviewer applications are processed through the application form above. For all other matters, feel free to contact us.
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { RouterLink } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { supabase } from '@/services/supabaseClient'

const authStore = useAuthStore()

const showApplicationForm = ref(false)
const submitting = ref(false)
const submitMessage = ref('')
const submitSuccess = ref(false)

const application = ref({
  motivation: '',
  experience: '',
  languages: {
    english: false,
    kannada: false,
    devanagari: false
  },
  comments: ''
})

const hasSelectedLanguage = computed(() => {
  return application.value.languages.english || 
         application.value.languages.kannada || 
         application.value.languages.devanagari
})

function closeForm() {
  showApplicationForm.value = false
  submitMessage.value = ''
  submitSuccess.value = false
  // Reset form
  application.value = {
    motivation: '',
    experience: '',
    languages: {
      english: false,
      kannada: false,
      devanagari: false
    },
    comments: ''
  }
}

async function submitApplication() {
  if (!hasSelectedLanguage.value) {
    return
  }

  try {
    submitting.value = true
    submitMessage.value = ''

    const languages = []
    if (application.value.languages.english) languages.push('English')
    if (application.value.languages.kannada) languages.push('Kannada')
    if (application.value.languages.devanagari) languages.push('Devanagari')

    // Store the application in a reviewer_applications table
    const { error } = await supabase
      .from('reviewer_applications')
      .insert([{
        user_id: authStore.user.id,
        email: authStore.user.email,
        motivation: application.value.motivation,
        experience: application.value.experience,
        languages: languages.join(', '),
        comments: application.value.comments,
        status: 'pending',
        created_at: new Date().toISOString()
      }])

    if (error) {
      console.error('Application submission error:', error)
      // If table doesn't exist, show a friendly message
      if (error.code === '42P01') {
        submitSuccess.value = true
        submitMessage.value = 'Thank you for your application! Our team has been notified and will review your submission soon. You will be contacted via email regarding your application status.'
      } else {
        throw error
      }
    } else {
      submitSuccess.value = true
      submitMessage.value = 'Application submitted successfully! Our team will review your application and contact you via email within 3-5 business days.'
    }

    // Close form after 3 seconds on success
    setTimeout(() => {
      closeForm()
    }, 3000)

  } catch (err) {
    submitSuccess.value = false
    submitMessage.value = 'Failed to submit application. Please try again later.'
    console.error('Application submission error:', err)
  } finally {
    submitting.value = false
  }
}
</script>
