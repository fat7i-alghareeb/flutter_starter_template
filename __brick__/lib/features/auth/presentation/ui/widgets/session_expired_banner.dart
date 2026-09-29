import 'package:flutter/material.dart';

import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../common/widgets/top_banner_slot.dart';
import '../../../../../core/services/session/auth_state_notifier.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/helpers/app_strings.dart';

/// «Your session has ended — sign in to continue» (`AuthMode.guestFirst`).
///
/// A session that ends without the reader asking is NOT a screen. They stay
/// where they were, browsing as a guest, and this strip at the top of the app
/// says what happened: the sentence, a way to sign in again and a way to put
/// it away.
///
/// It sits ABOVE the app, not over it — the app below is pushed down by its
/// height, so nothing on the screen (a header's bell, a back arrow) is ever
/// hidden behind it.
class SessionExpiredBanner extends StatelessWidget {
  const SessionExpiredBanner({
    super.key,
    required this.onSignIn,
    required this.onDismiss,
  });

  final VoidCallback onSignIn;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    // A soft error-tinted card under the status bar: an icon, one line, a
    // «Sign in» pill, a close.
    final tone = colors.error;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.screenMargin,
        MediaQuery.viewPaddingOf(context).top + AppSpacing.sm,
        AppSpacing.screenMargin,
        AppSpacing.sm,
      ),
      child: Material(
        color: Color.alphaBlend(tone.withValues(alpha: 0.12), colors.surface),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              AppIcon(AppIcons.user, color: tone),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                // A live region: nobody asked for this, so a screen reader
                // says it the moment it appears.
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    AppStrings.authSessionExpired,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Gives way before the message does on a narrow screen.
              Flexible(
                child: AppActionPill(
                  label: AppStrings.authSignIn,
                  onTap: onSignIn,
                ),
              ),
              AppBarAction(
                icon: AppIcons.close,
                label: AppStrings.actionClose,
                onTap: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SessionBannerHost extends StatelessWidget {
  const SessionBannerHost({
    super.key,
    required this.session,
    required this.onSignIn,
    required this.child,
  });

  final AuthStateNotifier session;

  /// Opens the sign-in screen. The banner has already put itself away.
  final VoidCallback onSignIn;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        return TopBannerSlot(
          banner: session.sessionExpired
              ? SessionExpiredBanner(
                  onSignIn: () {
                    session.setSessionExpired(false);
                    onSignIn();
                  },
                  onDismiss: () => session.setSessionExpired(false),
                )
              : null,
          child: child,
        );
      },
    );
  }
}
