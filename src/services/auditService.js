import { supabase } from './supabaseClient'

export const auditService = {
  // Log an audit event
  async logEvent(userId, action, entityType, entityId, changes = null) {
    const { data, error } = await supabase
      .from('audit_log')
      .insert([{
        user_id: userId,
        action,
        entity_type: entityType,
        entity_id: entityId,
        changes
      }])
      .select()
      .single()
    return { data, error }
  },

  // Get audit logs with filters
  async getAuditLogs({ userId, entityType, entityId, limit = 50, offset = 0 }) {
    let query = supabase
      .from('audit_log')
      .select(`
        *,
        user:user_profiles(id, email, role)
      `, { count: 'exact' })

    if (userId) {
      query = query.eq('user_id', userId)
    }

    if (entityType) {
      query = query.eq('entity_type', entityType)
    }

    if (entityId) {
      query = query.eq('entity_id', entityId)
    }

    query = query
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    const { data, error, count } = await query
    return { data, error, count }
  },

  // Get audit logs for a specific entity
  async getEntityAuditLog(entityType, entityId) {
    return this.getAuditLogs({ entityType, entityId })
  },

  // Get user's audit history
  async getUserAuditHistory(userId, limit = 100) {
    return this.getAuditLogs({ userId, limit })
  }
}
