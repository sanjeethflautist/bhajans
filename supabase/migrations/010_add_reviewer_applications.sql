-- Create reviewer_applications table
CREATE TABLE IF NOT EXISTS public.reviewer_applications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  motivation TEXT NOT NULL,
  experience TEXT NOT NULL,
  languages TEXT NOT NULL,
  comments TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  reviewed_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_reviewer_applications_status ON public.reviewer_applications(status);
CREATE INDEX IF NOT EXISTS idx_reviewer_applications_created_at ON public.reviewer_applications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviewer_applications_user_id ON public.reviewer_applications(user_id);

-- Enable Row Level Security
ALTER TABLE public.reviewer_applications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can submit reviewer applications" ON public.reviewer_applications;
DROP POLICY IF EXISTS "Users can view their own applications" ON public.reviewer_applications;
DROP POLICY IF EXISTS "Admins can view all applications" ON public.reviewer_applications;
DROP POLICY IF EXISTS "Admins can update applications" ON public.reviewer_applications;

-- Users can submit applications
CREATE POLICY "Users can submit reviewer applications"
  ON public.reviewer_applications FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can view their own applications
CREATE POLICY "Users can view their own applications"
  ON public.reviewer_applications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Admins can view all applications
CREATE POLICY "Admins can view all applications"
  ON public.reviewer_applications FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role = 'admin'
    )
  );

-- Admins can update applications
CREATE POLICY "Admins can update applications"
  ON public.reviewer_applications FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role = 'admin'
    )
  );
