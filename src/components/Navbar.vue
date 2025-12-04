<template>
  <nav class="bg-white/90 backdrop-blur-md shadow-lg border-b border-orange-100">
    <div class="container mx-auto px-4">
      <div class="flex justify-between items-center h-18">
        <!-- Logo and Brand -->
        <RouterLink to="/" class="flex items-center space-x-3 group">
          <span class="text-3xl">🎵</span>
          <span class="text-xl font-bold bg-gradient-to-r from-primary-600 to-accent-500 bg-clip-text text-transparent group-hover:from-primary-700 group-hover:to-accent-600 transition-all">Bhajan Manager</span>
        </RouterLink>

        <!-- Navigation Links -->
        <div class="flex items-center space-x-8">
          <RouterLink
            to="/"
            class="text-gray-600 hover:text-primary-600 font-medium transition-colors relative group py-2"
          >
            <span>Browse</span>
            <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-primary-600 to-accent-500 group-hover:w-full transition-all duration-300"></span>
          </RouterLink>

          <RouterLink
            v-if="authStore.canCreateBhajan"
            to="/my-bhajans"
            class="text-gray-600 hover:text-primary-600 font-medium transition-colors relative group py-2"
          >
            <span>My Bhajans</span>
            <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-primary-600 to-accent-500 group-hover:w-full transition-all duration-300"></span>
          </RouterLink>

          <RouterLink
            v-if="authStore.canCreateBhajan"
            to="/bhajan/create"
            class="text-gray-600 hover:text-primary-600 font-medium transition-colors relative group py-2"
          >
            <span>Create</span>
            <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-primary-600 to-accent-500 group-hover:w-full transition-all duration-300"></span>
          </RouterLink>

          <RouterLink
            v-if="authStore.isAdmin"
            to="/admin"
            class="text-gray-600 hover:text-primary-600 font-medium transition-colors relative group py-2"
          >
            <span>Admin</span>
            <span class="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-primary-600 to-accent-500 group-hover:w-full transition-all duration-300"></span>
          </RouterLink>

          <!-- User Menu -->
          <div v-if="authStore.isAuthenticated" class="relative">
            <button
              @click.stop="toggleUserMenu"
              class="flex items-center space-x-2 px-4 py-2 rounded-xl bg-gradient-to-r from-primary-50 to-accent-50 hover:from-primary-100 hover:to-accent-100 text-gray-700 font-medium transition-all cursor-pointer border border-primary-200"
            >
              <span class="text-sm">{{ authStore.user?.email || 'User' }}</span>
              <span class="text-xs bg-gradient-to-r from-primary-500 to-accent-500 text-white px-3 py-1 rounded-full font-semibold">
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
                class="absolute right-0 mt-3 w-52 bg-white/95 backdrop-blur-sm rounded-2xl shadow-2xl py-2 z-50 border border-orange-100"
              >
                <button
                  @click="handleSignOut"
                  class="w-full text-left px-4 py-3 text-gray-700 hover:bg-gradient-to-r hover:from-primary-50 hover:to-accent-50 transition-all flex items-center space-x-3 rounded-xl mx-1"
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

function toggleUserMenu() {
  showUserMenu.value = !showUserMenu.value
}

function closeUserMenu() {
  showUserMenu.value = false
}

async function handleSignOut() {
  await authStore.signOut()
  showUserMenu.value = false
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
