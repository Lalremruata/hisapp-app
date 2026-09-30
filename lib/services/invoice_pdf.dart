import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/invoice.dart';

/// Builds the tax invoice as a real PDF.
///
/// The page is laid out in the pdf package's own widget layer rather than
/// captured from the screen, so the text stays vector: crisp on a 600dpi
/// printer, selectable and searchable in a viewer, and a few kilobytes rather
/// than a few megabytes when it goes out on WhatsApp.
Future<Uint8List> buildInvoicePdf(InvoiceData data) async {
  final theme = await _theme();
  final doc = pw.Document(title: data.invoiceNo, author: data.workshopName);

  doc.addPage(
    // MultiPage, not Page: a big job runs to twenty lines and more, and a
    // single fixed sheet would throw rather than carry on overleaf. The table
    // splits across sheets on its own.
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      margin: const pw.EdgeInsets.symmetric(horizontal: 42, vertical: 44),
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox()
          : pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 14),
              child: pw.Text(
                '${data.invoiceNo} \u00b7 continued',
                style: _style(size: 8, color: _label),
              ),
            ),
      footer: (context) => context.pagesCount == 1
          ? pw.SizedBox()
          : pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: _style(size: 8, color: _label),
              ),
            ),
      build: (context) => [
        _masthead(data),
        pw.SizedBox(height: 18),
        pw.Divider(color: _rule, height: 1, thickness: 1),
        pw.SizedBox(height: 16),
        _counterparty(data),
        pw.SizedBox(height: 16),
        pw.Divider(color: _rule, height: 1, thickness: 1),
        pw.SizedBox(height: 14),
        _table(data),
        pw.SizedBox(height: 22),
        _footer(data),
        pw.SizedBox(height: 28),
        _signature(),
      ],
    ),
  );

  return doc.save();
}

// Ink on paper. The screen shows the page on the design's tinted stock because
// it sits on a dark ground; on an actual sheet that tint is a full-bleed flood
// of ink, so the printed page is white and only the marks are coloured.
const _ink = PdfColor.fromInt(0xFF161826);
const _muted = PdfColor.fromInt(0xFF595D6C);
const _label = PdfColor.fromInt(0xFF75798C);
const _rule = PdfColor.fromInt(0xFFCFD3E5);
const _hairline = PdfColor.fromInt(0xFFE4E7F5);
const _accent = PdfColor.fromInt(0xFF5D5294);

pw.ThemeData? _cached;

Future<pw.ThemeData> _theme() async {
  if (_cached case final theme?) return theme;

  // Inter, bundled: the standard PDF faces carry no rupee sign, and this
  // invoice is made of rupee amounts.
  Future<pw.Font> load(String name) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/$name'));

  final regular = await load('Inter-Regular.ttf');
  final medium = await load('Inter-Medium.ttf');
  final semiBold = await load('Inter-SemiBold.ttf');

  return _cached =
      pw.ThemeData.withFont(
        base: regular,
        bold: medium,
        italic: regular,
        boldItalic: medium,
        icons: null,
      ).copyWith(
        defaultTextStyle: pw.TextStyle(
          font: regular,
          fontSize: 9.5,
          color: _ink,
        ),
        header0: pw.TextStyle(font: semiBold, fontSize: 9.5, color: _ink),
      );
}

pw.TextStyle _style({
  double size = 9.5,
  PdfColor color = _ink,
  bool medium = false,
  double? letterSpacing,
  double? lineSpacing,
}) => pw.TextStyle(
  fontSize: size,
  color: color,
  fontWeight: medium ? pw.FontWeight.bold : pw.FontWeight.normal,
  letterSpacing: letterSpacing,
  lineSpacing: lineSpacing,
);

pw.Widget _kicker(String text) => pw.Text(
  text.toUpperCase(),
  style: _style(size: 7.5, color: _label, letterSpacing: 0.75),
);

pw.Widget _masthead(InvoiceData data) => pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(data.workshopName, style: _style(size: 17, medium: true)),
          pw.SizedBox(height: 5),
          pw.Text(
            data.workshopAddress,
            style: _style(size: 9, color: _muted, lineSpacing: 2),
          ),
          pw.Text(
            'Phone ${data.workshopPhone}',
            style: _style(size: 9, color: _muted, lineSpacing: 2),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'GSTIN ${data.gstin} \u00b7 State ${data.placeOfSupply}',
            style: _style(size: 9, medium: true),
          ),
        ],
      ),
    ),
    pw.SizedBox(width: 24),
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'TAX INVOICE',
          style: _style(
            size: 8,
            color: _accent,
            medium: true,
            letterSpacing: 1.1,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(data.invoiceNo, style: _style(size: 12, medium: true)),
        pw.SizedBox(height: 2),
        pw.Text(
          'Date ${data.dateLabel}',
          style: _style(size: 9, color: _muted),
        ),
        pw.Text(
          'Place of supply \u00b7 ${data.placeOfSupply}',
          style: _style(size: 9, color: _muted),
        ),
      ],
    ),
  ],
);

pw.Widget _block(String label, List<pw.Widget> children) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [_kicker(label), pw.SizedBox(height: 3), ...children],
);

pw.Widget _counterparty(InvoiceData data) => pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Expanded(
      flex: 4,
      child: _block('Billed to', [
        pw.Text(data.customerName, style: _style(size: 10.5, medium: true)),
        if (data.customerPhone.isNotEmpty)
          pw.Text(data.customerPhone, style: _style(size: 9, color: _muted)),
      ]),
    ),
    pw.Expanded(
      flex: 4,
      child: _block('Vehicle', [
        pw.Text(
          data.registration,
          style: _style(size: 10.5, medium: true, letterSpacing: 0.3),
        ),
        if (data.vehicleLine.isNotEmpty)
          pw.Text(data.vehicleLine, style: _style(size: 9, color: _muted)),
      ]),
    ),
    pw.Expanded(
      flex: 3,
      child: _block('Payment', [
        pw.Text(data.paymentLabel, style: _style(size: 10.5, medium: true)),
      ]),
    ),
  ],
);

