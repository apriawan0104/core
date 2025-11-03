# Storage Service Performance Guide

Guide untuk mengoptimalkan performance storage service di aplikasi Anda.

## 📊 Performance Characteristics

### Hive Performance Benchmarks

| Operation | Regular Box | Lazy Box |
|-----------|-------------|----------|
| **Open Box** | 10-100ms | 5-20ms |
| **Read (single)** | <1ms (RAM) | 1-5ms (Disk) |
| **Write (single)** | 1-5ms | 1-5ms |
| **Batch Write (100 items)** | 10-50ms | 10-50ms |
| **Memory Usage** | All data in RAM | Metadata only (~1%) |

### Multiple Boxes Impact

```dart
// 4 Small Boxes (typical app)
// Memory: 50KB + 10KB + 20KB + 10KB = 90KB
// Startup: ~100ms total
// Verdict: ✅ EXCELLENT - No performance issues

// 4 Medium Boxes 
// Memory: 500KB + 100KB + 200KB + 50KB = 850KB
// Startup: ~200ms total
// Verdict: ✅ GOOD - Still very fast

// 4 Large Boxes
// Memory: 5MB + 2MB + 10MB + 1MB = 18MB
// Startup: ~500ms total
// Verdict: ⚠️ HEAVY - Consider lazy boxes
```

---

## ⚡ Optimization Strategies

### Strategy 1: Use Lazy Boxes for Large Data

```dart
Future<void> setupStorage() async {
  // Small data → Regular Box (fast access)
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: 'preferences',
      useLazyBox: false,  // ✅ Regular: ~20 entries
    ),
    instanceName: 'preferences',
  );
  
  // Large data → Lazy Box (memory efficient)
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: 'cache',
      useLazyBox: true,  // ✅ Lazy: 1000+ entries
    ),
    instanceName: 'cache',
  );
  
  await getIt<StorageService>(instanceName: 'preferences').initialize();
  await getIt<StorageService>(instanceName: 'cache').initialize();
}
```

### Strategy 2: Lazy Initialize Non-Critical Boxes

```dart
Future<void> setupStorage() async {
  // Critical: Initialize immediately
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(boxName: 'preferences'),
    instanceName: 'preferences',
  );
  await getIt<StorageService>(instanceName: 'preferences').initialize();
  
  // Non-critical: Register only, initialize on-demand
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(boxName: 'cache'),
    instanceName: 'cache',
  );
  // Don't initialize yet - will initialize on first use
}

// Later, when needed
Future<void> ensureCacheReady() async {
  final cache = getIt<StorageService>(instanceName: 'cache');
  if (!cache.isInitialized) {
    await cache.initialize();
  }
}
```

### Strategy 3: Periodic Cleanup

```dart
// Clear cache periodically to keep size small
Future<void> cleanupOldCache() async {
  final cache = getIt<StorageService>(instanceName: 'cache');
  
  // Get all keys
  final keys = await cache.getAllKeys();
  
  // Check expiration and delete old items
  for (final key in keys) {
    if (await cache.isExpired(key)) {
      await cache.delete(key);
    }
  }
  
  // Compact to free disk space
  await cache.compact();
}

// Run cleanup on app start or periodically
void setupPeriodicCleanup() {
  Timer.periodic(Duration(hours: 24), (_) async {
    await cleanupOldCache();
  });
}
```

### Strategy 4: Smart Box Naming & Separation

```dart
// ✅ GOOD: Separate by purpose and size
// - Small boxes: User settings, tokens (regular box)
// - Large boxes: API cache, images (lazy box)

Future<void> setupSmartStorage() async {
  // 1. Small & Hot Data (Regular Box)
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: 'hot_data',      // Frequently accessed
      useLazyBox: false,        // Keep in memory
    ),
    instanceName: 'hot',
  );
  
  // 2. Large & Cold Data (Lazy Box)
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: 'cold_data',     // Rarely accessed
      useLazyBox: true,         // Load on-demand
    ),
    instanceName: 'cold',
  );
  
  // 3. Secure Data (Regular Box + Encryption)
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: 'secure',
      useLazyBox: false,        // Small sensitive data
      encryptionCipher: HiveAesCipher(key),
    ),
    instanceName: 'secure',
  );
}
```

---

## 🎯 Decision Tree: Regular vs Lazy Box

