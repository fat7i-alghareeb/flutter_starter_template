import 'package:flutter/material.dart';

import '../../core/network/offline/response_cache.dart';
import '../../utils/constants/design_constants.dart';
import '../../utils/helpers/app_formats.dart';
import '../../utils/helpers/app_strings.dart';
import 'ds/ds.dart';

/// Room for one banner ABOVE [child] — never over it.
///
/// The app wraps its whole router in these (`App`), so a banner that states
/// something about the whole app — an expired session, no network — pushes
/// the app down by its own height and hides nothing: not a header's bell,
/// not a back arrow.
///
/// The tree is the SAME shape with and without a banner — a `Column` whose
/// last child is the app — so a banner appearing never re-parents the
/// router's `Navigator`, which would rebuild it from nothing and throw away
/// every screen the reader had open.
class TopBannerSlot extends StatelessWidget {
  const TopBannerSlot({super.key, required this.banner, required this.child});

  /// Null for none.
  final Widget? banner;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ?banner,
        Expanded(
          key: const ValueKey<String>('app'),
          child: MediaQuery.removePadding(
            context: context,
            // The banner already sits under the status bar.
            removeTop: banner != null,
            child: child,
          ),
        ),
      ],
    );
  }
}

/// «لا يوجد اتصال — تعرض ما حُفظ منذ ساعتين» over the app, while the lists
/// on screen are the saved copies `OfflineCacheInterceptor` answered with.
class OfflineBannerHost extends StatelessWidget {
  const OfflineBannerHost({
    super.key,
    required this.notice,
    required this.child,
  });

  final OfflineNotice notice;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notice,
      builder: (context, _) {
        final savedAt = notice.savedAt;
        return TopBannerSlot(
          banner: savedAt == null
              ? null
              : OfflineBanner(savedAt: savedAt, onDismiss: notice.dismiss),
          child: child,
        );
      },
    );
  }
}

/// The strip itself: the offline glyph, the sentence with WHEN the copy was
/// saved — «old» means nothing without it — and a way to put it away.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.savedAt,
    required this.onDismiss,
  });

  final DateTime savedAt;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = colors.onSurfaceVariant;

    return Material(
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          top: MediaQuery.viewPaddingOf(context).top,
          start: AppSpacing.screenMargin,
          end: AppSpacing.xs,
        ),
        child: Row(
          children: <Widget>[
            AppIcon(
              AppIcons.offline,
              size: AppIconSizes.inline,
              color: foreground,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  AppStrings.stateOfflineCached(
                    AppFormats.relativeTime(context, savedAt),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: foreground,
                  ),
                ),
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
    );
  }
}
