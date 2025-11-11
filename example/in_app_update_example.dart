// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Example demonstrating how to use the In-App Update service.
///
/// This example shows:
/// 1. Service initialization
/// 2. Checking for updates
/// 3. Performing immediate updates
/// 4. Handling flexible updates
/// 5. Monitoring installation status
/// 6. Smart update strategies based on priority
///
/// ## Important Testing Notes
///
/// ⚠️ In-app updates CANNOT be tested locally!
///
/// To test this example:
/// 1. Upload your app to Play Console (Internal Test track)
/// 2. Install the app on device via Play Store
/// 3. Upload a new version with higher version code
/// 4. Run this example on the test device
///
/// See: https://developer.android.com/guide/playcore/in-app-updates/test
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupInAppUpdate();

  // Check for updates on startup
  final updateManager = UpdateManager(GetIt.instance<InAppUpdateService>());
  await updateManager.checkForUpdates();

  runApp(const InAppUpdateExampleApp());
}

/// Setup in-app update service
Future<void> setupInAppUpdate() async {
  final getIt = GetIt.instance;

  // Register in-app update service
  getIt.registerLazySingleton<InAppUpdateService>(
    () => AndroidInAppUpdateServiceImpl(),
  );

  // Initialize service
  final updateService = getIt<InAppUpdateService>();
  final result = await updateService.initialize();

  result.fold(
    (failure) => print('❌ Update service init failed: $failure'),
    (_) => print('✅ Update service initialized'),
  );
}

/// Example app demonstrating in-app updates
class InAppUpdateExampleApp extends StatelessWidget {
  const InAppUpdateExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In-App Update Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const InAppUpdateExampleScreen(),
    );
  }
}

/// Main screen with update controls
class InAppUpdateExampleScreen extends StatefulWidget {
  const InAppUpdateExampleScreen({super.key});

  @override
  _InAppUpdateExampleScreenState createState() =>
      _InAppUpdateExampleScreenState();
}

