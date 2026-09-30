import 'package:flutter/widgets.dart';

/// Whether the on-screen keyboard is up.
///
/// The app pads every route clear of the keyboard and zeroes the inset below
/// that, so a screen cannot read it off [MediaQuery]. The billing screens need
/// to know, to fold away what can wait while something is being typed.
class KeyboardScope extends InheritedWidget {
  const KeyboardScope({super.key, required this.open, required super.child});

  final bool open;

  static bool isOpen(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<KeyboardScope>()?.open ??
      false;

  @override
  bool updateShouldNotify(KeyboardScope oldWidget) => open != oldWidget.open;
}
