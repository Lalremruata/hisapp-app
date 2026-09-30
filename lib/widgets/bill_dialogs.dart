import 'package:flutter/widgets.dart';

import '../models/bill.dart';
import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';

/// Asks how the customer paid, then settles the bill.
///
/// Returns true when the bill was settled. "Due" settles it too — the work is
/// billed, the money is not in yet — and the bill stays on the outstanding
/// list until it is marked otherwise.
Future<bool> showPaymentDialog(BuildContext context) async {
  final model = BillingScope.read(context);
  final settled = await showNocturneDialog<bool>(
    context: context,
    builder: (context) => _PaymentForm(model: model),
  );
  return settled ?? false;
}

class _PaymentForm extends StatefulWidget {
  const _PaymentForm({required this.model});

  final BillingModel model;

  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  late PaymentMethod _method = widget.model.isPaid
      ? widget.model.payment ?? PaymentMethod.cash
      : PaymentMethod.cash;

  static const _icons = {
    PaymentMethod.cash: PhosphorIcons.money,
    PaymentMethod.upi: PhosphorIcons.deviceMobile,
    PaymentMethod.card: PhosphorIcons.creditCard,
    PaymentMethod.due: PhosphorIcons.clock,
  };

  @override
  Widget build(BuildContext context) {
    final due = _method == PaymentMethod.due;

    return NDialog(
      title: 'Take ${widget.model.totalLabel}',
      actions: [
        NButton(
          'Cancel',
          variant: ButtonVariant.secondary,
          height: 56,
          padding: 18,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        NButton(
          due ? 'Save as due' : 'Mark paid',
          variant: due ? ButtonVariant.primary : ButtonVariant.success,
          icon: due ? PhosphorIcons.clock : PhosphorIcons.check,
          height: 56,
          fontSize: 17,
          padding: 20,
          onPressed: () {
            widget.model.settleBill(_method);
            Navigator.of(context).pop(true);
          },
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('How was it paid?', style: N.label(size: 16)),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              final width = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final method in PaymentMethod.values)
                    SizedBox(
                      width: width,
                      child: _MethodTile(
                        label: method.label,
                        icon: _icons[method]!,
                        selected: method == _method,
                        onTap: () => setState(() => _method = method),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            due
                ? 'The bill is issued and stays on your unpaid list until the '
                      'money comes in.'
                : 'This prints on the invoice, against ${widget.model.invoiceNo}.',
            style: N.caption(size: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// One way of paying, as a big tile: picture, word, and a tick when chosen.
class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Tappable(
      onTap: onTap,
      builder: (context, states, _) {
        final ink = selected ? N.onAccent : N.text;
        return Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? N.accentFill
                : states.pressed
                ? N.a(0.14)
                : states.hovered
                ? N.a(0.07)
                : N.surface,
            borderRadius: N.brMd,
            border: Border.all(
              color: selected ? N.accentFill : N.t(0.38),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              PhosphorIcon(icon, size: 26, color: ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: N.font(size: 18, weight: FontWeight.w600, color: ink),
                ),
              ),
              if (selected)
                PhosphorIcon(PhosphorIcons.check, size: 20, color: ink),
            ],
          ),
        );
      },
    ),
  );
}

/// What opening an already-issued bill asks before letting it be changed.
enum ReopenChoice { view, edit }

/// Warns that a bill has already been given to the customer.
///
/// A workshop does correct genuine mistakes, so this does not block the edit —
/// it makes sure nobody changes an issued invoice without meaning to.
Future<ReopenChoice?> showReopenDialog(BuildContext context, SavedBill bill) {
  return showNocturneDialog<ReopenChoice>(
    context: context,
    builder: (context) => NDialog(
      title: '${bill.invoiceNo} · ${bill.status.label}',
      actions: [
        NButton(
          'Just view',
          variant: ButtonVariant.secondary,
          icon: PhosphorIcons.printer,
          height: 56,
          padding: 18,
          onPressed: () => Navigator.of(context).pop(ReopenChoice.view),
        ),
        NButton(
          'Edit it',
          icon: PhosphorIcons.pencil,
          height: 56,
          padding: 20,
          onPressed: () => Navigator.of(context).pop(ReopenChoice.edit),
        ),
      ],
      child: Text(
        'This bill was already given to the customer. Changing it now changes '
        'what prints next time, under the same number.',
        style: N.font(size: 16, color: N.t(0.85), height: 1.5),
      ),
    ),
  );
}

/// Confirms taking a bill out of the archive.
Future<bool> showDeleteBillDialog(BuildContext context, SavedBill bill) async {
  final removed = await showNocturneDialog<bool>(
    context: context,
    builder: (context) => NDialog(
      title: 'Delete ${bill.invoiceNo}?',
      actions: [
        NButton(
          'Keep it',
          variant: ButtonVariant.secondary,
          height: 56,
          padding: 18,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        NButton(
          'Delete',
          variant: ButtonVariant.danger,
          icon: PhosphorIcons.trash,
          height: 56,
          padding: 20,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
      child: Text(
        bill.isPaid
            ? 'It goes for good, and its number is not given out again. A bill '
                  'you have already handed over is usually better corrected '
                  'than deleted.'
            : 'It goes for good, and its number is not given out again.',
        style: N.font(size: 16, color: N.t(0.85), height: 1.5),
      ),
    ),
  );
  return removed ?? false;
}

/// How a bill stands — held, due, or paid and by what means — as a tag whose
/// colour and glyph both say it.
class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.isPaid, required this.payment});

  final bool isPaid;
  final PaymentMethod? payment;

  @override
  Widget build(BuildContext context) {
    if (!isPaid) return const NTag.neutral('Held');
    if (payment == PaymentMethod.due) return const NTag.warning('Due');
    return NTag.success('Paid · ${payment?.label ?? ''}'.trim());
  }
}

/// [StatusTag] for the bill on the counter.
class BillStatusTag extends StatelessWidget {
  const BillStatusTag({super.key, required this.model});

  final BillingModel model;

  @override
  Widget build(BuildContext context) =>
      StatusTag(isPaid: model.isPaid, payment: model.payment);
}
