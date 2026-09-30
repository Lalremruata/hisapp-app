import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database.dart';
import '../models/bill.dart';
import '../models/catalog.dart';
import '../models/vehicle.dart';
import 'backup.dart';
import 'bill_store.dart';
import 'item_store.dart';
import 'settings_store.dart';

/// Meta keys.
const nextNumberKey = 'next_number';
const settingsKey = 'settings';

/// Reads an enum back by name, falling back rather than throwing on a value
/// written by some other version.
T _byName<T extends Enum>(List<T> values, String? name, T otherwise) =>
    values.where((value) => value.name == name).firstOrNull ?? otherwise;

/// Saved bills, on the device's SQLite database.
class SqliteBillStore implements BillStore {
  const SqliteBillStore(this._db);

  final AppDatabase _db;

  @override
  Future<BillArchive> load() async {
    final bills = await (_db.select(
      _db.bills,
    )..orderBy([(row) => OrderingTerm.asc(row.seq)])).get();
    final lines = await (_db.select(
      _db.billLines,
    )..orderBy([(row) => OrderingTerm.asc(row.position)])).get();

    final linesByBill = <String, List<CartLine>>{};
    for (final line in lines) {
      (linesByBill[line.billId] ??= []).add(
        CartLine(
          name: line.name,
          rate: line.rate,
          gst: line.gst,
          kind: _byName(ItemKind.values, line.kind, ItemKind.part),
          code: line.code,
          qty: line.qty < 1 ? 1 : line.qty,
        ),
      );
    }

    final next = int.tryParse(await _db.readMeta(nextNumberKey) ?? '');
    return BillArchive(
      bills: [
        for (final bill in bills)
          SavedBill(
            id: bill.id,
            invoiceNo: bill.invoiceNo,
            date: bill.date,
            vehicle: VehicleDetails(
              registration: bill.registration,
              makeModel: bill.makeModel,
              odometer: bill.odometer,
              customerName: bill.customerName,
              customerPhone: bill.customerPhone,
            ),
            lines: linesByBill[bill.id] ?? const [],
            status: _byName(BillStatus.values, bill.status, BillStatus.held),
            ratesIncludeGst: bill.ratesIncludeGst,
            payment: bill.payment == null
                ? null
                : PaymentMethod.values
                      .where((method) => method.name == bill.payment)
                      .firstOrNull,
          ),
      ],
      nextNumber: next != null && next > 0
          ? next
          : const BillArchive().nextNumber,
    );
  }

  @override
  Future<void> saveBill(SavedBill bill, {required int nextNumber}) =>
      _db.transaction(() async {
        await writeBill(_db, bill);
        await _db.writeMeta(nextNumberKey, '$nextNumber');
      });

  @override
  Future<void> deleteBill(String id) =>
      (_db.delete(_db.bills)..where((row) => row.id.equals(id))).go();

  @override
  Future<void> replaceAll(BillArchive archive) => _db.transaction(() async {
    await _db.delete(_db.billLines).go();
    await _db.delete(_db.bills).go();
    for (final bill in archive.bills) {
      await writeBill(_db, bill);
    }
    await _db.writeMeta(nextNumberKey, '${archive.nextNumber}');
  });
}

/// Writes one bill and its lines, keeping its place in the order it was
/// raised in when it is already there. Run inside a transaction.
Future<void> writeBill(AppDatabase db, SavedBill bill) async {
  final existing = await (db.select(
    db.bills,
  )..where((row) => row.id.equals(bill.id))).getSingleOrNull();
  final seq =
      existing?.seq ??
      ((await (db.selectOnly(db.bills)..addColumns([db.bills.seq.max()]))
                  .map((row) => row.read(db.bills.seq.max()))
                  .getSingle()) ??
              0) +
          1;

  final vehicle = bill.vehicle;
  await db
      .into(db.bills)
      .insertOnConflictUpdate(
        BillsCompanion.insert(
          id: bill.id,
          invoiceNo: bill.invoiceNo,
          date: bill.date,
          status: bill.status.name,
          payment: Value(bill.payment?.name),
          ratesIncludeGst: bill.ratesIncludeGst,
          registration: Value(vehicle.registration),
          makeModel: Value(vehicle.makeModel),
          odometer: Value(vehicle.odometer),
          customerName: Value(vehicle.customerName),
          customerPhone: Value(vehicle.customerPhone),
          seq: seq,
        ),
      );

  await (db.delete(
    db.billLines,
  )..where((row) => row.billId.equals(bill.id))).go();
  await db.batch((batch) {
    batch.insertAll(db.billLines, [
      for (final (position, line) in bill.lines.indexed)
        BillLinesCompanion.insert(
          billId: bill.id,
          position: position,
          name: line.name,
          rate: line.rate,
          gst: line.gst,
          kind: line.kind.name,
          code: Value(line.code),
          qty: line.qty,
        ),
    ]);
  });
}

