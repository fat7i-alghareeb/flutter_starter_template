import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../core/injection/injectable.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/services/session/auth_state_notifier.dart';
import '../../../../../core/services/session/pending_action.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/helpers/app_strings.dart';
import '../screens/login_screen.dart';

/// Runs a protected action — now for a signed-in reader, after the sign-in
/// sheet for a guest (`AuthMode.guestFirst`).
///
/// ```dart
/// AuthGate.run(context, ProtectedAction.save, () async {
///   context.read<ItemBloc>().add(const ItemEvent.saveToggled());
/// });
/// ```
class AuthGate {
  AuthGate._();

  static Future<void> run(
    BuildContext context,
    ProtectedAction action,
    Future<void> Function() onGranted,
  ) async {
    final session = getIt<AuthStateNotifier>();
    if (session.isAuthenticated) return onGranted();
    await AuthGateSheet.show(context, action: action, onGranted: onGranted);
  }
}

/// The sheet a guest sees when they touch a protected action.
///
/// There is **no forced sign-in screen** in guest-first mode: this sheet
/// appears only at the moment an action needs an account.
///
/// It names the action — «Sign in to save this», not a generic prompt —
/// because a user who is told why they are signing in signs in; a user handed
/// a wall leaves.
///
/// Call [show] and pass what to do afterwards. On success the action runs on
/// its own (`PendingActionQueue`) and the user stays exactly where they were.
class AuthGateSheet extends StatelessWidget {
  const AuthGateSheet._({required this.action});

  final ProtectedAction action;

  /// Opens the gate for [action], remembering [onGranted] to run after sign-in.
  ///
  /// Returns true when the user signed in, false when they backed out.
  static Future<bool> show(
    BuildContext context, {
    required ProtectedAction action,
    required Future<void> Function() onGranted,
  }) async {
    getIt<PendingActionQueue>().remember(action, onGranted);

    final granted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AuthGateSheet._(action: action),
    );

    if (granted != true) {
      // Backing out must not leave an intent armed — it would then fire on
      // some later, unrelated sign-in.
      getIt<PendingActionQueue>().clear();
    }
    return granted ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.lg,
              end: AppSpacing.lg,
              top: AppSpacing.sm,
              // Above the keyboard when there is one, and above the system
              // bar always.
              bottom:
                  AppSpacing.lg +
                  math.max(
                    MediaQuery.viewInsetsOf(context).bottom,
                    MediaQuery.viewPaddingOf(context).bottom,
                  ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: AppStateDisc(
                    child: AppIcon(
                      action.icon,
                      size: 34,
                      color: AppStateDisc.iconColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  // The action names itself. This is the whole point.
                  action.prompt,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  action.benefit,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg2),
                FilledButton(
                  onPressed: () => _openSignIn(context),
                  child: Text(AppStrings.authSignIn),
                ),
                const SizedBox(height: AppSpacing.sm),
                // «Later» — one of the sheet's three ways out, beside the drag
                // and the scrim.
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onSurface,
                      side: BorderSide(color: colors.outlineVariant),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppStrings.authLater),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppStrings.authTerms,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }

  /// The sign-in page, pushed over the sheet. Signing in there runs the
  /// remembered action (`AuthBloc` → `PendingActionQueue`); back here the
  /// sheet closes as granted. Backing out of the page leaves the sheet up.
  static Future<void> _openSignIn(BuildContext context) async {
    final pushed = AppNavigator.push<void>(context, AppPage.login);
    await (pushed ??
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        ));
    if (!context.mounted) return;
    if (getIt<AuthStateNotifier>().isAuthenticated) {
      Navigator.of(context).pop(true);
    }
  }
}
