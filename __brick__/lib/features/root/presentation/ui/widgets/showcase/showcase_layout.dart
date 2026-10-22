import '../../../../../../common/imports/imports.dart';
import '../../../../../../common/widgets/scroll_reveal.dart';
import '../nav_bar/app_bottom_nav.dart';

/// The frame the four showcase tabs share: the scrolling page, a title and a
/// line under it.
///
/// The column is at most [maxWidth] wide and centred in the window
/// (`AppContentWidth`); on a phone it is simply the screen. Page padding is
/// the layout's gutter, so it follows the window size.
class ShowcasePage extends StatelessWidget {
  const ShowcasePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  /// A column of reading width: wider than this the demos are only more
  /// empty space between them.
  static const double maxWidth = 840;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.layout.gutter,
        vertical: AppSpacing.md,
      ).copyWith(bottom: AppBottomNav.listBottomPadding(context)),
      child: AppContentWidth(
        maxWidth: maxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.headlineSmall),
            AppSpacing.xs.verticalSpace,
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.lg.verticalSpace,
            ...children,
            AppSpacing.lg.verticalSpace,
          ],
        ),
      ),
    );
  }
}

/// A titled group of demos with a hairline under it.
///
/// With [flow] (the default) the demos sit side by side and wrap to the next
/// line when the row is full, so a wide window is not a tall strip of
/// buttons. Pass `flow: false` for demos that take the whole width — a form,
/// a full-width button.
class ShowcaseSection extends StatelessWidget {
  const ShowcaseSection({
    super.key,
    required this.title,
    required this.children,
    this.flow = true,
  });

  final String title;
  final List<Widget> children;
  final bool flow;

  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          AppSpacing.sm.verticalSpace,
          if (flow)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children,
            )
          else
            for (var i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0) AppSpacing.sm.verticalSpace,
              children[i],
            ],
          AppSpacing.md.verticalSpace,
          const Divider(height: 1),
          AppSpacing.md.verticalSpace,
        ],
      ),
    );
  }
}
