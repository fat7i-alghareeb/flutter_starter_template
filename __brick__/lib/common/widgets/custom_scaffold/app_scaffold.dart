import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../common/widgets/app_affixes.dart';
import '../../../common/widgets/app_icon_source.dart';
import '../../../common/widgets/form/app_reactive_text_field.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../utils/constants/design_constants.dart';
import '../../../utils/extensions/context_extensions.dart';
import '../../../utils/extensions/theme_extensions.dart';
import '../../../utils/extensions/widget_extensions.dart';

part 'app_scaffold_variants.dart';
part 'app_scaffold_app_bar.dart';
part 'app_scaffold_search.dart';
part 'app_scaffold_drawer.dart';
part 'app_scaffold_tap_area.dart';

/// A compact, feature-driven scaffold that composes optional UI sections
/// (custom app bar, search field, end drawer) without using Flutter's [AppBar].
///
/// This widget is designed for:
/// - Low memory footprint
/// - Minimal rebuild surface
/// - Avoiding building/rendering disabled sections
///
/// Important constraints:
/// - Does **not** use Flutter's [AppBar].
/// - Does **not** wrap content in [SafeArea].
/// - Only renders sections whose [ScaffoldFeature] is enabled.
///
/// ## Recommended usage
///
/// ### 1) App bar only
/// ```dart
/// return AppScaffold.appBar(
///   appBarConfig: const AppScaffoldAppBarConfig(title: 'Profile'),
///   child: const ProfileBody(),
/// );
/// ```
///
/// ### 2) App bar + search
/// ```dart
/// return AppScaffold.all(
///   appBarConfig: const AppScaffoldAppBarConfig(
///     title: 'Products',
///     enableDrawer: true,
///   ),
///   searchConfig: AppScaffoldSearchConfig(
///     formGroup: form,
///     formControlName: 'search',
///     hintText: 'Search...',
///   ),
///   child: const ProductsBody(),
/// );
/// ```
///
/// ### 3) Custom features
/// ```dart
/// return AppScaffold.custom(
///   features: const [ScaffoldFeature.search],
///   searchConfig: AppScaffoldSearchConfig(
///     formGroup: form,
///     formControlName: 'search',
///   ),
///   child: const ResultsBody(),
/// );
/// ```
///
/// ## Drawer behavior
/// The end drawer is only enabled when:
/// - [ScaffoldFeature.appBar] is enabled
/// - and [AppScaffoldAppBarConfig.enableDrawer] is `true`
class AppScaffold extends StatelessWidget {
  const AppScaffold._({
    super.key,
    required this.child,
    required Set<ScaffoldFeature> features,
    this.scaffoldConfig = const AppScaffoldConfig(),
    this.appBarConfig,
    this.searchConfig,

    this.bottomNavigationBar,
    this.topSpacing = 0,
    this.afterAppBarSpacing = AppSpacing.md,
    this.afterSearchSpacing = AppSpacing.md,
  }) : _features = features;

  /// Creates a scaffold that renders only the [child] body.
  ///
  /// This constructor enables no optional features.
  factory AppScaffold.body({
    Key? key,
    required Widget child,
    AppScaffoldConfig scaffoldConfig = const AppScaffoldConfig(),
    double topSpacing = 0,
    Widget? bottomNavigationBar,
  }) {
    return AppScaffold._(
      key: key,
      features: const <ScaffoldFeature>{},
      scaffoldConfig: scaffoldConfig,
      topSpacing: topSpacing,
      bottomNavigationBar: bottomNavigationBar,
      child: child,
    );
  }

  factory AppScaffold.appBar({
    Key? key,
    required Widget child,
    AppScaffoldConfig scaffoldConfig = const AppScaffoldConfig(),
    required AppScaffoldAppBarConfig appBarConfig,
    double topSpacing = 0,
    double afterAppBarSpacing = AppSpacing.md,
    Widget? bottomNavigationBar,
  }) {
    return AppScaffold._(
      key: key,
      features: const {ScaffoldFeature.appBar},
      scaffoldConfig: scaffoldConfig,
      appBarConfig: appBarConfig,
      topSpacing: topSpacing,
      afterAppBarSpacing: afterAppBarSpacing,
      bottomNavigationBar: bottomNavigationBar,
      child: child,
    );
  }

