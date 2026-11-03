AI INSTRUCTION: Read ALL project docs (PRD, Architecture, Design, Rules, Phases) before writing any code.

# ClimateScope — Design System

---

## 1. Color Tokens

| Token Name | Hex | Usage | Status |
|---|---|---|---|
| `colorBackground` | `#1E1E1E` | Root scaffold background, app canvas | Given |
| `colorSurface` | `#2A2A2E` | Metric cards, forecast container, bottom sheet | Proposed |
| `colorSurfaceVariant` | `#333338` | Hourly slot (default), search field fill | Proposed |
| `colorTextPrimary` | `#FFFFFF` | Primary data (temperature, city name, headings) | Given |
| `colorTextSecondary` | `#9E9EA8` | Secondary labels, descriptions, units, timestamps | Proposed |
| `colorAccentBlue` | `#3B82F6` | Selected hourly slot, water indicators, active UI elements | Proposed |
| `colorWeatherYellow` | `#FACC15` | **EXCLUSIVELY** sun icon and lightning icon tints | Proposed |
| `colorWeatherWhite` | `#E2E2E8` | Cloud, fog, and snow icon tints | Proposed |
| `colorWeatherBlue` | `#60A5FA` | Rain and drizzle icon tints | Proposed |
| `colorError` | `#EF4444` | Error state icon tint (muted red treatment) | Proposed |
| `colorOfflineBanner` | `#3B3B40` | Offline/staleness banner background | Proposed |
| `colorDivider` | `#3B3B40` | Subtle dividers between forecast rows | Proposed |

> [!WARNING]
> `colorWeatherYellow` (`#FACC15`) must **NEVER** be used for buttons, links, warnings, error states, or text. It is reserved **exclusively** for weather indicators: sun and lightning icons.

---

## 2. WCAG Contrast Checks

Contrast ratios calculated using the WCAG 2.1 relative luminance formula.

**Methodology:** Relative luminance L = 0.2126×R + 0.7152×G + 0.0722×B (after sRGB linearization). Contrast ratio = (L_lighter + 0.05) / (L_darker + 0.05).

| # | Foreground | Background | Contrast Ratio | AA Normal (≥4.5:1) | AA Large (≥3:1) | Result |
|---|---|---|---|---|---|---|
| 1 | `#FFFFFF` (1.0) | `#1E1E1E` (0.033) | **15.4:1** | ✅ Pass | ✅ Pass | Excellent |
| 2 | `#9E9EA8` (0.346) | `#1E1E1E` (0.033) | **4.8:1** | ✅ Pass | ✅ Pass | Passes AA normal — but marginal |
| 3 | `#FFFFFF` (1.0) | `#2A2A2E` (0.046) | **12.9:1** | ✅ Pass | ✅ Pass | Excellent |
| 4 | `#9E9EA8` (0.346) | `#2A2A2E` (0.046) | **4.1:1** | ❌ Fail | ✅ Pass | **See recommendation below** |
| 5 | `#FFFFFF` (1.0) | `#333338` (0.061) | **10.9:1** | ✅ Pass | ✅ Pass | Excellent |
| 6 | `#3B82F6` (0.216) | `#1E1E1E` (0.033) | **3.2:1** | ❌ Fail | ✅ Pass | Large/bold text only |
| 7 | `#3B82F6` (0.216) | `#333338` (0.061) | **2.4:1** | ❌ Fail | ❌ Fail | **Decorative/icon use only** |
| 8 | `#FACC15` (0.679) | `#1E1E1E` (0.033) | **8.8:1** | ✅ Pass | ✅ Pass | Icon only (decorative) |
| 9 | `#EF4444` (0.178) | `#1E1E1E` (0.033) | **2.7:1** | ❌ Fail | ❌ Fail | **Icon only + paired with text** |

### Contrast Recommendations

> [!IMPORTANT]
> **Row 4 — `#9E9EA8` on `#2A2A2E` (4.1:1):** Fails AA for normal text. **Mandate:** Secondary text inside `colorSurface` cards must use **Medium weight (500) or heavier**, or **size ≥ 16sp** (qualifies as large text at 3:1). At Caption size (12sp) with Regular weight, this pair fails — use `colorTextPrimary` instead, or lighten the secondary color to `#B0B0BA` (Proposed fallback: ~5.0:1).

> [!NOTE]
> **Row 6 — `#3B82F6` as text on dark backgrounds:** Only passes at large text (≥ 18sp or ≥ 14sp bold). This color is used primarily for the selected hourly slot **background** (white text on blue) and for **icon tints**, not as body text, so this is acceptable.

