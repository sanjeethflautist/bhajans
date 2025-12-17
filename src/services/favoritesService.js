import { supabase } from './supabaseClient'

export const favoritesService = {
  // Add bhajan to favorites
  async addToFavorites(bhajanId) {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return { data: null, error: { message: 'Must be logged in to add favorites' } }
    }

    const { data, error } = await supabase
      .from('favorites')
      .insert([{ 
        user_id: user.id, 
        bhajan_id: bhajanId 
      }])
      .select()
      .single()

    return { data, error }
  },

  // Remove bhajan from favorites
  async removeFromFavorites(bhajanId) {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return { data: null, error: { message: 'Must be logged in' } }
    }

    const { error } = await supabase
      .from('favorites')
      .delete()
      .eq('user_id', user.id)
      .eq('bhajan_id', bhajanId)

    return { error }
  },

  // Check if bhajan is favorited by current user
  async isFavorited(bhajanId) {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return { data: false, error: null }
    }

    const { data, error } = await supabase
      .from('favorites')
      .select('id')
      .eq('user_id', user.id)
      .eq('bhajan_id', bhajanId)
      .single()

    return { data: !!data, error: error?.code === 'PGRST116' ? null : error }
  },

  // Get user's favorite bhajans
  async getUserFavorites({ limit = 50, offset = 0 } = {}) {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return { data: null, error: { message: 'Must be logged in' } }
    }

    const { data, error, count } = await supabase
      .from('favorites')
      .select(`
        id,
        created_at,
        bhajan:bhajans (
          id,
          title,
          lyrics,
          description,
          created_at,
          updated_at,
          status,
          created_by,
          view_count,
          creator:user_profiles!created_by (
            id,
            email,
            role
          )
        )
      `, { count: 'exact' })
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    // Transform data to extract bhajan info
    const bhajans = data?.map(fav => ({
      ...fav.bhajan,
      favorited_at: fav.created_at
    })) || []

    return { data: bhajans, error, count }
  },

  // Get favorites count for a bhajan
  async getFavoritesCount(bhajanId) {
    const { count, error } = await supabase
      .from('favorites')
      .select('*', { count: 'exact', head: true })
      .eq('bhajan_id', bhajanId)

    return { count, error }
  },

  // Toggle favorite status
  async toggleFavorite(bhajanId) {
    const { data: isFavorited } = await this.isFavorited(bhajanId)
    
    if (isFavorited) {
      const result = await this.removeFromFavorites(bhajanId)
      return { success: !result.error, error: result.error, isFavorited: false }
    } else {
      const result = await this.addToFavorites(bhajanId)
      return { success: !result.error, error: result.error, isFavorited: true }
    }
  }
}
