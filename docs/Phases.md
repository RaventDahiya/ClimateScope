AI INSTRUCTION: Read ALL project docs (PRD, Architecture, Design, Rules, Phases) before writing any code.

# ClimateScope — Implementation Phases

> [!IMPORTANT]
> **Stop-and-Wait Protocol:** After completing each phase, **STOP and WAIT** for user confirmation before proceeding to the next phase. Do not batch phases together.

---

## Phase 0: Project Setup (Est: 0.5h)

**Goal:** Scaffold the Flutter project, folder structure, assets, and dark theme tokens.

### Tasks

- Create Flutter project (`flutter create climate_scope` or use existing)
- Set up folder structure per `Architecture.md`
- Add dependencies to `pubspec.yaml`: `flutter_riverpod`, `dio`, `shared_preferences`, `intl`
- Add Inter font files to `assets/fonts/` and register in `pubspec.yaml`
- Create `app_colors.dart`, `app_typography.dart`, `app_dimensions.dart`, `app_theme.dart`
- Create `api_constants.dart`, `app_constants.dart`
- Create `app_strings.dart` with all user-facing strings
- Set up `main.dart` with `ProviderScope` and `app.dart` with `MaterialApp` + dark theme
- Configure system UI overlay (status bar, nav bar) for dark mode

### Files

`main.dart`, `app.dart`, all `core/` files, `pubspec.yaml`

### Acceptance Criteria

- [ ] App launches with a dark background and no errors
- [ ] `flutter analyze` passes with no errors
- [ ] Folder structure matches `Architecture.md`
- [ ] All theme tokens, strings, and constants are defined

### Test Checklist

