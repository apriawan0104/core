# Push engine

Mesin push yang dipakai semua app. App mengisi nilai dan perilaku miliknya sendiri. `app_core` tidak mengenal nama modul, nama halaman, format rute, atau router app.

Token, topic, notifikasi lokal, dan jadwal tanpa audience ada di [`../doc/README.md`](../doc/README.md). File ini hanya untuk `PushNotificationService`.

Dua jalur di modul notification ini berdiri berdampingan:

| Jalur | Kapan dipakai |
|---|---|
| `FirebaseMessagingService` dan `LocalNotificationService` | App hanya butuh token, topic, dan notifikasi lokal generik, termasuk jadwal |
| `PushNotificationService` | App butuh audience (user + modul), channel suara, dan callback saat notifikasi di-tap |

Satu proses hanya memakai satu jalur. Lihat [Yang harus diterima developer](#yang-harus-diterima-developer).

## Yang ada di core, yang ada di app

Core:

- init Firebase bila belum ada, lalu berhenti aman bila konfigurasi belum lengkap
- izin, token, subscribe dan unsubscribe topic
- simpan dan pulihkan audience lewat store yang diberikan app
- tampilkan notifikasi lokal saat foreground, dan untuk pesan data-only di background
- memanggil `onOpened` dengan `data` pesan yang di-tap, sekali per `messageId`
- susun body FCM HTTP v1 lewat `buildFcmMessageFor`

App:

- `PushNotificationSettings`: topic, prefix modul, suara, channel, ikon, warna, dan nama field judul, isi, serta suara di payload
- fungsi background top-level dengan `@pragma('vm:entry-point')`
- `PushAudienceStore` (SharedPreferences, atau `StorageService` yang sudah di-init)
- membaca `data` di `onOpened` dan membuka halaman lewat router app, termasuk aturan payload-ke-rute
- memanggil `syncAudience` setelah login dan `clearAudience` saat logout
- file native: `google-services.json`, `GoogleService-Info.plist`, ikon, suara, izin

## Dependensi app

Selaraskan dengan core:

- `firebase_core: ^4.2.1`
- `firebase_messaging: ^16.0.3`
- `flutter_local_notifications: ^17.2.3`

`go_router` tidak masuk ke `app_core`. App yang memakai GoRouter memanggilnya dari `onOpened`.

## Setup di app

### 1. Settings

Simpan di app, misalnya `lib/src/config/notification/push_notification.config.dart`.

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

abstract final class PushNotificationConfig {
  static final PushNotificationSettings settings = PushNotificationSettings(
    generalTopic: 'general',
    moduleTopicPrefix: 'module_',
    defaultSound: 'default',
    iosSoundExtension: '.caf',
    extraSounds: const [],
    defaultAndroidChannelId: 'app_default',
    soundChannelPrefix: 'app_sound_',
    androidChannelName: 'App',
    androidChannelDescription: 'Notifikasi aplikasi',
    notificationIcon: 'ic_notification',
    notificationColor: const Color(0xFF08A94C),
    soundField: 'sound',
    titleField: 'title',
    bodyField: 'body',
    storagePrefix: 'app_push',
    iosBundleId: 'com.example.app',
  );
}
```

`notificationIcon: 'ic_notification'` memakai `res/drawable/ic_notification.xml`, tanpa `@drawable/` dan tanpa ekstensi. `defaultSound: 'default'` memakai suara sistem. Nilai lain adalah nama file tanpa ekstensi Android: `res/raw/<nama>.mp3` dan `ios/Runner/<nama>.caf`.

Key Firebase di settings diisi hanya bila `google-services.json` dan `GoogleService-Info.plist` tidak ada. Bila file native ada, biarkan key kosong. `Firebase.initializeApp()` memakai file itu.

### 2. Penyimpanan audience

Core tidak memilih SharedPreferences atau Hive. App menyediakan `PushAudienceStore`.

SharedPreferences, tanpa mengubah `StorageService`:

```dart
class SharedPreferencesPushAudienceStore implements PushAudienceStore {
  @override
  Future<String?> readString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> writeString(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, value);
  }

  @override
  Future<List<String>> readStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? const [];
  }

  @override
  Future<void> writeStringList(String key, List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, values);
  }
}
```

Atau, bila `StorageService` core sudah di-init sebelum push:

```dart
final store = StorageServicePushAudienceStore(getIt<StorageService>());
```

Kunci yang ditulis: `{storagePrefix}_user`, `{storagePrefix}_modules`, `{storagePrefix}_topics`.

### 3. Entry point background

Fungsi ini harus top-level di app dan memakai `@pragma('vm:entry-point')`. Isolate background tidak berbagi instance service dengan UI.

```dart
import 'package:app_core/app_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) {
  return handlePushBackgroundMessage(
    message,
    PushNotificationConfig.settings,
  );
}

