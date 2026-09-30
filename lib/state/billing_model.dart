import 'package:flutter/widgets.dart';

import '../models/bill.dart';
import '../models/catalog.dart';
import '../models/invoice.dart';
import '../models/money.dart';
import '../models/pricing.dart';
import '../models/upi.dart';
import '../models/vehicle.dart';
import 'backup.dart';
import 'bill_store.dart';
import 'item_store.dart';
import 'settings_store.dart';

/// Which of the two draft boxes the keypad is typing into.
enum KeypadTarget { quantity, rate }

/// The workshop's own details — set once, printed on every invoice.
class WorkshopSettings {
  const WorkshopSettings({
    this.name = 'LC Automobiles',
    this.gstin = '23ABCDE1234F1Z5',
    this.address = 'Ngaizel Road, Saikhamakawn, Aizawl, Mizoram 796001',
    this.phone = '0731 4901 220',
    this.invoicePrefix = 'INV/26-27/',
    this.ratesIncludeGst = true,
    this.worksOffline = true,
    this.accountName = '',
    this.bankName = '',
    this.accountNo = '',
    this.bankBranch = '',
    this.ifsc = '',
    this.branchCode = '',
    this.micr = '',
    this.upiId = '',
  });

  final String name;
  final String gstin;
  final String address;
  final String phone;
  final String invoicePrefix;

  /// When the printed rates already carry GST, the tax is backed out of the
  /// line rather than added on top.
  final bool ratesIncludeGst;

  final bool worksOffline;

  // Where a customer pays the workshop. Printed under the amount in words;
  // a blank field is left off the bill.
  final String accountName;
  final String bankName;
  final String accountNo;
  final String bankBranch;
  final String ifsc;
  final String branchCode;
  final String micr;

  /// The UPI ID the bill's QR code pays, like workshop@upi. Blank prints no
  /// code.
  final String upiId;

  WorkshopSettings copyWith({
    String? name,
    String? gstin,
    String? address,
    String? phone,
    String? invoicePrefix,
    bool? ratesIncludeGst,
    bool? worksOffline,
    String? accountName,
    String? bankName,
    String? accountNo,
    String? bankBranch,
    String? ifsc,
    String? branchCode,
    String? micr,
    String? upiId,
  }) => WorkshopSettings(
    name: name ?? this.name,
    gstin: gstin ?? this.gstin,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    invoicePrefix: invoicePrefix ?? this.invoicePrefix,
    ratesIncludeGst: ratesIncludeGst ?? this.ratesIncludeGst,
    worksOffline: worksOffline ?? this.worksOffline,
    accountName: accountName ?? this.accountName,
    bankName: bankName ?? this.bankName,
    accountNo: accountNo ?? this.accountNo,
    bankBranch: bankBranch ?? this.bankBranch,
    ifsc: ifsc ?? this.ifsc,
    branchCode: branchCode ?? this.branchCode,
    micr: micr ?? this.micr,
    upiId: upiId ?? this.upiId,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'gstin': gstin,
    'address': address,
    'phone': phone,
    'invoicePrefix': invoicePrefix,
    'ratesIncludeGst': ratesIncludeGst,
    'worksOffline': worksOffline,
    'accountName': accountName,
    'bankName': bankName,
    'accountNo': accountNo,
    'bankBranch': bankBranch,
    'ifsc': ifsc,
    'branchCode': branchCode,
    'micr': micr,
    'upiId': upiId,
  };

  /// Reads back what [toJson] wrote. A field that is missing or of the wrong
  /// type keeps its default, so a record from an older build still loads.
  factory WorkshopSettings.fromJson(Map<String, dynamic> json) {
    const fallback = WorkshopSettings();
    String text(String key, String otherwise) =>
        json[key] is String ? json[key] as String : otherwise;
    bool flag(String key, bool otherwise) =>
        json[key] is bool ? json[key] as bool : otherwise;
    return WorkshopSettings(
      name: text('name', fallback.name),
      gstin: text('gstin', fallback.gstin),
      address: text('address', fallback.address),
      phone: text('phone', fallback.phone),
      invoicePrefix: text('invoicePrefix', fallback.invoicePrefix),
      ratesIncludeGst: flag('ratesIncludeGst', fallback.ratesIncludeGst),
      worksOffline: flag('worksOffline', fallback.worksOffline),
      accountName: text('accountName', fallback.accountName),
      bankName: text('bankName', fallback.bankName),
      accountNo: text('accountNo', fallback.accountNo),
      bankBranch: text('bankBranch', fallback.bankBranch),
      ifsc: text('ifsc', fallback.ifsc),
      branchCode: text('branchCode', fallback.branchCode),
      micr: text('micr', fallback.micr),
      upiId: text('upiId', fallback.upiId),
    );
  }

