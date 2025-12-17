-- =============================================
-- Update User Roles System
-- =============================================

-- Create new role type
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role_new') THEN
    CREATE TYPE user_role_new AS ENUM ('contributor', 'reviewer', 'admin');
  END IF;
END $$;

-- Add a temporary column with the new type
ALTER TABLE public.user_profiles 
  ADD COLUMN IF NOT EXISTS role_new user_role_new;

-- Migrate existing data to new roles
UPDATE public.user_profiles 
SET role_new = CASE 
  WHEN role::text = 'admin' THEN 'admin'::user_role_new
  WHEN role::text = 'editor' THEN 'contributor'::user_role_new
  WHEN role::text = 'user' THEN 'contributor'::user_role_new
  ELSE 'contributor'::user_role_new
END;

-- Drop the old column (CASCADE will drop dependent policies)
ALTER TABLE public.user_profiles DROP COLUMN role CASCADE;

-- Rename the new column to the original name
ALTER TABLE public.user_profiles RENAME COLUMN role_new TO role;

-- Set NOT NULL constraint
ALTER TABLE public.user_profiles 
  ALTER COLUMN role SET NOT NULL;

-- Set default for new users
ALTER TABLE public.user_profiles 
  ALTER COLUMN role SET DEFAULT 'contributor'::user_role_new;

-- Drop old type
DROP TYPE IF EXISTS user_role CASCADE;

-- Rename new type to old name
ALTER TYPE user_role_new RENAME TO user_role;

-- Update the default to use the renamed type
ALTER TABLE public.user_profiles 
  ALTER COLUMN role SET DEFAULT 'contributor'::user_role;

-- Add comments
COMMENT ON TYPE user_role IS 'contributor: Can create and edit own bhajans, reviewer: Can approve/reject bhajans, admin: Full access';
COMMENT ON COLUMN public.user_profiles.role IS 'User role: contributor (default), reviewer, or admin';

-- Recreate RLS policies with new roles

-- =============================================
-- Bhajans table policies
-- =============================================

-- Anyone can view approved bhajans
DROP POLICY IF EXISTS "Anyone can view approved bhajans" ON public.bhajans;
CREATE POLICY "Anyone can view approved bhajans"
  ON public.bhajans
  FOR SELECT
  TO public
  USING (status = 'approved');

-- Contributors can create bhajans
DROP POLICY IF EXISTS "Editors and admins can create bhajans" ON public.bhajans;
CREATE POLICY "Contributors can create bhajans"
  ON public.bhajans
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = created_by
  );

-- Users can update own bhajans, reviewers and admins can update any
DROP POLICY IF EXISTS "Users can update own bhajans, admins can update any" ON public.bhajans;
DROP POLICY IF EXISTS "Users can update own bhajans, editors and admins can update any" ON public.bhajans;
CREATE POLICY "Users can update own bhajans, reviewers and admins can update any"
  ON public.bhajans
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = created_by OR 
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role IN ('reviewer', 'admin')
    )
  );

-- Only admins can delete bhajans
DROP POLICY IF EXISTS "Only admins can delete bhajans" ON public.bhajans;
CREATE POLICY "Only admins can delete bhajans"
  ON public.bhajans
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =============================================
-- Bhajan tags policies
-- =============================================

-- Anyone can view tags for visible bhajans
DROP POLICY IF EXISTS "Anyone can view tags for visible bhajans" ON public.bhajan_tags;
CREATE POLICY "Anyone can view tags for visible bhajans"
  ON public.bhajan_tags
  FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM public.bhajans
      WHERE id = bhajan_id AND status = 'approved'
    )
  );

-- Contributors can manage tags on their own bhajans
DROP POLICY IF EXISTS "Editors and admins can manage tags" ON public.bhajan_tags;
CREATE POLICY "Contributors can manage tags"
  ON public.bhajan_tags
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.bhajans
      WHERE id = bhajan_id AND created_by = auth.uid()
    )
  );

-- =============================================
-- Reports policies
-- =============================================

-- Users can view own reports, admins can view all
DROP POLICY IF EXISTS "Users can view own reports, admins can view all" ON public.reports;
CREATE POLICY "Users can view own reports, admins can view all"
  ON public.reports
  FOR SELECT
  TO authenticated
  USING (
    reported_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Only admins and reviewers can update reports
DROP POLICY IF EXISTS "Only admins can update reports" ON public.reports;
CREATE POLICY "Only admins and reviewers can update reports"
  ON public.reports
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role IN ('reviewer', 'admin')
    )
  );

-- =============================================
-- Audit log policies
-- =============================================

-- Users can view own audit logs, admins can view all
DROP POLICY IF EXISTS "Users can view own audit logs, admins can view all" ON public.audit_log;
CREATE POLICY "Users can view own audit logs, admins can view all"
  ON public.audit_log
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =============================================
-- User profiles policies
-- =============================================

-- Admins can update any profile
DROP POLICY IF EXISTS "Admins can update any profile" ON public.user_profiles;
CREATE POLICY "Admins can update any profile"
  ON public.user_profiles
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =============================================
-- Recreate views if they exist
-- =============================================

-- Drop and recreate bhajans_with_details view if it exists
DROP VIEW IF EXISTS public.bhajans_with_details CASCADE;
CREATE OR REPLACE VIEW public.bhajans_with_details AS
SELECT 
  b.*,
  up.email as creator_email,
  up.role as creator_role
FROM public.bhajans b
LEFT JOIN public.user_profiles up ON b.created_by = up.id;

-- Drop and recreate dashboard_stats view if it exists
DROP VIEW IF EXISTS public.dashboard_stats CASCADE;
CREATE OR REPLACE VIEW public.dashboard_stats AS
SELECT 
  (SELECT COUNT(*) FROM public.bhajans WHERE status = 'approved') as total_approved_bhajans,
  (SELECT COUNT(*) FROM public.bhajans WHERE status = 'pending_review') as pending_review_bhajans,
  (SELECT COUNT(*) FROM public.user_profiles) as total_users,
  (SELECT COUNT(*) FROM public.reports WHERE status = 'open') as open_reports;
