AI INSTRUCTION: Read ALL project docs (PRD, Architecture, Design, Rules, Phases) before writing any code.

# ClimateScope — Architecture Document

---

## 1. Pattern: Feature-First Layered MVVM with Riverpod

### Architecture Overview

ClimateScope uses a **feature-first layered MVVM** (Model-View-ViewModel) architecture with **Riverpod** as the state management and dependency injection solution. The app has a single feature (`weather`) organized into four layers.

```
┌─────────────────────────────────────────────┐
│               Presentation                   │
│   Widgets, Screens, Sheets (ConsumerWidget) │
│         ↕ ref.watch / ref.read              │
├─────────────────────────────────────────────┤
│               Application                    │
│   AsyncNotifier / Notifier (ViewModels)      │
│         ↕ method calls                      │
├─────────────────────────────────────────────┤
│                 Domain                       │
│   Models, Enums, Failures, Mappers           │
│         ↕ data types                        │
├─────────────────────────────────────────────┤
│                  Data                        │
│   API Clients (Dio), Repository, Storage     │
└─────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Responsibility | Imports Allowed |
|---|---|---|
| **Presentation** | Widgets, screens, sheets. Consumes providers via `ref.watch`/`ref.read`. No business logic. | Application (providers), Domain (models/enums), Core (theme/strings) |
| **Application** | Notifiers (AsyncNotifier/Notifier). Orchestrates use cases, manages state. No UI imports. | Domain (models/enums/failures), Data (repository) |
| **Domain** | Models, enums, typed failures, weather code mapper. Pure Dart — no Flutter imports. | None (self-contained) |
| **Data** | API clients (Dio), repository, local storage (SharedPreferences). Network + persistence. | Domain (models/failures) |

### Why Not BLoC or Provider?

| Alternative | Why Not |
|---|---|
| **BLoC** | Powerful but disproportionately heavy for a single-screen app. Requires `bloc`, `flutter_bloc`, and typically `equatable` packages. The event/state boilerplate (sealed event classes, multiple state classes per feature) adds significant ceremony for what is essentially two async data flows (search and weather). BLoC excels in multi-screen apps with complex event-driven logic; here it would be over-engineering. |
| **Provider** | Lower-level predecessor to Riverpod by the same author (Remi Rousselet). Lacks built-in `AsyncValue` for loading/error/data states, has no compile-time provider safety, depends on `BuildContext` for access (problematic in notifiers), and is harder to test. Riverpod is its explicit successor and is recommended for new projects. |
| **Riverpod with AsyncNotifier** ✅ | Built-in `AsyncValue<T>` eliminates custom loading/error/data sealed classes. Compile-time safe providers (no runtime `ProviderNotFoundException`). No `BuildContext` dependency in notifiers. `CancelToken`-friendly. Excellent fit for a small app with two clear async data flows. |

---

## 2. Stack & Versions

| Technology | Version | Purpose |
|---|---|---|
| Flutter | 3.47.9 (stable) | UI framework |
| Dart | 3.13.7 | Language |
| DevTools | 2.60.0 | Debugging |
| `flutter_riverpod` | latest | State management (AsyncNotifier/Notifier, no codegen) |
| `dio` | latest | HTTP client with timeouts and cancel tokens |
| `shared_preferences` | latest | Local key-value persistence |
| `intl` | latest | Date/time formatting |
| `geolocator` | latest (bonus only) | Device GPS location |

### Platform Targets

| Platform | Minimum Version | Source |
|---|---|---|
| Android | API 24 (Android 7.0 Nougat) | Flutter 3.47 template default |
| iOS | 15.0 | Flutter 3.47 template default |

> [!NOTE]
> `geolocator` requires Android minSdk ≥ 21 and iOS ≥ 12. Both are satisfied by the Flutter 3.47 defaults (24 and 15.0 respectively).

---

## 3. Data Flow

### Primary Flow: Search → Weather Display

```
User taps city selector (header)
    │
    ▼
Modal bottom sheet opens
    │
    ▼
User types city name
    │
    ▼
Input validated ─── Invalid? ──→ Show validation feedback, STOP
    │
    ▼ (valid, after debounce — Proposed: 500ms)
    │
Geocoding API call (GET /v1/search?name={city}&count=5)
    │
    ├── `results` key missing ──→ Show "No results found"
    │
    ▼
Show result list (name + admin1 + country)
    │
    ▼
User taps a result → sheet closes
    │
    ▼
