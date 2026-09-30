/// What a line on a workshop bill is: a part fitted, or work done.
///
/// GST treats the two differently — goods carry an HSN code, services carry a
/// SAC — so the distinction has to reach the printed invoice.
enum ItemKind {
  part('Part', 'HSN'),
  labour('Labour', 'SAC');

  const ItemKind(this.label, this.codeLabel);

  final String label;

  /// What the code against this line is called on a tax invoice.
  final String codeLabel;
}

/// The SAC for maintenance and repair of motor vehicles, which is what nearly
/// every job in a workshop is billed under.
const motorServiceSac = '998714';

/// One thing the workshop sells: a part off the shelf or an operation off the
/// rate card.
class CatalogItem {
  const CatalogItem({
    required this.name,
    required this.rate,
    required this.gst,
    this.kind = ItemKind.part,
    this.code = '',
    this.stock,
  });

  final String name;

  /// The rate, in rupees — per piece for a part, per job for an operation.
  /// Whether it already carries GST is a setting on the workshop, not on the
  /// item — see [WorkshopSettings.ratesIncludeGst].
  final double rate;

  /// The GST slab, as a whole percentage (5, 12, 18…).
  final int gst;

  final ItemKind kind;

  /// The HSN (parts) or SAC (labour) that has to appear against the line on a
  /// tax invoice. Blank when nobody knew it at the counter.
  final String code;

  /// What the stores has on hand. Null for labour, which is not stocked, and
  /// for a part typed in at the counter that nobody counted.
  final int? stock;

  /// The GST slabs an item can sit in.
  static const slabs = <int>[0, 5, 12, 18, 28];

  String get codeLabel => kind.codeLabel;

  Map<String, Object?> toJson() => {
    'name': name,
    'rate': rate,
    'gst': gst,
    'kind': kind.name,
    'code': code,
    'stock': stock,
  };

  /// Rebuilds an item from storage, tolerating a record written by an older
  /// version: anything missing or of the wrong type falls back rather than
  /// throwing, so one bad row cannot cost the workshop the whole list.
  static CatalogItem? fromJson(Object? json) {
    if (json is! Map) return null;
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) return null;
    final rate = json['rate'];
    if (rate is! num) return null;
    final gst = json['gst'];
    final stock = json['stock'];
    return CatalogItem(
      name: name,
      rate: rate.toDouble(),
      gst: gst is num ? gst.toInt() : 0,
      kind: ItemKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => ItemKind.part,
      ),
      code: json['code'] is String ? json['code'] as String : '',
      stock: stock is num ? stock.toInt() : null,
    );
  }
}

/// The rate card the app ships with.
///
/// This is the starting point, not the whole list — anything typed in at the
/// counter is stored separately and loaded on top, so editing this list later
/// still reaches workshops already running.
const seedCatalog = <CatalogItem>[
  // ── parts ────────────────────────────────────────────────────────────────
  CatalogItem(
    name: 'Engine Oil 5W-30 (3.5 L)',
    rate: 1450,
    gst: 18,
    code: '2710',
    stock: 12,
  ),
  CatalogItem(name: 'Oil Filter', rate: 320, gst: 18, code: '8421', stock: 24),
  CatalogItem(name: 'Air Filter', rate: 450, gst: 18, code: '8421', stock: 18),
  CatalogItem(
    name: 'Brake Pad Set (Front)',
    rate: 1850,
    gst: 28,
    code: '8708',
    stock: 8,
  ),
  CatalogItem(
    name: 'Wiper Blade Pair',
    rate: 640,
    gst: 18,
    code: '8512',
    stock: 15,
  ),
  CatalogItem(
    name: 'Battery 35 Ah',
    rate: 4200,
    gst: 28,
    code: '8507',
    stock: 4,
  ),
  CatalogItem(
    name: 'Spark Plug (set of 4)',
    rate: 880,
    gst: 28,
    code: '8511',
    stock: 10,
  ),
  CatalogItem(name: 'Coolant 1 L', rate: 380, gst: 18, code: '3820', stock: 20),
  CatalogItem(
    name: 'Clutch Plate Set',
    rate: 3900,
    gst: 28,
    code: '8708',
    stock: 3,
  ),
  CatalogItem(
    name: 'Headlamp Bulb H4',
    rate: 240,
    gst: 18,
    code: '8539',
    stock: 30,
  ),

  // ── labour ───────────────────────────────────────────────────────────────
  CatalogItem(
    name: 'Engine oil change',
    rate: 350,
    gst: 18,
    kind: ItemKind.labour,
    code: motorServiceSac,
  ),
  CatalogItem(
    name: 'Wheel balancing (per wheel)',
    rate: 100,
    gst: 18,
    kind: ItemKind.labour,
    code: motorServiceSac,
  ),
  CatalogItem(
    name: 'Wheel alignment',
    rate: 500,
    gst: 18,
    kind: ItemKind.labour,
    code: motorServiceSac,
  ),
  CatalogItem(
    name: 'General service',
    rate: 1200,
    gst: 18,
    kind: ItemKind.labour,
    code: motorServiceSac,
  ),
  CatalogItem(
    name: 'Brake service',
    rate: 600,
    gst: 18,
    kind: ItemKind.labour,
    code: motorServiceSac,
  ),
  CatalogItem(
    name: 'AC service & gas refill',
    rate: 1500,
    gst: 18,
    kind: ItemKind.labour,
    code: motorServiceSac,
  ),
  CatalogItem(
    name: 'Denting & painting (per panel)',
    rate: 2500,
    gst: 18,
    kind: ItemKind.labour,
    code: motorServiceSac,
  ),
  CatalogItem(
    name: 'Clutch overhaul',
    rate: 1800,
    gst: 18,
    kind: ItemKind.labour,
    code: motorServiceSac,
  ),
];

/// The jobs and parts pinned to the keypad screen. Kept on the seed list so
/// the row does not shift under the mechanic's thumb as the rate card grows.
const favouriteIndices = <int>[10, 13, 11, 12, 0, 1];

List<CatalogItem> get favourites => [
  for (final i in favouriteIndices) seedCatalog[i],
];

/// A catalog item at a quantity, on a bill.
class CartLine {
  CartLine({
    required this.name,
    required this.rate,
    required this.gst,
    required this.kind,
    required this.code,
    required this.qty,
  });

  CartLine.from(CatalogItem item, {required this.qty, double? rate})
    : name = item.name,
      rate = rate ?? item.rate,
      gst = item.gst,
      kind = item.kind,
      code = item.code;

  final String name;
  final double rate;
  final int gst;
  final ItemKind kind;
  final String code;
  int qty;

  CartLine copy() => CartLine(
    name: name,
    rate: rate,
    gst: gst,
    kind: kind,
    code: code,
    qty: qty,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'rate': rate,
    'gst': gst,
    'kind': kind.name,
    'code': code,
    'qty': qty,
  };

  static CartLine? fromJson(Object? json) {
    if (json is! Map) return null;
    final name = json['name'];
    final rate = json['rate'];
    final qty = json['qty'];
    if (name is! String || name.trim().isEmpty) return null;
    if (rate is! num || qty is! num) return null;
    return CartLine(
      name: name,
      rate: rate.toDouble(),
      gst: json['gst'] is num ? (json['gst'] as num).toInt() : 0,
      kind: ItemKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => ItemKind.part,
      ),
      code: json['code'] is String ? json['code'] as String : '',
      qty: qty.toInt() < 1 ? 1 : qty.toInt(),
    );
  }
}
