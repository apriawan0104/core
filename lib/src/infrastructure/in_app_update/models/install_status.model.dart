/// Enum representing the status of an app update installation.
///
/// This wraps the install status from the in_app_update package
/// to provide a dependency-independent representation.
enum InstallStatus {
  /// Unknown install status.
  unknown,

  /// Install is pending - waiting to be processed.
  pending,

  /// Update is being downloaded.
  downloading,

  /// Update has been downloaded and is ready to install.
  downloaded,

  /// Update is being installed.
  installing,

  /// Update has been successfully installed.
  installed,

  /// Update installation failed.
  failed,

  /// Update installation was cancelled.
  canceled;

  /// Check if download is in progress.
  bool get isDownloading => this == InstallStatus.downloading;

  /// Check if download is complete and ready to install.
  bool get isDownloaded => this == InstallStatus.downloaded;

  /// Check if installation is in progress.
  bool get isInstalling => this == InstallStatus.installing;

  /// Check if installation is complete.
  bool get isInstalled => this == InstallStatus.installed;

  /// Check if installation failed.
  bool get isFailed => this == InstallStatus.failed;

  /// Check if installation was cancelled.
  bool get isCanceled => this == InstallStatus.canceled;

  /// Check if ready to complete flexible update.
  bool get isReadyToComplete => isDownloaded;
}

