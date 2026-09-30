import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisap_app_2_0/main.dart';
import 'package:hisap_app_2_0/screens/invoice_a4.dart';
import 'package:hisap_app_2_0/screens/phone_billing.dart';
import 'package:hisap_app_2_0/screens/bills_screen.dart';
import 'package:hisap_app_2_0/screens/rate_card_screen.dart';
import 'package:hisap_app_2_0/screens/workshop_settings_screen.dart';
import 'package:hisap_app_2_0/screens/tablet_keypad_billing.dart';
import 'package:hisap_app_2_0/screens/tablet_rail_billing.dart';
import 'package:hisap_app_2_0/state/backup.dart';
import 'package:hisap_app_2_0/state/theme_store.dart';
import 'package:hisap_app_2_0/theme/components.dart';
import 'package:hisap_app_2_0/widgets/suggestions.dart';
import 'package:hisap_app_2_0/widgets/vehicle_panel.dart';
import 'package:hisap_app_2_0/state/billing_model.dart';
import 'support/demo_bill.dart';

/// The artboard sizes the design is drawn at.
const _tablet = Size(1194, 834);
const _phone = Size(390, 844);

extension on WidgetTester {
  /// Renders the app at [size] in logical pixels, the way the artboard is,
  /// with the tablet set to bill on [layout]. The demo job is on the counter
  /// unless [blank] asks for the app as it really opens.
  Future<void> pumpAppAt(
    Size size, {
    TabletLayout layout = TabletLayout.search,
    bool blank = false,
  }) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
    await pumpWidget(
      HisapApp(
        model: blank ? null : BillingModel().withDemoBill(),
        theme: ThemeController(
          store: InMemoryThemeStore(),
          tabletLayout: layout,
        ),
      ),
    );
    await pumpAndSettle();
  }

  /// Brings up an on-screen keyboard [height] tall, the way the platform
  /// reports one: as an inset at the bottom of the view.
  Future<void> raiseKeyboard(double height) async {
    view.viewInsets = FakeViewPadding(bottom: height);
    addTearDown(view.resetViewInsets);
    await pumpAndSettle();
  }
}

/// The search box, found by key rather than by position — the vehicle panel
/// puts five fields above it.
final _search = find.byKey(const ValueKey('search-field'));
final _newItemName = find.byKey(const ValueKey('new-item-name'));
final _newItemRate = find.byKey(const ValueKey('new-item-rate'));

/// The dialog's own confirm button — the screen behind it has one with the
/// same label, sitting under the modal barrier.
final _confirmNewItem = find.descendant(
  of: find.byType(NDialog),
  matching: find.widgetWithText(NButton, 'Add to bill'),
);

/// Switches the new-item form from Labour, which it opens on, to Part.
Future<void> _choosePart(WidgetTester tester) async {
  await tester.tap(
    find.descendant(of: find.byType(NDialog), matching: find.text('Part')),
  );
  await tester.pump();
}

