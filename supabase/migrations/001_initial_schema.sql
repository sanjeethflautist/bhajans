-- =============================================
-- Bhajan Management System Database Schema
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- 1. Create custom types/enums
-- =============================================

-- User roles enum
CREATE TYPE user_role AS ENUM ('user', 'editor', 'admin');

-- Bhajan status enum
CREATE TYPE bhajan_status AS ENUM ('draft', 'pending_review', 'approved', 'rejected');

-- Report issue types enum
CREATE TYPE issue_type AS ENUM ('incorrect_lyrics', 'offensive_content', 'copyright', 'other');

-- Report status enum
CREATE TYPE report_status AS ENUM ('open', 'under_review', 'resolved', 'dismissed');

-- =============================================
-- 2. Create tables
-- =============================================

-- User profiles table (extends Supabase Auth)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    role user_role NOT NULL DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Bhajans table
CREATE TABLE IF NOT EXISTS public.bhajans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    lyrics TEXT NOT NULL,
    description TEXT,
    created_by UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    status bhajan_status NOT NULL DEFAULT 'draft',
    reviewed_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    review_comment TEXT
);

-- Bhajan tags table
CREATE TABLE IF NOT EXISTS public.bhajan_tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bhajan_id UUID NOT NULL REFERENCES public.bhajans(id) ON DELETE CASCADE,
    tag_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    UNIQUE(bhajan_id, tag_name)
);

-- Reports table
CREATE TABLE IF NOT EXISTS public.reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bhajan_id UUID NOT NULL REFERENCES public.bhajans(id) ON DELETE CASCADE,
    reported_by UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    issue_type issue_type NOT NULL,
    description TEXT NOT NULL,
    status report_status NOT NULL DEFAULT 'open',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    resolution_comment TEXT
);

-- Audit log table
CREATE TABLE IF NOT EXISTS public.audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    changes JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- =============================================
-- 3. Create indexes for performance
-- =============================================

CREATE INDEX IF NOT EXISTS idx_bhajans_created_by ON public.bhajans(created_by);
CREATE INDEX IF NOT EXISTS idx_bhajans_status ON public.bhajans(status);
CREATE INDEX IF NOT EXISTS idx_bhajans_created_at ON public.bhajans(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bhajan_tags_bhajan_id ON public.bhajan_tags(bhajan_id);
CREATE INDEX IF NOT EXISTS idx_bhajan_tags_tag_name ON public.bhajan_tags(tag_name);
CREATE INDEX IF NOT EXISTS idx_reports_bhajan_id ON public.reports(bhajan_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON public.audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_entity ON public.audit_log(entity_type, entity_id);

-- Full-text search index for bhajans
CREATE INDEX IF NOT EXISTS idx_bhajans_search ON public.bhajans 
USING GIN (to_tsvector('english', title || ' ' || COALESCE(lyrics, '') || ' ' || COALESCE(description, '')));

-- =============================================
-- 4. Create functions
-- =============================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, role)
    VALUES (NEW.id, NEW.email, 'user');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to log audit events
CREATE OR REPLACE FUNCTION log_audit_event(
    p_user_id UUID,
    p_action TEXT,
    p_entity_type TEXT,
    p_entity_id UUID,
    p_changes JSONB
)
RETURNS UUID AS $$
DECLARE
    v_audit_id UUID;
BEGIN
    INSERT INTO public.audit_log (user_id, action, entity_type, entity_id, changes)
    VALUES (p_user_id, p_action, p_entity_type, p_entity_id, p_changes)
    RETURNING id INTO v_audit_id;
    
    RETURN v_audit_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 5. Create triggers
-- =============================================

-- Trigger to update updated_at on bhajans
DROP TRIGGER IF EXISTS update_bhajans_updated_at ON public.bhajans;
CREATE TRIGGER update_bhajans_updated_at
    BEFORE UPDATE ON public.bhajans
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger to create user profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- 6. Row Level Security (RLS) Policies
-- =============================================

-- Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bhajans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bhajan_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- User Profiles Policies
CREATE POLICY "Users can view all profiles" ON public.user_profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can update any profile" ON public.user_profiles
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Bhajans Policies
CREATE POLICY "Anyone can view approved bhajans" ON public.bhajans
    FOR SELECT USING (
        status = 'approved' OR
        created_by = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role IN ('editor', 'admin')
        )
    );

