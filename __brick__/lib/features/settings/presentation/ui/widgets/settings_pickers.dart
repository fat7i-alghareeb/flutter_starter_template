import 'package:flutter/material.dart';

import '../../../../../common/widgets/app_bottom_sheet.dart';
import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../core/config/localization_config.dart';
import '../../../../../core/injection/injectable.dart';
import '../../../../../core/services/localization/locale_service.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/helpers/app_strings.dart';

/// The theme and the language — a picker SHEET, never a screen.
class SettingsPickers {
  SettingsPickers._();

  static ThemeController? get _theme =>
      getIt.isRegistered<ThemeController>() ? getIt<ThemeController>() : null;

  /// «Light» · «Dark» · «System».
  static String themeLabel(BuildContext context) =>
      labelForTheme(_theme?.themeMode ?? ThemeMode.system);

  static String labelForTheme(ThemeMode mode) => switch (mode) {
    ThemeMode.light => AppStrings.settingsThemeLight,
    ThemeMode.dark => AppStrings.settingsThemeDark,
    ThemeMode.system => AppStrings.settingsThemeSystem,
  };

  /// The language the app is actually in — read from the context, so a
  /// screen that changed it a moment ago shows the new value.
  ///
  /// Through `Localizations`, not `context.locale`: the latter throws where
  /// `EasyLocalization` is not an ancestor (a test, a preview).
  static String languageLabel(BuildContext context) => labelForLocale(
    Localizations.maybeLocaleOf(context) ??
        const Locale(AppLocalizationConfig.fallbackLanguageCode),
  );

  /// Each language named in ITSELF — «العربية», not «Arabic» — so someone
  /// who landed in a language they cannot read still finds their own.
  static String labelForLocale(Locale locale) => switch (locale.languageCode) {
    'ar' => 'العربية',
    'en' => 'English',
    final code => code,
  };

  static List<Locale> get supportedLocales => <Locale>[
    for (final code in AppLocalizationConfig.supportedLanguageCodes)
      Locale(code),
  ];

  static Future<void> showTheme(BuildContext context) async {
    final controller = _theme;
    if (controller == null) return;

    await AppBottomSheet.show<void>(
      context,
      sheet: AppBottomSheet.basic(
        title: AppStrings.settingsTheme,
        titleIcon: AppIcons.darkMode,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final mode in <ThemeMode>[
              ThemeMode.system,
              ThemeMode.light,
              ThemeMode.dark,
            ])
              _PickerRow(
                label: labelForTheme(mode),
                isSelected: controller.themeMode == mode,
                onTap: () {
                  controller.setThemeMode(mode);
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> showLanguage(BuildContext context) async {
    final current = Localizations.maybeLocaleOf(context)?.languageCode;

    await AppBottomSheet.show<void>(
      context,
      sheet: AppBottomSheet.basic(
        title: AppStrings.settingsLanguage,
        titleIcon: AppIcons.language,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final locale in supportedLocales)
              _PickerRow(
                label: labelForLocale(locale),
                isSelected: current == locale.languageCode,
                onTap: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  // Through `LocaleService`, which STORES the choice:
                  // `context.setLocale` alone would last until the app
                  // closes. The whole app rebuilds in the new direction.
                  await getIt<LocaleService>().changeLanguage(
                    AppLanguage.values.byName(locale.languageCode),
                    context,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// One choice. The current one is marked by weight AND a tick — never by
/// colour alone.
class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? colors.primary : colors.onSurface,
                      fontWeight: isSelected ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                if (isSelected)
                  AppIcon(
                    AppIcons.success,
                    size: AppIconSizes.inline,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