  /// A GSTIN is 15 characters: 2 state digits, a 10-character PAN, an entity
  /// digit, a literal Z, and a check character.
  static final _gstinPattern = RegExp(
    r'^\d{2}[A-Z]{5}\d{4}[A-Z]\d[A-Z][0-9A-Z]$',
  );

  bool get gstinLooksValid => _gstinPattern.hasMatch(gstin.toUpperCase());

  /// A UPI ID is a handle, an @, and the bank or app it lives with.
  static final _upiPattern = RegExp(r'^[A-Za-z0-9._-]{2,}@[A-Za-z0-9]{2,}$');

  bool get upiIdLooksValid => _upiPattern.hasMatch(upiId.trim());

  /// The first two digits of a GSTIN are the state it was issued in, which is
  /// also the place of supply for work done on the premises. Derived rather
  /// than typed, so the invoice cannot claim one state in the GSTIN and
  /// another under "place of supply".
  String get stateCode =>
      gstin.trim().length >= 2 ? gstin.trim().substring(0, 2) : '';

  String? get stateName => gstStates[stateCode];

  /// "23 — Madhya Pradesh", or just the code when it is not one we know.
  String get placeOfSupply {
    if (stateCode.isEmpty) return '—';
    final name = stateName;
    return name == null ? stateCode : '$stateCode — $name';
  }
}

/// The GST state codes, as they appear at the front of every GSTIN.
const gstStates = <String, String>{
  '01': 'Jammu & Kashmir',
  '02': 'Himachal Pradesh',
  '03': 'Punjab',
  '04': 'Chandigarh',
  '05': 'Uttarakhand',
  '06': 'Haryana',
  '07': 'Delhi',
  '08': 'Rajasthan',
  '09': 'Uttar Pradesh',
  '10': 'Bihar',
  '11': 'Sikkim',
  '12': 'Arunachal Pradesh',
  '13': 'Nagaland',
  '14': 'Manipur',
  '15': 'Mizoram',
  '16': 'Tripura',
  '17': 'Meghalaya',
  '18': 'Assam',
  '19': 'West Bengal',
  '20': 'Jharkhand',
  '21': 'Odisha',
  '22': 'Chhattisgarh',
  '23': 'Madhya Pradesh',
  '24': 'Gujarat',
  '26': 'Dadra & Nagar Haveli and Daman & Diu',
  '27': 'Maharashtra',
  '29': 'Karnataka',
  '30': 'Goa',
  '31': 'Lakshadweep',
  '32': 'Kerala',
  '33': 'Tamil Nadu',
  '34': 'Puducherry',
  '35': 'Andaman & Nicobar Islands',
  '36': 'Telangana',
  '37': 'Andhra Pradesh',
  '38': 'Ladakh',
  '97': 'Other Territory',
};

/// One priced line, ready to render — the Dart counterpart of the design's
/// `lines[]`.
class BillLine {
  const BillLine({
    required this.index,
    required this.name,
    required this.kind,
    required this.code,
    required this.qty,
    required this.rate,
    required this.gst,
    required this.taxable,
    required this.tax,
  });

  final int index;
  final String name;
  final ItemKind kind;

  /// The HSN or SAC printed against this line — which of the two it is comes
  /// from [kind].
  final String code;

  final int qty;
  final double rate;
  final int gst;

  /// The line's value before tax — what the invoice's "Taxable" column shows.
  final double taxable;

  /// CGST and SGST together for this line.
  final double tax;

  double get gross => taxable + tax;

  String get codeLabel => kind.codeLabel;

  String get rateLabel => money(rate);
  String get gstLabel => '$gst%';
  String get amountLabel => money(taxable);
  String get grossLabel => money(gross);

  /// Half the tax — one of CGST or SGST, which split the slab evenly on an
  /// intra-state supply.
  String get halfGstLabel => money(tax / 2);
  String get halfGstPct => gst.isEven ? '${gst ~/ 2}%' : '${gst / 2}%';
}

/// The one bill every screen in the design reads from and writes to.
///
/// The tablet layouts, the phone layout and the printed invoice are five views
/// onto this single object, exactly as the artboards are five renderings of one
/// component's state.
class BillingModel extends ChangeNotifier {
  BillingModel({
    ItemStore? store,
    BillStore? bills,
    SettingsStore? settings,
    RestorePointStore? restorePoints,
  }) : _store = store ?? InMemoryItemStore(),
       _billStore = bills ?? InMemoryBillStore(),
       _settingsStore = settings ?? InMemorySettingsStore(),
       _restorePoints = restorePoints ?? InMemoryRestorePointStore();

