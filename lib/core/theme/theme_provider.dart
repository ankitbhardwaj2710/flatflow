import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();

    switch (mode) {
      case ThemeMode.dark:
        await prefs.setString(_themeKey, 'dark');
        break;

      case ThemeMode.light:
        await prefs.setString(_themeKey, 'light');
        break;

      case ThemeMode.system:
        await prefs.setString(_themeKey, 'system');
        break;
    }
  }

  Future<void> toggleDarkMode() async {
    final newMode =
        state == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark;

    await setTheme(newMode);
  }
}