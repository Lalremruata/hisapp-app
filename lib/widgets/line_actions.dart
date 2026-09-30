import 'package:flutter/widgets.dart';

import '../models/catalog.dart';
import '../state/billing_model.dart';
import '../theme/components.dart';

/// Takes a line off the bill, and says so with a way to put it back.
///
/// A mis-tap on a busy counter should cost one more tap, not the line.
void removeLine(BuildContext context, int index) {
  final model = BillingScope.read(context);
  _offerUndo(context, model, index, model.removeAt(index));
}

/// Nudges a line's quantity; when − takes it to nothing, offers it back the
/// same way [removeLine] does.
void bumpLine(BuildContext context, int index, int delta) {
  final model = BillingScope.read(context);
  final removed = model.bump(index, delta);
  if (removed != null) _offerUndo(context, model, index, removed);
}

void _offerUndo(
  BuildContext context,
  BillingModel model,
  int index,
  CartLine line,
) {
  showNToast(
    context,
    'Removed ${line.name}',
    actionLabel: 'Undo',
    onAction: () => model.restoreAt(index, line),
  );
}
