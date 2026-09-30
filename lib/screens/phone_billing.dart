import 'package:flutter/widgets.dart';

import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';
import '../widgets/added_line.dart';
import '../widgets/bill_parts.dart';
import '../widgets/invoice_date.dart';
import '../widgets/keyboard_scope.dart';
import '../widgets/line_actions.dart';
import '../widgets/new_item_dialog.dart';
import '../widgets/suggestions.dart';
import '../widgets/vehicle_panel.dart';

/// One-thumb billing on a phone: the same job, big numbers, and the charge
/// button always within reach at the bottom.
class PhoneBilling extends StatefulWidget {
  const PhoneBilling({
    super.key,
    required this.onOpenSettings,
    required this.onOpenRateCard,
    required this.onOpenBills,
    required this.onOpenInvoice,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenRateCard;
  final VoidCallback onOpenBills;
  final VoidCallback onOpenInvoice;

  @override
  State<PhoneBilling> createState() => _PhoneBillingState();
}

class _PhoneBillingState extends State<PhoneBilling> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);
    if (_search.text != model.query) _search.text = model.query;
    final lines = model.lines;

    // With the keyboard up the phone keeps only what typing needs: the box,
    // the lines it adds to and what they come to.
    final typing = KeyboardScope.isOpen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      model.isSaved ? 'Bill' : 'New bill',
                      style: N.font(size: 24, weight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${model.invoiceNo} ·',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: N.caption(size: 14),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Flexible(child: InvoiceDateButton()),
                      ],
                    ),
                  ],
                ),
              ),
              LabeledIconButton(
                label: 'Bills',
                icon: PhosphorIcons.listBullets,
                width: 64,
                onPressed: widget.onOpenBills,
              ),
              LabeledIconButton(
                label: 'Parts',
                icon: PhosphorIcons.cube,
                width: 64,
                onPressed: widget.onOpenRateCard,
              ),
              LabeledIconButton(
                label: 'Settings',
                icon: PhosphorIcons.gear,
                width: 64,
                onPressed: widget.onOpenSettings,
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: typing
              ? const SizedBox.shrink()
              : const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: VehicleSummaryRow(),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: NInput(
            key: const ValueKey('search-field'),
            controller: _search,
            placeholder: 'Search a part or a job',
            height: 56,
            fontSize: 18,
            horizontalPadding: 14,
            // One item after another without the keyboard dropping.
            keepFocusOnSubmit: true,
            onChanged: model.updateQuery,
            onSubmitted: (_) => addOrCreate(context),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Kicker('On this bill'),
                            const SizedBox(width: 10),
                            Text(
                              '${model.lineCount} items',
                              style: N.caption(size: 14),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: AddedLineScroller(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          empty: const EmptyBillHint(
                            'Search above to add a part or a job.',
                          ),
                          children: [
                            for (final line in lines) _PhoneLine(line: line),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Floats over the bill rather than pushing it down, and stops
                // short of the keyboard, scrolling whatever does not fit.
                if (model.showSuggestions)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 0,
                    child: SuggestionList(
                      detailed: false,
                      maxHeight: (constraints.maxHeight - 8).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _ChargeBar(onOpenInvoice: widget.onOpenInvoice, compact: typing),
      ],
    );
  }
}

/// One line on two rows: what it is and what it costs on top, the rate and
/// the buttons that change it underneath — nothing squeezed to fit a phone.
class _PhoneLine extends StatelessWidget {
  const _PhoneLine({required this.line});

  final BillLine line;

  @override
  Widget build(BuildContext context) {
    return AddedLineMark(index: line.index, child: _row(context));
  }

  Widget _row(BuildContext context) {
    return Edged(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    line.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: N.font(size: 17, weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  line.amountLabel,
                  style: N.font(size: 17, weight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${line.rateLabel} each\nGST ${line.gstLabel}',
                    style: N.caption(size: 14, height: 1.35),
                  ),
                ),
                StepButton(
                  label: '−',
                  semanticLabel: 'One fewer ${line.name}',
                  onPressed: () => bumpLine(context, line.index, -1),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${line.qty}',
                    textAlign: TextAlign.center,
                    style: N.font(size: 19, weight: FontWeight.w600),
                  ),
                ),
                StepButton(
                  label: '+',
                  semanticLabel: 'One more ${line.name}',
                  onPressed: () => bumpLine(context, line.index, 1),
                ),
                const SizedBox(width: 12),
                StepButton(
                  label: '×',
                  quiet: true,
                  semanticLabel: 'Remove ${line.name}',
                  onPressed: () => removeLine(context, line.index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChargeBar extends StatelessWidget {
  const _ChargeBar({required this.onOpenInvoice, required this.compact});

  final VoidCallback onOpenInvoice;

  /// The keyboard is up: only the total stays, on one slim row. Charging
  /// comes back with the rest of the bar once the keyboard goes down.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);

    if (compact) {
      return Edged(
        top: true,
        child: Container(
          color: N.panel,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text('Total', style: N.font(size: 16, color: N.t(0.75))),
              ),
              Text(
                model.totalLabel,
                style: N.font(size: 20, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Edged(
      top: true,
      child: Container(
        color: N.panel,
        padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SummaryRow('Taxable', model.taxableLabel, size: 15),
            SummaryRow('CGST + SGST (auto)', model.gstTotalLabel, size: 15),
            const SizedBox(height: 2),
            TakePaymentButton(
              onOpenInvoice: onOpenInvoice,
              label: 'Charge ${model.totalLabel}',
            ),
            if (model.isPaid) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: NButton(
                      'Print',
                      variant: ButtonVariant.secondary,
                      icon: PhosphorIcons.printer,
                      height: 52,
                      onPressed: onOpenInvoice,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NButton(
                      'Next bill',
                      variant: ButtonVariant.secondary,
                      icon: PhosphorIcons.plus,
                      height: 52,
                      onPressed: model.newBill,
                    ),
                  ),
                ],
              ),
            ] else if (model.settings.worksOffline) ...[
              const SizedBox(height: 8),
              Text(
                'Bill saves on the phone — syncs when internet returns',
                textAlign: TextAlign.center,
                style: N.caption(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
