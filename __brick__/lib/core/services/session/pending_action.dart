import 'package:injectable/injectable.dart';

import '../../../common/widgets/ds/app_icons.dart';
import '../../../utils/helpers/app_strings.dart';
import '../../../utils/helpers/colored_print.dart';

/// The actions that need an account in [AuthMode.guestFirst].
///
/// Browsing, searching and reading stay open. Only these ask for an account,
/// and each one names itself in the sign-in sheet: the reader is told what
/// they are signing in **for**, never handed a generic «please sign in».
///
/// Add your app's own actions here — each needs a [prompt], a [benefit] and
/// an [icon].
enum ProtectedAction {
  save,
  like,
  comment,
  report,
  follow,
  openAccount,
  openNotifications,
  openSettings;

  /// The line shown in the sign-in sheet, already translated.
  String get prompt => switch (this) {
    ProtectedAction.save => AppStrings.authGateSave,
    ProtectedAction.like => AppStrings.authGateLike,
    ProtectedAction.comment => AppStrings.authGateComment,
    ProtectedAction.report => AppStrings.authGateReport,
    ProtectedAction.follow => AppStrings.authGateFollow,
    ProtectedAction.openAccount => AppStrings.authGateAccount,
    ProtectedAction.openNotifications => AppStrings.authGateNotifications,
    ProtectedAction.openSettings => AppStrings.authGateSettings,
  };

  /// What signing in gives, under the title: the reader is told what they
  /// get, not only what they are asked.
  String get benefit => switch (this) {
    ProtectedAction.save => AppStrings.authBenefitSave,
    ProtectedAction.like ||
    ProtectedAction.comment => AppStrings.authBenefitReact,
    ProtectedAction.report => AppStrings.authBenefitReport,
    ProtectedAction.follow => AppStrings.authBenefitFollow,
    ProtectedAction.openNotifications => AppStrings.authBenefitNotifications,
    ProtectedAction.openAccount ||
    ProtectedAction.openSettings => AppStrings.authBenefitSettings,
  };

  /// The action's OWN glyph — not a generic lock.
  String get icon => switch (this) {
    ProtectedAction.save => AppIcons.bookmark,
    ProtectedAction.like => AppIcons.heart,
    ProtectedAction.comment => AppIcons.comment,
    ProtectedAction.report => AppIcons.report,
    ProtectedAction.follow => AppIcons.star,
    ProtectedAction.openAccount => AppIcons.user,
    ProtectedAction.openNotifications => AppIcons.bell,
    ProtectedAction.openSettings => AppIcons.settings,
  };
}

/// Messages the auth layer passes between itself.
class PendingActionMessages {
  PendingActionMessages._();

  /// Marks a dismissed platform sign-in dialog, so the bloc can tell «the
  /// user changed their mind» apart from «sign-in broke» and stay quiet about
  /// the first.
  static const String cancelled = '__sign_in_cancelled__';
}

/// Holds what the user was doing when the sign-in gate appeared.
///
/// The point of the whole gate design: a guest taps «Save», signs in, and the
/// item is saved **for them** — they do not have to find it again and tap
/// save a second time. Without this the sign-in feels like a punishment for
/// having tried.
///
/// Only one action is ever held. A newer intent replaces an older one: the
/// user is acting on the newest thing they touched, and a queue would replay
/// forgotten taps behind their back.
@lazySingleton
class PendingActionQueue {
  PendingActionQueue();

  ProtectedAction? _action;
  Future<void> Function()? _run;

  /// What is waiting, for the sheet to describe itself with.
  ProtectedAction? get pending => _action;

  bool get hasPending => _run != null;

  /// Remembers [run] to be executed once sign-in succeeds.
  void remember(ProtectedAction action, Future<void> Function() run) {
    if (_action != null) {
      printY('[PendingAction] replacing $_action with $action');
    }
    _action = action;
    _run = run;
  }

  /// Runs and clears whatever was waiting. Safe to call with nothing pending.
  Future<void> runPending() async {
    final run = _run;
    final action = _action;
    clear();

    if (run == null) return;
    printG('[PendingAction] resuming $action');
    try {
      await run();
    } catch (error) {
      // A failed resume must not take the sign-in down with it — the user IS
      // signed in at this point, and that part succeeded.
      printR('[PendingAction] $action failed after sign-in: $error');
    }
  }

  void clear() {
    _action = null;
    _run = null;
  }
}
