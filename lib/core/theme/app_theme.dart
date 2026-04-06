import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();
  
  // Colors - Light Theme
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF03A9F4);
  static const Color accentLight = Color(0xFF00BCD4);
  
  // Colors - Dark Theme
  static const Color primaryDarkTheme = Color(0xFF90CAF9);
  static const Color secondaryDarkTheme = Color(0xFF81D4FA);
  static const Color accentDarkTheme = Color(0xFF80DEEA);
  
  // Common Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Device Status Colors
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color blocked = Color(0xFFE53935);
  static const Color limited = Color(0xFFFF9800);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2196F3),
    Color(0xFF1976D2),
  ];
  
  static const List<Color> darkGradient = [
    Color(0xFF1A237E),
    Color(0xFF0D47A1),
  ];
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: secondaryLight,
        surface: surfaceLight,
        background: backgroundLight,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onBackground: textPrimaryLight,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        color: surfaceLight,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryLight,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: _buildTextTheme(Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
      textButtonTheme: _buildTextButtonTheme(Brightness.light),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
      chipTheme: _buildChipTheme(Brightness.light),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryLight,
        unselectedItemColor: textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: surfaceLight,
        contentTextStyle: GoogleFonts.cairo(
          color: textPrimaryLight,
          fontSize: 14.sp,
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: surfaceLight,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDarkTheme,
        secondary: secondaryDarkTheme,
        surface: surfaceDark,
        background: backgroundDark,
        error: error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimaryDark,
        onBackground: textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        color: surfaceDark,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: surfaceDark,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: textPrimaryDark),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.dark),
      textButtonTheme: _buildTextButtonTheme(Brightness.dark),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
      chipTheme: _buildChipTheme(Brightness.dark),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryDarkTheme,
        unselectedItemColor: textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryDarkTheme,
        foregroundColor: Colors.black,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: surfaceDark,
        contentTextStyle: GoogleFonts.cairo(
          color: textPrimaryDark,
          fontSize: 14.sp,
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: surfaceDark,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
      ),
    );
  }
  
  // Text Theme
  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? textPrimaryDark : textPrimaryLight;
    final secondaryColor = isDark ? textSecondaryDark : textSecondaryLight;
    
    return TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineLarge: GoogleFonts.cairo(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: primaryColor,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: primaryColor,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
    );
  }
  
  // Elevated Button Theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? primaryDarkTheme : primaryLight,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  // Outlined Button Theme
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? primaryDarkTheme : primaryLight;
    
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.5),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  // Text Button Theme
  static TextButtonThemeData _buildTextButtonTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDark ? primaryDarkTheme : primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        textStyle: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  // Input Decoration Theme
  static InputDecorationTheme _buildInputDecorationTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? primaryDarkTheme : primaryLight;
    final fillColor = isDark ? surfaceDark : surfaceLight;
    
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      hintStyle: GoogleFonts.cairo(
        fontSize: 14.sp,
        color: isDark ? textSecondaryDark : textSecondaryLight,
      ),
      labelStyle: GoogleFonts.cairo(
        fontSize: 14.sp,
        color: isDark ? textSecondaryDark : textSecondaryLight,
      ),
      errorStyle: GoogleFonts.cairo(
        fontSize: 12.sp,
        color: error,
      ),
    );
  }
  
  // Chip Theme
  static ChipThemeData _buildChipTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    return ChipThemeData(
      backgroundColor: isDark ? surfaceDark : surfaceLight,
      selectedColor: isDark ? primaryDarkTheme : primaryLight,
      labelStyle: GoogleFonts.cairo(
        fontSize: 12.sp,
        color: isDark ? textPrimaryDark : textPrimaryLight,
      ),
      secondaryLabelStyle: GoogleFonts.cairo(
        fontSize: 12.sp,
        color: isDark ? Colors.black : Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}
