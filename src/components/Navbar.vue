<template>
  <nav class="bg-white shadow-md sticky top-0 z-50">
    <div class="container mx-auto px-4">
      <div class="flex justify-between items-center h-16">
        <!-- Logo and Brand -->
        <RouterLink to="/" class="flex items-center space-x-2">
          <span class="text-2xl">🎵</span>
          <span class="text-lg sm:text-xl font-bold text-gray-800">Bhajans</span>
        </RouterLink>

        <!-- Mobile Menu Button -->
        <button 
          @click="toggleMobileMenu"
          class="md:hidden p-2 rounded-lg hover:bg-gray-100 transition"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="!showMobileMenu" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        <!-- Desktop Navigation Links -->
        <div class="hidden md:flex items-center space-x-6">
          <RouterLink
            to="/"
            class="text-gray-600 hover:text-primary-600 font-medium transition-colors"
          >
            Browse
          </RouterLink>

          <RouterLink
            v-if="authStore.canCreateBhajan"
            to="/my-bhajans"
            class="text-gray-600 hover:text-primary-600 font-medium transition-colors"
          >
            My Bhajans
          </RouterLink>

          <RouterLink
            v-if="authStore.canCreateBhajan"
            to="/bhajan/create"
            class="text-gray-600 hover:text-primary-600 font-medium transition-colors"
          >
            Create
          </RouterLink>

          <RouterLink
            v-if="authStore.isAdmin"
            to="/admin"
            class="text-gray-600 hover:text-primary-600 font-medium transition-colors"
          >
            Admin
          </RouterLink>

          <!-- User Menu -->
          <div v-if="authStore.isAuthenticated" class="relative">
            <button
              @click.stop="toggleUserMenu"
              class="flex items-center space-x-2 px-3 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium transition-all cursor-pointer"
            >
              <span class="text-sm truncate max-w-[100px]">{{ authStore.user?.email || 'User' }}</span>
              <span class="text-xs bg-primary-600 text-white px-2 py-1 rounded font-medium">
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
              enter-active-class="transition ease-out duration-100"
              enter-from-class="transform opacity-0 scale-95"
              enter-to-class="transform opacity-100 scale-100"
              leave-active-class="transition ease-in duration-75"
              leave-from-class="transform opacity-100 scale-100"
              leave-to-class="transform opacity-0 scale-95"
            >
              <div
                v-if="showUserMenu"
                @click.stop
                class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl py-2 z-50 border border-gray-200"
              >
                <button
                  @click="handleSignOut"
                  class="w-full text-left px-4 py-2 text-gray-700 hover:bg-gray-100 transition flex items-center space-x-2"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                  </svg>
                  <span>Sign Out</span>
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
              v-if="authStore.isAdmin"
              to="/admin"
              @click="closeMobileMenu"
              class="px-4 py-2 text-gray-600 hover:bg-gray-100 hover:text-primary-600 rounded-lg transition"
            >
              Admin
            </RouterLink>

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

const router = useRouter()
const authStore = useAuthStore()
const showUserMenu = ref(false)
const showMobileMenu = ref(false)

function toggleUserMenu() {
  showUserMenu.value = !showUserMenu.value
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

async function handleSignOut() {
  await authStore.signOut()
  showUserMenu.value = false
  showMobileMenu.value = false
  router.push('/login')
}

// Click outside to close
function handleClickOutside(event) {
  const userMenu = event.target.closest('.relative')
  if (!userMenu && showUserMenu.value) {
    closeUserMenu()
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>
