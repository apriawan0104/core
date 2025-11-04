// ignore_for_file: avoid_print, unused_field

/// WebView Example
///
/// This example demonstrates how to use the WebView service from BUMA Core.
///
/// Features demonstrated:
/// - WebView initialization with configuration
/// - Loading URLs
/// - JavaScript execution
/// - JavaScript channels (Dart ↔ JS communication)
/// - Navigation controls (back, forward, reload)
/// - Navigation delegate (page events, progress, errors)
/// - Cookie management
/// - Loading HTML string
///
/// To run this example:
/// 1. Make sure you've set up the platform-specific configuration (see QUICK_START.md)
/// 2. Register the services in your DI container
/// 3. Use the WebViewExamplePage widget in your app

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:webview_flutter/webview_flutter.dart';

final getIt = GetIt.instance;

/// Setup WebView services in DI container
void setupWebViewServices() {
  // Register WebView Service
  getIt.registerLazySingleton<WebViewService>(
    () => FlutterWebViewServiceImpl(),
  );

  // Register Cookie Service
  getIt.registerLazySingleton<WebViewCookieService>(
    () => FlutterWebViewCookieServiceImpl(),
  );
}

/// Example app entry point
void main() {
  // Setup DI
  setupWebViewServices();

  runApp(const WebViewExampleApp());
}

class WebViewExampleApp extends StatelessWidget {
  const WebViewExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WebViewExamplePage(),
    );
  }
}

class WebViewExamplePage extends StatefulWidget {
  const WebViewExamplePage({Key? key}) : super(key: key);

  @override
  State<WebViewExamplePage> createState() => _WebViewExamplePageState();
}

class _WebViewExamplePageState extends State<WebViewExamplePage> {
  late final WebViewService _webViewService;
  late final WebViewCookieService _cookieService;

  bool _isInitialized = false;
  bool _isLoading = false;
  double _progress = 0.0;
  String? _currentUrl;
  String? _pageTitle;
  String? _error;
  final List<String> _jsMessages = [];

