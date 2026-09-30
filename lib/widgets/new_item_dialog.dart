import 'package:flutter/widgets.dart';

import '../models/catalog.dart';
import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';

/// Asks for a part or a job the rate card does not have, and creates it.
///
/// Returns the created item, or null if the shopkeeper backed out. The item is
/// on the master by the time this returns, unless they turned that off — what
/// happens to it next is the caller's business, because the search screens bill
/// it while the keypad loads it into the draft.
Future<CatalogItem?> showNewItemDialog(
  BuildContext context, {
  String prefillName = '',
  String confirmLabel = 'Add to bill',
}) {
  final model = BillingScope.read(context);
  return showNocturneDialog<CatalogItem>(
    context: context,
    builder: (context) => _NewItemForm(
      model: model,
      prefillName: prefillName,
      confirmLabel: confirmLabel,
    ),
  );
}

/// Opens [existing] for editing on the rate card.
///
/// Saving writes the change straight through; removing takes the item off the
/// rate card. Either way a bill already open is untouched, because a line
/// copies what it needs when it is added.
Future<void> showItemEditor(BuildContext context, CatalogItem existing) {
  final model = BillingScope.read(context);
  return showNocturneDialog<void>(
    context: context,
    builder: (context) => _NewItemForm(
      model: model,
      existing: existing,
      prefillName: existing.name,
      confirmLabel: 'Save',
    ),
  );
}

/// Creates an item and puts it straight on the bill — what both search screens
/// do with the result.
Future<void> createAndBill(
  BuildContext context, {
  String prefillName = '',
}) async {
  final model = BillingScope.read(context);
  final item = await showNewItemDialog(context, prefillName: prefillName);
  if (item == null) return;
  model.addToCart(item);
  if (context.mounted) showNToast(context, 'Added ${item.name}');
}

/// What "Add to bill" and the Enter key do: take the first match, or — when
/// nothing matches — offer to create what was typed. The model cannot open a
/// dialog, so this branch lives in the widget layer.
void addOrCreate(BuildContext context) {
  final model = BillingScope.read(context);
  if (model.suggestions.isNotEmpty) {
    final name = model.suggestions.first.name;
    model.addFirstSuggestion();
    showNToast(context, 'Added $name');
  } else if (model.query.trim().isNotEmpty) {
    createAndBill(context, prefillName: model.query);
  }
}

class _NewItemForm extends StatefulWidget {
  const _NewItemForm({
    required this.model,
    required this.prefillName,
    required this.confirmLabel,
    this.existing,
  });

  final BillingModel model;
  final String prefillName;
  final String confirmLabel;

  /// The item being changed, or null when one is being made.
  final CatalogItem? existing;

  @override
  State<_NewItemForm> createState() => _NewItemFormState();
}

class _NewItemFormState extends State<_NewItemForm> {
  late final _name = TextEditingController(text: widget.prefillName.trim());
  late final _rate = TextEditingController(
    text: widget.existing == null ? '' : _plain(widget.existing!.rate),
  );

  /// A new job starts with the SAC for vehicle repair, as switching to a job
  /// would give it.
  late final _code = TextEditingController(
    text: widget.existing?.code ?? motorServiceSac,
  );

  /// Labour, first on the choice and chosen from the start. Switching to a
  /// part moves the slab and the code with it.
  late ItemKind _kind = widget.existing?.kind ?? ItemKind.labour;

  /// Service work carries 18%. Switching to a part moves this to the 28% most
  /// motor-vehicle parts sit at.
  late int _gst = widget.existing?.gst ?? 18;
  bool _remember = true;

  bool get _editing => widget.existing != null;

