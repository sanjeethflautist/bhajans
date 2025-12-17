-- =============================================
-- Update User Roles System
-- =============================================

-- Drop old role type and create new one
ALTER TABLE public.user_profiles DROP CONSTRAINT IF EXISTS user_profiles_role_check;

-- Drop the old enum type (this will require updating existing data first)
-- First, set all users to a temporary valid value
UPDATE public.user_profiles SET role = 'user' WHERE role = 'editor';

-- Now we can safely modify the enum
-- Note: In PostgreSQL, we can't directly modify an enum, so we need to:
-- 1. Create a new type
-- 2. Update the column to use the new type
-- 3. Drop the old type

-- Create new role type
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role_new') THEN
    CREATE TYPE user_role_new AS ENUM ('contributor', 'reviewer', 'admin');
  END IF;
END $$;

-- Update all existing users to 'contributor' (everyone can create/edit their own bhajans)
UPDATE public.user_profiles SET role = 'contributor'::text WHERE role IN ('user', 'editor');

-- Alter the column to use new type
ALTER TABLE public.user_profiles 
  ALTER COLUMN role TYPE user_role_new 
  USING role::text::user_role_new;

-- Drop old type
DROP TYPE IF EXISTS user_role CASCADE;

-- Rename new type to old name
ALTER TYPE user_role_new RENAME TO user_role;

-- Update default role for new users
ALTER TABLE public.user_profiles 
  ALTER COLUMN role SET DEFAULT 'contributor'::user_role;

-- Add comments
COMMENT ON TYPE user_role IS 'contributor: Can create and edit own bhajans, reviewer: Can approve/reject bhajans, admin: Full access';
COMMENT ON COLUMN public.user_profiles.role IS 'User role: contributor (default), reviewer, or admin';
