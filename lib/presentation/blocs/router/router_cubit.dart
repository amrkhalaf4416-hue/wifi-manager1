import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wifi_manager/core/network/dio_client.dart';
import 'package:wifi_manager/data/datasources/local/settings_local_datasource.dart';
import 'package:wifi_manager/data/datasources/remote/router_remote_datasource.dart';
import 'package:wifi_manager/data/models/router_settings_model.dart';

part 'router_state.dart';

class RouterCubit extends Cubit<RouterState> {
  final RouterRemoteDataSource _remoteDataSource;
  final SettingsLocalDataSource _localDataSource;
  final DioClient _dioClient;
  
  RouterCubit(
    this._remoteDataSource,
    this._localDataSource,
    this._dioClient,
  ) : super(const RouterState()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final settings = await _localDataSource.getRouterSettings();
    
    // Update DioClient with saved settings
    if (_remoteDataSource is RouterRemoteDataSourceImpl) {
      (_remoteDataSource as RouterRemoteDataSourceImpl).updateSettings(settings);
    }
    
    emit(state.copyWith(settings: settings));
    
    // Check if already logged in
    if (settings.hasValidSession) {
      await checkLoginStatus();
    }
  }
  
  Future<void> login(String username, String password) async {
    emit(state.copyWith(status: RouterStatus.authenticating));
    
    final success = await _remoteDataSource.login(username, password);
    
    if (success) {
      final newSettings = state.settings.copyWith(
        username: username,
        password: password,
        isLoggedIn: true,
        lastLoginTime: DateTime.now(),
        sessionCookie: _dioClient.sessionCookie,
      );
      
      await _localDataSource.saveRouterSettings(newSettings);
      
      // Update remote data source
      if (_remoteDataSource is RouterRemoteDataSourceImpl) {
        (_remoteDataSource as RouterRemoteDataSourceImpl).updateSettings(newSettings);
      }
      
      emit(state.copyWith(
        status: RouterStatus.authenticated,
        settings: newSettings,
      ));
    } else {
      emit(state.copyWith(
        status: RouterStatus.error,
        errorMessage: 'Invalid credentials or router not responding',
      ));
    }
  }
  
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _localDataSource.clearRouterSettings();
    
    emit(state.copyWith(
      status: RouterStatus.unauthenticated,
      settings: const RouterSettingsModel(),
    ));
  }
  
  Future<void> checkLoginStatus() async {
    emit(state.copyWith(status: RouterStatus.checking));
    
    final isLoggedIn = await _remoteDataSource.isLoggedIn();
    
    if (isLoggedIn) {
      emit(state.copyWith(status: RouterStatus.authenticated));
    } else {
      // Try to re-login if we have saved credentials
      if (state.settings.isSaveCredentials && 
          state.settings.username.isNotEmpty && 
          state.settings.password.isNotEmpty) {
        await login(state.settings.username, state.settings.password);
      } else {
        emit(state.copyWith(status: RouterStatus.unauthenticated));
      }
    }
  }
  
  Future<void> checkRouterReachable() async {
    emit(state.copyWith(status: RouterStatus.checking));
    
    final isReachable = await _remoteDataSource.isRouterReachable();
    
    if (isReachable) {
      emit(state.copyWith(status: RouterStatus.reachable));
    } else {
      emit(state.copyWith(
        status: RouterStatus.unreachable,
        errorMessage: 'Router is not reachable. Please check your connection.',
      ));
    }
  }
  
  Future<void> updateRouterIp(String ip) async {
    final newSettings = state.settings.copyWith(routerIp: ip);
    await _localDataSource.saveRouterSettings(newSettings);
    
    _dioClient.setBaseUrl(ip);
    
    if (_remoteDataSource is RouterRemoteDataSourceImpl) {
      (_remoteDataSource as RouterRemoteDataSourceImpl).updateSettings(newSettings);
    }
    
    emit(state.copyWith(settings: newSettings));
  }
  
  Future<void> updateCredentials(String username, String password) async {
    final newSettings = state.settings.copyWith(
      username: username,
      password: password,
    );
    await _localDataSource.saveRouterSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }
  
  Future<void> saveCredentials(bool save) async {
    final newSettings = state.settings.copyWith(isSaveCredentials: save);
    await _localDataSource.saveRouterSettings(newSettings);
    emit(state.copyWith(settings: newSettings));
  }
  
  Future<void> getRouterInfo() async {
    emit(state.copyWith(status: RouterStatus.loading));
    
    final info = await _remoteDataSource.getRouterInfo();
    
    if (info != null) {
      await _localDataSource.saveRouterSettings(info);
      emit(state.copyWith(
        status: RouterStatus.authenticated,
        settings: info,
      ));
    }
  }
  
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
