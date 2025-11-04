/// Internet connection status
///
/// Represents the current state of internet connectivity.
/// This is independent of the underlying connectivity checker implementation.
enum ConnectivityStatusEntity {
  /// Device has active internet connection
  /// Can send and receive data from the internet
  connected,

  /// Device has no internet connection
  /// May be connected to Wi-Fi/Mobile but no actual internet access
  disconnected,
}

extension ConnectivityStatusEntityExtension on ConnectivityStatusEntity {
  /// Check if device is connected to the internet
  bool get isConnected => this == ConnectivityStatusEntity.connected;

  /// Check if device is disconnected from the internet
  bool get isDisconnected => this == ConnectivityStatusEntity.disconnected;

  /// Get human-readable status message
  String get message {
    switch (this) {
      case ConnectivityStatusEntity.connected:
        return 'Connected to internet';
      case ConnectivityStatusEntity.disconnected:
        return 'No internet connection';
    }
  }
}

