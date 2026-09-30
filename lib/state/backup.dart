import 'dart:convert';

import '../models/bill.dart';
import 'billing_model.dart';
import 'item_store.dart';

/// Marks a file as one of ours, so a stray JSON file is turned away before
/// anything is written.
const _format = 'hisap-backup';

/// The version this build writes. A backup from a newer build is refused
/// rather than half-read.
const backupVersion = 1;

/// A backup file that cannot be restored, with a reason fit to show at the
/// counter.
class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// How a backup is brought onto a device.
enum RestoreMode {
  /// Adds what the device does not have yet and keeps everything it does.
  merge,

  /// Wipes the device and puts the backup in its place.
  replace,
}

/// Everything a workshop keeps — its details, its rate card and every bill —
/// as one file it can move to another device or put somewhere safe.
///
/// Written through the models' own JSON, so a backup does not care how the
/// database lays its tables out.
class Backup {
  const Backup({
    required this.exportedAt,
    required this.settings,
    required this.bills,
    required this.nextNumber,
    required this.items,
    this.unreadable = 0,
  });

  final DateTime exportedAt;

  /// The workshop's details. Null when the file carries none, so restoring it
  /// keeps the device's own rather than falling back to the defaults.
  final WorkshopSettings? settings;

  final List<SavedBill> bills;
  final int nextNumber;
  final ItemMasterData items;

  /// Bills in the file that could not be read and were left out.
  final int unreadable;

  /// A name that sorts by date: hisap-backup-2026-09-28.json
  String get fileName => 'hisap-backup-${_day(exportedAt)}.json';

  Map<String, Object?> toJson() => {
    'format': _format,
    'version': backupVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'workshop': settings?.toJson(),
    'nextNumber': nextNumber,
    'bills': [for (final bill in bills) bill.toJson()],
    'items': items.toJson(),
  };

  String encode() => jsonEncode(toJson());

  /// Reads a backup file, or throws a [BackupException] saying why not.
  ///
  /// A bill or item that cannot be read is dropped and counted, as it is when
  /// the device loads its own records: one bad row must not cost the rest.
  static Backup parse(String text) {
    const notOurs = BackupException(
      'This file is not a Hisap backup. Pick the .json file made by '
      '"Export backup".',
    );

    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      throw notOurs;
    }
    if (json is! Map || json['format'] != _format) throw notOurs;

    final version = json['version'];
    if (version is! num) throw notOurs;
    if (version > backupVersion) {
      throw const BackupException(
        'This backup was made by a newer version of the app. Update the app '
        'on this device, then import it again.',
      );
    }

    final rawBills = json['bills'];
    final archive = BillArchive.fromJson({
      'bills': rawBills,
      'nextNumber': json['nextNumber'],
    });
    final workshop = json['workshop'];

    return Backup(
      exportedAt: DateTime.tryParse('${json['exportedAt']}') ?? DateTime.now(),
      settings: workshop is Map<String, dynamic>
          ? WorkshopSettings.fromJson(workshop)
          : null,
      bills: archive.bills,
      nextNumber: archive.nextNumber,
      items: ItemMasterData.fromJson(json['items']),
      unreadable: rawBills is List ? rawBills.length - archive.bills.length : 0,
    );
  }

  /// This backup with [incoming] brought in on top of it: bills this one does
  /// not have are added after its own, and anything both have keeps this
  /// one's version. The workshop's details stay as they are.
  ///
  /// The numbering carries on from the higher of the two, so no number either
  /// side has handed out is given out again.
  MergeResult mergeIn(Backup incoming) {
    final ids = {for (final bill in bills) bill.id};
    final numbers = {for (final bill in bills) bill.invoiceNo};
    final added = <SavedBill>[];
    var clashes = 0;
    for (final bill in incoming.bills) {
      if (!ids.add(bill.id)) continue;
      if (numbers.contains(bill.invoiceNo)) clashes++;
      added.add(bill);
    }

    String key(String name) => name.trim().toLowerCase();
    final names = {for (final item in items.custom) key(item.name)};

    return MergeResult(
      backup: Backup(
        exportedAt: exportedAt,
        settings: settings,
        bills: [...bills, ...added],
        nextNumber: nextNumber > incoming.nextNumber
            ? nextNumber
            : incoming.nextNumber,
        items: ItemMasterData(
          custom: [
            ...items.custom,
            for (final item in incoming.items.custom)
              if (names.add(key(item.name))) item,
          ],
          overrides: {...incoming.items.overrides, ...items.overrides},
          hidden: {...items.hidden, ...incoming.items.hidden},
        ),
      ),
      added: added.length,
      skipped: incoming.bills.length - added.length,
      clashes: clashes,
    );
  }
}

/// What a merge came to, and how it got there.
class MergeResult {
  const MergeResult({
    required this.backup,
    required this.added,
    required this.skipped,
    required this.clashes,
  });

  final Backup backup;

  /// Bills brought in.
  final int added;

  /// Bills the device already had.
  final int skipped;

  /// Bills brought in whose invoice number a bill already here also carries —
  /// two devices that numbered bills independently.
  final int clashes;
}

/// What a restore did, for the message afterwards.
class RestoreReport {
  const RestoreReport({
    required this.mode,
    required this.bills,
    this.skipped = 0,
    this.clashes = 0,
  });

  final RestoreMode mode;

  /// Bills now on the device (replace) or brought in (merge).
  final int bills;

  final int skipped;
  final int clashes;
}

/// Where the device's data from just before the last import is kept, so an
/// import can be undone.
abstract interface class RestorePointStore {
  Future<String?> read();

  Future<void> keep(String backup);

  Future<void> clear();
}

/// A store that forgets when the process does. The default, so a test can
/// build a [BillingModel] without a database.
class InMemoryRestorePointStore implements RestorePointStore {
  String? _backup;

  @override
  Future<String?> read() async => _backup;

  @override
  Future<void> keep(String backup) async => _backup = backup;

  @override
  Future<void> clear() async => _backup = null;
}

/// 2026-09-28
String _day(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
