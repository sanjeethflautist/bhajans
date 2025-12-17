<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-primary-100">
    <div class="max-w-md w-full bg-white rounded-xl shadow-lg p-8">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Forgot Password?</h1>
        <p class="text-gray-600">Enter your email to receive a password reset link</p>
      </div>

      <!-- Success Message -->
      <div v-if="emailSent" class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg mb-6">
        <p class="font-medium mb-1">Email sent!</p>
        <p class="text-sm">Check your inbox for password reset instructions. The link will expire in 1 hour.</p>
      </div>

      <!-- Form (hidden after successful submission) -->
      <form v-if="!emailSent" @submit.prevent="handleForgotPassword" class="space-y-6">
        <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
          {{ error }}
        </div>

        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
            Email Address
          </label>
          <input
            id="email"
            v-model="email"
            type="email"
            required
            class="input-field"
            placeholder="you@example.com"
            :disabled="loading"
          />
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ loading ? 'Sending...' : 'Send Reset Link' }}
        </button>
      </form>

      <div class="mt-6 text-center space-y-2">
        <p class="text-gray-600">
          <RouterLink to="/login" class="text-primary-600 hover:text-primary-700 font-medium">
            Back to Login
          </RouterLink>
        </p>
        <p class="text-gray-600 text-sm">
          Don't have an account?
          <RouterLink to="/signup" class="text-primary-600 hover:text-primary-700 font-medium">
            Sign up
          </RouterLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
import { authService } from '@/services/authService'

const email = ref('')
const loading = ref(false)
const error = ref('')
const emailSent = ref(false)

async function handleForgotPassword() {
  loading.value = true
  error.value = ''

  try {
    const result = await authService.sendPasswordResetEmail(email.value)

    if (result.error) {
      error.value = result.error.message || 'Failed to send reset email. Please try again.'
    } else {
      emailSent.value = true
    }
  } catch (err) {
    error.value = 'An unexpected error occurred. Please try again.'
    console.error('Forgot password error:', err)
  } finally {
    loading.value = false
  }
}
</script>