> [!NOTE]
> **Row 9 — `#EF4444` on dark background:** Used exclusively as an **icon tint** paired with white/grey text labels. The error message text itself is always `colorTextPrimary` (white), which passes at 15.4:1. The red icon is supplementary, not the sole information carrier.

---

## 3. Typography Scale

**Typeface:** Inter (Proposed). Bundled as asset files in `assets/fonts/`. Not downloaded at runtime.
**Fallback:** System sans-serif (Roboto on Android, SF Pro on iOS) if Inter fails to load.

| Role | Font Weight | Size (sp) | Line Height | Letter Spacing | Usage | Status |
|---|---|---|---|---|---|---|
| `heroTemperature` | Bold (700) | 72 | 1.0 | -2.0 | Main temperature display, focal point | Proposed |
| `heroCondition` | Regular (400) | 18 | 1.4 | 0.0 | Condition text below temperature | Proposed |
| `headerCity` | SemiBold (600) | 22 | 1.3 | 0.0 | City name in header (tappable) | Proposed |
| `headerTime` | Regular (400) | 14 | 1.4 | 0.2 | Date and time in header | Proposed |
| `sectionTitle` | SemiBold (600) | 16 | 1.3 | 0.5 | "5 days", "Today", section headers | Proposed |
| `body` | Regular (400) | 16 | 1.5 | 0.0 | General text, messages | Proposed |
| `label` | Medium (500) | 14 | 1.4 | 0.2 | Metric labels ("Wind", "Humidity") | Proposed |
| `metricValue` | SemiBold (600) | 20 | 1.2 | 0.0 | Wind speed, humidity values | Proposed |
| `caption` | Regular (400) | 12 | 1.4 | 0.3 | Units, timestamps, secondary info | Proposed |
| `hourlyTemp` | Medium (500) | 14 | 1.2 | 0.0 | Temperature in hourly slot | Proposed |
| `hourlyTime` | Regular (400) | 12 | 1.2 | 0.2 | Time label in hourly slot | Proposed |
| `forecastDay` | Medium (500) | 16 | 1.4 | 0.0 | Day name in 5-day list | Proposed |
| `forecastTemp` | Regular (400) | 16 | 1.4 | 0.0 | Min/max temperatures in 5-day list | Proposed |

> [!TIP]
> All `TextStyle` definitions live in `app_typography.dart`. Widgets reference them as `AppTypography.heroTemperature`, never inline.

---

## 4. Spacing & Corner Radius Scales

### Spacing Scale (Proposed)

| Token | Value (dp) | Usage |
|---|---|---|
| `spaceXs` | 4 | Internal padding, tiny gaps between icon and text |
| `spaceSm` | 8 | Between closely related elements |
| `spaceMd` | 12 | Card internal padding (smaller cards) |
| `spaceLg` | 16 | Section gaps, standard card padding |
| `spaceXl` | 24 | Between major sections, screen horizontal padding |
| `spaceXxl` | 32 | Hero section vertical spacing |

### Corner Radius Scale (Proposed)

All elements use **soft, rounded corners** — no sharp edges anywhere.

| Token | Value (dp) | Usage |
|---|---|---|
| `radiusSm` | 8 | Hourly slots, small chips |
| `radiusMd` | 12 | Search field, search result tiles |
| `radiusLg` | 16 | Metric cards, forecast container, general cards |
| `radiusXl` | 24 | Bottom sheet top corners |
| `radiusFull` | 999 | Pill shapes (if used) |

### Elevation Approach

- **No drop shadows** anywhere in the app.
- Depth is achieved through **tone-based contrast**: lighter surface colors (`colorSurface`, `colorSurfaceVariant`) layered on the darker background (`colorBackground`).
- The **only visual depth effect** beyond tone is the radial glow gradient behind the hero weather icon (see Section 5).

---

## 5. Radial Glow Specification (Icon Backlight)

The primary weather icon sits within a soft glowing radial gradient that acts as a backlight, adding depth and approximating 3D icon effects.

### Container Specification (Proposed)

| Property | Value |
|---|---|
| Container size | 160 × 160 logical pixels |
| Icon size | 80 logical pixels |
| Gradient type | `RadialGradient` |
| Gradient center | `Alignment.center` |
| Gradient radius | 0.5 (half the container) |
| Gradient stops | `[0.0, 1.0]` |
| Edge color | `Colors.transparent` (always) |

