import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../providers/repository_providers.dart';

/// Estado del tema
enum ThemeModeOption {
  light,
  dark,
  system,
}

/// Notifier del tema
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Cargar tema guardado
  Future<void> _loadTheme() async {
    final themeString = _prefs.getString(AppConstants.prefThemeMode) ?? 'system';
    state = _themeModeFromString(themeString);
  }

  /// Cambiar tema
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(AppConstants.prefThemeMode, _themeModeToString(mode));
  }

  /// Convertir string a ThemeMode
  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Convertir ThemeMode a string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}

/// Provider del tema
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
