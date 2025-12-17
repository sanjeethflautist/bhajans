-- =============================================
-- Verify Multi-Script Data
-- =============================================
-- This query checks if bhajans have multi-script data

SELECT 
  id,
  title,
  title_kannada,
  title_devanagari,
  CASE WHEN lyrics IS NOT NULL THEN 'YES' ELSE 'NO' END as has_lyrics,
  CASE WHEN lyrics_kannada IS NOT NULL THEN 'YES' ELSE 'NO' END as has_lyrics_kannada,
  CASE WHEN lyrics_devanagari IS NOT NULL THEN 'YES' ELSE 'NO' END as has_lyrics_devanagari,
  CASE WHEN meaning IS NOT NULL THEN 'YES' ELSE 'NO' END as has_meaning
FROM public.bhajans
ORDER BY created_at DESC
LIMIT 10;
