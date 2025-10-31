# Responsive Service - Screen Adaptation Module

## 📋 Overview

Modul Responsive Service mengimplementasikan **Dependency Inversion Principle (DIP)** untuk fungsionalitas adaptasi layar di package App Core. Modul ini menyediakan abstraksi untuk screen adaptation yang memisahkan aplikasi dari library konkret (`flutter_screenutil`), menghasilkan kode yang lebih testable, maintainable, dan flexible.

## 🎯 Keunggulan

- ✅ **Dependency Inversion**: High-level code tidak bergantung langsung pada library eksternal
- ✅ **Easy Testing**: Mudah di-mock untuk unit testing
- ✅ **Clean Architecture**: Pemisahan layer yang jelas
- ✅ **Flexible**: Bisa mengganti implementasi tanpa mengubah kode aplikasi
- ✅ **Developer Friendly**: Extension methods yang intuitif (`.w`, `.h`, `.sp`, `.r`)

## 🏗️ Arsitektur

```
┌─────────────────────────────────┐
│   Application Layer             │
│   (UI Components, Screens)      │
│   Menggunakan: .w .h .sp .r     │
└─────────────┬───────────────────┘
              │ depends on
              ▼
┌─────────────────────────────────┐
│   ResponsiveService             │◄─── Abstract Interface
│   (Contract/Abstraction)        │     (High-level policy)
└─────────────────────────────────┘
              ▲
              │ implements
              │
┌─────────────────────────────────┐
│ ResponsiveServiceImpl           │◄─── Concrete Implementation
│ (Uses flutter_screenutil)       │     (Low-level detail)
└─────────────────────────────────┘
```

## 📦 Struktur Modul

```
responsive/
├── responsive.dart                          # Public API exports
├── contract/
│   ├── contracts.dart                       # Contract exports
│   └── responsive.service.dart              # Abstract interface
├── impl/
│   ├── impl.dart                            # Implementation exports
│   └── responsive.service.impl.dart         # Concrete implementation
├── extension/
│   ├── extension.dart                       # Extension exports
│   └── responsive.extension.dart            # Extension methods
├── widget/
│   ├── widgets.dart                         # Widget exports
│   └── app_screen_util_init.widget.dart    # Initialization widget
└── doc/
    └── README.md                            # This file
```

## 🚀 Quick Start

### 1. Inisialisasi (Recommended - Menggunakan Widget)

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await configureDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan AppScreenUtilInit untuk inisialisasi (DIP approach)
    return AppScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return MaterialApp(
          title: 'My App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            // Bisa menggunakan screen util di theme
            textTheme: TextTheme(
              headlineLarge: TextStyle(fontSize: 32.sp),
              headlineMedium: TextStyle(fontSize: 24.sp),
              bodyLarge: TextStyle(fontSize: 16.sp),
              bodyMedium: TextStyle(fontSize: 14.sp),
            ),
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
```

### 2. Inisialisasi Alternatif (Manual)

```dart
import 'package:app_core/app_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize manually
    getIt<ResponsiveService>().init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
    );

    return MaterialApp(
      title: 'My App',
      home: const HomePage(),
    );
  }
}
```

## 📖 Cara Penggunaan

### A. Extension Methods (Recommended)

Extension methods menyediakan syntax yang clean dan mudah dibaca.

#### 1. Size Adaptation

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

Container(
  width: 100.w,           // Adapted width
  height: 200.h,          // Adapted height
  padding: EdgeInsets.all(16.r),  // Adapted radius
  child: Text(
    'Hello World',
    style: TextStyle(fontSize: 14.sp),  // Adapted font size
  ),
)
```

#### 2. Spacing Widgets

```dart
Column(
  children: [
    Text('Title'),
    16.verticalSpace,     // SizedBox(height: 16.h)
    Text('Subtitle'),
    8.horizontalSpace,    // SizedBox(width: 8.w)
  ],
)
```

#### 3. Screen Percentage

```dart
Container(
  width: 0.8.sw,  // 80% dari screen width
  height: 0.5.sh, // 50% dari screen height
)
```

#### 4. EdgeInsets Adaptation

```dart
Container(
  padding: EdgeInsets.all(16).r,           // Semua sisi adapted dengan radius
  margin: EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 10,
  ).w,                                     // Adapted dengan width ratio
)
```

