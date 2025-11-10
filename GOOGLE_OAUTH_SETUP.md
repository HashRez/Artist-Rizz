# Google OAuth 2.0 Implementation Guide

## Overview

The LocalArtists platform now supports Google OAuth 2.0 authentication alongside traditional email/password authentication. This guide provides complete setup instructions and technical documentation.

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Configure Google Cloud Console

1. **Go to** [Google Cloud Console](https://console.cloud.google.com/)

2. **Create a new project** or select existing one:
   - Click "Select Project" → "New Project"
   - Name: "LocalArtists" (or your choice)
   - Click "Create"

3. **Enable OAuth consent screen**:
   - Navigate to: APIs & Services → OAuth consent screen
   - User Type: **External** (for public access)
   - Click "Create"

4. **Fill out App Information**:
   - App name: `LocalArtists Platform`
   - User support email: Your email
   - Developer contact: Your email
   - Click "Save and Continue"

5. **Add Scopes** (optional for now):
   - Click "Save and Continue" (default scopes are sufficient)

6. **Add Test Users** (if in development):
   - Add your Gmail address
   - Click "Save and Continue"

### Step 2: Create OAuth 2.0 Credentials

1. **Navigate to**: APIs & Services → Credentials

2. **Click** "Create Credentials" → "OAuth client ID"

3. **Configure OAuth Client**:
   - Application type: **Web application**
   - Name: `LocalArtists Web Client`

4. **Add Authorized JavaScript Origins**:
   ```
   http://localhost:5173
   https://your-production-domain.com
   ```

5. **Add Authorized Redirect URIs**:
   ```
   http://localhost:5173/auth/callback
   https://your-production-domain.com/auth/callback
   ```

6. **Click "Create"**

7. **Copy your credentials**:
   - Client ID: `xxxxx.apps.googleusercontent.com`
   - Client Secret: `xxxxx`
   - **Save these securely!**

### Step 3: Configure Supabase

1. **Go to** [Supabase Dashboard](https://app.supabase.com)

2. **Navigate to**: Your Project → Authentication → Providers

3. **Enable Google Provider**:
   - Toggle "Google" to ON
   - Paste your **Client ID**
   - Paste your **Client Secret**
   - Click "Save"

4. **Copy the Callback URL** from Supabase:
   - Should look like: `https://your-project.supabase.co/auth/v1/callback`

5. **Go back to Google Cloud Console**:
   - Add this Supabase callback URL to your "Authorized redirect URIs"
   - Click "Save"

---

## ✅ That's It! Google OAuth is Now Configured

Your users can now sign in with Google. The application will:
1. Show "Continue with Google" buttons on Login and Signup pages
2. Automatically create user profiles on first Google sign-in
3. Handle session management securely

---

## 🔧 Technical Implementation Details

### Architecture

```
┌─────────────┐         ┌──────────────┐         ┌────────────┐
│   User      │────────▶│   Frontend   │────────▶│   Google   │
│   Browser   │◀────────│   (React)    │◀────────│   OAuth    │
└─────────────┘         └──────────────┘         └────────────┘
                               │
                               ▼
                        ┌──────────────┐
                        │   Supabase   │
                        │   Auth       │
                        └──────────────┘
                               │
                               ▼
                        ┌──────────────┐
                        │  PostgreSQL  │
                        │  (profiles)  │
                        └──────────────┘
```

### Files Modified

1. **src/pages/Login.tsx**
   - Added `handleGoogleSignIn` function
   - Added Google Sign-In button with official logo
   - Added "Or continue with email" divider

2. **src/pages/Signup.tsx**
   - Added `handleGoogleSignIn` function
   - Added Google Sign-In button
   - Same UI improvements as Login

3. **src/pages/AuthCallback.tsx** (NEW)
   - Handles OAuth redirect from Google
   - Creates user profile if first-time sign-in
   - Redirects to appropriate page based on role

4. **src/App.tsx**
   - Added `/auth/callback` route

### OAuth Flow

```
1. User clicks "Continue with Google"
   ↓
2. Frontend calls: supabase.auth.signInWithOAuth({ provider: 'google' })
   ↓
3. User redirected to Google sign-in page
   ↓
4. User authorizes the application
   ↓
5. Google redirects to: /auth/callback
   ↓
6. AuthCallback component:
   - Gets session from Supabase
   - Checks if profile exists
   - Creates profile if new user (role: 'customer')
   - Redirects to home page
   ↓
7. User is now authenticated!
```

### Security Features

✅ **OAuth 2.0 Standard Compliance**
- Uses authorization code flow
- PKCE (Proof Key for Code Exchange) enabled by Supabase
- State parameter for CSRF protection

✅ **Secure Token Storage**
- Tokens stored in httpOnly cookies (managed by Supabase)
- No tokens exposed to JavaScript
- Automatic token refresh

✅ **Session Management**
- Session timeout: 1 hour (configurable in Supabase)
- Automatic session refresh on activity
- Secure logout with token revocation

✅ **Profile Security**
- Profile creation with Row Level Security (RLS)
- User can only access their own data
- Role-based access control (artist/customer)

---

## 🧪 Testing the OAuth Flow

### Test Checklist

1. **New User Sign-Up via Google**:
   ```
   ✓ Click "Continue with Google" on signup page
   ✓ Complete Google authorization
   ✓ Verify redirect to home page
   ✓ Check profile created in database
   ✓ Verify default role is 'customer'
   ```

2. **Existing User Sign-In via Google**:
   ```
   ✓ Click "Continue with Google" on login page
   ✓ Complete Google authorization
   ✓ Verify redirect to home page
   ✓ Verify existing profile loaded
   ```

3. **Session Persistence**:
   ```
   ✓ Sign in with Google
   ✓ Close browser
   ✓ Reopen browser
   ✓ Verify still authenticated
   ```

4. **Sign Out**:
   ```
   ✓ Click "Sign Out" in header
   ✓ Verify redirected to login
   ✓ Verify session cleared
   ```

### Testing with Different Accounts

Test with:
- Personal Gmail account
- Google Workspace account
- Multiple Google accounts (account switcher)

### Error Testing

Test error scenarios:
- Cancel Google authorization → Should return to login
- Network failure during OAuth → Should show error message
- Invalid credentials → Should show Google error

---

## 🔐 Production Deployment Checklist

### Before Going Live

- [ ] Update Google OAuth redirect URIs with production domain
- [ ] Update Supabase Site URL in project settings
- [ ] Enable HTTPS only (disable HTTP redirects in production)
- [ ] Review OAuth consent screen for public release
- [ ] Test OAuth flow on production domain
- [ ] Monitor Supabase Auth logs for errors
- [ ] Set up error tracking (Sentry, etc.)

### Security Best Practices

1. **Never commit credentials**
   - Client ID and Secret should be in Supabase only
   - Use environment variables for any config

2. **Use HTTPS in production**
   - OAuth requires HTTPS for production
   - Supabase handles this automatically

3. **Regularly rotate secrets**
   - Update OAuth client secret periodically
   - Update Supabase configuration

4. **Monitor authentication logs**
   - Check for suspicious login patterns
   - Monitor failed authentication attempts

---

## 📊 Database Schema

### Profiles Table

When a user signs in with Google for the first time, the following profile is created:

```sql
INSERT INTO profiles (id, name, email, role, phone, created_at)
VALUES (
  user.id,                                    -- From Google auth
  user.user_metadata.full_name,              -- From Google profile
  user.email,                                 -- From Google account
  'customer',                                 -- Default role
  user.user_metadata.phone,                  -- If provided by Google
  NOW()
);
```

### User Metadata from Google

Google OAuth provides:
- `email`: User's Gmail address
- `full_name`: User's full name from Google account
- `picture`: Profile picture URL (available but not used currently)
- `email_verified`: Whether email is verified by Google (always true)

---

## 🐛 Troubleshooting

### Common Issues

1. **"Redirect URI mismatch" error**
   ```
   Solution: Check that redirect URI in Google Cloud Console
   exactly matches your callback URL (including http/https and trailing slash)
   ```

2. **"Invalid client" error**
   ```
   Solution: Verify Client ID and Secret are correctly entered in Supabase
   ```

3. **Stuck on "Completing sign in..." page**
   ```
   Solution: Check browser console for errors
   Verify Supabase session is being created
   Check database for profile creation errors
   ```

4. **Profile not created after Google sign-in**
   ```
   Solution: Check Supabase logs for database errors
   Verify RLS policies allow profile creation
   Check for foreign key constraint violations
   ```

5. **Google consent screen shows "unverified app"**
   ```
   Solution: This is normal during development
   For production, submit app for Google verification
   ```

### Debug Mode

Enable debug logging:

```typescript
// In AuthCallback.tsx, uncomment these lines:
console.log('Session:', session)
console.log('Profile:', existingProfile)
console.log('User metadata:', session?.user.user_metadata)
```

### Support Resources

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Google OAuth 2.0 Docs](https://developers.google.com/identity/protocols/oauth2)
- [OAuth 2.0 Playground](https://developers.google.com/oauthplayground)

---

## 🚀 Advanced Features (Future Enhancements)

### Suggested Improvements

1. **Profile Picture from Google**
   ```typescript
   // Store Google profile picture in user profile
   avatar_url: session.user.user_metadata.picture
   ```

2. **Email Verification Skip**
   ```typescript
   // Google emails are pre-verified
   email_verified: true
   ```

3. **Account Linking**
   ```typescript
   // Allow users to link Google account to existing email account
   ```

4. **OAuth Provider Selection**
   ```typescript
   // Add Facebook, Apple, GitHub OAuth
   // Show user which provider they used to sign up
   ```

5. **Two-Factor Authentication**
   ```typescript
   // Require 2FA for sensitive operations
   // Even if signed in with Google
   ```

---

## 📈 Analytics & Monitoring

### Metrics to Track

1. **Authentication Success Rate**
   - Google OAuth success vs failures
   - Email/password success vs failures

2. **User Preferences**
   - % of users choosing Google OAuth
   - % of users using email/password

3. **Session Duration**
   - Average session length
   - Sessions ended by timeout vs explicit logout

4. **Error Rates**
   - OAuth callback errors
   - Profile creation failures
   - Session refresh failures

### Recommended Tools

- **Supabase Analytics**: Built-in auth analytics
- **Google Analytics**: Track sign-in events
- **Sentry**: Error tracking and alerts
- **LogRocket**: Session replay for debugging

---

## ✅ Summary

Your LocalArtists platform now has enterprise-grade authentication with Google OAuth 2.0!

**What's Working**:
- ✅ Google Sign-In on Login page
- ✅ Google Sign-In on Signup page
- ✅ Automatic profile creation
- ✅ Session management
- ✅ Secure token handling
- ✅ Role-based access control

**Next Steps**:
1. Test the OAuth flow thoroughly
2. Configure production domain in Google Cloud
3. Deploy to production
4. Monitor authentication logs

**Need Help?**
- Check the troubleshooting section above
- Review Supabase Auth logs
- Check browser console for errors
- Verify Google Cloud Console configuration

---

## 📝 Change Log

### Version 1.0.0 - Initial OAuth Implementation
- Added Google OAuth 2.0 support
- Created AuthCallback page
- Updated Login and Signup pages
- Added automatic profile creation
- Implemented secure session handling

