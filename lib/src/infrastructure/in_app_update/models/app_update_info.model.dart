import 'install_status.model.dart';
import 'update_availability.model.dart';

/// Model representing information about an available app update.
///
/// This wraps the AppUpdateInfo from the in_app_update package
/// to provide a dependency-independent representation.
///
/// ## Properties
///
/// - [updateAvailability]: Whether an update is available
/// - [immediateUpdateAllowed]: Whether immediate update is allowed
/// - [flexibleUpdateAllowed]: Whether flexible update is allowed
/// - [availableVersionCode]: Version code of the available update (Android only)
/// - [installStatus]: Current installation status
/// - [packageName]: The package name of the app
/// - [clientVersionStalenessDays]: Days since update became available (nullable)
/// - [updatePriority]: Priority of the update (0-5, where 5 is highest)
class AppUpdateInfo {
  /// Availability status of the update.
  final UpdateAvailability updateAvailability;

  /// Whether immediate update type is allowed.
  final bool immediateUpdateAllowed;

  /// Whether flexible update type is allowed.
  final bool flexibleUpdateAllowed;

  /// Available version code (Android version code).
  final int? availableVersionCode;

  /// Current installation status.
  final InstallStatus installStatus;

  /// Package name of the app.
  final String packageName;

  /// Number of days since the update became available.
  ///
  /// Returns null if the update is not available or if this information
  /// cannot be determined.
  final int? clientVersionStalenessDays;

  /// Update priority (0-5).
  ///
  /// Set by the developer in Play Console. Higher priority suggests
  /// a more important update. Use this to decide between immediate
  /// or flexible update flows.
  ///
  /// - 0: Default priority
  /// - 1-2: Low priority (flexible update)
  /// - 3-4: Medium priority (flexible with more prompts)
  /// - 5: High priority (immediate update)
  final int updatePriority;

  const AppUpdateInfo({
    required this.updateAvailability,
    required this.immediateUpdateAllowed,
    required this.flexibleUpdateAllowed,
    this.availableVersionCode,
    required this.installStatus,
    required this.packageName,
    this.clientVersionStalenessDays,
    this.updatePriority = 0,
  });

  /// Check if any update is available.
  bool get isUpdateAvailable => updateAvailability.isUpdateAvailable;

  /// Check if no update is available.
  bool get isUpdateNotAvailable => updateAvailability.isUpdateNotAvailable;

  /// Check if this update should be immediate based on priority.
  ///
  /// Returns true if priority >= 4 (high priority update).
  bool get shouldBeImmediate => updatePriority >= 4;

  /// Check if this update can be flexible based on priority.
  ///
  /// Returns true if priority < 4 (low to medium priority).
  bool get canBeFlexible => updatePriority < 4;

  /// Check if the update has been downloaded and ready to install.
  bool get isReadyToInstall => installStatus.isReadyToComplete;

  /// Copy with new values.
  AppUpdateInfo copyWith({
    UpdateAvailability? updateAvailability,
    bool? immediateUpdateAllowed,
    bool? flexibleUpdateAllowed,
    int? availableVersionCode,
    InstallStatus? installStatus,
    String? packageName,
    int? clientVersionStalenessDays,
    int? updatePriority,
  }) {
    return AppUpdateInfo(
      updateAvailability: updateAvailability ?? this.updateAvailability,
      immediateUpdateAllowed:
          immediateUpdateAllowed ?? this.immediateUpdateAllowed,
      flexibleUpdateAllowed:
          flexibleUpdateAllowed ?? this.flexibleUpdateAllowed,
      availableVersionCode: availableVersionCode ?? this.availableVersionCode,
      installStatus: installStatus ?? this.installStatus,
      packageName: packageName ?? this.packageName,
      clientVersionStalenessDays:
          clientVersionStalenessDays ?? this.clientVersionStalenessDays,
      updatePriority: updatePriority ?? this.updatePriority,
    );
  }

  @override
  String toString() {
    return 'AppUpdateInfo('
        'updateAvailability: $updateAvailability, '
        'immediateUpdateAllowed: $immediateUpdateAllowed, '
        'flexibleUpdateAllowed: $flexibleUpdateAllowed, '
        'availableVersionCode: $availableVersionCode, '
        'installStatus: $installStatus, '
        'packageName: $packageName, '
        'clientVersionStalenessDays: $clientVersionStalenessDays, '
        'updatePriority: $updatePriority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUpdateInfo &&
        other.updateAvailability == updateAvailability &&
        other.immediateUpdateAllowed == immediateUpdateAllowed &&
        other.flexibleUpdateAllowed == flexibleUpdateAllowed &&
        other.availableVersionCode == availableVersionCode &&
        other.installStatus == installStatus &&
        other.packageName == packageName &&
        other.clientVersionStalenessDays == clientVersionStalenessDays &&
        other.updatePriority == updatePriority;
  }

  @override
  int get hashCode {
    return Object.hash(
      updateAvailability,
      immediateUpdateAllowed,
      flexibleUpdateAllowed,
      availableVersionCode,
      installStatus,
      packageName,
      clientVersionStalenessDays,
      updatePriority,
    );
  }
}