### Glow Colors by Condition Group (Proposed)

| Condition Group | WMO Codes | Center Color | Opacity | Icon |
|---|---|---|---|---|
| Clear Sky | 0 | `#FACC15` | 0.20 | `Icons.wb_sunny_rounded` |
| Mainly Clear | 1 | `#FACC15` | 0.15 | `Icons.wb_sunny_rounded` |
| Partly Cloudy / Overcast | 2, 3 | `#9E9EA8` | 0.12 | `Icons.cloud_rounded` |
| Fog / Rime Fog | 45, 48 | `#9E9EA8` | 0.15 | `Icons.cloud_rounded` |
| Drizzle | 51, 53, 55 | `#60A5FA` | 0.15 | `Icons.grain_rounded` |
| Rain | 61, 63, 65 | `#3B82F6` | 0.18 | `Icons.water_drop_rounded` |
| Snow | 71, 73, 75 | `#E2E2E8` | 0.12 | `Icons.ac_unit_rounded` |
| Rain Showers | 80, 81, 82 | `#3B82F6` | 0.18 | `Icons.water_drop_rounded` |
| Thunderstorm | 95 | `#FACC15` | 0.20 | `Icons.thunderstorm_rounded` |
| Thunderstorm + Hail | 96, 99 | `#FACC15` | 0.20 | `Icons.thunderstorm_rounded` |
| Unknown | other | `#9E9EA8` | 0.10 | `Icons.help_outline_rounded` |

### Implementation Notes

- Use `Container` with `BoxDecoration(gradient: RadialGradient(...))` — no `CustomPainter` needed.
- The gradient's natural falloff from center to edge provides sufficient softness. No explicit `BackdropFilter` or blur required.
- The glow is **static** (not animated) by default. An optional subtle pulse animation is out of scope.

---

## 6. Icon Mapping Table

All mappings live in a single file: `weather_code_mapper.dart`.

| WMO Code(s) | Condition Text | Material Icon | Icon Tint Token | Color Rule |
|---|---|---|---|---|
| 0 | Clear Sky | `Icons.wb_sunny_rounded` | `colorWeatherYellow` | Yellow — sun only |
| 1 | Mainly Clear | `Icons.wb_sunny_rounded` | `colorWeatherYellow` | Yellow — sun only |
| 2 | Partly Cloudy | `Icons.cloud_rounded` | `colorWeatherWhite` | White for clouds |
| 3 | Overcast | `Icons.cloud_rounded` | `colorWeatherWhite` | White for clouds |
| 45 | Fog | `Icons.cloud_rounded` | `colorWeatherWhite` | White/grey for fog |
| 48 | Rime Fog | `Icons.cloud_rounded` | `colorWeatherWhite` | White/grey for fog |
| 51 | Light Drizzle | `Icons.grain_rounded` | `colorWeatherBlue` | Blue for water |
| 53 | Moderate Drizzle | `Icons.grain_rounded` | `colorWeatherBlue` | Blue for water |
| 55 | Dense Drizzle | `Icons.grain_rounded` | `colorWeatherBlue` | Blue for water |
| 61 | Slight Rain | `Icons.water_drop_rounded` | `colorWeatherBlue` | Blue for rain |
| 63 | Moderate Rain | `Icons.water_drop_rounded` | `colorWeatherBlue` | Blue for rain |
| 65 | Heavy Rain | `Icons.water_drop_rounded` | `colorWeatherBlue` | Blue for rain |
| 71 | Slight Snow | `Icons.ac_unit_rounded` | `colorWeatherWhite` | White for snow |
| 73 | Moderate Snow | `Icons.ac_unit_rounded` | `colorWeatherWhite` | White for snow |
| 75 | Heavy Snow | `Icons.ac_unit_rounded` | `colorWeatherWhite` | White for snow |
| 80 | Slight Showers | `Icons.water_drop_rounded` | `colorWeatherBlue` | Blue for rain |
| 81 | Moderate Showers | `Icons.water_drop_rounded` | `colorWeatherBlue` | Blue for rain |
| 82 | Violent Showers | `Icons.water_drop_rounded` | `colorWeatherBlue` | Blue for rain |
| 95 | Thunderstorm | `Icons.thunderstorm_rounded` | `colorWeatherYellow` | Yellow — lightning only |
| 96 | Thunderstorm + Slight Hail | `Icons.thunderstorm_rounded` | `colorWeatherYellow` | Yellow — lightning only |
| 99 | Thunderstorm + Heavy Hail | `Icons.thunderstorm_rounded` | `colorWeatherYellow` | Yellow — lightning only |
| **Other** | **Unknown** | `Icons.help_outline_rounded` | `colorTextSecondary` | Grey fallback |