```
How many items in box?
│
├─→ < 100 items
│   └─→ Use Regular Box (fast access, low memory)
│
├─→ 100 - 1000 items
│   ├─→ Items < 1KB each?
│   │   └─→ Use Regular Box (total < 1MB)
│   │
│   └─→ Items > 1KB each?
│       └─→ Use Lazy Box (could be > 1MB)
│
└─→ > 1000 items
    └─→ Use Lazy Box (memory efficient)
```

---

## 💡 Real-World Examples

### Example 1: Typical Flutter App (E-Commerce)

```dart
Future<void> setupECommerceStorage() async {
  // User preferences: ~10 entries, ~5KB total
  // → Regular Box ✅
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: 'user_prefs',
      useLazyBox: false,
    ),
    instanceName: 'prefs',
  );
  
  // Auth tokens: ~5 entries, ~2KB total
  // → Regular Box + Encrypted ✅
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: 'auth',
      useLazyBox: false,
      encryptionCipher: HiveAesCipher(authKey),
    ),
    instanceName: 'auth',
  );
  
  // Product cache: ~500 products, ~500KB total
  // → Lazy Box ✅ (or use expiration to keep small)
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: 'product_cache',
      useLazyBox: true,  // Large dataset
    ),
    instanceName: 'cache',
  );
  
  // Cart items: ~20 items, ~10KB total
  // → Regular Box ✅
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(
      boxName: 'cart',
      useLazyBox: false,
    ),
    instanceName: 'cart',
  );
  
  // Total Memory: 5KB + 2KB + 10KB = 17KB
  // (Product cache not in memory thanks to lazy box!)
  // Total Startup: ~150ms
  // Verdict: ⚡ EXCELLENT PERFORMANCE
}
```

### Example 2: Social Media App

```dart
Future<void> setupSocialMediaStorage() async {
  // User settings: Regular Box
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(boxName: 'settings', useLazyBox: false),
    instanceName: 'settings',
  );
  
  // Feed cache: 1000+ posts → Lazy Box!
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(boxName: 'feed_cache', useLazyBox: true),
    instanceName: 'feed',
  );
  
  // Draft posts: Regular Box
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(boxName: 'drafts', useLazyBox: false),
    instanceName: 'drafts',
  );
  
  // Image metadata: 500+ images → Lazy Box!
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(boxName: 'image_meta', useLazyBox: true),
    instanceName: 'images',
  );
  
  // Memory: Settings (5KB) + Drafts (20KB) = 25KB only!
  // Feed cache & image meta use lazy loading
}
```

---

## 🔍 Monitoring & Debugging

### Check Box Sizes

```dart
Future<void> monitorStorageSize() async {
  final storage = getIt<StorageService>(instanceName: 'cache');
  
  final size = await storage.getSize();
  final keys = await storage.getAllKeys();
  
  print('Box size: ${(size / 1024).toStringAsFixed(2)} KB');
  print('Number of keys: ${keys.length}');
  print('Average per entry: ${(size / keys.length / 1024).toStringAsFixed(2)} KB');
  
  if (size > 5 * 1024 * 1024) {  // > 5MB
    print('⚠️ Box is large, consider using lazy box or cleanup');
  }
}
```

### Measure Initialization Time

```dart
Future<void> setupStorageWithProfiling() async {
  final stopwatch = Stopwatch()..start();
  
  // Initialize storage
  getIt.registerLazySingleton<StorageService>(
    () => HiveStorageServiceImpl(boxName: 'test'),
  );
  
  final storage = getIt<StorageService>();
  await storage.initialize();
  
  stopwatch.stop();
  print('Storage initialization took: ${stopwatch.elapsedMilliseconds}ms');
  
  if (stopwatch.elapsedMilliseconds > 200) {
    print('⚠️ Slow initialization, consider lazy box');
  }
}
```

### Memory Profiling

```dart
import 'dart:developer' as developer;

Future<void> profileMemoryUsage() async {
  // Trigger GC
  developer.Timeline.instantSync('Before Storage Init');
  
  final storage = getIt<StorageService>();
  await storage.initialize();
  
  developer.Timeline.instantSync('After Storage Init');
  
  // Use Flutter DevTools → Memory tab to see impact
}
```

---

## 🚀 Advanced Optimizations

### 1. Batch Operations

