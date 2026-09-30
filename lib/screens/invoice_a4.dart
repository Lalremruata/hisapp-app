import 'package:flutter/foundation.dart'
    show
        TargetPlatform,
        debugPrint,
        debugPrintStack,
        defaultTargetPlatform,
        kIsWeb;
import 'package:barcode/barcode.dart';
import 'package:flutter/widgets.dart';
import 'package:printing/printing.dart';

import '../models/bill.dart';
import '../models/invoice.dart';
import '../services/invoice_pdf.dart';
import '../state/billing_model.dart';
import '../theme/components.dart';
import '../theme/nocturne.dart';
import '../theme/phosphor.dart';

/// The A4 tax invoice for a job, printed from either device.
///
/// This is the one light surface in the system: paper, drawn from the light
/// end of the neutral ramp rather than from the dark ground.
class InvoiceA4Screen extends StatelessWidget {
  const InvoiceA4Screen({super.key});

  /// A4 at 96dpi, which is the width the artboard is drawn at.
  static const pageWidth = 794.0;

  @override
  Widget build(BuildContext context) {
    N.watch(context);
    final inset = MediaQuery.paddingOf(context);

    return ColoredBox(
      color: N.desk,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Toolbar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 32 + inset.bottom),
                // The page keeps its A4 proportions and scales down whole on a
                // narrow screen, the way a print preview does.
                // The sheet is set at print size whatever the text-size
                // setting says: it has to show what the printer will do.
                child: MediaQuery.withNoTextScaling(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: pageWidth,
                      child: const InvoicePage(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Toolbar extends StatefulWidget {
  const _Toolbar();

  @override
  State<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<_Toolbar> {
  /// True while the PDF is being built, so a slow first build — it loads the
  /// fonts — cannot be fired twice by an impatient second tap.
  bool _busy = false;

  /// What went wrong last time, shown next to the buttons. A printer that will
  /// not answer has to say so — silence at the counter looks like a bill that
  /// went out when it did not.
  String? _problem;

  Future<void> _run(Future<void> Function(InvoiceData data) action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _problem = null;
    });
    try {
      await action(BillingScope.read(context).invoiceData);
    } catch (error, stack) {
      debugPrint('invoice: $error');
      debugPrintStack(stackTrace: stack);
      if (mounted) setState(() => _problem = 'Could not do that — $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _print() => _run((data) async {
    final bytes = await buildInvoicePdf(data);
    // Hands the sheet to the platform's own print dialog, which is also where
    // "Save as PDF" lives on every desktop and phone.
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: data.fileName,
      usePrinterSettings: true,
    );
  });

  Future<void> _shareOrSave() => _run((data) async {
    final bytes = await buildInvoicePdf(data);
    await Printing.sharePdf(
      bytes: bytes,
      filename: data.fileName,
      subject: 'Invoice ${data.invoiceNo}',
      body: 'Your invoice from ${data.workshopName}.',
    );
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 20, 12),
    child: Row(
      children: [
        const BackButtonN(),
        const SizedBox(width: 14),
        Expanded(
          child: _problem == null
              ? Text(
                  'Tax invoice',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: N.font(size: 20, weight: FontWeight.w600),
                )
              : Text(
                  _problem!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: N.font(
                    size: 14,
                    weight: FontWeight.w500,
                    color: N.dangerInk,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        NButton(
          // On the web the file lands in Downloads, which is saving it; on
          // Windows there is no share sheet, so it opens in the PDF viewer;
          // on a phone it is the share sheet, where "Save to Files" also lives.
          kIsWeb
              ? 'Save PDF'
              : defaultTargetPlatform == TargetPlatform.windows
              ? 'Open PDF'
              : 'Share',
          variant: ButtonVariant.secondary,
          padding: 16,
          onPressed: _busy ? null : _shareOrSave,
        ),
        const SizedBox(width: 10),
        NButton(
          _busy ? 'Working…' : 'Print',
          padding: 20,
          icon: _busy ? null : PhosphorIcons.printer,
          onPressed: _busy ? null : _print,
        ),
      ],
    ),
  );
}

/// The page itself, at its printed size. Lifted out so the same widget can be
/// handed to a print or PDF pipeline later.
class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  // Ink on paper. Pinned here rather than read through [N], and the same
  // values the PDF prints with (`services/invoice_pdf.dart`): this page is a
  // picture of what the printer will put on white A4, so it looks the same
  // whichever palette — or redesign — the app around it is wearing.
  static const _ink = Color(0xFF161826);

  /// The sheet itself.
  static const paper = Color(0xFFF3F5FE);
  static const _paper = paper;
  static const _rule = Color(0xFFCFD3E5);
  static const _hairline = Color(0xFFE4E7F5);
  static const _muted = Color(0xFF595D6C);
  static const _label = Color(0xFF75798C);
  static const _heading = Color(0xFF5D5294);

  static TextStyle _font({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) => N.font(
    size: size,
    weight: weight,
    color: color ?? _ink,
    height: height,
    letterSpacing: letterSpacing,
  );

  @override
  Widget build(BuildContext context) {
    final model = BillingScope.of(context);
    final store = model.settings;
    final invoice = model.invoiceData;

    return Container(
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: N.brSm,
        boxShadow: N.shadowLg,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── masthead ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: _font(
                          size: 24,
                          weight: FontWeight.w500,
                          letterSpacing: -0.015 * 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${store.address}\nPhone ${store.phone}',
                        style: _font(size: 12.5, color: _muted, height: 1.6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GSTIN ${store.gstin} · State ${store.placeOfSupply}',
                        style: _font(size: 12.5, weight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TAX INVOICE',
                      style: _font(
                        size: 11,
                        weight: FontWeight.w600,
                        color: _heading,
                        letterSpacing: 0.14 * 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      model.invoiceNo,
                      style: _font(size: 17, weight: FontWeight.w500),
                    ),
                    Text(
                      'Date ${model.invoiceDateLabel}\n'
                      'Place of supply · ${store.placeOfSupply}',
                      textAlign: TextAlign.right,
                      style: _font(size: 12.5, color: _muted, height: 1.6),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: _rule),

          // ── counterparty ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Block(
                  flex: 4,
                  label: 'Billed to',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.vehicle.customerName.trim().isEmpty
                            ? '—'
                            : model.vehicle.customerName.trim(),
                        style: _font(size: 14.5, weight: FontWeight.w500),
                      ),
                      if (model.vehicle.customerPhone.trim().isNotEmpty)
                        Text(
                          model.vehicle.customerPhone.trim(),
                          style: _font(size: 12.5, color: _muted),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                _Block(
                  flex: 4,
                  label: 'Vehicle',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.vehicle.registration.trim().toUpperCase().isEmpty
                            ? '—'
                            : model.vehicle.registration.trim().toUpperCase(),
                        style: _font(
                          size: 14.5,
                          weight: FontWeight.w500,
                          letterSpacing: 14.5 * 0.03,
                        ),
                      ),
                      Text(
                        [
                          if (model.vehicle.makeModel.trim().isNotEmpty)
                            model.vehicle.makeModel.trim(),
                          if (model.vehicle.odometerLabel.isNotEmpty)
                            model.vehicle.odometerLabel,
                        ].join(' · '),
                        style: _font(size: 12.5, color: _muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                _Block(
                  flex: 3,
                  label: 'Payment',
                  child: Text(switch ((model.isPaid, model.payment)) {
                    (true, PaymentMethod.due) => 'On account · due',
                    (true, final method?) => '${method.label} · settled',
                    _ => 'Not yet paid',
                  }, style: _font(size: 14.5, weight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          Container(height: 1, color: _rule),

          // ── lines ──────────────────────────────────────────────────────
          const SizedBox(height: 18),
          _InvoiceTable(
            partLines: model.partLines,
            labourLines: model.labourLines,
          ),

          // ── totals ─────────────────────────────────────────────────────
          const SizedBox(height: 26),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMOUNT IN WORDS',
                      style: _font(
                        size: 11,
                        color: _label,
                        letterSpacing: 0.1 * 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      model.totalWords,
                      style: _font(
                        size: 13,
                        weight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    if (invoice.showsPayment) ...[
                      const SizedBox(height: 18),
                      _PayTo(invoice: invoice),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Goods once sold will not be taken back. '
                      'This is a computer-generated invoice.',
                      style: _font(size: 11.5, color: _label, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              SizedBox(width: 290, child: _Totals(model: model)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Where the customer can pay: the bank account, and a UPI code for this
/// bill's total. The same block the PDF prints (`services/invoice_pdf.dart`).
class _PayTo extends StatelessWidget {
  const _PayTo({required this.invoice});

  final InvoiceData invoice;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (invoice.bankLines.isNotEmpty)
        _Block(
          flex: 1,
          label: 'Bank details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, value) in invoice.bankLines)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text.rich(
                    TextSpan(
                      text: '$label  ',
                      style: InvoicePage._font(
                        size: 12,
                        color: InvoicePage._muted,
                      ),
                      children: [
                        TextSpan(
                          text: value,
                          style: InvoicePage._font(size: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      if (invoice.upiUri case final uri?) ...[
        if (invoice.bankLines.isNotEmpty) const SizedBox(width: 16),
        Column(
          children: [
            // Quiet zone of white round the code, so a phone camera finds its
            // edges against the tinted sheet.
            Container(
              color: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.all(4),
              child: UpiQr(data: uri, size: 104),
            ),
            const SizedBox(height: 5),
            Text('Scan to pay with UPI', style: InvoicePage._font(size: 11)),
            Text(
              invoice.upiId,
              style: InvoicePage._font(size: 11, color: InvoicePage._muted),
            ),
          ],
        ),
      ],
    ],
  );
}

/// A QR code, painted square by square.
class UpiQr extends StatelessWidget {
  const UpiQr({super.key, required this.data, required this.size});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _QrPainter(data));
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data);

  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    // Unsmoothed, so neighbouring squares meet without a hairline seam.
    final paint = Paint()
      ..color = InvoicePage._ink
      ..isAntiAlias = false;
    for (final element in Barcode.qrCode().make(
      data,
      width: size.width,
      height: size.height,
    )) {
      if (element is BarcodeBar && element.black) {
        canvas.drawRect(
          Rect.fromLTWH(
            element.left,
            element.top,
            element.width,
            element.height,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.data != data;
}

class _Block extends StatelessWidget {
  const _Block({required this.label, required this.child, this.flex});

  final String label;
  final Widget child;

  /// Set when the block shares a row and has to be able to give way.
  final int? flex;

  @override
  Widget build(BuildContext context) {
    final column = _column();
    return flex == null ? column : Expanded(flex: flex!, child: column);
  }

  Widget _column() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label.toUpperCase(),
        style: InvoicePage._font(
          size: 11,
          color: InvoicePage._label,
          letterSpacing: 0.1 * 11,
        ),
      ),
      const SizedBox(height: 5),
      child,
    ],
  );
}

class _InvoiceTable extends StatelessWidget {
  const _InvoiceTable({required this.partLines, required this.labourLines});

  final List<BillLine> partLines;
  final List<BillLine> labourLines;

  static const _widths = <int, TableColumnWidth>{
    0: FlexColumnWidth(),
    1: IntrinsicColumnWidth(),
    2: IntrinsicColumnWidth(),
    3: IntrinsicColumnWidth(),
    4: IntrinsicColumnWidth(),
    5: IntrinsicColumnWidth(),
    6: IntrinsicColumnWidth(),
    7: IntrinsicColumnWidth(),
  };

  @override
  Widget build(BuildContext context) {
    Widget head(String label, {bool right = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        label.toUpperCase(),
        textAlign: right ? TextAlign.right : TextAlign.left,
        style: InvoicePage._font(
          size: 10.5,
          weight: FontWeight.w600,
          color: InvoicePage._label,
          letterSpacing: 0.09 * 10.5,
        ),
      ),
    );

    Widget cell(
      String text, {
      bool right = false,
      Color? color,
      FontWeight weight = FontWeight.w400,
      String? small,
    }) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Text.rich(
        TextSpan(
          text: text,
          children: small == null
              ? null
              : [
                  TextSpan(
                    text: ' $small',
                    style: InvoicePage._font(size: 11, color: color),
                  ),
                ],
        ),
        textAlign: right ? TextAlign.right : TextAlign.left,
        style: InvoicePage._font(size: 13, color: color, weight: weight),
      ),
    );

    return Table(
      columnWidths: _widths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: InvoicePage._rule)),
          ),
          children: [
            head('Item'),
            head('HSN/SAC'),
            head('Qty', right: true),
            head('Rate', right: true),
            head('Taxable', right: true),
            head('CGST', right: true),
            head('SGST', right: true),
            head('Amount', right: true),
          ],
        ),
        // Parts fitted, then work done. The band is only worth printing when
        // the invoice carries both.
        if (partLines.isNotEmpty && labourLines.isNotEmpty)
          _sectionRow('Parts fitted'),
        for (final line in partLines) _lineRow(line, cell),
        if (partLines.isNotEmpty && labourLines.isNotEmpty)
          _sectionRow('Work done'),
        for (final line in labourLines) _lineRow(line, cell),
      ],
    );
  }

  /// A band naming the group of lines under it, spanning every column.
  TableRow _sectionRow(String label) => TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(6, 14, 6, 4),
        child: Text(
          label.toUpperCase(),
          style: InvoicePage._font(
            size: 10,
            weight: FontWeight.w600,
            color: InvoicePage._heading,
            letterSpacing: 0.12 * 10,
          ),
        ),
      ),
      for (var i = 0; i < 7; i++) const SizedBox.shrink(),
    ],
  );

  TableRow _lineRow(BillLine line, _CellBuilder cell) => TableRow(
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: InvoicePage._hairline)),
    ),
    children: [
      cell(line.name),
      // A hand-entered item may have no code; a dash keeps the column
      // reading as a column.
      cell(line.code.isEmpty ? '—' : line.code, color: InvoicePage._muted),
      cell('${line.qty}', right: true),
      cell(line.rateLabel, right: true),
      cell(line.amountLabel, right: true),
      cell(
        line.halfGstLabel,
        right: true,
        color: InvoicePage._muted,
        small: '(${line.halfGstPct})',
      ),
      cell(
        line.halfGstLabel,
        right: true,
        color: InvoicePage._muted,
        small: '(${line.halfGstPct})',
      ),
      cell(line.grossLabel, right: true, weight: FontWeight.w500),
    ],
  );
}

/// The signature of the cell builder the table rows share.
typedef _CellBuilder =
    Widget Function(
      String text, {
      bool right,
      Color color,
      FontWeight weight,
      String? small,
    });

class _Totals extends StatelessWidget {
  const _Totals({required this.model});

  final BillingModel model;

  Widget _row(String label, String value, {bool ruled = false}) => Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: ruled
        ? BoxDecoration(
            border: Border(bottom: BorderSide(color: InvoicePage._rule)),
          )
        : null,
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: InvoicePage._font(size: 13, color: InvoicePage._muted),
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: InvoicePage._font(size: 13)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _row('Taxable value', model.taxableLabel),
      _row('CGST', model.cgstLabel),
      _row('SGST', model.sgstLabel),
      _row('Round off', model.roundLabel, ruled: true),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                'Total payable',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: InvoicePage._font(size: 13, weight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  model.totalLabel,
                  maxLines: 1,
                  style: InvoicePage._font(
                    size: 26,
                    weight: FontWeight.w500,
                    letterSpacing: -0.02 * 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // The signature rule, left blank for a hand.
      Container(
        margin: const EdgeInsets.only(top: 22),
        height: 64,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: InvoicePage._rule)),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Authorised signatory',
        textAlign: TextAlign.right,
        style: InvoicePage._font(size: 11.5, color: InvoicePage._label),
      ),
    ],
  );
}
