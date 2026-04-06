import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wifi_manager/core/theme/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;
  final String? hint;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint ?? 'Search...',
          hintStyle: TextStyle(
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isNotEmpty) {
                return IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }
}