Forecast API call (GET /v1/forecast?lat&lon&current&daily&hourly&forecast_days=5&timezone=auto)
    │
    ├── Success ──→ Parse → Create models → Update state → UI rebuilds
    │                                          │
    │                                          ▼
    │                                  Cache to SharedPreferences (JSON)
    │
    ├── DioException ──→ Map to WeatherFailure → Show error UI
    │
    └── Timeout ──→ TimeoutFailure → Show timeout message
```

### Secondary Flow: App Start (Cache Load)

```
App starts
    │
    ▼
WeatherNotifier.build() called
    │
    ▼
Load cached WeatherData from SharedPreferences
    │
    ├── Cache exists + valid ──→ Show cached data
    │       │
    │       ▼
    │   Check connectivity
    │       │
    │       ├── Online ──→ Refresh in background (optional)
    │       └── Offline ──→ Show "may be outdated" banner
    │
    ├── Cache exists + corrupted ──→ Clear cache, return null (empty state)
    │
    └── No cache ──→ Return null (empty state: "Search for a city…")
```

### Request Cancellation Flow

```
Search "Lon" → API request A starts (CancelToken A)
    │
User types "don" → "London"
    │
    ▼
Cancel CancelToken A → API request A aborted
    │
    ▼
Search "London" → API request B starts (CancelToken B)
    │
    ▼
Results for "London" arrive → display
```

---

## 4. Folder & File Tree

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_dimensions.dart
│   ├── utils/
│   │   ├── weather_code_mapper.dart
│   │   └── unit_converter.dart
│   └── strings/
│       └── app_strings.dart
├── features/
│   └── weather/
│       ├── data/
│       │   ├── api/
│       │   │   ├── weather_api_client.dart
│       │   │   └── geocoding_api_client.dart
│       │   ├── repositories/
│       │   │   └── weather_repository.dart
│       │   └── local/
│       │       └── weather_local_storage.dart
│       ├── domain/
│       │   ├── models/
│       │   │   ├── city_model.dart
│       │   │   ├── current_weather_model.dart
│       │   │   ├── daily_forecast_model.dart
│       │   │   ├── hourly_forecast_model.dart
│       │   │   └── weather_data_model.dart
│       │   ├── enums/
│       │   │   ├── weather_condition.dart
│       │   │   └── temperature_unit.dart
│       │   └── failures/
│       │       └── weather_failure.dart
│       ├── application/
│       │   ├── weather_notifier.dart
│       │   ├── search_notifier.dart
│       │   ├── settings_notifier.dart
│       │   └── providers.dart
│       └── presentation/
│           ├── weather_screen.dart
│           ├── widgets/
│           │   ├── weather_header.dart
│           │   ├── weather_hero.dart
│           │   ├── hourly_strip.dart
│           │   ├── hourly_slot.dart
│           │   ├── metric_card.dart
│           │   ├── metric_cards_row.dart
│           │   ├── daily_forecast_list.dart
│           │   ├── daily_forecast_row.dart
│           │   ├── weather_icon_glow.dart
│           │   ├── offline_banner.dart
│           │   ├── empty_state.dart
│           │   ├── error_state.dart
│           │   └── loading_state.dart
│           └── sheets/
│               ├── search_bottom_sheet.dart
│               ├── search_field.dart
│               ├── search_result_tile.dart
│               └── recent_searches_list.dart
assets/
├── fonts/
│   ├── Inter-Regular.ttf
│   ├── Inter-Medium.ttf
│   ├── Inter-SemiBold.ttf
│   └── Inter-Bold.ttf
```

### File Responsibilities

