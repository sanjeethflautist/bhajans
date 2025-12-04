# Applying View Counter Migration

To add view counter functionality, you need to run the migration on your Supabase database.

## Steps:

1. Go to your Supabase project: https://supabase.com/dashboard/project/uuxujibnnjzsrptxwoxy

2. Navigate to **SQL Editor** in the left sidebar

3. Click **New Query**

4. Copy and paste the entire contents of `supabase/migrations/002_add_view_counters.sql`

5. Click **Run** to execute the migration

## What this migration adds:

- `view_count` column to the `bhajans` table (tracks individual bhajan views)
- `site_stats` table with `total_home_visits` (tracks homepage visits)
- `increment_bhajan_view_count()` function (increments bhajan view counter)
- `increment_home_visits()` function (increments homepage visit counter)
- `site_statistics` view (provides aggregate statistics)

## Verification:

After running the migration, you can verify it worked by running:

```sql
-- Check if view_count column was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'bhajans' AND column_name = 'view_count';

-- Check if site_stats table exists
SELECT * FROM public.site_stats;

-- Check if functions exist
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('increment_bhajan_view_count', 'increment_home_visits');
```
