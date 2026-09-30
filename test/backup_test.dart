import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisap_app_2_0/data/database.dart';
import 'package:hisap_app_2_0/models/bill.dart';
import 'package:hisap_app_2_0/models/catalog.dart';
import 'package:hisap_app_2_0/services/bills_csv.dart';
import 'package:hisap_app_2_0/state/backup.dart';
import 'package:hisap_app_2_0/state/bill_store.dart';
import 'package:hisap_app_2_0/state/billing_model.dart';
import 'package:hisap_app_2_0/state/item_store.dart';
import 'package:hisap_app_2_0/state/settings_store.dart';
import 'package:hisap_app_2_0/state/sqlite_stores.dart';

import 'support/demo_bill.dart';

/// A model with two bills on file — one paid, one held — and a hand-added
/// item, as a workshop a few days in would have.
BillingModel _workshop({
  String name = 'LC Automobiles',
  BillStore? bills,
  ItemStore? items,
  SettingsStore? settings,
  RestorePointStore? restorePoints,
}) {
  final model = BillingModel(
    bills: bills,
    store: items,
    settings: settings,
    restorePoints: restorePoints,
  );
  model.withDemoBill();
  model.updateSettings(model.settings.copyWith(name: name));
  model.settleBill(PaymentMethod.cash);
  model.newBill();
  model.withDemoBill();
  model.holdBill();
  model.createItem(name: 'Horn ($name)', rate: 450, gst: 18);
  return model;
}

