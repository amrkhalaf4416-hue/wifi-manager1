import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wifi_manager/core/theme/app_theme.dart';
import 'package:wifi_manager/presentation/blocs/router/router_cubit.dart';
import 'package:wifi_manager/presentation/pages/devices_page.dart';
import 'package:wifi_manager/presentation/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    
    _controller.forward();
    
    // Navigate after animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _checkAuthAndNavigate();
      }
    });
  }
  
  void _checkAuthAndNavigate() {
    final routerCubit = context.read<RouterCubit>();
    final state = routerCubit.state;
    
    if (state.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DevicesPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Container
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppTheme.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryLight.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.wifi_tethering,
                        size: 60.w,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // App Name
                    Text(
                      'WiFi Manager',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Subtitle
                    Text(
                      'Huawei HG531 V1',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark 
                            ? AppTheme.textSecondaryDark 
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 48.h),
                    // Loading Indicator
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppTheme.primaryDarkTheme : AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
