# Mobile Search - Network Troubleshooting Guide

## Quick Diagnostics

### 1. Check Console First
Open mobile browser console and look for:

```javascript
// Good - Search working
[SEARCH] Starting search...
[SEARCH] Auth status: anonymous undefined
[SEARCH] Artists query result: { count: 3, error: null }
[SEARCH] Search complete, loading: false

// Bad - Timeout
[SEARCH] Query timeout after 15 seconds
[SEARCH] Query aborted/timeout

// Bad - RLS Error
[SEARCH] Artists query result: { error: "Row level security violation" }
```

### 2. Check Network Panel

#### Healthy Request
```
Method: POST
URL: /rest/v1/artists?select=*,profiles(profile_picture)
Status: 200 OK
Time: 800ms - 2000ms
Size: 5-50KB
Response: {"data": [...]}
```

#### Unhealthy Request (Timeout)
```
Status: (pending) or (failed)
Time: 15000ms+
```

#### Unhealthy Request (RLS)
```
Status: 200 OK
Response: {"message": "Row level security policy violation"}
```

---

## Common Issues & Fixes

### Issue 1: Query Timeout After 15 Seconds

**Symptoms:**
- Console: `[SEARCH] Query timeout after 15 seconds`
- Network: Request pending for 15s then cancelled
- UI: Error message "Search is taking too long..."

**Possible Causes:**
1. Network too slow (< 1 Mbps)
2. Supabase cold start (first query of the day)
3. Database under heavy load
4. Mobile device throttling

**Fixes:**
1. **Check network speed:**
   ```javascript
   // Run in console
   console.log(navigator.connection?.effectiveType)
   // Should show: '4g' or '3g', not 'slow-2g'
   ```

2. **Try on WiFi:** Switch from cellular to WiFi

3. **Check Supabase status:** Visit status.supabase.com

4. **Wait and retry:** First query after idle may be slow (cold start)

5. **Check if DNS issue:**
   ```bash
   # On desktop, ping Supabase
   ping [your-project].supabase.co
   ```

---

### Issue 2: RLS Policy Violation

**Symptoms:**
- Console: `Artists query result: { error: "Row level security violation" }`
- Network: 200 OK but error in response body
- UI: Shows demo data (fallback)

**Fix:**
Verify RLS policy exists:

```sql
-- Run in Supabase SQL editor
SELECT policyname
FROM pg_policies
WHERE tablename = 'profiles'
  AND policyname = 'Anyone can view profile pictures for artists';
```

**Expected:** One row returned

**If empty:** Policy missing, run `RLS_POLICY_FIX.sql`

---

### Issue 3: CORS Error

**Symptoms:**
- Console: `CORS policy: No 'Access-Control-Allow-Origin' header`
- Network: Request blocked before sending
- UI: Infinite spinner or error

**This should NOT happen** because Supabase handles CORS automatically.

**If it does:**
1. Check `VITE_SUPABASE_URL` in `.env` is correct
2. Verify URL doesn't have `localhost` or `127.0.0.1`
3. Check if using custom domain with wrong config

---

### Issue 4: Stale Cache / Service Worker

**Symptoms:**
- Code changes don't appear
- Old "Searching..." behavior persists
- Console shows old code

**Fixes:**
1. **Clear browser cache:**
   - Safari: Settings → Clear History and Website Data
   - Chrome: Settings → Privacy → Clear browsing data

2. **Hard reload:**
   - Pull down page to refresh (mobile)
   - Cmd+Shift+R (desktop)

3. **Check for service worker:**
   ```javascript
   // Run in console
   navigator.serviceWorker.getRegistrations().then(registrations => {
     console.log('Service workers:', registrations.length)
     registrations.forEach(r => r.unregister())
   })
   ```

4. **Use debug panel:** Visit `/debug/auth` → "Clear Browser Cache"

---

### Issue 5: Session Lost on Mobile

