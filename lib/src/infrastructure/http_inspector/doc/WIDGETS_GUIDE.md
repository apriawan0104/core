# HTTP Inspector Widgets Guide

This guide covers the pre-built widgets available for HTTP Inspector that make it easy to access the inspector UI during development.

## 📋 Table of Contents

- [HttpInspectorButton](#httpinspectorbutton)
- [HttpInspectorOverlay](#httpinspectoroverlay)
- [Usage Examples](#usage-examples)
- [Customization](#customization)
- [Best Practices](#best-practices)

---

## HttpInspectorButton

A floating action button widget that provides quick access to HTTP Inspector.

### Features

- ✅ Easy to add as FloatingActionButton
- ✅ Customizable appearance
- ✅ Optional label for extended FAB
- ✅ Badge support (coming soon)
- ✅ Only visible in debug mode by default
- ✅ Automatic service detection from DI

### Basic Usage

#### As Floating Action Button

```dart
Scaffold(
  appBar: AppBar(title: Text('My App')),
  body: MyContent(),
  floatingActionButton: HttpInspectorButton(),
)
```

#### With Label (Extended FAB)

```dart
Scaffold(
  floatingActionButton: HttpInspectorButton(
    label: 'API Inspector',
  ),
)
```

#### Custom Position

```dart
Stack(
  children: [
    MyContent(),
    Positioned(
      right: 16,
      bottom: 80,
      child: HttpInspectorButton(),
    ),
  ],
)
```

### Customization Options

```dart
HttpInspectorButton(
  // Custom background color
  backgroundColor: Colors.red,
  
  // Custom icon
  icon: Icons.network_check,
  
  // Button size
  size: 64,
  
  // Label text (makes it extended FAB)
  label: 'Debug API',
  
  // Show badge (for request count)
  showBadge: true,
  
  // Tooltip text
  tooltip: 'Open HTTP Inspector',
  
  // Button position hint
  position: HttpInspectorButtonPosition.bottomRight,
  
  // Visibility control
  debugModeOnly: true,
  
  // Custom service instance
  service: myCustomService,
)
```

### Position Options

```dart
enum HttpInspectorButtonPosition {
  bottomRight,  // Default
  bottomLeft,
  topRight,
  topLeft,
  custom,      // Use with Positioned widget
}
```

---

## HttpInspectorOverlay

A draggable floating button that stays on top of your app's UI.

### Features

- ✅ Draggable to any position
- ✅ Stays on top of all content
- ✅ Minimalist design
- ✅ Only visible in debug mode
- ✅ Zero layout space requirement
- ✅ Auto-hides in production

### Basic Usage

#### Wrap Your App

```dart
MaterialApp(
  home: HttpInspectorOverlay(
    child: MyHomePage(),
  ),
)
```

#### Wrap Specific Screens

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HttpInspectorOverlay(
      child: Scaffold(
        appBar: AppBar(title: Text('My Page')),
        body: MyContent(),
      ),
    );
  }
}
```

### Customization Options

```dart
HttpInspectorOverlay(
  child: MyApp(),
  
  // Initial position
  initialPosition: Offset(20, 100),
  
  // Custom background color
  backgroundColor: Colors.red.shade700,
  
  // Custom icon
  icon: Icons.network_check,
  
  // Button size
  size: 48,
  
  // Visibility control
  debugModeOnly: true,
  enabled: true,
  
  // Custom service instance
  service: myCustomService,
)
```

---

## Usage Examples

### Example 1: Simple FAB

```dart
import 'package:app_core/app_core.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      body: Center(
        child: Text('Hello World'),
      ),
      floatingActionButton: HttpInspectorButton(),
    );
  }
}
```

### Example 2: Extended FAB with Custom Style

```dart
floatingActionButton: HttpInspectorButton(
  label: 'Network',
  icon: Icons.wifi,
  backgroundColor: Colors.deepPurple,
  tooltip: 'View Network Requests',
)
```

### Example 3: Multiple Buttons

```dart
Scaffold(
  body: MyContent(),
  floatingActionButton: Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      // Your app's main FAB
      FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      SizedBox(height: 16),
      
      // HTTP Inspector button
      HttpInspectorButton(
        size: 48, // Smaller size
      ),
    ],
  ),
)
```

### Example 4: Draggable Overlay

```dart
void main() {
  runApp(
    HttpInspectorOverlay(
      initialPosition: Offset(20, 100),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}
```

### Example 5: Conditional Display

```dart
class MyPage extends StatelessWidget {
  final bool showDebugTools;
  
  const MyPage({this.showDebugTools = false});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyContent(),
      floatingActionButton: showDebugTools
          ? HttpInspectorButton(
              label: 'Debug',
              backgroundColor: Colors.orange,
            )
          : null,
    );
  }
}
```

### Example 6: Custom Error Handling

```dart
class MyInspectorButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HttpInspectorButton(
      service: GetIt.instance<HttpInspectorService>(),
      backgroundColor: Colors.red.shade700,
      icon: Icons.bug_report,
      label: 'Debug API',
      tooltip: 'Open HTTP Inspector',
    );
  }
}
```

---

## Customization

### Theme-Based Styling

```dart
class ThemedInspectorButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return HttpInspectorButton(
      backgroundColor: theme.colorScheme.secondary,
      icon: Icons.network_check,
      size: 56,
    );
  }
}
```

### Responsive Size

```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

