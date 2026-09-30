import 'package:flutter/widgets.dart';

import '../models/catalog.dart';
import '../models/money.dart';
import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';
import '../widgets/new_item_dialog.dart';

/// Everything the workshop can put on a bill, and the one place to change it.
///
/// Parts and jobs are listed apart, as they are billed. Anything here can be
/// repriced or taken off; a shipped item that has been changed can be put back
/// the way it came.
class RateCardScreen extends StatefulWidget {
  const RateCardScreen({super.key});

  @override
  State<RateCardScreen> createState() => _RateCardScreenState();
}

class _RateCardScreenState extends State<RateCardScreen> {
  final _filter = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  bool _matches(CatalogItem item) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return item.name.toLowerCase().contains(q) ||
        item.code.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    N.watch(context);
    final model = BillingScope.of(context);
    final inset = MediaQuery.paddingOf(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final parts = [
      for (final item in model.items)
        if (item.kind == ItemKind.part && _matches(item)) item,
    ];
    final labour = [
      for (final item in model.items)
        if (item.kind == ItemKind.labour && _matches(item)) item,
    ];
    final removed = [
      for (final item in model.removedItems)
        if (_matches(item)) item,
    ];

    return ColoredBox(
      color: N.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onNew: () => showNewItemDialog(context)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                wide ? 24 : 20,
                0,
                wide ? 24 : 20,
                14,
              ),
              child: NInput(
                key: const ValueKey('rate-card-filter'),
                controller: _filter,
                height: 52,
                fontSize: 17,
                horizontalPadding: 14,
                placeholder: 'Search parts and jobs',
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  wide ? 24 : 20,
                  0,
                  wide ? 24 : 20,
                  24 + inset.bottom,
                ),
                children: [
                  if (parts.isEmpty && labour.isEmpty && removed.isEmpty)
                    _Empty(query: _query),
                  if (parts.isNotEmpty) ...[
                    _SectionHead('Parts', count: parts.length),
                    for (final item in parts) _ItemRow(item: item),
                    const SizedBox(height: 22),
                  ],
                  if (labour.isNotEmpty) ...[
                    _SectionHead('Jobs', count: labour.length),
                    for (final item in labour) _ItemRow(item: item),
                    const SizedBox(height: 22),
                  ],
                  if (removed.isNotEmpty) ...[
                    _SectionHead('Removed', count: removed.length),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'These came with the app and you took them off. '
                        'Putting one back restores the price it shipped with.',
                        style: N.caption(size: 14, height: 1.4),
                      ),
                    ),
                    for (final item in removed) _RemovedRow(item: item),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onNew});

  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 10,
            children: [
              const BackButtonN(),
              NButton(
                'New item',
                icon: PhosphorIcons.plus,
                padding: 18,
                onPressed: onNew,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Rate card', style: N.font(size: 24, weight: FontWeight.w600)),
          Text(
            '${model.items.length} parts and jobs · '
            'tap one to change its price',
            style: N.caption(size: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SectionHead extends StatelessWidget {
  const _SectionHead(this.label, {required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Kicker('$label · $count'),
  );
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);
    final detail = [
      if (item.code.isNotEmpty) '${item.codeLabel} ${item.code}',
      'GST ${item.gst}%',
      if (item.stock case final stock?) 'in stock $stock',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Tappable(
        onTap: () => showItemEditor(context, item),
        builder: (context, states, _) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: states.pressed ? N.a(0.08) : N.panel,
            borderRadius: N.brLg,
            border: Border.all(
              color: states.hovered ? N.accent : N.line,
              width: 1.5,
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
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: N.font(size: 17, weight: FontWeight.w600),
                        ),
                        // Only the differences from the shipped list are worth
                        // marking; an untouched shipped item needs no badge.
                        if (!model.isShipped(item))
                          const NTag.info('Yours')
                        else if (model.isEdited(item))
                          const NTag.warning(
                            'Repriced',
                            icon: PhosphorIcons.pencil,
                          ),
                      ],
                    ),
                    if (detail.isNotEmpty)
                      Text(detail, style: N.caption(size: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // The price over the way to change it, so neither is squeezed
              // off a phone.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    money(item.rate),
                    style: N.font(size: 17, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.pencil,
                        size: 16,
                        color: N.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: N.font(
                          size: 15,
                          weight: FontWeight.w600,
                          color: N.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemovedRow extends StatelessWidget {
  const _RemovedRow({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.read(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: N.brMd,
          border: Border.all(color: N.line, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: N.font(size: 16, color: N.t(0.75)),
                  ),
                  Text(
                    '${money(item.rate)} · ${item.kind.label}',
                    style: N.caption(size: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            NButton(
              'Put back',
              variant: ButtonVariant.secondary,
              padding: 14,
              onPressed: () => model.restoreItem(item),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Text(
      query.trim().isEmpty
          ? 'Your rate card is empty. Add the parts and jobs you sell.'
          : 'Nothing on the rate card matches “${query.trim()}”.',
      textAlign: TextAlign.center,
      style: N.caption(size: 16, height: 1.5),
    ),
  );
}