  final ItemStore _store;
  final BillStore _billStore;
  final SettingsStore _settingsStore;
  final RestorePointStore _restorePoints;

  /// Whether the data from before the last import is still kept, so the
  /// import can be undone.
  bool _hasRestorePoint = false;

  /// The bill on the counter. The app opens on a blank one.
  final List<CartLine> _cart = [];

  /// The rate card as the workshop sees it: the shipped list with its own
  /// edits and removals applied, then whatever it has typed in since.
  final List<CatalogItem> _items = [...seedCatalog];

  /// The workshop's difference from the shipped list.
  final List<CatalogItem> _custom = [];
  final Map<String, CatalogItem> _overrides = {};
  final Set<String> _hidden = {};

  WorkshopSettings _settings = const WorkshopSettings();

  /// The car on the ramp, filled in for each job.
  VehicleDetails _vehicle = const VehicleDetails();

  /// The bill on the counter: its identity once saved, and where it stands.
  String? _billId;
  String? _billNumber;
  BillStatus _status = BillStatus.held;
  PaymentMethod? _payment;
  DateTime _billDate = DateTime.now();

  /// The tax mode this bill was raised under, once it has one. Null for a
  /// bill not yet saved, which follows the workshop's setting.
  bool? _billRatesIncludeGst;

  /// Every bill saved so far, oldest first, and the next number to hand out.
  final List<SavedBill> _bills = [];
  int _nextNumber = 148;

  String _query = '';

  /// The line the last add landed on — a new one, or one it merged into — and
  /// a count that moves on every add, so a screen can bring it into view even
  /// when the same line is added to twice running.
  CartLine? _lastAdded;
  int _addSerial = 0;

  /// The keypad opens on the first common job, and its boxes agree with it.
  CatalogItem _draft = seedCatalog[favouriteIndices.first];
  String _qtyText = '1';
  String _rateText = '350';
  KeypadTarget _target = KeypadTarget.quantity;

  // ── reads ────────────────────────────────────────────────────────────────

  /// The workshop's details as it saved them — never altered by the bill on
  /// the counter.
  WorkshopSettings get settings => _settings;

  /// Whether the rates on the bill on the counter already carry GST: the mode
  /// it was saved under, or the workshop's setting for a bill not saved yet.
  bool get ratesIncludeGst => _billRatesIncludeGst ?? _settings.ratesIncludeGst;
  VehicleDetails get vehicle => _vehicle;
  String get query => _query;

  /// Where on the bill the last add went, or null once that line has gone.
  int? get lastAddedIndex {
    final line = _lastAdded;
    if (line == null) return null;
    final index = _cart.indexWhere((candidate) => identical(candidate, line));
    return index < 0 ? null : index;
  }

  int get addSerial => _addSerial;

  /// Everything the shop can sell, in the order it was added.
  List<CatalogItem> get items => List.unmodifiable(_items);

  /// Just the hand-entered items.
  List<CatalogItem> get customItems => List.unmodifiable(_custom);

  /// Shipped items the workshop has taken off its rate card. Shown so a
  /// removal can be undone.
  List<CatalogItem> get removedItems => [
    for (final item in seedCatalog)
      if (_hidden.contains(item.name)) item,
  ];

  /// Whether [item] came off the shipped list rather than being typed in.
  bool isShipped(CatalogItem item) =>
      seedCatalog.any((seed) => seed.name == item.name);

  /// Whether the workshop has changed this shipped item's price or codes.
  bool isEdited(CatalogItem item) => _overrides.containsKey(item.name);
  CatalogItem get draft => _draft;
  String get qtyText => _qtyText;
  String get rateText => _rateText;
  KeypadTarget get target => _target;

  /// This bill's number once it has been saved, or the number it will take.
  String get invoiceNo =>
      _billNumber ?? '${_settings.invoicePrefix}${_padded(_nextNumber)}';

  static String _padded(int number) => number.toString().padLeft(4, '0');

  /// Whether this bill has been saved at all.
  bool get isSaved => _billId != null;

  BillStatus get status => _status;
  PaymentMethod? get payment => _payment;
  bool get isPaid => _status == BillStatus.paid;

  /// The saved bills, newest first — the order a workshop looks for them in.
  List<SavedBill> get bills => List.unmodifiable(_bills.reversed);

  /// Bills with money still to come in: held, or settled as due.
  List<SavedBill> get outstandingBills => [
    for (final bill in bills)
      if (bill.isOutstanding) bill,
  ];

  /// The day this bill was raised.
  DateTime get invoiceDate => _billDate;

  String get invoiceDateLabel => dateLabel(invoiceDate);

