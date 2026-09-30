import 'package:flutter/widgets.dart';

import '../models/catalog.dart';
import '../models/money.dart';
import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';
import '../widgets/bill_parts.dart';
import '../widgets/invoice_date.dart';
import '../widgets/line_actions.dart';
import '../widgets/new_item_dialog.dart';
import '../widgets/vehicle_panel.dart';

/// The same job as the search layout, reached by tapping a common job or part
/// and punching the quantity on a keypad. No small fields, no keyboard.
class TabletKeypadBilling extends StatelessWidget {
  const TabletKeypadBilling({
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopBar(
          onOpenSettings: onOpenSettings,
          onOpenRateCard: onOpenRateCard,
          onOpenBills: onOpenBills,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: _Composer()),
              SizedBox(
                width: 384,
                child: _BillPanel(onOpenInvoice: onOpenInvoice),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
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
      bottom: true,
      child: Container(
        color: N.panel,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Flexible(
              child: Text(
                model.settings.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: N.font(size: 18, weight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 20),
            const LabeledIconButton(
              icon: PhosphorIcons.receipt,
              label: 'Billing',
              selected: true,
              width: 80,
            ),
            const SizedBox(width: 6),
            LabeledIconButton(
              icon: PhosphorIcons.listBullets,
              label: 'Bills',
              width: 80,
              onPressed: onOpenBills,
            ),
            const SizedBox(width: 6),
            LabeledIconButton(
              icon: PhosphorIcons.cube,
              label: 'Parts',
              width: 80,
              onPressed: onOpenRateCard,
            ),
            const SizedBox(width: 6),
            LabeledIconButton(
              icon: PhosphorIcons.gear,
              label: 'Settings',
              width: 80,
              onPressed: onOpenSettings,
            ),
            const Spacer(),
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

class _Composer extends StatelessWidget {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Kicker('Common jobs & parts'),
              const SizedBox(width: 10),
              Flexible(
                child: Text('Tap one to choose it', style: N.caption(size: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _FavouriteChips(),
          const SizedBox(height: 16),
          const _DraftCard(),
        ],
      ),
    );
  }
}

class _FavouriteChips extends StatelessWidget {
  const _FavouriteChips();

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in favourites)
          _Chip(item: item, selected: item.name == model.draft.name),
        // This screen has no search box, so the way to something not on the
        // list has to live on the row itself.
        const _OtherItemChip(),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.item, required this.selected});

  final CatalogItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.read(context);

    return Semantics(
      selected: selected,
      button: true,
      child: Tappable(
        onTap: () => model.setDraft(item),
        builder: (context, states, _) => Container(
          constraints: const BoxConstraints(minWidth: 176, minHeight: 56),
          padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
          decoration: BoxDecoration(
            color: selected
                ? N.a(0.12)
                : states.pressed
                ? N.a(0.1)
                : N.surface,
            borderRadius: N.brMd,
            border: Border.all(
              color: selected || states.hovered ? N.accent : N.t(0.38),
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: N.font(size: 16, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: money(item.rate),
                          style: N.font(
                            size: 14,
                            weight: FontWeight.w600,
                            color: N.accent,
                          ),
                        ),
                        TextSpan(
                          text: ' · GST ${item.gst}%',
                          style: N.caption(size: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (selected) ...[
                const SizedBox(width: 10),
                PhosphorIcon(PhosphorIcons.check, size: 20, color: N.accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the new-item form and loads whatever it makes into the draft, ready
/// for the keypad to take a quantity.
class _OtherItemChip extends StatelessWidget {
  const _OtherItemChip();

  Future<void> _create(BuildContext context) async {
    final model = BillingScope.read(context);
    final item = await showNewItemDialog(
      context,
      confirmLabel: 'Use this item',
    );
    if (item != null) model.setDraft(item);
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => _create(context),
      builder: (context, states, _) => Container(
        constraints: const BoxConstraints(minWidth: 176, minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: states.pressed ? N.a(0.14) : N.a(0.06),
          borderRadius: N.brMd,
          border: Border.all(color: N.accent, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+ Other item',
              style: N.font(size: 16, weight: FontWeight.w600, color: N.accent),
            ),
            const SizedBox(height: 2),
            Text('Not on the rate card', style: N.caption(size: 14)),
          ],
        ),
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard();

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: N.panel,
        borderRadius: N.brLg,
        border: Border.all(color: N.line, width: 1.5),
        boxShadow: N.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Kicker('Now adding'),
                    const SizedBox(height: 2),
                    Text(
                      model.draft.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: N.font(size: 22, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              NButton(
                'Add ${money(model.draftTotal)}',
                height: 60,
                fontSize: 18,
                padding: 24,
                icon: PhosphorIcons.plus,
                onPressed: () {
                  final name = model.draft.name;
                  model.addDraft();
                  showNToast(context, 'Added $name');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DraftBox(
                  label: 'Quantity',
                  value: model.qtyText.isEmpty ? '0' : model.qtyText,
                  focused: model.target == KeypadTarget.quantity,
                  onTap: () => model.setTarget(KeypadTarget.quantity),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DraftBox(
                  label: 'Rate each (₹)',
                  value: model.rateText.isEmpty ? '0' : model.rateText,
                  focused: model.target == KeypadTarget.rate,
                  onTap: () => model.setTarget(KeypadTarget.rate),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DraftBox(
                  label: 'GST (automatic)',
                  value: '${model.draft.gst}%',
                  valueColor: N.t(0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _Keypad(),
        ],
      ),
    );
  }
}

class _DraftBox extends StatelessWidget {
  const _DraftBox({
    required this.label,
    required this.value,
    this.focused = false,
    this.onTap,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool focused;
  final VoidCallback? onTap;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: focused,
    button: onTap != null,
    child: Tappable(
      onTap: onTap,
      builder: (context, states, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: focused ? N.a(0.08) : N.surface,
          borderRadius: N.brMd,
          // The box the keypad types into takes a heavy accent ring; the
          // others keep a plain edge.
          border: Border.all(
            color: focused ? N.accent : N.line,
            width: focused ? 3 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: N.label(color: focused ? N.accent : N.t(0.8))),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: N.font(
                size: 30,
                weight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Keypad extends StatelessWidget {
  const _Keypad();

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.read(context);
    const keys = BillingModel.keypadKeys;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        const columns = 4;
        const keyHeight = 58.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final key in keys)
              SizedBox(
                width: width,
                height: keyHeight,
                child: _Key(label: key, onPressed: () => model.pressKey(key)),
              ),
          ],
        );
      },
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  /// Clear and backspace take something away, so they look it: amber, apart
  /// from the digits.
  bool get _erases => label == 'C' || label == BillingModel.backspaceKey;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label == BillingModel.backspaceKey
        ? 'Backspace'
        : label == 'C'
        ? 'Clear'
        : null,
    child: Tappable(
      onTap: onPressed,
      builder: (context, states, _) {
        final ink = _erases ? N.warningInk : N.text;
        return AnimatedScale(
          scale: states.pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 80),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: states.pressed
                  ? (_erases ? N.warning.withValues(alpha: 0.3) : N.a(0.2))
                  : _erases
                  ? N.warningSoft
                  : states.hovered
                  ? N.a(0.06)
                  : N.surface,
              borderRadius: N.brMd,
              border: Border.all(
                color: _erases ? N.warningSoft : N.t(0.3),
                width: 1.5,
              ),
            ),
            child: label == BillingModel.backspaceKey
                ? BackspaceGlyph(size: 30, color: ink)
                : Text(
                    label,
                    textScaler: TextScaler.noScaling,
                    style: N.font(
                      size: 28,
                      weight: FontWeight.w600,
                      color: ink,
                    ),
                  ),
          ),
        );
      },
    ),
  );
}

class _BillPanel extends StatelessWidget {
  const _BillPanel({required this.onOpenInvoice});

  final VoidCallback onOpenInvoice;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);
    final lines = model.lines;

    return Edged(
      left: true,
      child: Container(
        color: N.panel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // This layout has no vehicle panel, so the bill panel has to say
            // which car is being charged — and let it be set.
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: VehicleSummaryRow(),
            ),
            Edged(
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Kicker('Bill'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${model.lineCount} items',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: N.caption(size: 14),
                      ),
                    ),
                    const Flexible(child: InvoiceDateButton()),
                  ],
                ),
              ),
            ),
            Expanded(
              child: lines.isEmpty
                  ? const EmptyBillHint('Tap a job or part, then Add.')
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: lines.length,
                      itemBuilder: (context, i) => _CompactLine(line: lines[i]),
                    ),
            ),
            Edged(
              top: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SummaryRow('Taxable', model.taxableLabel, size: 15),
                    SummaryRow('CGST + SGST', model.gstTotalLabel, size: 15),
                    TotalPayable(model: model, size: 34),
                    const SizedBox(height: 12),
                    TakePaymentButton(onOpenInvoice: onOpenInvoice),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactLine extends StatelessWidget {
  const _CompactLine({required this.line});

  final BillLine line;

  @override
  Widget build(BuildContext context) {
    return Edged(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    line.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: N.font(size: 16, weight: FontWeight.w600),
                  ),
                  Text(
                    '${line.qty} × ${line.rateLabel} · GST ${line.gstLabel}',
                    style: N.caption(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              line.amountLabel,
              style: N.font(size: 16, weight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            StepButton(
              label: '×',
              quiet: true,
              size: 44,
              fontSize: 22,
              semanticLabel: 'Remove ${line.name}',
              onPressed: () => removeLine(context, line.index),
            ),
          ],
        ),
      ),
    );
  }
}
