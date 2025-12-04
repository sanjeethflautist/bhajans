#!/bin/bash

# Bhajan Management Tool - Installation Script
# This script will guide you through the installation process

echo "=================================="
echo "Bhajan Management Tool Setup"
echo "=================================="
echo ""

# Check Node.js version
echo "Checking Node.js version..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    echo "   Visit: https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version is too old. Please upgrade to version 18 or higher."
    echo "   Current version: $(node -v)"
    exit 1
fi

echo "✅ Node.js version: $(node -v)"
echo ""

# Install dependencies
echo "Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed successfully"
echo ""

# Check for .env.local file
if [ ! -f .env.local ]; then
    echo "⚠️  No .env.local file found"
    echo "   Creating from .env.example..."
    cp .env.example .env.local
    echo "✅ Created .env.local"
    echo ""
    echo "⚠️  IMPORTANT: You must configure .env.local with your Supabase credentials!"
    echo ""
    echo "   1. Go to https://supabase.com"
    echo "   2. Create a new project (or use existing)"
    echo "   3. Get your Project URL and anon key from Settings → API"
    echo "   4. Update .env.local with these values"
    echo ""
    echo "   Then run: npm run dev"
    echo ""
else
    echo "✅ .env.local file exists"
    echo ""
fi

# Display next steps
echo "=================================="
echo "Installation Complete! ✨"
echo "=================================="
echo ""
echo "Next Steps:"
echo ""
echo "1. Configure Supabase (if not done yet):"
echo "   → Read SUPABASE_SETUP.md for detailed instructions"
echo "   → Or follow QUICKSTART.md for a quick 10-minute setup"
echo ""
echo "2. Update .env.local with your Supabase credentials:"
echo "   → VITE_SUPABASE_URL=https://your-project.supabase.co"
echo "   → VITE_SUPABASE_ANON_KEY=your-anon-key"
echo ""
echo "3. Start the development server:"
echo "   → npm run dev"
echo ""
echo "4. Open http://localhost:5173 in your browser"
echo ""
echo "5. Create your first account and promote to admin:"
echo "   → Sign up through the UI"
echo "   → Update role to 'admin' in Supabase Table Editor"
echo ""
echo "=================================="
echo "Documentation:"
echo "=================================="
echo ""
echo "• QUICKSTART.md     - Get started in 10 minutes"
echo "• SUPABASE_SETUP.md - Detailed Supabase configuration"
echo "• README.md         - Complete documentation"
echo "• DEPLOYMENT.md     - Deploy to production"
echo ""
echo "Need help? Check the documentation or open an issue!"
echo ""
