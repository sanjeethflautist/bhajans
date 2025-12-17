import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const usePreferencesStore = defineStore('preferences', () => {
  // User preferences stored in localStorage
  const showMeaning = ref(JSON.parse(localStorage.getItem('showMeaning') || 'false'))
  const enabledScripts = ref(JSON.parse(localStorage.getItem('enabledScripts') || '["english"]'))

  // Available script options
  const scriptOptions = [
    { id: 'english', label: 'English', field: 'lyrics' },
    { id: 'kannada', label: 'ಕನ್ನಡ', field: 'lyrics_kannada' },
    { id: 'devanagari', label: 'देवनागरी', field: 'lyrics_devanagari' }
  ]

  // Computed values
  const hasEnabledScript = computed(() => enabledScripts.value.length > 0)
  
  const getEnabledScriptFields = computed(() => {
    return scriptOptions
      .filter(script => enabledScripts.value.includes(script.id))
      .map(script => script.field)
  })

  // Actions
  function toggleMeaning() {
    showMeaning.value = !showMeaning.value
    localStorage.setItem('showMeaning', JSON.stringify(showMeaning.value))
  }

  function setShowMeaning(value) {
    showMeaning.value = value
    localStorage.setItem('showMeaning', JSON.stringify(showMeaning.value))
  }

  function toggleScript(scriptId) {
    const index = enabledScripts.value.indexOf(scriptId)
    if (index > -1) {
      // Remove script only if at least one will remain
      if (enabledScripts.value.length > 1) {
        enabledScripts.value.splice(index, 1)
      }
    } else {
      // Add script
      enabledScripts.value.push(scriptId)
    }
    localStorage.setItem('enabledScripts', JSON.stringify(enabledScripts.value))
  }

  function isScriptEnabled(scriptId) {
    return enabledScripts.value.includes(scriptId)
  }

  function setEnabledScripts(scripts) {
    // Ensure at least one script is enabled
    if (scripts.length > 0) {
      enabledScripts.value = scripts
      localStorage.setItem('enabledScripts', JSON.stringify(enabledScripts.value))
    }
  }

  function resetToDefaults() {
    showMeaning.value = false
    enabledScripts.value = ['english']
    localStorage.setItem('showMeaning', JSON.stringify(showMeaning.value))
    localStorage.setItem('enabledScripts', JSON.stringify(enabledScripts.value))
  }

  return {
    // State
    showMeaning,
    enabledScripts,
    scriptOptions,
    
    // Computed
    hasEnabledScript,
    getEnabledScriptFields,
    
    // Actions
    toggleMeaning,
    setShowMeaning,
    toggleScript,
    isScriptEnabled,
    setEnabledScripts,
    resetToDefaults
  }
})
