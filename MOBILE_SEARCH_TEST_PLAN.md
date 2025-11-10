# Mobile Search Fix - Test Plan

## Pre-Test Setup

### 1. Enable Mobile Console Logging
**iOS Safari:**
1. Settings → Safari → Advanced → Web Inspector (ON)
2. Connect device to Mac
3. Safari → Develop → [Your Device] → [Your Page]

**Android Chrome:**
1. Settings → About Chrome → Tap "Version" 7 times (enable Developer mode)
2. Settings → Developer options → USB debugging (ON)
3. Connect device to computer
4. Chrome desktop → More tools → Remote devices
5. Inspect your page

**Alternative (All Devices):**
- Use Eruda console: Add to your app temporarily
```html
<script src="https://cdn.jsdelivr.net/npm/eruda"></script>
<script>eruda.init();</script>
```

### 2. Clear Cache Before Testing
- Safari: Settings → Safari → Clear History and Website Data
- Chrome: Settings → Privacy → Clear browsing data

## Test Cases

### Test 1: Anonymous User Search (Most Important)
**Goal:** Verify search works without login

**Steps:**
1. Open app in mobile browser (don't log in)
2. Navigate to `/search` page
3. Open console/dev tools
4. Click "Apply Filters" or change filter

**Expected Result:**
- ✅ Console shows: `[SEARCH] Auth status: anonymous`
- ✅ Search completes in < 5 seconds
- ✅ Results display (real data or demo data)
- ✅ No infinite spinner
- ✅ Profile pictures visible on artist cards

**If It Fails:**
- Check console for `[SEARCH] Query timeout`
- Check network panel for hanging requests
- Navigate to `/debug/auth` and click "Test Database Query"

---

### Test 2: Authenticated User Search
**Goal:** Verify search works when logged in

**Steps:**
1. Log in to your account
2. Navigate to `/search` page
3. Open console
4. Apply filters

**Expected Result:**
- ✅ Console shows: `[SEARCH] Auth status: authenticated [user-id]`
- ✅ Search completes quickly (< 2 seconds)
- ✅ Real database results show
- ✅ Profile pictures display

---

### Test 3: Timeout Handling (Slow Network)
**Goal:** Verify graceful timeout behavior

**Steps:**
1. Enable network throttling (Slow 3G)
2. Navigate to `/search`
3. Wait for search to complete

**Expected Result:**
- ✅ After 15 seconds, console shows: `[SEARCH] Query timeout`
- ✅ Error message displays: "Search is taking too long..."
- ✅ Demo data loads as fallback
- ✅ Spinner stops

---

### Test 4: Debug Panel
**Goal:** Verify debug utility works

**Steps:**
1. Navigate to `/debug/auth`
2. Check "Session Status" section
3. Click "Test Database Query"
4. Check console

**Expected Result:**
- ✅ Session info displays correctly
- ✅ Test query completes in < 2 seconds
- ✅ Alert shows: "Query completed in XXXms"
- ✅ Console shows: `[DEBUG] Query result: { duration: "XXXms", count: X }`

---

### Test 5: Profile Pictures Display
**Goal:** Verify RLS fix allows profile picture reads

**Steps:**
1. Search for artists
2. Check artist cards

**Expected Result:**
- ✅ Profile pictures show for artists who uploaded them
- ✅ Default icon shows for artists without pictures
- ✅ No broken image icons
- ✅ No RLS errors in console

---

### Test 6: Error Recovery
**Goal:** Verify app recovers from errors

**Steps:**
1. Turn on airplane mode
2. Navigate to `/search`
3. Wait 15 seconds
4. Turn off airplane mode
5. Click "Apply Filters"

**Expected Result:**
- ✅ First search fails gracefully with demo data
- ✅ Second search succeeds with real data
- ✅ No app crash
- ✅ User can continue using app

---

## Console Commands for Manual Testing

Open mobile console and run:

### Check Session
```javascript
supabase.auth.getSession().then(({data}) => console.log('Session:', data.session))
```

### Test Artists Query
```javascript
supabase.from('artists').select('*').then(({data, error}) => console.log('Artists:', data?.length, error))
```

### Test Profiles Query
```javascript
supabase.from('profiles').select('profile_picture').then(({data, error}) => console.log('Profiles:', data?.length, error))
```

### Test Artists + Profiles Join
```javascript
supabase.from('artists').select('*, profiles(profile_picture)').then(({data, error}) => console.log('Join:', data?.length, error))
```

## Success Criteria

### Minimum Requirements (Must Pass)
- [ ] Search completes on mobile (authenticated or anonymous)
- [ ] Spinner stops within 15 seconds
- [ ] Console shows `[SEARCH]` logs
- [ ] No RLS policy violation errors
- [ ] Artist results display

### Ideal Requirements (Should Pass)
- [ ] Search completes in < 5 seconds
- [ ] Profile pictures display correctly
- [ ] Debug panel works
- [ ] Error messages are user-friendly
- [ ] Demo data fallback works

## Regression Checks

Ensure existing functionality still works:

- [ ] Desktop search still works
- [ ] Login/signup flows work
- [ ] Artist profile pages load
- [ ] Bookings can be created
- [ ] Portfolio uploads work

## Known Issues & Workarounds

### Issue: Service Worker Caching
**Symptom:** Old code still running after deploy
**Workaround:**
- Clear browser cache
- Hard reload (pull down to refresh)
- Unregister service worker in DevTools

### Issue: Session Lost on Mobile
**Symptom:** Shows anonymous when should be authenticated
**Workaround:**
- Check `/debug/auth` session status
- Log out and log back in
- Clear cookies

### Issue: Slow Initial Load
**Symptom:** First search takes 10+ seconds
**Explanation:** Cold start of Supabase connection
**Expected:** Subsequent searches should be faster

## Reporting Issues

If search still fails, collect:

1. **Console logs** - All `[SEARCH]` and `[DEBUG]` lines
2. **Network panel** - Screenshot of pending/failed requests
3. **Debug panel** - Screenshot of `/debug/auth` page
4. **Device info** - Browser, OS version
5. **User state** - Logged in or anonymous

Example report:
```
Device: iPhone 12, iOS 17.1, Safari
User: Anonymous
Console: [SEARCH] Query timeout after 15 seconds
Network: POST /rest/v1/artists - pending (15000ms)
Debug: Session shows "No session"
```

## Next Steps After Testing

### If All Tests Pass ✅
- Deploy to production
- Monitor error logs for 24 hours
- Check analytics for search success rate

### If Tests Fail ❌
1. Check which test failed
2. Review console logs
3. Verify RLS migration applied
4. Check network connectivity
5. Try `/debug/auth` panel

### Performance Monitoring
Track these metrics:
- Average search time (target: < 2s)
- Timeout rate (target: < 1%)
- Fallback usage rate (target: < 5%)
- RLS error rate (target: 0%)
