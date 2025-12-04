import { defineStore } from 'pinia'
import { ref } from 'vue'
import { bhajanService } from '@/services/bhajanService'
import { tagService } from '@/services/tagService'
import { auditService } from '@/services/auditService'
import { useAuthStore } from './authStore'

export const useBhajanStore = defineStore('bhajan', () => {
  const bhajans = ref([])
  const currentBhajan = ref(null)
  const loading = ref(false)
  const error = ref(null)
  const totalCount = ref(0)

  // Fetch bhajans with filters
  async function fetchBhajans(filters = {}) {
    try {
      loading.value = true
      error.value = null
      const { data, error: fetchError, count } = await bhajanService.getBhajans(filters)
      
      if (fetchError) throw fetchError
      
      bhajans.value = data
      totalCount.value = count
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Fetch single bhajan
  async function fetchBhajanById(id) {
    try {
      loading.value = true
      error.value = null
      const { data, error: fetchError } = await bhajanService.getBhajanById(id)
      
      if (fetchError) throw fetchError
      
      currentBhajan.value = data
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Create new bhajan
  async function createBhajan(bhajanData, tags = []) {
    try {
      loading.value = true
      error.value = null
      
      const authStore = useAuthStore()
      
      // Add creator
      bhajanData.created_by = authStore.user.id
      
      const { data, error: createError } = await bhajanService.createBhajan(bhajanData)
      
      if (createError) throw createError
      
      // Add tags
      if (tags.length > 0) {
        await tagService.updateBhajanTags(data.id, tags)
      }

      // Log audit event
      await auditService.logEvent(
        authStore.user.id,
        'create',
        'bhajan',
        data.id,
        { title: data.title }
      )
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Update bhajan
  async function updateBhajan(id, updates, tags = null) {
    try {
      loading.value = true
      error.value = null
      
      const authStore = useAuthStore()
      
      const { data, error: updateError } = await bhajanService.updateBhajan(id, updates)
      
      if (updateError) throw updateError
      
      // Update tags if provided
      if (tags !== null) {
        await tagService.updateBhajanTags(id, tags)
      }

      // Log audit event
      await auditService.logEvent(
        authStore.user.id,
        'update',
        'bhajan',
        id,
        updates
      )
      
      // Update current bhajan if it's the one being edited
      if (currentBhajan.value?.id === id) {
        currentBhajan.value = data
      }
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Delete bhajan
  async function deleteBhajan(id) {
    try {
      loading.value = true
      error.value = null
      
      const authStore = useAuthStore()
      
      const { error: deleteError } = await bhajanService.deleteBhajan(id)
      
      if (deleteError) throw deleteError

      // Log audit event
      await auditService.logEvent(
        authStore.user.id,
        'delete',
        'bhajan',
        id,
        null
      )
      
      // Remove from local state
      bhajans.value = bhajans.value.filter(b => b.id !== id)
      if (currentBhajan.value?.id === id) {
        currentBhajan.value = null
      }
      
      return { success: true }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Submit for review
  async function submitForReview(id) {
    return updateBhajan(id, { status: 'pending_review' })
  }

  // Approve bhajan (admin only)
  async function approveBhajan(id, reviewComment = '') {
    try {
      loading.value = true
      error.value = null
      
      const authStore = useAuthStore()
      
      const { data, error: approveError } = await bhajanService.approveBhajan(
        id,
        authStore.user.id,
        reviewComment
      )
      
      if (approveError) throw approveError

      // Log audit event
      await auditService.logEvent(
        authStore.user.id,
        'approve',
        'bhajan',
        id,
        { review_comment: reviewComment }
      )
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Reject bhajan (admin only)
  async function rejectBhajan(id, reviewComment = '') {
    try {
      loading.value = true
      error.value = null
      
      const authStore = useAuthStore()
      
      const { data, error: rejectError } = await bhajanService.rejectBhajan(
        id,
        authStore.user.id,
        reviewComment
      )
      
      if (rejectError) throw rejectError

      // Log audit event
      await auditService.logEvent(
        authStore.user.id,
        'reject',
        'bhajan',
        id,
        { review_comment: reviewComment }
      )
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Fetch pending reviews
  async function fetchPendingReviews() {
    return fetchBhajans({ status: 'pending_review' })
  }

  // Get pending review count
  async function getPendingReviewCount() {
    try {
      const { data, error: fetchError, count } = await bhajanService.getBhajans({
        status: 'pending_review',
        limit: 1,
        offset: 0
      })
      
      if (fetchError) throw fetchError
      
      return count || 0
    } catch (err) {
      console.error('Error fetching pending review count:', err)
      return 0
    }
  }

  return {
    // State
    bhajans,
    currentBhajan,
    loading,
    error,
    totalCount,
    // Actions
    fetchBhajans,
    fetchBhajanById,
    createBhajan,
    updateBhajan,
    deleteBhajan,
    submitForReview,
    approveBhajan,
    rejectBhajan,
    fetchPendingReviews,
    getPendingReviewCount
  }
})
