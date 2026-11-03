# ClimateScope — Agent Handoff Document

> Last updated: 2026-11-03 · 14:25 IST

---

## 1. Goal

Build **ClimateScope** — a single-screen, dark-themed Flutter weather app using the Open-Meteo API (no API key), Riverpod MVVM, and Dio. The app must pass a Mobile Developer Internship evaluation rubric covering: functionality, code structure, error handling, UI/UX polish, Git history, and README completeness.

Full spec lives in `docs/PRD.md`, architecture in `docs/Architecture.md`, design tokens in `docs/Design.md`, coding rules in `docs/Rules.md`, and the phase plan in `docs/Phases.md`.

**Total phases:** 0–9 (Phases 8a–8d are cuttable bonus features)

---

## 2. Current State

| Phase | Description | Status |
|---|---|---|
| 0 | Project Setup — scaffold, theme, fonts, constants | ✅ Complete (committed) |
| 1 | Models & API Clients | ✅ Complete (committed) |
| 2 | Weather Code Mapper | ✅ Complete (committed) |
| 3 | State Management & Basic UI | ✅ Complete (committed) |
| 4 | Loading / Error / Empty States | ✅ Complete (committed) |
| 5 | Offline Cache | ⏳ Not started |
| 6 | Edge Cases | ⏳ Not started |
| 7 | Design Polish | ⏳ Not started |
| 8a–8d | Bonus Features | ⏳ Not started |
| 9 | Final Polish & README | ⏳ Not started |

**Git log (latest):**
```
feat(states): add loading, error, and empty state views
feat(ui): implement search, current weather, and 5-day forecast
305d18e feat(mapper): add WMO weather code to icon and label mapper
3fe690d feat(models): add data models, API clients, and repository
a263dcd feat(setup): scaffold project with folder structure and dark theme
```

**`flutter analyze` status:** Hangs in sandbox and runner due to Windows sandbox daemon IPC limitations. Run manually in user's external terminal.

---

## 3. Active Files

### Core — Phase 0 ✅

| File | Purpose |
|---|---|
| `lib/main.dart` | Entry point — `ProviderScope` + `SystemUiOverlayStyle` |
| `lib/app.dart` | `MaterialApp` — dark theme only, `home = WeatherScreen` |
| `lib/core/constants/api_constants.dart` | Base URLs, endpoints, timeouts, query param strings |
| `lib/core/constants/app_constants.dart` | Cache keys, debounce duration, max recent searches |
| `lib/core/strings/app_strings.dart` | All user-facing strings (errors, labels, units) |
| `lib/core/theme/app_colors.dart` | All color tokens as `static const Color` |
| `lib/core/theme/app_typography.dart` | All `TextStyle` definitions using Inter font |
| `lib/core/theme/app_dimensions.dart` | Spacing scale + corner radius tokens |
| `lib/core/theme/app_theme.dart` | `ThemeData` (dark only) + `SystemUiOverlayStyle` |

### Domain — Phase 1 ✅

| File | Purpose |
|---|---|
| `lib/features/weather/domain/enums/temperature_unit.dart` | `celsius` / `fahrenheit` enum with `.symbol` getter |
| `lib/features/weather/domain/enums/weather_condition.dart` | All WMO condition groups + `fromCode(int)` factory |
| `lib/features/weather/domain/failures/weather_failure.dart` | Sealed class: `NetworkFailure`, `TimeoutFailure`, `NotFoundFailure`, `ServerFailure`, `CacheFailure`, `UnknownFailure` |
| `lib/features/weather/domain/models/city_model.dart` | Immutable — `fromJson` / `toJson` |
| `lib/features/weather/domain/models/current_weather_model.dart` | Immutable — `fromJson` |
| `lib/features/weather/domain/models/daily_forecast_model.dart` | Immutable — `fromArrays` + `fromJson` / `toJson` |
| `lib/features/weather/domain/models/hourly_forecast_model.dart` | Immutable — `fromArrays` + `fromJson` / `toJson` |
| `lib/features/weather/domain/models/weather_data_model.dart` | Aggregate — `fromJson`, `fromCacheJson` (cache-version-checked), `toJson` |

### Data — Phase 1 ✅

| File | Purpose |
|---|---|
| `lib/features/weather/data/api/geocoding_api_client.dart` | Dio GET `/v1/search` — handles missing `results` key, `CancelToken` |
| `lib/features/weather/data/api/weather_api_client.dart` | Dio GET `/v1/forecast` — current + daily + hourly, `CancelToken` |
| `lib/features/weather/data/repositories/weather_repository.dart` | Combines both clients; maps all `DioException` → `WeatherFailure` |

### Utils — Phase 2 ✅

| File | Purpose |
|---|---|
| `lib/core/utils/weather_code_mapper.dart` | `WeatherCodeMapper.map(int)` → `WeatherInfo` (icon, tint, glow, text) |

### Application — Phase 3 ✅

