import 'package:flutter/material.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Text input field for city searches with clear button and inline validation.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.onSubmitted,
    this.errorText,
    this.autofocus = true,
  });

  /// Text editing controller for the search input.
  final TextEditingController controller;

  /// Callback when user changes the input text.
  final ValueChanged<String> onChanged;

  /// Callback when user taps the clear button.
  final VoidCallback onClear;

  /// Callback when user submits via the keyboard search action.
  final ValueChanged<String>? onSubmitted;

  /// Inline validation error message, or null if input is valid.
  final String? errorText;

  /// Whether the field should autofocus when displayed.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.colorSurfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: errorText != null
                      ? Border.all(color: AppColors.colorError, width: 1.0)
                      : null,
                ),
                child: TextField(
                  controller: controller,
                  autofocus: autofocus,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  cursorColor: AppColors.colorAccentBlue,
                  style: AppTypography.body,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchHint,
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.colorTextSecondary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.colorTextSecondary,
                    ),
                    suffixIcon: hasText
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.colorTextSecondary,
                            ),
                            onPressed: onClear,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceLg,
                      vertical: AppDimensions.spaceMd,
                    ),
                  ),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: AppDimensions.spaceXs),
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.spaceSm,
                  ),
                  child: Text(
                    errorText!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.colorError,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

