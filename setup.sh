#!/bin/bash

# Smart Reverse Logistics Portal - Setup Guide
# Run this script to set up the entire application

set -e  # Exit on error

echo "🚀 Setting up Smart Reverse Logistics Portal..."
echo ""

# Backend Setup
echo "📦 Setting up Rails Backend..."
cd returns-api

echo "  Installing gems..."
bundle install > /dev/null

echo "  Creating database..."
rails db:create > /dev/null

echo "  Running migrations..."
rails db:migrate > /dev/null

echo "✅ Backend ready!"
echo ""

# Frontend Setup
echo "📦 Setting up React Frontend..."
cd ../returns-frontend

echo "  Installing dependencies..."
npm install > /dev/null

echo "✅ Frontend ready!"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "🎉 Setup Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📖 To run the application:"
echo ""
echo "Terminal 1 - Backend (Rails):"
echo "  cd returns-api"
echo "  rails s"
echo ""
echo "Terminal 2 - Frontend (React):"
echo "  cd returns-frontend"
echo "  npm start"
echo ""
echo "📍 Access the app at:"
echo "  Backend:  http://localhost:3000"
echo "  Frontend: http://localhost:3001 or automatic port"
echo ""
echo "📚 Documentation:"
echo "  - ITERATION_1.md - Complete architecture & design"
echo "  - ITERATION_1_SUMMARY.md - Quick reference"
echo ""
echo "═══════════════════════════════════════════════════════════"
