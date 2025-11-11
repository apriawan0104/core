import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../contract/contracts.dart';

/// A draggable overlay widget for HTTP Inspector
///
/// This widget provides a floating, draggable button that stays on top
/// of your app's UI, making it easy to access HTTP Inspector during
/// development without taking up space in your layout.
///
/// ## Features:
/// - Draggable button that can be moved anywhere on screen
/// - Minimizes to small icon when not in use
/// - Can be expanded to show quick stats
/// - Only visible in debug mode by default
/// - Automatically hides in production builds
///
/// ## Usage:
///
/// ### Wrap Your App:
/// ```dart
/// MaterialApp(
///   home: HttpInspectorOverlay(
///     child: MyHomePage(),
///   ),
/// )
/// ```
///
/// ### With Custom Position:
/// ```dart
/// HttpInspectorOverlay(
///   initialPosition: Offset(20, 100),
///   child: MyHomePage(),
/// )
/// ```
///
/// ### Custom Appearance:
/// ```dart
/// HttpInspectorOverlay(
///   backgroundColor: Colors.red.shade700,
///   icon: Icons.network_check,
///   child: MyHomePage(),
/// )
/// ```
class HttpInspectorOverlay extends StatefulWidget {
  /// Child widget
  final Widget child;

  /// HTTP Inspector service instance
  final HttpInspectorService? service;

  /// Initial position of the button
  final Offset? initialPosition;

  /// Background color
  final Color? backgroundColor;

  /// Icon to display
  final IconData icon;

  /// Size of the button when minimized
  final double size;

  /// Whether to show only in debug mode
  final bool debugModeOnly;

  /// Whether to show the overlay
  final bool enabled;

  const HttpInspectorOverlay({
    super.key,
    required this.child,
    this.service,
    this.initialPosition,
    this.backgroundColor,
    this.icon = Icons.bug_report,
    this.size = 56,
    this.debugModeOnly = true,
    this.enabled = true,
  });

  @override
  State<HttpInspectorOverlay> createState() => _HttpInspectorOverlayState();
}

class _HttpInspectorOverlayState extends State<HttpInspectorOverlay> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition ?? const Offset(20, 100);
  }

  @override
  Widget build(BuildContext context) {
    // Don't show if disabled or in release mode (when debugModeOnly is true)
    if (!widget.enabled || (widget.debugModeOnly && kReleaseMode)) {
      return widget.child;
    }

    // Get service
    final service = widget.service ?? _getServiceFromDI();
    if (service == null || !service.isEnabled()) {
      return widget.child;
    }

    return Stack(
      children: [
        // Main app content
        widget.child,

        // Draggable button overlay
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: Draggable(
            feedback: _buildButton(context, service, isDragging: true),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: _buildButton(context, service),
            ),
            onDragEnd: (details) {
              setState(() {
                _position = details.offset;
              });
            },
            child: _buildButton(context, service),
          ),
        ),
      ],
    );
  }

  /// Build the floating button
  Widget _buildButton(
    BuildContext context,
    HttpInspectorService service, {
    bool isDragging = false,
  }) {
    final theme = Theme.of(context);
    final backgroundColor =
        widget.backgroundColor ?? theme.colorScheme.secondary.withOpacity(0.9);

    return GestureDetector(
      onTap: () => _openInspector(context, service),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.size / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: isDragging ? 12 : 8,
              spreadRadius: isDragging ? 2 : 0,
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: widget.size * 0.5,
        ),
      ),
    );
  }

  /// Get service from DI
  HttpInspectorService? _getServiceFromDI() {
    try {
      return GetIt.instance<HttpInspectorService>();
    } catch (e) {
      debugPrint('HttpInspectorOverlay: Service not registered in DI');
      return null;
    }
  }

  /// Open inspector
  Future<void> _openInspector(
    BuildContext context,
    HttpInspectorService service,
  ) async {
    final result = await service.showInspectorUI(context);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (_) {
        // Success
      },
    );
  }
}
