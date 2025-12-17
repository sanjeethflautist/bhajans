-- =============================================
-- Add Multi-Script Title Support
-- =============================================

-- Add columns for titles in different scripts
ALTER TABLE public.bhajans 
ADD COLUMN IF NOT EXISTS title_kannada TEXT,
ADD COLUMN IF NOT EXISTS title_devanagari TEXT;

-- Update the existing full-text search index to include all title variants
DROP INDEX IF EXISTS idx_bhajans_search;

CREATE INDEX idx_bhajans_search ON public.bhajans 
USING GIN (to_tsvector('english', 
  title || ' ' || 
  COALESCE(title_kannada, '') || ' ' || 
  COALESCE(title_devanagari, '') || ' ' || 
  COALESCE(lyrics, '') || ' ' || 
  COALESCE(lyrics_kannada, '') || ' ' || 
  COALESCE(lyrics_devanagari, '') || ' ' || 
  COALESCE(description, '') || ' ' || 
  COALESCE(meaning, '')
));

-- Add comments to document the columns
COMMENT ON COLUMN public.bhajans.title IS 'Title in English/Roman script';
COMMENT ON COLUMN public.bhajans.title_kannada IS 'Title in Kannada script';
COMMENT ON COLUMN public.bhajans.title_devanagari IS 'Title in Devanagari script';
