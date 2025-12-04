# Bhajan Management Tool

A comprehensive web-based platform for managing devotional bhajans with role-based access control, content review workflow, and user reporting features.

![Vue.js](https://img.shields.io/badge/Vue.js-3.4-42b883?logo=vue.js)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ecf8e?logo=supabase)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-CSS-38bdf8?logo=tailwind-css)

## Features

### 🎵 Core Functionality
- **Browse & Search**: Explore bhajans with advanced search and tag filtering
- **CRUD Operations**: Create, read, update, and delete bhajans
- **Tagging System**: Categorize bhajans with multiple tags
- **Rich Metadata**: Title, description, lyrics, and creator information

### 👥 User Management
- **Role-Based Access Control**: User, Editor, and Admin roles
- **Email/Password Authentication**: Secure signup and login via Supabase Auth
- **Protected Routes**: Route guards based on user permissions

### 📝 Review Workflow
- **Draft System**: Editors create bhajans as drafts
- **Review Queue**: Admins review and approve/reject submissions
- **Review Comments**: Feedback system for submitters
- **Status Tracking**: Draft → Pending Review → Approved/Rejected

### 🚨 Reporting System
- **User Reports**: Report incorrect lyrics, offensive content, copyright issues
- **Admin Dashboard**: Manage all reports with status tracking
- **Resolution Workflow**: Open → Under Review → Resolved/Dismissed

### 📊 Admin Dashboard
- **Statistics Overview**: Total bhajans, pending reviews, open reports
- **User Management**: Promote users to editor/admin roles
- **Audit Log**: Track all system activities
- **Recent Activity**: Monitor latest actions

## Technology Stack

- **Frontend**: Vue.js 3 with Composition API
- **Build Tool**: Vite
- **State Management**: Pinia
- **Routing**: Vue Router 4
- **Styling**: Tailwind CSS
- **Backend**: Supabase (PostgreSQL + Auth)
- **Deployment**: Vercel/Netlify (Frontend), Supabase Hosting (Backend)

## Project Structure

```
bhajan-tool/
├── src/
│   ├── components/          # Reusable Vue components
│   │   ├── BhajanCard.vue
│   │   ├── BhajanForm.vue
│   │   ├── TagSelector.vue
│   │   ├── ReviewPanel.vue
│   │   ├── ReportForm.vue
│   │   └── Navbar.vue
│   ├── pages/              # Page components
│   │   ├── Home.vue
│   │   ├── BhajanDetail.vue
│   │   ├── BhajanCreate.vue
│   │   ├── BhajanEdit.vue
│   │   ├── MyBhajans.vue
│   │   ├── AdminDashboard.vue
│   │   ├── ReviewQueue.vue
│   │   ├── ReportsPage.vue
│   │   ├── Login.vue
│   │   └── Signup.vue
│   ├── stores/             # Pinia stores
│   │   ├── authStore.js
│   │   ├── bhajanStore.js
│   │   ├── reportStore.js
│   │   └── tagStore.js
│   ├── services/           # API services
│   │   ├── supabaseClient.js
│   │   ├── authService.js
│   │   ├── bhajanService.js
│   │   ├── tagService.js
│   │   ├── reportService.js
│   │   ├── auditService.js
│   │   └── adminService.js
│   ├── router/            # Vue Router config
│   │   └── index.js
│   ├── App.vue
│   ├── main.js
│   └── style.css
├── supabase/
│   └── migrations/
│       └── 001_initial_schema.sql
├── public/
├── index.html
├── vite.config.js
├── tailwind.config.js
├── package.json
└── README.md
```

## Setup Instructions

### Prerequisites

- Node.js 18+ and npm
- A Supabase account (free tier is sufficient)

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd bhajan-tool
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Setup Supabase

#### Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in project details and click "Create new project"
4. Wait for the project to be provisioned

#### Run Database Migration

1. In your Supabase dashboard, go to **SQL Editor**
2. Open `supabase/migrations/001_initial_schema.sql`
3. Copy the entire contents
4. Paste into the SQL Editor and click "Run"
5. Verify all tables were created successfully

#### Enable Email Authentication

1. Go to **Authentication** → **Providers**
2. Enable **Email** provider
3. Configure email templates (optional)

#### Get API Credentials

1. Go to **Settings** → **API**
2. Copy your **Project URL** (looks like `https://xxxxx.supabase.co`)
3. Copy your **anon/public** key

### 4. Configure Environment Variables

Create a `.env.local` file in the root directory:

```bash
cp .env.example .env.local
```

Edit `.env.local` and add your Supabase credentials:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
VITE_APP_NAME=Bhajan Manager
```

### 5. Start Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:5173`

## User Roles & Permissions

### User (Default)
- Browse approved bhajans
- Search and filter bhajans
- Report issues
- View own reports

### Editor
- All User permissions
- Create bhajans (saved as drafts)
- Edit own bhajans
- Submit bhajans for review
- View own submissions

### Admin
- All Editor permissions
- Review and approve/reject bhajans
- Manage all bhajans (edit/delete any)
- View and manage all reports
- Access admin dashboard
- Promote users to editor/admin roles
- View audit logs

## Creating Your First Admin User

1. Sign up for a new account through the UI
2. Go to your Supabase dashboard
3. Navigate to **Table Editor** → **user_profiles**
4. Find your user record
5. Edit the `role` field and change it to `admin`
6. Save the changes
7. Refresh your application and you'll have admin access

## Database Schema

### Tables

- **user_profiles**: Extended user information with roles
- **bhajans**: Bhajan content with status tracking
- **bhajan_tags**: Many-to-many relationship for tags
- **reports**: User-submitted issue reports
- **audit_log**: System activity tracking

### Key Features

- Row Level Security (RLS) policies for data protection
- Automatic timestamp updates
- Foreign key relationships with cascade deletes
- Full-text search indexes
- Audit logging triggers

## Development

### Available Scripts

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Code Style

- Use Composition API with `<script setup>`
- Follow Vue.js 3 best practices
- Use Tailwind CSS utility classes
- Keep components small and focused
- Use Pinia for state management

## Deployment

### Frontend (Vercel/Netlify)

#### Vercel

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Click "New Project"
4. Import your repository
5. Add environment variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
   - `VITE_APP_NAME`
6. Click "Deploy"

#### Netlify

1. Push your code to GitHub
2. Go to [netlify.com](https://netlify.com)
3. Click "Add new site" → "Import an existing project"
4. Connect your repository
5. Set build settings:
   - Build command: `npm run build`
   - Publish directory: `dist`
6. Add environment variables
7. Click "Deploy site"

### Backend (Supabase)

Your Supabase backend is already hosted! Just ensure:
- Database is configured with the migration
- RLS policies are enabled
- Email auth is configured
- Backups are enabled (Project Settings → Database → Backups)

## Security Considerations

- ✅ RLS policies protect all data access
- ✅ JWT-based authentication
- ✅ Environment variables for sensitive data
- ✅ Input validation on client and server
- ✅ Role-based authorization
- ✅ Secure password requirements (6+ characters)
- ⚠️ Consider adding rate limiting for production
- ⚠️ Configure email verification for new accounts

## Performance Optimizations

- Lazy loading for route components
- Pagination for large lists
- Debounced search input
- Indexed database queries
- Optimized Tailwind CSS (purge unused styles)
- Vite build optimization

## Troubleshooting

### Authentication Issues

**Problem**: Can't sign in
- Check Supabase credentials in `.env.local`
- Verify email auth is enabled in Supabase
- Check browser console for errors

**Problem**: User created but no profile
- Ensure the trigger `on_auth_user_created` exists
- Check if migration ran successfully

### Database Issues

**Problem**: RLS policy errors
- Verify you're authenticated
- Check user role in `user_profiles` table
- Ensure RLS policies were created correctly

**Problem**: Can't see data
- Check RLS policies match your user role
- Verify data exists in the tables
- Check network tab for error responses

### Build Issues

**Problem**: Build fails
- Run `npm install` to ensure dependencies are installed
- Check Node.js version (18+ required)
- Clear `node_modules` and reinstall if needed

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License - feel free to use this project for your own purposes!

## Support

For issues and questions:
- Check the troubleshooting section
- Review Supabase documentation
- Check Vue.js documentation
- Open an issue on GitHub

## Roadmap

- [ ] Add media support (audio/video)
- [ ] Implement favorites/bookmarks
- [ ] Add social sharing features
- [ ] Create mobile app (React Native)
- [ ] Add batch operations for admins
- [ ] Implement advanced search with AI
- [ ] Add user profiles and contributions
- [ ] Create API for third-party integrations

---

Built with ❤️ using Vue.js and Supabase
