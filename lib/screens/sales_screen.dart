import 'package:flutter/widgets.dart';

import '../models/catalog.dart';
import '../models/money.dart';
import '../models/sales_stats.dart';
import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';

/// How the workshop is selling: the takings over a period, which parts and
/// jobs bring the money in and which sit on the shelf, and which vehicles
/// and customers the business comes from.
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key, this.now});

  /// Today, for the periods. Left null it is the clock's; a test pins it.
  final DateTime? now;

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  /// How many rows a list shows before "Show all".
  static const _preview = 10;

  SalesPeriod _period = SalesPeriod.thisMonth;
  bool _slowSellers = false;
  bool _allItems = false;
  bool _allCustomers = false;

  @override
  Widget build(BuildContext context) {
    N.watch(context);
    final model = BillingScope.of(context);
    final inset = MediaQuery.paddingOf(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final gutter = wide ? 24.0 : 20.0;
    final now = widget.now ?? DateTime.now();

    final stats = SalesStats.from(
      model.bills,
      period: _period,
      now: now,
      rateCard: model.items,
    );

    return ColoredBox(
      color: N.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Padding(
              padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 6),
              child: _PeriodPicker(
                value: _period,
                wide: wide,
                onChanged: (period) => setState(() {
                  _period = period;
                  _allItems = false;
                  _allCustomers = false;
                }),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 14),
              child: Text(_range(now), style: N.caption(size: 14)),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  0,
                  gutter,
                  24 + inset.bottom,
                ),
                children: [
                  _Tiles(stats: stats),
                  const SizedBox(height: 10),
                  if (stats.isEmpty)
                    const _Empty()
                  else ...[
                    Text(
                      'Parts ${money(stats.partsSales)} · '
                      'Labour ${money(stats.labourSales)} · '
                      'GST collected ${money(stats.gst)}',
                      style: N.caption(size: 14),
                    ),
                    const SizedBox(height: 26),
                    ..._items(stats, wide: wide),
                    const SizedBox(height: 26),
                    ..._customers(stats),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The days the figures cover, written out.
  String _range(DateTime now) {
    final from = _period.start(now);
    final until = _period.end(now);
    if (from == null) return 'Every issued bill. Held bills are not counted.';
    final last = until == null
        ? 'today'
        : BillingModel.dateLabel(until.subtract(const Duration(days: 1)));
    return '${BillingModel.dateLabel(from)} to $last · '
        'issued bills only, held bills are not counted';
  }

  List<Widget> _items(SalesStats stats, {required bool wide}) {
    final best = stats.items;
    final List<Widget> rows;
    final int total;

    if (_slowSellers) {
      // What did not sell at all says the most, so it comes first.
      final unsold = stats.unsold;
      final least = best.reversed.toList();
      total = unsold.length + least.length;
      var budget = _allItems ? total : _preview;
      rows = [
        if (unsold.isNotEmpty && budget > 0) ...[
          _SubHead('Not sold this period', count: unsold.length),
          for (final item in unsold.take(budget)) _UnsoldRow(item: item),
        ],
      ];
      budget -= unsold.length;
      if (least.isNotEmpty && budget > 0) {
        rows
          ..add(_SubHead('Sold the least', count: least.length))
          ..addAll([
            for (final item in least.take(budget))
              _ItemRow(item: item, top: best.first.sales),
          ]);
      }
    } else {
      total = best.length;
      rows = [
        for (final (i, item) in best.take(_allItems ? total : _preview).indexed)
          _ItemRow(item: item, top: best.first.sales, rank: i + 1),
      ];
    }

    return [
      Text('Parts & jobs', style: N.font(size: 20, weight: FontWeight.w600)),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: NSegmented<bool>(
          key: const ValueKey('sales-items-mode'),
          options: const [false, true],
          value: _slowSellers,
          expand: !wide,
          verticalPadding: 8,
          labelOf: (slow) => slow ? 'Slow sellers' : 'Best sellers',
          onChanged: (slow) => setState(() {
            _slowSellers = slow;
            _allItems = false;
          }),
        ),
      ),
      const SizedBox(height: 12),
      ...rows,
      if (total > _preview)
        _ShowAll(
          all: _allItems,
          count: total,
          onPressed: () => setState(() => _allItems = !_allItems),
        ),
    ];
  }

  List<Widget> _customers(SalesStats stats) {
    final customers = stats.customers;
    return [
      Text('Top customers', style: N.font(size: 20, weight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(
        'By vehicle registration, or by name when no vehicle was entered.',
        style: N.caption(size: 14),
      ),
      const SizedBox(height: 12),
      for (final (i, customer)
          in customers
              .take(_allCustomers ? customers.length : _preview)
              .indexed)
        _CustomerRow(customer: customer, rank: i + 1),
      if (customers.length > _preview)
        _ShowAll(
          all: _allCustomers,
          count: customers.length,
          onPressed: () => setState(() => _allCustomers = !_allCustomers),
        ),
    ];
  }
}

/// The four periods: one row on a tablet, two by two on a phone, where four
/// abreast would break "month" in half.
class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({
    required this.value,
    required this.wide,
    required this.onChanged,
  });

  final SalesPeriod value;
  final bool wide;
  final ValueChanged<SalesPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    NSegmented<SalesPeriod> group(List<SalesPeriod> options) => NSegmented(
      options: options,
      value: value,
      expand: !wide,
      labelOf: (period) => period.label,
      onChanged: onChanged,
    );

    if (wide) {
      return Align(
        alignment: Alignment.centerLeft,
        child: group(SalesPeriod.values),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        group(const [SalesPeriod.thisMonth, SalesPeriod.lastMonth]),
        const SizedBox(height: 8),
        group(const [SalesPeriod.thisYear, SalesPeriod.allTime]),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 20, 16),
    child: Row(
      children: [
        const BackButtonN(),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Sales',
            style: N.font(size: 24, weight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

/// The four figures the period comes down to. Four abreast on a tablet, two
/// by two on a phone.
class _Tiles extends StatelessWidget {
  const _Tiles({required this.stats});

  final SalesStats stats;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _Tile(label: 'Sales before GST', value: rupees(stats.sales), lead: true),
      _Tile(label: 'Bills issued', value: '${stats.billCount}'),
      _Tile(label: 'Average bill', value: rupees(stats.averageBill)),
      _Tile(
        label: 'Due, not yet paid',
        value: rupees(stats.dueAmount),
        warn: stats.dueAmount > 0,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final columns = constraints.maxWidth >= 640 ? 4 : 2;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    this.lead = false,
    this.warn = false,
  });

  final String label;
  final String value;

  /// The figure the screen leads with, drawn a little larger.
  final bool lead;

  /// Money still owed: marked, in words as well as colour.
  final bool warn;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: BoxDecoration(
      color: N.panel,
      borderRadius: N.brLg,
      border: Border.all(color: N.line, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: N.caption(size: 14)),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: N.font(
              size: lead ? 30 : 26,
              weight: FontWeight.w600,
              color: warn ? N.warningInk : N.text,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SubHead extends StatelessWidget {
  const _SubHead(this.title, {required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 10),
    child: Kicker('$title · $count'),
  );
}

/// The frame every row in the lists sits in.
class _RowCard extends StatelessWidget {
  const _RowCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: N.panel,
        borderRadius: N.brLg,
        border: Border.all(color: N.line, width: 1.5),
      ),
      child: child,
    ),
  );
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.top, this.rank});

  final ItemSales item;

  /// What the best seller made, so every bar is drawn against it.
  final double top;

  /// Its place among the best sellers, when the list is in that order.
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final one = item.qty == 1;
    final unit = item.kind == ItemKind.part
        ? (one ? 'pc' : 'pcs')
        : (one ? 'time' : 'times');
    final share = (item.share * 100).toStringAsFixed(item.share < 0.1 ? 1 : 0);

    return _RowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rank != null)
                SizedBox(
                  width: 30,
                  child: Text(
                    '$rank',
                    style: N.font(
                      size: 17,
                      weight: FontWeight.w600,
                      color: N.t(0.55),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: N.font(size: 17, weight: FontWeight.w600),
                        ),
                        _KindTag(item.kind),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.qty} $unit · on ${item.billCount} '
                      '${item.billCount == 1 ? 'bill' : 'bills'} · '
                      '$share% of sales',
                      style: N.caption(size: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                money(item.sales),
                style: N.font(size: 18, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _Bar(fraction: top > 0 ? item.sales / top : 0),
        ],
      ),
    );
  }
}

/// A thin meter: the row's sales against the best seller's. The track is
/// a pale step of the same accent, so the bar reads across its whole length.
class _Bar extends StatelessWidget {
  const _Bar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 6,
      decoration: BoxDecoration(color: N.a(0.14), borderRadius: N.brSm),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: fraction.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(color: N.accent, borderRadius: N.brSm),
        ),
      ),
    ),
  );
}

