// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

// Import app_core (in real app, this would be: import 'package:app_core/app_core.dart';)
import 'package:app_core/app_core.dart';

/// HTTP Inspector Example Application
///
/// This example demonstrates how to use the HTTP Inspector service
/// with different HTTP clients (Dio and http package).
///
/// Features demonstrated:
/// - Service initialization
/// - Dio interceptor integration
/// - http client wrapper
/// - Navigator observer setup
/// - Manual UI opening
/// - Configuration management
/// - Error handling

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HTTP Inspector Service
  final httpInspectorService = ChuckerHttpInspectorServiceImpl();
  final initResult = await httpInspectorService.initialize(
    const HttpInspectorConfig(
      showNotifications: true,
      showOnRelease: false, // Only in debug mode
      showOnlyErrors: false, // Show all requests
      maxContentLength: 250000,
      showImagePreview: true,
      enableSharing: true,
      headersToHide: [
        'authorization',
        'cookie',
        'api-key',
      ],
    ),
  );

  initResult.fold(
    (failure) {
      print('❌ Failed to initialize HTTP Inspector: $failure');
    },
    (_) {
      print('✅ HTTP Inspector initialized successfully');
    },
  );

  // Register in DI container for easy access
  GetIt.instance.registerSingleton<HttpInspectorService>(httpInspectorService);

  runApp(const HttpInspectorExampleApp());
}

class HttpInspectorExampleApp extends StatelessWidget {
  const HttpInspectorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpInspector = GetIt.instance<HttpInspectorService>();

    return MaterialApp(
      title: 'HTTP Inspector Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Add HTTP Inspector navigator observer
      navigatorObservers: [
        httpInspector.getNavigatorObserver(),
      ],
      home: const HttpInspectorHomePage(),
    );
  }
}

class HttpInspectorHomePage extends StatefulWidget {
  const HttpInspectorHomePage({super.key});

  @override
  State<HttpInspectorHomePage> createState() => _HttpInspectorHomePageState();
}

class _HttpInspectorHomePageState extends State<HttpInspectorHomePage> {
  final _httpInspector = GetIt.instance<HttpInspectorService>();
  String _lastResult = 'No requests yet';
  bool _isLoading = false;

  // Dio instance with HTTP Inspector
  late final Dio _dio;

  // http.Client instance with HTTP Inspector
  late final http.Client _httpClient;

  @override
  void initState() {
    super.initState();
    _setupDio();
    _setupHttpClient();
  }

