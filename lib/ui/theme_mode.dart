import 'package:flutter/material.dart';

class ThemeModeWidget extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  ThemeModeWidget({
    required super.child,
    super.key,
    required ThemeMode initialMode,
  }) : super(notifier: ValueNotifier<ThemeMode>(initialMode));

  set themeMode(ThemeMode newMode) {
    notifier?.value = newMode;
  }

  ThemeMode get value => notifier?.value ?? ThemeMode.system;

  static ThemeModeWidget? of(BuildContext context) {
    final configNotifier =
        context.dependOnInheritedWidgetOfExactType<ThemeModeWidget>();
    return configNotifier;
  }
}