HttpInspectorButton(
  size: 56.w, // Responsive size
  icon: Icons.bug_report,
)
```

### Dark Mode Support

```dart
HttpInspectorButton(
  backgroundColor: Theme.of(context).brightness == Brightness.dark
      ? Colors.blue.shade700
      : Colors.blue,
)
```

---

## Best Practices

### 1. Use in Development Only

```dart
Scaffold(
  floatingActionButton: kDebugMode
      ? HttpInspectorButton()
      : null,
)
```

### 2. Combine with Feature Flags

```dart
Scaffold(
  floatingActionButton: FeatureFlags.showDebugTools
      ? HttpInspectorButton(label: 'Debug')
      : null,
)
```

### 3. Position Carefully

```dart
// ✅ GOOD: Bottom right (doesn't block content)
floatingActionButton: HttpInspectorButton()

// ⚠️ CAREFUL: Custom position (might block UI)
Stack(
  children: [
    MyContent(),
    Positioned(
      right: 16,
      top: 80, // Make sure it doesn't block important content
      child: HttpInspectorButton(),
    ),
  ],
)
```

### 4. Accessibility

```dart
HttpInspectorButton(
  tooltip: 'Open HTTP Inspector', // Always provide tooltip
  size: 56, // Minimum touch target size
)
```

### 5. Error Handling

The widgets automatically handle errors and show snackbars, but you can provide custom service:

```dart
class MyInspectorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      final service = GetIt.instance<HttpInspectorService>();
      return HttpInspectorButton(service: service);
    } catch (e) {
      // Service not available, don't show button
      return SizedBox.shrink();
    }
  }
}
```

### 6. Testing

```dart
testWidgets('Inspector button shows in debug mode', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        floatingActionButton: HttpInspectorButton(),
      ),
    ),
  );
  
  expect(find.byType(HttpInspectorButton), findsOneWidget);
});
```

---

## Advanced Usage

### Custom Service Provider

```dart
class MyApp extends StatelessWidget {
  final HttpInspectorService inspector;
  
  const MyApp({required this.inspector});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: HttpInspectorButton(
          service: inspector,
        ),
      ),
    );
  }
}
```

### State Management Integration

```dart
// With Provider
Consumer<AppState>(
  builder: (context, state, child) {
    return HttpInspectorButton(
      backgroundColor: state.debugMode ? Colors.red : Colors.blue,
    );
  },
)

// With Bloc
BlocBuilder<DebugBloc, DebugState>(
  builder: (context, state) {
    return state.showInspector
        ? HttpInspectorButton()
        : SizedBox.shrink();
  },
)
```

### Animation

```dart
class AnimatedInspectorButton extends StatefulWidget {
  @override
  State<AnimatedInspectorButton> createState() => 
      _AnimatedInspectorButtonState();
}

class _AnimatedInspectorButtonState 
    extends State<AnimatedInspectorButton> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.1),
          child: HttpInspectorButton(),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## Comparison

| Feature | HttpInspectorButton | HttpInspectorOverlay |
|---------|-------------------|---------------------|
| Layout Space | Takes FAB space | No layout space |
| Draggable | No | Yes |
| Label Support | Yes | No |
| Badge Support | Yes | No |
| Best For | Quick access | Always visible |
| Setup | Add to Scaffold | Wrap widget tree |

---

## Troubleshooting

### Button Not Showing

**Possible Causes:**
1. Service not registered in DI
2. Release mode (debugModeOnly=true)
3. Inspector disabled

**Solution:**
```dart
// Check service registration
try {
  final service = GetIt.instance<HttpInspectorService>();
  print('Service available: ${service.isEnabled()}');
} catch (e) {
  print('Service not registered');
}

// Force show in release (not recommended)
HttpInspectorButton(
  debugModeOnly: false,
)
```

### Button Not Opening Inspector

**Possible Causes:**
1. Navigator observer not added
2. Service not initialized

**Solution:**
```dart
// Verify navigator observer
MaterialApp(
  navigatorObservers: [
    GetIt.instance<HttpInspectorService>().getNavigatorObserver(),
  ],
)

// Check initialization
final result = await inspector.initialize(config);
result.fold(
  (failure) => print('Init failed: $failure'),
  (_) => print('Initialized'),
);
```

---

## Related Documentation

- [HTTP Inspector Setup](../../../HTTP_INSPECTOR_SETUP.md)
- [Quick Start Guide](./QUICK_START.md)
- [README](./README.md)
- [Example App](../../../example/http_inspector_example.dart)

---

**Happy Debugging!** 🐛🔍

