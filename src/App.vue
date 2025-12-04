<template>
  <div id="app" class="min-h-screen">
    <Navbar v-if="authStore.user" />
    <main class="container mx-auto px-4 py-8">
      <RouterView />
    </main>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { RouterView } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import Navbar from '@/components/Navbar.vue'

const authStore = useAuthStore()

onMounted(async () => {
  await authStore.initializeAuth()
})
</script>
