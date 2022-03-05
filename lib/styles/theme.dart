import 'package:flutter/material.dart';

import 'color.dart';

class AppTheme {
  static const _floatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
  );

  static const _bottomNavigationBarTheme = BottomNavigationBarThemeData(
    selectedItemColor: AppColors.bluePurple,
  );

  static const colorScheme = ColorScheme.light(
    primary: AppColors.primary,
  );

  static final global = ThemeData.from(colorScheme: colorScheme).copyWith(
    appBarTheme: const AppBarTheme(
      elevation: .4,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    floatingActionButtonTheme: _floatingActionButtonTheme,
    bottomNavigationBarTheme: _bottomNavigationBarTheme,
    iconTheme: const IconThemeData(
      color: AppColors.grey,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.black,
        onSurface: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        primary: AppColors.primary,
        onPrimary: Colors.black,
      ),
    ),
  );
}
