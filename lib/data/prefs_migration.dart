import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bill.dart';
import '../state/item_store.dart';
import '../state/sqlite_stores.dart';
import 'database.dart';

/// Where builds before SQLite kept everything, one JSON string per key.
const _billsKey = 'bills.v1';
const _itemsKey = 'item_master.v3';
const _settingsKey = 'settings.v1';

const _migratedKey = 'migrated_from_prefs';

/// Carries a workshop's bills, rate card and details over from the
/// SharedPreferences records older builds wrote. Runs once: after that the
/// database is the record.
///
/// The old records are left where they are, so a workshop that has to go back
/// to an older build still finds its history.
Future<void> importFromPrefs(AppDatabase db) async {
  if (await db.readMeta(_migratedKey) != null) return;

  final prefs = await SharedPreferences.getInstance();
  Object? read(String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  final bills = BillArchive.fromJson(read(_billsKey));
  final items = ItemMasterData.fromJson(read(_itemsKey));
  final settings = read(_settingsKey);

  await db.transaction(() async {
    for (final bill in bills.bills) {
      await writeBill(db, bill);
    }
    if (!bills.isEmpty) {
      await db.writeMeta(nextNumberKey, '${bills.nextNumber}');
    }
    if (!items.isEmpty) await writeItems(db, items);
    if (settings is Map<String, dynamic>) {
      await db.writeMeta(settingsKey, jsonEncode(settings));
    }
    await db.writeMeta(_migratedKey, DateTime.now().toIso8601String());
  });
}
