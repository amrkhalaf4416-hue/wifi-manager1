import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wifi_manager/data/datasources/local/settings_local_datasource.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SettingsLocalDataSource _localDataSource;

  ThemeCubit(this._localDataSource) : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedMode = await _localDataSource.getThemeMode();
    final flutterMode = _toFlutterThemeMode(savedMode);
    if (!isClosed) emit(ThemeState(themeMode: flutterMode));
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _localDataSource.setThemeMode(_fromFlutterThemeMode(mode));
    if (!isClosed) emit(ThemeState(themeMode: mode));
  }

  ThemeMode _toFlutterThemeMode(ThemeMode mode) => mode;

  ThemeMode _fromFlutterThemeMode(ThemeMode mode) => mode;
}