| File | Layer | Responsibility |
|---|---|---|
| `main.dart` | Entry | App entry point, wraps in `ProviderScope`, calls `runApp` |
| `app.dart` | Entry | `MaterialApp` widget, applies `AppTheme`, sets home to `WeatherScreen` |
| **Core** | | |
| `api_constants.dart` | Core | Base URLs, endpoint paths, timeout durations, query parameters |
| `app_constants.dart` | Core | Cache keys, debounce duration, max recent searches count |
| `app_theme.dart` | Core | `ThemeData` definition (dark only), system UI overlay config |
| `app_colors.dart` | Core | All color tokens as `static const Color` |
| `app_typography.dart` | Core | All `TextStyle` definitions using Inter font family |
| `app_dimensions.dart` | Core | Spacing scale, corner radii, icon sizes, component dimensions |
| `weather_code_mapper.dart` | Core | WMO code → condition text + `IconData` + `Color` tint. Single source of truth. |
| `unit_converter.dart` | Core | Pure functions: `celsiusToFahrenheit(double)`, `kmhToMph(double)` and inverses |
| `app_strings.dart` | Core | All user-facing strings as `static const String`. Error messages, labels, units. |
| **Data** | | |
| `geocoding_api_client.dart` | Data | Dio GET to geocoding endpoint. Handles missing `results` key. Returns `List<CityModel>`. |
| `weather_api_client.dart` | Data | Dio GET to forecast endpoint. Returns parsed current + daily + hourly data. |
| `weather_repository.dart` | Data | Combines API clients. Maps `DioException` → `WeatherFailure`. Single data access point for notifiers. |
| `weather_local_storage.dart` | Data | Read/write `WeatherDataModel` JSON, unit preference, and recent searches to `SharedPreferences`. |
| **Domain** | | |
| `city_model.dart` | Domain | Immutable class: `name`, `latitude`, `longitude`, `country`, `admin1`. `fromJson`/`toJson`. |
| `current_weather_model.dart` | Domain | Immutable class: `temperature`, `humidity`, `weatherCode`, `windSpeed`. `fromJson`. |
| `daily_forecast_model.dart` | Domain | Immutable class: `date`, `weatherCode`, `tempMin`, `tempMax`. `fromJson`. |
| `hourly_forecast_model.dart` | Domain | Immutable class: `time`, `temperature`, `weatherCode`. `fromJson`. |
| `weather_data_model.dart` | Domain | Aggregate: `current`, `List<DailyForecastModel>`, `List<HourlyForecastModel>`, `CityModel`, `timezone`, `lastUpdated`. `fromJson`/`toJson` for cache. |
| `weather_condition.dart` | Domain | Enum representing weather condition groups (clearSky, partlyCloudy, fog, etc.) |
| `temperature_unit.dart` | Domain | Enum: `celsius`, `fahrenheit` |
| `weather_failure.dart` | Domain | Sealed class: `NetworkFailure`, `TimeoutFailure`, `NotFoundFailure`, `ServerFailure`, `CacheFailure`, `UnknownFailure` |
| **Application** | | |
| `weather_notifier.dart` | Application | `AsyncNotifier<WeatherDataModel?>`. `build()` loads cache. `fetchWeather(city)` calls repository. Manages `CancelToken`. |
| `search_notifier.dart` | Application | `AsyncNotifier<List<CityModel>>`. `search(query)` calls geocoding. Manages `CancelToken`. Validates input. |
| `settings_notifier.dart` | Application | `Notifier<TemperatureUnit>`. `toggle()` method. Persists to storage. |
| `providers.dart` | Application | All provider declarations: `weatherNotifierProvider`, `searchNotifierProvider`, `settingsNotifierProvider`, plus Dio and repository providers. |
| **Presentation** | | |
| `weather_screen.dart` | Presentation | Main (only) screen. `ConsumerWidget`. Watches `weatherNotifierProvider`. Switches on `AsyncValue` for loading/data/error/empty. Scrollable column layout. |
| `weather_header.dart` | Presentation | City name (tappable → opens sheet), date/time display, dropdown chevron icon |
| `weather_hero.dart` | Presentation | Glowing weather icon + oversized temperature + condition text |
| `hourly_strip.dart` | Presentation | Section title + horizontal `ListView.builder` of `HourlySlot` widgets |
| `hourly_slot.dart` | Presentation | Single time slot: time label, icon, temperature. Selected state via `colorAccentBlue` |
| `metric_card.dart` | Presentation | Single metric display: icon, label, value+unit. Rounded card with `colorSurface` |
| `metric_cards_row.dart` | Presentation | Row containing Wind and Humidity `MetricCard` widgets |
| `daily_forecast_list.dart` | Presentation | "5 days" section title + rounded container with `DailyForecastRow` children |
| `daily_forecast_row.dart` | Presentation | Single day: day name, icon, min temp, max temp |
| `weather_icon_glow.dart` | Presentation | `Container` with `RadialGradient` decoration + centered weather `Icon` |
| `offline_banner.dart` | Presentation | "Data may be outdated • Last updated: {time}" banner |
| `empty_state.dart` | Presentation | First-launch view: search icon + prompt text |
| `error_state.dart` | Presentation | Error icon + friendly message + retry button |
| `loading_state.dart` | Presentation | Centered `CircularProgressIndicator` |
| `search_bottom_sheet.dart` | Presentation | Modal bottom sheet container. Manages search field + results/recent/states. |
| `search_field.dart` | Presentation | `TextField` with validation, search icon, clear button |
| `search_result_tile.dart` | Presentation | City result: name + admin1 + country. Tappable. |
| `recent_searches_list.dart` | Presentation | List of recent city selections with "Clear all" (bonus) |