void main() {
  group('Backup file', () {
    test('survives a round trip through the file', () {
      final model = _workshop();
      final backup = model.backup();

      final back = Backup.parse(backup.encode());

      expect(back.bills.map((b) => b.id), backup.bills.map((b) => b.id));
      expect(back.bills.first.lines, hasLength(4));
      expect(back.nextNumber, backup.nextNumber);
      expect(back.settings!.name, 'LC Automobiles');
      expect(back.items.custom.single.name, 'Horn (LC Automobiles)');
      expect(back.unreadable, 0);
      expect(back.fileName, startsWith('hisap-backup-'));
      expect(back.fileName, endsWith('.json'));
    });

    test('turns away a file that is not a backup', () {
      for (final text in [
        'not json',
        '[]',
        '{"bills": []}',
        '{"format": "hisap-backup"}',
      ]) {
        expect(
          () => Backup.parse(text),
          throwsA(
            isA<BackupException>().having(
              (e) => e.message,
              'message',
              contains('not a Hisap backup'),
            ),
          ),
          reason: text,
        );
      }
    });

    test('turns away a backup from a newer build', () {
      final json = _workshop().backup().toJson()..['version'] = 99;
      expect(
        () => Backup.parse(jsonEncode(json)),
        throwsA(
          isA<BackupException>().having(
            (e) => e.message,
            'message',
            contains('newer version'),
          ),
        ),
      );
    });

    test('drops and counts a bill it cannot read', () {
      final json = _workshop().backup().toJson();
      json['bills'] = [...json['bills']! as List, 'nonsense'];

      final back = Backup.parse(jsonEncode(json));
      expect(back.bills, hasLength(2));
      expect(back.unreadable, 1);
    });

    test('without workshop details, keeps none rather than the defaults', () {
      final json = _workshop().backup().toJson()..remove('workshop');
      expect(Backup.parse(jsonEncode(json)).settings, isNull);
    });
  });

  group('Backup.mergeIn', () {
    test('adds what is missing and keeps what is here', () {
      final here = _workshop(name: 'Tablet').backup();
      final phone = _workshop(name: 'Phone').backup();
      // The phone also has one of the tablet's bills, edited.
      final shared = here.bills.first.copyWith(payment: PaymentMethod.upi);
      final incoming = Backup(
        exportedAt: phone.exportedAt,
        settings: phone.settings,
        bills: [...phone.bills, shared],
        nextNumber: 400,
        items: ItemMasterData(
          custom: [
            ...phone.items.custom,
            const CatalogItem(name: 'horn (tablet) ', rate: 1, gst: 0),
          ],
          overrides: {
            'Oil Filter': const CatalogItem(
              name: 'Oil Filter',
              rate: 999,
              gst: 18,
            ),
          },
          hidden: {'Coolant 1 L'},
        ),
      );

      final merged = here.mergeIn(incoming);
      final result = merged.backup;

      expect(merged.added, 2);
      expect(merged.skipped, 1);
      // Both devices numbered from 148 on their own.
      expect(merged.clashes, 2);
      expect(result.bills, hasLength(4));
      expect(result.bills.first.payment, PaymentMethod.cash);
      expect(result.nextNumber, 400);
      expect(result.settings!.name, 'Tablet');
      // A name already on the card, in other case and spacing, is not added.
      expect(result.items.custom.map((i) => i.name), [
        'Horn (Tablet)',
        'Horn (Phone)',
      ]);
      expect(result.items.overrides['Oil Filter']!.rate, 999);
      expect(result.items.hidden, {'Coolant 1 L'});
    });

    test('keeps the higher number when this device is further on', () {
      final here = _workshop().backup();
      final older = Backup(
        exportedAt: DateTime(2026),
        settings: null,
        bills: const [],
        nextNumber: 149,
        items: const ItemMasterData(),
      );
      expect(here.mergeIn(older).backup.nextNumber, here.nextNumber);
      expect(here.nextNumber, greaterThan(149));
    });
  });

  group('BillingModel.restore', () {
    test('replace puts the backup in place of everything', () async {
      final bills = InMemoryBillStore();
      final items = InMemoryItemStore();
      final settings = InMemorySettingsStore();
      final tablet = _workshop(
        name: 'Tablet',
        bills: bills,
        items: items,
        settings: settings,
      );
      final phone = _workshop(name: 'Phone').backup();

      final report = await tablet.restore(phone, RestoreMode.replace);

      expect(report.bills, 2);
      expect(tablet.settings.name, 'Phone');
      expect(
        tablet.bills.map((b) => b.id).toSet(),
        phone.bills.map((b) => b.id).toSet(),
      );
      expect(tablet.items.any((i) => i.name == 'Horn (Phone)'), isTrue);
      expect(tablet.items.any((i) => i.name == 'Horn (Tablet)'), isFalse);
      expect(tablet.lines, isEmpty);

      // And it is what the device has stored, not just what it shows.
      final restarted = BillingModel(
        bills: bills,
        store: items,
        settings: settings,
      );
      await restarted.loadSettings();
      await restarted.loadItems();
      await restarted.loadBills();
      expect(restarted.settings.name, 'Phone');
      expect(restarted.bills, hasLength(2));
      expect(restarted.items.any((i) => i.name == 'Horn (Phone)'), isTrue);
    });

    test('merge keeps this device and reports what it did', () async {
      final tablet = _workshop(name: 'Tablet');
      final phone = _workshop(name: 'Phone').backup();

      final report = await tablet.restore(phone, RestoreMode.merge);

      expect(report.mode, RestoreMode.merge);
      expect(report.bills, 2);
      expect(tablet.bills, hasLength(4));
      expect(tablet.settings.name, 'Tablet');
    });

    test('parks a bill left on the counter before bringing data in', () async {
      final tablet = _workshop();
      tablet.withDemoBill(); // not saved yet
      final before = tablet.bills.length;

      await tablet.restore(_workshop().backup(), RestoreMode.merge);

      expect(tablet.lines, isEmpty);
      expect(tablet.bills.length, before + 1 + 2);
    });

    test('an import can be undone, once', () async {
      final points = InMemoryRestorePointStore();
      final tablet = _workshop(name: 'Tablet', restorePoints: points);
      final ids = tablet.bills.map((b) => b.id).toList();
      expect(tablet.hasRestorePoint, isFalse);

      await tablet.restore(
        _workshop(name: 'Phone').backup(),
        RestoreMode.replace,
      );
      expect(tablet.hasRestorePoint, isTrue);

      await tablet.undoRestore();
      expect(tablet.settings.name, 'Tablet');
      expect(tablet.bills.map((b) => b.id), ids);
      expect(tablet.hasRestorePoint, isFalse);
      expect(await points.read(), isNull);

      // A later start knows there is nothing to undo.
      final restarted = BillingModel(restorePoints: points);
      await restarted.loadRestorePoint();
      expect(restarted.hasRestorePoint, isFalse);
    });

    test('a numbering that goes on from the backup', () async {
      final tablet = _workshop();
      final phone = _workshop().backup();
      await tablet.restore(
        Backup(
          exportedAt: phone.exportedAt,
          settings: phone.settings,
          bills: phone.bills,
          nextNumber: 300,
          items: phone.items,
        ),
        RestoreMode.replace,
      );
      tablet.withDemoBill();
      expect(tablet.saveBill().invoiceNo, 'INV/26-27/0300');
    });
  });

  group('On the SQLite database', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('replace and undo reach the database', () async {
      BillingModel open() => BillingModel(
        bills: SqliteBillStore(db),
        store: SqliteItemStore(db),
        settings: SqliteSettingsStore(db),
        restorePoints: SqliteRestorePointStore(db),
      );
      Future<BillingModel> restart() async {
        final model = open();
        await model.loadSettings();
        await model.loadItems();
        await model.loadBills();
        await model.loadRestorePoint();
        return model;
      }

      final tablet = _workshop(
        name: 'Tablet',
        bills: SqliteBillStore(db),
        items: SqliteItemStore(db),
        settings: SqliteSettingsStore(db),
        restorePoints: SqliteRestorePointStore(db),
      );
      await db.select(db.bills).get(); // let the counter's writes land
      final ids = tablet.bills.map((b) => b.id).toSet();

      await tablet.restore(
        _workshop(name: 'Phone').backup(),
        RestoreMode.replace,
      );
      var after = await restart();
      expect(after.settings.name, 'Phone');
      expect(after.bills.map((b) => b.id).toSet().intersection(ids), isEmpty);
      expect(after.hasRestorePoint, isTrue);
      expect(await db.select(db.billLines).get(), hasLength(8));

      await after.undoRestore();
      after = await restart();
      expect(after.settings.name, 'Tablet');
      expect(after.bills.map((b) => b.id).toSet(), ids);
      expect(after.items.any((i) => i.name == 'Horn (Tablet)'), isTrue);
      expect(after.hasRestorePoint, isFalse);
    });
  });

  group('Bills CSV', () {
    test('one row per bill, with the invoice\'s own figures', () {
      final model = BillingModel().withDemoBill();
      final total = model.total;
      final cgst = model.cgst;
      model.settleBill(PaymentMethod.upi);

      final csv = billsCsv(model.bills);
      final rows = csv.substring(1).trimRight().split('\r\n');

      expect(csv, startsWith('﻿'));
      expect(rows, hasLength(2));
      expect(rows.first, startsWith('Invoice no,Date,Status,Payment'));
      final cells = rows.last.split(',');
      expect(cells[0], 'INV/26-27/0148');
      expect(cells[2], 'Paid');
      expect(cells[3], 'UPI');
      expect(cells[4], 'MZ 01 AB 1234');
      expect(cells[10], cgst.toStringAsFixed(2));
      expect(cells[13], total.toStringAsFixed(2));
    });

    test('quotes what needs quoting and defuses formulas', () {
      final model = BillingModel().withDemoBill();
      model.updateVehicle(
        model.vehicle.copyWith(
          customerName: 'Lalremruata, "Mapuia"',
          makeModel: '=HYPERLINK("x")',
          customerPhone: '+91 98220 41188',
        ),
      );
      model.saveBill();

      final row = billsCsv(model.bills).split('\r\n')[1];
      expect(row, contains('"Lalremruata, ""Mapuia"""'));
      expect(row, contains('"\'=HYPERLINK(""x"")"'));
      // A phone number is left as typed.
      expect(row, contains(',+91 98220 41188,'));
    });
  });
}
