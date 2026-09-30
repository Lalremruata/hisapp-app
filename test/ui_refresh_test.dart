import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisap_app_2_0/main.dart';
import 'package:hisap_app_2_0/screens/bills_screen.dart';
import 'package:hisap_app_2_0/screens/invoice_a4.dart';
import 'package:hisap_app_2_0/screens/rate_card_screen.dart';
import 'package:hisap_app_2_0/screens/workshop_settings_screen.dart';
import 'package:hisap_app_2_0/state/billing_model.dart';
import 'package:hisap_app_2_0/state/theme_store.dart';
import 'package:hisap_app_2_0/theme/components.dart';
import 'package:hisap_app_2_0/theme/nocturne.dart';

import 'support/demo_bill.dart';

const _tablet = Size(1194, 834);
const _phone = Size(390, 844);

extension on WidgetTester {
  Future<ThemeController> pumpApp(
    Size size, {
    NThemeMode mode = NThemeMode.day,
    NTextSize textSize = NTextSize.normal,
    TabletLayout layout = TabletLayout.search,
    BillingModel? model,
  }) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
    final theme = ThemeController(
      store: InMemoryThemeStore(),
      mode: mode,
      textSize: textSize,
      tabletLayout: layout,
    );
    await pumpWidget(
      HisapApp(theme: theme, model: model ?? BillingModel().withDemoBill()),
    );
    await pumpAndSettle();
    return theme;
  }

  Future<void> open(String label) async {
    await tap(find.bySemanticsLabel(label).first);
    await pumpAndSettle();
  }

  Future<void> back() async {
    await tap(find.bySemanticsLabel('Back').first);
    await pumpAndSettle();
  }
}

void main() {
  tearDown(() => N.palette = NPalette.daylight);

  // Every screen, at the largest text, in both palettes, on both sizes. A
  // label that no longer fits throws a RenderFlex overflow, which fails the
  // test — so this is the check that "Extra large" is usable, not just set.
  group('extra-large text fits', () {
    for (final mode in [NThemeMode.day, NThemeMode.night]) {
      for (final layout in TabletLayout.values) {
        testWidgets('tablet ${layout.name} layout, ${mode.name}', (
          tester,
        ) async {
          await tester.pumpApp(
            _tablet,
            mode: mode,
            textSize: NTextSize.extraLarge,
            layout: layout,
          );
          expect(tester.takeException(), isNull);

          await tester.open('Bills');
          expect(find.byType(BillsScreen), findsOneWidget);
          await tester.back();

          await tester.open('Parts');
          expect(find.byType(RateCardScreen), findsOneWidget);
          await tester.back();

          await tester.open('Settings');
          expect(find.byType(WorkshopSettingsScreen), findsOneWidget);
          await tester.back();

          await tester.tap(find.widgetWithText(NButton, 'Take payment'));
          await tester.pumpAndSettle();
          expect(find.text('How was it paid?'), findsOneWidget);
          await tester.tap(find.widgetWithText(NButton, 'Mark paid'));
          await tester.pumpAndSettle();
          expect(find.byType(InvoiceA4Screen), findsOneWidget);
        });
      }

      testWidgets('phone, ${mode.name}', (tester) async {
        await tester.pumpApp(
          _phone,
          mode: mode,
          textSize: NTextSize.extraLarge,
        );
        expect(find.textContaining('Charge'), findsOneWidget);

        await tester.open('Bills');
        await tester.back();
        await tester.open('Parts');
        await tester.back();
        await tester.open('Settings');
        await tester.back();

        await tester.tap(
          find.bySemanticsLabel(RegExp('^Vehicle and customer')).first,
        );
        await tester.pumpAndSettle();
        expect(find.text('Registration no.'), findsOneWidget);
      });
    }
  });

  group('the text-size setting', () {
    testWidgets('enlarges the counter but not the printed sheet', (
      tester,
    ) async {
      final theme = await tester.pumpApp(_tablet);
      double scaleOf(Finder finder) =>
          MediaQuery.textScalerOf(tester.element(finder)).scale(10) / 10;

      expect(scaleOf(find.text('Add to bill')), closeTo(1.0, 1e-6));

      theme.setTextSize(NTextSize.extraLarge);
      await tester.pumpAndSettle();
      expect(scaleOf(find.text('Add to bill')), closeTo(1.3, 1e-6));

      await tester.tap(find.text('Print invoice'));
      await tester.pumpAndSettle();
      expect(scaleOf(find.text('TAX INVOICE')), closeTo(1.0, 1e-6));
    });

    testWidgets('is remembered', (tester) async {
      final store = InMemoryThemeStore();
      ThemeController(store: store).setTextSize(NTextSize.large);
      final next = ThemeController(store: store);
      await next.load();
      expect(next.textSize, NTextSize.large);
    });
  });

  group('taking a line off', () {
    testWidgets('can be undone from the message that says so', (tester) async {
      final model = BillingModel().withDemoBill();
      await tester.pumpApp(_tablet, model: model);
      final before = model.lines.length;
      final total = model.totalLabel;
      final first = model.lines.first.name;

      await tester.tap(find.bySemanticsLabel('Remove $first'));
      await tester.pump();
      expect(model.lines.length, before - 1);
      expect(find.text('Removed $first'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(model.lines.length, before);
      expect(model.lines.first.name, first);
      expect(model.totalLabel, total);
      expect(find.text('Removed $first'), findsNothing);
    });

    testWidgets('by − at one is offered back too', (tester) async {
      final model = BillingModel().withDemoBill();
      await tester.pumpApp(_phone, model: model);
      final line = model.lines.first;
      for (var i = line.qty; i > 1; i--) {
        model.bump(line.index, -1);
      }
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('One fewer ${line.name}'));
      await tester.pump();
      expect(find.text('Removed ${line.name}'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(model.lines.first.name, line.name);
    });

    testWidgets('the message goes by itself', (tester) async {
      final model = BillingModel().withDemoBill();
      await tester.pumpApp(_tablet, model: model);
      final first = model.lines.first.name;

      await tester.tap(find.bySemanticsLabel('Remove $first'));
      await tester.pump();
      expect(find.text('Removed $first'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Removed $first'), findsNothing);
    });
  });

  test('no screen sets text below 13px', () {
    // The printed sheet is exempt: it is drawn at A4 size, not read at arm's
    // length on a tablet.
    final sources = [
      ...Directory('lib/screens').listSync(),
      ...Directory('lib/widgets').listSync(),
    ].whereType<File>().where((f) => !f.path.endsWith('invoice_a4.dart'));
    final small = RegExp(r'\bsize: (\d+(?:\.\d+)?)\b');

    for (final file in sources) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Icon and box sizes are not type.
        if (!line.contains('N.font(') &&
            !line.contains('N.caption(') &&
            !line.contains('N.label(') &&
            !(i > 0 && lines[i - 1].trimRight().endsWith('N.font('))) {
          continue;
        }
        for (final match in small.allMatches(line)) {
          expect(
            double.parse(match.group(1)!),
            greaterThanOrEqualTo(13),
            reason: '${file.path}:${i + 1} sets text at ${match.group(1)}px',
          );
        }
      }
    }
  });
}
