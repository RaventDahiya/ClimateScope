/// Design system spacing, radius, and dimension constants for ClimateScope.
abstract final class AppDimensions {
  // Spacing Scale
  /// 4.0 dp: Internal padding, tiny gaps between icon and text.
  static const double spaceXs = 4.0;

  /// 8.0 dp: Spacing between closely related elements.
  static const double spaceSm = 8.0;

  /// 12.0 dp: Card internal padding (smaller cards).
  static const double spaceMd = 12.0;

  /// 16.0 dp: Section gaps, standard card padding.
  static const double spaceLg = 16.0;

  /// 24.0 dp: Spacing between major sections, screen horizontal padding.
  static const double spaceXl = 24.0;

  /// 32.0 dp: Hero section vertical spacing.
  static const double spaceXxl = 32.0;

  // Corner Radius Scale
  /// 8.0 dp: Hourly slots, small chips.
  static const double radiusSm = 8.0;

  /// 12.0 dp: Search field, search result tiles.
  static const double radiusMd = 12.0;

  /// 16.0 dp: Metric cards, forecast container, general cards.
  static const double radiusLg = 16.0;

  /// 24.0 dp: Bottom sheet top corners.
  static const double radiusXl = 24.0;

  /// 999.0 dp: Full circle / pill shapes.
  static const double radiusFull = 999.0;

  // Component Dimensions
  /// 160.0 dp: Hero weather icon glow container size (width & height).
  static const double heroIconContainerSize = 160.0;

  /// 80.0 dp: Hero weather icon glyph size.
  static const double heroIconSize = 80.0;

  /// 64.0 dp: Standard hourly slot item width.
  static const double hourlySlotWidth = 64.0;

  /// 24.0 dp: Standard small weather icon size (hourly slot, daily row).
  static const double weatherIconSmall = 24.0;

  /// 40.0 dp: Modal bottom sheet drag handle width.
  static const double dragHandleWidth = 40.0;

  /// 4.0 dp: Modal bottom sheet drag handle height.
  static const double dragHandleHeight = 4.0;

  /// 48.0 dp: Minimum accessible interactive tap target size.
  static const double minTapTargetSize = 48.0;
}

