-- =============================================
-- Update User Roles System
-- =============================================

-- Step 1: Handle role column migration
DO $$ 
DECLARE
  role_column_exists boolean;
  role_new_column_exists boolean;
  current_role_type text;
BEGIN
  -- Check if role column exists
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public'
    AND table_name = 'user_profiles' 
    AND column_name = 'role'
  ) INTO role_column_exists;

  -- Check if role_new column exists
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public'
    AND table_name = 'user_profiles' 
    AND column_name = 'role_new'
  ) INTO role_new_column_exists;

  -- Get current type of role column if it exists
  IF role_column_exists THEN
    SELECT udt_name INTO current_role_type
    FROM information_schema.columns 
    WHERE table_schema = 'public'
    AND table_name = 'user_profiles' 
    AND column_name = 'role';
  END IF;

  -- If role already uses user_role with contributor, skip migration
  IF role_column_exists AND current_role_type = 'user_role' AND EXISTS (
    SELECT 1 FROM pg_enum e
    JOIN pg_type t ON e.enumtypid = t.oid
    WHERE t.typname = 'user_role' AND e.enumlabel = 'contributor'
  ) THEN
    RAISE NOTICE 'Role column already migrated to new type';
    RETURN;
  END IF;

  -- Create new role type if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role_new') THEN
    CREATE TYPE user_role_new AS ENUM ('contributor', 'reviewer', 'admin');
    RAISE NOTICE 'Created user_role_new type';
  END IF;

  -- Add temporary column if it doesn't exist
  IF NOT role_new_column_exists THEN
    ALTER TABLE public.user_profiles ADD COLUMN role_new user_role_new;
    RAISE NOTICE 'Added role_new column';
  END IF;

  -- Migrate data if role column exists and role_new is null
  IF role_column_exists THEN
    UPDATE public.user_profiles 
    SET role_new = CASE 
      WHEN role::text = 'admin' THEN 'admin'::user_role_new
      WHEN role::text = 'editor' THEN 'contributor'::user_role_new
      WHEN role::text = 'user' THEN 'contributor'::user_role_new
      ELSE 'contributor'::user_role_new
    END
    WHERE role_new IS NULL;
    RAISE NOTICE 'Migrated role data';

    -- Drop old role column with CASCADE
    ALTER TABLE public.user_profiles DROP COLUMN role CASCADE;
    RAISE NOTICE 'Dropped old role column with CASCADE';
  END IF;

  -- Rename role_new to role
  IF role_new_column_exists OR NOT role_column_exists THEN
    ALTER TABLE public.user_profiles RENAME COLUMN role_new TO role;
    RAISE NOTICE 'Renamed role_new to role';
  END IF;

  -- Set constraints
  ALTER TABLE public.user_profiles ALTER COLUMN role SET NOT NULL;
  ALTER TABLE public.user_profiles ALTER COLUMN role SET DEFAULT 'contributor'::user_role_new;
  RAISE NOTICE 'Set NOT NULL and DEFAULT constraints';

  -- Drop old type and rename new type
  DROP TYPE IF EXISTS user_role CASCADE;
  ALTER TYPE user_role_new RENAME TO user_role;
  RAISE NOTICE 'Renamed user_role_new to user_role';

  -- Update default to use renamed type
  ALTER TABLE public.user_profiles ALTER COLUMN role SET DEFAULT 'contributor'::user_role;

  -- Add comments
  COMMENT ON TYPE user_role IS 'contributor: Can create and edit own bhajans, reviewer: Can approve/reject bhajans, admin: Full access';
  COMMENT ON COLUMN public.user_profiles.role IS 'User role: contributor (default), reviewer, or admin';
  RAISE NOTICE 'Migration completed successfully';

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error during migration: %', SQLERRM;
    RAISE;
END $$;

-- Recreate RLS policies with new roles

-- =============================================
-- Bhajans table policies
-- =============================================

-- Drop all existing bhajan policies first
DROP POLICY IF EXISTS "Anyone can view approved bhajans" ON public.bhajans;
DROP POLICY IF EXISTS "Editors and admins can create bhajans" ON public.bhajans;
DROP POLICY IF EXISTS "Contributors can create bhajans" ON public.bhajans;
DROP POLICY IF EXISTS "Users can update own bhajans, admins can update any" ON public.bhajans;
DROP POLICY IF EXISTS "Users can update own bhajans, editors and admins can update any" ON public.bhajans;
DROP POLICY IF EXISTS "Users can update own bhajans, reviewers and admins can update any" ON public.bhajans;
DROP POLICY IF EXISTS "Only admins can delete bhajans" ON public.bhajans;

-- Anyone can view approved bhajans
CREATE POLICY "Anyone can view approved bhajans"
  ON public.bhajans
  FOR SELECT
  TO public
  USING (status = 'approved');

-- Contributors can create bhajans
CREATE POLICY "Contributors can create bhajans"
  ON public.bhajans
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = created_by
  );

-- Users can update own bhajans, reviewers and admins can update any
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
  )
  WITH CHECK (
    -- Allow if user is the creator OR if user is reviewer/admin
    auth.uid() = created_by OR 
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role IN ('reviewer', 'admin')
    )
  );

-- Only admins can delete bhajans
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

-- Drop all existing bhajan_tags policies first
DROP POLICY IF EXISTS "Anyone can view tags for visible bhajans" ON public.bhajan_tags;
DROP POLICY IF EXISTS "Editors and admins can manage tags" ON public.bhajan_tags;
DROP POLICY IF EXISTS "Contributors can manage tags" ON public.bhajan_tags;

-- Anyone can view tags for visible bhajans
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

-- Drop all existing reports policies first
DROP POLICY IF EXISTS "Users can view own reports, admins can view all" ON public.reports;
DROP POLICY IF EXISTS "Only admins can update reports" ON public.reports;
DROP POLICY IF EXISTS "Only admins and reviewers can update reports" ON public.reports;

-- Users can view own reports, admins can view all
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

-- Drop all existing audit_log policies first
DROP POLICY IF EXISTS "Users can view own audit logs, admins can view all" ON public.audit_log;

-- Users can view own audit logs, admins can view all
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

-- Drop all existing user_profiles policies first
DROP POLICY IF EXISTS "Admins can update any profile" ON public.user_profiles;

-- Admins can update any profile
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
