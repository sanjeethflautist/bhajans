# Quick Start Guide

Get up and running with the Bhajan Management Tool in under 10 minutes!

## Prerequisites

- ✅ Node.js 18+ installed
- ✅ npm installed
- ✅ A Supabase account (free)

## Setup Steps

### 1. Install Dependencies (1 minute)

```bash
npm install
```

This installs all required packages:
- Vue.js 3
- Vite
- Pinia (state management)
- Vue Router
- Supabase client
- Tailwind CSS

### 2. Create Supabase Project (3 minutes)

1. Go to [supabase.com](https://supabase.com)
2. Sign in and click "New Project"
3. Fill in:
   - Name: `bhajan-tool`
   - Database Password: (save this!)
   - Region: (closest to you)
4. Click "Create new project"
5. Wait 2-3 minutes for provisioning

### 3. Setup Database (2 minutes)

1. In Supabase, go to **SQL Editor**
2. Click "New query"
3. Copy contents of `supabase/migrations/001_initial_schema.sql`
4. Paste into SQL Editor
5. Click "Run" (or press Cmd/Ctrl + Enter)
6. Wait for success message

### 4. Get API Credentials (1 minute)

1. In Supabase, go to **Settings** → **API**
2. Copy:
   - Project URL
   - anon public key
3. Create `.env.local` file:
   ```bash
   cp .env.example .env.local
   ```
4. Edit `.env.local` and paste your credentials:
   ```env
   VITE_SUPABASE_URL=https://xxxxx.supabase.co
   VITE_SUPABASE_ANON_KEY=eyJxxx...
   VITE_APP_NAME=Bhajan Manager
   ```

### 5. Enable Authentication (1 minute)

1. In Supabase, go to **Authentication** → **Providers**
2. Toggle **Email** ON
3. Configure:
   - Confirm email: ✅ ON (recommended)
   - Secure email change: ✅ ON

### 6. Start Development Server (1 minute)

```bash
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

### 7. Create Your Account (1 minute)

1. Click "Sign Up"
2. Enter email and password (6+ characters)
3. Submit the form
4. Check your email for confirmation (if enabled)
5. Sign in

### 8. Promote to Admin (1 minute)

Since you need admin access to test all features:

1. Go to Supabase → **Table Editor** → **user_profiles**
2. Find your user row
3. Double-click the `role` cell
4. Change from `user` to `admin`
5. Save
6. Refresh your app

## What to Try Next

Now that you're set up, try these features:

### As Admin
1. **Create a Bhajan**
   - Click "Create" in navbar
   - Fill in title, description, lyrics
   - Add some tags
   - Save as draft

2. **Submit for Review**
   - Go to "My Bhajans"
   - Click "Submit for Review" on your draft
   - It moves to pending status

3. **Review & Approve**
   - Go to "Admin" → "Review Queue"
   - Click "Show Details"
   - Add review comment
   - Click "Approve"

4. **Browse Bhajans**
   - Go to home page
   - Search and filter
   - Click on a bhajan to view details

5. **Test Reporting**
   - View any bhajan
   - Click "Report Issue"
   - Select issue type and describe
   - Submit report

6. **Manage Reports**
   - Go to "Admin" → "Reports"
   - Review open reports
   - Resolve or dismiss reports

### As Editor (create another account)
- Can create and edit own bhajans
- Can submit bhajans for review
- Cannot approve/reject bhajans
- Cannot access admin dashboard

### As User (create another account)
- Can browse approved bhajans only
- Can search and filter
- Can report issues
- Cannot create bhajans

## Project Structure Overview

```
bhajan-tool/
├── src/
│   ├── components/      # Reusable components
│   ├── pages/          # Page components (routes)
│   ├── stores/         # Pinia state management
│   ├── services/       # API services
│   ├── router/         # Vue Router config
│   └── style.css       # Tailwind styles
├── supabase/
│   └── migrations/     # Database schema
├── .env.example        # Example env file
└── README.md          # Full documentation
```

## Common Commands

```bash
# Start dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Install new package
npm install package-name
```

## Troubleshooting Quick Fixes

### Can't sign in?
- Check `.env.local` has correct Supabase credentials
- Verify email auth is enabled in Supabase
- Try clearing browser cache

### No data showing?
- Make sure migration ran successfully
- Check browser console for errors
- Verify you're signed in

### Build errors?
- Delete `node_modules` and run `npm install`
- Check Node.js version: `node --version` (should be 18+)
- Clear Vite cache: `rm -rf node_modules/.vite`

## Next Steps

1. **Read the full documentation**: `README.md`
2. **Learn about Supabase setup**: `SUPABASE_SETUP.md`
3. **Plan your deployment**: `DEPLOYMENT.md`
4. **Customize the app**:
   - Change colors in `tailwind.config.js`
   - Add new features
   - Customize email templates in Supabase

## Getting Help

- 📖 Check `README.md` for detailed docs
- 🔍 Search [Supabase docs](https://supabase.com/docs)
- 💬 Ask in [Supabase Discord](https://discord.supabase.com)
- 🐛 Open an issue on GitHub

## What You Built

Congratulations! You now have a full-featured bhajan management platform with:

✅ User authentication  
✅ Role-based access control  
✅ CRUD operations for bhajans  
✅ Tag management  
✅ Review workflow  
✅ Reporting system  
✅ Admin dashboard  
✅ Search and filtering  
✅ Audit logging  

Happy coding! 🎉
