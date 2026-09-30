import 'package:flutter/widgets.dart';

import '../models/bill.dart';
import '../models/money.dart';
import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';
import '../widgets/bill_dialogs.dart';

/// Every bill the workshop has saved: what is still owed, and everything
/// already settled — to reopen, correct or print again.
class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key, required this.onPrint});

  /// Opens the printed invoice for whatever is on the counter.
  final VoidCallback onPrint;

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final _filter = TextEditingController();
  String _query = '';
  bool _outstandingOnly = false;

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  bool _matches(SavedBill bill) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return bill.invoiceNo.toLowerCase().contains(q) ||
        bill.vehicle.registration.toLowerCase().contains(q) ||
        bill.vehicle.makeModel.toLowerCase().contains(q) ||
        bill.vehicle.customerName.toLowerCase().contains(q);
  }

  /// Puts a bill back on the counter, asking first if it has already been
  /// issued, and prints it when that is all that was wanted.
  Future<void> _open(SavedBill bill) async {
    final model = BillingScope.read(context);

    if (bill.isPaid) {
      final choice = await showReopenDialog(context, bill);
      if (choice == null || !mounted) return;
      model.openBill(bill);
      if (!mounted) return;
      Navigator.of(context).pop();
      if (choice == ReopenChoice.view) widget.onPrint();
      return;
    }

    model.openBill(bill);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _print(SavedBill bill) async {
    BillingScope.read(context).openBill(bill);
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onPrint();
  }

  Future<void> _delete(SavedBill bill) async {
    final confirmed = await showDeleteBillDialog(context, bill);
    if (!confirmed || !mounted) return;
    BillingScope.read(context).deleteBill(bill);
  }

  @override
  Widget build(BuildContext context) {
    N.watch(context);
    final model = BillingScope.of(context);
    final inset = MediaQuery.paddingOf(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final gutter = wide ? 24.0 : 20.0;

    final source = _outstandingOnly ? model.outstandingBills : model.bills;
    final bills = [
      for (final bill in source)
        if (_matches(bill)) bill,
    ];

    return ColoredBox(
      color: N.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(model: model),
            Padding(
              padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 12),
              child: Row(
                children: [
                  Expanded(
                    child: NInput(
                      key: const ValueKey('bills-filter'),
                      controller: _filter,
                      height: 52,
                      fontSize: 17,
                      horizontalPadding: 14,
                      placeholder: 'Search by bill no., vehicle or customer',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  NSegmented<bool>(
                    options: const [false, true],
                    value: _outstandingOnly,
                    labelOf: (only) => only ? 'Unpaid' : 'All',
                    onChanged: (only) =>
                        setState(() => _outstandingOnly = only),
                  ),
                ],
              ),
            ),
            Expanded(
              child: bills.isEmpty
                  ? _Empty(
                      query: _query,
                      outstandingOnly: _outstandingOnly,
                      anySaved: model.bills.isNotEmpty,
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        gutter,
                        0,
                        gutter,
                        24 + inset.bottom,
                      ),
                      itemCount: bills.length,
                      itemBuilder: (context, i) => _BillRow(
                        bill: bills[i],
                        wide: wide,
                        current:
                            model.isSaved &&
                            bills[i].invoiceNo == model.invoiceNo,
                        onOpen: () => _open(bills[i]),
                        onPrint: () => _print(bills[i]),
                        onDelete: () => _delete(bills[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.model});

  final BillingModel model;

  @override
  Widget build(BuildContext context) {
    final outstanding = model.outstandingBills;
    final owed = outstanding.fold<double>(
      0,
      (sum, bill) => sum + model.totalOf(bill),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 16),
      child: Row(
        children: [
          const BackButtonN(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Saved bills',
                  style: N.font(size: 24, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (model.bills.isEmpty)
                  Text('Nothing saved yet', style: N.caption(size: 14))
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${model.bills.length} saved',
                        style: N.caption(size: 14),
                      ),
                      if (outstanding.isNotEmpty)
                        NTag.warning(
                          '${outstanding.length} unpaid · ${money(owed)} owed',
                        )
                      else
                        const NTag.success('All paid'),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.bill,
    required this.wide,
    required this.current,
    required this.onOpen,
    required this.onPrint,
    required this.onDelete,
  });

  final SavedBill bill;
  final bool wide;
  final bool current;
  final VoidCallback onOpen;
  final VoidCallback onPrint;
  final VoidCallback onDelete;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get _date =>
      '${bill.date.day} ${_months[bill.date.month - 1]} ${bill.date.year}';

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);
    final vehicle = bill.vehicle;
    final pieces = bill.lines.fold<int>(0, (sum, line) => sum + line.qty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        child: Tappable(
          onTap: onOpen,
          builder: (context, states, _) => Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: current ? N.a(0.06) : N.panel,
              borderRadius: N.brLg,
              border: Border.all(
                color: current || states.hovered ? N.accent : N.line,
                width: current ? 2.5 : 1.5,
              ),
            ),
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
                            bill.invoiceNo,
                            style: N.font(size: 17, weight: FontWeight.w600),
                          ),
                          StatusTag(isPaid: bill.isPaid, payment: bill.payment),
                          if (current)
                            const NTag.info(
                              'On the counter',
                              icon: PhosphorIcons.receipt,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (vehicle.registration.trim().isNotEmpty)
                            vehicle.registration.trim().toUpperCase(),
                          if (vehicle.customerName.trim().isNotEmpty)
                            vehicle.customerName.trim(),
                          '$_date · $pieces items',
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
                  rupees(model.totalOf(bill)),
                  style: N.font(size: 18, weight: FontWeight.w600),
                ),
                if (wide) ...[
                  const SizedBox(width: 16),
                  NButton(
                    'Print',
                    variant: ButtonVariant.secondary,
                    icon: PhosphorIcons.printer,
                    onPressed: onPrint,
                  ),
                  const SizedBox(width: 8),
                  NButton(
                    'Delete',
                    variant: ButtonVariant.dangerQuiet,
                    icon: PhosphorIcons.trash,
                    onPressed: onDelete,
                  ),
                ] else ...[
                  const SizedBox(width: 10),
                  NButton(
                    'Print',
                    variant: ButtonVariant.secondary,
                    padding: 12,
                    onPressed: onPrint,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.query,
    required this.outstandingOnly,
    required this.anySaved,
  });

  final String query;
  final bool outstandingOnly;
  final bool anySaved;

  @override
  Widget build(BuildContext context) {
    final String message;
    if (query.trim().isNotEmpty) {
      message = 'No saved bill matches “${query.trim()}”.';
    } else if (outstandingOnly) {
      message = anySaved
          ? 'Nothing is unpaid. Every saved bill has been settled.'
          : 'Nothing saved yet.';
    } else {
      message =
          'Nothing saved yet. Hold a bill to park it, or take payment to '
          'issue it — either way it turns up here.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: N.caption(size: 16, height: 1.5),
      ),
    );
  }
}
