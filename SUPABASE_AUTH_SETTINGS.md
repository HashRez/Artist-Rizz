# Supabase Auth Settings for Testing

## Current Status

✅ **Fixed Issues:**
- All existing users have been manually confirmed in the database
- All users now have profiles created
- Signup form now uses correct role ('customer' instead of 'user')
- Email confirmation checks commented out in code

## Required Supabase Dashboard Configuration

To fully disable email confirmation for testing, you need to update your Supabase project settings:

### Steps to Disable Email Confirmation:

1. **Go to Supabase Dashboard**
   - Navigate to: https://supabase.com/dashboard/project/potlfngsyiqkioacddxk

2. **Navigate to Authentication Settings**
   - Click on "Authentication" in the left sidebar
   - Click on "Providers"
   - Find "Email" provider

3. **Disable Email Confirmation**
   - Look for "Confirm email" toggle
   - **Turn it OFF** for testing
   - Save changes

4. **Alternative: Auto-confirm emails**
   - If there's an option for "Auto Confirm" or "Skip email verification"
   - Enable it for testing purposes

## Database Fixes Applied

The following SQL commands have already been executed to fix existing users:

```sql
-- Confirmed all unconfirmed users
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- Created profiles for all users without them
INSERT INTO profiles (id, email, name, role)
SELECT
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'name', u.raw_user_meta_data->>'full_name', split_part(u.email, '@', 1)) as name,
  CASE
    WHEN u.raw_user_meta_data->>'role' = 'artist' THEN 'artist'
    ELSE 'customer'
  END as role
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;
```

## Code Changes Made

1. **Signup.tsx**
   - Changed default role from 'user' to 'customer'
   - Commented out email confirmation requirement check

2. **useAuth.tsx**
   - Commented out email confirmation requirement check in signup
   - Profile creation happens immediately after signup

3. **Login.tsx**
   - Commented out email confirmation error handling

## Testing Now

You should now be able to:
- ✅ Sign up with any email address (real or fake)
- ✅ Get immediately logged in after signup
- ✅ Login with existing accounts without email verification errors
- ✅ Create artist or customer accounts

## For Production

When ready to re-enable email confirmation:

1. **In Supabase Dashboard:**
   - Turn ON "Confirm email" toggle
   - Configure email templates if needed

2. **In Code:**
   - Search for `COMMENTED OUT FOR TESTING`
   - Uncomment all those blocks
   - Test the full email confirmation flow

## Current Test Accounts

These accounts are now working:
- hasnainkhan9250@gmail.com (Google OAuth)
- hrkhan9250@gmail.com
- hrkhan@gmail.com
- sadainreza@gmail.com
- aa@gmail.com
- k@gmail.com

All accounts are confirmed and have profiles.