  /// A rate without a trailing `.0`, so an edit does not turn 350 into 350.0.
  static String _plain(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

  /// Parts and jobs default to different slabs and different codes, so
  /// changing the kind moves both — unless the code was typed over by hand.
  void _setKind(ItemKind kind) {
    setState(() {
      final codeWasDefault =
          _code.text.trim() ==
          (_kind == ItemKind.labour ? motorServiceSac : '');
      _kind = kind;
      _gst = kind == ItemKind.labour ? 18 : 28;
      if (codeWasDefault) {
        _code.text = kind == ItemKind.labour ? motorServiceSac : '';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // The confirm button tracks what has been typed.
    _name.addListener(_onChanged);
    _rate.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _name.removeListener(_onChanged);
    _rate.removeListener(_onChanged);
    for (final controller in [_name, _rate, _code]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? get _parsedRate {
    final value = double.tryParse(_rate.text.trim());
    if (value == null || value <= 0) return null;
    return value;
  }

  bool get _canSubmit => _name.text.trim().isNotEmpty && _parsedRate != null;

  void _submit() {
    final rate = _parsedRate;
    if (!_canSubmit || rate == null) return;

    if (_editing) {
      widget.model.updateItem(
        widget.existing!,
        CatalogItem(
          name: _name.text.trim(),
          rate: rate,
          gst: _gst,
          kind: _kind,
          code: _code.text.trim(),
          stock: widget.existing!.stock,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    final item = widget.model.createItem(
      name: _name.text,
      rate: rate,
      gst: _gst,
      kind: _kind,
      code: _code.text,
      remember: _remember,
    );
    Navigator.of(context).pop(item);
  }

  Future<void> _confirmRemove() async {
    final item = widget.existing!;
    final shipped = widget.model.isShipped(item);
    final removed = await showNocturneDialog<bool>(
      context: context,
      builder: (context) => NDialog(
        title: 'Remove ${item.name}?',
        actions: [
          NButton(
            'Keep it',
            variant: ButtonVariant.secondary,
            height: 52,
            padding: 16,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          NButton(
            'Remove',
            variant: ButtonVariant.danger,
            icon: PhosphorIcons.trash,
            height: 52,
            padding: 18,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
        child: Text(
          shipped
              ? 'It comes off your rate card. You can put it back later, and '
                    'any bill it is already on stays as it is.'
              : 'It comes off your rate card for good. Any bill it is already '
                    'on stays as it is.',
          style: N.font(size: 16, color: N.t(0.85), height: 1.5),
        ),
      ),
    );

    if (removed != true || !mounted) return;
    widget.model.deleteItem(item);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return NDialog(
      title: _editing
          ? 'Edit ${_kind == ItemKind.labour ? 'job' : 'part'}'
          : _kind == ItemKind.labour
          ? 'New job'
          : 'New part',
      leadingAction: _editing
          ? NButton(
              'Remove',
              variant: ButtonVariant.dangerQuiet,
              icon: PhosphorIcons.trash,
              height: 52,
              padding: 12,
              onPressed: _confirmRemove,
            )
          : null,
      actions: [
        NButton(
          'Cancel',
          variant: ButtonVariant.secondary,
          height: 52,
          padding: 16,
          onPressed: () => Navigator.of(context).pop(),
        ),
        NButton(
          widget.confirmLabel,
          height: 52,
          padding: 18,
          onPressed: _canSubmit ? _submit : null,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('What is it?', style: N.label()),
          const SizedBox(height: 6),
          NSegmented<ItemKind>(
            // Labour first, ahead of parts.
            options: const [ItemKind.labour, ItemKind.part],
            value: _kind,
            expand: true,
            labelOf: (kind) => kind.label,
            onChanged: _setKind,
          ),
          const SizedBox(height: N.space4),
          NField(
            label: _kind == ItemKind.labour ? 'Job' : 'Part name',
            child: NInput(
              key: const ValueKey('new-item-name'),
              selectAllOnFocus: _editing,
              controller: _name,
              height: 52,
              fontSize: 17,
              autofocus: widget.prefillName.trim().isEmpty,
              placeholder: _kind == ItemKind.labour
                  ? 'e.g. Radiator flush'
                  : 'e.g. Fuel filter',
            ),
          ),
          const SizedBox(height: N.space4),
          NField(
            label: _kind == ItemKind.labour
                ? 'Charge per job (₹)'
                : 'Rate each (₹)',
            child: NInput(
              key: const ValueKey('new-item-rate'),
              selectAllOnFocus: _editing,
              controller: _rate,
              height: 52,
              fontSize: 17,
              placeholder: '0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: N.space4),
          Text('GST slab', style: N.label()),
          const SizedBox(height: 6),
          NSegmented<int>(
            options: CatalogItem.slabs,
            value: _gst,
            expand: true,
            labelOf: (slab) => '$slab%',
            onChanged: (slab) => setState(() => _gst = slab),
          ),
          const SizedBox(height: N.space4),
          NField(
            label: '${_kind.codeLabel} code (optional)',
            hint: Text(
              _kind == ItemKind.labour
                  ? 'Vehicle repair work is usually SAC $motorServiceSac.'
                  : 'Printed against this line on the tax invoice.',
              style: N.caption(),
            ),
            child: NInput(
              key: const ValueKey('new-item-code'),
              selectAllOnFocus: _editing,
              controller: _code,
              height: 52,
              fontSize: 17,
              placeholder: '—',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: N.space4),
          if (!_editing)
            NSwitchRow(
              title: 'Save to my rate card',
              subtitle: 'So you can search for it next time',
              value: _remember,
              onChanged: (value) => setState(() => _remember = value),
            ),
          if (_editing && widget.model.isShipped(widget.existing!)) ...[
            const SizedBox(height: 4),
            Text(
              'This one came with the app. Your changes stay on this device, '
              'and you can put it back the way it was.',
              style: N.caption(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