> [!IMPORTANT]
> The mapper returns a data class/record containing `conditionText` (String), `icon` (IconData), and `tintColor` (Color). This is the single source of truth for all weather-code-to-visual mappings in the app.

---

## 7. Component Specifications

### 7.1 Header

| Property | Value |
|---|---|
| Width | Full screen width |
| Horizontal padding | `spaceXl` (24) |
| Vertical padding | `spaceLg` (16) top, `spaceSm` (8) bottom |
| Background | Transparent (sits on `colorBackground`) |

**Left side:**
- City name: `headerCity` style, `colorTextPrimary`, tappable (opens search sheet)
- Trailing chevron icon: `Icons.keyboard_arrow_down_rounded`, `colorTextSecondary`, 20px

**Right side or below city:**
- Date and time: `headerTime` style, `colorTextSecondary`
- Format: `"Monday, Nov 3"` (Proposed) using city-local timezone
- When showing cached data: `"Last updated: 2:30 PM"` (Proposed format)

### 7.2 Hero Section

| Property | Value |
|---|---|
| Alignment | Centered horizontally |
| Top padding | `spaceXxl` (32) |
| Bottom padding | `spaceXl` (24) |

**Content (top to bottom):**
1. Weather icon with glow: 160×160 container (see Section 5), icon 80px with condition-appropriate tint
2. Temperature: `heroTemperature` style, `colorTextPrimary`, centered. Show unit (e.g., `"23°C"`)
3. Condition text: `heroCondition` style, `colorTextSecondary`, centered (e.g., `"Partly Cloudy"`)

### 7.3 Hourly Strip

| Property | Value |
|---|---|
| Section title | "Today" (`sectionTitle` style), left-aligned, padding `spaceXl` horizontal |
| Scroll direction | Horizontal (`ListView.builder`) |
| Horizontal padding | `spaceXl` (24) leading, then `spaceSm` (8) between slots |
| Slot width | 64 logical pixels (Proposed) |

**Each Slot (`HourlySlot`):**

| Property | Default State | Selected State |
|---|---|---|
| Background | `colorSurfaceVariant` | `colorAccentBlue` |
| Corner radius | `radiusSm` (8) | `radiusSm` (8) |
| Vertical padding | `spaceSm` (8) top and bottom | Same |
| Horizontal padding | `spaceXs` (4) | Same |
| Time text | `hourlyTime` style, `colorTextSecondary` | `hourlyTime` style, `colorTextPrimary` |
| Icon | 24px, condition tint | 24px, `colorTextPrimary` |
| Temperature | `hourlyTemp` style, `colorTextPrimary` | `hourlyTemp` style, `colorTextPrimary` |

- Default selected slot: current hour in city timezone.
- **Open Question:** Tapping a slot only changes the selection highlight (visual feedback only). Default behavior — no data update on tap.
- Content stacks vertically: time → icon → temperature.

### 7.4 Metric Cards

**Row layout:**
- 2 cards side by side, gap `spaceMd` (12)
- Horizontal padding `spaceXl` (24)
- Vertical margin `spaceLg` (16) top

**Each Card:**

| Property | Value |
|---|---|
| Background | `colorSurface` |
| Corner radius | `radiusLg` (16) |
| Padding | `spaceLg` (16) all sides |
| Flex | `Expanded` (equal width) |

**Wind Card content:**
- Icon: `Icons.air_rounded`, 24px, `colorTextSecondary`
- Label: "Wind" (`label` style, `colorTextSecondary`)
- Value: `"{speed} km/h"` (`metricValue` style, `colorTextPrimary`)

**Humidity Card content:**
- Icon: `Icons.water_drop_rounded`, 24px, `colorAccentBlue` (this is the "blue water indicator")
- Label: "Humidity" (`label` style, `colorTextSecondary`)
- Value: `"{value}%"` (`metricValue` style, `colorTextPrimary`)

### 7.5 5-Day Forecast List

| Property | Value |
|---|---|
| Section title | "5 days" (`sectionTitle` style), left-aligned |
| Container background | `colorSurface` |
| Container radius | `radiusLg` (16) |
| Container padding | `spaceLg` (16) |
| Horizontal margin | `spaceXl` (24) |
| Top margin | `spaceLg` (16) |
| Bottom margin | `spaceXxl` (32) — bottom of scroll |