final pushNotificationService = PushNotificationService(
  settings: PushNotificationConfig.settings,
  onBackgroundMessage: firebaseMessagingBackgroundHandler,
  audienceStore: SharedPreferencesPushAudienceStore(),
);
```

### 4. Init dan callback tap

Panggil sebelum `runApp`. `onOpened` menerima `data` pesan. App yang membaca data itu, lalu membuka halaman.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pushNotificationService.initialize(
    onOpened: (data) {
      // resolvePushNavigation adalah resolver milik app (lihat bagian di bawah).
      final request = resolvePushNavigation(data);
      if (request == null || request.isEmpty) return;
      if (request.routeName != null) {
        router.pushNamed(
          request.routeName!,
          pathParameters: request.pathParameters,
          queryParameters: request.queryParameters,
        );
      } else if (request.location != null) {
        router.push(request.location!);
      }
    },
  );
  runApp(const MyApp());
}
```

`onOpened` dipanggil di frame berikutnya. Core memanggilnya untuk tap saat app di background, tap notifikasi lokal, dan app yang dibuka dari keadaan terminated. `messageId` yang sama hanya diteruskan sekali. Key `_messageId` sudah dibuang dari `data`.

### 5. Audience

Setelah login:

```dart
await pushNotificationService.syncAudience(
  userId: userId,
  modules: {'hrgs'},
);
```

`userId` disimpan untuk dikirim backend bersama device token. Ia tidak menjadi topic. `modules` adalah kunci tanpa prefix. `hrgs` dengan prefix `module_` menjadi topic `module_hrgs`.

Saat logout:

```dart
await pushNotificationService.clearAudience();
```

Topic umum tetap ter-subscribe. Topic modul yang tidak lagi diinginkan di-unsubscribe.

Device token ada di `pushNotificationService.deviceToken` setelah `initialize` berhasil. Pengiriman token ke backend adalah tugas app.

### 6. File native

**Android**

- `POST_NOTIFICATIONS` di `AndroidManifest.xml`
- meta-data `default_notification_channel_id` sama dengan `defaultAndroidChannelId`
- meta-data ikon dan warna notifikasi
- `res/drawable/ic_notification.xml`: putih, latar transparan
- `res/raw/keep.xml` menahan ikon agar tidak dihapus R8
- `isCoreLibraryDesugaringEnabled = true` dan `desugar_jdk_libs`
- plugin `com.google.gms.google-services` bila `google-services.json` ada
- suara kustom di `res/raw/<nama>.mp3`

**iOS**

- `UIBackgroundModes` berisi `remote-notification`
- `aps-environment`: `development` untuk debug, `production` untuk TestFlight dan App Store
- `UNUserNotificationCenter.current().delegate = self` di `AppDelegate`
- suara kustom `<nama>.caf` masuk target Runner
- APNs key diunggah ke Firebase Console, bukan ke repo

## Payload dan navigasi (sisi app)

Core tidak membaca `layout`, `RouteName`, `path`, atau `query`. Semua itu format payload yang dipilih app. Core hanya memberikan `data` mentah ke `onOpened`.

Contoh yang dipakai BSpace ada di `lib/src/config/notification/push_navigation.dart` shell. Di sana app mendefinisikan:

- `PushRouteTarget`: alias payload ke nama rute, dengan `pathKeys` dan `queryKeys`
- `resolvePushNavigation(data)`: membaca `target`, `layout`, atau rute langsung, lalu mengembalikan `PushNavigationRequest`
- aplikasi request itu ke `GoRouter` di callback app

Payload tanpa tujuan dibiarkan. Notifikasi tetap tampil, tidak ada halaman yang dibuka.

### Kasus payload dan hasilnya

Core selalu memanggil `onOpened` dengan `data`, termasuk saat payload tidak punya tujuan. Keputusan ada di resolver app. Tabel ini mengikuti tes di shell (`test/push_notification_test.dart`) dan alias `task` yang didaftarkan app di `PushRouteConfig`.

| Payload `data` | Hasil resolver shell |
|---|---|
| `{"target": "task", "taskId": "42"}` | `routeName: verification`, `pathParameters: {taskId: 42}` |
| `{"target": "landing"}` | `routeName: landing` (alias bawaan) |
| `{"target": "tidak-ada"}` | alias tidak terdaftar, lanjut ke field lain. Bila tidak ada, hasilnya kosong |
| `{"layout": "{\"RouteName\":\"verification\",\"PathParameter\":{\"taskId\":\"7\"},\"QueryParameter\":{\"tab\":\"detail\"}}"}` | `routeName`, path, dan query dari JSON layout |
| `{"route": "/shell/landing"}` | `location: /shell/landing` |
| `{"sound": "chime"}` | tidak ada tujuan. Suara tidak ikut masuk query |
| `{"title": "Halo"}` | tidak ada tujuan. Notifikasi tetap tampil |

