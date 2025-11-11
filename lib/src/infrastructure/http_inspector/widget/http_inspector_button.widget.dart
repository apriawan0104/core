import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../contract/contracts.dart';

/// A floating action button widget for HTTP Inspector
///
/// This widget provides a convenient button to open the HTTP Inspector UI
/// during development. It's useful for debugging API calls without waiting
/// for notifications.
///
/// ## Features:
/// - Floating action button with customizable position
/// - Badge showing number of captured requests (optional)
/// - Only visible in debug mode by default
/// - Customizable appearance
///
/// ## Usage:
///
/// ### Basic Usage (Floating Button):
/// ```dart
/// Scaffold(
///   body: MyContent(),
///   floatingActionButton: HttpInspectorButton(),
/// )
/// ```
///
/// ### Custom Position:
/// ```dart
/// Stack(
///   children: [
///     MyContent(),
///     Positioned(
///       right: 16,
///       bottom: 80,
///       child: HttpInspectorButton(
///         position: HttpInspectorButtonPosition.bottomRight,
///       ),
///     ),
///   ],
/// )
/// ```
///
/// ### Custom Appearance:
/// ```dart
/// HttpInspectorButton(
///   backgroundColor: Colors.red,
///   icon: Icons.network_check,
///   size: 56,
///   label: 'API Debug',
/// )
/// ```
class HttpInspectorButton extends StatelessWidget {
  /// HTTP Inspector service instance
  final HttpInspectorService? service;

  /// Background color of the button
  final Color? backgroundColor;

  /// Icon to display
  final IconData icon;

  /// Size of the button
  final double size;

  /// Optional label text
  final String? label;

  /// Whether to show badge with request count
  final bool showBadge;

  /// Tooltip text
  final String? tooltip;

  /// Button position hint
  final HttpInspectorButtonPosition position;

  /// Whether to show only in debug mode
  final bool debugModeOnly;

  const HttpInspectorButton({
    super.key,
    this.service,
    this.backgroundColor,
    this.icon = Icons.bug_report,
    this.size = 56,
    this.label,
    this.showBadge = false,
    this.tooltip,
    this.position = HttpInspectorButtonPosition.bottomRight,
    this.debugModeOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get service from DI if not provided
    final inspectorService = service ?? _getServiceFromDI();

    if (inspectorService == null) {
      return const SizedBox.shrink();
    }

    // Check if should be visible
    if (debugModeOnly && !inspectorService.isEnabled()) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.secondary;

    // Build button content
    Widget button;

    if (label != null) {
      // Extended FAB with label
      button = FloatingActionButton.extended(
        onPressed: () => _openInspector(context, inspectorService),
        backgroundColor: effectiveBackgroundColor,
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip ?? 'Open HTTP Inspector',
      );
    } else {
      // Regular FAB
      button = SizedBox(
        width: size,
        height: size,
        child: FloatingActionButton(
          onPressed: () => _openInspector(context, inspectorService),
          backgroundColor: effectiveBackgroundColor,
          tooltip: tooltip ?? 'Open HTTP Inspector',
          child: Icon(icon),
        ),
      );
    }

    // Add badge if enabled
    if (showBadge) {
      button = Badge(
        label: const Text('•'),
        backgroundColor: Colors.red,
        child: button,
      );
    }

    return button;
  }

  /// Get service from DI container
  HttpInspectorService? _getServiceFromDI() {
    try {
      return GetIt.instance<HttpInspectorService>();
    } catch (e) {
      debugPrint('HttpInspectorButton: Service not registered in DI');
      return null;
    }
  }

  /// Open HTTP Inspector UI
  Future<void> _openInspector(
    BuildContext context,
    HttpInspectorService service,
  ) async {
    final result = await service.showInspectorUI(context);

    result.fold(
      (failure) {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open inspector: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (_) {
        // Success - inspector opened
      },
    );
  }
}

/// Position options for HTTP Inspector Button
enum HttpInspectorButtonPosition {
  /// Bottom right corner
  bottomRight,

  /// Bottom left corner
  bottomLeft,

  /// Top right corner
  topRight,

  /// Top left corner
  topLeft,

  /// Custom position (use with Positioned widget)
  custom,
}
