import 'bill.dart';
import 'catalog.dart';
import 'pricing.dart';

/// The stretch of days the sales figures cover.
enum SalesPeriod {
  thisMonth('This month'),
  lastMonth('Last month'),

  /// The financial year, April to March — the year the invoice numbers and
  /// the GST returns run on.
  thisYear('This year'),
  allTime('All time');

  const SalesPeriod(this.label);

  final String label;

  /// The first day in the period, or null when it reaches back to the start.
  DateTime? start(DateTime now) => switch (this) {
    thisMonth => DateTime(now.year, now.month),
    lastMonth => DateTime(now.year, now.month - 1),
    thisYear => DateTime(now.month >= 4 ? now.year : now.year - 1, 4),
    allTime => null,
  };

  /// The first day after the period, or null when it runs on to today.
  DateTime? end(DateTime now) => switch (this) {
    lastMonth => DateTime(now.year, now.month),
    thisMonth || thisYear || allTime => null,
  };

  bool contains(DateTime day, {required DateTime now}) {
    final from = start(now);
    final until = end(now);
    if (from != null && day.isBefore(from)) return false;
    if (until != null && !day.isBefore(until)) return false;
    return true;
  }
}

/// How one part or job sold over a period.
class ItemSales {
  ItemSales._(this.name, this.kind);

  final String name;
  final ItemKind kind;

  /// Pieces for a part, times done for a job.
  int qty = 0;

  /// What it brought in before GST.
  double sales = 0;

  /// How many bills it was on.
  int billCount = 0;

  /// Its part of everything sold in the period, from 0 to 1.
  double share = 0;
}

/// Everything one vehicle — or, failing a registration, one customer — was
/// billed over a period.
class CustomerSales {
  CustomerSales._(this.label);

  /// The registration, or the customer's name or phone when there is none.
  String label;

  String makeModel = '';
  String customerName = '';
  int billCount = 0;
  double sales = 0;
  DateTime? lastVisit;
}

/// What the workshop sold over a period: the totals, which parts and jobs
/// earned the most and least, and who the business came from.
///
/// Counts issued bills only — paid, or settled as due. A held bill is a job
/// still on the ramp, not a sale. Sales are the taxable value, before GST:
/// the GST is the government's, not the workshop's.
class SalesStats {
  SalesStats._();

  /// Works the figures out from [bills]. [rateCard] is what the workshop can
  /// bill today, so the parts and jobs that sold nothing can be listed too.
  factory SalesStats.from(
    Iterable<SavedBill> bills, {
    required SalesPeriod period,
    required DateTime now,
    Iterable<CatalogItem> rateCard = const [],
  }) {
    final stats = SalesStats._();
    final items = <String, ItemSales>{};
    final customers = <String, CustomerSales>{};

    for (final bill in bills) {
      if (!bill.isPaid || !period.contains(bill.date, now: now)) continue;
      final inclusive = bill.ratesIncludeGst;

      var billSales = 0.0;
      final onThisBill = <String>{};
      for (final line in bill.lines) {
        final priced = priceLine(line, inclusive: inclusive);
        billSales += priced.taxable;
        stats.gst += priced.tax;
        switch (line.kind) {
          case ItemKind.part:
            stats.partsSales += priced.taxable;
          case ItemKind.labour:
            stats.labourSales += priced.taxable;
        }

        final key = _itemKey(line.name, line.kind);
        final item = items[key] ??= ItemSales._(line.name.trim(), line.kind);
        item.qty += line.qty;
        item.sales += priced.taxable;
        if (onThisBill.add(key)) item.billCount++;
      }

      final total = payableTotal(bill.lines, inclusive: inclusive);
      stats.sales += billSales;
      stats.collected += total;
      stats.billCount++;
      if (bill.payment == PaymentMethod.due) stats.dueAmount += total;

      final (key, label) = _customerKey(bill);
      final customer = customers[key] ??= CustomerSales._(label);
      customer.billCount++;
      customer.sales += billSales;
      // The newest visit says what the vehicle and its owner are called now.
      if (customer.lastVisit == null ||
          !bill.date.isBefore(customer.lastVisit!)) {
        customer
          ..lastVisit = bill.date
          ..label = label;
        if (bill.vehicle.makeModel.trim().isNotEmpty) {
          customer.makeModel = bill.vehicle.makeModel.trim();
        }
        if (bill.vehicle.customerName.trim().isNotEmpty) {
          customer.customerName = bill.vehicle.customerName.trim();
        }
      }
    }

    for (final item in items.values) {
      item.share = stats.sales > 0 ? item.sales / stats.sales : 0;
    }

    stats.items = items.values.toList()
      ..sort((a, b) => b.sales.compareTo(a.sales));
    stats.customers = customers.values.toList()
      ..sort((a, b) => b.sales.compareTo(a.sales));

    final listed = <String>{};
    stats.unsold = [
      for (final item in rateCard)
        if (!items.containsKey(_itemKey(item.name, item.kind)) &&
            listed.add(_itemKey(item.name, item.kind)))
          item,
    ];

    return stats;
  }

  /// Sales before GST.
  double sales = 0;
  double gst = 0;

  /// What the issued bills came to, GST and rounding included.
  int collected = 0;

  int billCount = 0;

  /// What bills settled as due came to — sold, but not yet collected.
  int dueAmount = 0;

  double partsSales = 0;
  double labourSales = 0;

  /// The average bill, before GST.
  double get averageBill => billCount == 0 ? 0 : sales / billCount;

  /// Every part and job that sold, the biggest earner first.
  List<ItemSales> items = const [];

  /// What is on the rate card but did not sell at all in the period.
  List<CatalogItem> unsold = const [];

  /// Every vehicle or customer billed, the biggest first.
  List<CustomerSales> customers = const [];

  bool get isEmpty => billCount == 0;

  /// A line typed in at the counter as "oil filter " is the same oil filter.
  static String _itemKey(String name, ItemKind kind) =>
      '${kind.name}:${name.trim().toLowerCase()}';

  /// Bills are put together by registration, then by name, then by phone. A
  /// bill with none of them is a walk-in.
  static (String, String) _customerKey(SavedBill bill) {
    final vehicle = bill.vehicle;
    final registration = vehicle.registration.trim().toUpperCase();
    if (registration.isNotEmpty) {
      return (
        'reg:${registration.replaceAll(RegExp(r'\s+'), '')}',
        registration,
      );
    }
    final name = vehicle.customerName.trim();
    if (name.isNotEmpty) return ('name:${name.toLowerCase()}', name);
    final phone = vehicle.customerPhone.replaceAll(RegExp(r'\D'), '');
    if (phone.isNotEmpty) return ('phone:$phone', vehicle.customerPhone.trim());
    return ('walk-in', walkInLabel);
  }

  static const walkInLabel = 'Walk-in (no vehicle or name)';
}
