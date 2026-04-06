import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wifi_manager/data/datasources/local/settings_local_datasource.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  final SettingsLocalDataSource _localDataSource;

  LocaleCubit(this._localDataSource) : super(const LocaleState()) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final lang = await _localDataSource.getLocale();
    if (!isClosed) emit(LocaleState(locale: Locale(lang)));
  }

  Future<void> setLocale(String languageCode) async {
    await _localDataSource.setLocale(languageCode);
    if (!isClosed) emit(LocaleState(locale: Locale(languageCode)));
  }
}
