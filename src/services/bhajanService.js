import { supabase } from './supabaseClient'

export const bhajanService = {
  // Get all bhajans (with filters)
  async getBhajans({ status, searchQuery, tags, sortBy = 'created_at', sortOrder = 'desc', limit, offset = 0 }) {
    let query = supabase
      .from('bhajans')
      .select(`
        *,
        creator:user_profiles!created_by(id, email, role),
        tags:bhajan_tags(id, tag_name)
      `, { count: 'exact' })

    if (status) {
      query = query.eq('status', status)
    }

    if (searchQuery) {
      query = query.or(`title.ilike.%${searchQuery}%,lyrics.ilike.%${searchQuery}%,description.ilike.%${searchQuery}%,title_kannada.ilike.%${searchQuery}%,title_devanagari.ilike.%${searchQuery}%,lyrics_kannada.ilike.%${searchQuery}%,lyrics_devanagari.ilike.%${searchQuery}%`)
    }

    if (tags && tags.length > 0) {
      const { data: bhajanIds } = await supabase
        .from('bhajan_tags')
        .select('bhajan_id')
        .in('tag_name', tags)
      
      if (bhajanIds && bhajanIds.length > 0) {
        const ids = bhajanIds.map(t => t.bhajan_id)
        query = query.in('id', ids)
      }
    }

    query = query.order(sortBy, { ascending: sortOrder === 'asc' })

    if (limit) {
      query = query.range(offset, offset + limit - 1)
    }

    const { data, error, count } = await query
    
    console.log('getBhajans result:', { data, error, count, filters: { status, searchQuery, tags, sortBy, sortOrder, limit, offset } })
    
    return { data, error, count }
  },

  // Get single bhajan by ID
  async getBhajanById(id) {
    const { data, error } = await supabase
      .from('bhajans')
      .select(`
        *,
        creator:user_profiles!created_by(id, email, role),
        reviewer:user_profiles!reviewed_by(id, email, role),
        tags:bhajan_tags(id, tag_name)
      `)
      .eq('id', id)
      .single()
    return { data, error }
  },

  // Create new bhajan
  async createBhajan(bhajanData) {
    const { data, error } = await supabase
      .from('bhajans')
      .insert([bhajanData])
      .select()
      .single()
    return { data, error }
  },

  // Update bhajan
  async updateBhajan(id, updates) {
    const { data, error } = await supabase
      .from('bhajans')
      .update(updates)
      .eq('id', id)
      .select()
    
    if (error) return { data: null, error }
    
    // Return the first item from the array
    return { data: data?.[0] || null, error: null }
  },

  // Delete bhajan
  async deleteBhajan(id) {
    const { error } = await supabase
      .from('bhajans')
      .delete()
      .eq('id', id)
    return { error }
  },

  // Submit bhajan for review
  async submitForReview(id) {
    return this.updateBhajan(id, { status: 'pending_review' })
  },

  // Approve bhajan (admin only)
  async approveBhajan(id, reviewedBy, reviewComment) {
    return this.updateBhajan(id, {
      status: 'approved',
      reviewed_by: reviewedBy,
      reviewed_at: new Date().toISOString(),
      review_comment: reviewComment
    })
  },

  // Reject bhajan (admin only)
  async rejectBhajan(id, reviewedBy, reviewComment) {
    return this.updateBhajan(id, {
      status: 'rejected',
      reviewed_by: reviewedBy,
      reviewed_at: new Date().toISOString(),
      review_comment: reviewComment
    })
  },

  // Get bhajans pending review
  async getPendingReviewBhajans() {
    return this.getBhajans({ status: 'pending_review' })
  }
}
