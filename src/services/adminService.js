import { supabase } from './supabaseClient'

export const adminService = {
  // Get dashboard statistics
  async getDashboardStats() {
    const { data, error } = await supabase
      .from('dashboard_stats')
      .select('*')
      .single()
    return { data, error }
  },

  // Get all users (admin only)
  async getAllUsers({ limit, offset = 0 }) {
    let query = supabase
      .from('user_profiles')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })

    if (limit) {
      query = query.range(offset, offset + limit - 1)
    }

    const { data, error, count } = await query
    return { data, error, count }
  },

  // Update user role
  async updateUserRole(userId, newRole) {
    const { data, error } = await supabase
      .from('user_profiles')
      .update({ role: newRole })
      .eq('id', userId)
      .select()
      .single()
    return { data, error }
  },

  // Get pending reviews count
  async getPendingReviewsCount() {
    const { count, error } = await supabase
      .from('bhajans')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'pending_review')
    return { count, error }
  },

  // Get open reports count
  async getOpenReportsCount() {
    const { count, error } = await supabase
      .from('reports')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'open')
    return { count, error }
  },

  // Get recent activity
  async getRecentActivity(limit = 20) {
    const { data, error } = await supabase
      .from('audit_log')
      .select(`
        *,
        user:user_profiles(id, email, role)
      `)
      .order('created_at', { ascending: false })
      .limit(limit)
    return { data, error }
  }
}
