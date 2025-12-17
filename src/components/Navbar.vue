<template>
  <nav class="glass sticky top-0 z-50 border-b border-white/20 shadow-lg backdrop-blur-xl">
    <div class="container mx-auto px-3 sm:px-4">
      <div class="flex justify-between items-center h-14 sm:h-16">
        <!-- Logo and Brand -->
        <RouterLink to="/" class="flex items-center space-x-2 group">
          <span class="text-2xl transform group-hover:scale-110 transition-transform">🎵</span>
          <span class="text-lg sm:text-xl font-bold gradient-text">Bhajans</span>
        </RouterLink>

        <!-- Mobile Menu Button -->
        <button 
          @click="toggleMobileMenu"
          class="md:hidden p-2 rounded-xl hover:bg-white/50 transition-all duration-200"
        >
          <svg class="w-6 h-6 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="!showMobileMenu" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        <!-- Desktop Navigation Links -->
        <div class="hidden md:flex items-center space-x-4 lg:space-x-6">
          <RouterLink
            to="/"
            class="text-gray-700 hover:text-primary-600 font-medium transition-all duration-200 hover:scale-105"
          >
            Browse
          </RouterLink>

          <RouterLink
            to="/about"
            class="text-gray-700 hover:text-primary-600 font-medium transition-all duration-200 hover:scale-105"
          >
            About
          </RouterLink>

          <RouterLink
            v-if="authStore.canCreateBhajan"
            to="/my-bhajans"
            class="text-gray-700 hover:text-primary-600 font-medium transition-all duration-200 hover:scale-105"
          >
            My Bhajans
          </RouterLink>

          <RouterLink
            v-if="authStore.canCreateBhajan"
            to="/bhajan/create"
            class="text-gray-700 hover:text-primary-600 font-medium transition-all duration-200 hover:scale-105"
          >
            Create
          </RouterLink>

          <RouterLink
            v-if="authStore.canReviewBhajan"
            to="/admin/review-queue"
            class="text-gray-700 hover:text-primary-600 font-medium transition-all duration-200 hover:scale-105 relative"
          >
            Review
            <span 
              v-if="pendingReviewCount > 0" 
              class="absolute -top-2 -right-2 bg-gradient-to-r from-red-500 to-pink-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center animate-pulse shadow-lg"
            >
              {{ pendingReviewCount }}
            </span>
          </RouterLink>

          <RouterLink
            v-if="authStore.isAdmin"
            to="/admin"
            class="text-gray-700 hover:text-primary-600 font-medium transition-all duration-200 hover:scale-105"
          >
            Admin
          </RouterLink>

          <!-- Preferences Button -->
          <div class="relative">
            <button
              @click.stop="togglePreferencesMenu"
              class="p-2 rounded-xl hover:bg-white/50 transition-all duration-200 text-gray-700 hover:text-primary-600 transform hover:scale-110"
              title="Display preferences"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </button>

            <!-- Preferences Dropdown -->
            <Transition
              enter-active-class="transition ease-out duration-200"
              enter-from-class="transform opacity-0 scale-95 -translate-y-2"
              enter-to-class="transform opacity-100 scale-100 translate-y-0"
              leave-active-class="transition ease-in duration-150"
              leave-from-class="transform opacity-100 scale-100 translate-y-0"
              leave-to-class="transform opacity-0 scale-95 -translate-y-2"
            >
              <div
                v-if="showPreferencesMenu"
                @click.stop
                class="absolute right-0 mt-2 w-72 glass rounded-2xl shadow-2xl py-3 z-50 border border-white/20"
              >
                <div class="px-4 py-2 border-b border-gray-200/50">
                  <h3 class="font-semibold text-gray-800 flex items-center">
                    <svg class="w-4 h-4 mr-2 text-primary-500" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M11.49 3.17c-.38-1.56-2.6-1.56-2.98 0a1.532 1.532 0 01-2.286.948c-1.372-.836-2.942.734-2.106 2.106.54.886.061 2.042-.947 2.287-1.561.379-1.561 2.6 0 2.978a1.532 1.532 0 01.947 2.287c-.836 1.372.734 2.942 2.106 2.106a1.532 1.532 0 012.287.947c.379 1.561 2.6 1.561 2.978 0a1.533 1.533 0 012.287-.947c1.372.836 2.942-.734 2.106-2.106a1.533 1.533 0 01.947-2.287c1.561-.379 1.561-2.6 0-2.978a1.532 1.532 0 01-.947-2.287c.836-1.372-.734-2.942-2.106-2.106a1.532 1.532 0 01-2.287-.947zM10 13a3 3 0 100-6 3 3 0 000 6z" clip-rule="evenodd" />
                    </svg>
                    Display Preferences
                  </h3>
                </div>
                
                <!-- Script Selection -->
                <div class="px-4 py-3 border-b border-gray-200/50">
                  <label class="block text-sm font-medium text-gray-700 mb-2">Script Options</label>
                  <div class="space-y-2">
                    <label
                      v-for="script in preferencesStore.scriptOptions"
                      :key="script.id"
                      class="flex items-center space-x-2 cursor-pointer hover:bg-white/50 p-2 rounded-lg transition-colors"
                    >
                      <input
                        type="checkbox"
                        :checked="preferencesStore.isScriptEnabled(script.id)"
                        @change="preferencesStore.toggleScript(script.id)"
                        class="w-4 h-4 text-primary-600 rounded border-gray-300 focus:ring-primary-500 focus:ring-offset-0"
                      />
                      <span class="text-sm text-gray-700">{{ script.label }}</span>
                    </label>
                  </div>
                </div>

                <!-- Show Meaning Toggle -->
                <div class="px-4 py-3">
                  <label class="flex items-center justify-between cursor-pointer hover:bg-white/50 p-2 rounded-lg transition-colors">
                    <span class="text-sm font-medium text-gray-700">Show Meaning</span>
                    <button
                      @click="preferencesStore.toggleMeaning()"
                      :class="[
                        'relative inline-flex h-6 w-11 items-center rounded-full transition-colors shadow-inner',
                        preferencesStore.showMeaning ? 'bg-gradient-to-r from-primary-600 to-purple-600' : 'bg-gray-300'
                      ]"
                    >
                      <span
                        :class="[
                          'inline-block h-4 w-4 transform rounded-full bg-white transition-transform shadow-md',
                          preferencesStore.showMeaning ? 'translate-x-6' : 'translate-x-1'
                        ]"
                      />
                    </button>
                  </label>
                </div>
              </div>
            </Transition>
          </div>

          <!-- User Menu -->
          <div v-if="authStore.isAuthenticated" class="relative">
            <button
              @click.stop="toggleUserMenu"
              class="flex items-center space-x-2 px-3 py-2 rounded-xl glass hover:bg-white/50 text-gray-700 font-medium transition-all cursor-pointer shadow-sm hover:shadow-md"
            >
              <span class="text-sm truncate max-w-[100px]">{{ authStore.user?.email || 'User' }}</span>
              <span class="text-xs bg-gradient-to-r from-primary-600 to-purple-600 text-white px-2 py-1 rounded-full font-medium shadow-sm">
                {{ authStore.userRole }}
              </span>
              <svg 
                class="w-4 h-4 transition-transform" 
                :class="{ 'rotate-180': showUserMenu }"
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>

            <!-- Dropdown Menu -->
            <Transition
              enter-active-class="transition ease-out duration-200"
              enter-from-class="transform opacity-0 scale-95 -translate-y-2"
              enter-to-class="transform opacity-100 scale-100 translate-y-0"
              leave-active-class="transition ease-in duration-150"
              leave-from-class="transform opacity-100 scale-100 translate-y-0"
              leave-to-class="transform opacity-0 scale-95 -translate-y-2"
            >
              <div
                v-if="showUserMenu"
                @click.stop
                class="absolute right-0 mt-2 w-48 glass rounded-2xl shadow-2xl py-2 z-50 border border-white/20"
              >
                <button
                  @click="handleSignOut"
                  class="w-full text-left px-4 py-2 text-gray-700 hover:bg-gradient-to-r hover:from-red-50 hover:to-pink-50 transition-all rounded-lg mx-2 my-1 flex items-center space-x-2 group"
                >
                  <svg class="w-5 h-5 group-hover:text-red-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                  </svg>
                  <span class="group-hover:text-red-600 transition-colors">Sign Out</span>
                </button>
              </div>
            </Transition>
          </div>

          <RouterLink
            v-else
            to="/login"
            class="btn-primary"
          >
            Sign In
          </RouterLink>
        </div>
      </div>

      <!-- Mobile Menu -->
      <Transition
        enter-active-class="transition ease-out duration-200"
        enter-from-class="opacity-0 -translate-y-2"
        enter-to-class="opacity-100 translate-y-0"
        leave-active-class="transition ease-in duration-150"
        leave-from-class="opacity-100 translate-y-0"
        leave-to-class="opacity-0 -translate-y-2"
      >
        <div v-if="showMobileMenu" class="md:hidden py-4 border-t border-gray-200">
          <div class="flex flex-col space-y-2">
            <RouterLink
              to="/"
              @click="closeMobileMenu"
              class="px-4 py-2 text-gray-600 hover:bg-gray-100 hover:text-primary-600 rounded-lg transition"
            >
              Browse
            </RouterLink>

            <RouterLink
              to="/about"
              @click="closeMobileMenu"
              class="px-4 py-2 text-gray-600 hover:bg-gray-100 hover:text-primary-600 rounded-lg transition"
            >
              About
            </RouterLink>

            <RouterLink
              v-if="authStore.canCreateBhajan"
              to="/my-bhajans"
              @click="closeMobileMenu"
              class="px-4 py-2 text-gray-600 hover:bg-gray-100 hover:text-primary-600 rounded-lg transition"
            >
              My Bhajans
            </RouterLink>

            <RouterLink
              v-if="authStore.canCreateBhajan"
              to="/bhajan/create"
              @click="closeMobileMenu"
              class="px-4 py-2 text-gray-600 hover:bg-gray-100 hover:text-primary-600 rounded-lg transition"
            >
              Create
            </RouterLink>

            <RouterLink
              v-if="authStore.canReviewBhajan"
              to="/admin/review-queue"
              @click="closeMobileMenu"
              class="px-4 py-2 text-gray-600 hover:bg-gray-100 hover:text-primary-600 rounded-lg transition flex items-center justify-between"
            >
              <span>Pending Review</span>
              <span 
                v-if="pendingReviewCount > 0" 
                class="bg-red-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center"
              >
                {{ pendingReviewCount }}
              </span>
            </RouterLink>

            <RouterLink
              v-if="authStore.isAdmin"
              to="/admin"
              @click="closeMobileMenu"
              class="px-4 py-2 text-gray-600 hover:bg-gray-100 hover:text-primary-600 rounded-lg transition"
            >
              Admin
            </RouterLink>

            <!-- Mobile Preferences Section -->
            <div class="px-4 py-3 border-t border-gray-200 mt-2">
              <h3 class="font-semibold text-gray-800 mb-3">Display Preferences</h3>
              
              <!-- Script Selection -->
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">Script Options</label>
                <div class="space-y-2">
                  <label
                    v-for="script in preferencesStore.scriptOptions"
                    :key="script.id"
                    class="flex items-center space-x-2 cursor-pointer hover:bg-gray-50 p-2 rounded"
                  >
                    <input
                      type="checkbox"
                      :checked="preferencesStore.isScriptEnabled(script.id)"
                      @change="preferencesStore.toggleScript(script.id)"
                      class="w-4 h-4 text-primary-600 rounded border-gray-300 focus:ring-primary-500"
                    />
                    <span class="text-sm text-gray-700">{{ script.label }}</span>
                  </label>
                </div>
              </div>

              <!-- Show Meaning Toggle -->
              <label class="flex items-center justify-between cursor-pointer hover:bg-gray-50 p-2 rounded">
                <span class="text-sm font-medium text-gray-700">Show Meaning</span>
                <button
                  @click="preferencesStore.toggleMeaning()"
                  :class="[
                    'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
                    preferencesStore.showMeaning ? 'bg-primary-600' : 'bg-gray-300'
                  ]"
                >
                  <span
                    :class="[
                      'inline-block h-4 w-4 transform rounded-full bg-white transition-transform',
                      preferencesStore.showMeaning ? 'translate-x-6' : 'translate-x-1'
                    ]"
                  />
                </button>
              </label>
            </div>

            <div v-if="authStore.isAuthenticated" class="px-4 py-2 border-t border-gray-200 mt-2">
              <div class="text-sm text-gray-500 mb-2">{{ authStore.user?.email }}</div>
              <div class="text-xs bg-primary-100 text-primary-700 px-2 py-1 rounded inline-block mb-3">
                {{ authStore.userRole }}
              </div>
              <button
                @click="handleSignOut"
                class="w-full text-left px-4 py-2 text-red-600 hover:bg-red-50 rounded-lg transition flex items-center space-x-2"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
                <span>Sign Out</span>
              </button>
            </div>

            <RouterLink
              v-else
              to="/login"
              @click="closeMobileMenu"
              class="mx-4 btn-primary text-center"
            >
              Sign In
            </RouterLink>
          </div>
        </div>
      </Transition>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { useBhajanStore } from '@/stores/bhajanStore'
