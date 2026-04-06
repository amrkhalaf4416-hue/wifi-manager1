import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi_manager/core/constants/app_constants.dart';
import 'package:wifi_manager/core/theme/app_theme.dart';
import 'package:wifi_manager/core/utils/extensions.dart';
import 'package:wifi_manager/presentation/blocs/locale/locale_cubit.dart';
import 'package:wifi_manager/presentation/blocs/router/router_cubit.dart';
import 'package:wifi_manager/presentation/blocs/theme/theme_cubit.dart';
import 'package:wifi_manager/presentation/pages/login_page.dart';
import 'package:wifi_manager/presentation/pages/router_webview_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = '${info.version}+${info.buildNumber}');
    } catch (_) {
      if (mounted) setState(() => _appVersion = AppConstants.appVersion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        children: [
          // ── قسم الراوتر ──
          _SectionHeader(title: 'الراوتر'),
          BlocBuilder<RouterCubit, RouterState>(
            builder: (context, state) {
              final s = state.settings;
              return Column(children: [
                _SettingsTile(
                  icon: Icons.router,
                  title: 'عنوان IP',
                  subtitle: s.routerIp,
                  onTap: () => _showIpDialog(context, s.routerIp),
                ),
                _SettingsTile(
                  icon: Icons.person,
                  title: 'اسم المستخدم',
                  subtitle: s.username,
                  onTap: () => _showUsernameDialog(context, s.username),
                ),
                _SettingsTile(
                  icon: Icons.lock,
                  title: 'كلمة المرور',
                  subtitle: '••••••',
                  onTap: () => _showPasswordDialog(context),
                ),
                if (s.routerModel != null)
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'طراز الراوتر',
                    subtitle: s.routerModel!,
                  ),
                if (s.ssid != null)
                  _SettingsTile(
                    icon: Icons.wifi,
                    title: 'اسم الشبكة',
                    subtitle: s.ssid!,
                  ),
                _SettingsTile(
                  icon: Icons.open_in_browser,
                  title: 'فتح صفحة الراوتر',
                  subtitle: 'إعداد يدوي عبر المتصفح',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RouterWebViewPage(
                        url: 'http://${s.routerIp}',
                      ),
                    ),
                  ),
                ),
              ]);
            },
          ),
          SizedBox(height: 8.h),

          // ── قسم المظهر ──
          _SectionHeader(title: 'المظهر واللغة'),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return _SettingsTile(
                icon: Icons.brightness_6,
                title: 'المظهر',
                subtitle: _themeLabel(themeState.themeMode),
                onTap: () => _showThemeDialog(context, themeState.themeMode),
              );
            },
          ),
          BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return _SettingsTile(
                icon: Icons.language,
                title: 'اللغة',
                subtitle: localeState.locale.languageCode == 'ar' ? 'العربية' : 'English',
                onTap: () => _toggleLocale(context, localeState),
              );
            },
          ),
          SizedBox(height: 8.h),

          // ── قسم الحساب ──
          _SectionHeader(title: 'الحساب'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            subtitle: 'العودة لشاشة الدخول',
            iconColor: Colors.red,
            onTap: () => _confirmLogout(context),
          ),
          SizedBox(height: 8.h),

          // ── حول التطبيق ──
          _SectionHeader(title: 'حول التطبيق'),
          _SettingsTile(
            icon: Icons.info,
            title: 'الإصدار',
            subtitle: _appVersion.isEmpty ? AppConstants.appVersion : _appVersion,
          ),
          _SettingsTile(
            icon: Icons.wifi_tethering,
            title: 'الجهاز المدعوم',
            subtitle: 'Huawei HG531 V1',
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'فاتح';
      case ThemeMode.dark: return 'داكن';
      case ThemeMode.system: return 'تلقائي (حسب الجهاز)';
    }
  }

  void _toggleLocale(BuildContext ctx, LocaleState state) {
    final next = state.locale.languageCode == 'ar' ? 'en' : 'ar';
    ctx.read<LocaleCubit>().setLocale(next);
  }

  void _showThemeDialog(BuildContext ctx, ThemeMode current) {
    showDialog(
      context: ctx,
      builder: (_) => SimpleDialog(
        title: const Text('اختر المظهر'),
        children: [
          for (final mode in ThemeMode.values)
            RadioListTile<ThemeMode>(
              value: mode,
              groupValue: current,
              title: Text(_themeLabel(mode)),
              onChanged: (v) {
                Navigator.pop(_);
                if (v != null) ctx.read<ThemeCubit>().setTheme(v);
              },
            ),
        ],
      ),
    );
  }

  void _showIpDialog(BuildContext ctx, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('عنوان IP للراوتر'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(hintText: '192.168.1.1'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              final ip = ctrl.text.trim();
              if (ip.isValidIp) {
                ctx.read<RouterCubit>().updateRouterIp(ip);
                Navigator.pop(_);
              } else {
                ctx.showSnackBar('عنوان IP غير صحيح', isError: true);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showUsernameDialog(BuildContext ctx, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('اسم المستخدم'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ctx.read<RouterCubit>().updateCredentials(ctrl.text.trim(), ctx.read<RouterCubit>().state.settings.password);
                Navigator.pop(_);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext ctx) {
    final ctrl = TextEditingController();
    bool obscure = true;
    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (_, set) => AlertDialog(
          title: const Text('كلمة المرور'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: 'كلمة المرور الجديدة',
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => set(() => obscure = !obscure),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(_), child: const Text('إلغاء')),
            TextButton(
              onPressed: () {
                if (ctrl.text.isNotEmpty) {
                  ctx.read<RouterCubit>().updateCredentials(ctx.read<RouterCubit>().state.settings.username, ctrl.text);
                  Navigator.pop(_);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_), child: const Text('إلغاء')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(_);
              ctx.read<RouterCubit>().logout();
              Navigator.of(ctx).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ──

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: iconColor ?? (isDark ? AppTheme.primaryDarkTheme : AppTheme.primaryLight), size: 22),
      title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(fontSize: 12.sp, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight))
          : null,
      trailing: onTap != null ? Icon(Icons.chevron_right, size: 18, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight) : null,
      onTap: onTap,
    );
  }
}