void main() {
  group('tablet, 1194 x 834', () {
    testWidgets('the keyboard does not cover the settings form', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);
      await tester.tap(find.bySemanticsLabel('Settings').first);
      await tester.pumpAndSettle();

      // The last field of the form, scrolled only just into view — where the
      // keyboard will land on top of it.
      final prefix = find.descendant(
        of: find.widgetWithText(NField, 'Invoice numbers start with'),
        matching: find.byType(EditableText),
      );
      await tester.dragUntilVisible(
        prefix,
        find.byType(ListView),
        const Offset(0, -80),
      );
      await tester.pumpAndSettle();
      await tester.tap(prefix);
      await tester.pump();

      const keyboard = 380.0;
      await tester.raiseKeyboard(keyboard);

      expect(
        tester.getRect(prefix).bottom,
        lessThan(_tablet.height - keyboard),
      );
    });

    testWidgets('the app opens on a blank bill', (tester) async {
      await tester.pumpAppAt(_tablet, blank: true);

      expect(find.textContaining('Nothing on this bill yet.'), findsOneWidget);
      expect(find.text('0 items on this bill'), findsOneWidget);
    });

    testWidgets('opens on the search layout with the bill priced', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);

      expect(find.byType(TabletRailBilling), findsOneWidget);
      // The title and the New bill action both read "New bill".
      expect(find.textContaining('Invoice INV/26-27/0148'), findsOneWidget);
      expect(find.text('Engine Oil 5W-30 (3.5 L)'), findsOneWidget);

      // 1,450 + 320 fitted and 350 + 400 of work, all at 18%: 2,973.60.
      expect(find.text('₹2,520.00'), findsOneWidget);
      expect(find.text('₹2,974'), findsOneWidget);
    });

    testWidgets('+ and − reprice the bill', (tester) async {
      await tester.pumpAppAt(_tablet);

      // The atta line's + button: the first stepper in the table.
      await tester.tap(find.text('+').first);
      await tester.pump();

      expect(find.text('₹3,970.00'), findsOneWidget); // taxable
      expect(find.text('₹4,685'), findsOneWidget); // payable
    });

    testWidgets('typing shows suggestions and adding clears the box', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);

      await tester.enterText(_search, 'coolant');
      await tester.pump();
      expect(find.textContaining('HSN 3820'), findsWidgets);

      await tester.tap(find.text('Add to bill'));
      await tester.pumpAndSettle();
      expect(find.textContaining('in stock'), findsNothing);
    });

    testWidgets('with the keyboard up, every match can be reached and '
        'the line it adds shows above the keyboard', (tester) async {
      await tester.pumpAppAt(_tablet);
      await tester.tap(_search);
      await tester.pump();

      const keyboard = 380.0;
      final keyboardTop = _tablet.height - keyboard;
      await tester.raiseKeyboard(keyboard);

      // The vehicle folds away to leave the room to the search.
      expect(find.byType(VehicleSummaryRow), findsNothing);

      // "e" matches five items: the list stops at the keyboard and scrolls.
      await tester.enterText(_search, 'e');
      await tester.pump();
      final list = find.byType(SuggestionList);
      expect(tester.getRect(list).bottom, lessThanOrEqualTo(keyboardTop));

      final last = find.text('Wiper Blade Pair');
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      expect(last.hitTestable(), findsOneWidget);
      expect(tester.getRect(last).bottom, lessThanOrEqualTo(keyboardTop));

      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(list, findsNothing);
      expect(tester.getRect(last).bottom, lessThanOrEqualTo(keyboardTop));

      // And it all comes back when the keyboard goes.
      await tester.raiseKeyboard(0);
      expect(find.byType(VehicleSummaryRow), findsOneWidget);
      expect(find.text('Print invoice'), findsOneWidget);
    });

    testWidgets('tapping the search box brings back a keyboard that was '
        'put away', (tester) async {
      await tester.pumpAppAt(_tablet);
      await tester.tap(_search);
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);

      // The system's hide key: the keyboard goes, the box keeps its focus.
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      expect(tester.testTextInput.isVisible, isFalse);

      await tester.tap(_search);
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);
    });

    testWidgets('the layout setting reaches the keypad design', (tester) async {
      await tester.pumpAppAt(_tablet);

      await tester.tap(find.bySemanticsLabel('Settings').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Keypad'));
      await tester.tap(find.text('Keypad'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Back').first);
      await tester.pumpAndSettle();

      expect(find.byType(TabletKeypadBilling), findsOneWidget);
      expect(find.text('Now adding'.toUpperCase()), findsOneWidget);
      // Once as the chip on the row, once as the draft it loaded.
      // On the chip row, in the draft, and on the bill it is already part of.
      expect(find.text('Engine oil change'), findsNWidgets(3));
    });

    testWidgets('the keypad types into the targeted box', (tester) async {
      await tester.pumpAppAt(_tablet, layout: TabletLayout.keypad);

      await tester.tap(find.text('C'));
      await tester.pump();
      await tester.tap(find.text('7'));
      await tester.pump();

      // The quantity box is targeted on open, so 7 lands there.
      expect(find.text('7'), findsWidgets);
      expect(find.text('350'), findsOneWidget); // the rate is untouched
    });
  });

  group('phone, 390 x 844', () {
    testWidgets('the keyboard does not cover a dialog\'s fields', (
      tester,
    ) async {
      await tester.pumpAppAt(_phone);
      await tester.tap(find.byType(VehicleSummaryRow));
      await tester.pumpAndSettle();
      expect(find.byType(NDialog), findsOneWidget);

      // The dialog's last field, nearest the bottom of the screen.
      final phoneField = find
          .descendant(
            of: find.byType(NDialog),
            matching: find.byType(EditableText),
          )
          .last;
      await tester.tap(phoneField);
      await tester.pump();

      const keyboard = 330.0;
      await tester.raiseKeyboard(keyboard);

      expect(
        tester.getRect(phoneField).bottom,
        lessThan(_phone.height - keyboard),
      );
    });

    testWidgets('with the keyboard up, the list gets the room and the '
        'line just added comes into view', (tester) async {
      await tester.pumpAppAt(_phone);
      await tester.tap(_search);
      await tester.pump();

      const keyboard = 330.0;
      final keyboardTop = _phone.height - keyboard;
      await tester.raiseKeyboard(keyboard);

      // Only the total stays of the charge bar, and the vehicle folds away.
      expect(find.textContaining('Charge'), findsNothing);
      expect(find.text('Total'), findsOneWidget);
      expect(find.byType(VehicleSummaryRow), findsNothing);

      await tester.enterText(_search, 'e');
      await tester.pump();
      expect(
        tester.getRect(find.byType(SuggestionList)).bottom,
        lessThanOrEqualTo(keyboardTop),
      );

      // Labour lands at the foot of the bill, below what is showing.
      await tester.enterText(_search, 'clutch overhaul');
      await tester.pump();
      await tester.tap(find.text('Clutch overhaul'));
      await tester.pumpAndSettle();

      final added = find.text('Clutch overhaul');
      expect(added.hitTestable(), findsOneWidget);
      expect(tester.getRect(added).bottom, lessThanOrEqualTo(keyboardTop));

      await tester.raiseKeyboard(0);
      expect(find.textContaining('Charge'), findsOneWidget);
    });

    testWidgets('falls back to the one-thumb layout', (tester) async {
      await tester.pumpAppAt(_phone);

      expect(find.byType(PhoneBilling), findsOneWidget);
      expect(find.byType(TabletRailBilling), findsNothing);
      expect(find.textContaining('Charge'), findsOneWidget);
    });

    testWidgets('reaches the store settings and saves a change', (
      tester,
    ) async {
      await tester.pumpAppAt(_phone);

      await tester.tap(find.bySemanticsLabel('Settings').first);
      await tester.pumpAndSettle();
      expect(find.byType(WorkshopSettingsScreen), findsOneWidget);
      expect(
        find.text('Looks like a valid 15-character GSTIN'),
        findsOneWidget,
      );

      // Switching to inclusive rates backs the GST out of the same gross.
      // Below the screen settings, so scrolled to rather than assumed.
      await tester.dragUntilVisible(
        find.text('Rates include GST'),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rates include GST'));
      await tester.pump();

      await tester.ensureVisible(find.text('Save details'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save details'));
      await tester.pumpAndSettle();

      expect(find.byType(PhoneBilling), findsOneWidget);
      // The taxable value drops — the gross the owner pays does not.
      expect(find.text('₹2,520.00'), findsNothing);
      expect(find.text('₹2,135.59'), findsOneWidget);
      expect(find.text('Charge ₹2,520'), findsOneWidget);
    });

    testWidgets('an ill-formed GSTIN loses the valid hint', (tester) async {
      await tester.pumpAppAt(_phone);
      await tester.tap(find.bySemanticsLabel('Settings').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText).at(1), 'nope');
      await tester.pump();
      expect(find.text('Looks like a valid 15-character GSTIN'), findsNothing);
      expect(find.textContaining('15 characters, like'), findsOneWidget);
    });

    testWidgets('undoes an import, and the form follows', (tester) async {
      tester.view.physicalSize = _phone;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final model = BillingModel().withDemoBill();
      final other = BillingModel();
      other.updateSettings(other.settings.copyWith(name: 'Zote Motors'));
      await model.restore(other.backup(), RestoreMode.replace);

      await tester.pumpWidget(
        HisapApp(
          model: model,
          theme: ThemeController(store: InMemoryThemeStore()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Settings').first);
      await tester.pumpAndSettle();
      expect(find.text('Zote Motors'), findsOneWidget);

      await tester.dragUntilVisible(
        find.text('Undo last import'),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.ensureVisible(find.text('Undo last import'));
      await tester.pumpAndSettle();
      expect(find.text('Export backup'), findsOneWidget);
      expect(find.text('Export bills for accountant (CSV)'), findsOneWidget);
      await tester.tap(find.text('Undo last import'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo import'));
      await tester.pumpAndSettle();

      expect(model.settings.name, 'LC Automobiles');
      // The form shows what is stored now, so saving it keeps the undo.
      await tester.drag(find.byType(ListView), const Offset(0, 3000));
      await tester.pumpAndSettle();
      expect(find.text('LC Automobiles'), findsOneWidget);
      expect(find.text('Zote Motors'), findsNothing);
      expect(find.text('Undo last import'), findsNothing);
    });
  });

  group('the printed invoice', () {
    testWidgets('prints the bill with the HSN, the split and the words', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);

      await tester.tap(find.text('Print invoice'));
      await tester.pumpAndSettle();

      expect(find.byType(InvoiceA4Screen), findsOneWidget);
      expect(find.text('TAX INVOICE'), findsOneWidget);
      expect(find.text('INV/26-27/0148'), findsOneWidget);
      expect(find.textContaining('GSTIN 23ABCDE1234F1Z5'), findsOneWidget);
      expect(find.text('2710'), findsOneWidget); // the engine oil's HSN
      expect(
        find.text('Rupees Two Thousand Nine Hundred Seventy Four only'),
        findsOneWidget,
      );
    });
  });

  group('the invoice with bank details', () {
    testWidgets('shows the bank block and the UPI code', (tester) async {
      tester.view.physicalSize = _tablet;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final model = BillingModel().withDemoBill()
        ..updateSettings(
          const WorkshopSettings(
            bankName: 'State Bank Of India',
            accountNo: '000012345678',
            ifsc: 'SBIN0000001',
            upiId: 'workshop@upi',
          ),
        );
      await tester.pumpWidget(
        HisapApp(
          model: model,
          theme: ThemeController(store: InMemoryThemeStore()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Print invoice'));
      await tester.pumpAndSettle();

      expect(find.text('BANK DETAILS'), findsOneWidget);
      expect(find.textContaining('000012345678'), findsOneWidget);
      expect(find.byType(UpiQr), findsOneWidget);
      expect(find.text('workshop@upi'), findsOneWidget);
    });
  });

  group('an item that is not on the list', () {
    testWidgets('a search with no match offers to create it', (tester) async {
      await tester.pumpAppAt(_tablet);

      await tester.enterText(_search, 'Fuel Filter');
      await tester.pump();

      expect(find.text('Add "Fuel Filter" as a new item'), findsOneWidget);
      expect(find.text('not on your rate card'), findsOneWidget);
    });

    testWidgets('creating it bills it and reprices the total', (tester) async {
      await tester.pumpAppAt(_tablet);

      await tester.enterText(_search, 'Fuel Filter');
      await tester.pump();
      await tester.tap(find.text('Add "Fuel Filter" as a new item'));
      await tester.pumpAndSettle();

      // The form opens on Labour, with the typed name already in it; a
      // filter is a part, so that is chosen.
      expect(find.text('New job'), findsOneWidget);
      expect(find.text('Fuel Filter'), findsWidgets);
      // A job starts with the vehicle-repair SAC; a part has no default code.
      final code = find.descendant(
        of: find.byKey(const ValueKey('new-item-code')),
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(code).controller.text, '998714');
      await _choosePart(tester);
      expect(find.text('New part'), findsOneWidget);
      expect(tester.widget<EditableText>(code).controller.text, isEmpty);

      // Nothing to add until there is a rate.
      expect(tester.widget<NButton>(_confirmNewItem).onPressed, isNull);

      await tester.enterText(_newItemRate, '780');
      await tester.pump();
      expect(tester.widget<NButton>(_confirmNewItem).onPressed, isNotNull);

      await tester.tap(_confirmNewItem);
      await tester.pumpAndSettle();

      // 2,520 + 780 taxable; the part takes the 28% a part defaults to.
      expect(find.text('\u20B93,300.00'), findsOneWidget);
      expect(find.text('\u20B93,972'), findsOneWidget);
      expect(find.text('Fuel Filter'), findsOneWidget);
    });

    testWidgets('it is an ordinary suggestion afterwards', (tester) async {
      await tester.pumpAppAt(_tablet);

      await tester.enterText(_search, 'Fuel Filter');
      await tester.pump();
      await tester.tap(find.text('Add "Fuel Filter" as a new item'));
      await tester.pumpAndSettle();
      await _choosePart(tester);
      await tester.enterText(_newItemRate, '780');
      await tester.pump();
      await tester.tap(_confirmNewItem);
      await tester.pumpAndSettle();

      await tester.enterText(_search, 'fuel');
      await tester.pump();

      expect(find.text('Add "fuel" as a new item'), findsNothing);
      // No stock count is claimed for something nobody counted.
      expect(find.text('GST 28%'), findsOneWidget);
      expect(find.textContaining('in stock'), findsNothing);
    });

    testWidgets('Cancel leaves the bill and the list alone', (tester) async {
      await tester.pumpAppAt(_tablet);

      await tester.enterText(_search, 'Fuel Filter');
      await tester.pump();
      await tester.tap(find.text('Add "Fuel Filter" as a new item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('New job'), findsNothing);
      expect(find.text('\u20B92,974'), findsOneWidget);
    });

    testWidgets('the keypad screen reaches the same form', (tester) async {
      await tester.pumpAppAt(_tablet, layout: TabletLayout.keypad);

      expect(find.text('+ Other item'), findsOneWidget);
      await tester.tap(find.text('+ Other item'));
      await tester.pumpAndSettle();

      // Towing is work, which is what the form opens on — and switching to
      // Part and back lands on it again.
      expect(find.text('New job'), findsOneWidget);
      await _choosePart(tester);
      expect(find.text('New part'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(NDialog),
          matching: find.text('Labour'),
        ),
      );
      await tester.pump();
      expect(find.text('New job'), findsOneWidget);

      await tester.enterText(_newItemName, 'Towing charge');
      await tester.pump();
      await tester.enterText(_newItemRate, '1500');
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(NDialog),
          matching: find.widgetWithText(NButton, 'Use this item'),
        ),
      );
      await tester.pumpAndSettle();

      // It lands in the draft, ready for a quantity, rather than on the bill.
      expect(find.text('Towing charge'), findsOneWidget);
      expect(find.text('1500'), findsOneWidget);
    });

    testWidgets('the phone offers it too', (tester) async {
      await tester.pumpAppAt(_phone);

      await tester.enterText(_search, 'brake fluid');
      await tester.pump();
      expect(find.text('Add "brake fluid" as a new item'), findsOneWidget);
    });
  });

  group('the rate card', () {
    Future<void> openRateCard(WidgetTester tester) async {
      await tester.tap(find.bySemanticsLabel('Parts').first);
      await tester.pumpAndSettle();
    }

    /// Filters down to one row, which is both how the card is meant to be
    /// used and what keeps the row on screen in a test viewport.
    Future<void> findRow(WidgetTester tester, String query) async {
      await tester.enterText(
        find.byKey(const ValueKey('rate-card-filter')),
        query,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the Parts rail icon opens it, listing parts and jobs', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);
      await openRateCard(tester);

      expect(find.byType(RateCardScreen), findsOneWidget);
      expect(find.text('Rate card'), findsOneWidget);
      expect(find.text('PARTS · 10'), findsOneWidget);
      expect(find.text('Engine Oil 5W-30 (3.5 L)'), findsOneWidget);
      // The jobs follow the parts, further down the list.
      await tester.dragUntilVisible(
        find.text('JOBS · 8'),
        find.descendant(
          of: find.byType(RateCardScreen),
          matching: find.byType(ListView),
        ),
        const Offset(0, -300),
      );
      expect(find.text('JOBS · 8'), findsOneWidget);
    });

    testWidgets('the filter narrows it to what was typed', (tester) async {
      await tester.pumpAppAt(_tablet);
      await openRateCard(tester);

      await tester.enterText(
        find.byKey(const ValueKey('rate-card-filter')),
        'wheel',
      );
      await tester.pump();

      expect(find.text('Wheel alignment'), findsOneWidget);
      expect(find.text('Engine Oil 5W-30 (3.5 L)'), findsNothing);
      expect(find.text('PARTS · 10'), findsNothing);
    });

    testWidgets('repricing a shipped job sticks, and marks it', (tester) async {
      await tester.pumpAppAt(_tablet);
      await openRateCard(tester);
      await findRow(tester, 'alignment');

      await tester.tap(find.text('Wheel alignment'));
      await tester.pumpAndSettle();
      expect(find.text('Edit job'), findsOneWidget);

      // Tapping the rate selects what is there, so typing replaces it rather
      // than running on the end of it.
      await tester.tap(_newItemRate);
      await tester.pumpAndSettle();
      final rate = tester.widget<EditableText>(
        find.descendant(of: _newItemRate, matching: find.byType(EditableText)),
      );
      expect(rate.controller.selection.textInside(rate.controller.text), '500');

      await tester.enterText(_newItemRate, '750');
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(NDialog),
          matching: find.widgetWithText(NButton, 'Save'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₹750.00'), findsOneWidget);
      expect(find.text('Repriced'), findsOneWidget);
    });

    testWidgets('a new price reaches the bill, but not a line already on it', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);
      await openRateCard(tester);

      await findRow(tester, 'oil filter');
      await tester.tap(find.text('Oil Filter'));
      await tester.pumpAndSettle();
      await tester.enterText(_newItemRate, '400');
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(NDialog),
          matching: find.widgetWithText(NButton, 'Save'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Back').first);
      await tester.pumpAndSettle();

      // The filter already on the bill keeps the price it was added at.
      expect(find.text('₹2,974'), findsOneWidget);

      // Adding it again brings the new price, on its own line.
      await tester.enterText(_search, 'Oil Filter');
      await tester.pump();
      await tester.tap(find.text('Add to bill'));
      await tester.pumpAndSettle();
      expect(find.text('₹3,446'), findsOneWidget);
    });

    testWidgets('removing asks first, then offers to put it back', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);
      await openRateCard(tester);
      await findRow(tester, 'alignment');

      await tester.tap(find.text('Wheel alignment'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(NButton, 'Remove'));
      await tester.pumpAndSettle();

      expect(find.text('Remove Wheel alignment?'), findsOneWidget);
      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();
      expect(find.text('Edit job'), findsOneWidget, reason: 'still editing');

      await tester.tap(find.widgetWithText(NButton, 'Remove'));
      await tester.pumpAndSettle();
      // The editor is still behind the confirmation, and has a Remove of its
      // own — take the one inside the dialog that is asking.
      await tester.tap(
        find.descendant(
          of: find.ancestor(
            of: find.text('Remove Wheel alignment?'),
            matching: find.byType(NDialog),
          ),
          matching: find.widgetWithText(NButton, 'Remove'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Wheel alignment'),
        findsOneWidget,
        reason: 'now removed',
      );
      expect(find.text('REMOVED · 1'), findsOneWidget);
      expect(find.text('JOBS · 1'), findsNothing, reason: 'off the card');

      await tester.tap(find.text('Put back'));
      await tester.pumpAndSettle();
      expect(find.text('JOBS · 1'), findsOneWidget);
      expect(find.text('REMOVED · 1'), findsNothing);
    });

    testWidgets('a hand-added item is marked and can be edited', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);
      await openRateCard(tester);

      await tester.tap(find.widgetWithText(NButton, 'New item'));
      await tester.pumpAndSettle();
      await _choosePart(tester);
      await tester.enterText(_newItemName, 'Fuel Filter');
      await tester.pump();
      await tester.enterText(_newItemRate, '780');
      await tester.pump();
      await tester.tap(_confirmNewItem);
      await tester.pumpAndSettle();

      expect(find.text('PARTS · 11'), findsOneWidget);

      await findRow(tester, 'fuel');
      expect(find.text('Yours'), findsOneWidget);
      await tester.tap(find.text('Fuel Filter'));
      await tester.pumpAndSettle();
      expect(find.text('Edit part'), findsOneWidget);
      await tester.enterText(_newItemRate, '870');
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(NDialog),
          matching: find.widgetWithText(NButton, 'Save'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₹870.00'), findsOneWidget);
      expect(
        find.text('PARTS · 1'),
        findsOneWidget,
        reason: 'edited, not added',
      );
    });

    testWidgets('the phone reaches it too', (tester) async {
      await tester.pumpAppAt(_phone);
      await openRateCard(tester);
      expect(find.byType(RateCardScreen), findsOneWidget);
    });
  });

  group('saving and reprinting a bill', () {
    Future<void> openBills(WidgetTester tester) async {
      await tester.tap(find.bySemanticsLabel('Bills').first);
      await tester.pumpAndSettle();
    }

    Future<void> takePayment(WidgetTester tester, String method) async {
      await tester.tap(find.widgetWithText(NButton, 'Take payment'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: find.byType(NDialog), matching: find.text(method)),
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(NButton, 'Mark paid'));
      await tester.pumpAndSettle();
    }

    testWidgets('holding parks the bill and clears the counter', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);

      await tester.tap(find.widgetWithText(NButton, 'Hold bill'));
      await tester.pumpAndSettle();

      expect(find.text('Engine Oil 5W-30 (3.5 L)'), findsNothing);
      expect(find.textContaining('Invoice INV/26-27/0149'), findsOneWidget);

      await openBills(tester);
      expect(find.byType(BillsScreen), findsOneWidget);
      expect(find.text('INV/26-27/0148'), findsOneWidget);
      expect(find.text('Held'), findsOneWidget);
      expect(find.text('₹2,974'), findsOneWidget);
    });

    testWidgets('taking payment records the method and prints it', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);
      await takePayment(tester, 'Cash');

      // Settling opens the invoice, which now prints how it was paid.
      expect(find.byType(InvoiceA4Screen), findsOneWidget);
      expect(find.text('Cash · settled'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back').first);
      await tester.pumpAndSettle();
      expect(find.text('Paid · Cash'), findsWidgets);
    });

    testWidgets('a settled bill can be found and reprinted later', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);
      await takePayment(tester, 'UPI');
      await tester.tap(find.bySemanticsLabel('Back').first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(NButton, 'New bill'));
      await tester.pumpAndSettle();
      expect(find.text('Engine Oil 5W-30 (3.5 L)'), findsNothing);

      await openBills(tester);
      await tester.tap(find.widgetWithText(NButton, 'Print'));
      await tester.pumpAndSettle();

      expect(find.byType(InvoiceA4Screen), findsOneWidget);
      expect(find.text('INV/26-27/0148'), findsOneWidget);
      expect(find.text('UPI · settled'), findsOneWidget);
      expect(
        find.text('Rupees Two Thousand Nine Hundred Seventy Four only'),
        findsOneWidget,
      );
    });

    testWidgets('reopening a paid bill warns before it can be changed', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);
      await takePayment(tester, 'Cash');
      await tester.tap(find.bySemanticsLabel('Back').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(NButton, 'New bill'));
      await tester.pumpAndSettle();

      await openBills(tester);
      await tester.tap(find.text('INV/26-27/0148'));
      await tester.pumpAndSettle();

      expect(find.text('INV/26-27/0148 · Paid'), findsOneWidget);
      expect(
        find.textContaining('already given to the customer'),
        findsOneWidget,
      );

      await tester.tap(find.text('Edit it'));
      await tester.pumpAndSettle();

      // Back on the counter, under its own number, ready to correct.
      expect(find.text('Engine Oil 5W-30 (3.5 L)'), findsOneWidget);
      expect(find.text('Bill INV/26-27/0148'), findsOneWidget);
    });

    testWidgets('a correction keeps the number and does not add a bill', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);
      await tester.tap(find.widgetWithText(NButton, 'Hold bill'));
      await tester.pumpAndSettle();
      await openBills(tester);
      await tester.tap(find.text('INV/26-27/0148'));
      await tester.pumpAndSettle();

      // One more can of oil onto the reopened bill.
      await tester.tap(find.text('+').first);
      await tester.pump();
      // 3,970 taxable at 18% → 4,684.60, rounded.
      expect(find.text('₹4,685'), findsOneWidget);

      await openBills(tester);
      expect(find.text('INV/26-27/0148'), findsOneWidget);
      expect(find.text('INV/26-27/0149'), findsNothing);
      expect(find.text('₹4,685'), findsOneWidget);
    });

    testWidgets('the unpaid filter shows only what is still owed', (
      tester,
    ) async {
      await tester.pumpAppAt(_tablet);
      await takePayment(tester, 'Cash');
      await tester.tap(find.bySemanticsLabel('Back').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(NButton, 'New bill'));
      await tester.pumpAndSettle();

      // A second bill, parked unpaid.
      await tester.enterText(_search, 'Coolant');
      await tester.pump();
      await tester.tap(find.text('Add to bill'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(NButton, 'Hold bill'));
      await tester.pumpAndSettle();

      await openBills(tester);
      expect(find.text('INV/26-27/0148'), findsOneWidget);
      expect(find.text('INV/26-27/0149'), findsOneWidget);

      await tester.tap(find.text('Unpaid'));
      await tester.pumpAndSettle();
      expect(find.text('INV/26-27/0149'), findsOneWidget);
      expect(find.text('INV/26-27/0148'), findsNothing, reason: 'it is paid');
    });

    testWidgets('the phone reaches the list too', (tester) async {
      await tester.pumpAppAt(_phone);
      await tester.tap(find.bySemanticsLabel('Bills').first);
      await tester.pumpAndSettle();
      expect(find.byType(BillsScreen), findsOneWidget);
      expect(find.textContaining('Hold a bill to park it'), findsOneWidget);
    });
  });
}
