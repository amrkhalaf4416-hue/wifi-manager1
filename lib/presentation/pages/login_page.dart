import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wifi_manager/core/constants/app_constants.dart';
import 'package:wifi_manager/core/theme/app_theme.dart';
import 'package:wifi_manager/core/utils/extensions.dart';
import 'package:wifi_manager/presentation/blocs/router/router_cubit.dart';
import 'package:wifi_manager/presentation/pages/devices_page.dart';
import 'package:wifi_manager/presentation/pages/router_webview_page.dart';
import 'package:wifi_manager/presentation/widgets/custom_button.dart';
import 'package:wifi_manager/presentation/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ipController = TextEditingController(text: AppConstants.defaultRouterIp);
  
  bool _obscurePassword = true;
  bool _useDefaultCredentials = true;
  bool _saveCredentials = true;
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _ipController.dispose();
    super.dispose();
  }
  
  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _useDefaultCredentials 
          ? AppConstants.defaultUsername 
          : _usernameController.text;
      final password = _useDefaultCredentials 
          ? AppConstants.defaultPassword 
          : _passwordController.text;
      
      // Update router IP if changed
      if (_ipController.text != AppConstants.defaultRouterIp) {
        context.read<RouterCubit>().updateRouterIp(_ipController.text);
      }
      
      context.read<RouterCubit>().login(username, password);
    }
  }
  
  void _openManualConfig() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RouterWebViewPage(
          url: 'http://${AppConstants.defaultRouterIp}',
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: BlocConsumer<RouterCubit, RouterState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DevicesPage()),
            );
          } else if (state.hasError) {
            context.showSnackBar(state.errorMessage!, isError: true);
            context.read<RouterCubit>().clearError();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),
                    // Logo
                    Center(
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppTheme.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.wifi_tethering,
                          size: 40.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    // Title
                    Center(
                      child: Text(
                        'Login to Router',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        'Huawei HG531 V1',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark 
                              ? AppTheme.textSecondaryDark 
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    // Router IP
                    CustomTextField(
                      controller: _ipController,
                      label: 'Router IP Address',
                      hint: '192.168.1.1',
                      prefixIcon: Icons.router,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter router IP';
                        }
                        if (!value.isValidIp) {
                          return 'Invalid IP address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    // Use Default Credentials
                    CheckboxListTile(
                      value: _useDefaultCredentials,
                      onChanged: (value) {
                        setState(() {
                          _useDefaultCredentials = value ?? true;
                        });
                      },
                      title: Text(
                        'Use Default Credentials (admin/admin)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    SizedBox(height: 16.h),
                    // Username
                    if (!_useDefaultCredentials) ...[
                      CustomTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: 'admin',
                        prefixIcon: Icons.person,
                        enabled: !_useDefaultCredentials,
                        validator: !_useDefaultCredentials
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              }
                            : null,
                      ),
                      SizedBox(height: 16.h),
                    ],
                    // Password
                    if (!_useDefaultCredentials) ...[
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••',
                        prefixIcon: Icons.lock,
                        obscureText: _obscurePassword,
                        enabled: !_useDefaultCredentials,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword 
                                ? Icons.visibility_off 
                                : Icons.visibility,
                            color: isDark 
                                ? AppTheme.textSecondaryDark 
                                : AppTheme.textSecondaryLight,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: !_useDefaultCredentials
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              }
                            : null,
                      ),
                      SizedBox(height: 16.h),
                    ],
                    // Save Credentials
                    CheckboxListTile(
                      value: _saveCredentials,
                      onChanged: (value) {
                        setState(() {
                          _saveCredentials = value ?? true;
                        });
                      },
                      title: Text(
                        'Save credentials for next time',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    SizedBox(height: 32.h),
                    // Login Button
                    CustomButton(
                      text: 'Login',
                      onPressed: _login,
                      isLoading: state.isAuthenticating,
                    ),
                    SizedBox(height: 16.h),
                    // Manual Config Button
                    Center(
                      child: TextButton(
                        onPressed: _openManualConfig,
                        child: Text(
                          'Manual Configuration',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark 
                                ? AppTheme.primaryDarkTheme 
                                : AppTheme.primaryLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
