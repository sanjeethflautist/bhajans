import { supabase } from './supabase'

export const analyticsService = {
  // Increment view count for a bhajan
  async trackBhajanView(bhajanId) {
    try {
      const { error } = await supabase.rpc('increment_bhajan_view_count', {
        bhajan_uuid: bhajanId
      })

      if (error) throw error
      
      return { success: true }
    } catch (error) {
      console.error('Error tracking bhajan view:', error)
      return { success: false, error: error.message }
    }
  },

  // Increment home page visit count
  async trackHomeVisit() {
    try {
      const { error } = await supabase.rpc('increment_home_visits')

      if (error) throw error
      
      return { success: true }
    } catch (error) {
      console.error('Error tracking home visit:', error)
      return { success: false, error: error.message }
    }
  },

  // Get site-wide statistics
  async getSiteStatistics() {
    try {
      const { data, error } = await supabase
        .from('site_statistics')
        .select('*')
        .single()

      if (error) throw error

      return { data, error: null }
    } catch (error) {
      console.error('Error fetching site statistics:', error)
      return { data: null, error: error.message }
    }
  },

  // Get most viewed bhajans
  async getMostViewedBhajans(limit = 10) {
    try {
      const { data, error } = await supabase
        .from('bhajans')
        .select(`
          id,
          title,
          description,
          view_count,
          created_at
        `)
        .eq('status', 'approved')
        .order('view_count', { ascending: false })
        .limit(limit)

      if (error) throw error

      return { data, error: null }
    } catch (error) {
      console.error('Error fetching most viewed bhajans:', error)
      return { data: null, error: error.message }
    }
  }
}
