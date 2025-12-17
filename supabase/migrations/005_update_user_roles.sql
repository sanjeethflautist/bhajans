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

-- Drop the old column
ALTER TABLE public.user_profiles DROP COLUMN role;

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