class _InAppUpdateExampleScreenState extends State<InAppUpdateExampleScreen>
    with WidgetsBindingObserver {
  final InAppUpdateService _updateService =
      GetIt.instance<InAppUpdateService>();
  AppUpdateInfo? _updateInfo;
  InstallStatus _installStatus = InstallStatus.unknown;
  bool _isChecking = false;
  String _statusMessage = 'Tap "Check for Updates" to begin';
  StreamSubscription<InstallStatus>? _installStatusSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToInstallStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _installStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check for updates when app resumes
      _checkForUpdates();
    }
  }

  void _listenToInstallStatus() {
    _installStatusSubscription = _updateService.installStatusStream.listen(
      (status) {
        setState(() {
          _installStatus = status;
          _statusMessage = 'Install status: ${status.name}';
        });

        if (status.isDownloaded) {
          _showInstallPrompt();
        } else if (status.isFailed) {
          _showMessage('Update failed', isError: true);
        } else if (status.isCanceled) {
          _showMessage('Update cancelled');
        }
      },
    );
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Checking for updates...';
    });

    final result = await _updateService.checkForUpdate();

    result.fold(
      (failure) {
        setState(() {
          _isChecking = false;
          _statusMessage = 'Error: ${failure.message}';
        });

        if (failure.code == 'ERROR_API_NOT_AVAILABLE') {
          _showMessage(
            'In-app updates not available. '
            'App must be installed via Google Play Store.',
            isError: true,
          );
        } else if (failure.code == 'PLATFORM_NOT_SUPPORTED') {
          _showMessage(
            'In-app updates are only available on Android.',
            isError: true,
          );
        } else {
          _showMessage('Failed to check for updates: ${failure.message}',
              isError: true);
        }
      },
      (info) {
        setState(() {
          _updateInfo = info;
          _isChecking = false;
        });

        if (info.isUpdateAvailable) {
          setState(() {
            _statusMessage = 'Update available: v${info.availableVersionCode}';
          });
          _showMessage(
              'Update available! Version: ${info.availableVersionCode}');
        } else {
          setState(() {
            _statusMessage = 'App is up to date';
          });
          _showMessage('Your app is up to date');
        }
      },
    );
  }

  Future<void> _performImmediateUpdate() async {
    setState(() {
      _statusMessage = 'Starting immediate update...';
    });

    final result = await _updateService.performImmediateUpdate();

    result.fold(
      (failure) {
        setState(() {
          _statusMessage = 'Update failed: ${failure.message}';
        });

        if (failure.code == 'UPDATE_CANCELLED') {
          _showMessage('Update was cancelled');
        } else {
          _showMessage('Update failed: ${failure.message}', isError: true);
        }
      },
      (_) {
        // Update completed successfully
        // Note: App should restart automatically
        setState(() {
          _statusMessage = 'Update completed! App will restart...';
        });
      },
    );
  }

  Future<void> _startFlexibleUpdate() async {
    setState(() {
      _statusMessage = 'Starting flexible update...';
    });

    final result = await _updateService.startFlexibleUpdate();

    result.fold(
      (failure) {
        setState(() {
          _statusMessage = 'Update failed: ${failure.message}';
        });
        _showMessage('Failed to start update: ${failure.message}',
            isError: true);
      },
      (_) {
        setState(() {
          _statusMessage = 'Downloading update in background...';
        });
        _showMessage('Downloading update in background...');
      },
    );
  }

  Future<void> _completeFlexibleUpdate() async {
    final result = await _updateService.completeFlexibleUpdate();

    result.fold(
      (failure) {
        _showMessage('Failed to install update: ${failure.message}',
            isError: true);
      },
      (_) {
        _showMessage('Installing update... App will restart.');
      },
    );
  }

  void _showInstallPrompt() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Update Ready'),
        content: const Text(
          'Update has been downloaded. Install now?\n\n'
          'The app will restart after installation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _completeFlexibleUpdate();
            },
            child: const Text('Install Now'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In-App Update Example'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isChecking
                              ? Icons.refresh
                              : _updateInfo?.isUpdateAvailable == true
                                  ? Icons.system_update
                                  : Icons.check_circle,
                          color: _updateInfo?.isUpdateAvailable == true
                              ? Colors.orange
                              : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    if (_updateInfo != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          'Update Available', _updateInfo!.isUpdateAvailable),
                      _buildInfoRow(
                          'Available Version',
                          _updateInfo!.availableVersionCode?.toString() ??
                              'N/A'),
                      _buildInfoRow('Update Priority',
                          '${_updateInfo!.updatePriority}/5'),
                      _buildInfoRow(
                          'Staleness Days',
                          _updateInfo!.clientVersionStalenessDays?.toString() ??
                              'N/A'),
                      _buildInfoRow('Immediate Allowed',
                          _updateInfo!.immediateUpdateAllowed),
                      _buildInfoRow('Flexible Allowed',
                          _updateInfo!.flexibleUpdateAllowed),
                      _buildInfoRow(
                          'Install Status', _installStatus.name.toUpperCase()),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Check for Updates Button
            FilledButton.icon(
              onPressed: _isChecking ? null : _checkForUpdates,
              icon: _isChecking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isChecking ? 'Checking...' : 'Check for Updates'),
            ),

            const SizedBox(height: 16),

            // Immediate Update Section
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.system_update,
                            color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Immediate Update',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Full-screen update that blocks the app until complete. '
                      'Use for critical updates.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _updateInfo?.isUpdateAvailable == true &&
                              _updateInfo!.immediateUpdateAllowed
                          ? _performImmediateUpdate
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Perform Immediate Update'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Flexible Update Section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.download, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Flexible Update',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Background download that lets users continue using the app. '
                      'Better UX for non-critical updates.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _updateInfo?.isUpdateAvailable == true &&
                                    _updateInfo!.flexibleUpdateAllowed &&
                                    !_installStatus.isDownloaded
                                ? _startFlexibleUpdate
                                : null,
                            child: const Text('Start Download'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: _installStatus.isDownloaded
                                ? _completeFlexibleUpdate
                                : null,
                            child: const Text('Install'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Testing Info
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Testing Requirements',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '⚠️ In-app updates cannot be tested locally!\n\n'
                      'To test:\n'
                      '1. Upload app to Play Console (Internal Test track)\n'
                      '2. Install on device via Play Store\n'
                      '3. Upload new version (higher version code)\n'
                      '4. Publish new version\n'
                      '5. Test on device',
                      style: TextStyle(fontSize: 12),
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

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value.toString(),
            style: TextStyle(
              color: value is bool ? (value ? Colors.green : Colors.red) : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Update manager with smart update strategy
class UpdateManager {
  final InAppUpdateService _updateService;

  UpdateManager(this._updateService);

  /// Check for updates with smart handling
  Future<void> checkForUpdates() async {
    final result = await _updateService.checkForUpdate();

    await result.fold(
      (failure) async {
        print('❌ Update check failed: ${failure.code} - ${failure.message}');

        if (failure.code == 'ERROR_API_NOT_AVAILABLE') {
          print(
              'ℹ️ App not installed via Play Store (expected in development)');
        }
      },
      (info) async {
        if (!info.isUpdateAvailable) {
          print('✅ App is up to date');
          return;
        }

        print('📦 Update available!');
        print('   Version: ${info.availableVersionCode}');
        print('   Priority: ${info.updatePriority}/5');
        print('   Staleness: ${info.clientVersionStalenessDays ?? 0} days');

        // Smart update handling based on priority
        if (info.updatePriority == 5) {
          // Critical - force immediate update
          print('🚨 Critical update - performing immediate update');
          await _performImmediateUpdate();
        } else if (info.updatePriority >= 4) {
          // High priority - suggest immediate
          print('⚠️ High priority update - suggesting immediate update');
          // In real app, show dialog to user
          await _performImmediateUpdate();
        } else {
          // Normal priority - flexible update
          print('ℹ️ Normal priority - starting flexible update');
          await _startFlexibleUpdate();
        }
      },
    );
  }

  Future<void> _performImmediateUpdate() async {
    final result = await _updateService.performImmediateUpdate();

    result.fold(
      (failure) => print('❌ Immediate update failed: $failure'),
      (_) => print('✅ Immediate update completed'),
    );
  }

  Future<void> _startFlexibleUpdate() async {
    final result = await _updateService.startFlexibleUpdate();

    result.fold(
      (failure) => print('❌ Flexible update failed: $failure'),
      (_) {
        print('✅ Flexible update started');
        _listenToInstallStatus();
      },
    );
  }

  void _listenToInstallStatus() {
    _updateService.installStatusStream.listen((status) {
      print('📊 Install status: ${status.name}');

      if (status.isDownloaded) {
        print('✅ Update downloaded - ready to install');
        // In real app, show prompt to user
      } else if (status.isFailed) {
        print('❌ Update failed');
      } else if (status.isCanceled) {
        print('ℹ️ Update cancelled');
      }
    });
  }
}
