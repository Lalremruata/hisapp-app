import 'catalog.dart';
import 'vehicle.dart';

/// How the customer settled up.
enum PaymentMethod {
  cash('Cash'),
  upi('UPI'),
  card('Card'),
  due('Due');

  const PaymentMethod(this.label);

  final String label;
}

/// Where a bill is in its life.
enum BillStatus {
  /// Parked. The job may still be going on, and nothing has been collected.
  held('Held'),

  /// Issued and settled.
  paid('Paid');

  const BillStatus(this.label);

  final String label;
}

/// A bill as it was saved — everything needed to reopen it, reprice it or
/// print it again, months later.
class SavedBill {
  const SavedBill({
    required this.id,
    required this.invoiceNo,
    required this.date,
    required this.vehicle,
    required this.lines,
    required this.status,
    required this.ratesIncludeGst,
    this.payment,
  });

  /// Stable for the life of the bill, so reopening and saving again updates
  /// this bill rather than adding another.
  final String id;

  final String invoiceNo;
  final DateTime date;
  final VehicleDetails vehicle;
  final List<CartLine> lines;
  final BillStatus status;

  /// Whether the rates on this bill already carried GST.
  ///
  /// Snapshotted rather than read from the workshop's current setting: if the
  /// shop switches to inclusive pricing next year, every invoice printed
  /// before it must still show the figures the customer actually paid.
  final bool ratesIncludeGst;

  final PaymentMethod? payment;

  bool get isPaid => status == BillStatus.paid;

  /// Unpaid work: held, or settled as due. What a workshop chases.
  bool get isOutstanding => !isPaid || payment == PaymentMethod.due;

  SavedBill copyWith({
    VehicleDetails? vehicle,
    List<CartLine>? lines,
    BillStatus? status,
    PaymentMethod? payment,
    bool? ratesIncludeGst,
  }) => SavedBill(
    id: id,
    invoiceNo: invoiceNo,
    date: date,
    vehicle: vehicle ?? this.vehicle,
    lines: lines ?? this.lines,
    status: status ?? this.status,
    ratesIncludeGst: ratesIncludeGst ?? this.ratesIncludeGst,
    payment: payment ?? this.payment,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'invoiceNo': invoiceNo,
    'date': date.toIso8601String(),
    'vehicle': vehicle.toJson(),
    'lines': [for (final line in lines) line.toJson()],
    'status': status.name,
    'ratesIncludeGst': ratesIncludeGst,
    'payment': payment?.name,
  };

  /// Rebuilds a bill from storage, or null when the record cannot be read.
  static SavedBill? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final invoiceNo = json['invoiceNo'];
    if (id is! String || id.isEmpty) return null;
    if (invoiceNo is! String) return null;

    final lines = <CartLine>[];
    final rawLines = json['lines'];
    if (rawLines is List) {
      for (final entry in rawLines) {
        final line = CartLine.fromJson(entry);
        if (line != null) lines.add(line);
      }
    }

    final rawPayment = json['payment'];
    return SavedBill(
      id: id,
      invoiceNo: invoiceNo,
      date: DateTime.tryParse('${json['date']}') ?? DateTime(2026, 9, 16),
      vehicle: VehicleDetails.fromJson(json['vehicle']),
      lines: lines,
      status: BillStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => BillStatus.held,
      ),
      ratesIncludeGst: json['ratesIncludeGst'] == true,
      payment: rawPayment == null
          ? null
          : PaymentMethod.values
                .where((method) => method.name == rawPayment)
                .firstOrNull,
    );
  }
}

/// Every bill the workshop has saved, and where its numbering has got to.
class BillArchive {
  const BillArchive({this.bills = const [], this.nextNumber = 148});

  /// Newest last, the order they were raised in.
  final List<SavedBill> bills;

  /// The number the next bill to be saved will take.
  final int nextNumber;

  bool get isEmpty => bills.isEmpty && nextNumber == 148;

  Map<String, Object?> toJson() => {
    'bills': [for (final bill in bills) bill.toJson()],
    'nextNumber': nextNumber,
  };

  static BillArchive fromJson(Object? json) {
    if (json is! Map) return const BillArchive();
    final bills = <SavedBill>[];
    final raw = json['bills'];
    if (raw is List) {
      for (final entry in raw) {
        final bill = SavedBill.fromJson(entry);
        if (bill != null) bills.add(bill);
      }
    }
    final next = json['nextNumber'];
    return BillArchive(
      bills: bills,
      nextNumber: next is num && next > 0 ? next.toInt() : 148,
    );
  }
}