---

## 5. Models

### Design Decision: Hand-Written Immutable Classes (Proposed)

**Justification:** The project has only 5 model classes. Using `freezed` + `json_serializable` + `build_runner` would add 3 dependencies, a code generation step, and generated file noise (`.g.dart`, `.freezed.dart`) — disproportionate overhead for this scale. Hand-written models are transparent, require no build step, and are easy to review in a take-home assignment. The trade-off (manual `copyWith` if needed, manual `fromJson`) is acceptable given the small model count.

### Model Definitions

#### CityModel

| Field | Type | Source | Notes |
|---|---|---|---|
| `name` | `String` | `results[i].name` | City name |
| `latitude` | `double` | `results[i].latitude` | For forecast API |
| `longitude` | `double` | `results[i].longitude` | For forecast API |
| `country` | `String` | `results[i].country` | For disambiguation |
| `admin1` | `String?` | `results[i].admin1` | Region/state, nullable (not all cities have it) |

#### CurrentWeatherModel

| Field | Type | Source | Notes |
|---|---|---|---|
| `temperature` | `double` | `current.temperature_2m` | Always Celsius from API |
| `humidity` | `int` | `current.relative_humidity_2m` | Percentage |
| `weatherCode` | `int` | `current.weather_code` | WMO code |
| `windSpeed` | `double` | `current.wind_speed_10m` | Always km/h from API |

#### DailyForecastModel

| Field | Type | Source | Notes |
|---|---|---|---|
| `date` | `DateTime` | `daily.time[i]` | Parsed from ISO date string |
| `weatherCode` | `int` | `daily.weather_code[i]` | WMO code |
| `tempMin` | `double` | `daily.temperature_2m_min[i]` | Celsius |
| `tempMax` | `double` | `daily.temperature_2m_max[i]` | Celsius |

#### HourlyForecastModel

| Field | Type | Source | Notes |
|---|---|---|---|
| `time` | `DateTime` | `hourly.time[i]` | Parsed from ISO datetime string |
| `temperature` | `double` | `hourly.temperature_2m[i]` | Celsius |
| `weatherCode` | `int` | `hourly.weather_code[i]` | WMO code |

#### WeatherDataModel (Aggregate, Cacheable)

| Field | Type | Notes |
|---|---|---|
| `current` | `CurrentWeatherModel` | Current conditions |
| `dailyForecasts` | `List<DailyForecastModel>` | 5-day list |
| `hourlyForecasts` | `List<HourlyForecastModel>` | ~120 entries (5 days × 24h), filtered to next ~24h in presentation |
| `city` | `CityModel` | Selected city |
| `timezone` | `String` | From API `timezone` field (e.g., `"Europe/Berlin"`) |
| `lastUpdated` | `DateTime` | Timestamp of successful fetch, for cache staleness display |
| `cacheVersion` | `int` | Schema version for cache migration (Proposed: start at `1`) |

`fromJson`/`toJson` on `WeatherDataModel` enables full serialization to/from `SharedPreferences`.

---

## 6. State Classes

### AsyncValue Eliminates Custom State Boilerplate

Riverpod's `AsyncValue<T>` provides three states out of the box:

| State | Type | Meaning |
|---|---|---|
| Loading | `AsyncLoading<T>` | Request in progress |
| Data | `AsyncData<T>` | Successful result |
| Error | `AsyncError<T>` | Failed with exception |

This eliminates the need for custom sealed state classes like `WeatherState { loading, loaded, error }`.

### Provider State Types

| Provider | State Type | Notes |
|---|---|---|
| `weatherNotifierProvider` | `AsyncValue<WeatherDataModel?>` | `null` data = empty (no search yet). Loading = fetching. Error = failure. |
| `searchNotifierProvider` | `AsyncValue<List<CityModel>>` | Empty list = no results. Loading = searching. Error = failure. |
| `settingsNotifierProvider` | `TemperatureUnit` | Synchronous. Uses `Notifier`, not `AsyncNotifier`. |

