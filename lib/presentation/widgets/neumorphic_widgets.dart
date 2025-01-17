import 'package:flutter/material.dart';

BoxDecoration flatBoxDecoration(double borderRadius, ColorScheme theme,
    [Color? color]) {
  return BoxDecoration(
    color: theme.onInverseSurface,
    borderRadius: BorderRadius.circular(borderRadius),
  );
}

BoxDecoration neumorphicBoxDecoration(double borderRadius, ColorScheme theme,
    [Color? color]) {
  return BoxDecoration(
    color: theme.surface,
    borderRadius: BorderRadius.circular(borderRadius),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [theme.surface, theme.surfaceTint],
    ),
    boxShadow: [
      BoxShadow(
        color: theme.surfaceBright, // Light source from top-left
        offset: const Offset(-5, -5), // Adjust for shadow position
        blurRadius: 10,
      ),
      BoxShadow(
        color: theme.shadow, // Dark source from bottom-right
        offset: const Offset(5, 5),
        blurRadius: 10,
      ),
    ],
  );
}