#### 5. BorderRadius Adaptation

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12).r,  // Adapted radius
  ),
)
```

#### 6. Const Widgets (REdgeInsets & RPadding)

```dart
// Untuk const widgets, gunakan REdgeInsets
const Padding(
  padding: REdgeInsets.all(16),
  child: Text('Hello'),
)

// Atau gunakan RPadding langsung
RPadding.all(
  16,
  child: Text('Hello'),
)

RPadding.symmetric(
  horizontal: 20,
  vertical: 10,
  child: Text('Hello'),
)
```

### B. Direct Service Usage

Bisa juga menggunakan service secara langsung melalui dependency injection:

```dart
import 'package:app_core/app_core.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final responsive = getIt<ResponsiveService>();
    
    return Container(
      width: responsive.setWidth(200),
      height: responsive.setHeight(100),
      child: Text(
        'Hello',
        style: TextStyle(
          fontSize: responsive.setSp(16),
        ),
      ),
    );
  }
}
```

### C. Screen Information Access

```dart
final responsive = getIt<ResponsiveService>();

// Screen dimensions
print('Screen Width: ${responsive.screenWidth}');
print('Screen Height: ${responsive.screenHeight}');

// Safe area
print('Status Bar Height: ${responsive.statusBarHeight}');
print('Bottom Bar Height: ${responsive.bottomBarHeight}');

// Display metrics
print('Pixel Ratio: ${responsive.pixelRatio}');
print('Text Scale Factor: ${responsive.textScaleFactor}');
print('Scale Width: ${responsive.scaleWidth}');
print('Scale Height: ${responsive.scaleHeight}');

