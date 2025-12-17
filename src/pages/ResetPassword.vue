<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-primary-100">
    <div class="max-w-md w-full bg-white rounded-xl shadow-lg p-8">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Reset Password</h1>
        <p class="text-gray-600">Enter your new password below</p>
      </div>

      <!-- Success Message -->
      <div v-if="passwordReset" class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg mb-6">
        <p class="font-medium mb-1">Password updated!</p>
        <p class="text-sm">Your password has been successfully reset. You can now log in with your new password.</p>
        <div class="mt-4">
          <RouterLink to="/login" class="btn-primary inline-block">
            Go to Login
          </RouterLink>
        </div>
      </div>

      <!-- Form (hidden after successful reset) -->
      <form v-if="!passwordReset" @submit.prevent="handleResetPassword" class="space-y-6">
        <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
          {{ error }}
        </div>

        <div v-if="!hasValidSession" class="bg-yellow-50 border border-yellow-200 text-yellow-700 px-4 py-3 rounded-lg">
          <p class="font-medium mb-1">Invalid or expired reset link</p>
          <p class="text-sm">Please request a new password reset link.</p>
          <div class="mt-3">
            <RouterLink to="/forgot-password" class="text-primary-600 hover:text-primary-700 font-medium underline">
              Request new link
            </RouterLink>
          </div>
        </div>

        <div v-if="hasValidSession">
          <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
            New Password
          </label>
          <input
            id="password"
            v-model="password"
            type="password"
            required
            minlength="6"
            class="input-field"
            placeholder="Enter new password (min. 6 characters)"
            :disabled="loading"
          />
        </div>

        <div v-if="hasValidSession">
          <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">
            Confirm New Password
          </label>
          <input
            id="confirmPassword"
            v-model="confirmPassword"
            type="password"
            required
            minlength="6"
            class="input-field"
            placeholder="Confirm new password"
            :disabled="loading"
          />
        </div>

        <button
          v-if="hasValidSession"
          type="submit"
          :disabled="loading || !passwordsMatch"
          class="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ loading ? 'Resetting...' : 'Reset Password' }}
        </button>

        <p v-if="password && confirmPassword && !passwordsMatch" class="text-red-600 text-sm">
          Passwords do not match
        </p>
      </form>

      <div class="mt-6 text-center">
        <p class="text-gray-600">
          <RouterLink to="/login" class="text-primary-600 hover:text-primary-700 font-medium">
            Back to Login
          </RouterLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { authService } from '@/services/authService'

const router = useRouter()

const password = ref('')
const confirmPassword = ref('')
const loading = ref(false)
const error = ref('')
const passwordReset = ref(false)
const hasValidSession = ref(false)

const passwordsMatch = computed(() => {
  return password.value && confirmPassword.value && password.value === confirmPassword.value
})

onMounted(async () => {
  // Check if user has a valid session (from password reset link)
  const { data } = await authService.getSession()
  hasValidSession.value = !!data?.session
})

async function handleResetPassword() {
  loading.value = true
  error.value = ''

  if (!passwordsMatch.value) {
    error.value = 'Passwords do not match'
    loading.value = false
    return
  }

  if (password.value.length < 6) {
    error.value = 'Password must be at least 6 characters long'
    loading.value = false
    return
  }

  try {
    const result = await authService.updatePassword(password.value)

    if (result.error) {
      error.value = result.error.message || 'Failed to reset password. Please try again.'
    } else {
      passwordReset.value = true
      // Auto redirect to login after 3 seconds
      setTimeout(() => {
        router.push('/login')
      }, 3000)
    }
  } catch (err) {
    error.value = 'An unexpected error occurred. Please try again.'
    console.error('Reset password error:', err)
  } finally {
    loading.value = false
  }
}
</script>
