import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

Color _themeColor = Colors.deepOrange;
bool _isDark = false;

@riverpod
setThemeColor(SetThemeColorRef ref, {required Color newCol}) {
  _themeColor = newCol;
  ref.invalidate(getThemeColorProvider);
}

@riverpod
Color getThemeColor(GetThemeColorRef ref) {
  return _themeColor;
}

@riverpod
toggleDarkmode(ToggleDarkmodeRef ref) {
  _isDark = !_isDark;
  ref.invalidate(getDarkmodeProvider);
}

@riverpod
bool getDarkmode(GetDarkmodeRef ref) {
  return _isDark;
}
