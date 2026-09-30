import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisap_app_2_0/main.dart';
import 'package:hisap_app_2_0/screens/billing_shell.dart';
import 'package:hisap_app_2_0/screens/invoice_a4.dart';
import 'package:hisap_app_2_0/screens/workshop_settings_screen.dart';
import 'package:hisap_app_2_0/state/theme_store.dart';
import 'package:hisap_app_2_0/theme/nocturne.dart';
import 'package:hisap_app_2_0/state/billing_model.dart';
import 'support/demo_bill.dart';

/// WCAG relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// The WCAG contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// [fg] laid over [bg] at its own alpha, as the screen composites it.
Color _over(Color fg, Color bg) => Color.from(
  alpha: 1,
  red: fg.r * fg.a + bg.r * (1 - fg.a),
  green: fg.g * fg.a + bg.g * (1 - fg.a),
  blue: fg.b * fg.a + bg.b * (1 - fg.a),
);

/// Every pair of colours the design puts one on top of the other, named the
/// way the app asks for them.
///
/// Read against both palettes: a role that carries its text at night has to
/// carry it by day too, which is the whole claim a second palette makes.
List<({String what, Color fg, Color bg, double floor})> _pairs(NPalette p) => [
  (what: 'text on bg', fg: p.text, bg: p.bg, floor: 12),
  (what: 'text on panel', fg: p.text, bg: p.panel, floor: 12),
  (what: 'text on surface', fg: p.text, bg: p.surface, floor: 12),
  (what: 'accent on bg', fg: p.accent, bg: p.bg, floor: 4.5),
  (what: 'accent on panel', fg: p.accent, bg: p.panel, floor: 4.5),
  (what: 'accent on surface', fg: p.accent, bg: p.surface, floor: 4.5),
  // The invoice screen's own chrome sits on the desk, not on the ground.
  (what: 'text on desk', fg: p.text, bg: p.desk, floor: 12),
  (what: 'accent on desk', fg: p.accent, bg: p.desk, floor: 4.5),
  // ...and the sheet laid on it has to read as a sheet.
  (what: 'paper on desk', fg: InvoicePage.paper, bg: p.desk, floor: 1.15),
  // The muted secondary label, as the totals and the meta rows use it.
  (what: 'neutral400 on bg', fg: p.neutral400, bg: p.bg, floor: 4.5),
  (what: 'neutral400 on panel', fg: p.neutral400, bg: p.panel, floor: 4.5),
  (
    what: 'neutral400 in a pill',
    fg: p.neutral400,
    bg: p.neutral900,
    floor: 4.5,
  ),
  // Accent text: the rail monogram, the suggestion rates, the Edit links.
  (what: 'accent300 on panel', fg: p.accent300, bg: p.panel, floor: 4.5),
  (what: 'accent300 on surface', fg: p.accent300, bg: p.surface, floor: 4.5),
  // Kickers and the small accent icons.
  (what: 'accent400 on bg', fg: p.accent400, bg: p.bg, floor: 4.5),
  (what: 'accent400 on panel', fg: p.accent400, bg: p.panel, floor: 4.5),
  // The three tags: held, due, paid.
  (what: 'held tag', fg: p.neutral100, bg: p.neutral800, floor: 4.5),
  (what: 'paid tag', fg: p.accent100, bg: p.accent800, floor: 4.5),
  (what: 'due tag', fg: p.accent200, bg: p.accent900, floor: 4.5),
  // The rail monogram sits on its own accent chip.
  (what: 'monogram on chip', fg: p.accent300, bg: p.accent800, floor: 4.5),
  // Solid actions: the label has to read on the fill.
  (what: 'label on main action', fg: p.onAccent, bg: p.accentFill, floor: 4.5),
  (what: 'label on payment', fg: p.onSuccess, bg: p.success, floor: 4.5),
  (what: 'label on warning', fg: p.onWarning, bg: p.warning, floor: 4.5),
  (what: 'label on delete', fg: p.onDanger, bg: p.danger, floor: 4.5),
  // Section titles in the warm highlight.
  (what: 'highlight on bg', fg: p.highlight, bg: p.bg, floor: 4.5),
  (what: 'highlight on panel', fg: p.highlight, bg: p.panel, floor: 4.5),
  (what: 'highlight on surface', fg: p.highlight, bg: p.surface, floor: 4.5),
  // Status tags, and the same inks set straight on the ground.
  (what: 'success tag', fg: p.successInk, bg: p.successSoft, floor: 4.5),
  (what: 'warning tag', fg: p.warningInk, bg: p.warningSoft, floor: 4.5),
  (what: 'danger tag', fg: p.dangerInk, bg: p.dangerSoft, floor: 4.5),
  (what: 'success ink on panel', fg: p.successInk, bg: p.panel, floor: 4.5),
  (what: 'warning ink on panel', fg: p.warningInk, bg: p.panel, floor: 4.5),
  (what: 'danger ink on surface', fg: p.dangerInk, bg: p.surface, floor: 4.5),
  (what: 'danger ink on panel', fg: p.dangerInk, bg: p.panel, floor: 4.5),
];

