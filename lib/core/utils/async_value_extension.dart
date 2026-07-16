import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/auth_service.dart';

/// Extension methods for AsyncValue to simplify UI logic
/// NOTE: Using unique names (ui*) to avoid colliding with Riverpod's built-in
/// AsyncValue extensions (which also define helpers like `isLoading`/`hasError`).
extension AsyncValueUiExt<T> on AsyncValue<T> {
  /// Check if loading
  bool get uiIsLoading => this is AsyncLoading;

  /// Check if has error
  bool get uiHasError => this is AsyncError;

  /// Get error message if exists
  String? get uiErrorMessage {
    return maybeWhen(
      error: (error, stackTrace) {
        if (error is AuthException) {
          return error.message;
        }
        return error.toString();
      },
      orElse: () => null,
    );
  }

  /// Check if has data
  bool get uiHasData => this is AsyncData;

  /// Safely get data
  T? get uiDataOrNull {
    return maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
  }
}


