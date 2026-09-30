// Renders the README screenshots from the app's own widgets, with sample data,
// so no real workshop's details end up in a picture.
//
//   flutter test tool/screenshots/screenshots_test.dart
//
// Writes PNGs to docs/screenshots/.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisap_app_2_0/main.dart';
import 'package:hisap_app_2_0/models/vehicle.dart';
import 'package:hisap_app_2_0/state/billing_model.dart';
import 'package:hisap_app_2_0/state/theme_store.dart';
import 'package:hisap_app_2_0/theme/nocturne.dart';

import '../../test/support/demo_bill.dart';

const _tablet = Size(1194, 834);
const _phone = Size(390, 844);

/// Rendered at twice the logical size, so the pictures stay sharp on a
/// high-density screen.
const _ratio = 2.0;

/// Made-up details: a sample workshop, bank account and UPI ID.
const _sampleWorkshop = WorkshopSettings(
  name: 'LC Automobiles',
  gstin: '15ABCDE1234F1Z5',
  address: 'Ngaizel Road, Aizawl, Mizoram 796001',
  phone: '0389 290 0000',
  ratesIncludeGst: false,
  accountName: 'LC Automobiles',
  bankName: 'State Bank Of India',
  accountNo: '000012345678',
  bankBranch: 'Main Branch',
  ifsc: 'SBIN0000001',
  upiId: 'workshop@upi',
);

BillingModel _sampleModel() {
  final model = BillingModel()..withDemoBill();
  model.updateSettings(_sampleWorkshop);
  model.updateVehicle(
    const VehicleDetails(
      registration: 'MZ 01 AB 1234',
      makeModel: 'BOLERO',
      odometer: '48210',
      customerName: 'Zoram Transport',
      customerPhone: '98220 41188',
    ),
  );
  return model;
}

Future<void> _loadFonts() async {
  final inter = FontLoader('Inter');
  for (final face in ['Regular', 'Medium', 'SemiBold']) {
    inter.addFont(rootBundle.load('assets/fonts/Inter-$face.ttf'));
  }
  await inter.load();
}

extension on WidgetTester {
  Future<void> pumpApp(
    Size size, {
    TabletLayout layout = TabletLayout.search,
    NThemeMode mode = NThemeMode.day,
  }) async {
    // The test binding flattens shadows into solid bands; draw them as the
    // app does. [save] puts it back before the end-of-test check.
    debugDisableShadows = false;
    view.physicalSize = size * _ratio;
    view.devicePixelRatio = _ratio;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
    await pumpWidget(
      HisapApp(
        model: _sampleModel(),
        theme: ThemeController(
          store: InMemoryThemeStore(),
          tabletLayout: layout,
          mode: mode,
        ),
      ),
    );
    await pumpAndSettle();
  }

  Future<void> save(String name) async {
    final element = find.byType(HisapApp).evaluate().single;
    await runAsync(() async {
      final image = await captureImage(element);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('docs/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    });
    debugDisableShadows = true;
  }
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('tablet billing, search', (tester) async {
    await tester.pumpApp(_tablet);
    await tester.save('tablet-billing');
  });

  testWidgets('tablet billing, keypad', (tester) async {
    await tester.pumpApp(_tablet, layout: TabletLayout.keypad);
    await tester.save('tablet-keypad');
  });

  testWidgets('tablet billing, night', (tester) async {
    await tester.pumpApp(_tablet, mode: NThemeMode.night);
    await tester.save('tablet-night');
  });

  testWidgets('phone billing', (tester) async {
    await tester.pumpApp(_phone);
    await tester.save('phone-billing');
  });

  testWidgets('tax invoice', (tester) async {
    // Tall enough for the whole A4 sheet, bank details and QR included.
    await tester.pumpApp(const Size(1194, 1000));
    await tester.tap(find.text('Print invoice'));
    await tester.pumpAndSettle();
    await tester.save('invoice');
  });

  testWidgets('settings, bank and UPI', (tester) async {
    await tester.pumpApp(_tablet);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('BANK & UPI'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    // The section's heading at the top of the screen, fields below it.
    await tester.runAsync(
      () => Scrollable.ensureVisible(tester.element(find.text('BANK & UPI'))),
    );
    await tester.pumpAndSettle();
    await tester.save('settings-bank');
  });
}
