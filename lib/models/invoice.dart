/// One printed line of a tax invoice, already formatted.
class InvoiceLine {
  const InvoiceLine({
    required this.name,
    required this.code,
    required this.qty,
    required this.rateLabel,
    required this.taxableLabel,
    required this.halfGstLabel,
    required this.halfGstPct,
    required this.grossLabel,
  });

  final String name;

  /// The HSN or SAC, or a dash where the workshop did not know it.
  final String code;

  final int qty;
  final String rateLabel;
  final String taxableLabel;
  final String halfGstLabel;
  final String halfGstPct;
  final String grossLabel;
}

/// Everything a tax invoice prints, worked out once.
///
/// The invoice is rendered twice — on screen in Flutter, and into a PDF for
/// printing and sharing — by two widget systems that cannot share layout code.
/// They share this instead, so the paper and the screen can never disagree
/// about the figures.
class InvoiceData {
  const InvoiceData({
    required this.workshopName,
    required this.workshopAddress,
    required this.workshopPhone,
    required this.gstin,
    required this.placeOfSupply,
    required this.invoiceNo,
    required this.dateLabel,
    required this.customerName,
    required this.customerPhone,
    required this.registration,
    required this.vehicleLine,
    required this.paymentLabel,
    required this.parts,
    required this.labour,
    required this.taxableLabel,
    required this.cgstLabel,
    required this.sgstLabel,
    required this.roundLabel,
    required this.totalLabel,
    required this.totalWords,
    this.bankLines = const [],
    this.upiId = '',
    this.upiUri,
  });

  final String workshopName;
  final String workshopAddress;
  final String workshopPhone;
  final String gstin;

  /// Where the work was done, as GST wants it stated: the state code and name
  /// from the workshop's own GSTIN.
  final String placeOfSupply;

  final String invoiceNo;
  final String dateLabel;

  final String customerName;
  final String customerPhone;

  final String registration;

  /// Make, model and the odometer reading, where they are known.
  final String vehicleLine;

  final String paymentLabel;

  final List<InvoiceLine> parts;
  final List<InvoiceLine> labour;

  final String taxableLabel;
  final String cgstLabel;
  final String sgstLabel;
  final String roundLabel;
  final String totalLabel;
  final String totalWords;

  /// The workshop's bank account, as label and value — only the fields it
  /// has filled in, in the order a bank slip asks for them.
  final List<(String, String)> bankLines;

  final String upiId;

  /// What the QR code carries: a UPI payment for this bill's total. Null when
  /// the workshop has no UPI ID, and then no code is printed.
  final String? upiUri;

  /// Whether the bill says how to pay the workshop at all.
  bool get showsPayment => bankLines.isNotEmpty || upiUri != null;

  /// Whether the invoice is worth naming its two groups of lines. With only
  /// one kind on the bill the bands are noise.
  bool get showsSections => parts.isNotEmpty && labour.isNotEmpty;

  /// A file name that sorts and searches well: INV-26-27-0148.pdf
  String get fileName =>
      '${invoiceNo.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')}.pdf';
}
