# Supabase Setup Guide

This guide will walk you through setting up Supabase for the Bhajan Management Tool.

## Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign in or create a new account
3. Click "New Project"
4. Fill in the details:
   - **Name**: Bhajan Manager (or your preferred name)
   - **Database Password**: Choose a strong password (save this!)
   - **Region**: Select the region closest to your users
   - **Pricing Plan**: Free tier is sufficient to start
5. Click "Create new project"
6. Wait 2-3 minutes for your project to be provisioned

## Step 2: Run the Database Migration

### Option A: Using SQL Editor (Recommended)

1. In your Supabase dashboard, navigate to **SQL Editor** (left sidebar)
2. Click the **"New query"** button
3. Open the file `supabase/migrations/001_initial_schema.sql` from your project
4. Copy the entire contents
5. Paste it into the SQL Editor
6. Click **"Run"** button (or press Cmd/Ctrl + Enter)
7. Wait for the query to complete
8. You should see a success message

### Option B: Using Supabase CLI (Advanced)

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push
```

### Verify the Migration

1. Go to **Table Editor** in your Supabase dashboard
2. You should see these tables:
   - `user_profiles`
   - `bhajans`
   - `bhajan_tags`
   - `reports`
   - `audit_log`
3. Check that each table has the correct columns and relationships

## Step 3: Configure Authentication

### Enable Email Authentication

1. Go to **Authentication** → **Providers** in the sidebar
2. Find **Email** in the list of providers
3. Toggle it **ON** if not already enabled
4. Configure the settings:
   - ✅ Enable email confirmations (recommended for production)
   - ✅ Enable secure email change
   - Set confirmation URL to your app URL (e.g., `http://localhost:5173` for development)

### Configure Email Templates (Optional)

1. Go to **Authentication** → **Email Templates**
2. Customize the templates:
   - **Confirm signup**: Email sent when users sign up
   - **Invite user**: Email sent when admins invite users
   - **Magic Link**: For passwordless login (optional)
   - **Change Email Address**: Email confirmation for email changes
   - **Reset Password**: Password reset emails

## Step 4: Set Up Row Level Security (RLS)

The migration script automatically enables RLS and creates policies. To verify:

1. Go to **Authentication** → **Policies**
2. Select each table and verify policies exist:
   - `user_profiles`: 2 policies (view all, update own)
   - `bhajans`: 4 policies (view, create, update, delete)
   - `bhajan_tags`: 2 policies (view, manage)
   - `reports`: 3 policies (create, view, update)
   - `audit_log`: 2 policies (view, insert)

### Test RLS Policies

1. Sign up for a test account
2. Try accessing data through the API
3. Verify that users can only see approved bhajans
4. Verify that users cannot access admin-only features

## Step 5: Get Your API Credentials

1. Go to **Settings** → **API** in the sidebar
2. Copy these values:
   - **Project URL**: `https://xxxxxx.supabase.co`
   - **anon/public key**: Long string starting with `eyJ...`
3. Paste them into your `.env.local` file:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

⚠️ **Never commit the `service_role` key to version control!**

## Step 6: Configure Database Settings (Optional)

### Enable Realtime (Optional)

If you want real-time updates:

1. Go to **Database** → **Replication**
2. Select tables you want to enable realtime for
3. Click the toggle to enable replication

### Configure Backups

1. Go to **Settings** → **Database**
2. Scroll to **Backup** section
3. Enable daily backups (recommended)
4. Set retention period (7-30 days)

### Set Up Connection Pooling (Production)

1. Go to **Settings** → **Database**
2. Find **Connection Pooling** section
3. Use the pooled connection string for production
4. Configure pool size based on your needs

## Step 7: Create Your First Admin User

Since the first user will be a regular user by default, you need to manually promote them to admin:

### Method 1: Using Table Editor

1. Sign up for an account through your application
2. Go to **Table Editor** → **user_profiles**
3. Find your user record
4. Double-click the `role` cell
5. Change from `user` to `admin`
6. Click the checkmark to save
7. Refresh your application

### Method 2: Using SQL Editor

```sql
-- Replace 'your-email@example.com' with your actual email
UPDATE user_profiles 
SET role = 'admin' 
WHERE email = 'your-email@example.com';
```

## Step 8: Test the Integration

### Test Authentication

1. Start your development server: `npm run dev`
2. Go to `http://localhost:5173`
3. Click "Sign Up"
4. Create a test account
5. Check your email for confirmation (if enabled)
6. Sign in with your credentials

### Test Database Operations

1. Sign in as an editor/admin
2. Try creating a bhajan
3. Add some tags
4. Submit for review (as editor)
5. Review and approve (as admin)
6. Try the search and filter features

### Test Permissions

1. Sign in as a regular user
2. Verify you can only see approved bhajans
3. Verify you cannot access admin pages
4. Try reporting an issue

## Troubleshooting

### Migration Fails

**Error**: Permission denied
- Make sure you're using the SQL Editor in the Supabase dashboard
- Check that you have the correct permissions

**Error**: Relation already exists
- Tables may already be created
- Drop existing tables and re-run migration
- Or skip to the next step if tables are correct

### Authentication Issues

**Problem**: Users can't sign in
- Check that Email auth is enabled
- Verify API credentials in `.env.local`
- Check browser console for error messages

**Problem**: No confirmation email received
- Check your spam folder
- Verify email templates are configured
- Check SMTP settings in Supabase

### RLS Policy Issues

**Problem**: "Row level security is enabled but no policies exist"
- Re-run the migration script
- Manually create policies using SQL Editor
- Check policies in Authentication → Policies

**Problem**: Users can't access their own data
- Verify the user is authenticated
- Check the RLS policies match your requirements
- Use SQL Editor to test queries manually

### Connection Issues

**Problem**: Can't connect to Supabase
- Check your internet connection
- Verify the Project URL is correct
- Check if Supabase is experiencing downtime (status.supabase.com)

**Problem**: API key is invalid
- Regenerate the anon key in Settings → API
- Update `.env.local` with new key
- Restart your development server

## Production Checklist

Before deploying to production:

- [ ] Email confirmation is enabled
- [ ] Email templates are customized
- [ ] Strong password policy is enforced (6+ chars minimum)
- [ ] RLS policies are tested and working
- [ ] Backups are enabled
- [ ] API keys are stored in environment variables
- [ ] Connection pooling is configured
- [ ] Database performance is optimized
- [ ] Rate limiting is considered (use middleware)
- [ ] Monitoring and alerts are set up

## Security Best Practices

1. **Never expose the `service_role` key**
   - Only use `anon` key in client code
   - Store secrets in environment variables

2. **Enable email verification**
   - Prevents fake accounts
   - Ensures valid email addresses

3. **Use strong passwords**
   - Enforce minimum 8 characters
   - Require mix of letters, numbers, symbols

4. **Regularly backup your database**
   - Enable automatic backups
   - Test restore procedures

5. **Monitor for suspicious activity**
   - Check audit logs regularly
   - Set up alerts for unusual patterns

6. **Keep Supabase updated**
   - Watch for security updates
   - Apply patches promptly

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Auth Guide](https://supabase.com/docs/guides/auth)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Database Best Practices](https://supabase.com/docs/guides/database/database-best-practices)
- [Supabase CLI](https://supabase.com/docs/reference/cli)

---

If you encounter any issues not covered here, please:
1. Check the [Supabase Community](https://github.com/supabase/supabase/discussions)
2. Review the [Troubleshooting Guide](https://supabase.com/docs/guides/platform/troubleshooting)
3. Open an issue in this repository
