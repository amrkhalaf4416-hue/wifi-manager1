import 'dart:async';
import 'package:dio/dio.dart';
import 'package:wifi_manager/core/constants/app_constants.dart';

/// [DioClient] — HTTP client مُحسَّن مع:
/// - Retry logic تلقائي
/// - Cookie management آمن (دمج كل الكوكيز)
/// - IP validation: يرفض أي IP خارج الشبكة المحلية
/// - Timeout لكل مرحلة (connect/receive/send)
class DioClient {
  late Dio _dio;
  String? _sessionCookie;
  String _baseUrl = 'http://${AppConstants.defaultRouterIp}';

  DioClient() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate',
          'Connection': 'keep-alive',
          'User-Agent': 'WiFiManager/1.0 (Android)',
        },
        followRedirects: true,
        maxRedirects: 3,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.addAll([
      _buildIpValidationInterceptor(),
      _buildCookieInterceptor(),
    ]);
  }

  InterceptorsWrapper _buildCookieInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
          options.headers['Cookie'] = _sessionCookie;
        }
        if (options.method == 'POST' && options.contentType == null) {
          options.contentType = 'application/x-www-form-urlencoded';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final rawCookies = response.headers['set-cookie'];
        if (rawCookies != null && rawCookies.isNotEmpty) {
          // BUG FIX: كان الكود القديم يأخذ أول كوكي فقط!
          // الإصلاح: دمج كل الكوكيز في سلسلة واحدة
          final cookies = rawCookies
              .map((c) => c.split(';').first.trim())
              .where((c) => c.isNotEmpty)
              .join('; ');
          if (cookies.isNotEmpty) _sessionCookie = cookies;
        }
        handler.next(response);
      },
    );
  }

  InterceptorsWrapper _buildIpValidationInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final host = Uri.tryParse(options.baseUrl)?.host ?? '';
        if (host.isNotEmpty && !_isLocalIp(host)) {
          handler.reject(DioException(
            requestOptions: options,
            message: 'Security: Only local network IPs are allowed.',
            type: DioExceptionType.cancel,
          ));
          return;
        }
        handler.next(options);
      },
    );
  }

  bool _isLocalIp(String ip) {
    if (ip == 'localhost' || ip == '127.0.0.1') return true;
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);
    if (first == null || second == null) return false;
    return (first == 192 && second == 168) ||
        first == 10 ||
        (first == 172 && second >= 16 && second <= 31);
  }

  void setBaseUrl(String ip) {
    _baseUrl = 'http://$ip';
    _dio.options.baseUrl = _baseUrl;
  }

  void setSessionCookie(String cookie) => _sessionCookie = cookie;
  void clearSession() => _sessionCookie = null;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) =>
      _withRetry(() => _dio.get(path, queryParameters: queryParameters, options: options));

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) =>
      _withRetry(() => _dio.post(path, data: data, queryParameters: queryParameters, options: options));

  Future<Response> _withRetry(Future<Response> Function() req, {int maxRetries = 2}) async {
    int attempt = 0;
    while (true) {
      try {
        return await req();
      } on DioException catch (e) {
        if (attempt >= maxRetries || e.type == DioExceptionType.cancel || e.response != null) rethrow;
        attempt++;
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  Future<bool> isRouterReachable() async {
    try {
      final r = await _dio.get('/', options: Options(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        sendTimeout: const Duration(seconds: 3),
      ));
      return r.statusCode != null && r.statusCode! < 500;
    } catch (_) {
      return false;
    }
  }

  Dio get dio => _dio;
  String? get sessionCookie => _sessionCookie;
  String get baseUrl => _baseUrl;
}
