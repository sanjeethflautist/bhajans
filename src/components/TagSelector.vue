<template>
  <div class="space-y-3">
    <!-- Selected Tags -->
    <div v-if="selectedTags.length > 0" class="flex flex-wrap gap-2">
      <span
        v-for="tag in selectedTags"
        :key="tag"
        class="bg-primary-600 text-white px-3 py-1 rounded-full text-sm flex items-center gap-2"
      >
        {{ tag }}
        <button
          type="button"
          @click="removeTag(tag)"
          class="hover:text-gray-200 transition"
        >
          ×
        </button>
      </span>
    </div>

    <!-- Tag Input -->
    <div class="relative">
      <input
        v-model="tagInput"
        type="text"
        class="input-field"
        placeholder="Type to search or add tags..."
        @input="handleInput"
        @keydown.enter.prevent="addCustomTag"
        @keydown.down.prevent="navigateDown"
        @keydown.up.prevent="navigateUp"
        @keydown.escape="closeSuggestions"
      />

      <!-- Suggestions Dropdown -->
      <div
        v-if="showSuggestions && filteredTags.length > 0"
        class="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg max-h-48 overflow-y-auto"
      >
        <button
          v-for="(tag, index) in filteredTags"
          :key="tag"
          type="button"
          :class="[
            'w-full text-left px-4 py-2 hover:bg-primary-50 transition',
            index === highlightedIndex ? 'bg-primary-100' : ''
          ]"
          @click="selectTag(tag)"
        >
          {{ tag }}
        </button>
      </div>
    </div>

    <!-- Popular Tags -->
    <div v-if="popularTags.length > 0 && !tagInput" class="pt-2">
      <p class="text-sm text-gray-600 mb-2">Popular tags:</p>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="tag in popularTags.slice(0, 10)"
          :key="tag.tag_name"
          type="button"
          :disabled="selectedTags.includes(tag.tag_name)"
          @click="selectTag(tag.tag_name)"
          class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-1 rounded-full text-sm transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ tag.tag_name }} ({{ tag.count }})
        </button>
      </div>
    </div>

    <p class="text-xs text-gray-500">
      Press Enter to add a custom tag, or select from suggestions
    </p>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useTagStore } from '@/stores/tagStore'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const tagStore = useTagStore()
const tagInput = ref('')
const selectedTags = ref([...props.modelValue])
const showSuggestions = ref(false)
const highlightedIndex = ref(0)

const popularTags = computed(() => tagStore.popularTags)

const filteredTags = computed(() => {
  if (!tagInput.value) return []
  
  const query = tagInput.value.toLowerCase()
  return tagStore.allTags
    .filter(tag => 
      tag.toLowerCase().includes(query) && 
      !selectedTags.value.includes(tag)
    )
    .slice(0, 10)
})

watch(selectedTags, (newTags) => {
  emit('update:modelValue', newTags)
}, { deep: true })

watch(() => props.modelValue, (newValue) => {
  selectedTags.value = [...newValue]
})

onMounted(async () => {
  await tagStore.fetchAllTags()
  await tagStore.fetchPopularTags()
})

function handleInput() {
  showSuggestions.value = true
  highlightedIndex.value = 0
}

function selectTag(tag) {
  if (!selectedTags.value.includes(tag)) {
    selectedTags.value.push(tag)
  }
  tagInput.value = ''
  showSuggestions.value = false
  highlightedIndex.value = 0
}

function removeTag(tag) {
  selectedTags.value = selectedTags.value.filter(t => t !== tag)
}

function addCustomTag() {
  const tag = tagInput.value.trim()
  
  if (tag && !selectedTags.value.includes(tag)) {
    selectedTags.value.push(tag)
    tagInput.value = ''
    showSuggestions.value = false
  } else if (filteredTags.value.length > 0) {
    selectTag(filteredTags.value[highlightedIndex.value])
  }
}

function navigateDown() {
  if (highlightedIndex.value < filteredTags.value.length - 1) {
    highlightedIndex.value++
  }
}

function navigateUp() {
  if (highlightedIndex.value > 0) {
    highlightedIndex.value--
  }
}

function closeSuggestions() {
  showSuggestions.value = false
  highlightedIndex.value = 0
}
</script>
