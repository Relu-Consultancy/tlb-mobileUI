# Plan: Backend-driven served cities + per-city curated sections

**Status:** planned, not implemented. **Date:** 2026-10-05.

## Why
Selecting **Prayagraj** shows "We're not currently serving this location" even though a
Prayagraj listing exists (events API returns *artist fest*). The cause is not the admin's
section curation in user app management. The app decides whether a city is "served"
from `supportedCities`, a list hard-coded in `lib/providers/location_state.dart`, and
Prayagraj isn't on it. Home and the Events / Classes / Programs / Venues tabs check that
list before loading anything, so every new city hits the same wall until the app is
edited and re-released.

Separately, the admin's curated sections (Spotlight, Hot Picks, tab rails, …) are global
today: the app never sends a city with them, and the API returns identical sections for
Mumbai, Agra or no city (verified against the live API).

## Decisions
1. The **backend provides the served-cities list** (admin-controlled); the app uses it.
2. The app **sends the selected city with the curated section requests**, so each city
   gets its own curated Home/tab sections once the backend filters by it.
3. Until the backend endpoint ships, the app falls back to its built-in list **with
   Prayagraj added**, so Prayagraj works immediately.

## Backend work needed (for the backend team)
- **New endpoint** for served cities. Proposed contract (the app keeps the path in one
  constant, so another path is a one-line change):
  `GET /api/v1/cities/served/` →
  `{"success": true, "data": [{"name": "Mumbai", "slug": "mumbai"}, ...]}`
  No such endpoint exists today (`cities/`, `locations/`, `listings/cities/` etc. all 404).
- **Filter curated sections by city:** `GET /api/v1/homepage/sections/` and
  `GET /api/v1/listings/{screen}/sections/` should honour `?city=` — the same parameter
  name the listing endpoints already use (`/listings/events/?city=Mumbai`). Today both
  ignore it.

The app side is safe to ship first: an ignored parameter changes nothing, and a missing
endpoint falls back to the built-in list.

## App changes

### A. Served cities from the backend
1. **New `lib/services/served_cities_service.dart`** — `fetch()` returns the city names,
   or null on 404 / timeout / malformed body. Accepts both the `{success, data}` envelope
   and a bare array (same tolerance as `HomeFeedService._fetch`). 30-second timeout like
   the other services.
2. **`lib/providers/location_state.dart`**
   - Replace the `supportedCities` field with `ValueNotifier<List<String>> servedCities`,
     seeded with the built-in fallback (current list + `'Prayagraj'`).
   - `Future<void> loadServedCities()`: load the cached list from SharedPreferences
     (key `tlb_served_cities`) first, so a later launch uses the last known list instantly
     and offline; then fetch. On success replace the list and update the cache; on
     failure keep what it has.
   - `isLocationSupported(city)` reads `servedCities.value`, case-insensitive and trimmed.
   - Test seam `fetchServedCities`, following the existing `fetchSaved` / `resolveCity`
     seams in the same class.
3. **Call it at launch** in `lib/main.dart`, alongside the existing startup work,
   fire-and-forget so it never delays the splash.
4. **React when the list arrives.** Home and `LocationGate` currently listen only to
   `selectedCity`. Switch both to
   `ListenableBuilder(listenable: Listenable.merge([selectedCity, servedCities]), …)`:
   - `lib/screens/home_screen.dart` — the builder wrapping the body
   - `LocationGate` in `lib/widgets/empty_location_widget.dart`

   `search_screen.dart` calls `isLocationSupported` during build, so it needs no change.

### B. Send the city with curated section requests
1. **`lib/services/home_feed_service.dart`** — add `String? city` to `fetchSections` and
   `fetchScreenSections`. Move the query building into a pure
   `@visibleForTesting static Uri buildUri(url, {lat, lng, city})`: adds `city` when
   non-empty and keeps the existing lat/lng both-or-neither rule.
2. **`lib/providers/home_feed_state.dart`** and **`lib/providers/discovery_feed_state.dart`**
   — `load()` passes `city: LocationState().cityOrNull`.
   Also fix a race both share: `load()` ignores a call made while one is already in
   flight, so a city change during the first fetch would leave the previous city's
   sections on screen. Add a `_reloadQueued` flag that re-runs the load once in `finally`.
3. **`location_state.dart` `setCity`** — refetch the already-loaded feeds when the **city
   name** changes, not only when coordinates change (today's behaviour), through the
   existing `_refreshGeoFeeds()` seam.

## Tests
- `test/services/served_cities_service_test.dart` — parses the envelope and a bare array;
  404 and malformed bodies return null.
- `test/providers/location_state_served_test.dart` — the fallback includes Prayagraj; a
  fetched list replaces it and `isLocationSupported` follows; a failed fetch keeps the
  previous list; matching ignores case and whitespace; the cached list is used on the
  next start.
- `test/widgets/location_gate_test.dart` — the gate switches from the empty state to the
  content when `servedCities` gains the selected city, with no city change.
- `test/services/home_feed_request_test.dart` — `buildUri` adds or omits `city`; the
  lat/lng rule still holds.
- `test/providers/location_state_saved_test.dart` — **TC_P_LOC_010** currently asserts
  "no refetch on a city change"; flip it, and add "choosing the same city again does not
  refetch".
- Feed states: a forced load requested mid-flight runs once more after the first one
  finishes (needs a small `@visibleForTesting` fetch seam on both states).

## Verification
1. `flutter analyze lib test` is clean and `flutter test` passes in full.
2. On the emulator, pick **Prayagraj**: Home and the tabs show content instead of
   "not serving", and the Events category screens show *artist fest*.
3. Pick a city with no listings and not on the list (e.g. Agra): it still shows
   "not serving".
4. Once the backend endpoint exists: add or remove a city in the admin portal and
   relaunch — the app follows it with no app update.

## Out of scope
- When a served city has nothing curated, Home and the tabs still hide the empty
  sections, and the tabs still fall back to placeholder banners. Unchanged by this plan.