// Orientation
print('Orientation: ${responsive.orientation}');
```

## 📚 Extension Methods Reference

### Number Extensions

| Extension | Deskripsi | Contoh |
|-----------|-----------|--------|
| `.w` | Adapt width berdasarkan design size | `100.w` |
| `.h` | Adapt height berdasarkan design size | `200.h` |
| `.r` | Adapt radius (minimum ratio width/height) | `16.r` |
| `.sp` | Adapt font size | `14.sp` |
| `.sm` | Minimum antara sp value dan value asli | `14.sm` |
| `.sw` | Persentase dari screen width | `0.5.sw` (50%) |
| `.sh` | Persentase dari screen height | `0.3.sh` (30%) |

### Spacing Extensions

| Extension | Deskripsi | Contoh |
|-----------|-----------|--------|
| `.verticalSpace` | Vertical spacing (SizedBox dengan height) | `20.verticalSpace` |
| `.horizontalSpace` | Horizontal spacing (SizedBox dengan width) | `10.horizontalSpace` |
| `.setVerticalSpacing` | Alias untuk verticalSpace | `20.setVerticalSpacing` |
| `.setHorizontalSpacing` | Alias untuk horizontalSpace | `10.setHorizontalSpacing` |

### Widget Extensions

| Extension | Deskripsi | Contoh |
|-----------|-----------|--------|
| `EdgeInsets.w` | Adapt EdgeInsets dengan width ratio | `EdgeInsets.all(16).w` |
| `EdgeInsets.h` | Adapt EdgeInsets dengan height ratio | `EdgeInsets.all(16).h` |
| `EdgeInsets.r` | Adapt EdgeInsets dengan radius ratio | `EdgeInsets.all(16).r` |
| `BorderRadius.w` | Adapt BorderRadius dengan width ratio | `BorderRadius.circular(8).w` |
| `BorderRadius.h` | Adapt BorderRadius dengan height ratio | `BorderRadius.circular(8).h` |
| `BorderRadius.r` | Adapt BorderRadius dengan radius ratio | `BorderRadius.circular(8).r` |
| `Radius.w` | Adapt Radius dengan width ratio | `Radius.circular(16).w` |
| `Radius.h` | Adapt Radius dengan height ratio | `Radius.circular(16).h` |
| `Radius.r` | Adapt Radius dengan radius ratio | `Radius.circular(16).r` |
| `BoxConstraints.w` | Adapt BoxConstraints dengan width ratio | `BoxConstraints(...).w` |
| `BoxConstraints.h` | Adapt BoxConstraints dengan height ratio | `BoxConstraints(...).h` |
| `BoxConstraints.r` | Adapt BoxConstraints dengan radius ratio | `BoxConstraints(...).r` |

## 💡 Contoh Lengkap

### Example 1: Product Card

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      height: 220.h,
      margin: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 120.h,
              fit: BoxFit.cover,
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Responsive Dashboard

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = getIt<ResponsiveService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        toolbarHeight: 56.h,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            8.verticalSpace,
            
            Text(
              'Here\'s your overview',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            
            24.verticalSpace,
            
            // Responsive layout based on screen width
            if (responsive.screenWidth < 600)
              _buildMobileLayout()
            else if (responsive.screenWidth < 1024)
              _buildTabletLayout()
            else
              _buildDesktopLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildStatCard('Sales', 'Rp 45M', Colors.blue),
        12.verticalSpace,
        _buildStatCard('Orders', '1,234', Colors.green),
        12.verticalSpace,
        _buildStatCard('Customers', '5,678', Colors.orange),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: [
        SizedBox(
          width: (getIt<ResponsiveService>().screenWidth - 44.w) / 2,
          child: _buildStatCard('Sales', 'Rp 45M', Colors.blue),
        ),
        SizedBox(
          width: (getIt<ResponsiveService>().screenWidth - 44.w) / 2,
          child: _buildStatCard('Orders', '1,234', Colors.green),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Sales', 'Rp 45M', Colors.blue)),
        12.horizontalSpace,
        Expanded(child: _buildStatCard('Orders', '1,234', Colors.green)),
        12.horizontalSpace,
        Expanded(child: _buildStatCard('Customers', '5,678', Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          8.verticalSpace,
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Example 3: Login Form

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    Icons.business,
                    size: 50.r,
                    color: Colors.white,
                  ),
                ),
                
                32.verticalSpace,
                
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                8.verticalSpace,
                
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                
                40.verticalSpace,
                
                // Email Field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    prefixIcon: Icon(Icons.email, size: 20.r),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 14.sp),
                ),
                
                16.verticalSpace,
                
                // Password Field
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    prefixIcon: Icon(Icons.lock, size: 20.r),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 14.sp),
                ),
                
                24.verticalSpace,
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 🧪 Testing

### Mock untuk Unit Testing

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockResponsiveService extends Mock implements ResponsiveService {}

void main() {
  late MockResponsiveService mockResponsive;

  setUp(() {
    mockResponsive = MockResponsiveService();
    
    // Setup mock behavior
    when(mockResponsive.setWidth(any)).thenAnswer((invocation) {
      final num value = invocation.positionalArguments[0];
      return value.toDouble() * 1.5;
    });
    
    when(mockResponsive.setHeight(any)).thenAnswer((invocation) {
      final num value = invocation.positionalArguments[0];
      return value.toDouble() * 1.5;
    });
    
    when(mockResponsive.setSp(any)).thenAnswer((invocation) {
      final num value = invocation.positionalArguments[0];
      return value.toDouble() * 1.5;
    });
    
    when(mockResponsive.screenWidth).thenReturn(375.0);
    when(mockResponsive.screenHeight).thenReturn(812.0);
    
    // Register in GetIt
    getIt.registerSingleton<ResponsiveService>(mockResponsive);
  });

  tearDown(() {
    getIt.reset();
  });

  test('should adapt width correctly', () {
    final result = mockResponsive.setWidth(100);
    expect(result, 150.0);
  });

  test('should adapt height correctly', () {
    final result = mockResponsive.setHeight(200);
    expect(result, 300.0);
  });
}
```

## 📐 Best Practices

### 1. Design Size Selection

Gunakan dimensi yang sesuai dengan design file:

```dart
// iPhone X/11/12/13
AppScreenUtilInit(designSize: const Size(375, 812))

// Android Material Design
AppScreenUtilInit(designSize: const Size(360, 690))

// iPad
AppScreenUtilInit(designSize: const Size(768, 1024))
```

### 2. Kapan Menggunakan Width vs Height vs Radius

```dart
// ✅ GOOD: Gunakan .w untuk lebar elemen
Container(width: 100.w)

// ✅ GOOD: Gunakan .h untuk tinggi elemen
Container(height: 50.h)

// ✅ GOOD: Gunakan .r untuk border radius dan elemen persegi
Container(
  width: 100.r,
  height: 100.r,  // Persegi yang konsisten
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),
  ),
)

// ✅ GOOD: Gunakan .sp untuk font size
Text('Hello', style: TextStyle(fontSize: 14.sp))
```

