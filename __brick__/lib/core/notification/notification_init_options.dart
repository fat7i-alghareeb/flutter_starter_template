class NotificationInitOptions {
  const NotificationInitOptions({
    this.initializeFirebase = true,
    this.enableFcm = true,
    this.requestPermissionsAtStartup = true,
  });

  /// Whether this module should call `Firebase.initializeApp()` internally.
  ///
  /// Set this to `false` if your project initializes Firebase elsewhere.
  final bool initializeFirebase;

  /// Whether FCM (firebase_messaging) should be enabled.
  ///
  /// If disabled, the module will only provide local notifications.
  final bool enableFcm;

  /// Whether notification permissions should be requested during initialization.
  ///
  /// This uses `permission_handler`.
  final bool requestPermissionsAtStartup;
}
