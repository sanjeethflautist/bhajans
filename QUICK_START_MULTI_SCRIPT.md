# Quick Start Guide - Multi-Script Feature

## 🚀 How to Apply the Changes

### Step 1: Apply Database Migration

You have two options:

#### Option A: Using Supabase CLI (Recommended)
```bash
cd /Users/snayak/Desktop/projects/bhajans
supabase db push
```

#### Option B: Manual Application via Supabase Dashboard
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Open `supabase/migrations/003_add_multi_script_support.sql`
4. Copy and paste the contents into the SQL Editor
5. Click "Run"

### Step 2: Verify Installation

No additional npm packages needed! All changes use existing dependencies.

### Step 3: Test the Features

1. **Start your development server** (if not already running):
   ```bash
   npm run dev
   ```

2. **Test the Preferences Menu:**
   - Look for the gear icon (⚙️) in the navbar
   - Click it to open preferences
   - Try toggling different scripts
   - Toggle "Show Meaning" on/off

3. **Create a Test Bhajan:**
   - Go to "Create" page
   - Fill in the title and English lyrics (required)
   - Add Kannada lyrics (optional)
   - Add Devanagari lyrics (optional)
   - Add meaning/translation (optional)
   - Save and view

4. **View the Results:**
   - Go to Browse/Home page
   - Check bhajan cards show lyrics in enabled scripts
   - Click on a bhajan to see the detail page
   - Verify all enabled scripts are displayed
   - Check meaning section appears when toggle is on

## 🎯 Usage Examples

### Example 1: Create Bhajan with All Scripts

**Title:** Om Namah Shivaya

**English Lyrics:**
```
Om Namah Shivaya
Om Namah Shivaya
Har Har Mahadev
```

**Kannada Lyrics:**
```
ಓಂ ನಮಃ ಶಿವಾಯ
ಓಂ ನಮಃ ಶಿವಾಯ
ಹರ ಹರ ಮಹಾದೇವ
```

**Devanagari Lyrics:**
```
ॐ नमः शिवाय
ॐ नमः शिवाय
हर हर महादेव
```

**Meaning:**
```
Salutations to Lord Shiva, the auspicious one.
This mantra invokes the divine grace and blessings of Lord Shiva.
```

### Example 2: User Preference Settings

**To view only Kannada:**
1. Click preferences (⚙️)
2. Uncheck "English" and "Devanagari"
3. Keep only "ಕನ್ನಡ" checked
4. Result: Only Kannada lyrics will be displayed

**To view meaning:**
1. Click preferences (⚙️)
2. Toggle "Show Meaning" to ON
3. Result: Meaning section appears on detail pages and cards

## 📱 Testing Checklist

- [ ] Database migration applied successfully
- [ ] Preferences icon appears in navbar (desktop)
- [ ] Preferences section appears in mobile menu
- [ ] Can toggle between different scripts
- [ ] Can enable/disable meaning display
- [ ] Settings persist after page reload
- [ ] Create form has all new fields
- [ ] Bhajan cards respect preference settings
- [ ] Detail page shows all enabled scripts
- [ ] At least one script always remains enabled
- [ ] Mobile responsive layout works correctly

## 🐛 Troubleshooting

### Preferences not saving?
- Check browser localStorage is enabled
- Try clearing browser cache and cookies
- Verify browser console for errors

### Scripts not displaying?
- Ensure bhajan has content in that script
- Verify script is enabled in preferences
- Check database migration was applied

### Migration errors?
- Verify you're connected to the correct Supabase project
- Check Supabase logs for specific error messages
- Ensure you have admin permissions on the database

## 📞 Support

If you encounter any issues:
1. Check browser console for JavaScript errors
2. Check Supabase logs for database errors
3. Verify all files were updated correctly
4. Review `MULTI_SCRIPT_FEATURE.md` for detailed documentation

---

**Note:** The application is backward compatible. Existing bhajans without Kannada/Devanagari lyrics will continue to work normally, displaying only English lyrics.
