import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/prefs_migration.dart';
import 'screens/billing_shell.dart';
import 'state/billing_model.dart';
import 'state/sqlite_stores.dart';
import 'state/theme_store.dart';
import 'theme/nocturne.dart';
import 'widgets/keyboard_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Everything a workshop saved under an older build is carried into the
  // database first, so the first load already finds it.
  final db = AppDatabase.open();
  try {
    await importFromPrefs(db);
  } catch (_) {
    // An import that fails is tried again next launch; the old records are
    // left untouched. Not a reason to refuse to bill today.
  }

  // The rate card and the saved bills are read before the first frame, so
  // nothing can be typed in on top of a list that is still loading.
  final model = BillingModel(
    store: SqliteItemStore(db),
    bills: SqliteBillStore(db),
    settings: SqliteSettingsStore(db),
    restorePoints: SqliteRestorePointStore(db),
  );
  await model.loadSettings();
  await model.loadItems();
  await model.loadBills();
  await model.loadRestorePoint();

  // As is the choice of palette, so the counter never sees the night one
  // flash before the day one it asked for.
  final theme = ThemeController();
  await theme.load();

  runApp(HisapApp(model: model, theme: theme));
}

/// A GST billing app for an automobile workshop: parts and labour on one bill
/// against the vehicle they were fitted to, tablet first, phone companion, and
/// an A4 tax invoice that prints from either.
class HisapApp extends StatefulWidget {
  const HisapApp({super.key, this.model, this.theme});

  /// One bill, shared by every screen — the tablet layouts, the phone layout
  /// and the printed invoice are all views onto it. A test may pass its own;
  /// otherwise the app builds one that keeps its items in memory.
  final BillingModel? model;

  /// Which palette to wear. A test may pass its own; otherwise the app builds
  /// one that follows the device and forgets when the process does.
  final ThemeController? theme;

  @override
  State<HisapApp> createState() => _HisapAppState();
}

class _HisapAppState extends State<HisapApp> {
  late final _model = widget.model ?? BillingModel();
  late final _theme =
      widget.theme ?? ThemeController(store: InMemoryThemeStore());

  @override
  void initState() {
    super.initState();
    _theme.addListener(_onThemeChanged);
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    _theme.removeListener(_onThemeChanged);
    _model.dispose();
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The one place the palette is chosen. [N] is read statically all over the
    // app, so it has to be set before anything below here builds — and this
    // rebuilds when the controller changes or the device flips to dark, which
    // is every way the answer can change.
    final palette = _theme.paletteFor(MediaQuery.platformBrightnessOf(context));
    N.palette = palette;

    return ThemeScope(
      controller: _theme,
      child: NPaletteScope(
        palette: palette,
        child: BillingScope(
          model: _model,
          child: MaterialApp(
            title: 'Billing',
            debugShowCheckedModeBanner: false,
            theme: _materialTheme(palette),
            // Every route sits on one Material at the ground colour: the
            // screens are built from the design system's own surfaces, not
            // Material's, but text still needs a Material ancestor to render
            // against.
            builder: (context, child) {
              // The text-size setting stacks on whatever the device already
              // asks for, so someone who has set their phone large gets
              // larger still rather than being reset.
              final media = MediaQuery.of(context);
              final factor = _theme.textSize.factor;
              return MediaQuery(
                data: media.copyWith(
                  textScaler: factor == 1
                      ? media.textScaler
                      : _ScaledBy(media.textScaler, factor),
                  // Taken up by the padding below.
                  viewInsets: media.viewInsets.copyWith(bottom: 0),
                ),
                child: Material(
                  color: N.bg,
                  // No screen here sits on a Scaffold, so nothing else gets
                  // out of the keyboard's way. Every route and dialog stops at
                  // the top of the keyboard instead, which is what lets a
                  // focused field scroll up into view rather than sit under
                  // it.
                  child: Padding(
                    padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
                    child: KeyboardScope(
                      open: media.viewInsets.bottom > 0,
                      child: DefaultTextStyle(
                        style: N.font(),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              );
            },
            home: const BillingShell(),
          ),
        ),
      ),
    );
  }

  /// Material's theme carries only what the framework itself paints — text
  /// selection, scrollbars, the ground. Everything visible comes from [N].
  ThemeData _materialTheme(NPalette palette) {
    final base = ThemeData(brightness: palette.brightness, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: palette.bg,
      canvasColor: palette.bg,
      colorScheme: base.colorScheme.copyWith(
        primary: palette.accent,
        surface: palette.surface,
        onSurface: palette.text,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.accent,
        selectionColor: palette.tint(0.3),
        selectionHandleColor: palette.accent,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: N.fontFamily,
        fontFamilyFallback: N.fontFamilyFallback,
        bodyColor: palette.text,
        displayColor: palette.text,
      ),
    );
  }
}

/// [base], then multiplied by [factor].
class _ScaledBy extends TextScaler {
  const _ScaledBy(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  double get textScaleFactor => base.scale(14) / 14 * factor;

  @override
  bool operator ==(Object other) =>
      other is _ScaledBy && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