### 3. Font Size dengan Maximum Limit

```dart
// Gunakan .sm untuk mencegah font terlalu besar
Text(
  'Body Text',
  style: TextStyle(fontSize: 14.sm),  // Won't exceed 14
)
```

### 4. Responsive Breakpoints

```dart
final responsive = getIt<ResponsiveService>();

if (responsive.screenWidth < 600) {
  // Mobile layout
} else if (responsive.screenWidth < 1024) {
  // Tablet layout
} else {
  // Desktop layout
}
```

### 5. Const Widgets

```dart
// Untuk const widgets, gunakan REdgeInsets dan RPadding
const Padding(
  padding: REdgeInsets.all(16),
  child: Text('Hello'),
)

// Atau
RPadding.all(16, child: Text('Hello'))
```

## 🔧 API Reference

### ResponsiveService Interface

```dart
abstract class ResponsiveService {
  // Initialization
  void init(
    BuildContext context, {
    Size designSize = const Size(360, 690),
    bool minTextAdapt = false,
    bool splitScreenMode = false,
  });

  // Size adaptation methods
  double setWidth(num width);
  double setHeight(num height);
  double radius(num size);
  double setSp(num fontSize);

  // Screen information getters
  double get pixelRatio;
  double get screenWidth;
  double get screenHeight;
  double get bottomBarHeight;
  double get statusBarHeight;
  double get textScaleFactor;
  double get scaleWidth;
  double get scaleHeight;
  Orientation get orientation;
}
```

## ❓ FAQ

### Q: Kenapa harus menggunakan abstraksi?

**A:** Dengan menggunakan abstraksi (`ResponsiveService`), kode aplikasi tidak bergantung langsung pada library eksternal (`flutter_screenutil`). Ini memudahkan testing, maintenance, dan fleksibilitas untuk mengganti implementasi di masa depan.

### Q: Apa bedanya AppScreenUtilInit dengan inisialisasi manual?

**A:** `AppScreenUtilInit` adalah widget wrapper yang mengikuti Dependency Inversion Principle. Ini lebih direkomendasikan karena:
- Lebih clean dan organized
- Mengikuti clean architecture
- Mudah di-test
- Inisialisasi otomatis untuk service

### Q: Apakah bisa menggunakan di StatelessWidget?

**A:** Ya, extension methods bisa digunakan di StatelessWidget atau StatefulWidget. Service akan diambil dari DI container (GetIt) secara otomatis.

### Q: Bagaimana cara mock untuk testing?

**A:** Buat mock class yang implements `ResponsiveService`, lalu register di GetIt saat testing:

```dart
class MockResponsiveService extends Mock implements ResponsiveService {}

setUp(() {
  getIt.registerSingleton<ResponsiveService>(MockResponsiveService());
});
```

### Q: Apakah support hot reload?

**A:** Ya, modul ini support hot reload dengan baik. Perubahan UI akan langsung terlihat.

### Q: Kapan menggunakan .w vs .r?

**A:** 
- Gunakan `.w` untuk elemen yang adaptasinya berdasarkan width
- Gunakan `.r` untuk border radius dan elemen yang harus konsisten (persegi, lingkaran)
- Untuk padding/margin, bisa pilih sesuai kebutuhan (biasanya `.r` lebih konsisten)

## 🔗 Dependencies

Modul ini menggunakan:
- `flutter_screenutil: ^5.9.0` - Library untuk screen adaptation
- `injectable: ^2.5.0` - Dependency injection annotations
- `get_it: ^8.0.2` - Service locator

## 📝 Changelog

### Version 1.0.0
- ✨ Initial implementation dengan DIP
- ✨ ResponsiveService abstraction
- ✨ ResponsiveServiceImpl menggunakan flutter_screenutil
- ✨ Extension methods untuk easy usage
- ✨ AppScreenUtilInit widget
- ✨ REdgeInsets dan RPadding untuk const support
- ✨ Comprehensive documentation

## 📄 License

Copyright © 2025 App Core Team. All rights reserved.

---

**💡 Tips:** Selalu gunakan extension methods (`.w`, `.h`, `.sp`, `.r`) untuk pengalaman development yang lebih baik dan kode yang lebih readable!
