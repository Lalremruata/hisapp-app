import 'package:flutter/widgets.dart';

import '../services/bills_csv.dart';
import '../services/data_files.dart';
import '../state/backup.dart';
import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';

/// Taking the workshop's data off the device and bringing it back: a backup
/// file to keep safe or move to another device, and a spreadsheet of bills for
/// the accountant.
class BackupSection extends StatefulWidget {
  const BackupSection({super.key, required this.onRestored});

  /// Called after an import or an undo has changed the workshop's details,
  /// so a form showing them can catch up.
  final VoidCallback onRestored;

  @override
  State<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<BackupSection> {
  bool _busy = false;

  /// Runs [job] with the buttons off, and says so if it fails.
  Future<void> _run(String failure, Future<void> Function() job) async {
    // The toast's Undo can outlive the screen that showed it.
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    try {
      await job();
    } on BackupException catch (error) {
      if (mounted) {
        showNToast(
          context,
          error.message,
          duration: const Duration(seconds: 8),
        );
      }
    } catch (error) {
      if (mounted) showNToast(context, '$failure $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportBackup(Rect? origin) =>
      _run('Could not export the backup.', () async {
        final backup = BillingScope.read(context).backup();
        final sent = await sendTextFile(
          text: backup.encode(),
          fileName: backup.fileName,
          mimeType: 'application/json',
          origin: origin,
        );
        if (sent && mounted) {
          showNToast(
            context,
            'Backup exported: ${_count(backup.bills.length, 'bill')}.',
          );
        }
      });

  Future<void> _exportCsv(Rect? origin) =>
      _run('Could not export the bills.', () async {
        final model = BillingScope.read(context);
        // Oldest first, the way an accountant reads a register.
        final bills = model.bills.reversed;
        final sent = await sendTextFile(
          text: billsCsv(bills),
          fileName: billsCsvFileName(DateTime.now()),
          mimeType: 'text/csv',
          origin: origin,
        );
        if (sent && mounted) {
          showNToast(
            context,
            'Exported ${_count(bills.length, 'bill')} for the accountant.',
          );
        }
      });

  Future<void> _import() => _run('Could not import the backup.', () async {
    final model = BillingScope.read(context);
    final text = await pickTextFile();
    if (text == null || !mounted) return;

    final backup = Backup.parse(text);
    final mode = await _showImportDialog(context, backup);
    if (mode == null || !mounted) return;

    final report = await model.restore(backup, mode);
    widget.onRestored();
    if (!mounted) return;
    showNToast(
      context,
      _reportMessage(report),
      actionLabel: 'Undo',
      onAction: _undo,
      duration: const Duration(seconds: 8),
    );
  });

  Future<void> _undo() => _run('Could not undo the import.', () async {
    await BillingScope.read(context).undoRestore();
    widget.onRestored();
    if (mounted) {
      showNToast(context, 'Put back the data from before the import.');
    }
  });

  Future<void> _confirmUndo() async {
    final sure = await showNocturneDialog<bool>(
      context: context,
      builder: (context) => NDialog(
        title: 'Undo the last import?',
        actions: [
          NButton(
            'Keep it',
            variant: ButtonVariant.secondary,
            height: 56,
            padding: 18,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          NButton(
            'Undo import',
            variant: ButtonVariant.danger,
            height: 56,
            padding: 20,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
        child: Text(
          'The bills, rate card and details go back to how they were just '
          'before it. Bills raised since the import are lost.',
          style: N.font(size: 16, color: N.t(0.85), height: 1.5),
        ),
      ),
    );
    if (sure ?? false) await _undo();
  }

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);

    Widget button(
      String label,
      void Function(Rect? origin) onPressed, {
      ButtonVariant variant = ButtonVariant.secondary,
    }) => Builder(
      builder: (context) => NButton(
        label,
        variant: variant,
        height: 52,
        expand: true,
        onPressed: _busy ? null : () => onPressed(_originOf(context)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Kicker('Backup & restore'),
        const SizedBox(height: 4),
        Text(
          'Keep a copy of your bills, rate card and details somewhere safe, '
          'or move them to another phone or tablet.',
          style: N.caption(size: 15, height: 1.5),
        ),
        const SizedBox(height: 14),
        button('Export backup', _exportBackup),
        const SizedBox(height: 10),
        button('Import backup', (_) => _import()),
        const SizedBox(height: 10),
        button('Export bills for accountant (CSV)', _exportCsv),
        if (model.hasRestorePoint) ...[
          const SizedBox(height: 10),
          button(
            'Undo last import',
            (_) => _confirmUndo(),
            variant: ButtonVariant.quiet,
          ),
        ],
      ],
    );
  }
}

/// Asks how to bring [backup] in, after saying what is in it.
Future<RestoreMode?> _showImportDialog(BuildContext context, Backup backup) {
  final items = backup.items;
  final contents = [
    _count(backup.bills.length, 'bill'),
    if (items.custom.isNotEmpty) _count(items.custom.length, 'added item'),
    if (items.overrides.isNotEmpty)
      _count(items.overrides.length, 'repriced item'),
    if (items.hidden.isNotEmpty) _count(items.hidden.length, 'removed item'),
  ].join(' · ');
  final from = [
    if (backup.settings case final settings?) settings.name,
    'exported ${BillingModel.dateLabel(backup.exportedAt)}',
  ].join(' · ');
  final body = N.font(size: 16, color: N.t(0.85), height: 1.5);

  return showNocturneDialog<RestoreMode>(
    context: context,
    builder: (context) => NDialog(
      title: 'Import this backup?',
      leadingAction: NButton(
        'Cancel',
        variant: ButtonVariant.quiet,
        height: 56,
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        NButton(
          'Replace',
          variant: ButtonVariant.secondary,
          height: 56,
          padding: 18,
          onPressed: () => Navigator.of(context).pop(RestoreMode.replace),
        ),
        NButton(
          'Merge',
          height: 56,
          padding: 20,
          onPressed: () => Navigator.of(context).pop(RestoreMode.merge),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(contents, style: N.font(size: 17, weight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(from, style: N.caption(size: 15)),
          if (backup.unreadable > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${_count(backup.unreadable, 'bill')} in the file could not be '
              'read and will be left out.',
              style: N.font(size: 15, color: N.warningInk),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Merge adds the bills this device does not have yet and keeps '
            'everything already here, including your workshop details.',
            style: body,
          ),
          const SizedBox(height: 8),
          Text(
            'Replace clears this device and puts the backup in its place.',
            style: body,
          ),
          const SizedBox(height: 8),
          Text(
            'Either way, you can undo it afterwards from Settings.',
            style: N.caption(size: 15),
          ),
        ],
      ),
    ),
  );
}

String _reportMessage(RestoreReport report) {
  if (report.mode == RestoreMode.replace) {
    return 'Backup restored: ${_count(report.bills, 'bill')}.';
  }
  final parts = [
    'Added ${_count(report.bills, 'bill')}.',
    if (report.skipped > 0)
      '${report.skipped} ${report.skipped == 1 ? 'was' : 'were'} already here.',
    if (report.clashes > 0)
      '${report.clashes} share an invoice number with a bill here.',
  ];
  return parts.join(' ');
}

String _count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

/// Where [context]'s widget sits on screen, for the iPad share sheet to
/// point from.
Rect? _originOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}
