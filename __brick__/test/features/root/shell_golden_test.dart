import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:{{project_name}}/common/widgets/ds/app_icons.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/app_bottom_nav.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/app_side_nav.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';

import '../../helpers/golden_helper.dart';

/// The side navigation at the two widths it takes: the 256dp sidebar of an
/// expanded window and the 80dp rail of a medium one. Right-to-left, both
/// themes — the sidebar sits on the right edge in Arabic.
void main() {
  setUpAll(loadTestFonts);

  final controller = NavigationController();

  const destinations = <AppNavDestination>[
    AppNavDestination(icon: AppIcons.home, label: 'الرئيسية'),
    AppNavDestination(icon: AppIcons.grid, label: 'الأزرار'),
    AppNavDestination(icon: AppIcons.edit, label: 'النماذج'),
    AppNavDestination(icon: AppIcons.comment, label: 'الحوارات'),
    AppNavDestination(icon: AppIcons.bell, label: 'التنبيهات'),
  ];

  Widget nav({required bool extended}) => SizedBox(
    height: 560,
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: AppSideNav(
        controller: controller,
        destinations: destinations,
        extended: extended,
        // Only what is the same in every project: the destinations and the
        // open one. The brand shows the app's NAME (a different
        // picture in every generated project) and the group, settings and
        // account rows are text that needs the app's translations loaded.
        config: const AppSideNavConfig(
          showBrand: false,
          showSearch: false,
          showGroups: false,
          showSettings: false,
          showAccount: false,
          showThemeToggle: false,
          collapsible: false,
        ),
      ),
    ),
  );

  goldenTest(
    'side_nav_sidebar',
    () => nav(extended: true),
    surfaceSize: const Size(900, 600),
  );

  goldenTest(
    'side_nav_rail',
    () => nav(extended: false),
    surfaceSize: const Size(700, 600),
  );
}