**Each Row (`DailyForecastRow`):**

| Element | Style | Color | Position |
|---|---|---|---|
| Day name | `forecastDay` | `colorTextPrimary` | Left |
| Weather icon | 24px | Condition tint (from mapper) | Center-left |
| Min temp | `forecastTemp` | `colorTextSecondary` | Center-right |
| Max temp | `forecastTemp` | `colorTextPrimary` | Right |

- Rows separated by `Divider` with color `colorDivider` and thickness 0.5 (Proposed).
- Last row has no divider.
- Day name format: `"Mon"`, `"Tue"`, etc. (short weekday). Today's row shows `"Today"`.

### 7.6 Search Bottom Sheet

| Property | Value |
|---|---|
| Type | Modal bottom sheet (`showModalBottomSheet`) |
| Background | `colorBackground` |
| Top corners | `radiusXl` (24) |
| `isScrollControlled` | `true` |
| `useSafeArea` | `true` |
| Max height | 85% of screen (Proposed) |

**Drag handle:**
- Width: 40, Height: 4, `colorDivider`, `radiusFull`, centered, top margin `spaceSm` (8)

**Search Field (`SearchField`):**

| Property | Value |
|---|---|
| Fill color | `colorSurfaceVariant` |
| Corner radius | `radiusMd` (12) |
| Horizontal margin | `spaceLg` (16) |
| Prefix icon | `Icons.search_rounded`, `colorTextSecondary` |
| Suffix icon | Clear button (`Icons.close_rounded`), shown when text is not empty |
| Placeholder | "Search for a city…" (`body` style, `colorTextSecondary`) |
| Text style | `body` style, `colorTextPrimary` |
| Keyboard type | `TextInputType.text` |
| Text input action | `TextInputAction.search` |
| Autofocus | `true` |

**Results List:**
- Each tile (`SearchResultTile`):
  - City name: `body` style, `colorTextPrimary`
  - Subtitle: `"admin1, country"` (`caption` style, `colorTextSecondary`)
  - Vertical padding: `spaceMd` (12)
  - Tappable: selects city, closes sheet
  - Divider between tiles: `colorDivider`

**Sheet States:**
- **Empty results:** "No cities found" centered (`body` style, `colorTextSecondary`)
- **Loading:** `CircularProgressIndicator` centered, `colorAccentBlue`
- **Error:** Error icon + message (`body` style, `colorTextPrimary`)
- **Recent searches (bonus):** Shown when input is empty. Section title "Recent" with "Clear all" text button (`label` style, `colorAccentBlue`). Each entry styled like a result tile.

### 7.7 State Views

#### Loading State

| Property | Value |
|---|---|
| Layout | Centered in available space |
| Indicator | `CircularProgressIndicator`, `colorAccentBlue` |
| Size | Default (36px) |

#### Empty State (First Launch)

| Property | Value |
|---|---|
| Layout | Centered vertically and horizontally |
| Icon | `Icons.search_rounded`, 64px, `colorTextSecondary` |
| Text | "Search for a city to see its weather" |
| Text style | `body`, `colorTextSecondary` |
| Spacing | `spaceLg` (16) between icon and text |

#### Error State

| Property | Value |
|---|---|
| Layout | Centered vertically and horizontally |
| Icon | `Icons.error_outline_rounded`, 64px, `colorError` |
| Message | Friendly text from `app_strings.dart` |
| Message style | `body`, `colorTextPrimary` |
| Retry button | Outlined button, `colorAccentBlue` border, `colorAccentBlue` text, `radiusMd` (12) |
| Spacing | `spaceLg` (16) between elements |

#### Offline Banner

| Property | Value |
|---|---|
| Position | Top of scrollable content, above hero |
| Background | `colorOfflineBanner` |
| Width | Full width |
| Padding | `spaceSm` (8) vertical, `spaceLg` (16) horizontal |
| Corner radius | None (full-bleed banner) |
| Icon | `Icons.cloud_off_rounded`, 16px, `colorTextSecondary` |
| Text | "Data may be outdated • Last updated: {time}" |
| Text style | `caption`, `colorTextSecondary` |

---

## 8. System UI Styling

| Element | Configuration |
|---|---|
| Status bar color | Transparent |
| Status bar icon brightness | `Brightness.light` (white icons) |
| Navigation bar color | `#1E1E1E` (`colorBackground`) |
| Navigation bar icon brightness | `Brightness.light` (white icons) |

