import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../application/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';
import 'search_field.dart';
import 'search_result_tile.dart';

/// Modal bottom sheet allowing users to search and select cities.
class SearchBottomSheet extends ConsumerStatefulWidget {
  const SearchBottomSheet({super.key});

  /// Displays the search modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      builder: (context) => const SearchBottomSheet(),
    );
  }

  @override
  ConsumerState<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends ConsumerState<SearchBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Restore existing query from notifier so state survives sheet recreation
    final existingQuery = ref.read(searchNotifierProvider.notifier).query;
    _controller = TextEditingController(text: existingQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);
    final validationError = notifier.validationError;
    final currentQuery = notifier.query;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.85,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle affordance
          Center(
            child: Container(
              margin: const EdgeInsets.only(
                top: AppDimensions.spaceSm,
                bottom: AppDimensions.spaceMd,
              ),
              width: AppDimensions.dragHandleWidth,
              height: AppDimensions.dragHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.colorDivider,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
          ),
          // Search input field
          SearchField(
            controller: _controller,
            errorText: validationError,
            onChanged: (val) {
              setState(() {});
              ref.read(searchNotifierProvider.notifier).onQueryChanged(val);
            },
            onSubmitted: (val) {
              ref.read(searchNotifierProvider.notifier).searchImmediate(val);
            },
            onClear: () {
              _controller.clear();
              setState(() {});
              ref.read(searchNotifierProvider.notifier).clear();
            },
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          // Results list or state indicator
          Flexible(
            child: searchAsync.when(
              loading: () => const LoadingState(),
              error: (error, _) => ErrorState(
                failure: error,
                onRetry: () {
                  final query = _controller.text;
                  if (query.trim().isNotEmpty) {
                    ref
                        .read(searchNotifierProvider.notifier)
                        .searchImmediate(query);
                  }
                },
              ),
              data: (cities) {
                if (validationError != null) {
                  return const SizedBox.shrink();
                }

                if (cities.isEmpty && currentQuery.trim().isNotEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    message: AppStrings.noResultsFoundFor(currentQuery.trim()),
                  );
                }

                if (cities.isEmpty) {
                  return const SizedBox.shrink();
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.spaceLg,
                  ),
                  itemCount: cities.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: AppColors.colorDivider,
                    height: 1,
                    thickness: 0.5,
                  ),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return SearchResultTile(
                      city: city,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).pop();
                        ref
                            .read(weatherNotifierProvider.notifier)
                            .fetchWeather(city);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

