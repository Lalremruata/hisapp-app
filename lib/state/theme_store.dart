import 'dart:ui' show Brightness;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/nocturne.dart';

/// How large the app sets its text, over whatever the device already asks
/// for.
enum NTextSize {
  normal('Normal', 1.0),
  large('Large', 1.15),
  extraLarge('Extra large', 1.3);

  const NTextSize(this.label, this.factor);

  /// How the setting names itself on screen.
  final String label;

  /// What every piece of text is multiplied by.
  final double factor;

  static NTextSize byName(String? name) => NTextSize.values.firstWhere(
    (size) => size.name == name,
    orElse: () => NTextSize.normal,
  );
}

/// The two tablet layouts: the same job, reached two ways.
enum TabletLayout {
  /// An icon rail and a type-to-add search box over the rate card.
  search('Search'),

  /// Big buttons for common jobs, and a keypad.
  keypad('Keypad');

  const TabletLayout(this.label);

  /// How the setting names itself on screen.
  final String label;

  static TabletLayout byName(String? name) => TabletLayout.values.firstWhere(
    (layout) => layout.name == name,
    orElse: () => TabletLayout.search,
  );
}

/// Where the counter screen's own preferences — palette, text size, tablet
/// layout — are kept between sessions.
abstract interface class ThemeStore {
  Future<NThemeMode> load();

  Future<void> save(NThemeMode mode);

  Future<NTextSize> loadTextSize();

  Future<void> saveTextSize(NTextSize size);

  Future<TabletLayout> loadLayout();

  Future<void> saveLayout(TabletLayout layout);
}

/// The real store, on the device.
class SharedPreferencesThemeStore implements ThemeStore {
  const SharedPreferencesThemeStore();

  static const _key = 'appearance.v1';
  static const _textSizeKey = 'textSize.v1';
  static const _layoutKey = 'tabletLayout.v1';

  @override
  Future<NThemeMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    // No record means the workshop has never opened the setting, and gets what
    // the app has always looked like.
    return NThemeMode.byName(prefs.getString(_key));
  }

  @override
  Future<void> save(NThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  @override
  Future<NTextSize> loadTextSize() async {
    final prefs = await SharedPreferences.getInstance();
    return NTextSize.byName(prefs.getString(_textSizeKey));
  }

  @override
  Future<void> saveTextSize(NTextSize size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_textSizeKey, size.name);
  }

  @override
  Future<TabletLayout> loadLayout() async {
    final prefs = await SharedPreferences.getInstance();
    return TabletLayout.byName(prefs.getString(_layoutKey));
  }

  @override
  Future<void> saveLayout(TabletLayout layout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_layoutKey, layout.name);
  }
}

/// A store that forgets when the process does. The default, so a test can
/// build a [ThemeController] without standing up a platform channel.
class InMemoryThemeStore implements ThemeStore {
  InMemoryThemeStore([
    this._mode = NThemeMode.defaultMode,
    this._textSize = NTextSize.normal,
    this._layout = TabletLayout.search,
  ]);

  NThemeMode _mode;
  NTextSize _textSize;
  TabletLayout _layout;

  @override
  Future<NThemeMode> load() async => _mode;

  @override
  Future<void> save(NThemeMode mode) async => _mode = mode;

  @override
  Future<NTextSize> loadTextSize() async => _textSize;

  @override
  Future<void> saveTextSize(NTextSize size) async => _textSize = size;

  @override
  Future<TabletLayout> loadLayout() async => _layout;

  @override
  Future<void> saveLayout(TabletLayout layout) async => _layout = layout;
}

/// Which palette the app wears (and the device brightness to fall back on
/// when that choice is [NThemeMode.system]), how large its text is, and which
/// tablet layout the counter bills on.
///
/// Held apart from `BillingModel`, which is about one bill: this is a property
/// of the screen the bill is being typed on, not of the workshop or its
/// invoices, and it outlives every bill.
class ThemeController extends ChangeNotifier {
  ThemeController({
    ThemeStore store = const SharedPreferencesThemeStore(),
    NThemeMode mode = NThemeMode.defaultMode,
    NTextSize textSize = NTextSize.normal,
    TabletLayout tabletLayout = TabletLayout.search,
  }) : _store = store,
       _mode = mode,
       _textSize = textSize,
       _tabletLayout = tabletLayout;

  final ThemeStore _store;
  NThemeMode _mode;
  NTextSize _textSize;
  TabletLayout _tabletLayout;

  NThemeMode get mode => _mode;
  NTextSize get textSize => _textSize;
  TabletLayout get tabletLayout => _tabletLayout;

  /// Reads the saved choices. Called before the first frame, so the app never
  /// shows one palette or size and then flips to the other.
  Future<void> load() async {
    _mode = await _store.load();
    _textSize = await _store.loadTextSize();
    _tabletLayout = await _store.loadLayout();
    notifyListeners();
  }

  void setTextSize(NTextSize value) {
    if (value == _textSize) return;
    _textSize = value;
    notifyListeners();
    _store.saveTextSize(value);
  }

  void setTabletLayout(TabletLayout value) {
    if (value == _tabletLayout) return;
    _tabletLayout = value;
    notifyListeners();
    _store.saveLayout(value);
  }

  void setMode(NThemeMode value) {
    if (value == _mode) return;
    _mode = value;
    notifyListeners();
    // Saved in the background: the palette is already on screen, and a
    // preference that fails to write is not worth holding the frame for.
    _store.save(value);
  }

  /// The palette to paint with, given what the device is currently set to.
  NPalette paletteFor(Brightness deviceBrightness) =>
      _mode.resolve(deviceBrightness);
}

/// Puts the [ThemeController] where the settings screen can reach it, the way
/// `BillingScope` does for the bill.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope above this widget');
    return scope!.notifier!;
  }
}
