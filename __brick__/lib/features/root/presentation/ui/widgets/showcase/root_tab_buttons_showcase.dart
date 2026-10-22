import '../../../../../../common/imports/imports.dart';
import 'showcase_layout.dart';

class RootTabButtonsShowcase extends StatelessWidget {
  const RootTabButtonsShowcase({super.key});

  void _pressed(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppSnackContent(AppStrings.showcasePressed(name)),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _inactive(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppSnackContent(AppStrings.showcaseButtonsInactiveTapped),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = IconSource.svg(AppIcons.arrowRight);

    return ShowcasePage(
      title: AppStrings.showcaseButtonsTitle,
      subtitle: AppStrings.showcaseButtonsSubtitle,
      children: <Widget>[
        ShowcaseSection(
          title: AppStrings.showcaseButtonsSectionBasic,
          children: <Widget>[
            AppButton.primary(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsDefault),
              child: AppButtonChild.label(AppStrings.showcaseButtonsDefault),
            ),
            AppButton.primary(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsLabelOnly),
              child: AppButtonChild.label(AppStrings.showcaseButtonsLabelOnly),
            ),
            AppButton.primary(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsIconOnly),
              child: AppButtonChild.icon(IconSource.svg(AppIcons.heart)),
            ),
            AppButton.primary(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsLabelIcon),
              child: AppButtonChild.labelIcon(
                label: AppStrings.showcaseButtonsLabelIcon,
                icon: icon,
              ),
            ),
            AppButton.primary(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsTrailingIcon),
              child: AppButtonChild.labelIcon(
                label: AppStrings.showcaseButtonsTrailingIcon,
                icon: icon,
                position: AppButtonIconPosition.trailing,
              ),
            ),
          ],
        ),

        ShowcaseSection(
          title: AppStrings.showcaseButtonsSectionStates,
          children: <Widget>[
            AppButton.primary(
              onTap: () {},
              isLoading: true,
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsLoadingPrimary,
              ),
            ),
            AppButton.primaryGradient(
              onTap: () {},
              isLoading: true,
              child: AppButtonChild.labelIcon(
                label: AppStrings.showcaseButtonsLoadingGradient,
                icon: IconSource.svg(AppIcons.clock),
              ),
            ),
            // Grey is how a button shows it is INACTIVE, and only that: any
            // button given `isActive: false` is drawn grey by itself.
            AppButton.primary(
              onTap: () {},
              isActive: false,
              onTapWhenInactive: () => _inactive(context),
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsDisabledInactive,
              ),
            ),
            // `AppButton.grey` is a button that is always inactive.
            AppButton.grey(
              onTapWhenInactive: () => _inactive(context),
              child: AppButtonChild.label(AppStrings.showcaseButtonsInactiveGrey),
            ),
          ],
        ),

        ShowcaseSection(
          title: AppStrings.showcaseButtonsSectionSolid,
          children: <Widget>[
            AppButton.primary(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsVariantPrimary),
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsVariantPrimary,
              ),
            ),
            AppButton.success(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsVariantSuccess),
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsVariantSuccess,
              ),
            ),
            AppButton.warning(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsVariantWarning),
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsVariantWarning,
              ),
            ),
            AppButton.error(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsVariantError),
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsVariantError,
              ),
            ),
          ],
        ),

        ShowcaseSection(
          title: AppStrings.showcaseButtonsSectionGradient,
          children: <Widget>[
            AppButton.primaryGradient(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsVariantPrimary),
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsVariantPrimary,
              ),
            ),
            AppButton.successGradient(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsVariantSuccess),
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsVariantSuccess,
              ),
            ),
            AppButton.warningGradient(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsVariantWarning),
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsVariantWarning,
              ),
            ),
            AppButton.errorGradient(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsVariantError),
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsVariantError,
              ),
            ),
          ],
        ),

        ShowcaseSection(
          title: AppStrings.showcaseButtonsSectionSizes,
          flow: false,
          children: <Widget>[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                AppButton.primary(
                  onTap: () =>
                      _pressed(context, AppStrings.showcaseButtonsWrap),
                  child: AppButtonChild.label(AppStrings.showcaseButtonsWrap),
                ),
                AppButton.primary(
                  onTap: () =>
                      _pressed(context, AppStrings.showcaseButtonsFixedWidth),
                  layout: const AppButtonLayout(width: 220),
                  child: AppButtonChild.label(
                    AppStrings.showcaseButtonsFixedWidth,
                  ),
                ),
                AppButton.primary(
                  onTap: () =>
                      _pressed(context, AppStrings.showcaseButtonsFixedHeight),
                  layout: const AppButtonLayout(height: 44),
                  child: AppButtonChild.label(
                    AppStrings.showcaseButtonsFixedHeight,
                  ),
                ),
                AppButton.primary(
                  onTap: () => _pressed(
                    context,
                    AppStrings.showcaseButtonsRelativeHeight,
                  ),
                  layout: const AppButtonLayout(percentageHeight: 0.06),
                  child: AppButtonChild.label(
                    AppStrings.showcaseButtonsRelativeHeight,
                  ),
                ),
              ],
            ),
            AppButton.primary(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsFullWidth),
              layout: const AppButtonLayout(percentageWidth: 1),
              child: AppButtonChild.label(AppStrings.showcaseButtonsFullWidth),
            ),
            Row(
              children: <Widget>[
                AppButton.primary(
                  onTap: () =>
                      _pressed(context, AppStrings.showcaseButtonsCircle),
                  layout: const AppButtonLayout(
                    shape: AppButtonShape.circle,
                    height: 52,
                  ),
                  child: AppButtonChild.icon(
                    IconSource.svg(AppIcons.edit),
                    size: 22,
                  ),
                ),
                AppSpacing.md.horizontalSpace,
                Expanded(
                  child: AppButton.primary(
                    onTap: () =>
                        _pressed(context, AppStrings.showcaseButtonsPill),
                    layout: const AppButtonLayout(
                      shape: AppButtonShape.pill,
                      percentageWidth: 1,
                    ),
                    child: AppButtonChild.labelIcon(
                      label: AppStrings.showcaseButtonsPill,
                      icon: IconSource.svg(AppIcons.grid),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        ShowcaseSection(
          title: AppStrings.showcaseButtonsSectionShadows,
          children: <Widget>[
            AppButton.primary(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsShadowDefault),
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsShadowDefault,
              ),
            ),
            AppButton.primary(
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsShadowNone),
              noShadow: true,
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsShadowNone,
              ),
            ),
            AppButton.variant(
              variant: AppButtonVariant.primary,
              fill: AppButtonFill.solid,
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsShadowCustom),
              customShadows: <BoxShadow>[
                BoxShadow(
                  color: context.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              child: AppButtonChild.label(
                AppStrings.showcaseButtonsShadowCustom,
              ),
            ),
          ],
        ),

        ShowcaseSection(
          title: AppStrings.showcaseButtonsSectionEverything,
          flow: false,
          children: <Widget>[
            AppButton.variant(
              variant: const CustomButtonVariant(
                color: Color(0xFF1E293B),
                gradientColor: LinearGradient(
                  colors: <Color>[Color(0xFF1E293B), Color(0xFF0EA5E9)],
                ),
              ),
              fill: AppButtonFill.gradient,
              onTap: () =>
                  _pressed(context, AppStrings.showcaseButtonsCustom),
              layout: const AppButtonLayout(
                percentageWidth: 1,
                height: 52,
                borderRadius: 18,
              ),
              shadowVariant: AppButtonShadowVariant.primary,
              child: AppButtonChild.labelIcon(
                label: AppStrings.showcaseButtonsCustom,
                icon: IconSource.svg(AppIcons.star),
              ),
            ),
            AppButton.variant(
              variant: AppButtonVariant.primary,
              fill: AppButtonFill.solid,
              onTap: null,
              isActive: false,
              noShadow: true,
              layout: const AppButtonLayout(percentageWidth: 1),
              child: AppButtonChild.label(AppStrings.showcaseButtonsEdge),
            ),
          ],
        ),
      ],
    );
  }
}
