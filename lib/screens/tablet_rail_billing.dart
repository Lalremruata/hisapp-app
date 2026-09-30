import 'package:flutter/widgets.dart';

import '../state/billing_model.dart';
import '../theme/components.dart';
import '../models/money.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';
import '../widgets/added_line.dart';
import '../widgets/bill_dialogs.dart';
import '../widgets/bill_parts.dart';
import '../widgets/invoice_date.dart';
import '../widgets/keyboard_scope.dart';
import '../widgets/line_actions.dart';
import '../widgets/new_item_dialog.dart';
import '../widgets/suggestions.dart';
import '../widgets/vehicle_panel.dart';

/// Tablet billing: a labelled rail, the vehicle on the ramp, a type-to-add
/// search box over the rate card, and the GST split worked out on the right as
/// the job grows.
class TabletRailBilling extends StatefulWidget {
  const TabletRailBilling({
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
  State<TabletRailBilling> createState() => _TabletRailBillingState();
}

class _TabletRailBillingState extends State<TabletRailBilling> {
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

    // With the keyboard up there is room for little more than the search box
    // and a few lines, so the vehicle folds away until it goes down again.
    final typing = KeyboardScope.isOpen(context);

    return Row(
      children: [
        _IconRail(
          onOpenSettings: widget.onOpenSettings,
          onOpenRateCard: widget.onOpenRateCard,
          onOpenBills: widget.onOpenBills,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(model: model),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: typing
                    ? const SizedBox.shrink()
                    : const Padding(
                        padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: VehicleSummaryRow(),
                      ),
              ),
              _SearchRow(controller: _search, model: model, compact: typing),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      Positioned.fill(
                        child: _Body(
                          onOpenInvoice: widget.onOpenInvoice,
                          compact: typing,
                        ),
                      ),
                      // The dropdown floats over the bill rather than pushing
                      // it down, so the line the shopkeeper just added stays
                      // put — and stops short of the keyboard, scrolling
                      // whatever does not fit.
                      if (model.showSuggestions)
                        Positioned(
                          left: 24,
                          right: 24,
                          top: 8,
                          child: SuggestionList(
                            detailed: true,
                            maxHeight: (constraints.maxHeight - 16).clamp(
                              0,
                              double.infinity,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconRail extends StatelessWidget {
  const _IconRail({
    required this.onOpenSettings,
    required this.onOpenRateCard,
    required this.onOpenBills,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenRateCard;
  final VoidCallback onOpenBills;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);

    return Edged(
      right: true,
      child: Container(
        width: 92,
        color: N.panel,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: N.accentFill,
                borderRadius: N.brMd,
              ),
              child: Text(
                _initials(model.settings.name),
                textScaler: TextScaler.noScaling,
                style: N.font(
                  size: 18,
                  weight: FontWeight.w600,
                  color: N.onAccent,
                ),
              ),
            ),
            const LabeledIconButton(
              icon: PhosphorIcons.receipt,
              label: 'Billing',
              selected: true,
            ),
            const SizedBox(height: 8),
            LabeledIconButton(
              icon: PhosphorIcons.listBullets,
              label: 'Bills',
              onPressed: onOpenBills,
            ),
            const SizedBox(height: 8),
            LabeledIconButton(
              icon: PhosphorIcons.cube,
              label: 'Parts',
              onPressed: onOpenRateCard,
            ),
            const Spacer(),
            LabeledIconButton(
              icon: PhosphorIcons.gear,
              label: 'Settings',
              onPressed: onOpenSettings,
            ),
          ],
        ),
      ),
    );
  }

  /// The workshop's monogram: the first letters of its first two words.
  static String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2);
    final letters = words.map((word) => word[0].toUpperCase()).join();
    return letters.isEmpty ? '₹' : letters;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.model});

  final BillingModel model;

  @override
  Widget build(BuildContext context) {
    return Edged(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          model.isSaved
                              ? 'Bill ${model.invoiceNo}'
                              : 'New bill',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: N.font(size: 22, weight: FontWeight.w600),
                        ),
                      ),
                      if (model.isSaved) ...[
                        const SizedBox(width: 10),
                        BillStatusTag(model: model),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Invoice ${model.invoiceNo} ·',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: N.caption(size: 14),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const InvoiceDateButton(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (model.settings.worksOffline) ...[
              const OfflineTag(),
              const SizedBox(width: 14),
            ],
            NButton(
              'Hold bill',
              variant: ButtonVariant.secondary,
              icon: PhosphorIcons.pause,
              onPressed: model.lines.isEmpty ? null : () => holdBill(context),
            ),
            const SizedBox(width: 10),
            NButton(
              'New bill',
              variant: ButtonVariant.secondary,
              icon: PhosphorIcons.plus,
              onPressed: model.newBill,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.model,
    required this.compact,
  });

  final TextEditingController controller;
  final BillingModel model;

