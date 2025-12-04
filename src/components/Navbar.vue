<template>
  <nav class="bg-white shadow-md">
    <div class="container mx-auto px-4">
      <div class="flex justify-between items-center h-16">
        <!-- Logo and Brand -->
        <RouterLink to="/" class="flex items-center space-x-2">
          <span class="text-2xl font-bold text-primary-600">🎵</span>
          <span class="text-xl font-bold text-gray-900">Bhajan Manager</span>
        </RouterLink>

        <!-- Navigation Links -->
        <div class="flex items-center space-x-6">
          <RouterLink
            to="/"
            class="text-gray-700 hover:text-primary-600 font-medium transition"
          >
            Browse
          </RouterLink>

          <RouterLink
            v-if="authStore.canCreateBhajan"
            to="/my-bhajans"
            class="text-gray-700 hover:text-primary-600 font-medium transition"
          >
            My Bhajans
          </RouterLink>

          <RouterLink
            v-if="authStore.canCreateBhajan"
            to="/bhajan/create"
            class="text-gray-700 hover:text-primary-600 font-medium transition"
          >
            Create
          </RouterLink>

          <RouterLink
            v-if="authStore.isAdmin"
            to="/admin"
            class="text-gray-700 hover:text-primary-600 font-medium transition"
          >
            Admin
          </RouterLink>

          <!-- User Menu -->
          <div v-if="authStore.isAuthenticated" class="relative">
            <button
              @click.stop="toggleUserMenu"
              class="flex items-center space-x-2 text-gray-700 hover:text-primary-600 font-medium transition cursor-pointer"
            >
              <span>{{ authStore.user?.email || 'User' }}</span>
              <span class="text-xs bg-primary-100 text-primary-700 px-2 py-1 rounded">
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
                class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 z-50 border border-gray-200"
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
