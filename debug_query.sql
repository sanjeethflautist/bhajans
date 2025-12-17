-- Check current bhajans and their data
SELECT 
  id,
  title,
  title_kannada,
  title_devanagari,
  status,
  created_by,
  created_at,
  LENGTH(lyrics) as lyrics_length,
  LENGTH(lyrics_kannada) as kannada_length,
  LENGTH(lyrics_devanagari) as devanagari_length
FROM public.bhajans
ORDER BY created_at DESC
LIMIT 10;

-- Check tags
SELECT 
  bt.bhajan_id,
  b.title,
  bt.tag_name
FROM public.bhajan_tags bt
JOIN public.bhajans b ON b.id = bt.bhajan_id
ORDER BY b.created_at DESC
LIMIT 20;

-- Check user profiles
SELECT id, email, role FROM public.user_profiles;
