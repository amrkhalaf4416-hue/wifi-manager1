import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wifi_manager/core/constants/app_constants.dart';
import 'package:wifi_manager/core/theme/app_theme.dart';
import 'package:wifi_manager/presentation/blocs/locale/locale_cubit.dart';
import 'package:wifi_manager/presentation/blocs/theme/theme_cubit.dart';
import 'package:wifi_manager/presentation/blocs/devices/devices_cubit.dart';
import 'package:wifi_manager/presentation/blocs/router/router_cubit.dart';
import 'package:wifi_manager/presentation/pages/splash_page.dart';
import 'package:wifi_manager/core/di/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Hive
  await Hive.initFlutter();

  // تهيئة Dependency Injection (يُسجّل Hive adapters داخلياً)
  await di.init();

  // قفل الاتجاه عمودياً
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const WiFiManagerApp());
}

class WiFiManagerApp extends StatelessWidget {
  const WiFiManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<ThemeCubit>()),
            BlocProvider(create: (_) => di.sl<LocaleCubit>()),
            BlocProvider(create: (_) => di.sl<RouterCubit>()),
            BlocProvider(create: (_) => di.sl<DevicesCubit>()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, localeState) {
                  return MaterialApp(
                    title: AppConstants.appName,
                    debugShowCheckedModeBanner: false,

                    // الترجمة
                    locale: localeState.locale,
                    supportedLocales: AppConstants.supportedLocales,
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],

                    // الثيم
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeState.themeMode,

                    // دعم RTL
                    builder: (context, child) {
                      return Directionality(
                        textDirection: localeState.isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: child!,
                      );
                    },

                    home: const SplashPage(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
