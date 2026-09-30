import 'catalog.dart';

/// How a line is priced. The one place that knows it, so the bill on the
/// counter and a bill read back off the device cannot drift apart.
///
/// [inclusive] is the workshop's tax mode *for that bill*: when the printed
/// rate already carries GST the tax is backed out of it rather than added on.
({double taxable, double tax}) priceLine(
  CartLine line, {
  required bool inclusive,
}) {
  final gross = line.qty * line.rate;
  final taxable = inclusive ? gross / (1 + line.gst / 100) : gross;
  return (taxable: taxable, tax: taxable * (line.gst / 100));
}

/// What a set of lines comes to, before tax and in tax.
({double taxable, double tax}) priceLines(
  Iterable<CartLine> lines, {
  required bool inclusive,
}) {
  var taxable = 0.0;
  var tax = 0.0;
  for (final line in lines) {
    final priced = priceLine(line, inclusive: inclusive);
    taxable += priced.taxable;
    tax += priced.tax;
  }
  return (taxable: taxable, tax: tax);
}

/// The rupee figure actually charged — the sum, rounded to the rupee.
int payableTotal(Iterable<CartLine> lines, {required bool inclusive}) {
  final priced = priceLines(lines, inclusive: inclusive);
  return (priced.taxable + priced.tax).round();
}
