part of 'locale_cubit.dart';

class LocaleState {
  final Locale locale;
  const LocaleState({this.locale = const Locale('ar')});

  bool get isRtl => locale.languageCode == 'ar';
}
