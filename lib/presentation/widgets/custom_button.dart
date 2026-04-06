import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wifi_manager/core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = backgroundColor ?? (isOutlined 
        ? Colors.transparent 
        : (isDark ? AppTheme.primaryDarkTheme : AppTheme.primaryLight));
    
    final fgColor = textColor ?? (isOutlined 
        ? (isDark ? AppTheme.primaryDarkTheme : AppTheme.primaryLight)
        : Colors.white);
    
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(color: fgColor),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 2,
          );
    
    final child = isLoading
        ? SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20.w),
                SizedBox(width: 8.w),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
    
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56.h,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: child,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: child,
            ),
    );
  }
}