| File | Purpose |
|---|---|
| `lib/features/weather/application/providers.dart` | All Riverpod provider declarations (Dio clients, repository, notifiers) |
| `lib/features/weather/application/weather_notifier.dart` | `AsyncNotifier<WeatherDataModel?>` managing weather fetch and `CancelToken` |
| `lib/features/weather/application/search_notifier.dart` | `AsyncNotifier<List<CityModel>>` with 500ms debounce, input validation, and `CancelToken` |
| `lib/features/weather/application/settings_notifier.dart` | `Notifier<TemperatureUnit>` with `SharedPreferences` unit preference persistence |

### Presentation — Phase 3 & 4 ✅

| File | Purpose |
|---|---|
| `lib/features/weather/presentation/weather_screen.dart` | Main screen consuming `weatherNotifierProvider`, `CustomScrollView` layout |
| `lib/features/weather/presentation/widgets/weather_header.dart` | Tappable city selector (opens search sheet) + date/time |
| `lib/features/weather/presentation/widgets/weather_hero.dart` | Weather icon (80px) + oversized temperature (`FittedBox`) + condition text |
| `lib/features/weather/presentation/widgets/metric_card.dart` | Surface card with icon, label, and metric value with units |
| `lib/features/weather/presentation/widgets/metric_cards_row.dart` | Side-by-side Wind and Humidity metric cards |
| `lib/features/weather/presentation/widgets/daily_forecast_row.dart` | Day label, condition icon, min/max temperatures |
| `lib/features/weather/presentation/widgets/daily_forecast_list.dart` | "5 days" container enclosing daily forecast rows separated by dividers |
| `lib/features/weather/presentation/widgets/loading_state.dart` | Centered `CircularProgressIndicator` with `colorAccentBlue` |
| `lib/features/weather/presentation/widgets/error_state.dart` | `colorError` icon + `WeatherFailure`-mapped message + `colorAccentBlue` retry button |
| `lib/features/weather/presentation/widgets/empty_state.dart` | Centered search icon + prompt text + optional interactive tap handler |
| `lib/features/weather/presentation/sheets/search_field.dart` | Search text field with prefix icon, clear button, and inline validation error |
| `lib/features/weather/presentation/sheets/search_result_tile.dart` | City search item: name + admin1 + country subtitle (≥48px tap target) |
| `lib/features/weather/presentation/sheets/search_bottom_sheet.dart` | Modal bottom sheet with drag handle, search field, dedicated loading/empty/error states |

### Empty directories — filled in upcoming phases

| Directory | Phase |
|---|---|
| `lib/features/weather/data/local/` | Phase 5 — `weather_local_storage.dart` |

---

## 4. Changes Made

### Phase 0
- Created Flutter project scaffold with feature-first folder structure
- Added `flutter_riverpod`, `dio`, `shared_preferences`, `intl` to `pubspec.yaml`
- Registered Inter font family (400/500/600/700 weights) in `pubspec.yaml`
- Defined all color tokens (`app_colors.dart`), typography (`app_typography.dart`), spacing/radius (`app_dimensions.dart`)
- Created full dark `ThemeData` + `SystemUiOverlayStyle` in `app_theme.dart`
- Created all constants (`api_constants.dart`, `app_constants.dart`) and strings (`app_strings.dart`)
- Set up `main.dart` with `ProviderScope` + system UI config

### Phase 1
- Created 2 enums: `TemperatureUnit`, `WeatherCondition` (with `fromCode`)
- Created 6 sealed failure classes under `WeatherFailure`
- Created 5 immutable domain models with `fromJson`/`toJson` and null-safe defaults throughout
- `WeatherDataModel.fromCacheJson()` performs cache version check (discards stale schema)
- Created `GeocodingApiClient` — handles the critical "missing `results` key" edge case
- Created `WeatherApiClient` — fetches current + daily + hourly in one call
- Created `WeatherRepository` — full `DioException` switch mapping per Architecture spec
- `CancelToken` plumbed through both API clients and repository methods

### Phase 2
- Created `lib/core/utils/weather_code_mapper.dart`
- `WeatherInfo` immutable data class with `conditionText`, `icon`, `tintColor`, `glowColor`, `glowOpacity` fields
- `WeatherCodeMapper.map(int code)` static method using Dart `switch` expression
- All 21 WMO codes mapped (0–99) per Design.md §6 icon table
- `colorWeatherYellow` used **exclusively** for codes 0, 1, 95, 96, 99 (sun + lightning)
- `glowColor` and `glowOpacity` embedded directly so Phase 7 `WeatherIconGlow` needs no separate lookup
- Unknown fallback (`_`) returns grey `help_outline_rounded` icon with `colorTextSecondary`