class _UnsoldRow extends StatelessWidget {
  const _UnsoldRow({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) => _RowCard(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: N.font(size: 17, weight: FontWeight.w600),
                  ),
                  _KindTag(item.kind),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [
                  'Rate ${money(item.rate)}',
                  if (item.stock != null) '${item.stock} in stock',
                ].join(' · '),
                style: N.caption(size: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const NTag.warning('No sales'),
      ],
    ),
  );
}

class _KindTag extends StatelessWidget {
  const _KindTag(this.kind);

  final ItemKind kind;

  @override
  Widget build(BuildContext context) => kind == ItemKind.part
      ? const NTag.neutral('Part', icon: PhosphorIcons.cube)
      : const NTag.info('Job', icon: PhosphorIcons.car);
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.customer, required this.rank});

  final CustomerSales customer;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final visits = customer.billCount;
    final last = customer.lastVisit;

    return _RowCard(
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: N.font(
                size: 17,
                weight: FontWeight.w600,
                color: N.t(0.55),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  customer.label,
                  style: N.font(size: 17, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (customer.makeModel.isNotEmpty) customer.makeModel,
                    if (customer.customerName.isNotEmpty &&
                        customer.customerName != customer.label)
                      customer.customerName,
                    '$visits ${visits == 1 ? 'visit' : 'visits'}',
                    if (last != null) 'last ${BillingModel.dateLabel(last)}',
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: N.caption(size: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            money(customer.sales),
            style: N.font(size: 18, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ShowAll extends StatelessWidget {
  const _ShowAll({
    required this.all,
    required this.count,
    required this.onPressed,
  });

  final bool all;
  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: NButton(
      all ? 'Show fewer' : 'Show all $count',
      variant: ButtonVariant.secondary,
      onPressed: onPressed,
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
    child: Text(
      'No bills were issued in this period. A bill counts once payment is '
      'taken, or it is settled as due.',
      textAlign: TextAlign.center,
      style: N.caption(size: 16, height: 1.5),
    ),
  );
}