```dart
// ❌ BAD: Multiple individual saves (slow)
for (final item in items) {
  await storage.save(item.id, item);
}

// ✅ GOOD: Batch save (fast)
final entries = {for (var item in items) item.id: item};
await storage.saveAll(entries);
```

### 2. Avoid Unnecessary Reads

```dart
// ❌ BAD: Read same value multiple times
final theme1 = await storage.get<String>('theme');
// ... later ...
final theme2 = await storage.get<String>('theme');  // Unnecessary read

// ✅ GOOD: Cache in memory for session
class ThemeService {
  String? _cachedTheme;
  final StorageService _storage;
  
  Future<String> getTheme() async {
    _cachedTheme ??= await _storage.get<String>('theme', defaultValue: 'light');
    return _cachedTheme!;
  }
  
  Future<void> setTheme(String theme) async {
    _cachedTheme = theme;
    await _storage.save('theme', theme);
  }
}
```

### 3. Use Expiration to Keep Boxes Small

```dart
// Save with TTL to auto-cleanup
await cache.saveWithExpiration(
  'api_response',
  data,
  expiresIn: Duration(hours: 24),
);

// Old data auto-deleted, box stays small
```

### 4. Compress Large Strings

```dart
import 'dart:convert';
import 'dart:io';

// Compress large JSON before storage
Future<void> saveLargeData(String key, Map<String, dynamic> data) async {
  final jsonString = jsonEncode(data);
  final bytes = utf8.encode(jsonString);
  final compressed = gzip.encode(bytes);
  
  await storage.save(key, base64Encode(compressed));
}

// Decompress on read
Future<Map<String, dynamic>> getLargeData(String key) async {
  final compressed = await storage.get<String>(key);
  if (compressed == null) return {};
  
  final bytes = base64Decode(compressed);
  final decompressed = gzip.decode(bytes);
  final jsonString = utf8.decode(decompressed);
  
  return jsonDecode(jsonString);
}
```

---

## ⚠️ Common Performance Pitfalls

### Pitfall 1: Opening Too Many Regular Boxes

```dart
// ❌ BAD: 10 regular boxes with large data
for (int i = 0; i < 10; i++) {
  await Hive.openBox('box_$i');  // Each loads to memory!
}
// Memory: Could be 50MB+ if boxes are large

// ✅ GOOD: Use lazy boxes or combine into one
await Hive.openLazyBox('combined_box');
```

### Pitfall 2: Storing Large Objects Without Pagination

```dart
// ❌ BAD: Store all 10,000 users in one key
await storage.save('all_users', allUsers);  // Huge object!

// ✅ GOOD: Paginate or store separately
for (final user in users) {
  await storage.save('user_${user.id}', user);
}
// Or use lazy box + batch operations
```

### Pitfall 3: Not Using Compaction

```dart
// ❌ BAD: Never compact (disk space grows)
await storage.delete('large_item');  // Space not freed!

// ✅ GOOD: Compact after bulk deletes
await storage.deleteAll(oldKeys);
await storage.compact();  // Free up disk space
```

---

## 📊 Performance Checklist

Before deploying, check:

- [ ] Small boxes (<100KB) use regular box
- [ ] Large boxes (>1MB) use lazy box
- [ ] Encryption only on secure data (adds 10-20% overhead)
- [ ] Periodic cleanup for cache boxes
- [ ] Batch operations for bulk saves
- [ ] Compaction after large deletes
- [ ] Initialization time < 200ms
- [ ] Memory usage reasonable for target devices

---

## 🎯 Summary

| Box Size | Items | Strategy | Memory | Speed |
|----------|-------|----------|--------|-------|
| **Tiny** | <50 | Regular Box | <50KB | ⚡⚡⚡ |
| **Small** | 50-100 | Regular Box | 50-500KB | ⚡⚡⚡ |
| **Medium** | 100-1000 | Lazy Box | <100KB | ⚡⚡ |
| **Large** | 1000+ | Lazy Box | <100KB | ⚡ |

**Golden Rule**: 
- **Regular Box**: Frequently accessed, small data (<1MB)
- **Lazy Box**: Rarely accessed or large data (>1MB)

---

For more information, see:
- [Storage Service Documentation](README.md)
- [Hive Performance Tips](https://docs.hivedb.dev/#/README?id=best-practices)