CREATE POLICY "Editors and admins can create bhajans" ON public.bhajans
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role IN ('editor', 'admin')
        )
    );

CREATE POLICY "Users can update own bhajans, editors and admins can update any" ON public.bhajans
    FOR UPDATE USING (
        created_by = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role IN ('editor', 'admin')
        )
    );

CREATE POLICY "Only admins can delete bhajans" ON public.bhajans
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Bhajan Tags Policies
CREATE POLICY "Anyone can view tags for visible bhajans" ON public.bhajan_tags
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.bhajans
            WHERE id = bhajan_id AND (
                status = 'approved' OR
                created_by = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM public.user_profiles
                    WHERE id = auth.uid() AND role IN ('editor', 'admin')
                )
            )
        )
    );

CREATE POLICY "Editors and admins can manage tags" ON public.bhajan_tags
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role IN ('editor', 'admin')
        )
    );

-- Reports Policies
CREATE POLICY "Authenticated users can create reports" ON public.reports
    FOR INSERT WITH CHECK (
        auth.uid() = reported_by AND
        auth.uid() IS NOT NULL
    );

CREATE POLICY "Users can view own reports, admins can view all" ON public.reports
    FOR SELECT USING (
        reported_by = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Only admins can update reports" ON public.reports
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Audit Log Policies
CREATE POLICY "Users can view own audit logs, admins can view all" ON public.audit_log
    FOR SELECT USING (
        user_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "System can insert audit logs" ON public.audit_log
    FOR INSERT WITH CHECK (true);

-- =============================================
-- 7. Create helpful views
-- =============================================

-- View for bhajans with creator info and tag count
CREATE OR REPLACE VIEW bhajans_with_details AS
SELECT 
    b.*,
    up.email as creator_email,
    up.role as creator_role,
    COUNT(DISTINCT bt.id) as tag_count,
    ARRAY_AGG(DISTINCT bt.tag_name) FILTER (WHERE bt.tag_name IS NOT NULL) as tags
FROM public.bhajans b
LEFT JOIN public.user_profiles up ON b.created_by = up.id
LEFT JOIN public.bhajan_tags bt ON b.id = bt.bhajan_id
GROUP BY b.id, up.email, up.role;

-- View for dashboard statistics
CREATE OR REPLACE VIEW dashboard_stats AS
SELECT 
    (SELECT COUNT(*) FROM public.bhajans WHERE status = 'approved') as approved_count,
    (SELECT COUNT(*) FROM public.bhajans WHERE status = 'pending_review') as pending_review_count,
    (SELECT COUNT(*) FROM public.bhajans WHERE status = 'draft') as draft_count,
    (SELECT COUNT(*) FROM public.reports WHERE status = 'open') as open_reports_count,
    (SELECT COUNT(*) FROM public.reports WHERE status = 'under_review') as under_review_reports_count,
    (SELECT COUNT(*) FROM public.user_profiles) as total_users,
    (SELECT COUNT(*) FROM public.user_profiles WHERE role = 'editor') as total_editors,
    (SELECT COUNT(*) FROM public.user_profiles WHERE role = 'admin') as total_admins;

-- =============================================
-- 8. Grant permissions
-- =============================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant permissions on tables
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Grant permissions on sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Grant execute on functions
GRANT EXECUTE ON FUNCTION log_audit_event TO authenticated;

-- =============================================
-- Script Complete
-- =============================================
