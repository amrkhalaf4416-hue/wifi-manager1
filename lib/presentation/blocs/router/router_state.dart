part of 'router_cubit.dart';

enum RouterStatus {
  initial,
  checking,
  reachable,
  authenticating,
  authenticated,
  unauthenticated,
  unreachable,
  loading,
  error,
}

class RouterState extends Equatable {
  final RouterStatus status;
  final RouterSettingsModel settings;
  final String? errorMessage;
  
  const RouterState({
    this.status = RouterStatus.initial,
    this.settings = const RouterSettingsModel(),
    this.errorMessage,
  });
  
  bool get isAuthenticated => status == RouterStatus.authenticated;
  bool get isAuthenticating => status == RouterStatus.authenticating;
  bool get isUnauthenticated => status == RouterStatus.unauthenticated;
  bool get isUnreachable => status == RouterStatus.unreachable;
  bool get hasError => errorMessage != null;
  
  RouterState copyWith({
    RouterStatus? status,
    RouterSettingsModel? settings,
    String? errorMessage,
  }) {
    return RouterState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, settings, errorMessage];
}
