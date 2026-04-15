// providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontSize {
  small,
  medium,
  large,
}

enum ThemeModeType {
  light,
  dark,
}

class ThemeProvider extends ChangeNotifier {
  FontSize _currentFontSize = FontSize.small;
  ThemeModeType _currentThemeMode = ThemeModeType.light;

  FontSize get currentFontSize => _currentFontSize;
  ThemeModeType get currentThemeMode => _currentThemeMode;

  // تحجيم الخط بناءً على الاختيار
  double get fontScale {
    switch (_currentFontSize) {
      case FontSize.small:
        return 1.0; // ✅ تم التعديل من 0.8 إلى 0.9
      case FontSize.medium:
        return 1.2; // ✅ تم التعديل من 1.0 إلى 1.1
      case FontSize.large:
        return 1.3; // ✅ تم التعديل من 1.2 إلى 1.3
    }
  }

  // وضع التطبيق (فاتح/داكن)
  ThemeMode get themeMode {
    switch (_currentThemeMode) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
    }
  }

  // لون الخلفية الرئيسي
  Color get backgroundColor {
    return _currentThemeMode == ThemeModeType.dark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F5F5);
  }

  // لون البطاقات
  Color get cardColor {
    return _currentThemeMode == ThemeModeType.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  // لون النص الرئيسي
  Color get textColor {
    return _currentThemeMode == ThemeModeType.dark
        ? Colors.white
        : const Color(0xFF2D2D2D);
  }

  // لون النص الثانوي
  Color get secondaryTextColor {
    return _currentThemeMode == ThemeModeType.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentFontSize = FontSize.values[prefs.getInt('fontSize') ?? 0];
    _currentThemeMode = ThemeModeType.values[prefs.getInt('themeMode') ?? 0];
    notifyListeners();
  }

  Future<void> setFontSize(FontSize size) async {
    _currentFontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontSize', size.index);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeType mode) async {
    _currentThemeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }
}
