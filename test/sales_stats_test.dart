import 'package:flutter_test/flutter_test.dart';
import 'package:hisap_app_2_0/models/bill.dart';
import 'package:hisap_app_2_0/models/catalog.dart';
import 'package:hisap_app_2_0/models/pricing.dart';
import 'package:hisap_app_2_0/models/sales_stats.dart';
import 'package:hisap_app_2_0/models/vehicle.dart';

final _now = DateTime(2026, 10, 12, 15);

CartLine _line(
  String name,
  double rate, {
  int qty = 1,
  int gst = 18,
  ItemKind kind = ItemKind.part,
}) =>
    CartLine(name: name, rate: rate, gst: gst, kind: kind, code: '', qty: qty);

var _serial = 0;

SavedBill _bill(
  List<CartLine> lines, {
  DateTime? date,
  BillStatus status = BillStatus.paid,
  PaymentMethod? payment = PaymentMethod.cash,
  bool inclusive = false,
  String registration = '',
  String name = '',
  String phone = '',
  String makeModel = '',
}) => SavedBill(
  id: 'bill-${_serial++}',
  invoiceNo: 'INV/$_serial',
  date: date ?? DateTime(2026, 10, 5),
  vehicle: VehicleDetails(
    registration: registration,
    makeModel: makeModel,
    customerName: name,
    customerPhone: phone,
  ),
  lines: lines,
  status: status,
  ratesIncludeGst: inclusive,
  payment: status == BillStatus.paid ? payment : null,
);

SalesStats _stats(
  List<SavedBill> bills, {
  SalesPeriod period = SalesPeriod.allTime,
  List<CatalogItem> rateCard = const [],
}) => SalesStats.from(bills, period: period, now: _now, rateCard: rateCard);

