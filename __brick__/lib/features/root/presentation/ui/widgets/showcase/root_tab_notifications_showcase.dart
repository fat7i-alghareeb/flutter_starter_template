import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show DateTimeComponents;

import '../../../../../../common/imports/imports.dart';
import '../../../../../../core/notification/notification_coordinator.dart';
import '../../../../constants/root_constants.dart';
import 'showcase_layout.dart';

class RootTabNotificationsShowcase extends StatefulWidget {
  const RootTabNotificationsShowcase({super.key});

  @override
  State<RootTabNotificationsShowcase> createState() =>
      _RootTabNotificationsShowcaseState();
}

class _RootTabNotificationsShowcaseState
    extends State<RootTabNotificationsShowcase> {
  NotificationCoordinator get _coordinator => getIt<NotificationCoordinator>();

  static const int _scheduledOnceId = 102;
  static const int _dailyId = 103;

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppSnackContent(msg),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  Future<void> _checkPermission() async {
    final granted = await _coordinator.isNotificationPermissionGranted();
    _toast(
      granted
          ? AppStrings.showcaseNotificationsPermissionGranted
          : AppStrings.showcaseNotificationsPermissionNotGranted,
    );
  }

  Future<void> _requestPermission() async {
    final granted = await _coordinator.requestNotificationPermission(
      openSettingsIfPermanentlyDenied: true,
    );
    _toast(
      granted
          ? AppStrings.showcaseNotificationsPermissionGranted
          : AppStrings.showcaseNotificationsPermissionDenied,
    );
  }

  Future<void> _showInstant() async {
    await _coordinator.showLocal(
      title: AppStrings.showcaseNotificationsInstantTitle,
      body: AppStrings.showcaseNotificationsInstantBody,
      data: <String, dynamic>{
        'route': RootConstants.routePath,
        'type': 'instant',
      },
    );
    _toast(AppStrings.showcaseNotificationsInstantRequested);
  }

  Future<void> _scheduleOnceIn5Seconds() async {
    final date = DateTime.now().add(const Duration(seconds: 5));
    await _coordinator.scheduleLocal(
      id: _scheduledOnceId,
      title: AppStrings.showcaseNotificationsOnceTitle,
      body: AppStrings.showcaseNotificationsOnceBody,
      date: date,
      data: <String, dynamic>{
        'route': RootConstants.routePath,
        'type': 'scheduled_once',
      },
    );
    _toast(AppStrings.showcaseNotificationsScheduled(_scheduledOnceId));
  }

  Future<void> _scheduleDailyAtNextMinute() async {
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    ).add(const Duration(minutes: 1));

    await _coordinator.scheduleLocal(
      id: _dailyId,
      title: AppStrings.showcaseNotificationsDailyTitle,
      body: AppStrings.showcaseNotificationsDailyBody,
      date: nextMinute,
      matchDateTimeComponents: DateTimeComponents.time,
      data: <String, dynamic>{
        'route': RootConstants.routePath,
        'type': 'daily',
      },
    );

    _toast(AppStrings.showcaseNotificationsDailySet(_dailyId));
  }

  Future<void> _cancelScheduledOnce() async {
    await _coordinator.cancelLocal(_scheduledOnceId);
    _toast(AppStrings.showcaseNotificationsCanceled(_scheduledOnceId));
  }

  Future<void> _cancelDaily() async {
    await _coordinator.cancelLocal(_dailyId);
    _toast(AppStrings.showcaseNotificationsCanceled(_dailyId));
  }

  Future<void> _cancelAll() async {
    await _coordinator.cancelAllLocal();
    _toast(AppStrings.showcaseNotificationsCanceledAll);
  }

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: AppStrings.showcaseNotificationsTitle,
      subtitle: AppStrings.showcaseNotificationsSubtitle,
      children: <Widget>[
        ShowcaseSection(
          title: AppStrings.showcaseNotificationsSectionPermission,
          children: <Widget>[
            AppButton.primary(
              onTap: _checkPermission,
              child: AppButtonChild.labelIcon(
                label: AppStrings.showcaseNotificationsCheckPermission,
                icon: IconSource.svg(AppIcons.success),
              ),
            ),
            AppButton.primaryGradient(
              onTap: _requestPermission,
              child: AppButtonChild.labelIcon(
                label: AppStrings.showcaseNotificationsRequestPermission,
                icon: IconSource.svg(AppIcons.bell),
              ),
            ),
          ],
        ),

        ShowcaseSection(
          title: AppStrings.showcaseNotificationsSectionInstant,
          children: <Widget>[
            AppButton.success(
              onTap: _showInstant,
              child: AppButtonChild.label(
                AppStrings.showcaseNotificationsShowInstant,
              ),
            ),
          ],
        ),

        ShowcaseSection(
          title: AppStrings.showcaseNotificationsSectionScheduled,
          children: <Widget>[
            AppButton.warning(
              onTap: _scheduleOnceIn5Seconds,
              child: AppButtonChild.label(
                AppStrings.showcaseNotificationsScheduleOnce(_scheduledOnceId),
              ),
            ),
            AppButton.warningGradient(
              onTap: _scheduleDailyAtNextMinute,
              child: AppButtonChild.label(
                AppStrings.showcaseNotificationsScheduleDaily(_dailyId),
              ),
            ),
          ],
        ),

        ShowcaseSection(
          title: AppStrings.cancel,
          children: <Widget>[
            AppButton.error(
              onTap: _cancelScheduledOnce,
              child: AppButtonChild.label(
                AppStrings.showcaseNotificationsCancelOnce(_scheduledOnceId),
              ),
            ),
            AppButton.error(
              onTap: _cancelDaily,
              child: AppButtonChild.label(
                AppStrings.showcaseNotificationsCancelDaily(_dailyId),
              ),
            ),
            AppButton.error(
              onTap: _cancelAll,
              child: AppButtonChild.label(
                AppStrings.showcaseNotificationsCancelAll,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