  /// A day as the invoice prints it: "16 Sep 2026".
  static String dateLabel(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  List<BillLine> get lines {
    final inclusive = ratesIncludeGst;
    return [
      for (var i = 0; i < _cart.length; i++)
        () {
          final line = _cart[i];
          final priced = priceLine(line, inclusive: inclusive);
          return BillLine(
            index: i,
            name: line.name,
            kind: line.kind,
            code: line.code,
            qty: line.qty,
            rate: line.rate,
            gst: line.gst,
            taxable: priced.taxable,
            tax: priced.tax,
          );
        }(),
    ];
  }

  /// Everything the tax invoice prints, for the screen and for the PDF.
  InvoiceData get invoiceData {
    InvoiceLine printed(BillLine line) => InvoiceLine(
      name: line.name,
      // A hand-entered item may have no code; a dash keeps the column
      // reading as a column.
      code: line.code.isEmpty ? '\u2014' : line.code,
      qty: line.qty,
      rateLabel: line.rateLabel,
      taxableLabel: line.amountLabel,
      halfGstLabel: line.halfGstLabel,
      halfGstPct: line.halfGstPct,
      grossLabel: line.grossLabel,
    );

    return InvoiceData(
      workshopName: _settings.name,
      workshopAddress: _settings.address,
      workshopPhone: _settings.phone,
      gstin: _settings.gstin,
      placeOfSupply: _settings.placeOfSupply,
      invoiceNo: invoiceNo,
      dateLabel: invoiceDateLabel,
      customerName: _vehicle.customerName.trim().isEmpty
          ? '\u2014'
          : _vehicle.customerName.trim(),
      customerPhone: _vehicle.customerPhone.trim(),
      registration: _vehicle.registration.trim().isEmpty
          ? '\u2014'
          : _vehicle.registration.trim().toUpperCase(),
      vehicleLine: [
        if (_vehicle.makeModel.trim().isNotEmpty) _vehicle.makeModel.trim(),
        if (_vehicle.odometerLabel.isNotEmpty) _vehicle.odometerLabel,
      ].join(' \u00b7 '),
      paymentLabel: switch ((isPaid, _payment)) {
        (true, PaymentMethod.due) => 'On account \u00b7 due',
        (true, final method?) => '${method.label} \u00b7 settled',
        _ => 'Not yet paid',
      },
      parts: [for (final line in partLines) printed(line)],
      labour: [for (final line in labourLines) printed(line)],
      taxableLabel: taxableLabel,
      cgstLabel: cgstLabel,
      sgstLabel: sgstLabel,
      roundLabel: roundLabel,
      totalLabel: totalLabel,
      totalWords: totalWords,
      bankLines: [
        for (final (label, value) in [
          ('Account name', _settings.accountName),
          ('Bank', _settings.bankName),
          ('A/c no.', _settings.accountNo),
          ('Branch', _settings.bankBranch),
          ('IFSC', _settings.ifsc.toUpperCase()),
          ('Branch code', _settings.branchCode),
          ('MICR', _settings.micr),
        ])
          if (value.trim().isNotEmpty) (label, value.trim()),
      ],
      upiId: _settings.upiId.trim(),
      upiUri: _settings.upiId.trim().isEmpty
          ? null
          : upiPayUri(
              upiId: _settings.upiId,
              payee: _settings.accountName.trim().isEmpty
                  ? _settings.name
                  : _settings.accountName,
              rupees: total,
              note: invoiceNo,
            ),
    );
  }

  /// What a saved bill came to, priced under the tax mode it was raised with
  /// rather than whatever the workshop uses today.
  int totalOf(SavedBill bill) =>
      payableTotal(bill.lines, inclusive: bill.ratesIncludeGst);

  /// The number of *pieces* on the bill, not the number of lines — what the
  /// design counts.
  int get lineCount => _cart.fold(0, (sum, line) => sum + line.qty);

  /// The bill split the way a workshop invoice prints it: parts fitted, then
  /// work done.
  List<BillLine> get partLines => [
    for (final line in lines)
      if (line.kind == ItemKind.part) line,
  ];

  List<BillLine> get labourLines => [
    for (final line in lines)
      if (line.kind == ItemKind.labour) line,
  ];

  /// What the parts came to, before tax — a figure the owner always asks for.
  double get partsTotal => partLines.fold(0, (sum, line) => sum + line.taxable);

  double get labourTotal =>
      labourLines.fold(0, (sum, line) => sum + line.taxable);

  double get taxable => lines.fold(0, (sum, line) => sum + line.taxable);
  double get gstTotal => lines.fold(0, (sum, line) => sum + line.tax);

  double get cgst => gstTotal / 2;
  double get sgst => gstTotal / 2;

  /// The untouched sum, before the bill is rounded to the rupee.
  double get rawTotal => taxable + gstTotal;

  int get total => rawTotal.round();

  double get roundOff => total - rawTotal;

  String get taxableLabel => money(taxable);
  String get cgstLabel => money(cgst);
  String get sgstLabel => money(sgst);
  String get gstTotalLabel => money(gstTotal);
  String get totalLabel => rupees(total);
  String get totalWords => amountInWords(total);

  /// The round-off, signed and without the rupee mark — `+0.40`, `−0.25`.
  String get roundLabel {
    final sign = roundOff >= 0 ? '+' : '−';
    return '$sign${groupIndian(roundOff.abs())}';
  }

  /// Up to five catalog matches for what has been typed. Empty until the
  /// search box has something in it.
  List<CatalogItem> get suggestions {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _items
        .where((item) => item.name.toLowerCase().contains(q))
        .take(5)
        .toList();
  }

  /// Whether the list under the search box is open at all. Anything typed
  /// opens it: with matches it offers them, and without it offers to create
  /// what was typed.
  bool get showSuggestions => _query.trim().isNotEmpty;

  /// Nothing in the master matches, so the only thing on offer is creating it.
  bool get hasNoMatches => showSuggestions && suggestions.isEmpty;

  // ── the keypad draft ─────────────────────────────────────────────────────

  /// At least one — an empty, zero or unparseable box still adds a single
  /// piece, so the Add button is never a no-op.
  int get draftQty {
    final parsed = int.tryParse(_qtyText) ?? double.tryParse(_qtyText)?.floor();
    if (parsed == null || parsed < 1) return 1;
    return parsed;
  }

  double get draftRate => double.tryParse(_rateText) ?? 0;

  /// What the "Add" button charges: the draft at its typed quantity and rate,
  /// with GST added on unless the rate already includes it.
  double get draftTotal =>
      draftQty * draftRate * (ratesIncludeGst ? 1 : 1 + _draft.gst / 100);

  // ── writes ───────────────────────────────────────────────────────────────

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  /// Takes the workshop's details and keeps them on the device, so the next
  /// start prints the same name, GSTIN, address and phone.
  void updateSettings(WorkshopSettings value) {
    _settings = value;
    _settingsStore.save(value.toJson()).catchError((Object _) {});
    notifyListeners();
  }

  void updateVehicle(VehicleDetails value) {
    _vehicle = value;
    _touch();
  }

  /// Dates the bill to [day] — back to the day the work was done, when it is
  /// written up late. Never forward: a tax invoice cannot be dated after the
  /// day it is issued, so a future day is taken as today.
  void updateInvoiceDate(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = DateTime(day.year, day.month, day.day);
    final date = picked.isAfter(today) ? today : picked;
    // The time of day is kept, so bills raised on one day still read in the
    // order they were written.
    _billDate = DateTime(
      date.year,
      date.month,
      date.day,
      _billDate.hour,
      _billDate.minute,
      _billDate.second,
    );
    _touch();
  }

  /// Keeps a bill that has already been saved in step with what is on the
  /// counter, so an edit is never lost by navigating away.
  void _touch() {
    if (isSaved) {
      saveBill();
    } else {
      notifyListeners();
    }
  }

  /// Reads the workshop's rate card back off the device. Called once at
  /// startup, before the first frame, so nothing can be added on top of a list
  /// that is still loading.
  Future<void> loadItems() async {
    try {
      final stored = await _store.load();
      if (stored.isEmpty) return;
      _custom
        ..clear()
        ..addAll(stored.custom);
      _overrides
        ..clear()
        ..addAll(stored.overrides);
      _hidden
        ..clear()
        ..addAll(stored.hidden);
      _rebuild();
    } catch (_) {
      // A rate card that will not load is not a reason to refuse to bill: the
      // workshop falls back to the shipped list and can type items in again.
    }
  }

  /// Reads the workshop's details back off the device. Called at startup,
  /// before the first frame, so the first invoice already carries them.
  Future<void> loadSettings() async {
    try {
      final stored = await _settingsStore.load();
      if (stored == null) return;
      _settings = WorkshopSettings.fromJson(stored);
      notifyListeners();
    } catch (_) {
      // Details that will not load are not a reason to refuse to bill: the
      // workshop is back on the defaults and can type them in again.
    }
  }

  /// Reads the saved bills back off the device, alongside the rate card.
  Future<void> loadBills() async {
    try {
      final archive = await _billStore.load();
      if (archive.isEmpty) return;
      _bills
        ..clear()
        ..addAll(archive.bills);
      _nextNumber = archive.nextNumber;
      notifyListeners();
    } catch (_) {
      // A history that will not load is not a reason to refuse to bill.
    }
  }

  // ── the bill's life ──────────────────────────────────────────────────────

  /// Saves the bill on the counter, giving it a number the first time.
  ///
  /// Returns the saved bill. Saving again updates the same record rather than
  /// adding another, so a bill reopened and corrected stays one bill with one
  /// number.
  SavedBill saveBill({BillStatus? status, PaymentMethod? payment}) {
    _billId ??= 'bill-${DateTime.now().microsecondsSinceEpoch}';
    if (_billNumber == null) {
      _billNumber = '${_settings.invoicePrefix}${_padded(_nextNumber)}';
      _nextNumber++;
    }
    if (status != null) _status = status;
    if (payment != null) _payment = payment;
    // Saved once, the bill keeps its tax mode even if the workshop later
    // switches, so its figures never move under it.
    _billRatesIncludeGst ??= _settings.ratesIncludeGst;

    final bill = SavedBill(
      id: _billId!,
      invoiceNo: _billNumber!,
      date: _billDate,
      vehicle: _vehicle,
      lines: [for (final line in _cart) line.copy()],
      status: _status,
      ratesIncludeGst: ratesIncludeGst,
      payment: _payment,
    );

    final at = _bills.indexWhere((candidate) => candidate.id == bill.id);
    if (at >= 0) {
      _bills[at] = bill;
    } else {
      _bills.add(bill);
    }

    _billStore
        .saveBill(bill, nextNumber: _nextNumber)
        .catchError((Object _) {});
    notifyListeners();
    return bill;
  }

  /// Parks the bill and clears the counter for the next vehicle.
  void holdBill() {
    if (_cart.isEmpty && !isSaved) return;
    saveBill(status: BillStatus.held);
    newBill();
  }

  /// Settles the bill. It stays on the counter so it can be printed straight
  /// away; [newBill] clears it when the next vehicle rolls in.
  SavedBill settleBill(PaymentMethod method) =>
      saveBill(status: BillStatus.paid, payment: method);

  /// Clears the counter. Anything unsaved on it is parked first, so a bill
  /// cannot be lost by starting the next one.
  void newBill() {
    if (_cart.isNotEmpty && !isSaved) saveBill(status: BillStatus.held);

    _cart.clear();
    _vehicle = const VehicleDetails();
    _billId = null;
    _billNumber = null;
    _status = BillStatus.held;
    _payment = null;
    _billDate = DateTime.now();
    _billRatesIncludeGst = null;
    _query = '';
    _lastAdded = null;
    notifyListeners();
  }

  /// Puts a saved bill back on the counter, to be corrected or reprinted.
  ///
  /// Whatever was on the counter is parked first, for the same reason.
  void openBill(SavedBill bill) {
    if (_cart.isNotEmpty && (!isSaved || _billId != bill.id)) {
      if (!isSaved) {
        saveBill(status: BillStatus.held);
      }
    }

    _cart
      ..clear()
      ..addAll([for (final line in bill.lines) line.copy()]);
    _vehicle = bill.vehicle;
    _billId = bill.id;
    _billNumber = bill.invoiceNo;
    _status = bill.status;
    _payment = bill.payment;
    _billDate = bill.date;
    // The bill keeps the tax mode it was raised under, so reopening one from
    // before the workshop switched does not silently reprice it. The
    // workshop's own setting is left alone.
    _billRatesIncludeGst = bill.ratesIncludeGst;
    _query = '';
    _lastAdded = null;
    notifyListeners();
  }

  /// Takes a bill out of the archive for good.
  void deleteBill(SavedBill bill) {
    _bills.removeWhere((candidate) => candidate.id == bill.id);
    if (_billId == bill.id) {
      _billId = null;
      _billNumber = null;
    }
    _billStore.deleteBill(bill.id).catchError((Object _) {});
    notifyListeners();
  }

  // ── backup and restore ───────────────────────────────────────────────────

  /// Everything the workshop keeps, as one backup.
  Backup backup() => Backup(
    exportedAt: DateTime.now(),
    settings: _settings,
    bills: List.of(_bills),
    nextNumber: _nextNumber,
    items: ItemMasterData(
      custom: List.of(_custom),
      overrides: Map.of(_overrides),
      hidden: Set.of(_hidden),
    ),
  );

  bool get hasRestorePoint => _hasRestorePoint;

  /// Finds out whether an import can still be undone. Called at startup.
  Future<void> loadRestorePoint() async {
    try {
      _hasRestorePoint = await _restorePoints.read() != null;
      notifyListeners();
    } catch (_) {
      // Without it the undo button stays hidden; billing is unaffected.
    }
  }

  /// Brings [incoming] onto the device, by [mode].
  ///
  /// The device's data from just before is kept first, so [undoRestore] can
  /// put it back. Unlike the counter's saves this waits for the writes and
  /// lets a failure through: the person importing needs to know.
  Future<RestoreReport> restore(Backup incoming, RestoreMode mode) async {
    // Whatever is on the counter is parked, so it is in the restore point
    // and nothing half-typed is left pointing at a bill that is gone.
    newBill();

    final current = backup();
    await _restorePoints.keep(current.encode());
    _hasRestorePoint = true;

    final RestoreReport report;
    final Backup target;
    if (mode == RestoreMode.replace) {
      target = incoming;
      report = RestoreReport(mode: mode, bills: incoming.bills.length);
    } else {
      final merged = current.mergeIn(incoming);
      target = merged.backup;
      report = RestoreReport(
        mode: mode,
        bills: merged.added,
        skipped: merged.skipped,
        clashes: merged.clashes,
      );
    }

    await _write(target);
    return report;
  }

  /// Puts back the data from before the last import.
  Future<void> undoRestore() async {
    final raw = await _restorePoints.read();
    if (raw == null) return;
    newBill();
    await _write(Backup.parse(raw));
    await _restorePoints.clear();
    _hasRestorePoint = false;
    notifyListeners();
  }

  /// Stores [data] in place of everything, then shows it.
  Future<void> _write(Backup data) async {
    final settings = data.settings ?? _settings;
    await _billStore.replaceAll(
      BillArchive(bills: data.bills, nextNumber: data.nextNumber),
    );
    await _store.save(data.items);
    await _settingsStore.save(settings.toJson());

    _settings = settings;
    _bills
      ..clear()
      ..addAll(data.bills);
    _nextNumber = data.nextNumber;
    _custom
      ..clear()
      ..addAll(data.items.custom);
    _overrides
      ..clear()
      ..addAll(data.items.overrides);
    _hidden
      ..clear()
      ..addAll(data.items.hidden);
    _rebuild();
  }

  /// Rebuilds the visible rate card from the shipped list and the workshop's
  /// changes to it, then tells the screens.
  void _rebuild() {
    _items
      ..clear()
      ..addAll([
        for (final item in seedCatalog)
          if (!_hidden.contains(item.name)) _overrides[item.name] ?? item,
        ..._custom,
      ]);
    notifyListeners();
  }

  /// Creates an item the master does not have.
  ///
  /// Returns the item already on file when the name is a match, so the list
  /// cannot grow two entries for one product. With [remember] the item joins
  /// the master and is stored; without it the item is for this bill only.
  CatalogItem createItem({
    required String name,
    required double rate,
    required int gst,
    ItemKind kind = ItemKind.part,
    String code = '',
    bool remember = true,
  }) {
    final trimmed = name.trim();
    final existing = _items.indexWhere(
      (item) => item.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (existing >= 0) return _items[existing];

    final item = CatalogItem(
      name: trimmed,
      rate: rate,
      gst: gst,
      kind: kind,
      code: code.trim(),
    );
    if (remember) {
      _custom.add(item);
      _persist();
      _rebuild();
    }
    return item;
  }

  /// Replaces [original] with [updated] on the rate card.
  ///
  /// Editing a shipped item is kept as a difference from the shipped list, so
  /// only what the workshop actually changed is stored. Renaming a shipped
  /// item takes it off the list and adds the new one in its place — which is
  /// what a rename looks like from the outside.
  ///
  /// Lines already on a bill are untouched: a [CartLine] copies what it needs
  /// when it is added, so repricing the rate card never silently rewrites a
  /// bill in progress.
  void updateItem(CatalogItem original, CatalogItem updated) {
    final renamed =
        original.name.trim().toLowerCase() != updated.name.trim().toLowerCase();

    if (isShipped(original)) {
      if (renamed) {
        _hidden.add(original.name);
        _overrides.remove(original.name);
        _custom.add(updated);
      } else {
        _overrides[original.name] = updated;
      }
    } else {
      final at = _custom.indexWhere((item) => item.name == original.name);
      if (at < 0) return;
      _custom[at] = updated;
    }

    _persist();
    _rebuild();
  }

  /// Takes [item] off the rate card. A shipped item is hidden rather than
  /// forgotten, so [restoreItem] can put it back.
  void deleteItem(CatalogItem item) {
    if (isShipped(item)) {
      _hidden.add(item.name);
      _overrides.remove(item.name);
    } else {
      _custom.removeWhere((candidate) => candidate.name == item.name);
    }
    _persist();
    _rebuild();
  }

  /// Puts a shipped item back the way it was shipped, undoing an edit, a
  /// removal, or both.
  void restoreItem(CatalogItem item) {
    _hidden.remove(item.name);
    _overrides.remove(item.name);
    _persist();
    _rebuild();
  }

  /// Writes the workshop's rate card out. The change is already in memory, so
  /// a storage failure costs it tomorrow's convenience, not today's sale — it
  /// must never surface as an error at the counter.
  void _persist() {
    _store
        .save(
          ItemMasterData(
            custom: List.of(_custom),
            overrides: Map.of(_overrides),
            hidden: Set.of(_hidden),
          ),
        )
        .catchError((Object _) {});
  }

  /// Adds [item] to the bill, merging into an existing line when the same
  /// product is already on it at the same rate.
  void addToCart(CatalogItem item, {int qty = 1, double? rate}) {
    final q = qty < 1 ? 1 : qty;
    final effectiveRate = rate ?? item.rate;
    final existing = _cart.indexWhere(
      (line) => line.name == item.name && line.rate == effectiveRate,
    );
    if (existing >= 0) {
      _cart[existing].qty += q;
      _lastAdded = _cart[existing];
    } else {
      _lastAdded = CartLine.from(item, qty: q, rate: effectiveRate);
      _cart.add(_lastAdded!);
    }
    _addSerial++;
    _query = '';
    _touch();
  }

  /// Adds the first suggestion, which is what the "Add to bill" button next to
  /// the search box does.
  void addFirstSuggestion() {
    final matches = suggestions;
    if (matches.isNotEmpty) addToCart(matches.first);
  }

  /// Nudges a line's quantity. Dropping below one takes the line off the bill,
  /// so − doubles as delete — and hands the line back, as [removeAt] does.
  CartLine? bump(int index, int delta) {
    final line = _cart[index];
    final next = line.qty + delta;
    if (next < 1) return removeAt(index);
    line.qty = next;
    _touch();
    return null;
  }

  /// Takes a line off the bill and hands it back, so the screen can offer to
  /// put it straight back with [restoreAt].
  CartLine removeAt(int index) {
    final line = _cart.removeAt(index);
    _touch();
    return line;
  }

  /// Puts a line [removeAt] took off back where it was.
  void restoreAt(int index, CartLine line) {
    _cart.insert(index.clamp(0, _cart.length), line);
    _touch();
  }

  /// Loads a favourite into the draft, ready for the keypad.
  void setDraft(CatalogItem item) {
    _draft = item;
    _rateText = item.rate == item.rate.roundToDouble()
        ? item.rate.toStringAsFixed(0)
        : '${item.rate}';
    _qtyText = '1';
    _target = KeypadTarget.quantity;
    notifyListeners();
  }

  void setTarget(KeypadTarget value) {
    _target = value;
    notifyListeners();
  }

  /// The backspace key. Named because both the model and the keypad that
  /// draws it have to agree on which key this is.
  static const backspaceKey = '⌫';

  /// Handles one keypad press against whichever box is targeted.
  void pressKey(String key) {
    var value = _target == KeypadTarget.quantity ? _qtyText : _rateText;

    switch (key) {
      case backspaceKey:
        value = value.isEmpty ? value : value.substring(0, value.length - 1);
      case 'C':
        value = '';
      case '.':
        // One decimal point only; typing it first gives "0.".
        value = value.contains('.') ? value : '${value.isEmpty ? '0' : value}.';
      default:
        // A lone leading zero is replaced rather than appended to.
        value = (value == '0' ? '' : value) + key;
    }

    if (_target == KeypadTarget.quantity) {
      _qtyText = value;
    } else {
      _rateText = value;
    }
    notifyListeners();
  }

  /// Puts the draft on the bill at its typed quantity and rate.
  void addDraft() {
    addToCart(
      _draft,
      qty: draftQty,
      rate: draftRate > 0 ? draftRate : _draft.rate,
    );
  }

  /// The keypad's layout, in reading order.
  static const keypadKeys = <String>[
    '1',
    '2',
    '3',
    backspaceKey,
    '4',
    '5',
    '6',
    'C',
    '7',
    '8',
    '9',
    '0',
    '.',
    '00',
  ];
}

/// Hands [BillingModel] down the tree and rebuilds dependents when the bill
/// changes — the job `provider` would do, without the dependency.
class BillingScope extends InheritedNotifier<BillingModel> {
  const BillingScope({
    super.key,
    required BillingModel model,
    required super.child,
  }) : super(notifier: model);

  static BillingModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BillingScope>();
    assert(scope != null, 'No BillingScope above this widget');
    return scope!.notifier!;
  }

  /// Reads the model without subscribing — for callbacks that only write.
  static BillingModel read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<BillingScope>();
    assert(scope != null, 'No BillingScope above this widget');
    return scope!.notifier!;
  }
}