pw.Widget _table(InvoiceData data) {
  pw.Widget head(String text, {bool right = false}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: pw.Text(
      text.toUpperCase(),
      textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
      style: _style(size: 7, color: _label, medium: true, letterSpacing: 0.65),
    ),
  );

  pw.Widget cell(
    String text, {
    bool right = false,
    PdfColor color = _ink,
    bool medium = false,
    String? small,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 7),
    child: pw.RichText(
      textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
      text: pw.TextSpan(
        text: text,
        style: _style(size: 9.5, color: color, medium: medium),
        children: small == null
            ? null
            : [
                pw.TextSpan(
                  text: ' $small',
                  style: _style(size: 7.5, color: color),
                ),
              ],
      ),
    ),
  );

  pw.TableRow section(String label) => pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(4, 10, 4, 3),
        child: pw.Text(
          label.toUpperCase(),
          style: _style(
            size: 7,
            color: _accent,
            medium: true,
            letterSpacing: 0.8,
          ),
        ),
      ),
      for (var i = 0; i < 7; i++) pw.SizedBox(),
    ],
  );

  pw.TableRow row(InvoiceLine line) => pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _hairline, width: 0.7)),
    ),
    children: [
      cell(line.name),
      cell(line.code, color: _muted),
      cell('${line.qty}', right: true),
      cell(line.rateLabel, right: true),
      cell(line.taxableLabel, right: true),
      cell(
        line.halfGstLabel,
        right: true,
        color: _muted,
        small: '(${line.halfGstPct})',
      ),
      cell(
        line.halfGstLabel,
        right: true,
        color: _muted,
        small: '(${line.halfGstPct})',
      ),
      cell(line.grossLabel, right: true, medium: true),
    ],
  );

  return pw.Table(
    columnWidths: const {
      0: pw.FlexColumnWidth(),
      1: pw.IntrinsicColumnWidth(),
      2: pw.IntrinsicColumnWidth(),
      3: pw.IntrinsicColumnWidth(),
      4: pw.IntrinsicColumnWidth(),
      5: pw.IntrinsicColumnWidth(),
      6: pw.IntrinsicColumnWidth(),
      7: pw.IntrinsicColumnWidth(),
    },
    defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.8)),
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
      if (data.showsSections) section('Parts fitted'),
      for (final line in data.parts) row(line),
      if (data.showsSections) section('Work done'),
      for (final line in data.labour) row(line),
    ],
  );
}

pw.Widget _footer(InvoiceData data) {
  pw.Widget total(String label, String value, {bool ruled = false}) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        decoration: ruled
            ? const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: _rule, width: 0.8),
                ),
              )
            : null,
        child: pw.Row(
          children: [
            pw.Text(label, style: _style(size: 9.5, color: _muted)),
            pw.Spacer(),
            pw.Text(value, style: _style(size: 9.5)),
          ],
        ),
      );

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _kicker('Amount in words'),
            pw.SizedBox(height: 3),
            pw.Text(
              data.totalWords,
              style: _style(size: 9.5, medium: true, lineSpacing: 2),
            ),
            if (data.showsPayment) ...[pw.SizedBox(height: 14), _payTo(data)],
            pw.SizedBox(height: 12),
            pw.Text(
              'Goods once sold will not be taken back. '
              'This is a computer-generated invoice.',
              style: _style(size: 8, color: _label, lineSpacing: 2),
            ),
          ],
        ),
      ),
      pw.SizedBox(width: 30),
      pw.SizedBox(
        width: 200,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            total('Taxable value', data.taxableLabel),
            total('CGST', data.cgstLabel),
            total('SGST', data.sgstLabel),
            total('Round off', data.roundLabel, ruled: true),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Total payable',
                  style: _style(size: 9.5, medium: true),
                ),
                pw.Spacer(),
                pw.Text(data.totalLabel, style: _style(size: 16, medium: true)),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

/// Where the customer can pay: the bank account, and a UPI code that opens a
/// payment for this bill's total in any UPI app.
pw.Widget _payTo(InvoiceData data) => pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    if (data.bankLines.isNotEmpty)
      pw.Expanded(
        child: _block('Bank details', [
          for (final (label, value) in data.bankLines)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1.5),
              child: pw.RichText(
                text: pw.TextSpan(
                  text: '$label  ',
                  style: _style(size: 8.5, color: _muted),
                  children: [
                    pw.TextSpan(text: value, style: _style(size: 8.5)),
                  ],
                ),
              ),
            ),
        ]),
      ),
    if (data.upiUri case final uri?) ...[
      if (data.bankLines.isNotEmpty) pw.SizedBox(width: 12),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: uri,
            width: 76,
            height: 76,
            color: _ink,
          ),
          pw.SizedBox(height: 4),
          pw.Text('Scan to pay with UPI', style: _style(size: 7.5)),
          pw.Text(data.upiId, style: _style(size: 7.5, color: _muted)),
        ],
      ),
    ],
  ],
);

pw.Widget _signature() => pw.Row(
  children: [
    pw.Spacer(),
    pw.SizedBox(
      width: 200,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            height: 46,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: _rule, width: 0.8),
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Authorised signatory',
            textAlign: pw.TextAlign.right,
            style: _style(size: 8, color: _label),
          ),
        ],
      ),
    ),
  ],
);
