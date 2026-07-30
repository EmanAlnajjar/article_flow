import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final Box<dynamic> _settingsBox;

  static const String _themeKey = 'theme_mode';

  ThemeCubit({
    required Box<dynamic> settingsBox,
  }) : _settingsBox = settingsBox,
        super(_readThemeMode(settingsBox));

  bool get isDark {
    return state == ThemeMode.dark;
  }

  Future<void> toggleTheme({
    required Brightness currentBrightness,
  }) async {
    final currentlyDark =
        state == ThemeMode.dark ||
            (state == ThemeMode.system &&
                currentBrightness == Brightness.dark);

    final newMode =
    currentlyDark
        ? ThemeMode.light
        : ThemeMode.dark;

    emit(newMode);

    await _settingsBox.put(
      _themeKey,
      newMode.name,
    );
  }

  Future<void> setThemeMode(
      ThemeMode mode,
      ) async {
    if (state == mode) {
      return;
    }

    emit(mode);

    await _settingsBox.put(
      _themeKey,
      mode.name,
    );
  }

  static ThemeMode _readThemeMode(
      Box<dynamic> box,
      ) {
    final savedMode = box.get(_themeKey);

    return switch (savedMode) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }
}