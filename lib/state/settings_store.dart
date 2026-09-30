/// Where the workshop's own details are kept between sessions.
///
/// Holds them as their JSON map, so this file does not have to know the shape
/// of [WorkshopSettings] — the model reads and writes it.
abstract interface class SettingsStore {
  /// The stored details, or null when none have been saved yet.
  Future<Map<String, dynamic>?> load();

  Future<void> save(Map<String, dynamic> settings);
}

/// A store that forgets when the process does. The default, so a test can
/// build a [BillingModel] without standing up a platform channel.
class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([this._settings]);

  Map<String, dynamic>? _settings;

  @override
  Future<Map<String, dynamic>?> load() async => _settings;

  @override
  Future<void> save(Map<String, dynamic> settings) async =>
      _settings = settings;
}