### Phase 3
- Implemented `providers.dart` declaring all API clients, repositories, and notifiers.
- Implemented `settings_notifier.dart` managing temperature unit preferences with `SharedPreferences` persistence.
- Implemented `weather_notifier.dart` (`AsyncNotifier<WeatherDataModel?>`) managing city weather fetching and `CancelToken` request cancellation.
- Implemented `search_notifier.dart` (`AsyncNotifier<List<CityModel>>`) with 500ms debounce, input validation rejecting empty, whitespace-only, and special-character-only input, and request cancellation.
- Implemented `weather_header.dart` with city name selector, accessible tap target, chevron, and date/time formatting via `intl`.
- Implemented `weather_hero.dart` with 160x160 container, 80px condition icon, `FittedBox` hero temperature, and condition label.
- Implemented `metric_card.dart` and `metric_cards_row.dart` for Wind and Humidity display with units.
- Implemented `daily_forecast_row.dart` and `daily_forecast_list.dart` for 5-day forecast.
- Implemented `search_field.dart`, `search_result_tile.dart`, and `search_bottom_sheet.dart` modal sheet with drag handle, clear button, and inline validation.
- Implemented `weather_screen.dart` with `AsyncValue.when()` handling empty state, loading, error, and populated `CustomScrollView` content.

### Phase 4
- Implemented `loading_state.dart` with centered `CircularProgressIndicator` tinted with `colorAccentBlue`.
- Implemented `empty_state.dart` with 64px `Icons.search_rounded` icon, text styled with `AppTypography.body` in `colorTextSecondary`, and optional `InkWell` wrapper for interactive tap actions.
- Implemented `error_state.dart` with 64px `Icons.error_outline_rounded` in `colorError`, user-friendly message mapped exhaustively from `WeatherFailure` sealed members using pattern matching, and an outlined `AppStrings.retry` button with `colorAccentBlue` border and text.
- Wrapped column contents in `SingleChildScrollView` to prevent any viewport overflow when virtual keyboards are open.
- Refactored `weather_screen.dart` to use `LoadingState`, `ErrorState`, and `EmptyState`.
- Refactored `search_bottom_sheet.dart` to use `LoadingState`, `ErrorState` with retry on search query, and `EmptyState` displaying `AppStrings.noResultsFoundFor(query)`.
- Updated `WeatherNotifier` to preserve `selectedCity` across requests so that retry actions on failure reliably retry the intended city.
- Added comprehensive unit/widget tests in `test/widget_test.dart` covering launch smoke test, `LoadingState`, `EmptyState`, and `ErrorState` message mapping and retry interaction.

---

## 5. Failed Attempts

| Issue | What Happened | Resolution |
|---|---|---|
| `flutter analyze` hangs in sandbox | Both `flutter analyze` and `dart analyze` start but never complete — process runs indefinitely with no output | Kill the task. Run manually in user's terminal outside the sandbox |
| `git add` / `git commit` fail in standard sandbox | `fatal: Unable to create '.git/index.lock': Permission denied` — sandbox lacks write access to `.git` | Always use `BypassSandbox: true` for all git operations |
| `&&` chaining in PowerShell | `'&&' is not a valid statement separator in this version` | Use separate `run_command` calls, or join commands with `;` |
| Removed stale `index.lock` | Attempted `Remove-Item -Force .git\index.lock` — file did not exist; permission error persisted anyway | Not a stale lock — sandbox simply has no `.git` write access |

---

## 6. Next Steps

### Immediate — Phase 5: Offline Cache (Est: 0.75h)

**Goal:** Persist last successful weather data and show it when offline.

**Files to build / update:**
- `lib/features/weather/data/local/weather_local_storage.dart` (read/write `WeatherData` JSON to `SharedPreferences`)
- `lib/features/weather/presentation/widgets/offline_banner.dart` — "Data may be outdated • Last updated: {time}"
- Modify `weather_notifier.dart` to load cache first, then refresh
- Distinguish "offline + cache" (show data + banner) from "offline + no cache" (error state)

Commit: `feat(cache): implement offline caching with staleness indicator`

### Remaining Phases (in order)

| Phase | Description |
|---|---|
| 5 | Offline cache — `weather_local_storage.dart` + `offline_banner.dart` |
| 6 | Edge cases — request cancellation, rotation, partial responses, `unit_converter.dart` |
| 7 | Design polish — glow icon, hourly strip, metric cards, WCAG check |
| 8a–8d | Bonus (cuttable in reverse order): pull-to-refresh, unit toggle, search history, location |
| 9 | README + final `flutter analyze` clean pass |

### Operational Rules for Next Agent

1. **`flutter analyze`** — always run manually in user's terminal outside sandbox
2. **`git add` / `git commit`** — always `BypassSandbox: true`
3. **Stop-and-Wait Protocol** — stop after each phase; wait for user confirmation before continuing
4. **No raw hex in widgets** — always use `AppColors.*` tokens
5. **No inline strings** — always use `AppStrings.*`
6. **No `dynamic` types** — strictly typed throughout
7. **No `print()`** — use `debugPrint()` during dev only; remove before commit