import { usePreferencesStore } from '@/stores/preferencesStore'

const router = useRouter()
const authStore = useAuthStore()
const bhajanStore = useBhajanStore()
const preferencesStore = usePreferencesStore()
const showUserMenu = ref(false)
const showMobileMenu = ref(false)
const showPreferencesMenu = ref(false)
const pendingReviewCount = ref(0)

function toggleUserMenu() {
  showUserMenu.value = !showUserMenu.value
  showPreferencesMenu.value = false
}

function togglePreferencesMenu() {
  showPreferencesMenu.value = !showPreferencesMenu.value
  showUserMenu.value = false
}

function toggleMobileMenu() {
  showMobileMenu.value = !showMobileMenu.value
}

function closeMobileMenu() {
  showMobileMenu.value = false
}

function closeUserMenu() {
  showUserMenu.value = false
}

function closePreferencesMenu() {
  showPreferencesMenu.value = false
}

async function handleSignOut() {
  showUserMenu.value = false
  showMobileMenu.value = false
  showPreferencesMenu.value = false
  
  // Sign out from Supabase
  await authStore.signOut()
  
  // Navigate to home page
  router.push('/')
}

// Click outside to close
function handleClickOutside(event) {
  const userMenu = event.target.closest('.relative')
  if (!userMenu) {
    if (showUserMenu.value) closeUserMenu()
    if (showPreferencesMenu.value) closePreferencesMenu()
  }
}

async function updatePendingReviewCount() {
  if (authStore.canReviewBhajan) {
    pendingReviewCount.value = await bhajanStore.getPendingReviewCount()
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  updatePendingReviewCount()
  
  // Update count every 30 seconds
  const interval = setInterval(updatePendingReviewCount, 30000)
  
  onUnmounted(() => {
    clearInterval(interval)
  })
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>
