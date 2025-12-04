import { supabase } from './supabaseClient'

export const tagService = {
  // Get all unique tags
  async getAllTags() {
    const { data, error } = await supabase
      .from('bhajan_tags')
      .select('tag_name')
      .order('tag_name')
    
    if (error) return { data: [], error }
    
    // Get unique tag names
    const uniqueTags = [...new Set(data.map(t => t.tag_name))]
    return { data: uniqueTags, error: null }
  },

  // Get tags for a specific bhajan
  async getBhajanTags(bhajanId) {
    const { data, error } = await supabase
      .from('bhajan_tags')
      .select('*')
      .eq('bhajan_id', bhajanId)
      .order('tag_name')
    return { data, error }
  },

  // Add tag to bhajan
  async addTagToBhajan(bhajanId, tagName) {
    const { data, error } = await supabase
      .from('bhajan_tags')
      .insert([{ bhajan_id: bhajanId, tag_name: tagName }])
      .select()
      .single()
    return { data, error }
  },

  // Remove tag from bhajan
  async removeTagFromBhajan(tagId) {
    const { error } = await supabase
      .from('bhajan_tags')
      .delete()
      .eq('id', tagId)
    return { error }
  },

  // Update bhajan tags (replace all)
  async updateBhajanTags(bhajanId, tagNames) {
    // First, delete existing tags
    await supabase
      .from('bhajan_tags')
      .delete()
      .eq('bhajan_id', bhajanId)

    // Then insert new tags
    if (tagNames.length > 0) {
      const tags = tagNames.map(name => ({
        bhajan_id: bhajanId,
        tag_name: name
      }))
      
      const { data, error } = await supabase
        .from('bhajan_tags')
        .insert(tags)
        .select()
      return { data, error }
    }

    return { data: [], error: null }
  },

  // Get popular tags with counts
  async getPopularTags(limit = 20) {
    const { data, error } = await supabase
      .rpc('get_popular_tags', { limit_count: limit })
    
    if (error) {
      // Fallback if RPC doesn't exist
      const { data: tagsData, error: tagsError } = await supabase
        .from('bhajan_tags')
        .select('tag_name')
      
      if (tagsError) return { data: [], error: tagsError }
      
      // Count occurrences
      const tagCounts = {}
      tagsData.forEach(t => {
        tagCounts[t.tag_name] = (tagCounts[t.tag_name] || 0) + 1
      })
      
      const popularTags = Object.entries(tagCounts)
        .map(([name, count]) => ({ tag_name: name, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, limit)
      
      return { data: popularTags, error: null }
    }
    
    return { data, error }
  }
}
