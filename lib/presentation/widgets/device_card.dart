import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:wifi_manager/core/theme/app_theme.dart';
import 'package:wifi_manager/domain/entities/device_entity.dart';

class DeviceCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback? onBlock;
  final VoidCallback? onUnblock;
  final VoidCallback? onSetSpeedLimit;
  final VoidCallback? onRemoveSpeedLimit;
  final VoidCallback? onEditName;

  const DeviceCard({
    super.key,
    required this.device,
    this.onBlock,
    this.onUnblock,
    this.onSetSpeedLimit,
    this.onRemoveSpeedLimit,
    this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Slidable(
      key: ValueKey(device.macAddress),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (!device.isBlocked) ...[
            SlidableAction(
              onPressed: (_) => onBlock?.call(),
              backgroundColor: AppTheme.blocked,
              foregroundColor: Colors.white,
              icon: Icons.block,
              label: 'Block',
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(12.r),
              ),
            ),
          ] else ...[
            SlidableAction(
              onPressed: (_) => onUnblock?.call(),
              backgroundColor: AppTheme.online,
              foregroundColor: Colors.white,
              icon: Icons.check_circle,
              label: 'Unblock',
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(12.r),
              ),
            ),
          ],
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => _showDeviceOptions(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Device Icon
                _buildDeviceIcon(isDark),
                SizedBox(width: 16.w),
                
                // Device Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.displayName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark 
                                    ? Colors.white 
                                    : AppTheme.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (device.isBlocked) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.blocked.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Blocked',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppTheme.blocked,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          if (device.hasSpeedLimit && !device.isBlocked) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.limited.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Limited',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppTheme.limited,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        device.manufacturer,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark 
                              ? AppTheme.textSecondaryDark 
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.computer,
                            size: 14.w,
                            color: isDark 
                                ? AppTheme.textSecondaryDark 
                                : AppTheme.textSecondaryLight,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            device.ipAddress,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark 
                                  ? AppTheme.textSecondaryDark 
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.fingerprint,
                            size: 14.w,
                            color: isDark 
                                ? AppTheme.textSecondaryDark 
                                : AppTheme.textSecondaryLight,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              device.formattedMac,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark 
                                    ? AppTheme.textSecondaryDark 
                                    : AppTheme.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (device.hasSpeedLimit) ...[
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.grey.shade800 
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            device.speedLimitDisplay,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark 
                                  ? AppTheme.textSecondaryDark 
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Status Indicator
                _buildStatusIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceIcon(bool isDark) {
    IconData iconData;
    Color iconColor;
    
    switch (device.deviceType) {
      case 'phone':
        iconData = Icons.smartphone;
        iconColor = Colors.blue;
        break;
      case 'tablet':
        iconData = Icons.tablet;
        iconColor = Colors.purple;
        break;
      case 'laptop':
        iconData = Icons.laptop;
        iconColor = Colors.indigo;
        break;
      case 'desktop':
        iconData = Icons.computer;
        iconColor = Colors.teal;
        break;
      case 'tv':
        iconData = Icons.tv;
        iconColor = Colors.orange;
        break;
      case 'gaming':
        iconData = Icons.gamepad;
        iconColor = Colors.red;
        break;
      case 'iot':
        iconData = Icons.smart_toy;
        iconColor = Colors.green;
        break;
      case 'camera':
        iconData = Icons.camera_alt;
        iconColor = Colors.pink;
        break;
      case 'printer':
        iconData = Icons.print;
        iconColor = Colors.brown;
        break;
      case 'router':
        iconData = Icons.router;
        iconColor = Colors.cyan;
        break;
      default:
        iconData = Icons.devices;
        iconColor = Colors.grey;
    }
    
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24.w,
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    IconData statusIcon;
    
    if (device.isBlocked) {
      statusColor = AppTheme.blocked;
      statusIcon = Icons.block;
    } else if (!device.isOnline) {
      statusColor = AppTheme.offline;
      statusIcon = Icons.offline_bolt;
    } else if (device.hasSpeedLimit) {
      statusColor = AppTheme.limited;
      statusIcon = Icons.speed;
    } else {
      statusColor = AppTheme.online;
      statusIcon = Icons.check_circle;
    }
    
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        statusIcon,
        color: statusColor,
        size: 16.w,
      ),
    );
  }

  void _showDeviceOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              
              // Device Name
              Text(
                device.displayName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                device.formattedMac,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark 
                      ? AppTheme.textSecondaryDark 
                      : AppTheme.textSecondaryLight,
                ),
              ),
              SizedBox(height: 24.h),
              
              // Options
              _buildOptionTile(
                context,
                icon: Icons.edit,
                title: 'Edit Name',
                onTap: () {
                  Navigator.pop(context);
                  onEditName?.call();
                },
              ),
              
              if (!device.isBlocked) ...[
                _buildOptionTile(
                  context,
                  icon: Icons.block,
                  title: 'Block Device',
                  iconColor: AppTheme.blocked,
                  onTap: () {
                    Navigator.pop(context);
                    onBlock?.call();
                  },
                ),
              ] else ...[
                _buildOptionTile(
                  context,
                  icon: Icons.check_circle,
                  title: 'Unblock Device',
                  iconColor: AppTheme.online,
                  onTap: () {
                    Navigator.pop(context);
                    onUnblock?.call();
                  },
                ),
              ],
              
              if (!device.hasSpeedLimit && !device.isBlocked) ...[
                _buildOptionTile(
                  context,
                  icon: Icons.speed,
                  title: 'Set Speed Limit',
                  onTap: () {
                    Navigator.pop(context);
                    onSetSpeedLimit?.call();
                  },
                ),
              ] else if (device.hasSpeedLimit) ...[
                _buildOptionTile(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Remove Speed Limit',
                  iconColor: AppTheme.error,
                  onTap: () {
                    Navigator.pop(context);
                    onRemoveSpeedLimit?.call();
                  },
                ),
              ],
              
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (isDark ? Colors.white : AppTheme.textPrimaryLight),
      ),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}
