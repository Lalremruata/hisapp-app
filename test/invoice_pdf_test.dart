import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisap_app_2_0/models/bill.dart';
import 'package:hisap_app_2_0/models/catalog.dart';
import 'package:hisap_app_2_0/models/upi.dart';
import 'package:hisap_app_2_0/services/invoice_pdf.dart';
import 'package:hisap_app_2_0/state/billing_model.dart';

import 'support/demo_bill.dart';

/// Reads the sheet count straight out of the document's page tree.
int pageCount(List<int> bytes) {
  final body = latin1.decode(bytes, allowInvalid: true);
  final match = RegExp(
    r'/Type/Pages/Kids\[[^\]]*\]/Count (\d+)',
  ).firstMatch(body);
  if (match == null) throw StateError('no page tree in the document');
  return int.parse(match.group(1)!);
}

const _bank = WorkshopSettings(
  accountName: 'Sample Motor Works',
  bankName: 'State Bank Of India',
  accountNo: '000012345678',
  bankBranch: 'Main Branch',
  ifsc: 'sbin0000001',
  upiId: 'workshop@upi',
);

void main() {
  // buildInvoicePdf loads the bundled fonts through the asset bundle.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InvoiceData', () {
    test('carries the figures the screen shows', () {
      final model = BillingModel().withDemoBill();
      final data = model.invoiceData;

      expect(data.invoiceNo, 'INV/26-27/0148');
      expect(data.workshopName, 'LC Automobiles');
      expect(data.gstin, '23ABCDE1234F1Z5');
      // Derived from the GSTIN, never typed twice.
      expect(data.placeOfSupply, '23 — Madhya Pradesh');
      expect(data.registration, 'MZ 01 AB 1234');
      expect(data.vehicleLine, 'BOLERO · 48,210 km');
      // The demo job has no customer name; the invoice prints a dash.
      expect(data.customerName, '\u2014');
      expect(data.taxableLabel, model.taxableLabel);
      expect(data.totalLabel, '₹2,974');
      expect(
        data.totalWords,
        'Rupees Two Thousand Nine Hundred Seventy Four only',
      );
    });

    test('splits parts from labour, and names the bands only when both', () {
      final model = BillingModel().withDemoBill();
      expect(model.invoiceData.parts, hasLength(2));
      expect(model.invoiceData.labour, hasLength(2));
      expect(model.invoiceData.showsSections, isTrue);
      expect(model.invoiceData.parts.first.code, '2710');
      expect(model.invoiceData.labour.first.code, motorServiceSac);

      // A bill of only parts has nothing to band off.
      final parts = BillingModel().withDemoBill()
        ..removeAt(3)
        ..removeAt(2);
      expect(parts.invoiceData.labour, isEmpty);
      expect(parts.invoiceData.showsSections, isFalse);
    });

    test('prints a dash where a code or a vehicle is missing', () {
      final model = BillingModel().withDemoBill();
      final item = model.createItem(name: 'Sundry charge', rate: 150, gst: 18);
      model.addToCart(item);
      expect(model.invoiceData.parts.last.code, '—');

      model.newBill();
      expect(model.invoiceData.registration, '—');
      expect(model.invoiceData.customerName, '—');
      expect(model.invoiceData.vehicleLine, '');
    });

    test('says how the bill was paid', () {
      final model = BillingModel().withDemoBill();
      expect(model.invoiceData.paymentLabel, 'Not yet paid');

      model.settleBill(PaymentMethod.cash);
      expect(model.invoiceData.paymentLabel, 'Cash · settled');

      model.saveBill(payment: PaymentMethod.due);
      expect(model.invoiceData.paymentLabel, 'On account · due');
    });

    test('prints no payment block until the workshop fills one in', () {
      final data = BillingModel().withDemoBill().invoiceData;
      expect(data.bankLines, isEmpty);
      expect(data.upiUri, isNull);
      expect(data.showsPayment, isFalse);
    });

    test('lists only the bank fields that are filled, in slip order', () {
      final model = BillingModel().withDemoBill()..updateSettings(_bank);
      expect(model.invoiceData.bankLines, [
        ('Account name', 'Sample Motor Works'),
        ('Bank', 'State Bank Of India'),
        ('A/c no.', '000012345678'),
        ('Branch', 'Main Branch'),
        ('IFSC', 'SBIN0000001'),
      ]);
      expect(model.invoiceData.showsPayment, isTrue);
    });

    test('the UPI code asks for this bill\'s total', () {
      final model = BillingModel().withDemoBill()..updateSettings(_bank);
      final uri = Uri.parse(model.invoiceData.upiUri!);
      expect(uri.scheme, 'upi');
      expect(uri.queryParameters['pa'], 'workshop@upi');
      expect(uri.queryParameters['pn'], 'Sample Motor Works');
      expect(uri.queryParameters['am'], '${model.total}.00');
      expect(uri.queryParameters['cu'], 'INR');
      expect(uri.queryParameters['tn'], 'INV/26-27/0148');

      // With no account name, the payee is the workshop.
      model.updateSettings(_bank.copyWith(accountName: ''));
      expect(
        Uri.parse(model.invoiceData.upiUri!).queryParameters['pn'],
        'LC Automobiles',
      );
    });

    test('names the file after the bill, fit for a file system', () {
      final model = BillingModel().withDemoBill();
      expect(model.invoiceData.fileName, 'INV-26-27-0148.pdf');
    });
  });

  group('upiPayUri', () {
    test('encodes what a UPI app has to read back', () {
      expect(
        upiPayUri(
          upiId: ' workshop@upi ',
          payee: 'LC Automobiles',
          rupees: 2974,
          note: 'INV/26-27/0148',
        ),
        'upi://pay?pa=workshop%40upi&pn=LC%20Automobiles&am=2974.00'
        '&cu=INR&tn=INV%2F26-27%2F0148',
      );
    });
  });

  group('buildInvoicePdf', () {
    test('bank details and the UPI code still fit on one sheet', () async {
      final model = BillingModel().withDemoBill()
        ..updateSettings(
          _bank.copyWith(branchCode: '12345', micr: '110002001'),
        );
      final bytes = await buildInvoicePdf(model.invoiceData);
      expect(pageCount(bytes), 1);
    });

    test('produces a real, single-page PDF', () async {
      final bytes = await buildInvoicePdf(
        BillingModel().withDemoBill().invoiceData,
      );

      expect(bytes.length, greaterThan(1000));
      expect(
        utf8.decode(bytes.take(5).toList()),
        '%PDF-',
        reason: 'the file header',
      );

      // One sheet: an invoice of four lines must not spill onto a second.
      expect(pageCount(bytes), 1);
    });

    test(
      'embeds the fonts rather than relying on the reader having them',
      () async {
        final bytes = await buildInvoicePdf(
          BillingModel().withDemoBill().invoiceData,
        );
        final body = latin1.decode(bytes, allowInvalid: true);

        // A subset of Inter goes in the file, which is what lets the rupee sign
        // print on a machine that has never heard of Inter.
        expect(body, contains('FontFile2'));
        expect(body, contains('Inter'));
      },
    );

    test('a bill of only parts still builds', () async {
      final model = BillingModel().withDemoBill()
        ..removeAt(3)
        ..removeAt(2);
      final bytes = await buildInvoicePdf(model.invoiceData);
      expect(bytes.length, greaterThan(1000));
    });

    test('an empty bill still builds rather than throwing', () async {
      final model = BillingModel()..newBill();
      final bytes = await buildInvoicePdf(model.invoiceData);
      expect(bytes.length, greaterThan(1000));
    });

    test('a long bill flows onto more sheets instead of clipping', () async {
      final model = BillingModel().withDemoBill();
      // Every part and job on one invoice — a genuine rebuild runs this long.
      for (final item in seedCatalog) {
        model.addToCart(item, qty: 2);
      }
      expect(model.lines.length, greaterThan(16));

      final bytes = await buildInvoicePdf(model.invoiceData);
      expect(
        pageCount(bytes),
        greaterThan(1),
        reason: 'it must carry on overleaf, not throw or clip',
      );
    });
  });
}
