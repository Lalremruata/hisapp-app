import '../models/catalog.dart';

/// Everything the workshop has changed about its rate card.
///
/// The shipped [seedCatalog] is never stored. What is stored is the difference
/// from it, so a later correction to a shipped part still reaches a workshop
/// that never touched that part.
class ItemMasterData {
  const ItemMasterData({
    this.custom = const [],
    this.overrides = const {},
    this.hidden = const {},
  });

  /// Items typed in at the counter, in the order they were added.
  final List<CatalogItem> custom;

  /// Shipped items the workshop has repriced, keyed by the shipped name.
  final Map<String, CatalogItem> overrides;

  /// Shipped items the workshop has taken off its rate card, by name. Kept
  /// rather than forgotten, so removing one can be undone.
  final Set<String> hidden;

  bool get isEmpty => custom.isEmpty && overrides.isEmpty && hidden.isEmpty;

  Map<String, Object?> toJson() => {
    'custom': [for (final item in custom) item.toJson()],
    'overrides': {
      for (final entry in overrides.entries) entry.key: entry.value.toJson(),
    },
    'hidden': hidden.toList(),
  };

  /// Rebuilds from storage, dropping anything it cannot read rather than
  /// throwing — one bad record must not cost the workshop its whole rate card.
  static ItemMasterData fromJson(Object? json) {
    if (json is! Map) return const ItemMasterData();

    final custom = <CatalogItem>[];
    final rawCustom = json['custom'];
    if (rawCustom is List) {
      for (final entry in rawCustom) {
        final item = CatalogItem.fromJson(entry);
        if (item != null) custom.add(item);
      }
    }

    final overrides = <String, CatalogItem>{};
    final rawOverrides = json['overrides'];
    if (rawOverrides is Map) {
      for (final entry in rawOverrides.entries) {
        final key = entry.key;
        final item = CatalogItem.fromJson(entry.value);
        if (key is String && item != null) overrides[key] = item;
      }
    }

    final hidden = <String>{};
    final rawHidden = json['hidden'];
    if (rawHidden is List) {
      for (final entry in rawHidden) {
        if (entry is String) hidden.add(entry);
      }
    }

    return ItemMasterData(custom: custom, overrides: overrides, hidden: hidden);
  }
}

/// Where the workshop's changes to its rate card are kept between sessions.
abstract interface class ItemStore {
  Future<ItemMasterData> load();

  Future<void> save(ItemMasterData data);
}

/// A store that forgets when the process does. The default, so a test can
/// build a [BillingModel] without standing up a platform channel.
class InMemoryItemStore implements ItemStore {
  InMemoryItemStore([ItemMasterData? initial])
    : _data = initial ?? const ItemMasterData();

  ItemMasterData _data;

  @override
  Future<ItemMasterData> load() async => _data;

  @override
  Future<void> save(ItemMasterData data) async => _data = data;
}
