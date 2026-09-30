import '../models/bill.dart';
import '../models/pricing.dart';

/// Every bill as one spreadsheet row, for the accountant: the figures a GST
/// return is filled from, worked out exactly as the printed invoice works
/// them out.
///
/// Held bills are included and marked, so the sheet agrees with the bills
/// screen; filtering is the spreadsheet's job.
String billsCsv(Iterable<SavedBill> bills) {
  final rows = <List<String>>[
    const [
      'Invoice no',
      'Date',
      'Status',
      'Payment',
      'Registration',
      'Make & model',
      'Odometer',
      'Customer',
      'Phone',
      'Taxable value',
      'CGST',
      'SGST',
      'Round off',
      'Total',
    ],
    for (final bill in bills) _row(bill),
  ];
  // The byte-order mark tells Excel the file is UTF-8, so the ₹ in a name or
  // an address typed in Mizo or Hindi does not come out as mojibake.
  return '﻿${rows.map((row) => row.map(_cell).join(',')).join('\r\n')}\r\n';
}

/// A name that sorts by date: hisap-bills-2026-09-28.csv
String billsCsvFileName(DateTime day) =>
    'hisap-bills-${day.year}-${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}.csv';

List<String> _row(SavedBill bill) {
  final inclusive = bill.ratesIncludeGst;
  final priced = priceLines(bill.lines, inclusive: inclusive);
  final total = payableTotal(bill.lines, inclusive: inclusive);
  final halfGst = priced.tax / 2;
  final vehicle = bill.vehicle;
  final d = bill.date;

  return [
    bill.invoiceNo,
    // ISO dates sort, and every spreadsheet reads them as dates.
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}',
    bill.status.label,
    bill.payment?.label ?? '',
    vehicle.registration.trim().toUpperCase(),
    vehicle.makeModel.trim(),
    vehicle.odometer.trim(),
    vehicle.customerName.trim(),
    vehicle.customerPhone.trim(),
    _amount(priced.taxable),
    _amount(halfGst),
    _amount(halfGst),
    _amount(total - priced.taxable - priced.tax),
    _amount(total.toDouble()),
  ];
}

String _amount(double value) => value.toStringAsFixed(2);

/// Quotes a cell when it needs it, and defuses one a spreadsheet would run as
/// a formula — anything typed at the counter ends up in here.
String _cell(String value) {
  var text = value;
  if (RegExp(r'^[=@]|^[+\-][^0-9]').hasMatch(text)) text = "'$text";
  if (RegExp(r'[",\r\n]').hasMatch(text)) {
    text = '"${text.replaceAll('"', '""')}"';
  }
  return text;
}