**Symptoms:**
- Console: `[SEARCH] Auth status: anonymous` (but you're logged in)
- Profile picture missing
- Bookmarks don't show

**Causes:**
- Cookie blocked by browser
- Private browsing mode
- Cross-site tracking prevention

**Fixes:**
1. **Check session:**
   ```javascript
   // Run in console
   supabase.auth.getSession().then(({data}) =>
     console.log('Has session:', !!data.session)
   )
   ```

2. **Check cookies enabled:**
   - Safari: Settings → Safari → Block All Cookies (should be OFF)
   - Chrome: Settings → Site settings → Cookies (should be allowed)

3. **Disable tracking prevention:**
   - Safari: Settings → Safari → Prevent Cross-Site Tracking (try OFF)

4. **Re-login:** Log out completely, then log back in

5. **Use debug panel:** Visit `/debug/auth` to see session details

---

### Issue 6: No Results Showing (Empty Data)

**Symptoms:**
- Console: `[SEARCH] Artists query result: { count: 0 }`
- UI: "No artists found"
- No error message

**Causes:**
- Database actually empty
- Filters too restrictive
- Network request succeeded but returned no data

**Fixes:**
1. **Check database has data:**
   ```sql
   SELECT COUNT(*) FROM artists;
   ```

2. **Check filters:**
   - Remove all filters
   - Try different service/location

3. **Verify demo data fallback:**
   - Should show demo data if DB empty
   - Check `mockArtists` in code

4. **Check query conditions:**
   ```javascript
   // Run in console
   supabase.from('artists').select('*').then(({data, error}) =>
     console.log('DB Artists:', data?.length, error)
   )
   ```

---

## Advanced Diagnostics

### Test Direct Database Connection

```javascript
// Run in mobile console
const testDB = async () => {
  console.log('Testing database connection...')

  const start = Date.now()

  const { data, error } = await supabase
    .from('artists')
    .select('*')
    .limit(1)

  const duration = Date.now() - start

  console.log({
    duration: `${duration}ms`,
    success: !error,
    hasData: !!data,
    count: data?.length,
    error: error?.message
  })
}

testDB()
```

**Expected:**
```javascript
{
  duration: "500-2000ms",
  success: true,
  hasData: true,
  count: 1,
  error: undefined
}
```

### Test Profiles JOIN

```javascript
// Test the specific query that was failing
const testJoin = async () => {
  const { data, error } = await supabase
    .from('artists')
    .select('*, profiles(profile_picture)')
    .limit(1)

  console.log('Join test:', {
    success: !error,
    data: data,
    error: error?.message
  })
}

testJoin()
```

### Test Auth Status

```javascript
// Check if session exists
supabase.auth.getSession().then(({ data: { session }, error }) => {
  console.log({
    hasSession: !!session,
    userId: session?.user?.id,
    email: session?.user?.email,
    expiresAt: session?.expires_at,
    error: error?.message
  })
})
```

### Monitor Network Timing

```javascript
// Track how long queries take
const { data, error } = await supabase
  .from('artists')
  .select('*')

console.log('Query completed')
```

Then check Network panel for timing:
- Queueing: < 50ms
- DNS: < 100ms
- Connection: < 200ms
- Request sent: < 50ms
- Waiting (TTFB): < 1000ms
- Content download: < 500ms

**Total should be < 2000ms**

---

## Environment Checks

### Verify Configuration

```javascript
// Run in console
console.log({
  supabaseUrl: import.meta.env.VITE_SUPABASE_URL,
  hasAnonKey: !!import.meta.env.VITE_SUPABASE_ANON_KEY,
  origin: window.location.origin,
  userAgent: navigator.userAgent,
  online: navigator.onLine,
  connection: navigator.connection?.effectiveType
})
```

**Expected:**
```javascript
{
  supabaseUrl: "https://xxx.supabase.co",
  hasAnonKey: true,
  origin: "https://your-app.com",
  userAgent: "Mozilla/5.0...",
  online: true,
  connection: "4g"
}
```

**Red flags:**
- ❌ `supabaseUrl: undefined` → Missing env var
- ❌ `supabaseUrl: "http://localhost"` → Wrong config
- ❌ `online: false` → No internet
- ❌ `connection: "slow-2g"` → Too slow

---

## Network Panel Reference

### What to Look For

1. **Request Headers:**
   ```
   apikey: [your-anon-key]
   Authorization: Bearer [token] (if authenticated)
   Content-Type: application/json
   Prefer: return=representation
   ```

2. **Response Headers:**
   ```
   Access-Control-Allow-Origin: *
   Content-Type: application/json
   X-Ratelimit-Remaining: [number]
   ```

3. **Timing Breakdown:**
   - DNS lookup: < 100ms
   - TCP connection: < 200ms
   - TLS handshake: < 300ms
   - Server processing: < 1000ms
   - Content download: < 500ms

### Red Flags

- ❌ Status: `(pending)` for > 5s
- ❌ Status: `(failed)`
- ❌ Status: `403 Forbidden`
- ❌ Status: `429 Too Many Requests`
- ❌ Timing: > 10s total
- ❌ Size: 0 bytes
- ❌ Missing `apikey` header

---

## Escalation Path

If issue persists after all checks:

1. **Collect diagnostics:**
   - Full console logs (copy all `[SEARCH]` and `[DEBUG]` lines)
   - Network panel screenshot
   - `/debug/auth` page screenshot
   - Device/browser info

2. **Check Supabase logs:**
   - Go to Supabase dashboard
   - Database → Logs
   - Look for errors around search time

3. **Test from different device:**
   - Try another mobile device
   - Try desktop browser
   - Try different network (WiFi vs cellular)

4. **Contact support with:**
   - All diagnostics above
   - Steps to reproduce
   - Expected vs actual behavior
   - Frequency (always/sometimes/random)

---

## Quick Reference Commands

```javascript
// Check session
supabase.auth.getSession()

// Test artists query
supabase.from('artists').select('*').limit(5)

// Test profiles query
supabase.from('profiles').select('profile_picture').limit(5)

// Test join query
supabase.from('artists').select('*, profiles(profile_picture)').limit(5)

// Check service workers
navigator.serviceWorker.getRegistrations()

// Clear cache via code
caches.keys().then(names => names.forEach(name => caches.delete(name)))

// Check network
console.log(navigator.onLine, navigator.connection)
```

---

## Success Indicators

You'll know it's working when:

✅ Console shows: `[SEARCH] Search complete, loading: false`
✅ Network request completes in < 5 seconds
✅ Status: `200 OK`
✅ Response has data array with artists
✅ UI shows results (not infinite spinner)
✅ No RLS errors in console
✅ Profile pictures display on cards
