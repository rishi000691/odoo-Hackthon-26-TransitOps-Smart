import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transitops/core/storage/secure_storage_service.dart';

/// Values written to / read from storage.
const _kLight = 'light';
const _kDark = 'dark';

/// Simple Cubit that holds the active [ThemeMode] and persists the choice
/// across restarts via the existing [SecureStorageService].
///
/// Matches the BLoC/Cubit state-management pattern already used in
/// lib/core/ and lib/features/.
class ThemeCubit extends Cubit<ThemeMode> {
  final SecureStorageService _storage;

  ThemeCubit({required SecureStorageService storage})
    : _storage = storage,
      super(ThemeMode.system);

  /// Load the saved preference from secure storage.
  /// Falls back to [ThemeMode.system] if no preference has been saved yet.
  Future<void> loadSavedTheme() async {
    final saved = await _storage.getThemeMode();
    if (saved == _kLight) {
      emit(ThemeMode.light);
    } else if (saved == _kDark) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system); // first launch default
    }
  }

  /// Toggle between light and dark. If the current mode is [ThemeMode.system],
  /// treat it as dark (the Nile-Blue palette reads as dark) and switch to light.
  Future<void> toggle() async {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(next);
    await _storage.saveThemeMode(next == ThemeMode.light ? _kLight : _kDark);
  }
}
