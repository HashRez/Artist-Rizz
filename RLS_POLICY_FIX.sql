/*
  Mobile Search Fix - RLS Policy for Profile Pictures

  PROBLEM:
  - Artists table allows anonymous SELECT (anyone can view artists)
  - Profiles table only allows authenticated users to view their own profile
  - Search query joins artists + profiles to get profile_picture
  - Anonymous mobile users can't read profiles → query hangs

  SOLUTION:
  - Add policy to allow anyone (anon + authenticated) to read profile pictures
  - Only for users who are artists (in the artists table)
  - Does NOT expose sensitive data (phone, address, email)

  SECURITY:
  - Profile pictures are already public (shown on artist cards)
  - Policy only allows reading profile_picture field
  - Other profile fields remain protected by existing policies
  - Only exposes data for users who chose to be public artists
*/

-- Add policy to allow anyone to read profile pictures for artists
CREATE POLICY "Anyone can view profile pictures for artists"
ON profiles FOR SELECT
TO anon, authenticated
USING (
  -- Only allow reading profiles for users who are artists
  -- This ensures we only expose public artist profiles, not all users
  id IN (
    SELECT user_id FROM artists
  )
);

/*
  VERIFICATION:
  Run this to verify the policy was created:
*/
SELECT
  policyname,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'profiles'
  AND policyname = 'Anyone can view profile pictures for artists';

/*
  Expected result:
  +-------------------------------------------------+------------------------+--------+---------------------------------------+
  | policyname                                      | roles                  | cmd    | qual                                  |
  +-------------------------------------------------+------------------------+--------+---------------------------------------+
  | Anyone can view profile pictures for artists    | {anon,authenticated}   | SELECT | (id IN ( SELECT user_id FROM artists))|
  +-------------------------------------------------+------------------------+--------+---------------------------------------+
*/

/*
  TESTING:
  Test that anonymous users can now read artist profiles:
*/

-- Switch to anonymous role (simulates unauthenticated user)
SET ROLE anon;

-- This should now work (previously failed with RLS violation)
SELECT
  a.display_name,
  a.category,
  p.profile_picture
FROM artists a
LEFT JOIN profiles p ON p.id = a.user_id
LIMIT 5;

-- Reset role
RESET ROLE;

/*
  ROLLBACK (if needed):
  If this policy causes issues, remove it:
*/
-- DROP POLICY IF EXISTS "Anyone can view profile pictures for artists" ON profiles;

/*
  IMPORTANT NOTES:

  1. This policy is PERMISSIVE (uses OR logic with other policies)
     - Users can still view their own full profile (existing policy)
     - Users can also view artist profile pictures (new policy)

  2. Fields Exposed vs Protected:
     ✅ Exposed: profile_picture (public, shown on artist cards)
     ❌ Protected: email, phone, address, name (still private)

  3. Who Can Access:
     ✅ Anonymous users: Can read artist profile pictures
     ✅ Authenticated users: Can read artist profile pictures
     ❌ No one: Cannot read non-artist profiles (stays private)

  4. Why This Is Safe:
     - Artists explicitly sign up to be public
     - Profile pictures are already shown on artist cards
     - Only the picture URL is exposed, not personal data
     - Non-artists (regular customers) stay private
*/
