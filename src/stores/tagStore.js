import { defineStore } from 'pinia'
import { ref } from 'vue'
import { tagService } from '@/services/tagService'

export const useTagStore = defineStore('tag', () => {
  const allTags = ref([])
  const popularTags = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Fetch all unique tags
  async function fetchAllTags() {
    try {
      loading.value = true
      error.value = null
      const { data, error: fetchError } = await tagService.getAllTags()
      
      if (fetchError) throw fetchError
      
      allTags.value = data
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Fetch popular tags
  async function fetchPopularTags(limit = 20) {
    try {
      loading.value = true
      error.value = null
      const { data, error: fetchError } = await tagService.getPopularTags(limit)
      
      if (fetchError) throw fetchError
      
      popularTags.value = data
      
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
    allTags,
    popularTags,
    loading,
    error,
    // Actions
    fetchAllTags,
    fetchPopularTags
  }
})
