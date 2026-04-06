import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wifi_manager/core/theme/app_theme.dart';
import 'package:wifi_manager/core/utils/extensions.dart';
import 'package:wifi_manager/domain/entities/device_entity.dart';
import 'package:wifi_manager/presentation/blocs/devices/devices_cubit.dart';
import 'package:wifi_manager/presentation/blocs/router/router_cubit.dart';
import 'package:wifi_manager/presentation/pages/login_page.dart';
import 'package:wifi_manager/presentation/pages/settings_page.dart';
import 'package:wifi_manager/presentation/widgets/device_card.dart';
import 'package:wifi_manager/presentation/widgets/empty_state.dart';
import 'package:wifi_manager/presentation/widgets/loading_shimmer.dart';
import 'package:wifi_manager/presentation/widgets/search_bar.dart';
import 'package:wifi_manager/presentation/widgets/stats_card.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // BUG FIX: استخدم addPostFrameCallback لتجنب setState أثناء build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DevicesCubit>().loadDevices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() => context.read<DevicesCubit>().refreshDevices();

  void _onSearchChanged(String query) =>
      context.read<DevicesCubit>().searchDevices(query);

  void _clearSearch() {
    _searchController.clear();
    context.read<DevicesCubit>().clearSearch();
  }

  // IMPROVEMENT: تحويل dialogs إلى methods واضحة
  Future<void> _confirmAndRun(
    BuildContext ctx, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool dangerous = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            style: dangerous
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(dangerous ? 'تأكيد' : 'موافق'),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) onConfirm();
  }

  void _logout() {
    _confirmAndRun(
      context,
      title: 'تسجيل الخروج',
      message: 'هل تريد تسجيل الخروج؟',
      dangerous: true,
      onConfirm: () {
        context.read<RouterCubit>().logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('الأجهزة المتصلة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'الإعدادات',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocConsumer<DevicesCubit, DevicesState>(
        // PERFORMANCE FIX: استخدام listenWhen لتجنب إعادة الـ listen بدون داعٍ
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage ||
            prev.actionStatus != curr.actionStatus,
        listener: (context, state) {
          if (state.errorMessage != null) {
            context.showSnackBar(state.errorMessage!, isError: true);
            context.read<DevicesCubit>().clearError();
          }
          if (state.actionStatus == DeviceActionStatus.success) {
            context.showSnackBar('تمت العملية بنجاح ✓');
            context.read<DevicesCubit>().clearActionStatus();
          }
          if (state.actionStatus == DeviceActionStatus.failure) {
            context.read<DevicesCubit>().clearActionStatus();
          }
        },
        builder: (context, state) => Column(
          children: [
            // شريط البحث
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: CustomSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
                hint: 'بحث عن جهاز...',
              ),
            ),

            // بطاقات الإحصاءات
            if (state.status != DevicesStatus.loading || state.devices.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(children: [
                  Expanded(
                    child: StatsCard(
                      title: 'المجموع',
                      value: state.devices.length.toString(),
                      icon: Icons.devices,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: StatsCard(
                      title: 'متصل',
                      value: state.onlineCount.toString(),
                      icon: Icons.wifi,
                      color: AppTheme.online,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: StatsCard(
                      title: 'محجوب',
                      value: state.blockedCount.toString(),
                      icon: Icons.block,
                      color: AppTheme.blocked,
                    ),
                  ),
                ]),
              ),

            // قائمة الأجهزة
            Expanded(child: _buildBody(context, state, isDark)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onRefresh,
        tooltip: 'تحديث',
        child: BlocBuilder<DevicesCubit, DevicesState>(
          buildWhen: (prev, curr) => prev.status != curr.status,
          builder: (_, state) => state.status == DevicesStatus.loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DevicesState state, bool isDark) {
    if (state.status == DevicesStatus.loading && state.devices.isEmpty) {
      return const LoadingShimmer();
    }

    final devices = state.displayDevices;

    if (devices.isEmpty) {
      return EmptyState(
        icon: Icons.devices_off,
        title: 'لا توجد أجهزة',
        subtitle: state.searchQuery != null
            ? 'لا توجد نتائج للبحث'
            : 'اسحب للأسفل للتحديث',
        onAction: _onRefresh,
        actionText: 'تحديث',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 80.h),
        itemCount: devices.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: DeviceCard(
            device: devices[index],
            onBlock: () => _handleBlock(context, devices[index]),
            onUnblock: () => _handleUnblock(context, devices[index]),
            onSetSpeedLimit: () => _showSpeedDialog(context, devices[index]),
            onRemoveSpeedLimit: () => _handleRemoveSpeed(context, devices[index]),
            onEditName: () => _showEditNameDialog(context, devices[index]),
          ),
        ),
      ),
    );
  }

  void _handleBlock(BuildContext ctx, DeviceEntity device) {
    _confirmAndRun(
      ctx,
      title: 'حظر الجهاز',
      message: 'هل تريد حظر "${device.displayName}"؟ سيتم قطع اتصاله.',
      dangerous: true,
      onConfirm: () => ctx.read<DevicesCubit>().blockDevice(device.macAddress),
    );
  }

  void _handleUnblock(BuildContext ctx, DeviceEntity device) {
    _confirmAndRun(
      ctx,
      title: 'إلغاء الحظر',
      message: 'هل تريد إلغاء حظر "${device.displayName}"؟',
      onConfirm: () => ctx.read<DevicesCubit>().unblockDevice(device.macAddress),
    );
  }

  void _handleRemoveSpeed(BuildContext ctx, DeviceEntity device) {
    _confirmAndRun(
      ctx,
      title: 'إزالة حد السرعة',
      message: 'هل تريد إزالة حد السرعة عن "${device.displayName}"؟',
      onConfirm: () => ctx.read<DevicesCubit>().removeSpeedLimit(device.macAddress),
    );
  }

  void _showSpeedDialog(BuildContext ctx, DeviceEntity device) {
    final downloadCtrl = TextEditingController(
      text: device.downloadSpeedLimit != null
          ? (device.downloadSpeedLimit! / 1000).toStringAsFixed(1)
          : '',
    );
    final uploadCtrl = TextEditingController(
      text: device.uploadSpeedLimit != null
          ? (device.uploadSpeedLimit! / 1000).toStringAsFixed(1)
          : '',
    );

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('تحديد سرعة: ${device.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: downloadCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'سرعة التنزيل (Mbps)',
                hintText: 'اتركه فارغاً للسرعة الكاملة',
                suffixText: 'Mbps',
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: uploadCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'سرعة الرفع (Mbps)',
                hintText: 'اتركه فارغاً للسرعة الكاملة',
                suffixText: 'Mbps',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(_);
              // BUG FIX: إضافة try-catch لتحويل القيم بأمان
              int? download, upload;
              try {
                if (downloadCtrl.text.isNotEmpty) {
                  download = (double.parse(downloadCtrl.text) * 1000).toInt();
                }
                if (uploadCtrl.text.isNotEmpty) {
                  upload = (double.parse(uploadCtrl.text) * 1000).toInt();
                }
              } catch (_) {
                ctx.showSnackBar('قيمة السرعة غير صحيحة', isError: true);
                return;
              }

              if (download == null && upload == null) return;

              ctx.read<DevicesCubit>().setSpeedLimit(
                device.macAddress,
                download,
                upload,
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext ctx, DeviceEntity device) {
    final ctrl = TextEditingController(text: device.displayName);

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('تعديل اسم الجهاز'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 50, // حد أقصى للاسم
          decoration: const InputDecoration(
            labelText: 'اسم الجهاز',
            hintText: 'أدخل اسماً مخصصاً',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(_);
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                ctx.read<DevicesCubit>().setDeviceName(device.macAddress, name);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
