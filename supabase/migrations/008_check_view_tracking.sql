-- =============================================
-- Check View Tracking Setup
-- =============================================

-- Check if view_count column exists
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'bhajans' AND column_name = 'view_count';

-- Check if site_stats table exists
SELECT table_name 
FROM information_schema.tables 
WHERE table_name = 'site_stats';

-- Check if RPC functions exist
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('increment_bhajan_view_count', 'increment_home_visits');

-- Check current view counts
SELECT id, title, view_count 
FROM public.bhajans 
ORDER BY view_count DESC 
LIMIT 5;

-- Test increment function (comment out after testing)
-- SELECT increment_bhajan_view_count((SELECT id FROM public.bhajans LIMIT 1));