  /// The keyboard is up: the label goes, since the box is already in use.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, compact ? 10 : 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Text('Add a part or a job', style: N.label(size: 15)),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: NInput(
                  key: const ValueKey('search-field'),
                  controller: controller,
                  placeholder: 'Type a name, e.g. oil filter',
                  height: 60,
                  fontSize: 18,
                  horizontalPadding: 16,
                  // One item after another without the keyboard dropping.
                  keepFocusOnSubmit: true,
                  onChanged: model.updateQuery,
                  onSubmitted: (_) => addOrCreate(context),
                ),
              ),
              const SizedBox(width: 12),
              NButton(
                'Add to bill',
                height: 60,
                fontSize: 17,
                padding: 24,
                icon: PhosphorIcons.plus,
                onPressed: () => addOrCreate(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.onOpenInvoice, required this.compact});

  final VoidCallback onOpenInvoice;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        compact ? 10 : 16,
        24,
        compact ? 12 : 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(child: _LineTable()),
          const SizedBox(width: 20),
          SizedBox(
            width: 340,
            child: _BillSummary(onOpenInvoice: onOpenInvoice, compact: compact),
          ),
        ],
      ),
    );
  }
}

/// The table's column widths: the item takes what is left, and its rate and
/// GST ride under its name rather than in columns of their own.
const _columns = <double?>[null, 156, 124, 48];
const _columnGap = 12.0;

class _LineTable extends StatelessWidget {
  const _LineTable();

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);
    final rows = <Widget>[
      // Parts fitted, then work done — the order a workshop invoice reads in.
      if (model.partLines.isNotEmpty) ...[
        const _SectionRow('Parts fitted'),
        for (final line in model.partLines) _LineRow(line: line),
      ],
      if (model.labourLines.isNotEmpty) ...[
        const _SectionRow('Work done'),
        for (final line in model.labourLines) _LineRow(line: line),
      ],
    ];

    return Container(
      decoration: BoxDecoration(
        color: N.panel,
        borderRadius: N.brLg,
        border: Border.all(color: N.line, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TableHead(),
          Expanded(
            child: AddedLineScroller(
              empty: const EmptyBillHint(
                'Type a part or a job above to add it.',
              ),
              children: rows,
            ),
          ),
          Edged(
            top: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                '${model.lineCount} items on this bill',
                style: N.caption(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHead extends StatelessWidget {
  const _TableHead();

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, TextAlign align) => Text(
      label,
      textAlign: align,
      style: N.label(color: N.t(0.75)),
    );

    return Edged(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _GridRow(
          children: [
            cell('Item', TextAlign.left),
            cell('Quantity', TextAlign.center),
            cell('Amount', TextAlign.right),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

/// A band naming the group of lines under it.
class _SectionRow extends StatelessWidget {
  const _SectionRow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Edged(
    bottom: true,
    child: Container(
      width: double.infinity,
      color: N.highlight.withValues(alpha: 0.08),
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
      child: Kicker(label),
    ),
  );
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});

  final BillLine line;

  @override
  Widget build(BuildContext context) {
    return AddedLineMark(index: line.index, child: _row(context));
  }

  Widget _row(BuildContext context) {
    return Edged(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _GridRow(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: N.font(size: 17, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    '${line.rateLabel} each',
                    'GST ${line.gstLabel}',
                    if (line.code.isNotEmpty) '${line.codeLabel} ${line.code}',
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: N.caption(),
                ),
              ],
            ),
            Row(
              children: [
                StepButton(
                  label: '−',
                  semanticLabel: 'One fewer ${line.name}',
                  onPressed: () => bumpLine(context, line.index, -1),
                ),
                Expanded(
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
              ],
            ),
            Text(
              line.amountLabel,
              textAlign: TextAlign.right,
              style: N.font(size: 17, weight: FontWeight.w600),
            ),
            StepButton(
              label: '×',
              quiet: true,
              semanticLabel: 'Remove ${line.name}',
              onPressed: () => removeLine(context, line.index),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lays children out on the table's grid.
class _GridRow extends StatelessWidget {
  const _GridRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(width: _columnGap),
        if (_columns[i] == null)
          Expanded(child: children[i])
        else
          SizedBox(width: _columns[i], child: children[i]),
      ],
    ],
  );
}

class _BillSummary extends StatelessWidget {
  const _BillSummary({required this.onOpenInvoice, required this.compact});

  final VoidCallback onOpenInvoice;

  /// The keyboard is up and the panel is short: printing can wait.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: N.surface,
        borderRadius: N.brLg,
        border: Border.all(color: N.line, width: 1.5),
        boxShadow: N.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Kicker('Bill summary'),
          const SizedBox(height: 14),
          // The figures give way before the two actions do: on a short tablet
          // the shopkeeper must still be able to reach "Take payment".
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (model.partLines.isNotEmpty)
                    SummaryRow('Parts', money(model.partsTotal)),
                  if (model.labourLines.isNotEmpty)
                    SummaryRow('Labour', money(model.labourTotal)),
                  SummaryRow('Taxable value', model.taxableLabel),
                  SummaryRow('CGST', model.cgstLabel),
                  SummaryRow('SGST', model.sgstLabel),
                  SummaryRow('Round off', model.roundLabel),
                  const SizedBox(height: 2),
                  Container(height: 1.5, color: N.line),
                  const SizedBox(height: 12),
                  TotalPayable(model: model, size: 38),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TakePaymentButton(onOpenInvoice: onOpenInvoice),
          if (!compact) ...[
            const SizedBox(height: 10),
            NButton(
              'Print invoice',
              variant: ButtonVariant.secondary,
              height: 52,
              fontSize: 17,
              icon: PhosphorIcons.printer,
              expand: true,
              onPressed: model.lines.isEmpty
                  ? null
                  : () {
                      // Printing saves first: an invoice handed to a customer
                      // must exist on the list it was printed from.
                      model.saveBill();
                      onOpenInvoice();
                    },
            ),
          ],
        ],
      ),
    );
  }
}
