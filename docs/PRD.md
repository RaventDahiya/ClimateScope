AI INSTRUCTION: Read ALL project docs (PRD, Architecture, Design, Rules, Phases) before writing any code.

# ClimateScope — Product Requirements Document

---

## 1. Overview

**Project:** ClimateScope — a weather application built as a take-home assignment for a Mobile Application Developer Internship.

**Context:** Evaluators will assess working features with real API data, clean code structure, error handling quality, UI/UX polish, Git history, and README completeness.

> [!IMPORTANT]
> A smaller app that is **clean and works** beats a bigger unfinished one. Time budget: **~6–8 hours**. Prioritize must-have features, then polish, then bonuses.

---

## 2. Problem & Goals

Users need a quick, reliable way to check **current weather** and a **5-day forecast** for any city. The app must demonstrate professional mobile development skills appropriate for an internship-level evaluation.

### Goals

| # | Goal |
|---|------|
| G1 | Deliver a polished, crash-free, dark-themed weather app |
| G2 | Integrate real API data (Open-Meteo) with proper error handling |
| G3 | Demonstrate clean architecture and code organization (feature-first MVVM) |
| G4 | Maintain a professional Git history with meaningful commits |

---

## 3. Target Users / Personas

| Persona | Description | Priorities |
|---------|-------------|------------|
| **Internship Evaluator** (primary) | Senior engineer reviewing code quality, architecture choices, and UX | Clean structure, error handling, working features, Git hygiene |
| **Casual Weather User** (secondary) | Anyone wanting quick weather lookups for a city | Speed, clarity, reliability, offline access |

---

## 4. User Stories

| ID | As a… | I want to… | So that… | Priority |
|----|-------|------------|----------|----------|
| US-01 | User | Search for a city by name | I can check weather in any location | Must-have |
| US-02 | User | View current weather (temp, condition, humidity, wind) | I know conditions right now | Must-have |
| US-03 | User | View a 5-day daily forecast (day, icon, min/max temp) | I can plan my week | Must-have |
| US-04 | User | View an hourly forecast strip (~24h) | I can plan my day with finer detail | Must-have |
| US-05 | User | See clear error messages when things go wrong | I understand what happened and what to do | Must-have |
| US-06 | User | See cached data when offline with a staleness indicator | I still get useful information without internet | Must-have |
| US-07 | User | Toggle temperature units between °C and °F | I can read temps in my preferred system | Bonus |
| US-08 | User | Pull down to refresh weather data | I can get the latest data on demand | Bonus |
| US-09 | User | See my recent city searches | I can quickly re-check frequent locations | Bonus |
| US-10 | User | Use my current GPS location | I don't have to type my city every time | Bonus |

---

## 5. Functional Requirements

### 5.1 City Search & Input Validation

- Text field for city name entry inside a modal bottom sheet.
- **Validation rules — no API call is made if:**
  - Input is empty.
  - Input is whitespace-only.
  - Input contains only special characters (no letters/digits).
- Invalid input → show inline validation feedback (not a snackbar, not a crash).

### 5.2 Two-Step API Flow (Open-Meteo, No API Key)

**Step 1 — Geocoding:**

```
GET https://geocoding-api.open-meteo.com/v1/search?name={city}&count=5
```

- Response fields used: `name`, `latitude`, `longitude`, `country`, `admin1`.
- **Critical:** When no cities match, the `results` key is **entirely omitted** from the response (it is NOT an empty array). The response body contains only `generationtime_ms`. The parser must handle this.

**Step 2 — Forecast:**

```
GET https://api.open-meteo.com/v1/forecast
    ?latitude={lat}
    &longitude={lon}
    &current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m
    &daily=weather_code,temperature_2m_max,temperature_2m_min
    &hourly=temperature_2m,weather_code
    &forecast_days=5
    &timezone=auto
```

### 5.3 Disambiguation

- When geocoding returns multiple matches → display a list showing **name + admin1 + country** for each result.
- User taps one → bottom sheet closes → forecast loads for that selection.

### 5.4 Current Weather Display

| Element | Source | Format |
|---------|--------|--------|
| City name | Geocoding `name` | Text |
| Country | Geocoding `country` | Text |
| Temperature | `current.temperature_2m` | `{value}°C` (always show unit) |
| Condition | `current.weather_code` → WMO mapper | Text label + icon |
| Humidity | `current.relative_humidity_2m` | `{value}%` |
| Wind speed | `current.wind_speed_10m` | `{value} km/h` |

### 5.5 5-Day Forecast

- Section labeled **"5 days"** (not "7 days").
- Each row: day name / date, condition icon, min temp, max temp.
- Source: `daily` arrays from forecast response.

### 5.6 Hourly Forecast

- Horizontal scrolling strip showing the **next ~24 hours** from the current hour in the city's local timezone.
- Each slot: hour label, weather icon, temperature.
- Variables: `temperature_2m`, `weather_code` (from `hourly` arrays).

### 5.7 WMO Weather Code Mapping

All mapping logic lives in **one file** (`weather_code_mapper.dart`).

| WMO Code(s) | Condition |
|-------------|-----------|
| 0 | Clear sky |
| 1, 2, 3 | Partly cloudy |
| 45, 48 | Fog |
| 51, 53, 55 | Drizzle |
| 61, 63, 65 | Rain |
| 71, 73, 75 | Snow |
| 80, 81, 82 | Rain showers |
| 95, 96, 99 | Thunderstorm |
| _Any other_ | **Unknown** (default icon) |

### 5.8 UI States

