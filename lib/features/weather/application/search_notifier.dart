import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/strings/app_strings.dart';
import '../domain/models/city_model.dart';
import 'providers.dart';

/// Notifier managing city search query state and results.
///
/// Implements 500ms debounce, input validation, and request cancellation.
class SearchNotifier extends AsyncNotifier<List<CityModel>> {
  CancelToken? _cancelToken;
  Timer? _debounceTimer;
  String _query = '';
  String? _validationError;

  // Unicode letter or number check (supports international scripts like München, São Paulo, 東京).
  static final RegExp _validQueryRegex = RegExp(r'[\p{L}\p{N}]', unicode: true);

  /// Current search query string.
  String get query => _query;

  /// Current inline validation error, or null if query is valid or empty.
  String? get validationError => _validationError;

  @override
  FutureOr<List<CityModel>> build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _cancelToken?.cancel('SearchNotifier disposed');
    });

    return const <CityModel>[];
  }

  /// Returns true if [q] contains at least one letter or digit.
  bool isValidCityQuery(String q) {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return false;
    return trimmed.contains(_validQueryRegex);
  }

  /// Called when the search text input changes.
  ///
  /// Applies a 500ms debounce before executing the API request.
  void onQueryChanged(String newQuery) {
    _query = newQuery;
    _debounceTimer?.cancel();
    _cancelToken?.cancel('Query changed');

    final trimmed = newQuery.trim();
    if (trimmed.isEmpty) {
      _validationError = null;
      state = const AsyncData(<CityModel>[]);
      return;
    }

    if (!isValidCityQuery(newQuery)) {
      _validationError = AppStrings.searchValidationInvalid;
      state = const AsyncData(<CityModel>[]);
      return;
    }

    _validationError = null;
    _debounceTimer = Timer(AppConstants.searchDebounceDuration, () {
      _executeSearch(newQuery);
    });
  }

  /// Immediately executes search for [q] (e.g. on keyboard action submit).
  Future<void> searchImmediate(String q) async {
    _debounceTimer?.cancel();
    _query = q;

    final trimmed = q.trim();
    if (trimmed.isEmpty) {
      _validationError = null;
      state = const AsyncData(<CityModel>[]);
      return;
    }

    if (!isValidCityQuery(q)) {
      _validationError = AppStrings.searchValidationInvalid;
      state = const AsyncData(<CityModel>[]);
      return;
    }

    _validationError = null;
    await _executeSearch(q);
  }

  Future<void> _executeSearch(String query) async {
    _cancelToken?.cancel('New search initiated');
    final cancelToken = _cancelToken = CancelToken();

    state = const AsyncLoading();

    final nextState = await AsyncValue.guard(() async {
      final repository = ref.read(weatherRepositoryProvider);
      return await repository.searchCities(query.trim(), cancelToken: cancelToken);
    });

    if (cancelToken.isCancelled) return;

    state = nextState;
  }

  /// Clears query, validation errors, and search results.
  void clear() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel('Search cleared');
    _query = '';
    _validationError = null;
    state = const AsyncData(<CityModel>[]);
  }
}

