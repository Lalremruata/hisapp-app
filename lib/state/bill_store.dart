import '../models/bill.dart';

/// Where saved bills are kept between sessions.
///
/// Bills are written one at a time: a correction to today's bill should not
/// cost rewriting every bill the workshop has ever raised.
abstract interface class BillStore {
  Future<BillArchive> load();

  /// Adds [bill], or replaces the one with its id, and records where the
  /// numbering has got to.
  Future<void> saveBill(SavedBill bill, {required int nextNumber});

  Future<void> deleteBill(String id);

  /// Puts [archive] in place of everything stored, as one step.
  Future<void> replaceAll(BillArchive archive);
}

/// A store that forgets when the process does. The default, so a test can
/// build a [BillingModel] without standing up a platform channel.
class InMemoryBillStore implements BillStore {
  InMemoryBillStore([BillArchive? initial])
    : _bills = [...?initial?.bills],
      _nextNumber = initial?.nextNumber ?? const BillArchive().nextNumber;

  final List<SavedBill> _bills;
  int _nextNumber;

  @override
  Future<BillArchive> load() async =>
      BillArchive(bills: List.of(_bills), nextNumber: _nextNumber);

  @override
  Future<void> saveBill(SavedBill bill, {required int nextNumber}) async {
    final at = _bills.indexWhere((candidate) => candidate.id == bill.id);
    if (at >= 0) {
      _bills[at] = bill;
    } else {
      _bills.add(bill);
    }
    _nextNumber = nextNumber;
  }

  @override
  Future<void> deleteBill(String id) async =>
      _bills.removeWhere((candidate) => candidate.id == id);

  @override
  Future<void> replaceAll(BillArchive archive) async {
    _bills
      ..clear()
      ..addAll(archive.bills);
    _nextNumber = archive.nextNumber;
  }
}