| State | Behavior |
|-------|----------|
| **Loading** | Visible loading indicator (e.g., shimmer or circular progress) |
| **Empty** | First launch, no search yet → `"Search for a city to see its weather"` |
| **Error — City not found** | `"No results found for '{query}'"` |
| **Error — No internet** | `"No internet connection"` with retry option |
| **Error — API failure** | `"Something went wrong. Please try again."` |
| **Error — Timeout** | `"Request timed out. Please try again."` |

### 5.9 Offline & Caching

- On successful forecast fetch → persist full result (current + daily + hourly) + city + timestamp to `SharedPreferences` as JSON.
- **Offline + cache exists:** Show cached data + **"Data may be outdated"** banner + **"Last updated: {time}"** label.
- **Offline + no cache:** Show error state or empty state (no internet message).

### 5.10 Header

- Display **city-local time** derived from `timezone=auto` in the API response.
- When showing cached data → include "Last updated: {formatted_time}".

### 5.11 Bonus Features (if time permits)

| Feature | Details |
|---------|---------|
| Pull-to-refresh | Swipe down on main screen to re-fetch forecast |
| Unit toggle | °C ↔ °F and km/h ↔ mph. Preference persisted. Conversion is local math (works offline). |
| Recent searches | Store last N cities as JSON array. Display in search sheet before typing. |
| Current location | Use `geolocator` to get device GPS → reverse to lat/lon → fetch forecast. Android minSdk 24 ≥ 21 ✓, iOS 15 ≥ 12 ✓. |

---

## 6. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| **Performance** | Never block the main/UI thread. Smooth 60fps scrolling. |
| **Reliability** | App must **never crash**. All exceptions caught and mapped to user-facing messages. |
| **Maintainability** | Strict separation of Presentation / Application / Domain / Data layers. |
| **Constants** | All URLs, timeouts, magic numbers live in `constants/` files. |
| **Strings** | All user-facing strings in a single `app_strings.dart` file. |
| **File length** | Target max ~300 lines per file (Proposed guideline). |
| **Git** | Regular, meaningful commits following Conventional Commits format (e.g., `feat:`, `fix:`, `refactor:`, `docs:`). |

---

## 7. Scope

### In Scope

Everything described in Sections 4–6 above.

### Out of Scope

The following were considered and **explicitly dropped** to stay within the time budget:

- ~~AQI (Air Quality Index)~~
- ~~UV index~~
- ~~Pressure~~
- ~~Cloud cover~~
- ~~Node flow chart~~
- ~~Radial arc meter~~
- ~~A third API call~~
- ~~Light theme~~ (dark only)

### Open Question

| Item | Decision | Default |
|------|----------|---------|
| `precipitation_probability` in hourly strip | Include or not? | **Not included** — can be added later by appending to hourly params and extending the model. |

---

## 8. Edge-Case Table

| # | Case | Expected Behavior | Handling Layer |
|---|------|-------------------|----------------|
| 1 | Nonexistent city (e.g., "xyznotacity") | "No results found" message displayed | Data layer parses missing `results` key |
| 2 | Input is spaces/special characters only | Validation prevents API call; show inline feedback | Presentation layer |
| 3 | No internet on first launch (no cache) | Error state with "No internet connection" message | Data + Presentation |
| 4 | No internet with existing cache | Show cached data + "Data may be outdated" banner + last-updated time | Data + Presentation |
| 5 | Slow/failed request (timeout) | Show timeout error after configured timeout duration | Data layer (Dio timeout config) |
| 6 | New search while previous is still loading | Cancel previous request via `CancelToken`, start new | Application layer |
| 7 | Same city name in different countries | Show `name + admin1 + country` in disambiguation list | Presentation layer |
| 8 | Unknown / unmapped weather codes | "Unknown" text + default icon | Domain layer (mapper) |
| 9 | Device rotation | State preserved — all state lives in Riverpod providers, not widget tree | Application layer |
| 10 | App killed and restarted | Cached data loaded from SharedPreferences on init | Data layer |
| 11 | Corrupted cache JSON | Catch parse error, clear the corrupted key, show empty/error state | Data layer |
| 12 | Partial API response (missing fields) | Null-safe defaults in `fromJson`, app never crashes | Domain layer (model factories) |
| 13 | Bottom sheet open during device rotation | Sheet state (search text, results) lives in Riverpod; survives rotation | Application + Presentation |

---

## 9. Success Criteria

Mapped to the evaluation rubric:

| Category | Weight | Criteria |
|----------|--------|----------|
| **Functionality** | 30% | All must-have features work end-to-end with real Open-Meteo API data |
| **Code Structure** | 25% | Feature-first MVVM, clean layer separation, typed models, no god-classes |
| **Error Handling** | 15% | All error states from §5.8 covered; app never crashes under any condition |
| **UI/UX** | 15% | Dark theme is polished, consistent spacing, responsive layout, accessible contrast |
| **Git / README** | 10% | Meaningful commit history (Conventional Commits), complete README with setup & architecture notes |
| **Bonus** | 5% | Pull-to-refresh, unit toggle, search history, current location (any subset) |

---

## 10. Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Scope vs. time** | High | Medium | Must-haves first. All bonus features are cuttable. Track time per phase. |
| **Open-Meteo availability** | Medium | Low | Free API with no key, but no SLA. Configured timeouts + local cache ensure the app remains usable. |
| **Design polish time sink** | Medium | Medium | Icon glow effects and hourly strip styling are done in a dedicated polish phase **after** all features work. |
| **Unfamiliar API response shapes** | Low | Low | Edge cases documented above. Defensive parsing with null-safe defaults. |
