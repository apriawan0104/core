import 'package:app_core/src/infrastructure/storage/contract/storage.service.dart';

/// Persists the push audience for one install.
///
/// The engine does not choose SharedPreferences or Hive. The app supplies a
/// store. [StorageServicePushAudienceStore] adapts [StorageService] when that
/// service is already initialized.
abstract class PushAudienceStore {
  Future<String?> readString(String key);

  /// Pass null to remove [key].
  Future<void> writeString(String key, String? value);

  Future<List<String>> readStringList(String key);

  Future<void> writeStringList(String key, List<String> values);
}

/// [PushAudienceStore] backed by the core [StorageService].
///
/// A failed read returns an empty value so push startup can continue. A failed
/// write is ignored after the storage call returns a failure.
class StorageServicePushAudienceStore implements PushAudienceStore {
  StorageServicePushAudienceStore(this._storage);

  final StorageService _storage;

  @override
  Future<String?> readString(String key) async {
    final result = await _storage.get<String>(key);
    return result.fold((_) => null, (value) => value);
  }

  @override
  Future<void> writeString(String key, String? value) async {
    if (value == null) {
      await _storage.delete(key);
      return;
    }
    await _storage.save<String>(key, value);
  }

  @override
  Future<List<String>> readStringList(String key) async {
    final result = await _storage.get<List<dynamic>>(key);
    return result.fold((_) => const [], (value) {
      if (value == null) return const [];
      return value.map((item) => item.toString()).toList();
    });
  }

  @override
  Future<void> writeStringList(String key, List<String> values) async {
    await _storage.save<List<String>>(key, values);
  }
}
