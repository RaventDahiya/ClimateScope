AI INSTRUCTION: Read ALL project docs (PRD, Architecture, Design, Rules, Phases) before writing any code.

> [!NOTE]
> **Antigravity Auto-Discovery:** This file should be placed at `.agents/rules/Rules.md` in the project root so Antigravity loads it automatically. Antigravity discovers rules from `.agents/` (or `.agent/`, `_agents/`, `_agent/`) at the workspace root.

> [!NOTE]
> **Phases as a Skill (Not Required):** `Phases.md` can be provided to Antigravity as a workflow skill at `.agents/skills/phases/SKILL.md` with appropriate frontmatter, but given the linear single-pass nature of this project, it is more practical to reference `Phases.md` directly in conversation. The phases are sequential and each ends with a stop-and-wait instruction, so a workflow skill is not necessary.

---

# ClimateScope — AI Coder Rules

## 1. Project Context

**ClimateScope** is a Flutter weather application. Key constraints:

- **Single screen** app (no routing)
- **Dark theme only** — no light theme
- **Open-Meteo API** — free, no API key
- **Riverpod MVVM** — AsyncNotifier pattern, no codegen
- **Time budget:** 6–8 hours
- **Read ALL project docs** (PRD, Architecture, Design, Rules, Phases) **before writing any code**

---

## 2. Allowed Libraries

| Library | Purpose | Notes |
|---|---|---|
| `flutter_riverpod` | State management | AsyncNotifier/Notifier, **NO codegen** |
| `dio` | HTTP client | Timeouts, cancel tokens |
| `shared_preferences` | Local storage | Cache, settings, search history |
| `intl` | Date/time formatting | For displaying dates and times |
| `geolocator` | Device location (bonus) | Only in bonus phase |

---

## 3. Forbidden Libraries & Practices

- ❌ `riverpod_generator`, `build_runner`, `freezed`, `json_serializable` — **NO code generation**
- ❌ `http` package — use `dio`
- ❌ `provider` package — use `flutter_riverpod`
- ❌ Any state management other than Riverpod
- ❌ Any new dependency without explicit approval from the user
- ❌ `flutter_bloc`, `bloc`, `equatable`
- ❌ `auto_route`, `go_router` — single screen app, no routing needed

---

## 4. Dart / Flutter Conventions

- Use `flutter_lints` (included by default in Flutter 3.47)
- Mark all possible constructors and widgets as `const`
- **NEVER** use `dynamic` type — always specify types
- **NEVER** use `print()` — use `debugPrint()` only during development, remove before commit
- Prefer `final` over `var`
- Use trailing commas for multi-line parameter lists
- Max file length: ~300 lines (Proposed). Split if exceeded.
- Follow effective Dart style guide naming conventions

---

## 5. Naming Conventions

| Item | Convention | Example |
|---|---|---|
| Files | snake_case | `weather_screen.dart` |
| Classes | PascalCase | `WeatherNotifier` |
| Variables/functions | camelCase | `fetchWeather()` |
| Constants | camelCase | `defaultTimeout` |
| Private members | _prefix | `_cancelToken` |
| Providers | camelCase + Provider suffix | `weatherNotifierProvider` |
| Enums | PascalCase name, camelCase values | `TemperatureUnit.celsius` |

---

## 6. Error Handling Rules

- **NEVER** swallow exceptions silently
- Map **ALL** `DioException` to typed `WeatherFailure` sealed class members
- DioException mapping:
  - `DioExceptionType.connectionTimeout`, `.sendTimeout`, `.receiveTimeout` → `TimeoutFailure`
  - `DioExceptionType.connectionError` → `NetworkFailure`
  - `DioExceptionType.badResponse` with 404 → `NotFoundFailure`
  - `DioExceptionType.badResponse` other → `ServerFailure`
  - All other → `UnknownFailure`
- Cache parse errors → `CacheFailure`, clear corrupted data
- Always provide user-friendly error messages (from `app_strings.dart`)
- Use `AsyncValue.guard()` in notifiers for error handling

---

## 7. "Always Do" List

- ✅ Read **ALL** project docs before writing any code
- ✅ Use theme color tokens from `app_colors.dart` — never raw hex in widgets
- ✅ Use text styles from `app_typography.dart` — never inline `TextStyle` in widgets
- ✅ Use spacing constants from `app_dimensions.dart`
- ✅ Use strings from `app_strings.dart` — no hard-coded user-facing text in widgets
- ✅ Use `const` constructors wherever possible
- ✅ Handle **ALL** states: loading, data, error, empty
- ✅ Cancel previous requests when starting a new search
- ✅ Validate search input before API calls
- ✅ Show units with all values (°C, km/h, %)
- ✅ Keep models immutable
- ✅ Use `ref.watch()` in widget `build()` methods
- ✅ Use `ref.read()` in callbacks and event handlers
- ✅ Test the app manually after completing each phase
- ✅ Commit after each phase with a meaningful Conventional Commit message

