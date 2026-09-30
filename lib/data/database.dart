import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// A saved bill. The vehicle and whoever is paying are kept on the bill
/// itself, as they were on the day — a car seen twice is two snapshots, not
/// one record that later edits would rewrite.
///
/// The invoice number is indexed but not unique: the JSON records this was
/// imported from never enforced it, and one duplicate must not cost the
/// workshop the rest of its history.
@DataClassName('BillRow')
@TableIndex(name: 'bills_invoice_no', columns: {#invoiceNo})
class Bills extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNo => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text()();
  TextColumn get payment => text().nullable()();
  BoolColumn get ratesIncludeGst => boolean()();
  TextColumn get registration => text().withDefault(const Constant(''))();
  TextColumn get makeModel => text().withDefault(const Constant(''))();
  TextColumn get odometer => text().withDefault(const Constant(''))();
  TextColumn get customerName => text().withDefault(const Constant(''))();
  TextColumn get customerPhone => text().withDefault(const Constant(''))();

  /// The order bills were raised in. Kept when a bill is saved again, so a
  /// correction does not move it to the end of the list.
  IntColumn get seq => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One line of a bill, copied off the rate card when it was added.
@DataClassName('BillLineRow')
class BillLines extends Table {
  TextColumn get billId =>
      text().references(Bills, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();
  RealColumn get rate => real()();
  IntColumn get gst => integer()();
  TextColumn get kind => text()();
  TextColumn get code => text().withDefault(const Constant(''))();
  IntColumn get qty => integer()();

  @override
  Set<Column> get primaryKey => {billId, position};
}

/// The columns every rate-card item carries.
mixin ItemColumns on Table {
  TextColumn get name => text()();
  RealColumn get rate => real()();
  IntColumn get gst => integer()();
  TextColumn get kind => text()();
  TextColumn get code => text().withDefault(const Constant(''))();
  IntColumn get stock => integer().nullable()();
}

/// Items typed in at the counter, in the order they were added.
@DataClassName('CustomItemRow')
class CustomItems extends Table with ItemColumns {
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {position};
}

/// Shipped items the workshop has repriced, keyed by the shipped name.
@DataClassName('ItemOverrideRow')
class ItemOverrides extends Table with ItemColumns {
  TextColumn get seedName => text()();

  @override
  Set<Column> get primaryKey => {seedName};
}

/// Shipped items the workshop has taken off its rate card.
@DataClassName('HiddenItemRow')
class HiddenItems extends Table {
  TextColumn get seedName => text()();

  @override
  Set<Column> get primaryKey => {seedName};
}

/// Single values: where the numbering has got to, the workshop's details.
@DataClassName('MetaRow')
class Meta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Everything the workshop keeps, on the device.
@DriftDatabase(
  tables: [Bills, BillLines, CustomItems, ItemOverrides, HiddenItems, Meta],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The database the app runs on: a file on mobile and desktop, the
  /// browser's storage on the web.
  AppDatabase.open()
    : super(
        driftDatabase(
          name: 'hisap',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<String?> readMeta(String key) async {
    final row = await (select(
      meta,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeMeta(String key, String value) => into(
    meta,
  ).insertOnConflictUpdate(MetaCompanion.insert(key: key, value: value));
}
