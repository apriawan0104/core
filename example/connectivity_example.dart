// ignore_for_file: unused_element, unused_local_variable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Import the core library
// In your app, this would be: import 'package:app_core/app_core.dart';
import 'package:app_core/app_core.dart';

/// Connectivity Service Example
///
/// This example demonstrates how to use the ConnectivityService to check
/// real internet connectivity (not just Wi-Fi/Mobile connection) in your Flutter app.
///
/// Features demonstrated:
/// - One-time connectivity check
/// - Real-time connectivity monitoring
/// - Custom check endpoints
/// - Lifecycle management (pause/resume)
/// - Offline banner
/// - Retry logic with connectivity
///
/// To run this example:
/// ```bash
/// flutter run lib/example/connectivity_example.dart
/// ```

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupDependencies();

  runApp(const ConnectivityExampleApp());
}

/// Setup dependencies
Future<void> setupDependencies() async {
  final getIt = GetIt.instance;

  // Register ConnectivityService
  getIt.registerLazySingleton<ConnectivityService>(
    () => InternetConnectionCheckerPlusServiceImpl(),
  );

  // Initialize the service
  final connectivity = getIt<ConnectivityService>();

  // Option 1: Initialize with default settings
  await connectivity.initialize();

  // Option 2: Initialize with custom settings (commented out)
  /*
  await connectivity.initialize(
    checkInterval: Duration(seconds: 10),
    checkOptions: [
      ConnectivityCheckOptionEntity(
        uri: Uri.parse('https://www.google.com'),
        timeout: Duration(seconds: 5),
      ),
      ConnectivityCheckOptionEntity(
        uri: Uri.parse('https://www.cloudflare.com'),
        timeout: Duration(seconds: 5),
      ),
    ],
  );
  */
}

/// Main app
class ConnectivityExampleApp extends StatefulWidget {
  const ConnectivityExampleApp({super.key});

  @override
  State<ConnectivityExampleApp> createState() => _ConnectivityExampleAppState();
}