---

## 8. "Never Do" List

- ❌ Never put business logic in widgets
- ❌ Never hard-code strings, URLs, colors, sizes, or timeouts in widgets
- ❌ Never use `BuildContext` inside Notifiers
- ❌ Never store app state in `StatefulWidget` (use Riverpod providers)
- ❌ Never use yellow (#FACC15) for anything except sun and lightning weather icons
- ❌ Never access `ref.watch()` outside of `build()` methods
- ❌ Never use `ref.read()` inside `build()` methods for state that should trigger rebuilds
- ❌ Never use `print()` — use `debugPrint()` if absolutely needed, remove before commit
- ❌ Never swallow exceptions
- ❌ Never use `dynamic`
- ❌ Never add dependencies without approval
- ❌ Never use raw `Map<String, dynamic>` in widget/presentation code — always use typed models
- ❌ Never block the main thread with synchronous heavy work
- ❌ Never use `setState()` for data that should be in providers
- ❌ Never implement a light theme

---

## 9. Design Rules

- Use **ONLY** the dark theme defined in `app_theme.dart`
- Reference color tokens by name (e.g., `AppColors.background`), never by hex value in widget files
- Yellow (`colorWeatherYellow`) is **RESERVED EXCLUSIVELY** for weather indicators: sun icon and lightning icon. It must **NEVER** be used for buttons, links, warnings, error states, or text.
- Error/warning states use `colorError` (muted red) or neutral icon + white/grey text
- All corners must be soft and rounded (use radius tokens)
- No drop shadows — use tone-based elevation only
- Radial glow gradient behind hero weather icon only

---

## 10. Async Rules

- All API calls must use `async/await`
- Use Dio's `CancelToken` for request cancellation
- Set timeouts on all Dio requests (connect: 10s, receive: 15s — Proposed)
- Never use `.then()` chains — use `async/await`
- Use `AsyncValue.guard()` for error-safe async operations in notifiers
- All notifier methods that do async work must be `Future<void>` (not `void`)

---

## 11. Riverpod-Specific Rules

- Wrap the app in `ProviderScope` in `main.dart`
- Use `ConsumerWidget` or `ConsumerStatefulWidget` (if lifecycle needed), not plain `StatelessWidget`
- Declare all providers in `providers.dart` within the feature
- Provider naming: `xyzNotifierProvider` for notifier providers
- `ref.watch(provider)` in `build()` — triggers rebuild on change
- `ref.read(provider.notifier)` in callbacks — does not trigger rebuild
- Never pass `ref` to functions outside the widget/notifier
- AsyncNotifier pattern: override `build()` for initial load, methods for mutations
- Use `.when()` or pattern matching on `AsyncValue` to handle loading/data/error

---

## 12. Conventional Commits

**Format:** `type(scope): description`

**Types and examples:**

| Commit Message | Phase |
|---|---|
| `feat(setup): scaffold project with folder structure and dark theme` | 0 |
| `feat(models): add data models, API clients, and repository` | 1 |
| `feat(mapper): add WMO weather code to icon and label mapper` | 2 |
| `feat(ui): implement search, current weather, and 5-day forecast` | 3 |
| `feat(states): add loading, error, and empty state views` | 4 |
| `feat(cache): implement offline caching with staleness indicator` | 5 |
| `feat(edge): handle edge cases and request cancellation` | 6 |
| `feat(design): polish UI with glow icon, hourly strip, and metric cards` | 7 |
| `feat(bonus): add pull-to-refresh support` | 8a |
| `feat(bonus): add metric/imperial unit toggle` | 8b |
| `feat(bonus): add search history with persistence` | 8c |
| `feat(bonus): add current location with permission handling` | 8d |
| `docs(readme): complete README with features, setup, and architecture` | 9 |

Scope is a short word identifying the area. Description is imperative, lowercase, no period.

---

## 13. Per-Phase Workflow

For **EVERY** phase:

1. Read the phase description and acceptance criteria in `Phases.md`
2. Implement all tasks listed for that phase
3. Run `flutter analyze` — fix all warnings and errors
4. Run the app on an emulator/device — verify acceptance criteria manually
5. Commit with the suggested Conventional Commit message
6. **STOP and WAIT** for user confirmation before proceeding to the next phase

> [!IMPORTANT]
> If requirements are unclear at any point: **ASK, don't assume.**