### UI Consumption Pattern

```dart
// In a ConsumerWidget's build method:
final weatherAsync = ref.watch(weatherNotifierProvider);

return weatherAsync.when(
  loading: () => const LoadingState(),
  error: (error, stack) => ErrorState(failure: error as WeatherFailure),
  data: (data) {
    if (data == null) return const EmptyState();
    return WeatherContent(data: data);
  },
);
```

---

## 7. Typed Failures (Sealed Class)

```dart
sealed class WeatherFailure {
  const WeatherFailure(this.message);
  final String message;
}

class NetworkFailure extends WeatherFailure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class TimeoutFailure extends WeatherFailure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

class NotFoundFailure extends WeatherFailure {
  const NotFoundFailure([super.message = 'City not found']);
}

class ServerFailure extends WeatherFailure {
  const ServerFailure([super.message = 'Server error']);
}

class CacheFailure extends WeatherFailure {
  const CacheFailure([super.message = 'Cache read error']);
}

class UnknownFailure extends WeatherFailure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
```

### DioException Mapping

| DioException Type | Status Code | Maps To |
|---|---|---|
| `connectionTimeout` | — | `TimeoutFailure` |
| `sendTimeout` | — | `TimeoutFailure` |
| `receiveTimeout` | — | `TimeoutFailure` |
| `connectionError` | — | `NetworkFailure` |
| `badResponse` | 404 | `NotFoundFailure` |
| `badResponse` | 5xx | `ServerFailure` |
| `badResponse` | other | `ServerFailure` |
| `cancel` | — | Silently ignored (user-initiated cancellation) |
| Any other | — | `UnknownFailure` |

The mapping lives in `weather_repository.dart` in a helper method. Notifiers catch `WeatherFailure` and set `AsyncValue.error(failure, stackTrace)`.

---

## 8. Request Cancellation Strategy

- Each notifier (`WeatherNotifier`, `SearchNotifier`) holds a `CancelToken? _cancelToken` field.
- On every new request:
  1. Cancel the previous token: `_cancelToken?.cancel('New request initiated')`
  2. Create a fresh token: `_cancelToken = CancelToken()`
  3. Pass the token to Dio: `dio.get(url, cancelToken: _cancelToken)`
- When Dio throws `DioException` with type `cancel`, catch it silently — it is expected behavior, not an error.
- This prevents stale results from overwriting fresh ones when the user types quickly or switches cities rapidly.

---

## 9. Caching Strategy

### What Is Stored

| SharedPreferences Key | Value Type | Content |
|---|---|---|
| `cached_weather_data` | `String` (JSON) | Full `WeatherDataModel.toJson()` including city, current, daily, hourly, timezone, lastUpdated, cacheVersion |
| `selected_unit` | `String` | `"celsius"` or `"fahrenheit"` |
| `recent_searches` | `String` (JSON array) | List of `CityModel.toJson()` objects, max 10 entries (Proposed) |

### Schema Versioning

The JSON includes a `cacheVersion` integer field (Proposed: start at `1`). On read:

1. Parse JSON.
2. Check `cacheVersion` against the current app's expected version.
3. If mismatch → discard the cached data (treat as cache miss), clear the key.
4. This prevents crashes when model fields change between app updates.

### Corruption Handling

```
Read SharedPreferences key
    │
    ▼
String is null? ──→ Return null (no cache)
    │
    ▼
JSON parse (try/catch)
    │
    ├── FormatException ──→ Clear key, return null
    ├── TypeError ──→ Clear key, return null
    │
    ▼
cacheVersion matches? ──→ No → Clear key, return null
    │
    ▼ Yes
Return WeatherDataModel
```

### Staleness Display

- When showing cached data, the `offline_banner.dart` widget reads `lastUpdated` and displays: `"Data may be outdated • Last updated: {formatted_time}"`
- No automatic refresh on a timer. Refresh is manual (pull-to-refresh in bonus phase).

---

## 10. Rotation / Restart State Strategy

### Rotation (Configuration Change)

- **All app state lives in Riverpod providers**, which exist outside the widget tree in the `ProviderScope`.
- When the device rotates, widgets are rebuilt but providers are **not** recreated.
- Result: weather data, search results, selected unit, and all other state survive rotation automatically.
- No `onSaveInstanceState`, no `AutomaticKeepAliveClientMixin`, no manual state restoration needed.

