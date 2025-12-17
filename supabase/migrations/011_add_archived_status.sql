-- Add archived status to bhajans and feature requests

-- Update bhajan_status enum to include archived
ALTER TYPE bhajan_status ADD VALUE IF NOT EXISTS 'archived';

-- Update feedback status check constraint to include archived (already exists)
-- No changes needed for feedback table

-- Update feature_requests status check constraint
DO $$ 
BEGIN
  -- Drop the old constraint if it exists
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'feature_requests_status_check' 
    AND conrelid = 'public.feature_requests'::regclass
  ) THEN
    ALTER TABLE public.feature_requests DROP CONSTRAINT feature_requests_status_check;
  END IF;
  
  -- Add the new constraint with archived status
  ALTER TABLE public.feature_requests 
    ADD CONSTRAINT feature_requests_status_check 
    CHECK (status IN ('new', 'under_review', 'planned', 'completed', 'rejected', 'archived'));
END $$;
