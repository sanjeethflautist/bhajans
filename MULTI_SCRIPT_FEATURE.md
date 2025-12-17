# Multi-Script Support Feature

This document describes the multi-script and meaning display features added to the Bhajan Manager application.

## Overview

The application now supports displaying bhajan titles and lyrics in three different scripts:
- **English/Roman Script** (default)
- **Kannada Script** (ಕನ್ನಡ)
- **Devanagari Script** (देवनागरी)

Additionally, users can view the meaning/translation of bhajans when available.

## Database Changes

### Migrations

**Migration 003:** `003_add_multi_script_support.sql`
- Added `lyrics_kannada`, `lyrics_devanagari`, and `meaning` columns

**Migration 004:** `004_add_multi_script_titles.sql`
- Added `title_kannada` and `title_devanagari` columns

Added the following columns to the `bhajans` table:
- `title_kannada` - TEXT (nullable) - Title in Kannada script
- `title_devanagari` - TEXT (nullable) - Title in Devanagari script
- `lyrics_kannada` - TEXT (nullable) - Lyrics in Kannada script
- `lyrics_devanagari` - TEXT (nullable) - Lyrics in Devanagari script  
- `meaning` - TEXT (nullable) - Meaning or translation of the bhajan

The migrations also:
- Update full-text search indexes to include all script variants (titles and lyrics)
- Add comments documenting each column's purpose

### To Apply the Migration

```bash
# Using Supabase CLI
supabase db push

# Or manually execute the SQL file in your Supabase dashboard
```

## Frontend Changes

### 1. Preferences Store (`src/stores/preferencesStore.js`)

New Pinia store to manage user display preferences:

**State:**
- `showMeaning` - Boolean to toggle meaning display
- `enabledScripts` - Array of enabled script IDs

**Actions:**
- `toggleMeaning()` - Toggle meaning display on/off
- `toggleScript(scriptId)` - Enable/disable a specific script
- `isScriptEnabled(scriptId)` - Check if a script is enabled
- `resetToDefaults()` - Reset to default preferences

Preferences are persisted in localStorage.

### 2. Updated Components

#### BhajanForm Component
- Added separate input fields for each script:
  - Title (English/Roman) - **Required**
  - Title (Kannada) - Optional
  - Title (Devanagari) - Optional
  - Lyrics (English/Roman) - **Required**
  - Lyrics (Kannada) - Optional
  - Lyrics (Devanagari) - Optional
- Added meaning/translation field
- Form validation ensures at least English title and lyrics are provided

#### BhajanCard Component
- Displays main title (English) with additional titles below in enabled scripts
- Displays lyrics preview in all enabled scripts
- Shows meaning preview when enabled (in blue box)
- Respects user preferences from the preferences store

#### BhajanDetail Page
- Displays main title with additional titles in other scripts beneath it
- Displays full lyrics in all enabled scripts in separate sections
- Each script section is clearly labeled
- Shows meaning in a dedicated section when enabled
- Displays helpful message if no lyrics available in selected scripts

#### Navbar Component
- Added preferences button (gear icon) in desktop view
- Dropdown menu with:
  - Script checkboxes (English, Kannada, Devanagari)
  - Show Meaning toggle switch
- Mobile menu includes full preferences section
- At least one script must remain enabled

## User Experience

### For Creators (Adding Bhajans)

1. Navigate to Create Bhajan page
2. Fill in required fields (Title in English, Lyrics in English)
3. Optionally add:
   - Title in Kannada
   - Title in Devanagari
   - Kannada lyrics
   - Devanagari lyrics
   - Meaning/Translation
4. Submit bhajan

**Note:** English title and lyrics are mandatory, other scripts and meaning are optional.

### For Viewers (Browsing Bhajans)

1. Click the preferences icon (⚙️) in the navbar
2. Select which scripts to display:
   - Check/uncheck English, Kannada, or Devanagari
   - At least one script must be selected
3. Toggle "Show Meaning" to display translations
4. Preferences are saved and persist across sessions

### Display Behavior

- **Browse/Home Page**: Cards show previews in enabled scripts
- **Detail Page**: Full lyrics displayed in all enabled scripts with clear section headers
- **No Content**: If a bhajan doesn't have lyrics in an enabled script, that section is hidden
- **Meaning**: Only shown when toggle is ON and bhajan has meaning content

## Technical Details

### LocalStorage Keys

- `showMeaning` - Boolean as JSON string
- `enabledScripts` - Array of script IDs as JSON string

### Script Configuration

```javascript
const scriptOptions = [
  { id: 'english', label: 'English', field: 'lyrics' },
  { id: 'kannada', label: 'ಕನ್ನಡ', field: 'lyrics_kannada' },
  { id: 'devanagari', label: 'देवनागरी', field: 'lyrics_devanagari' }
]
```

### Data Flow

1. User changes preferences → Preferences store updated → LocalStorage updated
2. Components read from preferences store
3. Components filter/display content based on enabled scripts
4. Reactive updates ensure UI reflects preference changes immediately

## Accessibility

- Proper `lang` attributes set on text fields for screen readers
- Checkbox inputs for script selection (keyboard accessible)
- Toggle switch with clear visual states
- Semantic HTML structure maintained

## Browser Compatibility

Requires browser support for:
- localStorage API
- ES6+ JavaScript features
- Modern CSS (flexbox, grid, transitions)

## Future Enhancements

Possible improvements:
- Add more script options (Telugu, Tamil, etc.)
- Font customization for different scripts
- Audio pronunciation support
- Transliteration tools
- Batch import/export with multi-script support