**Implementation:** Set via `SystemUiOverlayStyle.light` in `AppTheme` using:
- `appBarTheme.systemOverlayStyle`
- `ThemeData.scaffoldBackgroundColor`
- Explicit `SystemChrome.setSystemUIOverlayStyle` in `main.dart` if needed.

---

## 9. Animation Guidelines

### Animation Specifications (Proposed)

| Animation | Duration | Curve | Implementation | Notes |
|---|---|---|---|---|
| State transitions (loading ↔ data ↔ error) | 300ms | `Curves.easeInOut` | `AnimatedSwitcher` or `AnimatedCrossFade` | Smooth crossfade between states |
| Bottom sheet open/close | 300ms | `Curves.easeOutCubic` | Flutter default `showModalBottomSheet` | Use framework default |
| Hourly slot selection | 200ms | `Curves.easeOut` | `AnimatedContainer` for background color | Color transition on tap |
| Radial glow | — | — | Static `RadialGradient` | No animation. Static gradient only. |
| Pull-to-refresh | Default | Default | `RefreshIndicator` built-in | Framework handles animation |
| Page scroll | — | — | Standard `ListView` physics | `BouncingScrollPhysics` on iOS, `ClampingScrollPhysics` on Android |

### Reduced Motion Behavior

- Check `MediaQuery.disableAnimations` or `MediaQueryData.boldText` as accessibility proxy.
- When reduced motion is preferred: set all custom animation durations to `Duration.zero` (instant transitions).
- The radial glow gradient is already static and unaffected.
- Framework animations (`showModalBottomSheet`, `RefreshIndicator`) respect platform accessibility settings automatically.

### Performance Constraints

| Guideline | Reason |
|---|---|
| **No `Opacity` widget** for large areas | Triggers `saveLayer`, causing jank. Use `FadeTransition` or `AnimatedOpacity` instead. |
| **`ListView.builder`** for hourly strip | Lazy builds visible items only. Never use a `Row` with all ~24 children pre-built. |
| **No `CustomPainter`** for the glow | `Container` with `BoxDecoration(gradient: RadialGradient(...))` is sufficient and cheaper. |
| **Avoid `ClipRRect`** on large areas | Clipping can be expensive. Use `Container` with `borderRadius` in `BoxDecoration` instead. |
| **`const` widgets** wherever possible | Prevents unnecessary rebuilds. |

---

## 10. Accessibility

### Tap Targets

- All interactive elements must be at least **48 × 48 logical pixels** (Material default minimum).
- Hourly slots at 64px width satisfy this. Vertical height must also be ≥ 48px.
- Search result tiles with 12px vertical padding + text content comfortably exceed 48px.
- The header city name tap target should use `InkWell` with `padding` to ensure ≥ 48px.

### Text Scaling

- All text sizes use `sp` units (Flutter default behavior with `fontSize` in `TextStyle`).
- Respect `MediaQuery.textScaleFactor` — do not override it.
- **Hero temperature (72sp):** At 2× scale (144sp), may overflow horizontally. Wrap in `FittedBox` with `BoxFit.scaleDown` to prevent overflow while respecting the user's scaling intent.
- If `auto_size_text` package is considered for overflow prevention, it must be justified and approved per library policy.

### Semantics Labels

Every weather icon **must** have a semantic label for screen readers:

```dart
Icon(
  Icons.wb_sunny_rounded,
  semanticLabel: 'Clear Sky',  // from weather_code_mapper
  color: AppColors.weatherYellow,
  size: 80,
)
```

The `semanticLabel` value comes from the `conditionText` field of the weather code mapper, ensuring consistency between visual and auditory representation.

### Color Independence

- Information is **never** conveyed by color alone.
- Every colored indicator has an accompanying text label:
  - Weather icons → condition text shown below/beside
  - Humidity blue icon → "Humidity" label text
  - Error red icon → error message text
  - Offline banner → text description
- Selected hourly slot: blue background is accompanied by the slot's position in the list and its content, which is sufficient for screen readers.

### Focus Order

- Logical top-to-bottom reading order matching visual layout.
- Search sheet: search field receives focus first (autofocus), then results list.
- `Semantics` widget wraps compound components where needed to provide meaningful grouping.

### State Change Announcements

- When weather data loads successfully, the UI rebuild naturally updates the semantics tree.
- For explicit announcements, use `SemanticsService.announce(message, TextDirection.ltr)` on significant state changes (e.g., "Weather loaded for London" after a successful fetch).
- Error states include the error message in the semantics tree via text content — no additional announcement needed.