  factory AppScaffold.search({
    Key? key,
    required Widget child,
    AppScaffoldConfig scaffoldConfig = const AppScaffoldConfig(),
    required AppScaffoldSearchConfig searchConfig,
    double topSpacing = 0,
    double afterSearchSpacing = AppSpacing.md,
    Widget? bottomNavigationBar,
  }) {
    return AppScaffold._(
      key: key,
      features: const {ScaffoldFeature.search},
      scaffoldConfig: scaffoldConfig,
      searchConfig: searchConfig,
      topSpacing: topSpacing,
      afterSearchSpacing: afterSearchSpacing,
      bottomNavigationBar: bottomNavigationBar,
      child: child,
    );
  }

  factory AppScaffold.all({
    Key? key,
    required Widget child,
    AppScaffoldConfig scaffoldConfig = const AppScaffoldConfig(),
    required AppScaffoldAppBarConfig appBarConfig,
    required AppScaffoldSearchConfig searchConfig,
    double topSpacing = 0,
    double afterAppBarSpacing = AppSpacing.md,
    double afterSearchSpacing = AppSpacing.md,
    Widget? bottomNavigationBar,
  }) {
    return AppScaffold._(
      key: key,
      features: const {ScaffoldFeature.appBar, ScaffoldFeature.search},
      scaffoldConfig: scaffoldConfig,
      appBarConfig: appBarConfig,
      searchConfig: searchConfig,
      topSpacing: topSpacing,
      afterAppBarSpacing: afterAppBarSpacing,
      afterSearchSpacing: afterSearchSpacing,
      bottomNavigationBar: bottomNavigationBar,
      child: child,
    );
  }

  factory AppScaffold.custom({
    Key? key,
    required Widget child,
    required List<ScaffoldFeature> features,
    AppScaffoldConfig scaffoldConfig = const AppScaffoldConfig(),
    AppScaffoldAppBarConfig? appBarConfig,
    AppScaffoldSearchConfig? searchConfig,
    double topSpacing = 0,
    double afterAppBarSpacing = AppSpacing.md,
    double afterSearchSpacing = AppSpacing.md,
    Widget? bottomNavigationBar,
  }) {
    return AppScaffold._(
      key: key,
      features: Set<ScaffoldFeature>.unmodifiable(features),
      scaffoldConfig: scaffoldConfig,
      appBarConfig: appBarConfig,
      searchConfig: searchConfig,
      topSpacing: topSpacing,
      afterAppBarSpacing: afterAppBarSpacing,
      afterSearchSpacing: afterSearchSpacing,
      bottomNavigationBar: bottomNavigationBar,
      child: child,
    );
  }

  final Widget child;
  final Set<ScaffoldFeature> _features;
  final AppScaffoldConfig scaffoldConfig;

  final AppScaffoldAppBarConfig? appBarConfig;
  final AppScaffoldSearchConfig? searchConfig;

  final Widget? bottomNavigationBar;

  final double topSpacing;
  final double afterAppBarSpacing;
  final double afterSearchSpacing;

  /// Whether the app bar section is enabled by the feature set.
  bool get _appBarEnabled => _features.contains(ScaffoldFeature.appBar);

  /// Whether the search section is enabled by the feature set.
  bool get _searchEnabled => _features.contains(ScaffoldFeature.search);

  /// Drawer is intentionally gated behind the app bar so:
  /// - we don't expose a drawer action without a chrome that can trigger it
  /// - we don't allocate/endDrawer unless explicitly required
  bool get _drawerEnabled =>
      _appBarEnabled && (appBarConfig?.enableDrawer ?? false);

  @override
  Widget build(BuildContext context) {
    final appBarConfig = this.appBarConfig;
    final searchConfig = this.searchConfig;

    /// The body is composed from top-to-bottom.
    /// Disabled sections are not built at all.
    final body = SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          if (topSpacing > 0) topSpacing.verticalSpace,
          if (_appBarEnabled && appBarConfig != null) ...[
            _AppScaffoldAppBar(
              config: appBarConfig,
              drawerEnabled: _drawerEnabled,
            ).standardHorizontalPadding,
            if (afterAppBarSpacing > 0) afterAppBarSpacing.verticalSpace,
          ],
          if (_searchEnabled && searchConfig != null) ...[
            _AppScaffoldSearchField(
              config: searchConfig,
            ).standardHorizontalPadding,
            if (afterSearchSpacing > 0) afterSearchSpacing.verticalSpace,
          ],
          Expanded(child: child),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: scaffoldConfig.backgroundColor,
      resizeToAvoidBottomInset: scaffoldConfig.resizeToAvoidBottomInset,
      endDrawer: _drawerEnabled ? const _AppEndDrawerShell() : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