/// The workshop's changes to its rate card, on the device's SQLite database.
class SqliteItemStore implements ItemStore {
  const SqliteItemStore(this._db);

  final AppDatabase _db;

  @override
  Future<ItemMasterData> load() async {
    CatalogItem item(
      String name,
      double rate,
      int gst,
      String kind,
      String code,
      int? stock,
    ) => CatalogItem(
      name: name,
      rate: rate,
      gst: gst,
      kind: _byName(ItemKind.values, kind, ItemKind.part),
      code: code,
      stock: stock,
    );

    final custom = await (_db.select(
      _db.customItems,
    )..orderBy([(row) => OrderingTerm.asc(row.position)])).get();
    final overrides = await _db.select(_db.itemOverrides).get();
    final hidden = await _db.select(_db.hiddenItems).get();

    return ItemMasterData(
      custom: [
        for (final row in custom)
          item(row.name, row.rate, row.gst, row.kind, row.code, row.stock),
      ],
      overrides: {
        for (final row in overrides)
          row.seedName: item(
            row.name,
            row.rate,
            row.gst,
            row.kind,
            row.code,
            row.stock,
          ),
      },
      hidden: {for (final row in hidden) row.seedName},
    );
  }

  @override
  Future<void> save(ItemMasterData data) =>
      _db.transaction(() => writeItems(_db, data));
}

/// Replaces the stored rate-card changes with [data]. Run inside a
/// transaction.
Future<void> writeItems(AppDatabase db, ItemMasterData data) async {
  await db.delete(db.customItems).go();
  await db.delete(db.itemOverrides).go();
  await db.delete(db.hiddenItems).go();
  await db.batch((batch) {
    batch.insertAll(db.customItems, [
      for (final (position, item) in data.custom.indexed)
        CustomItemsCompanion.insert(
          position: Value(position),
          name: item.name,
          rate: item.rate,
          gst: item.gst,
          kind: item.kind.name,
          code: Value(item.code),
          stock: Value(item.stock),
        ),
    ]);
    batch.insertAll(db.itemOverrides, [
      for (final MapEntry(key: seedName, value: item) in data.overrides.entries)
        ItemOverridesCompanion.insert(
          seedName: seedName,
          name: item.name,
          rate: item.rate,
          gst: item.gst,
          kind: item.kind.name,
          code: Value(item.code),
          stock: Value(item.stock),
        ),
    ]);
    batch.insertAll(db.hiddenItems, [
      for (final seedName in data.hidden)
        HiddenItemsCompanion.insert(seedName: seedName),
    ]);
  });
}

/// The workshop's own details, on the device's SQLite database. Kept as the
/// JSON map [WorkshopSettings] reads and writes, so a new field does not need
/// a schema change.
class SqliteSettingsStore implements SettingsStore {
  const SqliteSettingsStore(this._db);

  final AppDatabase _db;

  @override
  Future<Map<String, dynamic>?> load() async {
    final raw = await _db.readMeta(settingsKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  @override
  Future<void> save(Map<String, dynamic> settings) =>
      _db.writeMeta(settingsKey, jsonEncode(settings));
}

/// The data from just before the last import, on the device's SQLite
/// database, so undoing an import survives a restart.
class SqliteRestorePointStore implements RestorePointStore {
  const SqliteRestorePointStore(this._db);

  static const _key = 'restore_point';

  final AppDatabase _db;

  @override
  Future<String?> read() => _db.readMeta(_key);

  @override
  Future<void> keep(String backup) => _db.writeMeta(_key, backup);

  @override
  Future<void> clear() =>
      (_db.delete(_db.meta)..where((row) => row.key.equals(_key))).go();
}