void main() {
  group('periods', () {
    test('this month runs from the 1st', () {
      const p = SalesPeriod.thisMonth;
      expect(p.contains(DateTime(2026, 10, 1), now: _now), isTrue);
      expect(p.contains(DateTime(2026, 9, 30, 23, 59), now: _now), isFalse);
    });

    test('last month is the whole of the month before, and only that', () {
      const p = SalesPeriod.lastMonth;
      expect(p.contains(DateTime(2026, 9, 1), now: _now), isTrue);
      expect(p.contains(DateTime(2026, 9, 30, 23, 59), now: _now), isTrue);
      expect(p.contains(DateTime(2026, 10, 1), now: _now), isFalse);
      expect(p.contains(DateTime(2026, 8, 31), now: _now), isFalse);
    });

    test('last month in January is December of the year before', () {
      final january = DateTime(2027, 1, 10);
      const p = SalesPeriod.lastMonth;
      expect(p.contains(DateTime(2026, 12, 15), now: january), isTrue);
      expect(p.contains(DateTime(2027, 1, 2), now: january), isFalse);
    });

    test('this year is the financial year, from 1 April', () {
      const p = SalesPeriod.thisYear;
      expect(p.contains(DateTime(2026, 4, 1), now: _now), isTrue);
      expect(p.contains(DateTime(2026, 3, 31), now: _now), isFalse);

      // In February the year still started last April.
      final february = DateTime(2027, 2, 1);
      expect(p.contains(DateTime(2026, 4, 1), now: february), isTrue);
      expect(p.contains(DateTime(2026, 3, 31), now: february), isFalse);
    });

    test('the figures follow the period', () {
      final bills = [
        _bill([_line('Oil Filter', 100)], date: DateTime(2026, 10, 2)),
        _bill([_line('Oil Filter', 100)], date: DateTime(2026, 9, 2)),
      ];
      expect(_stats(bills, period: SalesPeriod.thisMonth).billCount, 1);
      expect(_stats(bills, period: SalesPeriod.lastMonth).billCount, 1);
      expect(_stats(bills).billCount, 2);
    });
  });

  group('totals', () {
    test('count issued bills, due ones included, and leave held ones out', () {
      final stats = _stats([
        _bill([_line('Oil Filter', 100)]),
        _bill([_line('Air Filter', 200)], payment: PaymentMethod.due),
        _bill([_line('Battery', 5000)], status: BillStatus.held),
      ]);

      expect(stats.billCount, 2);
      expect(stats.sales, closeTo(300, 1e-9));
      expect(stats.gst, closeTo(54, 1e-9));
      expect(stats.collected, 354);
      expect(stats.dueAmount, 236);
      expect(stats.averageBill, closeTo(150, 1e-9));
      expect(stats.items.map((item) => item.name), isNot(contains('Battery')));
    });

    test('price each bill the way it was raised, as the invoice does', () {
      final exclusive = [_line('Oil Filter', 320, qty: 2)];
      final inclusive = [_line('General service', 1180, kind: ItemKind.labour)];
      final stats = _stats([
        _bill(exclusive),
        _bill(inclusive, inclusive: true),
      ]);

      final expected =
          priceLines(exclusive, inclusive: false).taxable +
          priceLines(inclusive, inclusive: true).taxable;
      expect(stats.sales, closeTo(expected, 1e-9));
      expect(stats.partsSales, closeTo(640, 1e-9));
      expect(stats.labourSales, closeTo(1000, 1e-9));
    });

    test('nothing issued is an empty period, not a divide by zero', () {
      final stats = _stats([
        _bill([_line('Oil Filter', 100)], status: BillStatus.held),
      ]);
      expect(stats.isEmpty, isTrue);
      expect(stats.averageBill, 0);
      expect(stats.items, isEmpty);
    });
  });

  group('parts and jobs', () {
    test('rank by sales, and add up across bills', () {
      final stats = _stats([
        _bill([_line('Oil Filter', 320, qty: 2), _line('Air Filter', 450)]),
        _bill([_line('Oil Filter', 320)]),
        _bill([_line('Wheel alignment', 500, kind: ItemKind.labour)]),
      ]);

      expect(stats.items.map((item) => item.name), [
        'Oil Filter',
        'Wheel alignment',
        'Air Filter',
      ]);
      final filter = stats.items.first;
      expect(filter.qty, 3);
      expect(filter.billCount, 2);
      expect(filter.sales, closeTo(960, 1e-9));
      expect(filter.share, closeTo(960 / 1910, 1e-9));
    });

    test('the same name typed differently is the same item', () {
      final stats = _stats([
        _bill([_line('Oil Filter', 100), _line(' oil filter ', 100)]),
      ]);
      expect(stats.items, hasLength(1));
      expect(stats.items.single.qty, 2);
      // Twice on one bill is still one bill.
      expect(stats.items.single.billCount, 1);
    });

    test('a part and a job of the same name are kept apart', () {
      final stats = _stats([
        _bill([
          _line('Coolant', 380),
          _line('Coolant', 200, kind: ItemKind.labour),
        ]),
      ]);
      expect(stats.items, hasLength(2));
    });

    test('list what is on the rate card and sold nothing', () {
      final stats = _stats(
        [
          _bill([_line(seedCatalog[1].name, seedCatalog[1].rate)]),
        ],
        rateCard: [seedCatalog[0], seedCatalog[1], seedCatalog[10]],
      );
      expect(stats.unsold, [seedCatalog[0], seedCatalog[10]]);
    });
  });

  group('customers', () {
    test('a vehicle is one customer, however its plate was typed', () {
      final stats = _stats([
        _bill(
          [_line('Oil Filter', 100)],
          registration: 'mz 01 ab 1234',
          date: DateTime(2026, 9, 1),
          makeModel: 'BOLERO',
        ),
        _bill(
          [_line('Oil Filter', 300)],
          registration: 'MZ01AB1234',
          date: DateTime(2026, 10, 1),
          name: 'Lalthanga',
        ),
        _bill([_line('Oil Filter', 200)], registration: 'MZ 02 C 9'),
      ]);

      expect(stats.customers, hasLength(2));
      final top = stats.customers.first;
      expect(top.billCount, 2);
      expect(top.sales, closeTo(400, 1e-9));
      expect(top.lastVisit, DateTime(2026, 10, 1));
      // The newest visit names it, but an older make is kept over a blank.
      expect(top.label, 'MZ01AB1234');
      expect(top.customerName, 'Lalthanga');
      expect(top.makeModel, 'BOLERO');
    });

    test('without a plate, by name, then by phone, then a walk-in', () {
      final stats = _stats([
        _bill([_line('Oil Filter', 400)], name: 'Mary'),
        _bill(
          [_line('Oil Filter', 300)],
          name: 'mary ',
          date: DateTime(2026, 10, 1),
        ),
        _bill([_line('Oil Filter', 200)], phone: '98220 41188'),
        _bill([_line('Oil Filter', 50)]),
        _bill([_line('Oil Filter', 50)]),
      ]);

      expect(stats.customers.map((c) => c.label), [
        'Mary',
        '98220 41188',
        SalesStats.walkInLabel,
      ]);
      expect(stats.customers.last.billCount, 2);
    });
  });
}
