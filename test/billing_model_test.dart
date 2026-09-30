import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisap_app_2_0/models/bill.dart';
import 'package:hisap_app_2_0/models/catalog.dart';
import 'package:hisap_app_2_0/models/money.dart';
import 'package:hisap_app_2_0/models/vehicle.dart';
import 'package:hisap_app_2_0/state/billing_model.dart';
import 'package:hisap_app_2_0/state/bill_store.dart';
import 'package:hisap_app_2_0/state/item_store.dart';
import 'package:hisap_app_2_0/state/settings_store.dart';

import 'support/demo_bill.dart';

void main() {
  group('money', () {
    test('groups in lakhs and crores, not thousands', () {
      expect(groupIndian(1234567), '12,34,567.00');
      expect(groupIndian(100000), '1,00,000.00');
      expect(groupIndian(999), '999.00');
      expect(groupIndian(12345678900), '12,34,56,78,900.00');
    });

    test('carries the rupee mark and two decimals', () {
      expect(money(285), '₹285.00');
      expect(money(1899.5), '₹1,899.50');
      expect(rupees(1899), '₹1,899');
    });

    test('writes the amount in words for a tax invoice', () {
      expect(amountInWords(0), 'Rupees Zero only');
      expect(amountInWords(21), 'Rupees Twenty One only');
      expect(amountInWords(105), 'Rupees One Hundred Five only');
      expect(
        amountInWords(1234567),
        'Rupees Twelve Lakh Thirty Four Thousand Five Hundred Sixty Seven only',
      );
      expect(amountInWords(10000000), 'Rupees One Crore only');
    });
  });

  group('BillingModel — opening', () {
    test('opens on a blank bill, dated today', () {
      final model = BillingModel();
      expect(model.lines, isEmpty);
      expect(model.lineCount, 0);
      expect(model.vehicle.registration, isEmpty);
      final now = DateTime.now();
      expect(
        DateTime(
          model.invoiceDate.year,
          model.invoiceDate.month,
          model.invoiceDate.day,
        ),
        DateTime(now.year, now.month, now.day),
      );
    });

    test('can be dated back to the day the work was done', () {
      final model = BillingModel().withDemoBill()
        ..updateInvoiceDate(DateTime(2026, 9, 3));
      expect(model.invoiceDateLabel, '3 Sep 2026');
      expect(model.invoiceData.dateLabel, '3 Sep 2026');
    });

    test('cannot be dated after today', () {
      final model = BillingModel()
        ..updateInvoiceDate(DateTime.now().add(const Duration(days: 5)));
      final now = DateTime.now();
      expect(
        model.invoiceDateLabel,
        BillingModel.dateLabel(DateTime(now.year, now.month, now.day)),
      );
    });

    test('a back date sticks to a saved bill and comes back on reopening', () {
      final model = BillingModel().withDemoBill();
      final saved = model.saveBill();
      model.updateInvoiceDate(DateTime(2026, 8, 30));
      expect(model.bills.single.date.day, 30);
      expect(model.bills.single.date.month, 8);

      model.newBill();
      expect(model.invoiceDate.month, isNot(8));
      model.openBill(model.bills.firstWhere((bill) => bill.id == saved.id));
      expect(model.invoiceDateLabel, '30 Aug 2026');
    });
  });

  group('BillingModel — GST', () {
    test('adds GST on top when rates exclude it', () {
      final model = BillingModel().withDemoBill();
      // Oil 1,450 + filter 320 fitted; oil change 350 and four wheels
      // balanced at 100 — everything on this job is 18%.
      expect(model.taxable, closeTo(1450 + 320 + 350 + 400, 0.001));
      expect(model.gstTotal, closeTo((1450 + 320 + 350 + 400) * 0.18, 0.001));
      // CGST and SGST split the slab evenly on an intra-state supply.
      expect(model.cgst, closeTo(model.sgst, 0.0001));
      expect(model.cgst + model.sgst, closeTo(model.gstTotal, 0.0001));
    });

    test('backs GST out of the rate when rates include it', () {
      final model = BillingModel().withDemoBill()
        ..updateSettings(const WorkshopSettings(ratesIncludeGst: true));

      const gross = 1450 + 320 + 350 + 400;
      // The owner pays the quoted figure either way, so the gross is the same
      // — the split moves, not the money at the counter.
      expect(model.taxable + model.gstTotal, closeTo(gross, 0.001));
      expect(model.taxable, lessThan(gross));

      final oil = model.lines.first;
      expect(oil.taxable, closeTo(1450 / 1.18, 0.001));
      expect(oil.tax, closeTo(1450 / 1.18 * 0.18, 0.001));
    });

    test('rounds the payable total to the rupee and shows the difference', () {
      final model = BillingModel().withDemoBill();
      expect(model.total, model.rawTotal.round());
      expect(model.roundOff.abs(), lessThanOrEqualTo(0.5));
      expect(model.roundLabel, anyOf(startsWith('+'), startsWith('−')));
    });

    test('counts pieces rather than lines', () {
      final model = BillingModel().withDemoBill();
      expect(model.lines.length, 4);
      expect(model.lineCount, 1 + 1 + 1 + 4);
    });

    test('splits the job into parts fitted and work done', () {
      final model = BillingModel().withDemoBill();
      expect(model.partLines.map((l) => l.name), [
        'Engine Oil 5W-30 (3.5 L)',
        'Oil Filter',
      ]);
      expect(model.labourLines.map((l) => l.name), [
        'Engine oil change',
        'Wheel balancing (per wheel)',
      ]);
      expect(model.partsTotal, closeTo(1450 + 320, 0.001));
      expect(model.labourTotal, closeTo(350 + 400, 0.001));
      expect(
        model.partsTotal + model.labourTotal,
        closeTo(model.taxable, 0.001),
      );
    });

    test('a part carries an HSN and a job carries a SAC', () {
      final model = BillingModel().withDemoBill();
      expect(model.partLines.first.kind, ItemKind.part);
      expect(model.partLines.first.codeLabel, 'HSN');
      expect(model.partLines.first.code, '2710');

      expect(model.labourLines.first.kind, ItemKind.labour);
      expect(model.labourLines.first.codeLabel, 'SAC');
      expect(model.labourLines.first.code, motorServiceSac);
    });
  });

  group('BillingModel — the bill', () {
    test('merges a repeat of the same item at the same rate', () {
      final model = BillingModel().withDemoBill();
      final before = model.lines.length;
      model.addToCart(seedCatalog[0]); // Engine oil, already on the bill
      expect(model.lines.length, before);
      expect(model.lines.first.qty, 2);
    });

    test('opens a new line when the same item is sold at another rate', () {
      final model = BillingModel().withDemoBill();
      model.addToCart(seedCatalog[0], rate: 1300);
      expect(model.lines.length, 5);
      expect(model.lines.last.rate, 1300);
    });

    test('clears the search box after adding', () {
      final model = BillingModel().withDemoBill()..updateQuery('oil filter');
      model.addFirstSuggestion();
      expect(model.query, '');
      expect(model.lines[1].qty, 2);
    });

    test('takes a line off the bill when its quantity falls below one', () {
      final model = BillingModel().withDemoBill();
      model.bump(1, -1); // the single oil filter
      expect(model.lines.length, 3);
      expect(model.lines.any((l) => l.name.contains('Oil Filter')), isFalse);
    });

    test('suggests at most five matches and none for an empty box', () {
      final model = BillingModel().withDemoBill();
      expect(model.suggestions, isEmpty);
      expect(model.showSuggestions, isFalse);
      expect(model.hasNoMatches, isFalse);

      model.updateQuery('e');
      expect(model.suggestions.length, lessThanOrEqualTo(5));

      model.updateQuery('WHEEL ALIGN');
      expect(model.suggestions.single.name, 'Wheel alignment');
    });

    test('an unmatched query still opens the list, to offer creating it', () {
      final model = BillingModel().withDemoBill()..updateQuery('nothing here');
      expect(model.suggestions, isEmpty);
      // The list opens even with no matches — that is where the row offering
      // to create the item lives.
      expect(model.showSuggestions, isTrue);
      expect(model.hasNoMatches, isTrue);

      model.updateQuery('   ');
      expect(model.showSuggestions, isFalse);
      expect(model.hasNoMatches, isFalse);
    });
  });

  group('BillingModel — the keypad', () {
    test('types digits into whichever box is targeted', () {
      final model = BillingModel().withDemoBill()
        ..setTarget(KeypadTarget.quantity)
        ..pressKey('C')
        ..pressKey('1')
        ..pressKey('2');
      expect(model.qtyText, '12');
      expect(model.rateText, '350');

      model
        ..setTarget(KeypadTarget.rate)
        ..pressKey('C')
        ..pressKey('9')
        ..pressKey('9');
      expect(model.rateText, '99');
      expect(model.qtyText, '12');
    });

    test('backspaces, clears, and keeps one decimal point', () {
      final model = BillingModel().withDemoBill()
        ..setTarget(KeypadTarget.rate)
        ..pressKey('C')
        ..pressKey('1')
        ..pressKey('.')
        ..pressKey('.')
        ..pressKey('5');
      expect(model.rateText, '1.5');

      model.pressKey('⌫');
      expect(model.rateText, '1.');

      model.pressKey('C');
      expect(model.rateText, '');

      // A decimal point on an empty box opens with a zero.
      model.pressKey('.');
      expect(model.rateText, '0.');
    });

    test('replaces a lone leading zero rather than appending to it', () {
      final model = BillingModel().withDemoBill()
        ..setTarget(KeypadTarget.quantity)
        ..pressKey('C')
        ..pressKey('0')
        ..pressKey('7');
      expect(model.qtyText, '7');
    });

    test('a favourite loads the draft and points the keypad at quantity', () {
      final model = BillingModel().withDemoBill()..setTarget(KeypadTarget.rate);
      model.setDraft(seedCatalog[15]); // AC service & gas refill, 1500
      expect(model.draft.name, 'AC service & gas refill');
      expect(model.rateText, '1500');
      expect(model.qtyText, '1');
      expect(model.target, KeypadTarget.quantity);
    });

    test('an empty or zero quantity box still adds one piece', () {
      final model = BillingModel().withDemoBill()
        ..setTarget(KeypadTarget.quantity)
        ..pressKey('C');
      expect(model.draftQty, 1);
    });

    test('the draft total carries GST unless the rate already does', () {
      // Wheel balancing, 100 a wheel at 18%.
      final model = BillingModel().withDemoBill()..setDraft(seedCatalog[11]);
      model
        ..setTarget(KeypadTarget.quantity)
        ..pressKey('C')
        ..pressKey('4');
      expect(model.draftTotal, closeTo(4 * 100 * 1.18, 0.001));

      model.updateSettings(const WorkshopSettings(ratesIncludeGst: true));
      expect(model.draftTotal, closeTo(4 * 100, 0.001));
    });

    test('adds the draft to the bill at the typed quantity and rate', () {
      final model = BillingModel().withDemoBill()
        ..setDraft(seedCatalog[16]); // denting
      model
        ..setTarget(KeypadTarget.quantity)
        ..pressKey('C')
        ..pressKey('3')
        ..setTarget(KeypadTarget.rate)
        ..pressKey('C')
        ..pressKey('1')
        ..pressKey('8')
        ..pressKey('0')
        ..pressKey('0')
        ..addDraft();

      final added = model.labourLines.last;
      expect(added.name, 'Denting & painting (per panel)');
      expect(added.qty, 3);
      expect(added.rate, 1800);
      expect(added.kind, ItemKind.labour);
    });
  });

  group('WorkshopSettings', () {
    test('the workshop details survive a restart', () async {
      final store = InMemorySettingsStore();
      BillingModel(settings: store).updateSettings(
        const WorkshopSettings().copyWith(
          address: 'Dawrpui, Aizawl',
          gstin: '15ABCDE1234F1Z5',
          phone: '98620 00000',
        ),
      );

      final reopened = BillingModel(settings: store);
      await reopened.loadSettings();
      expect(reopened.settings.address, 'Dawrpui, Aizawl');
      expect(reopened.settings.gstin, '15ABCDE1234F1Z5');
      expect(reopened.settings.phone, '98620 00000');
      expect(reopened.invoiceData.gstin, '15ABCDE1234F1Z5');
    });

    test('a record missing fields keeps the defaults for them', () async {
      final model = BillingModel(
        settings: InMemorySettingsStore({'phone': '98620 00000', 'gstin': 7}),
      );
      await model.loadSettings();
      expect(model.settings.phone, '98620 00000');
      expect(model.settings.gstin, const WorkshopSettings().gstin);
      expect(model.settings.address, const WorkshopSettings().address);
    });

    test('the bank and UPI details survive a restart', () async {
      final store = InMemorySettingsStore();
      BillingModel(settings: store).updateSettings(
        const WorkshopSettings().copyWith(
          accountName: 'Sample Motor Works',
          bankName: 'State Bank Of India',
          accountNo: '000012345678',
          bankBranch: 'Main Branch',
          ifsc: 'SBIN0000001',
          branchCode: '12345',
          micr: '110002001',
          upiId: 'workshop@upi',
        ),
      );

      final reopened = BillingModel(settings: store);
      await reopened.loadSettings();
      final settings = reopened.settings;
      expect(settings.accountName, 'Sample Motor Works');
      expect(settings.bankName, 'State Bank Of India');
      expect(settings.accountNo, '000012345678');
      expect(settings.bankBranch, 'Main Branch');
      expect(settings.ifsc, 'SBIN0000001');
      expect(settings.branchCode, '12345');
      expect(settings.micr, '110002001');
      expect(settings.upiId, 'workshop@upi');
    });

    test('a record from before bank details loads with them blank', () async {
      final model = BillingModel(
        settings: InMemorySettingsStore({'phone': '98620 00000'}),
      );
      await model.loadSettings();
      expect(model.settings.bankName, isEmpty);
      expect(model.settings.upiId, isEmpty);
      expect(model.invoiceData.showsPayment, isFalse);
    });

    test('recognises a well-formed UPI ID', () {
      expect(
        const WorkshopSettings(upiId: 'workshop@upi').upiIdLooksValid,
        isTrue,
      );
      expect(
        const WorkshopSettings(upiId: 'lc.auto-works@okaxis').upiIdLooksValid,
        isTrue,
      );
      expect(const WorkshopSettings().upiIdLooksValid, isFalse);
      expect(
        const WorkshopSettings(upiId: 'workshop').upiIdLooksValid,
        isFalse,
      );
      expect(const WorkshopSettings(upiId: 'a b@sbi').upiIdLooksValid, isFalse);
    });

    test('recognises a well-formed GSTIN', () {
      expect(const WorkshopSettings().gstinLooksValid, isTrue);
      expect(
        const WorkshopSettings(gstin: '23BCDPR7745K1ZP').gstinLooksValid,
        isTrue,
      );
    });

    test('rejects one of the wrong shape', () {
      expect(const WorkshopSettings(gstin: '').gstinLooksValid, isFalse);
      expect(
        const WorkshopSettings(gstin: '23ABCDE1234F1Z').gstinLooksValid,
        isFalse,
      );
      expect(
        const WorkshopSettings(gstin: 'ABCDE1234F1Z5XX').gstinLooksValid,
        isFalse,
      );
    });

    test('the place of supply comes from the GSTIN, not a second field', () {
      expect(const WorkshopSettings().stateCode, '23');
      expect(const WorkshopSettings().placeOfSupply, '23 — Madhya Pradesh');
      expect(
        const WorkshopSettings(gstin: '27ABCDE1234F1Z5').placeOfSupply,
        '27 — Maharashtra',
      );
      // An unknown or missing code degrades rather than inventing a state.
      expect(
        const WorkshopSettings(gstin: '99ABCDE1234F1Z5').placeOfSupply,
        '99',
      );
      expect(const WorkshopSettings(gstin: '').placeOfSupply, '—');
    });

    test('the invoice number follows the prefix the shop set', () {
      final model = BillingModel().withDemoBill()
        ..updateSettings(const WorkshopSettings(invoicePrefix: 'BILL/'));
      expect(model.invoiceNo, 'BILL/0148');
    });
  });

  group('BillingModel — items typed in at the counter', () {
    test('a new item joins the list and is findable by searching', () {
      final model = BillingModel().withDemoBill();
      final before = model.items.length;

      final item = model.createItem(
        name: 'Fuel Filter',
        rate: 780,
        gst: 28,
        code: '8421',
      );

      expect(item.name, 'Fuel Filter');
      expect(item.kind, ItemKind.part, reason: 'the default kind');
      expect(item.stock, isNull, reason: 'nobody counted it');
      expect(model.items.length, before + 1);

      model.updateQuery('fuel filter');
      expect(model.suggestions.single.name, 'Fuel Filter');
      expect(model.hasNoMatches, isFalse);
    });

    test('trims the name and the code', () {
      final model = BillingModel().withDemoBill();
      final item = model.createItem(
        name: '  Fuel Filter  ',
        rate: 780,
        gst: 28,
        code: ' 8421 ',
      );
      expect(item.name, 'Fuel Filter');
      expect(item.code, '8421');
    });

    test('a job is created as labour, with its SAC', () {
      final model = BillingModel().withDemoBill();
      final job = model.createItem(
        name: 'Radiator flush',
        rate: 900,
        gst: 18,
        kind: ItemKind.labour,
        code: motorServiceSac,
      );

      expect(job.kind, ItemKind.labour);
      expect(job.codeLabel, 'SAC');

      model.addToCart(job);
      expect(model.labourLines.last.name, 'Radiator flush');
      expect(model.partLines.any((l) => l.name == 'Radiator flush'), isFalse);
    });

    test('a name already on the list returns that item, not a duplicate', () {
      final model = BillingModel().withDemoBill();
      final before = model.items.length;

      // Different case, different rate — still the same part.
      final item = model.createItem(name: 'oil FILTER', rate: 99, gst: 18);

      expect(model.items.length, before, reason: 'no duplicate entry');
      expect(item.name, 'Oil Filter');
      expect(item.rate, 320, reason: 'the entry on file wins');
    });

    test('a one-off is billable without joining the list', () {
      final model = BillingModel().withDemoBill();
      final before = model.items.length;

      final item = model.createItem(
        name: 'Towing charge',
        rate: 1500,
        gst: 18,
        kind: ItemKind.labour,
        remember: false,
      );
      model.addToCart(item);

      expect(model.items.length, before);
      expect(model.lines.last.name, 'Towing charge');

      model.updateQuery('towing');
      expect(model.hasNoMatches, isTrue, reason: 'it was not remembered');
    });

    test('a created item prices through the GST split like any other', () {
      final model = BillingModel().withDemoBill();
      final item = model.createItem(
        name: 'Brake Fluid 500 ml',
        rate: 260,
        gst: 5,
      );
      model.addToCart(item, qty: 4);

      final line = model.lines.last;
      expect(line.taxable, closeTo(1040, 0.001));
      expect(line.tax, closeTo(52, 0.001));
      expect(line.halfGstPct, '2.5%');

      model.updateSettings(const WorkshopSettings(ratesIncludeGst: true));
      final inclusive = model.lines.last;
      expect(inclusive.taxable, closeTo(1040 / 1.05, 0.001));
      expect(inclusive.taxable + inclusive.tax, closeTo(1040, 0.001));
    });

    test('an item with no code still bills', () {
      final model = BillingModel().withDemoBill();
      final item = model.createItem(name: 'Sundry charge', rate: 150, gst: 18);
      expect(item.code, '');
      model.addToCart(item);
      expect(model.lines.last.code, '');
    });
  });

  group('BillingModel — the item master on disk', () {
    test('what one session creates, the next one loads', () async {
      final store = InMemoryItemStore();

      final monday = BillingModel(store: store).withDemoBill();
      monday.createItem(
        name: 'Radiator flush',
        rate: 900,
        gst: 18,
        kind: ItemKind.labour,
        code: motorServiceSac,
      );
      // The write is fire-and-forget, so let it land.
      await Future<void>.delayed(Duration.zero);

      final tuesday = BillingModel(store: store).withDemoBill();
      tuesday.updateQuery('radiator');
      expect(tuesday.suggestions, isEmpty, reason: 'not loaded yet');

      await tuesday.loadItems();
      // The kind survives the round trip, so a job does not come back as a
      // part with a SAC in the HSN column.
      expect(tuesday.suggestions.single.name, 'Radiator flush');
      expect(tuesday.suggestions.single.kind, ItemKind.labour);
      expect(tuesday.suggestions.single.code, motorServiceSac);
    });

    test(
      'only hand-entered items are stored, never the shipped list',
      () async {
        final store = InMemoryItemStore();
        final model = BillingModel(store: store).withDemoBill();
        expect(model.customItems, isEmpty);

        model.createItem(name: 'Fuel Filter', rate: 780, gst: 28);
        await Future<void>.delayed(Duration.zero);

        expect(model.customItems.single.name, 'Fuel Filter');
        expect((await store.load()).custom, hasLength(1));
      },
    );

    test('loading twice does not double the list', () async {
      final store = InMemoryItemStore(
        const ItemMasterData(
          custom: [CatalogItem(name: 'Fuel Filter', rate: 780, gst: 28)],
        ),
      );
      final model = BillingModel(store: store).withDemoBill();

      await model.loadItems();
      await model.loadItems();

      expect(model.customItems, hasLength(1));
      expect(model.items.length, seedCatalog.length + 1);
    });

    test(
      'a store that throws leaves the shop billing on the shipped list',
      () async {
        final model = BillingModel(store: _BrokenStore());
        await model.loadItems();

        expect(model.items.length, seedCatalog.length);
        // And a create still works, in memory, without surfacing the failure.
        expect(
          () => model.createItem(name: 'Fuel Filter', rate: 780, gst: 28),
          returnsNormally,
        );
        await Future<void>.delayed(Duration.zero);
        expect(model.customItems, hasLength(1));
      },
    );
  });

  group('CatalogItem storage', () {
    test('survives a round trip through JSON', () {
      const item = CatalogItem(
        name: 'Radiator flush',
        rate: 900.5,
        gst: 18,
        kind: ItemKind.labour,
        code: motorServiceSac,
      );
      final back = CatalogItem.fromJson(jsonDecode(jsonEncode(item.toJson())))!;

      expect(back.name, item.name);
      expect(back.rate, item.rate);
      expect(back.gst, item.gst);
      expect(back.kind, ItemKind.labour);
      expect(back.code, item.code);
      expect(back.stock, isNull);
    });

    test('a record it cannot read is dropped, not thrown on', () {
      expect(CatalogItem.fromJson(null), isNull);
      expect(CatalogItem.fromJson('nonsense'), isNull);
      expect(CatalogItem.fromJson(<String, Object?>{}), isNull);
      expect(CatalogItem.fromJson({'name': '  ', 'rate': 1}), isNull);
      expect(CatalogItem.fromJson({'name': 'x'}), isNull);

      // A record from an older version, missing the newer fields.
      final sparse = CatalogItem.fromJson({'name': 'x', 'rate': 10})!;
      expect(sparse.gst, 0);
      expect(sparse.code, '');
      expect(sparse.stock, isNull);
      // An unreadable kind falls back to a part rather than dropping the row.
      expect(sparse.kind, ItemKind.part);
      expect(
        CatalogItem.fromJson({
          'name': 'x',
          'rate': 10,
          'kind': 'nonsense',
        })!.kind,
        ItemKind.part,
      );
    });
  });

  group('VehicleDetails', () {
    test('recognises an Indian registration, however it is spaced', () {
      for (final reg in ['MH 12 AB 1234', 'mh12ab1234', 'DL 3C AB 1234']) {
        expect(
          VehicleDetails(registration: reg).registrationLooksValid,
          isTrue,
          reason: reg,
        );
      }
    });

    test('rejects one of the wrong shape', () {
      for (final reg in ['', '1234', 'ABCD', 'MH 12 AB 12345']) {
        expect(
          VehicleDetails(registration: reg).registrationLooksValid,
          isFalse,
          reason: '"$reg"',
        );
      }
    });

    test('reads the odometer back with its unit', () {
      expect(
        const VehicleDetails(odometer: '48210').odometerLabel,
        '48,210 km',
      );
      expect(
        const VehicleDetails(odometer: '48,210').odometerLabel,
        '48,210 km',
      );
      expect(const VehicleDetails(odometer: '').odometerLabel, '');
    });

    test('summarises itself for a one-line header', () {
      expect(const VehicleDetails().summary, 'No vehicle yet');
      expect(
        const VehicleDetails(
          registration: 'mh 12 ab 1234',
          makeModel: 'Maruti Swift VDi',
        ).summary,
        'MH 12 AB 1234 · Maruti Swift VDi',
      );
    });

    test('the bill carries the vehicle it is for', () {
      final model = BillingModel().withDemoBill();
      expect(model.vehicle.registration, 'MZ 01 AB 1234');

      model.updateVehicle(
        model.vehicle.copyWith(registration: 'KA 05 MN 7788'),
      );
      expect(model.vehicle.registration, 'KA 05 MN 7788');
      // Untouched fields survive the edit.
      expect(model.vehicle.makeModel, 'BOLERO');
      expect(model.vehicle.odometer, '48210');
    });
  });

  group('BillingModel — changing the rate card', () {
    CatalogItem byName(BillingModel model, String name) =>
        model.items.firstWhere((item) => item.name == name);

    test('reprices a shipped item without renaming it', () {
      final model = BillingModel().withDemoBill();
      final original = byName(model, 'General service');
      expect(original.rate, 1200);

      model.updateItem(
        original,
        const CatalogItem(
          name: 'General service',
          rate: 1500,
          gst: 18,
          kind: ItemKind.labour,
          code: motorServiceSac,
        ),
      );

      expect(byName(model, 'General service').rate, 1500);
      expect(model.isShipped(byName(model, 'General service')), isTrue);
      expect(model.isEdited(byName(model, 'General service')), isTrue);
      // The list keeps its length: this is an edit, not an addition.
      expect(model.items.length, seedCatalog.length);
      expect(model.customItems, isEmpty);
    });

    test('renaming a shipped item replaces it on the card', () {
      final model = BillingModel().withDemoBill();
      model.updateItem(
        byName(model, 'General service'),
        const CatalogItem(
          name: 'Full service',
          rate: 1500,
          gst: 18,
          kind: ItemKind.labour,
          code: motorServiceSac,
        ),
      );

      expect(model.items.any((i) => i.name == 'General service'), isFalse);
      expect(byName(model, 'Full service').rate, 1500);
      expect(model.customItems.single.name, 'Full service');
      // The original is recoverable rather than gone.
      expect(model.removedItems.single.name, 'General service');
    });

    test('edits a hand-added item in place', () {
      final model = BillingModel().withDemoBill();
      final created = model.createItem(
        name: 'Fuel Filter',
        rate: 780,
        gst: 28,
        code: '8421',
      );

      model.updateItem(
        created,
        const CatalogItem(
          name: 'Fuel Filter (Diesel)',
          rate: 870,
          gst: 28,
          code: '8421',
        ),
      );

      expect(model.customItems.single.name, 'Fuel Filter (Diesel)');
      expect(model.customItems.single.rate, 870);
      expect(model.items.where((i) => i.name.contains('Fuel')), hasLength(1));
    });

    test('an edit does not rewrite a bill already in progress', () {
      final model = BillingModel().withDemoBill();
      // The oil is on the opening bill at 1,450.
      expect(model.lines.first.rate, 1450);

      model.updateItem(
        byName(model, 'Engine Oil 5W-30 (3.5 L)'),
        const CatalogItem(
          name: 'Engine Oil 5W-30 (3.5 L)',
          rate: 1600,
          gst: 18,
          code: '2710',
        ),
      );

      expect(model.lines.first.rate, 1450, reason: 'the line is a snapshot');
      expect(byName(model, 'Engine Oil 5W-30 (3.5 L)').rate, 1600);
    });

    test('removing a shipped item hides it, and it can be put back', () {
      final model = BillingModel().withDemoBill();
      final alignment = byName(model, 'Wheel alignment');

      model.deleteItem(alignment);
      expect(model.items.any((i) => i.name == 'Wheel alignment'), isFalse);
      expect(model.removedItems.single.name, 'Wheel alignment');
      model.updateQuery('alignment');
      expect(model.hasNoMatches, isTrue);

      model.restoreItem(alignment);
      expect(byName(model, 'Wheel alignment').rate, 500);
      expect(model.removedItems, isEmpty);
    });

    test('putting a shipped item back also undoes a reprice', () {
      final model = BillingModel().withDemoBill();
      final original = byName(model, 'Wheel alignment');
      model.updateItem(
        original,
        const CatalogItem(
          name: 'Wheel alignment',
          rate: 750,
          gst: 18,
          kind: ItemKind.labour,
          code: motorServiceSac,
        ),
      );
      expect(byName(model, 'Wheel alignment').rate, 750);

      model.restoreItem(original);
      expect(byName(model, 'Wheel alignment').rate, 500);
      expect(model.isEdited(byName(model, 'Wheel alignment')), isFalse);
    });

    test('removing a hand-added item takes it off for good', () {
      final model = BillingModel().withDemoBill();
      final created = model.createItem(name: 'Fuel Filter', rate: 780, gst: 28);

      model.deleteItem(created);
      expect(model.customItems, isEmpty);
      expect(model.removedItems, isEmpty, reason: 'nothing shipped to restore');
      expect(model.items.length, seedCatalog.length);
    });

    test('a removed item stays off the bill it was never on', () {
      final model = BillingModel().withDemoBill();
      // The oil change is on the opening bill.
      model.deleteItem(byName(model, 'Engine oil change'));
      expect(model.labourLines.first.name, 'Engine oil change');
      expect(model.items.any((i) => i.name == 'Engine oil change'), isFalse);
    });
  });

  group('BillingModel — the rate card on disk', () {
    test('an edit, a removal and an addition all survive a restart', () async {
      final store = InMemoryItemStore();

      final monday = BillingModel(store: store).withDemoBill();
      monday.updateItem(
        monday.items.firstWhere((i) => i.name == 'Wheel alignment'),
        const CatalogItem(
          name: 'Wheel alignment',
          rate: 750,
          gst: 18,
          kind: ItemKind.labour,
          code: motorServiceSac,
        ),
      );
      monday.deleteItem(
        monday.items.firstWhere((i) => i.name == 'Coolant 1 L'),
      );
      monday.createItem(name: 'Fuel Filter', rate: 780, gst: 28, code: '8421');
      await Future<void>.delayed(Duration.zero);

      final tuesday = BillingModel(store: store).withDemoBill();
      await tuesday.loadItems();

      expect(
        tuesday.items.firstWhere((i) => i.name == 'Wheel alignment').rate,
        750,
      );
      expect(tuesday.items.any((i) => i.name == 'Coolant 1 L'), isFalse);
      expect(tuesday.removedItems.single.name, 'Coolant 1 L');
      expect(tuesday.customItems.single.name, 'Fuel Filter');
    });

    test(
      'the shipped list is never stored, only the difference from it',
      () async {
        final store = InMemoryItemStore();
        final model = BillingModel(store: store).withDemoBill();
        model.deleteItem(
          model.items.firstWhere((i) => i.name == 'Coolant 1 L'),
        );
        await Future<void>.delayed(Duration.zero);

        final stored = await store.load();
        expect(stored.custom, isEmpty);
        expect(stored.overrides, isEmpty);
        expect(stored.hidden, {'Coolant 1 L'});
      },
    );

    test('survives a round trip through JSON', () {
      final data = ItemMasterData(
        custom: const [CatalogItem(name: 'Fuel Filter', rate: 780, gst: 28)],
        overrides: const {
          'Wheel alignment': CatalogItem(
            name: 'Wheel alignment',
            rate: 750,
            gst: 18,
            kind: ItemKind.labour,
            code: motorServiceSac,
          ),
        },
        hidden: const {'Coolant 1 L'},
      );

      final back = ItemMasterData.fromJson(
        jsonDecode(jsonEncode(data.toJson())),
      );
      expect(back.custom.single.name, 'Fuel Filter');
      expect(back.overrides['Wheel alignment']!.rate, 750);
      expect(back.overrides['Wheel alignment']!.kind, ItemKind.labour);
      expect(back.hidden, {'Coolant 1 L'});
    });

    test('a record it cannot read leaves the rest of the card intact', () {
      final back = ItemMasterData.fromJson({
        'custom': [
          'nonsense',
          {'name': 'Fuel Filter', 'rate': 780},
        ],
        'overrides': {
          'Wheel alignment': 'nonsense',
          'Coolant 1 L': {'name': 'x', 'rate': 1},
        },
        'hidden': ['Coolant 1 L', 42],
      });

      expect(back.custom.single.name, 'Fuel Filter');
      expect(back.overrides.keys, ['Coolant 1 L']);
      expect(back.hidden, {'Coolant 1 L'});

      expect(ItemMasterData.fromJson(null).isEmpty, isTrue);
      expect(ItemMasterData.fromJson('nonsense').isEmpty, isTrue);
    });
  });

  group('BillingModel — saving a bill', () {
    test('a fresh bill is unsaved and shows the number it will take', () {
      final model = BillingModel().withDemoBill();
      expect(model.isSaved, isFalse);
      expect(model.bills, isEmpty);
      expect(model.invoiceNo, 'INV/26-27/0148');
    });

    test('saving gives it a number and puts it on the list', () {
      final model = BillingModel().withDemoBill();
      final bill = model.saveBill();

      expect(model.isSaved, isTrue);
      expect(bill.invoiceNo, 'INV/26-27/0148');
      expect(model.bills.single.invoiceNo, 'INV/26-27/0148');
      expect(bill.status, BillStatus.held);
      expect(bill.lines, hasLength(4));
    });

    test('saving again updates the same bill rather than adding another', () {
      final model = BillingModel().withDemoBill();
      model.saveBill();
      model.addToCart(seedCatalog[2]); // an air filter, which also saves

      expect(model.bills, hasLength(1));
      expect(model.bills.single.lines, hasLength(5));
      expect(model.invoiceNo, 'INV/26-27/0148');
    });

    test('each new bill takes the next number', () {
      final model = BillingModel().withDemoBill();
      model.holdBill();
      expect(model.invoiceNo, 'INV/26-27/0149', reason: 'the counter moved on');

      model.addToCart(seedCatalog[0]);
      model.saveBill();
      expect(model.bills.map((b) => b.invoiceNo), [
        'INV/26-27/0149',
        'INV/26-27/0148',
      ], reason: 'newest first');
    });

    test('holding parks the bill and clears the counter', () {
      final model = BillingModel().withDemoBill();
      model.holdBill();

      expect(model.lines, isEmpty);
      expect(model.isSaved, isFalse);
      expect(model.vehicle.hasVehicle, isFalse);
      expect(model.bills.single.status, BillStatus.held);
      expect(model.bills.single.vehicle.registration, 'MZ 01 AB 1234');
    });

    test('settling records how it was paid and keeps it on the counter', () {
      final model = BillingModel().withDemoBill();
      model.settleBill(PaymentMethod.cash);

      expect(model.isPaid, isTrue);
      expect(model.payment, PaymentMethod.cash);
      expect(model.lines, hasLength(4), reason: 'still printable');
      expect(model.bills.single.payment, PaymentMethod.cash);
      expect(model.bills.single.isOutstanding, isFalse);
    });

    test('a bill settled as due stays on the outstanding list', () {
      final model = BillingModel().withDemoBill();
      model.settleBill(PaymentMethod.due);

      expect(model.isPaid, isTrue);
      expect(model.outstandingBills.single.invoiceNo, 'INV/26-27/0148');
    });

    test(
      'starting a new bill parks anything unsaved rather than losing it',
      () {
        final model = BillingModel().withDemoBill();
        model.newBill();

        expect(model.lines, isEmpty);
        expect(
          model.bills.single.lines,
          hasLength(4),
          reason: 'parked, not lost',
        );
      },
    );

    test('starting a new bill on an empty counter saves nothing', () {
      // The first parks the job on the counter; the second has nothing to.
      final model = BillingModel().withDemoBill()..newBill();
      model.newBill();
      expect(model.bills, hasLength(1));
    });
  });

  group('BillingModel — reopening a bill', () {
    test('puts it back on the counter, priced as it was', () {
      final model = BillingModel().withDemoBill();
      model.settleBill(PaymentMethod.upi);
      final saved = model.bills.single;
      model.newBill();
      expect(model.lines, isEmpty);

      model.openBill(saved);
      expect(model.invoiceNo, 'INV/26-27/0148');
      expect(model.lines, hasLength(4));
      expect(model.vehicle.registration, 'MZ 01 AB 1234');
      expect(model.isPaid, isTrue);
      expect(model.payment, PaymentMethod.upi);
      expect(model.totalLabel, '\u20B92,974');
    });

    test('correcting a reopened bill keeps its number and updates it', () {
      final model = BillingModel().withDemoBill();
      model.settleBill(PaymentMethod.cash);
      final saved = model.bills.single;
      model.newBill();

      model.openBill(saved);
      model.bump(0, 1); // one more can of oil

      expect(model.bills, hasLength(1), reason: 'one bill, not two');
      expect(model.bills.single.invoiceNo, 'INV/26-27/0148');
      expect(model.bills.single.lines.first.qty, 2);
    });

    test('opening one parks whatever was on the counter', () {
      final model = BillingModel().withDemoBill();
      model.saveBill();
      final first = model.bills.single;
      model.newBill();
      model.addToCart(seedCatalog[5]); // a battery on a second bill

      model.openBill(first);
      expect(model.bills, hasLength(2));
      expect(model.invoiceNo, 'INV/26-27/0148');
      expect(
        model.bills.any((b) => b.lines.any((l) => l.name == 'Battery 35 Ah')),
        isTrue,
        reason: 'the second bill was parked, not dropped',
      );
    });

    test('a bill keeps the tax mode it was raised under', () {
      final model = BillingModel().withDemoBill();
      model.settleBill(PaymentMethod.cash);
      final exclusive = model.bills.single;
      expect(exclusive.ratesIncludeGst, isFalse);
      expect(model.totalOf(exclusive), 2974);

      // The workshop switches to inclusive pricing, and raises a new bill.
      model.newBill();
      model.updateSettings(model.settings.copyWith(ratesIncludeGst: true));
      model.addToCart(seedCatalog[0]);
      model.saveBill();

      // The old invoice must still print the figures the customer paid.
      expect(model.totalOf(exclusive), 2974);
      model.openBill(exclusive);
      expect(model.totalLabel, '\u20B92,974');
      expect(model.ratesIncludeGst, isFalse);
      // Reopening an old bill does not change what the workshop saved.
      expect(model.settings.ratesIncludeGst, isTrue);
    });

    test('settings show the saved tax mode while an old bill is open', () {
      final model = BillingModel()
        ..updateSettings(const WorkshopSettings(ratesIncludeGst: false))
        ..addToCart(seedCatalog[0]);
      final exclusive = model.saveBill();

      model
        ..newBill()
        ..updateSettings(model.settings.copyWith(ratesIncludeGst: true))
        ..openBill(exclusive);
      expect(model.ratesIncludeGst, isFalse);
      expect(model.settings.ratesIncludeGst, isTrue);

      // Back to a fresh bill, the workshop's setting applies again.
      model.newBill();
      expect(model.ratesIncludeGst, isTrue);
    });

    test('a saved bill keeps its mode when the workshop switches', () {
      final model = BillingModel()
        ..updateSettings(const WorkshopSettings(ratesIncludeGst: false))
        ..addToCart(seedCatalog[0]);
      final before = model.total;
      model
        ..settleBill(PaymentMethod.cash)
        ..updateSettings(model.settings.copyWith(ratesIncludeGst: true));
      expect(model.total, before);
      expect(model.bills.single.ratesIncludeGst, isFalse);
    });

    test('deleting takes it off the list for good', () {
      final model = BillingModel().withDemoBill();
      model.saveBill();
      model.deleteBill(model.bills.single);

      expect(model.bills, isEmpty);
      expect(model.isSaved, isFalse);
      // The number is not handed out again.
      model.saveBill();
      expect(model.invoiceNo, 'INV/26-27/0149');
    });
  });

  group('BillingModel — bills on disk', () {
    test('a saved bill and the numbering survive a restart', () async {
      final store = InMemoryBillStore();

      final monday = BillingModel(bills: store).withDemoBill();
      monday.settleBill(PaymentMethod.card);
      monday.holdBill();
      await Future<void>.delayed(Duration.zero);

      final tuesday = BillingModel(bills: store).withDemoBill();
      await tuesday.loadBills();

      expect(tuesday.bills, hasLength(1));
      expect(tuesday.bills.single.invoiceNo, 'INV/26-27/0148');
      expect(tuesday.bills.single.payment, PaymentMethod.card);
      expect(tuesday.bills.single.vehicle.makeModel, 'BOLERO');
      expect(tuesday.bills.single.lines, hasLength(4));
      // The counter carries on rather than reusing 0148.
      expect(tuesday.invoiceNo, 'INV/26-27/0149');
    });

    test('survives a round trip through JSON', () {
      final model = BillingModel().withDemoBill();
      model.settleBill(PaymentMethod.upi);
      final bill = model.bills.single;

      final back = SavedBill.fromJson(jsonDecode(jsonEncode(bill.toJson())))!;
      expect(back.id, bill.id);
      expect(back.invoiceNo, bill.invoiceNo);
      expect(back.status, BillStatus.paid);
      expect(back.payment, PaymentMethod.upi);
      expect(back.ratesIncludeGst, isFalse);
      expect(back.vehicle.registration, 'MZ 01 AB 1234');
      expect(back.lines.map((l) => l.name), bill.lines.map((l) => l.name));
      expect(back.lines.last.qty, 4);
      expect(back.lines.first.kind, ItemKind.part);
    });

    test('a record it cannot read is dropped, not thrown on', () {
      expect(SavedBill.fromJson(null), isNull);
      expect(SavedBill.fromJson({'invoiceNo': 'x'}), isNull);
      expect(SavedBill.fromJson({'id': 'a'}), isNull);

      final archive = BillArchive.fromJson({
        'bills': [
          'nonsense',
          {'id': 'a', 'invoiceNo': 'INV/1', 'lines': []},
        ],
        'nextNumber': 200,
      });
      expect(archive.bills.single.invoiceNo, 'INV/1');
      expect(archive.nextNumber, 200);
      expect(BillArchive.fromJson(null).isEmpty, isTrue);
    });

    test('a store that throws leaves the workshop billing', () async {
      final model = BillingModel(bills: _BrokenBillStore());
      await model.loadBills();
      expect(model.bills, isEmpty);
      expect(() => model.saveBill(), returnsNormally);
      expect(model.bills, hasLength(1));
    });
  });
}

/// A store whose device is having a bad day.
class _BrokenStore implements ItemStore {
  @override
  Future<ItemMasterData> load() async => throw StateError('no storage');

  @override
  Future<void> save(ItemMasterData data) async =>
      throw StateError('no storage');
}

/// A bill store whose device is having a bad day.
class _BrokenBillStore implements BillStore {
  @override
  Future<BillArchive> load() async => throw StateError('no storage');

  @override
  Future<void> saveBill(SavedBill bill, {required int nextNumber}) async =>
      throw StateError('no storage');

  @override
  Future<void> deleteBill(String id) async => throw StateError('no storage');

  @override
  Future<void> replaceAll(BillArchive archive) async =>
      throw StateError('no storage');
}
