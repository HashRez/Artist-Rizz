# Changelog

All notable changes to the LocalArtists platform are documented here in simple language.

## [2025-11-05] - Mobile Application Created

### Added
- **React Native Mobile App** - Complete mobile application for iOS and Android
  - Built with React Native and Expo for cross-platform deployment
  - Uses same Supabase database as web app
  - Full TypeScript implementation
  - Location: `/mobile/` directory

- **Core Mobile Features Implemented**
  - Authentication with Google OAuth
  - Bottom tab navigation (Home, Search, Favorites, Bookings, Profile)
  - Home screen with featured artists and categories
  - Search functionality with live results
  - Favorites management
  - Bookings list with status tracking
  - User profile screen

- **Mobile Documentation**
  - Complete README with setup instructions
  - Quick Start Guide (5-minute setup)
  - Mobile App Specification document
  - Changelog tracking all features
  - Delivery summary with next steps

- **Mobile Infrastructure**
  - Supabase client configured for mobile
  - Secure token storage with expo-secure-store
  - Type-safe database queries
  - Material Design theme system
  - Navigation structure with deep linking
  - Environment variables configured

### Technical Details
- Framework: React Native 0.74.5 with Expo SDK 51
- Language: TypeScript
- UI Library: React Native Paper
- Navigation: React Navigation 6
- Backend: Supabase (shared with web app)
- Ready for: iOS App Store and Google Play Store

---

## [2025-11-04] - Authentication System Overhaul

### Fixed
- **Redirect Loop Issue** - Fixed annoying automatic redirects to login page while browsing
  - Added proper loading state checks before redirecting users
  - Users can now browse artist profiles without unexpected login redirects
  - Changed in: `src/pages/ArtistProfile.tsx`

- **Email Confirmation System** - Built complete email verification flow
  - Added detection for when email confirmation is required
  - Created beautiful confirmation screen that shows after signup
  - Added "Resend confirmation email" button for users who didn't receive it
  - Changed in: `src/hooks/useAuth.tsx`, `src/pages/Signup.tsx`, `src/pages/Login.tsx`

- **Google OAuth Login** - Improved Google Sign-In reliability
  - Fixed callback handling to establish sessions properly
  - Added better error messages when OAuth fails
  - Added status updates during the sign-in process
  - Changed in: `src/pages/AuthCallback.tsx`

- **Login Error Messages** - Made error messages more helpful
  - Clear explanation when email needs to be confirmed
  - Added button to resend confirmation email from login page
  - Better error handling for common login issues
  - Changed in: `src/pages/Login.tsx`

### Added
- **Email Confirmation UI** - New screens for email verification
  - Confirmation pending screen after signup
  - Success message after confirming email
  - Resend button with countdown timer
  - Added in: `src/pages/Signup.tsx`

- **Resend Confirmation Function** - New utility for resending verification emails
  - Users can request new confirmation email
  - Prevents spam with rate limiting feedback
  - Added in: `src/hooks/useAuth.tsx`

### Technical Details
- All authentication flows now check loading state before redirecting
- Session establishment includes proper timing for OAuth callbacks
- Email confirmation status is tracked throughout signup process
- Build size: 414KB (114KB gzipped)

---

## [2025-11-04] - Google OAuth 2.0 Implementation

### Added
- **Google Sign-In Button** - One-click login with Google
  - Added Google OAuth button to login page
  - Added Google OAuth button to signup page
  - Uses secure PKCE flow for authentication
  - Added in: `src/pages/Login.tsx`, `src/pages/Signup.tsx`

- **OAuth Callback Handler** - Processes Google sign-in redirects
  - Created new page to handle OAuth returns
  - Establishes user session after Google authentication
  - Redirects to home page after successful login
  - Added in: `src/pages/AuthCallback.tsx`

- **OAuth Route** - New route for authentication callback
  - Added `/auth/callback` route to handle OAuth redirects
  - Updated in: `src/App.tsx`

### Technical Details
- Uses Supabase Google OAuth provider
- Implements PKCE security flow
- Build size: 409KB (113KB gzipped)

---

## [2025-11-04] - Initial Setup

### Added
- **React Application** - Modern web application framework
  - React 18 with TypeScript
  - Vite for fast development
  - Tailwind CSS for styling
  - React Router for navigation

- **Supabase Integration** - Database and authentication
  - PostgreSQL database
  - Row Level Security (RLS) policies
  - Email/password authentication
  - User profiles and artist profiles

- **Core Pages**
  - Home page with featured artists
  - Search page with filters
  - Login and signup pages
  - Artist profile pages
  - Booking system pages
  - Admin dashboard

- **Database Schema**
  - Users table with profiles
  - Artists table with portfolios
  - Bookings table with status tracking
  - Favorites system
  - Reviews and ratings

### Features
- Browse local artists by category
- Search and filter artists
- Book artists for events
- Save favorite artists
- User authentication
- Artist profile management
- Portfolio uploads
- Booking management

---

## How to Read This Changelog

- **Added** - New features or files
- **Fixed** - Bug fixes and problem solutions
- **Changed** - Updates to existing features
- **Removed** - Deleted features or files
- **Technical Details** - Important technical information

Each entry includes:
- What changed in simple language
- Why it matters to users
- Which files were modified