### App Restart (Process Death)

- On restart, `WeatherNotifier.build()` is called.
- It reads from `SharedPreferences` (cache) and returns the cached `WeatherDataModel` if available.
- The user sees the last-fetched weather immediately, with a staleness indicator if offline.
- `SettingsNotifier.build()` reads the persisted unit preference.

### No StatefulWidget State Dependencies

- Zero stateful data lives in `StatefulWidget.state`.
- `StatefulWidget` may be used only for animation controllers or `TextEditingController` (presentation-only concerns that don't need to survive rotation because they reset naturally — e.g., search field text is also mirrored in the notifier for debounce purposes).

---

## 11. Bottom Sheet State Handling

### State Location

- Search text (for debounce) and search results live in `SearchNotifier` (a Riverpod provider).
- The bottom sheet is opened via `showModalBottomSheet`. On rotation, Flutter may dismiss and re-show the modal. However:
  - The search query persists in the notifier.
  - The results persist in the notifier.
  - The `TextEditingController` in the sheet is initialized from the notifier's last query, so the field content is restored.

### Keyboard Handling

- `TextInputAction.search` on the search field.
- Keyboard dismisses on:
  - User tapping a search result.
  - User pressing the search action key.
  - Sheet closing.
- `resizeToAvoidBottomInset: true` (default) ensures the sheet content scrolls above the keyboard.

### Proposed Bottom Sheet Configuration

| Property | Value | Reason |
|---|---|---|
| `isScrollControlled` | `true` | Allows sheet to take more than 50% of screen |
| `useSafeArea` | `true` | Respects status bar |
| `shape` | `RoundedRectangleBorder` with `radiusXl` top corners | Design spec |
| `backgroundColor` | `AppColors.surface` | Design spec |
| `showDragHandle` | `true` | Standard sheet affordance |

---

## 12. Unit Conversion Approach

### Principle: Store Metric, Convert on Display

- Open-Meteo returns all values in metric (°C, km/h) by default.
- Data is stored in metric everywhere: models, cache, state.
- Conversion happens **only** in the presentation layer, at render time.
- This means the unit toggle works **offline** — it's pure local math, no API call needed.

### Conversion Functions (in `unit_converter.dart`)

| Function | Formula | Notes |
|---|---|---|
| `celsiusToFahrenheit(double c)` | `c × 9/5 + 32` | Returns `double` |
| `fahrenheitToCelsius(double f)` | `(f - 32) × 5/9` | Not needed for display, included for completeness |
| `kmhToMph(double kmh)` | `kmh × 0.621371` | Returns `double` |
| `mphToKmh(double mph)` | `mph × 1.60934` | Not needed for display, included for completeness |
| `formatTemperature(double value, TemperatureUnit unit)` | Converts + formats with unit suffix | Returns `String` like `"23°C"` or `"73°F"` |
| `formatWindSpeed(double value, TemperatureUnit unit)` | Converts + formats with unit suffix | Returns `String` like `"12 km/h"` or `"7 mph"` |

### Presentation Layer Usage

```dart
// In a widget:
final unit = ref.watch(settingsNotifierProvider);
final displayTemp = UnitConverter.formatTemperature(model.temperature, unit);
```

---

## 13. Extensibility

### Adding a Weekly Chart

1. Change `forecast_days=5` to `forecast_days=7` in `api_constants.dart`.
2. The existing `DailyForecastModel` and parsing logic handle any number of days.
3. Add a new `WeeklyChart` widget in `presentation/widgets/`.
4. No changes to notifiers or repository needed.

### Adding More Hourly Detail

1. Append variables to the `hourly` query parameter (e.g., `precipitation_probability`, `wind_speed_10m`).
2. Extend `HourlyForecastModel` with new fields.
3. Update `fromJson` to parse the new fields (with null-safe defaults for backward compatibility).
4. Add display widgets in the hourly slot or a detail view.

### Swapping Data Source

1. Create a new API client implementing the same method signatures.
2. Update `weather_repository.dart` to use the new client.
3. Models and notifiers remain unchanged if the repository interface is stable.
4. This is why the repository abstraction layer exists — it decouples notifiers from specific API implementations.

### Adding a Second City (Saved Locations)

1. Change `weatherNotifierProvider` to manage a `Map<CityModel, WeatherDataModel>` or a list.
2. Add a city management notifier.
3. Update the cache to store multiple entries.
4. Add a city-switcher UI component.

