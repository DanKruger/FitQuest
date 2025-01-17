import 'package:flutter/material.dart';

ButtonStyle buttonColorStyle({
  required Color foregroundColor,
  required Color backgroundColor,
}) {
  return ElevatedButton.styleFrom(
    foregroundColor: foregroundColor,
    backgroundColor: backgroundColor,
  );
}
