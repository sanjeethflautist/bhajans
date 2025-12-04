-- =============================================
-- Add View Counters for Bhajans
-- =============================================

-- Add view_count column to bhajans table
ALTER TABLE public.bhajans 
ADD COLUMN IF NOT EXISTS view_count INTEGER NOT NULL DEFAULT 0;

-- Create index for view_count for sorting by popularity
CREATE INDEX IF NOT EXISTS idx_bhajans_view_count ON public.bhajans(view_count DESC);

-- Add total_views column for home page visit tracking
CREATE TABLE IF NOT EXISTS public.site_stats (
    id INTEGER PRIMARY KEY DEFAULT 1,
    total_home_visits INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT single_row CHECK (id = 1)
);

-- Insert initial row
INSERT INTO public.site_stats (id, total_home_visits) 
VALUES (1, 0) 
ON CONFLICT (id) DO NOTHING;

-- Function to increment bhajan view count
CREATE OR REPLACE FUNCTION increment_bhajan_view_count(bhajan_uuid UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.bhajans 
  SET view_count = view_count + 1 
  WHERE id = bhajan_uuid;
END;
$$;

-- Function to increment home page visit count
CREATE OR REPLACE FUNCTION increment_home_visits()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.site_stats 
  SET total_home_visits = total_home_visits + 1 
  WHERE id = 1;
END;
$$;

-- Create a view for overall statistics
CREATE OR REPLACE VIEW public.site_statistics AS
SELECT 
  (SELECT COUNT(*) FROM public.bhajans WHERE status = 'approved') as total_bhajans,
  (SELECT SUM(view_count) FROM public.bhajans) as total_bhajan_views,
  (SELECT total_home_visits FROM public.site_stats WHERE id = 1) as total_home_visits;

-- RLS Policies for site_stats
ALTER TABLE public.site_stats ENABLE ROW LEVEL SECURITY;

-- Everyone can read site stats
CREATE POLICY "Anyone can read site stats"
  ON public.site_stats
  FOR SELECT
  TO public
  USING (true);

-- Grant permissions
GRANT SELECT ON public.site_statistics TO authenticated;
GRANT SELECT ON public.site_statistics TO anon;
