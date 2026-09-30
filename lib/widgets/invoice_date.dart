import 'package:flutter/widgets.dart';

import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';

/// The bill's date, as a control: tap it to date the bill back to the day the
/// work was done.
class InvoiceDateButton extends StatelessWidget {
  const InvoiceDateButton({super.key, this.size = 14});

  final double size;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);

    return Semantics(
      button: true,
      label: 'Invoice date, ${model.invoiceDateLabel}. Change',
      excludeSemantics: true,
      child: Tappable(
        onTap: () => showInvoiceDateDialog(context),
        builder: (context, states, _) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: N.brSm,
            color: states.pressed
                ? N.a(0.14)
                : states.hovered
                ? N.a(0.07)
                : const Color(0x00000000),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                PhosphorIcons.calendarBlank,
                size: size + 2,
                color: N.accent,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  model.invoiceDateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: N.font(
                    size: size,
                    weight: FontWeight.w600,
                    color: N.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks which day the bill is for, then dates it.
Future<void> showInvoiceDateDialog(BuildContext context) {
  final model = BillingScope.read(context);
  return showNocturneDialog<void>(
    context: context,
    builder: (context) => _InvoiceDateDialog(model: model),
  );
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

class _InvoiceDateDialog extends StatefulWidget {
  const _InvoiceDateDialog({required this.model});

  final BillingModel model;

  @override
  State<_InvoiceDateDialog> createState() => _InvoiceDateDialogState();
}

class _InvoiceDateDialogState extends State<_InvoiceDateDialog> {
  late DateTime _picked = _dayOf(widget.model.invoiceDate);
  late DateTime _month = DateTime(_picked.year, _picked.month);

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Sunday first, the way the wall calendar in the workshop reads.
  static const _weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  void _pick(DateTime day) => setState(() {
    _picked = day;
    _month = DateTime(day.year, day.month);
  });

  void _shiftMonth(int by) =>
      setState(() => _month = DateTime(_month.year, _month.month + by));

  @override
  Widget build(BuildContext context) {
    final today = _today();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final atThisMonth =
        _month.year == today.year && _month.month == today.month;

    return NDialog(
      title: 'Invoice date',
      actions: [
        NButton(
          'Cancel',
          variant: ButtonVariant.secondary,
          height: 56,
          padding: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        NButton(
          'Use ${BillingModel.dateLabel(_picked)}',
          icon: PhosphorIcons.check,
          height: 56,
          fontSize: 17,
          padding: 20,
          onPressed: () {
            widget.model.updateInvoiceDate(_picked);
            Navigator.of(context).pop();
          },
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The two days most bills are for, one tap each. Any other day is
          // on the calendar below, and then neither of these is lit.
          NSegmented<DateTime?>(
            options: [today, yesterday],
            value: _picked,
            labelOf: (day) => day == today ? 'Today' : 'Yesterday',
            expand: true,
            onChanged: (day) => _pick(day!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButtonTarget(
                label: 'Previous month',
                icon: PhosphorIcon(PhosphorIcons.caretLeft, color: N.text),
                onPressed: () => _shiftMonth(-1),
              ),
              Expanded(
                child: Text(
                  '${_monthNames[_month.month - 1]} ${_month.year}',
                  textAlign: TextAlign.center,
                  style: N.font(size: 18, weight: FontWeight.w600),
                ),
              ),
              // The calendar stops at this month: nothing after today can be
              // chosen, so there is nowhere forward to go.
              Opacity(
                opacity: atThisMonth ? 0.3 : 1,
                child: IgnorePointer(
                  ignoring: atThisMonth,
                  child: IconButtonTarget(
                    label: 'Next month',
                    icon: PhosphorIcon(PhosphorIcons.caretRight, color: N.text),
                    onPressed: () => _shiftMonth(1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _MonthGrid(
            month: _month,
            picked: _picked,
            today: today,
            weekdays: _weekdays,
            onPick: _pick,
          ),
          const SizedBox(height: 12),
          Text(
            _picked == today
                ? 'The invoice is dated today.'
                : 'The invoice will be dated '
                      '${BillingModel.dateLabel(_picked)}, not today.',
            style: N.caption(size: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// One month, a week to a row. Days after today are shown but cannot be
/// chosen.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.picked,
    required this.today,
    required this.weekdays,
    required this.onPick,
  });

  final DateTime month;
  final DateTime picked;
  final DateTime today;
  final List<String> weekdays;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // DateTime.weekday runs Monday 1 … Sunday 7; the grid starts on Sunday.
    final lead = DateTime(month.year, month.month).weekday % 7;
    final cells = lead + daysInMonth;
    final rows = (cells / 7).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final name in weekdays)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: N.caption(size: 13),
                  ),
                ),
              ),
          ],
        ),
        for (var row = 0; row < rows; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: () {
                    final dayNumber = row * 7 + col - lead + 1;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox(height: 48);
                    }
                    final day = DateTime(month.year, month.month, dayNumber);
                    return _DayCell(
                      day: day,
                      selected: day == picked,
                      isToday: day == today,
                      enabled: !day.isAfter(today),
                      onTap: () => onPick(day),
                    );
                  }(),
                ),
            ],
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.enabled,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: enabled,
    selected: selected,
    enabled: enabled,
    label: BillingModel.dateLabel(day),
    excludeSemantics: true,
    child: Tappable(
      onTap: enabled ? onTap : null,
      builder: (context, states, _) => Container(
        height: 48,
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: N.brMd,
          color: selected
              ? N.accentFill
              : states.pressed
              ? N.a(0.14)
              : states.hovered
              ? N.a(0.07)
              : const Color(0x00000000),
          border: isToday && !selected
              ? Border.all(color: N.accent, width: 1.5)
              : null,
        ),
        child: Text(
          '${day.day}',
          style: N.font(
            size: 16,
            weight: selected || isToday ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? N.onAccent
                : enabled
                ? N.text
                : N.t(0.3),
          ),
        ),
      ),
    ),
  );
}
