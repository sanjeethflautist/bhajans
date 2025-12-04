# Deployment Guide

This guide covers deploying the Bhajan Management Tool to production.

## Pre-Deployment Checklist

Before deploying, ensure you have:

- [ ] Completed Supabase setup (see SUPABASE_SETUP.md)
- [ ] Tested all features locally
- [ ] Created at least one admin user
- [ ] Configured environment variables
- [ ] Tested authentication flow
- [ ] Verified RLS policies are working
- [ ] Enabled database backups in Supabase

## Deployment Options

### Option 1: Deploy to Vercel (Recommended)

Vercel offers the best integration with Vite and provides automatic deployments.

#### Prerequisites
- GitHub account
- Vercel account (free tier is sufficient)
- Code pushed to a GitHub repository

#### Steps

1. **Push Code to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/yourusername/bhajan-tool.git
   git push -u origin main
   ```

2. **Connect to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "Add New" → "Project"
   - Import your GitHub repository
   - Vercel will auto-detect it's a Vite project

3. **Configure Environment Variables**
   - In the deployment settings, add these variables:
     ```
     VITE_SUPABASE_URL=https://your-project.supabase.co
     VITE_SUPABASE_ANON_KEY=your-anon-key-here
     VITE_APP_NAME=Bhajan Manager
     ```

4. **Deploy**
   - Click "Deploy"
   - Wait for the build to complete (~2-3 minutes)
   - Your app will be live at `https://your-project.vercel.app`

5. **Configure Custom Domain (Optional)**
   - Go to your project settings
   - Click "Domains"
   - Add your custom domain
   - Update DNS records as instructed

#### Automatic Deployments

Every push to your main branch will automatically deploy to Vercel.

To deploy from a different branch:
- Create a new branch
- Push your changes
- Vercel will create a preview deployment
- Merge to main to deploy to production

### Option 2: Deploy to Netlify

Netlify is another excellent option with similar features to Vercel.

#### Steps

1. **Push Code to GitHub** (same as Vercel)

2. **Connect to Netlify**
   - Go to [netlify.com](https://netlify.com)
   - Click "Add new site" → "Import an existing project"
   - Connect your GitHub account
   - Select your repository

3. **Configure Build Settings**
   ```
   Build command: npm run build
   Publish directory: dist
   ```

4. **Add Environment Variables**
   - Go to Site settings → Environment variables
   - Add the same variables as for Vercel

5. **Deploy**
   - Click "Deploy site"
   - Wait for the build to complete
   - Your app will be live at `https://your-site.netlify.app`

### Option 3: Self-Hosted (VPS/Cloud)

For more control, you can deploy to your own server.

#### Prerequisites
- VPS or cloud server (DigitalOcean, AWS, etc.)
- Node.js 18+ installed
- Nginx or Apache web server
- Domain name (optional)

#### Steps

1. **Build the Application**
   ```bash
   npm run build
   ```
   This creates a `dist` folder with static files.

2. **Upload to Server**
   ```bash
   scp -r dist/* user@your-server.com:/var/www/bhajan-tool/
   ```

3. **Configure Web Server**

   **Nginx Configuration:**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       root /var/www/bhajan-tool;
       index index.html;

       location / {
           try_files $uri $uri/ /index.html;
       }

       # Enable gzip compression
       gzip on;
       gzip_types text/css application/javascript application/json;
       
       # Cache static assets
       location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
           expires 1y;
           add_header Cache-Control "public, immutable";
       }
   }
   ```

4. **Set Up SSL (Recommended)**
   ```bash
   sudo certbot --nginx -d your-domain.com
   ```

5. **Start/Restart Web Server**
   ```bash
   sudo systemctl restart nginx
   ```

## Environment Configuration

### Development Environment

`.env.local` (local development):
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
VITE_APP_NAME=Bhajan Manager (Dev)
```

### Production Environment

