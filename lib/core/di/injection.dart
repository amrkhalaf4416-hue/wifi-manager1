import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_manager/core/network/dio_client.dart';
import 'package:wifi_manager/data/datasources/local/mac_oui_service.dart';
import 'package:wifi_manager/data/datasources/local/settings_local_datasource.dart';
import 'package:wifi_manager/data/datasources/remote/router_remote_datasource.dart';
import 'package:wifi_manager/data/models/device_model.dart';
import 'package:wifi_manager/data/models/router_settings_model.dart';
import 'package:wifi_manager/data/repositories/device_repository_impl.dart';
import 'package:wifi_manager/domain/repositories/device_repository.dart';
import 'package:wifi_manager/presentation/blocs/devices/devices_cubit.dart';
import 'package:wifi_manager/presentation/blocs/locale/locale_cubit.dart';
import 'package:wifi_manager/presentation/blocs/router/router_cubit.dart';
import 'package:wifi_manager/presentation/blocs/theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Hive Adapters (يجب تسجيلها قبل فتح أي Box) ──
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(DeviceModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(RouterSettingsModelAdapter());
  }

  // ── External Dependencies ──
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => DioClient());

  // ── Services ──
  sl.registerLazySingleton(() => MacOuiService());

  // ── Data Sources ──
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<RouterRemoteDataSource>(
    () => RouterRemoteDataSourceImpl(sl()),
  );

  // ── Repositories ──
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(sl(), sl(), sl()),
  );

  // ── BLoCs (Factory: جديد لكل صفحة) ──
  sl.registerFactory(() => ThemeCubit(sl()));
  sl.registerFactory(() => LocaleCubit(sl()));
  sl.registerFactory(() => DevicesCubit(sl()));
  sl.registerFactory(() => RouterCubit(sl(), sl(), sl()));
}
