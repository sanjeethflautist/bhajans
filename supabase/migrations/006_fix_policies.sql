-- =============================================
-- Fix RLS Policies for New Role System
-- =============================================
-- This migration ensures all policies are correctly set up
-- for the contributor/reviewer/admin role system

-- =============================================
-- Bhajans table policies
-- =============================================

-- Drop ALL existing policies on bhajans table
DO $$ 
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'bhajans'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.bhajans', pol.policyname);
  END LOOP;
END $$;

-- Create fresh policies for bhajans
CREATE POLICY "Anyone can view approved bhajans"
  ON public.bhajans
  FOR SELECT
  TO public
  USING (status = 'approved');

CREATE POLICY "Contributors can create bhajans"
  ON public.bhajans
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = created_by
  );

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
    -- Contributors can update their own bhajans
    -- Reviewers and admins can update any bhajan
    auth.uid() = created_by OR 
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND role IN ('reviewer', 'admin')
    )
  );

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

-- Drop ALL existing policies on bhajan_tags table
DO $$ 
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'bhajan_tags'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.bhajan_tags', pol.policyname);
  END LOOP;
END $$;

-- Create fresh policies for bhajan_tags
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

-- Drop ALL existing policies on reports table
DO $$ 
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'reports'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.reports', pol.policyname);
  END LOOP;
END $$;

-- Create fresh policies for reports
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

-- Drop ALL existing policies on audit_log table
DO $$ 
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'audit_log'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.audit_log', pol.policyname);
  END LOOP;
END $$;

-- Create fresh policies for audit_log
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

-- Drop ALL existing policies on user_profiles table
DO $$ 
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'user_profiles'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.user_profiles', pol.policyname);
  END LOOP;
END $$;

-- Create fresh policies for user_profiles
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

-- Add SELECT policy for user_profiles if missing
CREATE POLICY "Users can view all profiles"
  ON public.user_profiles
  FOR SELECT
  TO authenticated
  USING (true);
