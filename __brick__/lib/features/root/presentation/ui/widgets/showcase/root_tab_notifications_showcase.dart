import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show DateTimeComponents;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../common/imports/imports.dart';
import '../../../../../../core/injection/injectable.dart';
import '../../../../../../core/notification/notification_coordinator.dart';

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
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.s16w600),
        AppSpacing.sm.verticalSpace,
        ...children,
        AppSpacing.lg.verticalSpace,
        const Divider(height: 1),
        AppSpacing.lg.verticalSpace,
      ],
    );
  }

  Future<void> _checkPermission() async {
    final granted = await _coordinator.isNotificationPermissionGranted();
    _toast(granted ? 'Permission: granted' : 'Permission: not granted');
  }

  Future<void> _requestPermission() async {
    final granted = await _coordinator.requestNotificationPermission(
      openSettingsIfPermanentlyDenied: true,
    );
    _toast(granted ? 'Permission granted' : 'Permission denied');
  }

  Future<void> _showInstant() async {
    await _coordinator.showLocal(
      title: 'Instant notification',
      body: 'This is shown immediately.',
      data: <String, dynamic>{'route': '/root_screen', 'type': 'instant'},
    );
    _toast('Instant notification requested');
  }

  Future<void> _scheduleOnceIn5Seconds() async {
    final date = DateTime.now().add(const Duration(seconds: 5));
    await _coordinator.scheduleLocal(
      id: _scheduledOnceId,
      title: 'Scheduled notification',
      body: 'Scheduled for ~5 seconds from now.',
      date: date,
      data: <String, dynamic>{
        'route': '/root_screen',
        'type': 'scheduled_once',
      },
    );
    _toast('Scheduled (id=$_scheduledOnceId)');
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
      title: 'Daily repeating notification',
      body: 'This repeats daily at the same time.',
      date: nextMinute,
      matchDateTimeComponents: DateTimeComponents.time,
      data: <String, dynamic>{'route': '/root_screen', 'type': 'daily'},
    );

    _toast('Daily schedule set (id=$_dailyId)');
  }

  Future<void> _cancelScheduledOnce() async {
    await _coordinator.cancelLocal(_scheduledOnceId);
    _toast('Canceled (id=$_scheduledOnceId)');
  }

  Future<void> _cancelDaily() async {
    await _coordinator.cancelLocal(_dailyId);
    _toast('Canceled (id=$_dailyId)');
  }

  Future<void> _cancelAll() async {
    await _coordinator.cancelAllLocal();
    _toast('Canceled all notifications');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.standardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Local Notifications Showcase', style: AppTextStyles.s22w700),
          AppSpacing.sm.verticalSpace,
          Text(
            'Demonstrates permission, instant notifications, scheduled notifications, and repeating schedules.',
            style: AppTextStyles.s14w400.copyWith(
              color: context.onSurface.withValues(alpha: 0.75),
            ),
          ),
          AppSpacing.lg.verticalSpace,

          _section('Permission', [
            AppButton.primary(
              onTap: _checkPermission,
              child: AppButtonChild.labelIcon(
                label: 'Check permission',
                icon: IconSource.icon(Icons.verified_rounded),
              ),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primaryGradient(
              onTap: _requestPermission,
              child: AppButtonChild.labelIcon(
                label: 'Request permission',
                icon: IconSource.icon(Icons.notifications_rounded),
              ),
            ),
          ]),

          _section('Instant', [
            AppButton.success(
              onTap: _showInstant,
              child: AppButtonChild.label('Show instant notification'),
            ),
          ]),

          _section('Scheduled / repeating', [
            AppButton.warning(
              onTap: _scheduleOnceIn5Seconds,
              child: AppButtonChild.label(
                'Schedule in 5 seconds (id=$_scheduledOnceId)',
              ),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.warningGradient(
              onTap: _scheduleDailyAtNextMinute,
              child: AppButtonChild.label(
                'Schedule repeating daily (id=$_dailyId)',
              ),
            ),
          ]),

          _section('Cancel', [
            AppButton.grey(
              onTap: _cancelScheduledOnce,
              child: AppButtonChild.label(
                'Cancel scheduled once (id=$_scheduledOnceId)',
              ),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.grey(
              onTap: _cancelDaily,
              child: AppButtonChild.label('Cancel daily (id=$_dailyId)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.error(
              onTap: _cancelAll,
              child: AppButtonChild.label('Cancel all'),
            ),
          ]),

          AppSpacing.xl.verticalSpace,
        ],
      ),
    );
  }
}