/// The ink alphas the app actually asks for, and what each one is for.
const _inkAlphas = <double>[0.55, 0.6, 0.7, 0.8, 0.85];
const _tintAlphas = <double>[0.04, 0.06, 0.08, 0.1, 0.12, 0.16, 0.2];

void main() {
  // The day palette is derived from the night one by matching contrast, so
  // most of what is asserted below is a comparison between the two rather than
  // a number picked in advance.
  group('palettes', () {
    for (final palette in [NPalette.nocturne, NPalette.daylight]) {
      group(palette.name, () {
        test('carries its text at the contrast the design needs', () {
          for (final pair in _pairs(palette)) {
            final ratio = _contrast(pair.fg, pair.bg);
            expect(
              ratio,
              greaterThanOrEqualTo(pair.floor),
              reason:
                  '${palette.name}: ${pair.what} is ${ratio.toStringAsFixed(2)}:1, '
                  'below ${pair.floor}:1',
            );
          }
        });

        test('hairlines and hover tints stay hairlines', () {
          for (final alpha in _tintAlphas) {
            final edge = _over(palette.ink(alpha), palette.bg);
            expect(
              _contrast(edge, palette.bg),
              lessThan(2.0),
              reason:
                  '${palette.name}: ink($alpha) reads as ink, not as an edge',
            );
          }
        });

        test('the scrim sets the screen back behind a dialog', () {
          final behind = _over(palette.scrim, palette.bg);
          expect(
            _contrast(behind, palette.bg),
            greaterThan(1.1),
            reason: '${palette.name}: the backdrop leaves the screen as it was',
          );
        });
      });
    }

    test('the night palette quotes alphas exactly as it is asked', () {
      for (final alpha in [..._inkAlphas, ..._tintAlphas]) {
        expect(NPalette.nocturne.ink(alpha).a, closeTo(alpha, 1e-6));
        expect(NPalette.nocturne.tint(alpha).a, closeTo(alpha, 1e-6));
      }
    });

    test('the day palette reads no weaker than the night one', () {
      // What a second palette has to promise: a label muted to some step is
      // the same strength of label whichever ground it is on. Measured on
      // each ground role, since the two palettes step away from theirs
      // differently.
      const grounds = ['bg', 'panel', 'surface'];
      for (final alpha in _inkAlphas) {
        for (var i = 0; i < grounds.length; i++) {
          Color groundOf(NPalette p) => [p.bg, p.panel, p.surface][i];
          double strength(NPalette p) {
            final ground = groundOf(p);
            return _contrast(_over(p.ink(alpha), ground), ground);
          }

          final night = strength(NPalette.nocturne);
          final day = strength(NPalette.daylight);
          expect(
            day,
            greaterThan(night * 0.95),
            reason:
                'ink($alpha) on ${grounds[i]} reads at '
                '${day.toStringAsFixed(2)}:1 by day against '
                '${night.toStringAsFixed(2)}:1 at night',
          );
        }
      }
    });

    test('the day palette thickens ink and holds back tints', () {
      // Dark ink on a pale ground fades faster, so the same request has to
      // buy more of it...
      for (final alpha in _inkAlphas) {
        expect(
          NPalette.daylight.ink(alpha).a,
          greaterThan(alpha),
          reason: 'ink($alpha) was not strengthened for the pale ground',
        );
      }
      // ...while a black hairline already reads stronger than a white one.
      for (final alpha in _tintAlphas) {
        expect(
          NPalette.daylight.ink(alpha).a,
          lessThan(alpha),
          reason: 'tint($alpha) was not held back for the pale ground',
        );
      }
    });

    test('the ramps step the same way from either ground', () {
      for (final palette in [NPalette.nocturne, NPalette.daylight]) {
        final neutrals = [
          palette.neutral100,
          palette.neutral200,
          palette.neutral300,
          palette.neutral400,
          palette.neutral500,
          palette.neutral600,
          palette.neutral700,
          palette.neutral800,
          palette.neutral900,
        ];
        // 100 is furthest from the ground and 900 nearest it, whichever way
        // round the ground is.
        final distances = [
          for (final step in neutrals) _contrast(step, palette.bg),
        ];
        for (var i = 1; i < distances.length; i++) {
          expect(
            distances[i],
            lessThan(distances[i - 1]),
            reason:
                '${palette.name}: neutral${(i + 1) * 100} is not nearer the '
                'ground than neutral${i * 100}',
          );
        }
      }
    });
  });

  group('the appearance setting', () {
    test('resolves the device brightness only when asked to', () {
      expect(NThemeMode.day.resolve(Brightness.dark), NPalette.daylight);
      expect(NThemeMode.night.resolve(Brightness.light), NPalette.nocturne);
      expect(NThemeMode.system.resolve(Brightness.light), NPalette.daylight);
      expect(NThemeMode.system.resolve(Brightness.dark), NPalette.nocturne);
    });

    test('a workshop that has never chosen opens in daylight', () {
      expect(NThemeMode.byName(null), NThemeMode.day);
      expect(NThemeMode.byName('a mode from a later version'), NThemeMode.day);
      expect(NThemeMode.byName('day'), NThemeMode.day);
    });

    test('remembers what was chosen', () async {
      final store = InMemoryThemeStore();
      final controller = ThemeController(store: store);

      controller.setMode(NThemeMode.day);
      expect(await store.load(), NThemeMode.day);

      final next = ThemeController(store: store);
      await next.load();
      expect(next.mode, NThemeMode.day);
    });
  });

  group('the app in daylight', () {
    setUp(() => N.palette = NPalette.nocturne);
    tearDown(() => N.palette = NPalette.nocturne);

    testWidgets('opens on the day palette', (tester) async {
      await tester.pumpWidget(HisapApp(model: BillingModel().withDemoBill()));
      await tester.pumpAndSettle();

      expect(N.palette, NPalette.daylight);
    });

    testWidgets('repaints the whole app when the setting changes', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1194, 834);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final theme = ThemeController(
        store: InMemoryThemeStore(),
        mode: NThemeMode.night,
      );
      await tester.pumpWidget(
        HisapApp(theme: theme, model: BillingModel().withDemoBill()),
      );
      await tester.pumpAndSettle();

      ColoredBox ground() => tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(BillingShell),
              matching: find.byType(ColoredBox),
            )
            .first,
      );

      expect(ground().color, NPalette.nocturne.bg);

      theme.setMode(NThemeMode.day);
      await tester.pumpAndSettle();

      expect(N.palette, NPalette.daylight);
      expect(ground().color, NPalette.daylight.bg);
    });

    testWidgets('reaches the night palette from the settings screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(HisapApp(model: BillingModel().withDemoBill()));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Settings').first);
      await tester.pumpAndSettle();
      expect(find.byType(WorkshopSettingsScreen), findsOneWidget);

      // The settings screen has a scrollable per text field as well as the
      // list, so the list is named rather than guessed at.
      await tester.dragUntilVisible(
        find.text('Night'),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(find.text('Night'));
      await tester.pumpAndSettle();

      expect(N.palette, NPalette.nocturne);
    });

    testWidgets('prints the invoice on paper whichever palette is on', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1194, 834);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final theme = ThemeController(
        store: InMemoryThemeStore(),
        mode: NThemeMode.day,
      );
      await tester.pumpWidget(
        HisapApp(theme: theme, model: BillingModel().withDemoBill()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Print invoice'));
      await tester.pumpAndSettle();

      // The sheet is a picture of what the printer puts on A4, so it is the
      // one thing the day palette must not touch.
      final sheet = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(InvoicePage),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = sheet.decoration! as BoxDecoration;
      expect(decoration.color, InvoicePage.paper);
    });
  });
}
