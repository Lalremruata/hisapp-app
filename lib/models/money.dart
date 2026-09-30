/// Rupee formatting, in the Indian grouping the invoice has to print.
library;

/// Groups [value] the way `toLocaleString('en-IN')` does — the last three
/// digits, then pairs (12,34,567.00).
String groupIndian(num value, {int decimals = 2}) {
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals);
  final dot = fixed.indexOf('.');
  var whole = dot == -1 ? fixed : fixed.substring(0, dot);
  final fraction = dot == -1 ? '' : fixed.substring(dot);

  String grouped;
  if (whole.length <= 3) {
    grouped = whole;
  } else {
    final lastThree = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final pairs = <String>[];
    while (rest.length > 2) {
      pairs.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) pairs.insert(0, rest);
    grouped = '${pairs.join(',')},$lastThree';
  }

  return '${negative ? '-' : ''}$grouped$fraction';
}

/// A rupee amount to two decimals, with the sign.
String money(num value) => '₹${groupIndian(value)}';

/// A rupee amount with no paise — the rounded total.
String rupees(num value) => '₹${groupIndian(value, decimals: 0)}';

const _ones = <String>[
  'Zero',
  'One',
  'Two',
  'Three',
  'Four',
  'Five',
  'Six',
  'Seven',
  'Eight',
  'Nine',
  'Ten',
  'Eleven',
  'Twelve',
  'Thirteen',
  'Fourteen',
  'Fifteen',
  'Sixteen',
  'Seventeen',
  'Eighteen',
  'Nineteen',
];

const _tens = <String>[
  '',
  '',
  'Twenty',
  'Thirty',
  'Forty',
  'Fifty',
  'Sixty',
  'Seventy',
  'Eighty',
  'Ninety',
];

String _twoDigits(int v) => v < 20
    ? _ones[v]
    : _tens[v ~/ 10] + (v % 10 != 0 ? ' ${_ones[v % 10]}' : '');

String _hundreds(int v) => v < 100
    ? _twoDigits(v)
    : '${_ones[v ~/ 100]} Hundred${v % 100 != 0 ? ' ${_twoDigits(v % 100)}' : ''}';

/// The amount in words, in crore/lakh/thousand, as a tax invoice must carry it.
String amountInWords(num value) {
  var v = value.round();
  final parts = <String>[];

  if (v >= 10000000) {
    parts.add('${_hundreds(v ~/ 10000000)} Crore');
    v %= 10000000;
  }
  if (v >= 100000) {
    parts.add('${_hundreds(v ~/ 100000)} Lakh');
    v %= 100000;
  }
  if (v >= 1000) {
    parts.add('${_hundreds(v ~/ 1000)} Thousand');
    v %= 1000;
  }
  if (v != 0) parts.add(_hundreds(v));

  return 'Rupees ${parts.isEmpty ? 'Zero' : parts.join(' ')} only';
}