  /// Setup Dio with HTTP Inspector interceptor
  void _setupDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Get Dio interceptor from HTTP Inspector
    final interceptorResult = _httpInspector.getDioInterceptor();
    interceptorResult.fold(
      (failure) {
        print('❌ Failed to get Dio interceptor: $failure');
      },
      (interceptor) {
        _dio.interceptors.add(interceptor);
        print('✅ Dio interceptor added');
      },
    );
  }

  /// Setup http.Client with HTTP Inspector wrapper
  void _setupHttpClient() {
    final httpClientResult = _httpInspector.getHttpClient(http.Client());
    _httpClient = httpClientResult.fold(
      (failure) {
        print('❌ Failed to get http client: $failure');
        return http.Client();
      },
      (client) {
        print('✅ http client wrapped');
        return client;
      },
    );
  }

  /// Make GET request using Dio
  Future<void> _makeDioGetRequest() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Making Dio GET request...';
    });

    try {
      final response = await _dio.get('/posts/1');
      setState(() {
        _lastResult = '✅ Dio GET Success!\n'
            'Status: ${response.statusCode}\n'
            'Title: ${response.data['title']}\n\n'
            'Check the notification above! 👆';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Dio GET Failed: $e';
        _isLoading = false;
      });
    }
  }

  /// Make POST request using Dio
  Future<void> _makeDioPostRequest() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Making Dio POST request...';
    });

    try {
      final response = await _dio.post(
        '/posts',
        data: {
          'title': 'Test Post',
          'body': 'This is a test post from HTTP Inspector example',
          'userId': 1,
        },
      );
      setState(() {
        _lastResult = '✅ Dio POST Success!\n'
            'Status: ${response.statusCode}\n'
            'Created ID: ${response.data['id']}\n\n'
            'Check the notification! 👆';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Dio POST Failed: $e';
        _isLoading = false;
      });
    }
  }

  /// Make request using http package
  Future<void> _makeHttpRequest() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Making http package request...';
    });

    try {
      final response = await _httpClient.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users/1'),
      );
      setState(() {
        _lastResult = '✅ http Package Success!\n'
            'Status: ${response.statusCode}\n'
            'Body length: ${response.body.length} chars\n\n'
            'Check the notification! 👆';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ http Request Failed: $e';
        _isLoading = false;
      });
    }
  }

  /// Make failing request (404 error)
  Future<void> _makeFailingRequest() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Making request that will fail...';
    });

    try {
      await _dio.get('/posts/999999');
    } catch (e) {
      setState(() {
        _lastResult = '✅ Error captured!\n'
            'This is a 404 error example.\n\n'
            'Check the notification with error status! 👆';
        _isLoading = false;
      });
    }
  }

  /// Show HTTP Inspector UI manually
  Future<void> _showInspectorUI() async {
    final result = await _httpInspector.showInspectorUI(context);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open inspector: $failure')),
        );
      },
      (_) {
        // Success (if implementation supports manual opening)
      },
    );
  }

  /// Toggle inspector enabled state
  Future<void> _toggleInspector() async {
    final isEnabled = _httpInspector.isEnabled();
    final result = await _httpInspector.setEnabled(!isEnabled);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle: $failure')),
        );
      },
      (_) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Inspector ${!isEnabled ? "enabled" : "disabled"}',
            ),
          ),
        );
      },
    );
  }

  /// Clear all stored data
  Future<void> _clearData() async {
    final result = await _httpInspector.clearData();
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear data: $failure')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data cleared successfully')),
        );
      },
    );
  }

  /// Show current configuration
  void _showConfig() {
    final configResult = _httpInspector.getConfig();
    configResult.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get config: $failure')),
        );
      },
      (config) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Current Configuration'),
            content: SingleChildScrollView(
              child: Text(
                'Show Notifications: ${config.showNotifications}\n'
                'Show On Release: ${config.showOnRelease}\n'
                'Show Only Errors: ${config.showOnlyErrors}\n'
                'Max Content Length: ${config.maxContentLength}\n'
                'Show Image Preview: ${config.showImagePreview}\n'
                'Enable Sharing: ${config.enableSharing}\n'
                'Max Requests: ${config.maxRequestsToStore}\n'
                'Auto Clear: ${config.autoClearOldRequests}',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = _httpInspector.isEnabled();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('HTTP Inspector Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showConfig,
            tooltip: 'Show Config',
          ),
        ],
      ),
      // Add HTTP Inspector Button as FAB
      floatingActionButton: const HttpInspectorButton(
        label: 'Inspector',
        tooltip: 'Open HTTP Inspector',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Card(
              color: isEnabled ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      isEnabled ? Icons.check_circle : Icons.cancel,
                      color: isEnabled ? Colors.green : Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnabled
                          ? 'Inspector is ENABLED'
                          : 'Inspector is DISABLED',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Request buttons
            const Text(
              'Try Different Requests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _makeDioGetRequest,
              icon: const Icon(Icons.download),
              label: const Text('Dio GET Request'),
            ),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _makeDioPostRequest,
              icon: const Icon(Icons.upload),
              label: const Text('Dio POST Request'),
            ),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _makeHttpRequest,
              icon: const Icon(Icons.http),
              label: const Text('http Package Request'),
            ),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _makeFailingRequest,
              icon: const Icon(Icons.error),
              label: const Text('Failing Request (404)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Inspector controls
            const Text(
              'Inspector Controls:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _showInspectorUI,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Inspector UI'),
            ),

            ElevatedButton.icon(
              onPressed: _toggleInspector,
              icon: Icon(isEnabled ? Icons.toggle_on : Icons.toggle_off),
              label: Text(isEnabled ? 'Disable Inspector' : 'Enable Inspector'),
            ),

            ElevatedButton.icon(
              onPressed: _clearData,
              icon: const Icon(Icons.delete),
              label: const Text('Clear Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Result card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Result:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Text(_lastResult),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'How to Use',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Tap any request button above\n'
                      '2. Look for the notification at the top\n'
                      '3. Tap "Details" on the notification\n'
                      '4. View request/response details\n'
                      '5. Use search, filter, and share features',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}