Configure these in your hosting platform's environment variables:
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
VITE_APP_NAME=Bhajan Manager
```

⚠️ **Important**: Never commit `.env.local` to version control!

## Post-Deployment Tasks

### 1. Update Supabase Site URL

1. Go to Supabase Dashboard → Authentication → URL Configuration
2. Update "Site URL" to your production domain
3. Add your domain to "Redirect URLs"

### 2. Configure CORS (if needed)

If you're using a custom domain:
1. Go to Supabase Dashboard → Settings → API
2. Update CORS settings to allow your domain

### 3. Test Production Deployment

- [ ] Visit your production URL
- [ ] Test signup/login flow
- [ ] Create a test bhajan
- [ ] Test search and filtering
- [ ] Test reporting system (as user)
- [ ] Test admin dashboard (as admin)
- [ ] Test on mobile devices
- [ ] Check browser console for errors

### 4. Set Up Monitoring

#### Vercel Analytics (for Vercel deployments)
1. Go to your project in Vercel
2. Click "Analytics" tab
3. Enable analytics to track:
   - Page views
   - Performance metrics
   - User engagement

#### Supabase Monitoring
1. Go to Supabase Dashboard → Database → Reports
2. Monitor:
   - Database performance
   - Connection pool usage
   - Query performance
   - Storage usage

### 5. Configure Backups

1. Go to Supabase Dashboard → Settings → Database
2. Enable daily backups
3. Set retention period (7-30 days)
4. Test restore procedure

## Performance Optimization

### Frontend Optimization

The build process automatically:
- ✅ Minifies JavaScript and CSS
- ✅ Tree-shakes unused code
- ✅ Optimizes images
- ✅ Generates source maps (for debugging)

Additional optimizations:
- Enable gzip compression on your server
- Set up CDN for static assets (Vercel/Netlify do this automatically)
- Implement service workers for offline support (optional)

### Database Optimization

1. **Indexes**: Already created by migration
2. **Connection Pooling**: Enabled by default in Supabase
3. **Query Optimization**: Use `select` to fetch only needed columns

### Caching Strategy

The app already implements:
- Pinia state management (client-side caching)
- Debounced search (reduces API calls)
- Lazy loading for routes

## Security Hardening

### Production Security Checklist

- [ ] Email verification enabled
- [ ] Strong password policy enforced
- [ ] RLS policies tested and verified
- [ ] API keys stored securely (environment variables)
- [ ] HTTPS enabled (SSL certificate)
- [ ] CORS configured correctly
- [ ] Rate limiting considered (add if needed)
- [ ] Security headers configured (CSP, etc.)
- [ ] Regular security audits scheduled
- [ ] Database backups tested

### Security Headers (Nginx)

Add these to your Nginx config:
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

## Monitoring and Maintenance

### What to Monitor

1. **Uptime**: Use UptimeRobot or similar
2. **Error Rates**: Check browser console errors
3. **Performance**: Monitor page load times
4. **Database Usage**: Track connections and storage
5. **User Activity**: Monitor signup/login patterns

### Regular Maintenance Tasks

**Daily:**
- Check error logs
- Monitor user signups
- Review open reports

**Weekly:**
- Review database performance
- Check backup status
- Analyze user feedback

**Monthly:**
- Update dependencies (`npm outdated`)
- Review and optimize database queries
- Audit security settings
- Test disaster recovery procedures

## Troubleshooting Production Issues

### Build Failures

**Problem**: Build fails on Vercel/Netlify
```bash
# Solution: Check Node.js version
# Add .nvmrc file to specify Node version
echo "18" > .nvmrc
```

**Problem**: Environment variables not working
- Ensure variables are prefixed with `VITE_`
- Restart deployment after adding variables
- Check that variables are set in platform settings

### Runtime Errors

**Problem**: "Failed to fetch" errors
- Check Supabase URL is correct
- Verify API key is valid
- Check CORS settings in Supabase

**Problem**: Authentication not working
- Update Site URL in Supabase
- Add production domain to Redirect URLs
- Check that email auth is enabled

### Performance Issues

**Problem**: Slow page loads
- Enable CDN (automatic on Vercel/Netlify)
- Optimize images
- Check database query performance

**Problem**: Database connection errors
- Enable connection pooling
- Check concurrent connection limits
- Optimize queries to reduce connections

## Rollback Procedure

If you need to rollback a deployment:

### Vercel
1. Go to your project deployments
2. Find the last working deployment
3. Click "..." → "Promote to Production"

### Netlify
1. Go to Deploys
2. Find the last working deploy
3. Click "Publish deploy"

### Self-Hosted
```bash
# Backup current version
cp -r /var/www/bhajan-tool /var/www/bhajan-tool.backup

# Restore previous version
cp -r /var/www/bhajan-tool.previous /var/www/bhajan-tool

# Restart web server
sudo systemctl restart nginx
```

## Scaling Considerations

As your app grows, consider:

1. **Database Scaling**
   - Upgrade Supabase plan for more connections
   - Optimize queries with proper indexes
   - Consider read replicas for high traffic

2. **Frontend Scaling**
   - Use CDN for static assets (automatic on Vercel/Netlify)
   - Implement caching strategies
   - Consider using a service worker

3. **Feature Flags**
   - Implement feature flags for gradual rollouts
   - A/B test new features
   - Quick rollback of problematic features

## Cost Estimates

### Free Tier Limits

**Supabase Free:**
- 500 MB database
- 1 GB file storage
- 2 GB bandwidth
- 50,000 monthly active users

**Vercel Free:**
- 100 GB bandwidth
- Unlimited deployments
- Automatic HTTPS

**Netlify Free:**
- 100 GB bandwidth
- 300 build minutes/month
- Automatic HTTPS

### Upgrade Costs

**Supabase Pro** ($25/month):
- 8 GB database
- 100 GB file storage
- 250 GB bandwidth
- Unlimited MAU

**Vercel Pro** ($20/month):
- 1 TB bandwidth
- Advanced analytics
- Team collaboration

## Support and Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Netlify Documentation](https://docs.netlify.com)
- [Supabase Documentation](https://supabase.com/docs)
- [Vite Deployment Guide](https://vitejs.dev/guide/static-deploy.html)

---

Congratulations! Your Bhajan Management Tool is now deployed! 🎉
