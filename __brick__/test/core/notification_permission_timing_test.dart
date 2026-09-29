import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/notification/notification_config.dart';
import 'package:{{project_name}}/core/notification/notification_coordinator.dart';
import 'package:{{project_name}}/core/notification/notification_fcm_service.dart';
import 'package:{{project_name}}/core/notification/notification_init_options.dart';
import 'package:{{project_name}}/core/notification/notification_local_service.dart';
import 'package:{{project_name}}/core/notification/notification_permission_service.dart';
import 'package:{{project_name}}/core/notification/notification_timezone_service.dart';

class _MockPermission extends Mock implements NotificationPermissionService {}

class _MockTimezone extends Mock implements NotificationTimezoneService {}

class _MockLocal extends Mock implements NotificationLocalService {}

class _MockFcm extends Mock implements NotificationFcmService {}

/// The notification prompt is asked from the shell, never at start-up —
/// where it would land on top of onboarding on a first launch.
void main() {
  late _MockPermission permission;
  late NotificationCoordinator coordinator;

  setUp(() {
    permission = _MockPermission();
    final timezone = _MockTimezone();
    final local = _MockLocal();

    when(
      () => permission.requestNotificationPermission(
        enableDebugLogs: any(named: 'enableDebugLogs'),
        openSettingsIfPermanentlyDenied: any(
          named: 'openSettingsIfPermanentlyDenied',
        ),
      ),
    ).thenAnswer((_) async => true);
    when(
      permission.isNotificationPermissionGranted,
    ).thenAnswer((_) async => true);
    when(
      () => timezone.initialize(enableDebugLogs: any(named: 'enableDebugLogs')),
    ).thenAnswer((_) async {});
    when(
      () => local.initialize(
        config: any(named: 'config'),
        onNotificationTap: any(named: 'onNotificationTap'),
        requestPermissions: any(named: 'requestPermissions'),
      ),
    ).thenAnswer((_) async {});

    coordinator = NotificationCoordinator(
      permission,
      timezone,
      local,
      _MockFcm(),
    );
  });

  setUpAll(() {
    registerFallbackValue(AppNotificationConfig.defaults());
  });

  test('start-up with the app\'s options asks for nothing', () async {
    await coordinator.initialize(
      config: AppNotificationConfig.defaults(),
      onNotificationTap: (_) async {},
      options: const NotificationInitOptions(
        enableFcm: false,
        requestPermissionsAtStartup: false,
      ),
    );

    verifyNever(
      () => permission.requestNotificationPermission(
        enableDebugLogs: any(named: 'enableDebugLogs'),
        openSettingsIfPermanentlyDenied: any(
          named: 'openSettingsIfPermanentlyDenied',
        ),
      ),
    );
  });

  test('the shell asks once per launch, however often it comes up', () async {
    await coordinator.requestPermissionFromShell();
    await coordinator.requestPermissionFromShell();

    verify(
      () => permission.requestNotificationPermission(
        enableDebugLogs: any(named: 'enableDebugLogs'),
        openSettingsIfPermanentlyDenied: any(
          named: 'openSettingsIfPermanentlyDenied',
        ),
      ),
    ).called(1);
  });
}
