-- =============================================
-- Add Multi-Script Support for Bhajans
-- =============================================

-- Add columns for different scripts and meaning
ALTER TABLE public.bhajans 
ADD COLUMN IF NOT EXISTS lyrics_kannada TEXT,
ADD COLUMN IF NOT EXISTS lyrics_devanagari TEXT,
ADD COLUMN IF NOT EXISTS meaning TEXT;

-- Create indexes for full-text search on new columns
CREATE INDEX IF NOT EXISTS idx_bhajans_search_kannada ON public.bhajans 
USING GIN (to_tsvector('english', COALESCE(lyrics_kannada, '')));

CREATE INDEX IF NOT EXISTS idx_bhajans_search_devanagari ON public.bhajans 
USING GIN (to_tsvector('english', COALESCE(lyrics_devanagari, '')));

-- Update the existing full-text search index to include all scripts
DROP INDEX IF EXISTS idx_bhajans_search;

CREATE INDEX idx_bhajans_search ON public.bhajans 
USING GIN (to_tsvector('english', 
  title || ' ' || 
  COALESCE(lyrics, '') || ' ' || 
  COALESCE(lyrics_kannada, '') || ' ' || 
  COALESCE(lyrics_devanagari, '') || ' ' || 
  COALESCE(description, '') || ' ' || 
  COALESCE(meaning, '')
));

-- Add comments to document the columns
COMMENT ON COLUMN public.bhajans.lyrics IS 'Lyrics in English/Roman script';
COMMENT ON COLUMN public.bhajans.lyrics_kannada IS 'Lyrics in Kannada script';
COMMENT ON COLUMN public.bhajans.lyrics_devanagari IS 'Lyrics in Devanagari script';
COMMENT ON COLUMN public.bhajans.meaning IS 'Meaning/translation of the bhajan';
