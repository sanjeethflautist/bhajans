import { defineStore } from 'pinia'
import { ref } from 'vue'
import { reportService } from '@/services/reportService'
import { auditService } from '@/services/auditService'
import { useAuthStore } from './authStore'

export const useReportStore = defineStore('report', () => {
  const reports = ref([])
  const userReports = ref([])
  const loading = ref(false)
  const error = ref(null)
  const totalCount = ref(0)

  // Fetch all reports (admin only)
  async function fetchAllReports(filters = {}) {
    try {
      loading.value = true
      error.value = null
      const { data, error: fetchError, count } = await reportService.getAllReports(filters)
      
      if (fetchError) throw fetchError
      
      reports.value = data
      totalCount.value = count
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Fetch user's reports
  async function fetchUserReports() {
    try {
      loading.value = true
      error.value = null
      
      const authStore = useAuthStore()
      const { data, error: fetchError } = await reportService.getUserReports(authStore.user.id)
      
      if (fetchError) throw fetchError
      
      userReports.value = data
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Fetch reports for a bhajan
  async function fetchBhajanReports(bhajanId) {
    try {
      loading.value = true
      error.value = null
      const { data, error: fetchError } = await reportService.getBhajanReports(bhajanId)
      
      if (fetchError) throw fetchError
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Create new report
  async function createReport(reportData) {
    try {
      loading.value = true
      error.value = null
      
      const authStore = useAuthStore()
      reportData.reported_by = authStore.user.id
      
      const { data, error: createError } = await reportService.createReport(reportData)
      
      if (createError) throw createError

      // Log audit event
      await auditService.logEvent(
        authStore.user.id,
        'create_report',
        'report',
        data.id,
        { bhajan_id: reportData.bhajan_id, issue_type: reportData.issue_type }
      )
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Mark report as under review
  async function markAsUnderReview(reportId) {
    try {
      loading.value = true
      error.value = null
      
      const authStore = useAuthStore()
      const { data, error: updateError } = await reportService.markAsUnderReview(
        reportId,
        authStore.user.id
      )
      
      if (updateError) throw updateError

      // Log audit event
      await auditService.logEvent(
        authStore.user.id,
        'mark_under_review',
        'report',
        reportId,
        null
      )
      
      // Update local state
      const report = reports.value.find(r => r.id === reportId)
      if (report) {
        report.status = 'under_review'
      }
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Resolve report
  async function resolveReport(reportId, resolutionComment) {
    try {
      loading.value = true
      error.value = null
      
      const authStore = useAuthStore()
      const { data, error: resolveError } = await reportService.resolveReport(
        reportId,
        authStore.user.id,
        resolutionComment
      )
      
      if (resolveError) throw resolveError

      // Log audit event
      await auditService.logEvent(
        authStore.user.id,
        'resolve_report',
        'report',
        reportId,
        { resolution_comment: resolutionComment }
      )
      
      // Update local state
      const report = reports.value.find(r => r.id === reportId)
      if (report) {
        report.status = 'resolved'
        report.resolution_comment = resolutionComment
      }
      
      return { success: true, data }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  // Dismiss report
  async function dismissReport(reportId, resolutionComment) {
    try {
      loading.value = true
      error.value = null
      
      const authStore = useAuthStore()
      const { data, error: dismissError } = await reportService.dismissReport(
        reportId,
        authStore.user.id,
        resolutionComment
      )
      
      if (dismissError) throw dismissError

      // Log audit event
      await auditService.logEvent(
        authStore.user.id,
        'dismiss_report',
        'report',
        reportId,
        { resolution_comment: resolutionComment }
      )
      
      // Update local state
      const report = reports.value.find(r => r.id === reportId)
      if (report) {
        report.status = 'dismissed'
        report.resolution_comment = resolutionComment
      }
      
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
    reports,
    userReports,
    loading,
    error,
    totalCount,
    // Actions
    fetchAllReports,
    fetchUserReports,
    fetchBhajanReports,
    createReport,
    markAsUnderReview,
    resolveReport,
    dismissReport
  }
})
