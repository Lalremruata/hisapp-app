import 'package:flutter/widgets.dart';

import '../models/catalog.dart';
import '../models/money.dart';
import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';
import 'new_item_dialog.dart';

/// The autocomplete list that drops under the search box.
///
/// [detailed] is the tablet's three-line row (HSN, slab and stock); the phone
/// shows only the name and the rate.
///
/// [maxHeight] is the room left above the keyboard. What does not fit scrolls
/// rather than running on under the keyboard, and when there is too little
/// room for the detailed rows the list falls back to the short ones so more
/// of the matches show at once.
class SuggestionList extends StatelessWidget {
  const SuggestionList({super.key, required this.detailed, this.maxHeight});

  final bool detailed;
  final double? maxHeight;

  /// Below this, three detailed rows would not fit.
  static const _detailedMinHeight = 240.0;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);
    final limit = maxHeight;
    final showDetail =
        detailed && (limit == null || limit >= _detailedMinHeight);

    final rows = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in model.suggestions)
          _SuggestionRow(item: item, detailed: showDetail),
        // Nothing on the list matches, so the only thing to offer is
        // making it — which is the point at which the shopkeeper needs it.
        if (model.hasNoMatches) _CreateRow(query: model.query),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: limit ?? double.infinity),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: N.surface,
          borderRadius: N.brLg,
          border: Border.all(color: N.t(0.38), width: 1.5),
          boxShadow: N.shadowLg,
        ),
        child: ClipRRect(
          borderRadius: N.brLg,
          child: limit == null ? rows : SingleChildScrollView(child: rows),
        ),
      ),
    );
  }
}

/// The second line of a tablet suggestion. Labour is not stocked, and anything
/// typed in at the counter may have no code, so those parts are left out
/// rather than printed empty.
String _detailLine(CatalogItem item) {
  return [
    if (item.code.isNotEmpty) '${item.codeLabel} ${item.code}',
    'GST ${item.gst}%',
    if (item.stock case final stock?) 'in stock $stock',
  ].join(' · ');
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.item, required this.detailed});

  final CatalogItem item;
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.read(context);

    return Tappable(
      onTap: () {
        model.addToCart(item);
        showNToast(context, 'Added ${item.name}');
      },
      builder: (context, states, _) => Edged(
        bottom: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          color: states.pressed
              ? N.a(0.18)
              : states.hovered
              ? N.a(0.1)
              : const Color(0x00000000),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: N.font(size: 17, weight: FontWeight.w600),
                          ),
                        ),
                        if (item.kind == ItemKind.labour) ...[
                          const SizedBox(width: 8),
                          const NTag.info('Labour'),
                        ],
                      ],
                    ),
                    if (detailed)
                      Text(_detailLine(item), style: N.caption(size: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                money(item.rate),
                style: N.font(
                  size: 17,
                  weight: FontWeight.w600,
                  color: N.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The row that offers to create what was typed.
class _CreateRow extends StatelessWidget {
  const _CreateRow({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => createAndBill(context, prefillName: query),
      builder: (context, states, _) => Container(
        constraints: const BoxConstraints(minHeight: 60),
        color: states.pressed
            ? N.a(0.18)
            : states.hovered
            ? N.a(0.1)
            : const Color(0x00000000),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: N.accentFill,
                borderRadius: N.brMd,
              ),
              child: PhosphorIcon(
                PhosphorIcons.plus,
                size: 20,
                color: N.onAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add "${query.trim()}" as a new item',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: N.font(
                      size: 17,
                      weight: FontWeight.w600,
                      color: N.accent,
                    ),
                  ),
                  Text('not on your rate card', style: N.caption(size: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
