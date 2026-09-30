import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisap_app_2_0/data/database.dart';
import 'package:hisap_app_2_0/data/prefs_migration.dart';
import 'package:hisap_app_2_0/models/bill.dart';
import 'package:hisap_app_2_0/models/catalog.dart';
import 'package:hisap_app_2_0/state/billing_model.dart';
import 'package:hisap_app_2_0/state/item_store.dart';
import 'package:hisap_app_2_0/state/sqlite_stores.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/demo_bill.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('SqliteBillStore', () {
    test('a bill comes back as it was saved', () async {
      final store = SqliteBillStore(db);
      final model = BillingModel().withDemoBill();
      final bill = model.settleBill(PaymentMethod.upi);

      await store.saveBill(bill, nextNumber: 149);
      final archive = await store.load();

      final back = archive.bills.single;
      expect(back.id, bill.id);
      expect(back.invoiceNo, bill.invoiceNo);
      expect(back.date, bill.date);
      expect(back.status, BillStatus.paid);
      expect(back.payment, PaymentMethod.upi);
      expect(back.ratesIncludeGst, bill.ratesIncludeGst);
      expect(back.vehicle.registration, 'MZ 01 AB 1234');
      expect(back.vehicle.makeModel, 'BOLERO');
      expect(back.lines.map((l) => l.name), bill.lines.map((l) => l.name));
      expect(back.lines.map((l) => l.qty), bill.lines.map((l) => l.qty));
      expect(back.lines.map((l) => l.kind), bill.lines.map((l) => l.kind));
      expect(archive.nextNumber, 149);
    });

    test('saving a bill again updates it in place', () async {
      final store = SqliteBillStore(db);
      final model = BillingModel().withDemoBill();
      model.holdBill();
      final held = model.bills.single;
      final other = model.withDemoBill().saveBill();
      expect(other.invoiceNo, isNot(held.invoiceNo));

      await store.saveBill(held, nextNumber: 149);
      await store.saveBill(other, nextNumber: 150);
      await store.saveBill(
        held.copyWith(
          status: BillStatus.paid,
          payment: PaymentMethod.cash,
          lines: held.lines.take(1).toList(),
        ),
        nextNumber: 150,
      );

      final archive = await store.load();
      expect(archive.bills, hasLength(2));
      // A correction keeps the bill's place in the order it was raised in.
      expect(archive.bills.first.id, held.id);
      expect(archive.bills.first.status, BillStatus.paid);
      expect(archive.bills.first.lines, hasLength(1));
      expect(await db.select(db.billLines).get(), hasLength(1 + 4));
    });

    test('deleting a bill takes its lines with it', () async {
      final store = SqliteBillStore(db);
      final bill = BillingModel().withDemoBill().saveBill();
      await store.saveBill(bill, nextNumber: 149);

      await store.deleteBill(bill.id);

      expect((await store.load()).bills, isEmpty);
      expect(await db.select(db.billLines).get(), isEmpty);
    });

    test(
      'an empty database starts the numbering where the app always has',
      () async {
        expect((await SqliteBillStore(db).load()).nextNumber, 148);
      },
    );

    test(
      'a bill and the numbering survive a restart through the model',
      () async {
        final store = SqliteBillStore(db);
        final monday = BillingModel(bills: store).withDemoBill();
        monday.settleBill(PaymentMethod.card);
        monday.holdBill();
        await Future<void>.delayed(Duration.zero);
        await db.select(db.bills).get(); // let queued writes land

        final tuesday = BillingModel(bills: store);
        await tuesday.loadBills();
        expect(tuesday.bills, hasLength(1));
        expect(tuesday.invoiceNo, 'INV/26-27/0149');
      },
    );
  });

  group('SqliteItemStore', () {
    test('custom, repriced and removed items come back', () async {
      final store = SqliteItemStore(db);
      final data = ItemMasterData(
        custom: const [
          CatalogItem(name: 'Horn', rate: 450, gst: 18, code: '8512'),
          CatalogItem(
            name: 'Underbody coating',
            rate: 2200,
            gst: 18,
            kind: ItemKind.labour,
          ),
        ],
        overrides: {
          'Oil Filter': const CatalogItem(
            name: 'Oil Filter',
            rate: 350,
            gst: 18,
            stock: 20,
          ),
        },
        hidden: {'Battery 35 Ah'},
      );

      await store.save(data);
      await store.save(data); // replaces, never adds on top
      final back = await store.load();

      expect(back.custom.map((i) => i.name), ['Horn', 'Underbody coating']);
      expect(back.custom.last.kind, ItemKind.labour);
      expect(back.custom.first.stock, isNull);
      expect(back.overrides['Oil Filter']!.rate, 350);
      expect(back.overrides['Oil Filter']!.stock, 20);
      expect(back.hidden, {'Battery 35 Ah'});
    });
  });

  group('SqliteSettingsStore', () {
    test('the workshop details come back', () async {
      final store = SqliteSettingsStore(db);
      expect(await store.load(), isNull);

      final settings = const WorkshopSettings().copyWith(name: 'Zote Motors');
      await store.save(settings.toJson());

      final back = WorkshopSettings.fromJson((await store.load())!);
      expect(back.name, 'Zote Motors');
      expect(back.ratesIncludeGst, settings.ratesIncludeGst);
    });
  });

  group('importFromPrefs', () {
    test('carries an older build\'s records over once', () async {
      final bill = BillingModel().withDemoBill().settleBill(PaymentMethod.due);
      SharedPreferences.setMockInitialValues({
        'bills.v1': jsonEncode(
          BillArchive(bills: [bill], nextNumber: 212).toJson(),
        ),
        'item_master.v3': jsonEncode(
          const ItemMasterData(hidden: {'Coolant 1 L'}).toJson(),
        ),
        'settings.v1': jsonEncode(
          const WorkshopSettings().copyWith(phone: '0389 232 1111').toJson(),
        ),
      });

      await importFromPrefs(db);
      await importFromPrefs(db);

      final archive = await SqliteBillStore(db).load();
      expect(archive.bills.single.id, bill.id);
      expect(archive.bills.single.payment, PaymentMethod.due);
      expect(archive.nextNumber, 212);
      expect((await SqliteItemStore(db).load()).hidden, {'Coolant 1 L'});
      final settings = await SqliteSettingsStore(db).load();
      expect(settings!['phone'], '0389 232 1111');
    });

    test('a fresh install imports nothing and does not look again', () async {
      SharedPreferences.setMockInitialValues({});
      await importFromPrefs(db);

      expect((await SqliteBillStore(db).load()).bills, isEmpty);
      expect(await SqliteSettingsStore(db).load(), isNull);
      expect(await db.readMeta('migrated_from_prefs'), isNotNull);
    });
  });
}