- [ ] App launches on emulator
- [ ] Background is dark (#1E1E1E)
- [ ] Status bar icons are light

### Commit

```
feat(setup): scaffold project with folder structure and dark theme
```

---

## Phase 1: Models & API Clients (Est: 1.0h)

**Goal:** Create all data models and API client classes.

### Tasks

- Create `city_model.dart` (name, latitude, longitude, country, admin1) with `fromJson`/`toJson`
- Create `current_weather_model.dart` (temperature, humidity, weatherCode, windSpeed) with `fromJson`
- Create `daily_forecast_model.dart` (date, weatherCode, tempMin, tempMax) with `fromJson`
- Create `hourly_forecast_model.dart` (time, temperature, weatherCode) with `fromJson`
- Create `weather_data_model.dart` (current, dailyList, hourlyList, city, timezone, lastUpdated) with `fromJson`/`toJson` (for cache)
- Create `weather_failure.dart` sealed class with all failure types
- Create `temperature_unit.dart` enum
- Create `weather_condition.dart` enum mapped from WMO codes
- Create `geocoding_api_client.dart` with Dio (search method, `CancelToken`, handle missing `results` key)
- Create `weather_api_client.dart` with Dio (fetchForecast method, `CancelToken`, current+daily+hourly)
- Create `weather_repository.dart` (combines API clients, maps `DioException` → `WeatherFailure`)

### Files

All `domain/models/`, `domain/enums/`, `domain/failures/`, `data/api/`, `data/repositories/`

### Acceptance Criteria

- [ ] All models have `fromJson` and are immutable
- [ ] API clients compile and handle missing `results` key
- [ ] `WeatherFailure` sealed class covers all error types
- [ ] `DioException` mapping is implemented in repository
- [ ] `flutter analyze` passes

### Test Checklist

- [ ] App still launches without errors

### Commit

```
feat(models): add data models, API clients, and repository
```

---

## Phase 2: Weather Code Mapper (Est: 0.3h)

**Goal:** Implement the WMO code → condition text + icon + tint color mapping.

### Tasks

- Create `weather_code_mapper.dart`
- Map all WMO code groups per `Design.md` icon mapping table
- Return condition text, Material icon, and tint color for each code
- Include "Unknown" fallback for unmapped codes
- Ensure yellow is only used for sun (0, 1) and thunderstorm (95, 96, 99) icons

### Files

`core/utils/weather_code_mapper.dart`

### Acceptance Criteria

- [ ] Every WMO code in spec maps to correct icon, text, and color
- [ ] Unknown codes return fallback
- [ ] Yellow only on sun/lightning icons
- [ ] `flutter analyze` passes

### Test Checklist

- [ ] No runtime errors when imported

### Commit

```
feat(mapper): add WMO weather code to icon and label mapper
```

---

## Phase 3: State Management & Basic UI (Est: 1.5h)

**Goal:** Wire up Riverpod notifiers and build the main screen with search, current weather, and 5-day forecast.

### Tasks

- Create `weather_notifier.dart` (`AsyncNotifier<WeatherData?>`)
- Create `search_notifier.dart` (`AsyncNotifier<List<City>>`)
- Create `settings_notifier.dart` (`Notifier<TemperatureUnit>`)
- Create `providers.dart` with all provider declarations
- Build `weather_screen.dart` — main screen consuming weather provider
- Build `weather_header.dart` — city name + time
- Build `weather_hero.dart` — icon + temp + condition (basic, no glow yet)
- Build `daily_forecast_list.dart` + `daily_forecast_row.dart`
- Build `search_bottom_sheet.dart` + `search_field.dart` + `search_result_tile.dart`
- Input validation: reject empty, whitespace-only, special-character-only input
- Wire search → geocode → pick city → forecast flow

### Files

All `application/` files, `weather_screen.dart`, all `presentation/widgets/`, all `presentation/sheets/`

### Acceptance Criteria

- [ ] Search sheet opens from header
- [ ] Typing a valid city name shows results
- [ ] Results show name + admin1 + country
- [ ] Selecting a city loads and displays current weather
- [ ] 5-day forecast list shows correctly
- [ ] Invalid input shows validation feedback, no API call
- [ ] `flutter analyze` passes

### Test Checklist

- [ ] Search "London" → multiple results with different countries
- [ ] Select a London → weather loads
- [ ] Temperature, humidity, wind shown with units
- [ ] 5 days of forecast shown
- [ ] Empty/whitespace input rejected

### Commit

```
feat(ui): implement search, current weather, and 5-day forecast
```

---

## Phase 4: Loading, Error, and Empty States (Est: 0.5h)

**Goal:** Implement all state views.

### Tasks

- Build `loading_state.dart` — centered spinner
- Build `error_state.dart` — icon + message + retry button
- Build `empty_state.dart` — search prompt for first launch
- Wire states into `weather_screen.dart` using `AsyncValue.when()`
- Wire states into search bottom sheet
- Map `WeatherFailure` types to user-friendly messages from `app_strings.dart`

### Files

`loading_state.dart`, `error_state.dart`, `empty_state.dart`, `weather_screen.dart`

### Acceptance Criteria

- [ ] App shows empty state on first launch
- [ ] Loading spinner visible during API calls
- [ ] Error states show friendly messages for: no internet, timeout, not found, server error
- [ ] Retry button triggers a new request
- [ ] Search sheet has its own loading/error/empty states
- [ ] `flutter analyze` passes

### Test Checklist

- [ ] Fresh install → empty state shown
- [ ] Search while loading → spinner visible
- [ ] Airplane mode → "No internet" error
- [ ] Search "zzzzzqqqqq" → "No results found"

### Commit

```
feat(states): add loading, error, and empty state views
```

---

## Phase 5: Offline Cache (Est: 0.75h)

**Goal:** Persist last successful weather data and show it when offline.

### Tasks

- Create `weather_local_storage.dart` (read/write `WeatherData` JSON to `SharedPreferences`)
- Include cache version field for schema versioning
- Save on successful fetch, load on app start
- Create `offline_banner.dart` — "Data may be outdated • Last updated: {time}"
- Modify `weather_notifier` to load cache first, then refresh
- Distinguish "offline + cache" (show data + banner) from "offline + no cache" (error state)
- Handle corrupted JSON: catch, clear, return null

### Files

`weather_local_storage.dart`, `offline_banner.dart`, `weather_notifier.dart`

### Acceptance Criteria

- [ ] After a successful search, data persists across app restart
- [ ] Airplane mode with cache → shows data + offline banner + last updated time
- [ ] Airplane mode without cache → error state
- [ ] Corrupted cache → gracefully cleared, shows error/empty state
- [ ] `flutter analyze` passes

### Test Checklist

- [ ] Search a city → close app → reopen → data shown
- [ ] Enable airplane mode → reopen → cached data + banner
- [ ] First launch in airplane mode → error state

### Commit

```
feat(cache): implement offline caching with staleness indicator
```

---

## Phase 6: Edge Cases (Est: 0.5h)

**Goal:** Handle all remaining edge cases.

### Tasks

- Implement request cancellation (`CancelToken`) for search-while-loading
- Test rotation: verify state survives
- Test app restart: verify cached data loads
- Handle partial API responses (null-safe defaults in models)
- Verify bottom sheet state survives rotation
- Verify "Unknown" weather code fallback works
- Add `unit_converter.dart` (pure functions, for later use)

### Files

Various (models, notifiers, API clients)

### Acceptance Criteria

- [ ] New search cancels previous in-flight request
- [ ] Rotation preserves all state (weather data, search results, sheet open state)
- [ ] Unknown WMO code shows fallback icon and text
- [ ] Partial API response doesn't crash
- [ ] `flutter analyze` passes

### Test Checklist

- [ ] Rapidly search different cities → only last result shows
- [ ] Rotate while data is displayed → data preserved
- [ ] Rotate with search sheet open → sheet and results preserved

### Commit

```
feat(edge): handle edge cases and request cancellation
```

---

## Phase 7: Design Polish (Est: 1.0h)

**Goal:** Apply the full design system — glow icon, hourly strip, metric cards, forecast polish.

### Tasks

- Build `weather_icon_glow.dart` — radial gradient backlight per condition group
- Build `hourly_strip.dart` + `hourly_slot.dart` — horizontal scrolling, selected slot highlighting
- Build `metric_card.dart` + `metric_cards_row.dart` — wind and humidity
- Polish `daily_forecast_list.dart` — dividers, min/max styling
- Polish `weather_header.dart` — dropdown chevron, date formatting
- Apply all spacing, radius, and typography tokens
- Verify WCAG contrast on all text/background pairs
- Add `Semantics` labels to all weather icons

### Files

`weather_icon_glow.dart`, `hourly_strip.dart`, `hourly_slot.dart`, `metric_card.dart`, `metric_cards_row.dart`, plus polish on existing files

### Acceptance Criteria

- [ ] Hero icon has radial glow matching condition
- [ ] Hourly strip scrolls horizontally, current hour highlighted in blue
- [ ] Wind and Humidity cards styled correctly
- [ ] 5-day forecast rows have correct layout
- [ ] All elements use theme tokens (no raw hex)
- [ ] Icons have semantics labels
- [ ] `flutter analyze` passes

### Test Checklist

- [ ] Clear sky → yellow glow behind sun icon
- [ ] Rain → blue glow behind rain icon
- [ ] Hourly strip shows ~24 hours starting from current
- [ ] Wind and humidity values correct
- [ ] Visual consistency across different weather conditions

### Commit

```
feat(design): polish UI with glow icon, hourly strip, and metric cards
```

---

## ✅ MUST-HAVE COMPLETE — CUT LINE ✅

> [!IMPORTANT]
> Everything above is **required**. Everything below is **bonus** and can be cut in reverse order (8d → 8c → 8b → 8a) if time runs out.

---

## Phase 8a: Pull-to-Refresh (Est: 0.3h) — BONUS, CUTTABLE

**Goal:** Add pull-to-refresh to weather screen.

### Tasks

- Wrap main content in `RefreshIndicator`
- On refresh: call weather notifier's refresh method
- Offline behavior: keep cached data, show "unable to refresh" message

### Files

`weather_screen.dart`, `weather_notifier.dart`

### Acceptance Criteria

- [ ] Pull down refreshes weather data
- [ ] Offline pull-to-refresh keeps cached data and shows message

### Commit

```
feat(bonus): add pull-to-refresh support
```

---

## Phase 8b: Unit Toggle (Est: 0.5h) — BONUS, CUTTABLE

**Goal:** Add Metric/Imperial toggle.

### Tasks

- Add toggle UI (in header or as a settings icon)
- Wire `settings_notifier` to presentation layer
- Convert display values using `unit_converter.dart`
- Persist preference in `SharedPreferences`
- Verify it works offline (conversion is local)

### Files

`settings_notifier.dart`, `weather_screen.dart`, `unit_converter.dart`, `weather_hero.dart`, `hourly_slot.dart`, `metric_card.dart`, `daily_forecast_row.dart`

### Acceptance Criteria

- [ ] Toggle switches between °C/km/h and °F/mph
- [ ] Preference persists across restart
- [ ] Works offline

### Commit

```
feat(bonus): add metric/imperial unit toggle
```

---

## Phase 8c: Search History (Est: 0.5h) — BONUS, CUTTABLE

**Goal:** Add recent searches, persisted and clearable.

### Tasks

- Save selected cities to `SharedPreferences` (JSON array, max 10)
- Build `recent_searches_list.dart` in search sheet
- Show when search field is empty
- Add "Clear all" button
- Tapping a recent search loads that city

### Files

`weather_local_storage.dart`, `recent_searches_list.dart`, `search_bottom_sheet.dart`, `search_notifier.dart`

### Acceptance Criteria

- [ ] Recent searches shown in sheet when input is empty
- [ ] Tapping a recent search loads weather
- [ ] Clear all removes history
- [ ] History persists across restart

### Commit

```
feat(bonus): add search history with persistence
```

---

## Phase 8d: Current Location (Est: 0.5h) — BONUS, CUTTABLE

**Goal:** Add current location with proper permission handling.

### Tasks

- Add `geolocator` dependency
- Add location permission request flow
- Handle: denied, permanently denied, services off, timeout
- Add "Current Location" button/icon in header or search sheet
- On success: reverse geocode or use lat/lon directly for forecast
- Update Android manifest and iOS `Info.plist`

### Files

`pubspec.yaml`, `AndroidManifest.xml`, `Info.plist`, `search_bottom_sheet.dart` or `weather_header.dart`, `weather_notifier.dart`

### Acceptance Criteria

- [ ] Location button requests permission
- [ ] Denied → shows explanation
- [ ] Permanently denied → directs to settings
- [ ] Services off → shows message
- [ ] Success → loads weather for current location

### Commit

```
feat(bonus): add current location with permission handling
```

---

## Phase 9: Final Polish & README (Est: 0.5h)

**Goal:** Complete README, final cleanup.

### Tasks

- Fill in `README.md` with all sections
- Final `flutter analyze` — zero warnings
- Review all files for leftover TODOs or `print` statements
- Verify Git history has meaningful commits

### Files

`README.md`, any files needing cleanup

### Acceptance Criteria

- [ ] README is complete with all sections
- [ ] `flutter analyze` passes with zero warnings
- [ ] No `print` statements in code
- [ ] Git log shows meaningful commit history

### Commit

```
docs(readme): complete README with features, setup, and architecture
```

---

## Total Hours Summary

| Phase | Description | Est. Hours | Required? |
|---|---|---|---|
| 0 | Project Setup | 0.5 | ✅ Yes |
| 1 | Models & API Clients | 1.0 | ✅ Yes |
| 2 | Weather Code Mapper | 0.3 | ✅ Yes |
| 3 | State & Basic UI | 1.5 | ✅ Yes |
| 4 | Loading/Error/Empty States | 0.5 | ✅ Yes |
| 5 | Offline Cache | 0.75 | ✅ Yes |
| 6 | Edge Cases | 0.5 | ✅ Yes |
| 7 | Design Polish | 1.0 | ✅ Yes |
| **Must-Have Total** | | **6.05** | |
| 8a | Pull-to-Refresh | 0.3 | ⭐ Bonus |
| 8b | Unit Toggle | 0.5 | ⭐ Bonus |
| 8c | Search History | 0.5 | ⭐ Bonus |
| 8d | Current Location | 0.5 | ⭐ Bonus |
| 9 | Final Polish & README | 0.5 | ✅ Yes |
| **Grand Total** | | **8.35** | |

> [!TIP]
> Must-haves (6.05h) + README (0.5h) = **6.55h**, within the 6–8h budget. All four bonuses add 1.8h, bringing total to 8.35h. If time is tight, cut bonuses in **REVERSE order: 8d → 8c → 8b → 8a**. The cut order matches the priority list from the brief.
