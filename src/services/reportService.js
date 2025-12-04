import { supabase } from './supabaseClient'

export const reportService = {
  // Get all reports (admin only)
  async getAllReports({ status, limit, offset = 0 }) {
    let query = supabase
      .from('reports')
      .select(`
        *,
        bhajan:bhajans(id, title, status),
        reporter:user_profiles!reported_by(id, email),
        resolver:user_profiles!resolved_by(id, email)
      `, { count: 'exact' })

    if (status) {
      query = query.eq('status', status)
    }

    query = query.order('created_at', { ascending: false })

    if (limit) {
      query = query.range(offset, offset + limit - 1)
    }

    const { data, error, count } = await query
    return { data, error, count }
  },

  // Get reports for a specific bhajan
  async getBhajanReports(bhajanId) {
    const { data, error } = await supabase
      .from('reports')
      .select(`
        *,
        reporter:user_profiles!reported_by(id, email)
      `)
      .eq('bhajan_id', bhajanId)
      .order('created_at', { ascending: false })
    return { data, error }
  },

  // Get user's own reports
  async getUserReports(userId) {
    const { data, error } = await supabase
      .from('reports')
      .select(`
        *,
        bhajan:bhajans(id, title, status)
      `)
      .eq('reported_by', userId)
      .order('created_at', { ascending: false })
    return { data, error }
  },

  // Create new report
  async createReport(reportData) {
    const { data, error } = await supabase
      .from('reports')
      .insert([reportData])
      .select()
      .single()
    return { data, error }
  },

  // Update report status
  async updateReportStatus(reportId, status, resolvedBy, resolutionComment) {
    const updates = {
      status,
      resolved_by: resolvedBy,
      resolved_at: new Date().toISOString(),
      resolution_comment: resolutionComment
    }

    const { data, error } = await supabase
      .from('reports')
      .update(updates)
      .eq('id', reportId)
      .select()
      .single()
    return { data, error }
  },

  // Mark report as under review
  async markAsUnderReview(reportId, resolvedBy) {
    return this.updateReportStatus(reportId, 'under_review', resolvedBy, null)
  },

  // Resolve report
  async resolveReport(reportId, resolvedBy, resolutionComment) {
    return this.updateReportStatus(reportId, 'resolved', resolvedBy, resolutionComment)
  },

  // Dismiss report
  async dismissReport(reportId, resolvedBy, resolutionComment) {
    return this.updateReportStatus(reportId, 'dismissed', resolvedBy, resolutionComment)
  },

  // Get report statistics
  async getReportStats() {
    const { data, error } = await supabase
      .from('reports')
      .select('status')

    if (error) return { data: null, error }

    const stats = {
      total: data.length,
      open: data.filter(r => r.status === 'open').length,
      under_review: data.filter(r => r.status === 'under_review').length,
      resolved: data.filter(r => r.status === 'resolved').length,
      dismissed: data.filter(r => r.status === 'dismissed').length
    }

    return { data: stats, error: null }
  }
}
