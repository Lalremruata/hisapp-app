import 'package:flutter/widgets.dart';

import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';
import 'bill_dialogs.dart';

/// The pieces every billing layout shares: the way to take payment, the
/// total, and the small signals around them. One of each, so the tablet and
/// the phone never disagree about what the main action looks like.

/// The main action on a bill: solid green, because it is money coming in.
///
/// Once the bill is settled it says how, and still opens the payment dialog so
/// a wrong choice can be put right.
class TakePaymentButton extends StatelessWidget {
  const TakePaymentButton({super.key, required this.onOpenInvoice, this.label});

  final VoidCallback onOpenInvoice;

  /// What the button says before the bill is paid. The phone puts the total
  /// in it; the tablets have the total written large right above.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);

    return NButton(
      model.isPaid
          ? 'Paid · ${model.payment?.label ?? ''}'
          : label ?? 'Take payment',
      variant: ButtonVariant.success,
      icon: model.isPaid ? PhosphorIcons.check : PhosphorIcons.money,
      height: 64,
      fontSize: 20,
      expand: true,
      onPressed: model.lines.isEmpty
          ? null
          : () async {
              if (await showPaymentDialog(context) && context.mounted) {
                onOpenInvoice();
              }
            },
    );
  }
}

/// "Total payable" over the figure, the largest number on the screen.
class TotalPayable extends StatelessWidget {
  const TotalPayable({super.key, required this.model, this.size = 36});

  final BillingModel model;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text('Total', style: N.label(size: 17, color: N.text)),
      const SizedBox(width: 12),
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              model.totalLabel,
              maxLines: 1,
              style: N.font(
                size: size,
                weight: FontWeight.w600,
                letterSpacing: -0.01 * size,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

/// One figure of the GST split: its name on the left, its amount on the right.
class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key, this.size = 16});

  final String label;
  final String value;
  final double size;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: N.font(size: size, color: N.t(0.75)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: N.font(size: size, weight: FontWeight.w500),
        ),
      ],
    ),
  );
}

/// Says that bills are being kept on this device while there is no internet.
class OfflineTag extends StatelessWidget {
  const OfflineTag({super.key});

  @override
  Widget build(BuildContext context) =>
      const NTag.info('Works offline', icon: PhosphorIcons.check);
}

/// What an empty bill shows where its lines would be.
class EmptyBillHint extends StatelessWidget {
  const EmptyBillHint(this.how, {super.key});

  /// How to add the first line, on this layout.
  final String how;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Nothing on this bill yet.\n$how',
        textAlign: TextAlign.center,
        style: N.caption(size: 16, height: 1.5),
      ),
    ),
  );
}

/// Parks the bill on the counter and says where it went.
void holdBill(BuildContext context) {
  final model = BillingScope.read(context);
  final number = model.invoiceNo;
  model.holdBill();
  showNToast(context, 'Bill $number is held. Find it under Bills.');
}
