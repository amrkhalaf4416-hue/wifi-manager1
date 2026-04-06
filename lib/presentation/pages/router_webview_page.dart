import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wifi_manager/core/theme/app_theme.dart';

class RouterWebViewPage extends StatefulWidget {
  final String url;
  
  const RouterWebViewPage({
    super.key,
    required this.url,
  });

  @override
  State<RouterWebViewPage> createState() => _RouterWebViewPageState();
}

class _RouterWebViewPageState extends State<RouterWebViewPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;
  
  @override
  void initState() {
    super.initState();
    _initWebView();
  }
  
  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _progress = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading page: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Router Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                _controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                _controller.goForward();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          
          // Loading Indicator
          if (_isLoading)
            Container(
              color: isDark ? Colors.black54 : Colors.white54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _progress > 0 ? _progress : null,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Guide Overlay
          Positioned(
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
            child: Card(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryLight,
                          size: 20.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Quick Guide',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildGuideItem('1', 'Login with admin/admin'),
                    _buildGuideItem('2', 'Go to "Wireless" or "WiFi" settings'),
                    _buildGuideItem('3', 'Find "Station List" for connected devices'),
                    _buildGuideItem('4', 'Use "MAC Filter" to block devices'),
                    _buildGuideItem('5', 'Use "QoS" for speed limits'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGuideItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