class _ConnectivityExampleAppState extends State<ConnectivityExampleApp>
    with WidgetsBindingObserver {
  late ConnectivityService _connectivity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivity = GetIt.instance<ConnectivityService>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground
        debugPrint('🔄 App resumed - resuming connectivity checks');
        _connectivity.resume();
        break;
      case AppLifecycleState.paused:
        // App went to background
        debugPrint('⏸️  App paused - pausing connectivity checks');
        _connectivity.pause();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connectivity Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// Home page with navigation to examples
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectivity Examples'),
      ),
      body: ListView(
        children: [
          _buildExampleTile(
            context,
            title: '1. Basic Connectivity Check',
            subtitle: 'One-time connectivity check',
            icon: Icons.check_circle,
            page: const BasicCheckExample(),
          ),
          _buildExampleTile(
            context,
            title: '2. Real-Time Monitoring',
            subtitle: 'Listen to connectivity changes',
            icon: Icons.wifi,
            page: const RealTimeMonitoringExample(),
          ),
          _buildExampleTile(
            context,
            title: '3. Offline Banner',
            subtitle: 'Show banner when offline',
            icon: Icons.notifications,
            page: const OfflineBannerExample(),
          ),
          _buildExampleTile(
            context,
            title: '4. Custom Endpoints',
            subtitle: 'Check connectivity to your own API',
            icon: Icons.settings,
            page: const CustomEndpointsExample(),
          ),
          _buildExampleTile(
            context,
            title: '5. Retry Logic',
            subtitle: 'Automatic retry when connection returns',
            icon: Icons.refresh,
            page: const RetryLogicExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon, size: 32),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}

/// Example 1: Basic Connectivity Check
class BasicCheckExample extends StatefulWidget {
  const BasicCheckExample({super.key});

  @override
  State<BasicCheckExample> createState() => _BasicCheckExampleState();
}

class _BasicCheckExampleState extends State<BasicCheckExample> {
  final _connectivity = GetIt.instance<ConnectivityService>();
  bool _isChecking = false;
  String _status = 'Tap button to check connectivity';
  Color _statusColor = Colors.grey;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _status = 'Checking...';
      _statusColor = Colors.orange;
    });

    final result = await _connectivity.hasInternetConnection();

    result.fold(
      (failure) {
        setState(() {
          _isChecking = false;
          _status = 'Error: ${failure.message}';
          _statusColor = Colors.red;
        });
      },
      (isConnected) {
        setState(() {
          _isChecking = false;
          _status = isConnected ? 'Connected! 🌐' : 'Disconnected! 📵';
          _statusColor = isConnected ? Colors.green : Colors.red;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Connectivity Check'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isChecking
                    ? Icons.refresh
                    : _statusColor == Colors.green
                        ? Icons.wifi
                        : _statusColor == Colors.red
                            ? Icons.wifi_off
                            : Icons.help_outline,
                size: 100,
                color: _statusColor,
              ),
              const SizedBox(height: 32),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: _statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkConnection,
                icon: const Icon(Icons.refresh),
                label: const Text('Check Connection'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 2: Real-Time Monitoring
class RealTimeMonitoringExample extends StatefulWidget {
  const RealTimeMonitoringExample({super.key});

  @override
  State<RealTimeMonitoringExample> createState() =>
      _RealTimeMonitoringExampleState();
}

class _RealTimeMonitoringExampleState extends State<RealTimeMonitoringExample> {
  final _connectivity = GetIt.instance<ConnectivityService>();
  late StreamSubscription<ConnectivityStatusEntity> _subscription;
  bool _isOnline = false;
  final List<String> _events = [];

  @override
  void initState() {
    super.initState();

    // Get initial status
    _isOnline = _connectivity.isConnected ?? false;
    _addEvent('Initial status: ${_isOnline ? 'Online' : 'Offline'}');

    // Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen((status) {
      setState(() {
        _isOnline = status.isConnected;
      });

      _addEvent(status.message);

      if (status.isConnected) {
        _onConnected();
      } else {
        _onDisconnected();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _addEvent(String event) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _events.insert(0, '[$timestamp] $event');
      if (_events.length > 20) {
        _events.removeLast();
      }
    });
  }

  void _onConnected() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Back online! 🌐'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onDisconnected() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connection lost! 📵'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Monitoring'),
        actions: [
          // Connection indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isOnline ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: _isOnline ? Colors.green.shade50 : Colors.red.shade50,
            child: Column(
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 64,
                  color: _isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _isOnline ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Events list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _events[index],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 3: Offline Banner
class OfflineBannerExample extends StatelessWidget {
  const OfflineBannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Banner'),
      ),
      body: const Column(
        children: [
          // Offline banner
          OfflineBanner(),
          // Content
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 64, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Disconnect your internet to see the offline banner',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Offline banner widget
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = GetIt.instance<ConnectivityService>();

    return StreamBuilder<ConnectivityStatusEntity>(
      stream: connectivity.onConnectivityChanged,
      initialData: connectivity.currentStatus,
      builder: (context, snapshot) {
        final isOffline = snapshot.data?.isDisconnected ?? false;

        if (!isOffline) return const SizedBox.shrink();

        return Material(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.red,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Example 4: Custom Endpoints
class CustomEndpointsExample extends StatefulWidget {
  const CustomEndpointsExample({super.key});

  @override
  State<CustomEndpointsExample> createState() => _CustomEndpointsExampleState();
}

class _CustomEndpointsExampleState extends State<CustomEndpointsExample> {
  final _connectivity = GetIt.instance<ConnectivityService>();
  String _status = 'Using default endpoints';

  void _useDefaultEndpoints() {
    _connectivity.updateCheckOptions(
      ConnectivityCheckOptionEntity.defaultOptions,
    );
    setState(() {
      _status = 'Using default endpoints:\n'
          '- google.com\n'
          '- cloudflare.com\n'
          '- apple.com';
    });
  }

  void _useCustomEndpoints() {
    _connectivity.updateCheckOptions([
      ConnectivityCheckOptionEntity(
        uri: Uri.parse('https://www.github.com'),
        timeout: const Duration(seconds: 5),
      ),
      ConnectivityCheckOptionEntity(
        uri: Uri.parse('https://www.stackoverflow.com'),
        timeout: const Duration(seconds: 5),
      ),
    ]);
    setState(() {
      _status = 'Using custom endpoints:\n'
          '- github.com\n'
          '- stackoverflow.com';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Endpoints'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.settings, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _useDefaultEndpoints,
              icon: const Icon(Icons.public),
              label: const Text('Use Default Endpoints'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _useCustomEndpoints,
              icon: const Icon(Icons.code),
              label: const Text('Use Custom Endpoints'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Note: You can configure custom endpoints to check connectivity '
              'to your own API servers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 5: Retry Logic
class RetryLogicExample extends StatefulWidget {
  const RetryLogicExample({super.key});

  @override
  State<RetryLogicExample> createState() => _RetryLogicExampleState();
}

class _RetryLogicExampleState extends State<RetryLogicExample> {
  final _connectivity = GetIt.instance<ConnectivityService>();
  String _status = 'Ready to fetch';
  bool _isFetching = false;
  Color _statusColor = Colors.grey;

  Future<void> _fetchDataWithRetry() async {
    setState(() {
      _isFetching = true;
      _status = 'Checking connectivity...';
      _statusColor = Colors.orange;
    });

    // Check connectivity first
    final connectionResult = await _connectivity.hasInternetConnection();

    await connectionResult.fold(
      (failure) {
        setState(() {
          _isFetching = false;
          _status = 'Error: ${failure.message}';
          _statusColor = Colors.red;
        });
      },
      (isConnected) async {
        if (!isConnected) {
          setState(() {
            _status = 'No internet. Waiting for connection...';
          });

          // Wait for connection
          try {
            await _waitForConnection();
          } catch (e) {
            setState(() {
              _isFetching = false;
              _status = 'Timeout waiting for connection';
              _statusColor = Colors.red;
            });
            return;
          }
        }

        // Fetch data
        await _performFetch();
      },
    );
  }

  Future<void> _waitForConnection() async {
    // Wait until connected (with timeout)
    await _connectivity.onConnectivityChanged
        .firstWhere((status) => status.isConnected)
        .timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Connection timeout');
      },
    );

    setState(() {
      _status = 'Connected! Fetching data...';
    });
  }

  Future<void> _performFetch() async {
    // Simulate data fetching
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isFetching = false;
      _status = 'Data fetched successfully! ✅';
      _statusColor = Colors.green;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retry Logic'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isFetching
                    ? Icons.refresh
                    : _statusColor == Colors.green
                        ? Icons.check_circle
                        : _statusColor == Colors.red
                            ? Icons.error
                            : Icons.cloud_download,
                size: 100,
                color: _statusColor,
              ),
              const SizedBox(height: 32),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: _statusColor,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _isFetching ? null : _fetchDataWithRetry,
                icon: const Icon(Icons.download),
                label: const Text('Fetch Data with Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'This example demonstrates automatic retry logic.\n'
                'If there\'s no internet, it will wait for connection\n'
                'before proceeding with the data fetch.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
