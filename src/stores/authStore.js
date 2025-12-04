import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authService } from '@/services/authService'
import { supabase } from '@/services/supabaseClient'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const profile = ref(null)
  const session = ref(null)
  const loading = ref(false)
  const error = ref(null)

  // Computed properties
  const isAuthenticated = computed(() => !!user.value)
  const userRole = computed(() => profile.value?.role || 'user')
  const isAdmin = computed(() => userRole.value === 'admin')
  const isEditor = computed(() => userRole.value === 'editor' || userRole.value === 'admin')
  const canCreateBhajan = computed(() => isEditor.value)
  const canReview = computed(() => isAdmin.value)

  // Initialize auth state
  async function initializeAuth() {
    try {
      loading.value = true
      const { data } = await authService.getSession()
      
      if (data.session) {
        session.value = data.session
        user.value = data.session.user
        await fetchUserProfile()
      }

      // Listen for auth changes
      supabase.auth.onAuthStateChange(async (event, newSession) => {
        console.log('Auth state changed:', event, newSession?.user?.email)
        
        // Only update state for certain events
        if (event === 'SIGNED_OUT') {
          user.value = null
          profile.value = null
          session.value = null
        } else if (event === 'SIGNED_IN' || event === 'TOKEN_REFRESHED') {
          session.value = newSession
          user.value = newSession?.user || null
          
          if (newSession?.user) {
            await fetchUserProfile()
          }
        } else if (event === 'USER_UPDATED') {
          session.value = newSession
          user.value = newSession?.user || null
        }
      })
    } catch (err) {
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  // Fetch user profile
  async function fetchUserProfile() {
    if (!user.value) return

    try {
      const { data, error: profileError } = await authService.getUserProfile(user.value.id)
      if (profileError) throw profileError
      profile.value = data
    } catch (err) {
      error.value = err.message
    }
  }

  // Sign up
  async function signUp(email, password) {
    try {
      loading.value = true
      error.value = null
      const { data, error: signUpError } = await authService.signUp(email, password)
      
      if (signUpError) throw signUpError
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Sign in
  async function signIn(email, password) {
    try {
      loading.value = true
      error.value = null
      const { data, error: signInError } = await authService.signIn(email, password)
      
      if (signInError) throw signInError
      
      user.value = data.user
      session.value = data.session
      await fetchUserProfile()
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Sign out
  async function signOut() {
    try {
      loading.value = true
      error.value = null
      
      // Clear local state first
      user.value = null
      profile.value = null
      session.value = null
      
      // Then sign out from Supabase
      await authService.signOut()
      
      return { success: true }
    } catch (err) {
      error.value = err.message
      // Still clear state even if there's an error
      user.value = null
      profile.value = null
      session.value = null
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Update user role (admin only)
  async function updateUserRole(userId, newRole) {
    try {
      loading.value = true
      error.value = null
      const { data, error: updateError } = await authService.updateUserRole(userId, newRole)
      
      if (updateError) throw updateError
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  return {
    // State
    user,
    profile,
    session,
    loading,
    error,
    // Computed
    isAuthenticated,
    userRole,
    isAdmin,
    isEditor,
    canCreateBhajan,
    canReview,
    // Actions
    initializeAuth,
    fetchUserProfile,
    signUp,
    signIn,
    signOut,
    updateUserRole
  }
})
