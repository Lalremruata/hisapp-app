/// The link a UPI QR code carries: any UPI app that scans it opens a payment
/// to [upiId] for [rupees], with the invoice number as the note, so the
/// customer only has to confirm.
///
/// upi://pay?pa=workshop%40upi&pn=LC%20Automobiles&am=2974.00&cu=INR&tn=INV%2F26-27%2F0148
String upiPayUri({
  required String upiId,
  required String payee,
  required int rupees,
  required String note,
}) {
  String encode(String value) => Uri.encodeComponent(value.trim());
  return 'upi://pay'
      '?pa=${encode(upiId)}'
      '&pn=${encode(payee)}'
      '&am=$rupees.00'
      '&cu=INR'
      '&tn=${encode(note)}';
}