  final TextEditingController _urlController = TextEditingController(
    text: 'https://flutter.dev',
  );

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    try {
      // Get services from DI
      _webViewService = getIt<WebViewService>();
      _cookieService = getIt<WebViewCookieService>();

      // Configure webview
      final config = WebViewConfig(
        javaScriptEnabled: true,
        zoomEnabled: true,
        backgroundColor: 0xFFFFFFFF,
        debuggingEnabled: true, // Enable debugging for development
        gestureNavigationEnabled: true,
        localStorageEnabled: true,
        domStorageEnabled: true,
      );

      // Initialize
      final initResult = await _webViewService.initialize(config);

      await initResult.fold(
        (failure) async {
          setState(() {
            _error = 'Initialization failed: ${failure.message}';
          });
        },
        (_) async {
          // Setup navigation delegate
          await _setupNavigationDelegate();

          // Setup JavaScript channel for communication
          await _setupJavaScriptChannel();

          // Load initial URL
          await _loadUrl(_urlController.text);

          setState(() {
            _isInitialized = true;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    }
  }

  Future<void> _setupNavigationDelegate() async {
    await _webViewService.setNavigationDelegate(
      onNavigationRequest: (request) {
        print('Navigation request: ${request.url}');

        // Example: Block navigation to youtube.com
        if (request.url.contains('youtube.com')) {
          _showSnackBar('Navigation to YouTube is blocked');
          return WebViewNavigationDecision.prevent;
        }

        return WebViewNavigationDecision.navigate;
      },
      onPageStarted: (url) {
        print('Page started: $url');
        setState(() {
          _isLoading = true;
          _currentUrl = url;
        });
      },
      onPageFinished: (url) async {
        print('Page finished: $url');

        // Get page title
        final titleResult = await _webViewService.getTitle();
        titleResult.fold(
          (failure) => null,
          (title) {
            setState(() {
              _pageTitle = title;
            });
          },
        );

        setState(() {
          _isLoading = false;
        });
      },
      onProgress: (progress) {
        setState(() {
          _progress = progress / 100.0;
        });
      },
      onWebResourceError: (error) {
        print('Web resource error: ${error.description}');
        if (error.isForMainFrame) {
          _showSnackBar('Error: ${error.description}');
        }
      },
      onHttpError: (error) {
        print('HTTP error: ${error.statusCode}');
        _showSnackBar('HTTP Error: ${error.statusCode}');
      },
    );
  }

  Future<void> _setupJavaScriptChannel() async {
    final channel = WebViewJavaScriptChannel(
      name: 'FlutterChannel',
      onMessageReceived: (message) {
        print('Message from JavaScript: $message');
        setState(() {
          _jsMessages.add(message);
        });
        _showSnackBar('JS Message: $message');
      },
    );

    await _webViewService.addJavaScriptChannel(channel);
  }

  Future<void> _loadUrl(String url) async {
    if (!_isInitialized) {
      _showSnackBar('WebView not initialized yet');
      return;
    }

    // Validate URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final result = await _webViewService.loadUrl(url);

    result.fold(
      (failure) {
        _showSnackBar('Failed to load URL: ${failure.message}');
      },
      (_) {
        print('URL loaded successfully');
      },
    );
  }

  Future<void> _goBack() async {
    final canGoBackResult = await _webViewService.canGoBack();

    canGoBackResult.fold(
      (failure) => _showSnackBar('Error: ${failure.message}'),
      (canGoBack) async {
        if (canGoBack) {
          await _webViewService.goBack();
        } else {
          _showSnackBar('Cannot go back');
        }
      },
    );
  }

  Future<void> _goForward() async {
    final canGoForwardResult = await _webViewService.canGoForward();

    canGoForwardResult.fold(
      (failure) => _showSnackBar('Error: ${failure.message}'),
      (canGoForward) async {
        if (canGoForward) {
          await _webViewService.goForward();
        } else {
          _showSnackBar('Cannot go forward');
        }
      },
    );
  }

  Future<void> _reload() async {
    final result = await _webViewService.reload();
    result.fold(
      (failure) => _showSnackBar('Error: ${failure.message}'),
      (_) => print('Page reloaded'),
    );
  }

  Future<void> _executeJavaScript() async {
    // Example: Show alert in web page
    final result = await _webViewService.runJavaScript(
      "alert('Hello from Flutter!');",
    );

    result.fold(
      (failure) => _showSnackBar('JS Error: ${failure.message}'),
      (_) => _showSnackBar('JavaScript executed'),
    );
  }

  Future<void> _getPageInfo() async {
    // Get page title
    final titleResult = await _webViewService.runJavaScriptReturningResult(
      'document.title',
    );

    // Get page URL
    final urlResult = await _webViewService.currentUrl();

    titleResult.fold(
      (failure) => null,
      (jsResult) {
        final title = jsResult.asString() ?? 'No title';
        urlResult.fold(
          (failure) => null,
          (url) {
            _showDialog(
              'Page Info',
              'Title: $title\n\nURL: ${url ?? "Unknown"}',
            );
          },
        );
      },
    );
  }

  Future<void> _loadLocalHtml() async {
    final html = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body {
          font-family: Arial, sans-serif;
          padding: 20px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
        }
        .container {
          background: rgba(255, 255, 255, 0.1);
          padding: 20px;
          border-radius: 10px;
          backdrop-filter: blur(10px);
        }
        button {
          background: white;
          color: #667eea;
          border: none;
          padding: 15px 30px;
          font-size: 16px;
          border-radius: 5px;
          cursor: pointer;
          margin: 10px 5px;
        }
        button:hover {
          transform: scale(1.05);
          transition: transform 0.2s;
        }
        #counter {
          font-size: 48px;
          font-weight: bold;
          margin: 20px 0;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🎉 Local HTML Demo</h1>
        <p>This HTML is loaded directly from Dart!</p>
        
        <div id="counter">0</div>
        
        <button onclick="increment()">Increment</button>
        <button onclick="sendToDart()">Send to Dart</button>
        <button onclick="sendJson()">Send JSON</button>
      </div>
      
      <script>
        let count = 0;
        
        function increment() {
          count++;
          document.getElementById('counter').textContent = count;
        }
        
        function sendToDart() {
          FlutterChannel.postMessage('Counter value: ' + count);
        }
        
        function sendJson() {
          const data = {
            action: 'counter_update',
            value: count,
            timestamp: new Date().toISOString()
          };
          FlutterChannel.postMessage(JSON.stringify(data));
        }
      </script>
    </body>
    </html>
    ''';

    final result = await _webViewService.loadHtmlString(html);

    result.fold(
      (failure) => _showSnackBar('Error: ${failure.message}'),
      (_) => _showSnackBar('Local HTML loaded'),
    );
  }

  Future<void> _manageCookies() async {
    // Set a cookie
    final cookie = WebViewCookieData(
      name: 'example_cookie',
      value: 'flutter_webview_${DateTime.now().millisecondsSinceEpoch}',
      domain: 'flutter.dev',
      path: '/',
    );

    final result = await _cookieService.setCookie(cookie);

    result.fold(
      (failure) => _showSnackBar('Cookie error: ${failure.message}'),
      (_) => _showSnackBar('Cookie set successfully'),
    );
  }

  Future<void> _clearData() async {
    final cacheResult = await _webViewService.clearCache();
    final storageResult = await _webViewService.clearLocalStorage();
    final cookiesResult = await _cookieService.clearAllCookies();

    if (cacheResult.isRight() &&
        storageResult.isRight() &&
        cookiesResult.isRight()) {
      _showSnackBar('All data cleared');
    } else {
      _showSnackBar('Error clearing some data');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showJavaScriptMessages() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JavaScript Messages'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _jsMessages.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.message),
                title: Text(_jsMessages[index]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _jsMessages.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get controller from implementation
    final controller =
        (_webViewService as FlutterWebViewServiceImpl).controller;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('WebView Example', style: TextStyle(fontSize: 16)),
            if (_pageTitle != null)
              Text(
                _pageTitle!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
        actions: [
          if (_jsMessages.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: _showJavaScriptMessages,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_jsMessages.length}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'info':
                  _getPageInfo();
                  break;
                case 'js':
                  _executeJavaScript();
                  break;
                case 'html':
                  _loadLocalHtml();
                  break;
                case 'cookies':
                  _manageCookies();
                  break;
                case 'clear':
                  _clearData();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Text('Get Page Info'),
              ),
              const PopupMenuItem(
                value: 'js',
                child: Text('Execute JavaScript'),
              ),
              const PopupMenuItem(
                value: 'html',
                child: Text('Load Local HTML'),
              ),
              const PopupMenuItem(
                value: 'cookies',
                child: Text('Manage Cookies'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Data'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // URL bar
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'Enter URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: _loadUrl,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _loadUrl(_urlController.text),
                ),
              ],
            ),
          ),

          // WebView
          Expanded(
            child: controller != null
                ? WebViewWidget(controller: controller)
                : const Center(child: Text('WebView not available')),
          ),

          // Navigation bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goBack,
                  tooltip: 'Back',
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _goForward,
                  tooltip: 'Forward',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _reload,
                  tooltip: 'Reload',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
