import 'package:flutter/material.dart';

// Context Extensions
extension ContextExtensions on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // Media Query
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  
  // Navigation
  NavigatorState get navigator => Navigator.of(this);
  
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  
  Future<T?> push<T>(Widget page) => Navigator.of(this).push(
    MaterialPageRoute(builder: (_) => page),
  );
  
  Future<T?> pushReplacement<T>(Widget page) => Navigator.of(this).pushReplacement(
    MaterialPageRoute(builder: (_) => page),
  );
  
  Future<T?> pushAndRemoveUntil<T>(Widget page) => Navigator.of(this).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => page),
    (route) => false,
  );
  
  // SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Dialog
  Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) async {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous 
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText ?? 'Confirm'),
          ),
        ],
      ),
    );
  }
}

// String Extensions
extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  String get toTitleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  String get truncateMac {
    if (length <= 17) return this;
    return substring(0, 17);
  }
  
  String get formatMac {
    // Remove all non-alphanumeric characters
    final clean = replaceAll(RegExp(r'[^A-Fa-f0-9]'), '').toUpperCase();
    if (clean.length != 12) return this;
    
    // Format as XX:XX:XX:XX:XX:XX
    final parts = <String>[];
    for (var i = 0; i < 12; i += 2) {
      parts.add(clean.substring(i, i + 2));
    }
    return parts.join(':');
  }
  
  String get extractOui {
    final clean = replaceAll(RegExp(r'[^A-Fa-f0-9]'), '').toUpperCase();
    if (clean.length < 6) return '';
    return clean.substring(0, 6);
  }
  
  bool get isValidMac {
    final clean = replaceAll(RegExp(r'[^A-Fa-f0-9]'), '');
    return clean.length == 12;
  }
  
  bool get isValidIp {
    final parts = split('.');
    if (parts.length != 4) return false;
    
    for (final part in parts) {
      final number = int.tryParse(part);
      if (number == null || number < 0 || number > 255) {
        return false;
      }
    }
    return true;
  }
}

// DateTime Extensions
extension DateTimeExtensions on DateTime {
  String get formatted {
    final now = DateTime.now();
    final diff = now.difference(this);
    
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '$day/$month/$year';
    }
  }
  
  String get timeOnly {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

// Duration Extensions
extension DurationExtensions on Duration {
  String get formatted {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

// List Extensions
extension ListExtensions<T> on List<T> {
  List<T> get unique {
    return toSet().toList();
  }
  
  List<T> separatedBy(T separator) {
    if (length <= 1) return this;
    
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}

// Int Extensions
extension IntExtensions on int {
  String get toFileSize {
    if (this < 1024) {
      return '$this B';
    } else if (this < 1024 * 1024) {
      return '${(this / 1024).toStringAsFixed(1)} KB';
    } else if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  String get toSpeed {
    if (this < 1000) {
      return '$this Kbps';
    } else {
      return '${(this / 1000).toStringAsFixed(1)} Mbps';
    }
  }
}

// Widget Extensions
extension WidgetExtensions on Widget {
  Widget get center => Center(child: this);
  
  Widget get expand => Expanded(child: this);
  
  Widget get flexible => Flexible(child: this);
  
  Widget padding(EdgeInsets padding) => Padding(
    padding: padding,
    child: this,
  );
  
  Widget paddingAll(double value) => Padding(
    padding: EdgeInsets.all(value),
    child: this,
  );
  
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );
  
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
    child: this,
  );
}
