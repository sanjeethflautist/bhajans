import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'

// Lazy load pages for better performance
const Home = () => import('@/pages/Home.vue')
const Login = () => import('@/pages/Login.vue')
const Signup = () => import('@/pages/Signup.vue')
const BhajanDetail = () => import('@/pages/BhajanDetail.vue')
const BhajanCreate = () => import('@/pages/BhajanCreate.vue')
const BhajanEdit = () => import('@/pages/BhajanEdit.vue')
const AdminDashboard = () => import('@/pages/AdminDashboard.vue')
const ReviewQueue = () => import('@/pages/ReviewQueue.vue')
const ReportsPage = () => import('@/pages/ReportsPage.vue')
const MyBhajans = () => import('@/pages/MyBhajans.vue')

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home,
    meta: { requiresAuth: false }
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresAuth: false, guestOnly: true }
  },
  {
    path: '/signup',
    name: 'Signup',
    component: Signup,
    meta: { requiresAuth: false, guestOnly: true }
  },
  {
    path: '/bhajan/:id',
    name: 'BhajanDetail',
    component: BhajanDetail,
    meta: { requiresAuth: false }
  },
  {
    path: '/bhajan/create',
    name: 'BhajanCreate',
    component: BhajanCreate,
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/bhajan/:id/edit',
    name: 'BhajanEdit',
    component: BhajanEdit,
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/my-bhajans',
    name: 'MyBhajans',
    component: MyBhajans,
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/admin',
    name: 'AdminDashboard',
    component: AdminDashboard,
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/admin/review-queue',
    name: 'ReviewQueue',
    component: ReviewQueue,
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/admin/reports',
    name: 'ReportsPage',
    component: ReportsPage,
    meta: { requiresAuth: true, requiresAdmin: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guards
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  // Wait for auth to initialize if not already done
  if (!authStore.user && !authStore.loading) {
    await authStore.initializeAuth()
  }

  const requiresAuth = to.meta.requiresAuth
  const requiresEditor = to.meta.requiresEditor
  const requiresAdmin = to.meta.requiresAdmin
  const guestOnly = to.meta.guestOnly

  // Redirect authenticated users away from login/signup
  if (guestOnly && authStore.isAuthenticated) {
    return next('/')
  }

  // Check authentication
  if (requiresAuth && !authStore.isAuthenticated) {
    return next({
      name: 'Login',
      query: { redirect: to.fullPath }
    })
  }

  // Check editor role
  if (requiresEditor && !authStore.isEditor) {
    return next('/')
  }

  // Check admin role
  if (requiresAdmin && !authStore.isAdmin) {
    return next('/')
  }

  next()
})

export default router
