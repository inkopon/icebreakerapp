import 'package:flutter/material.dart';

import '../constants/general_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: false,
      fontFamily: inkDefaultFont,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: gradientStartColor,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