Kasus alur:

- **Tap saat app di background dan di foreground:** `onOpened` dipanggil sekali.
- **App dibuka dari keadaan terminated lewat notifikasi:** `onOpened` dipanggil sekali dari `getInitialMessage` atau dari notifikasi lokal yang membuka app.
- **Tap dua kali untuk `messageId` yang sama:** kedua tap tidak memanggil `onOpened` lebih dari sekali.
- **Payload tanpa `messageId`:** tidak ada dedupe. Setiap tap memanggil `onOpened`.

Aturan ini milik app. Di shell, `resolvePushNavigation` mengembalikan `null` atau `PushNavigationRequest` kosong untuk kasus tanpa tujuan, dan `BSpacePushNotification` tidak membuka halaman.

## Body untuk backend

`buildFcmMessageFor` menghasilkan body FCM HTTP v1. Backend yang mengirim. Server key tidak disimpan di aplikasi. `PushMessageDraft.data` dikirim apa adanya, jadi app yang ingin menyisipkan `layout` menaruhnya sendiri di sana.

```dart
final body = buildFcmMessageFor(
  PushNotificationConfig.settings,
  const PushMessageDraft(
    audience: PushAudience.module('hrgs'),
    title: 'Task',
    body: 'Baru',
    sound: 'chime',
    data: {'target': 'task', 'taskId': '42'},
  ),
);
```

`PushAudience.general()` memakai `generalTopic`. `PushAudience.token(token)` mengisi `token`, bukan `topic`.

## Perilaku

- **Web:** FCM tidak diinisialisasi.
- **Firebase belum dikonfigurasi:** `initialize` berhenti lebih awal. Aplikasi tetap berjalan. Push nonaktif sampai konfigurasi ada.
- **Izin:** diminta saat `initialize`.
- **Foreground iOS:** pesan yang punya blok `notification` ditampilkan sistem. Pesan data-only ditampilkan lewat notifikasi lokal.
- **Foreground Android:** semua pesan ditampilkan lewat notifikasi lokal, supaya suara mengikuti channel.
- **Background:** pesan yang sudah punya blok `notification` tidak ditampilkan lagi di handler. Menampilkannya lagi menggandakan banner. Pesan data-only ditampilkan lewat notifikasi lokal.
- **Tap ganda:** `messageId` yang sama diabaikan.
- **Suara Android:** satu channel mengunci suara pertama yang dipasang. Karena itu tiap suara memakai channel id sendiri.

## Yang harus diterima developer

1. **Satu jalur listener.** App yang membuat `PushNotificationService` tidak memanggil `FirebaseMessagingService.initialize` dan tidak memanggil `LocalNotificationService.initialize`. Keduanya memasang `onMessage` / `onMessageOpenedApp` atau callback tap plugin. Dipakai bersama, banner dan `onOpened` bisa jalan dua kali. App yang tidak membuat `PushNotificationService` tidak tersentuh. Signature method lama tidak berubah.

2. **Service baru tidak di-init oleh GetIt.** `configureDependencies()` tidak memanggil mesin push. App yang tidak meng-construct `PushNotificationService` tidak masuk ke alur ini.

3. **Router dan format payload tetap di app.** Core tidak mengimpor `go_router` dan tidak mengenal `layout`, `RouteName`, `path`, atau `query`.

4. **Handler background milik app.** Wajib top-level, wajib `@pragma('vm:entry-point')`, dan wajib meneruskan settings app itu. Settings tidak boleh di-hardcode di core.

5. **Store audience milik app.** Pindah dari SharedPreferences ke Hive memindahkan tempat data. Audience lama tidak ikut pindah sampai `syncAudience` dipanggil lagi. `StorageServicePushAudienceStore` membutuhkan `StorageService` yang sudah `initialize`.

6. **Versi Firebase mengikuti core.** `firebase_messaging` ^16 membutuhkan `firebase_core` ^4.2.1. App yang masih mem-pin `firebase_core` 3 atau `firebase_messaging` 15 gagal resolve.

7. **Nilai khusus app tidak masuk core.** Nama modul, nama rute, warna, dan id channel ditulis di settings app. Perubahan yang hanya berlaku untuk satu app ditambahkan sebagai field settings atau sebagai nilai di config app.

8. **Token dan user id bukan topic.** `deviceToken` dikirim app ke backend. `userId` hanya disimpan di perangkat. Topic yang dipasang adalah topic umum plus `module_<kunci>`.

9. **Pesan dengan blok `notification` di background ditampilkan OS.** Handler tidak menggambar banner kedua.

10. **Uji di perangkat fisik sebelum rilis.** Unit test mencakup nama topic, body FCM, dan passthrough data. Resolver payload diuji di app. Belum ada uji pengiriman FCM nyata di paket ini.
