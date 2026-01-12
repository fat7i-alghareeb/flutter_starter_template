
import '../../../../../../common/imports/imports.dart';



class RootTabButtonsShowcase extends StatelessWidget {
  const RootTabButtonsShowcase({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 700)),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
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

  @override
  Widget build(BuildContext context) {
    final icon = IconSource.icon(Icons.arrow_forward_rounded);

    return SingleChildScrollView(
      padding: AppSpacing.standardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AppButton Showcase', style: AppTextStyles.s22w700),
          AppSpacing.sm.verticalSpace,
          Text(
            'This page demonstrates most AppButton configurations (variants, fills, shapes, sizes, loading/disabled, and edge cases).',
            style: AppTextStyles.s14w400.copyWith(
              color: context.onSurface.withValues(alpha: 0.75),
            ),
          ),
          AppSpacing.lg.verticalSpace,

          _section(context, 'Default / basic content types', [
            AppButton.primary(
              onTap: () => _toast(context, 'Default pressed'),
              child: AppButtonChild.label('Default button'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: () => _toast(context, 'Label only pressed'),
              child: AppButtonChild.label('Label only'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: () => _toast(context, 'Icon only pressed'),
              child: AppButtonChild.icon(
                IconSource.icon(Icons.favorite_rounded),
              ),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: () => _toast(context, 'Label + icon pressed'),
              child: AppButtonChild.labelIcon(
                label: 'Label + icon',
                icon: icon,
              ),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: () => _toast(context, 'Trailing icon pressed'),
              child: AppButtonChild.labelIcon(
                label: 'Trailing icon',
                icon: icon,
                position: AppButtonIconPosition.trailing,
              ),
            ),
          ]),

          _section(context, 'Loading / disabled states', [
            AppButton.primary(
              onTap: () {},
              isLoading: true,
              child: AppButtonChild.label('Loading (primary)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primaryGradient(
              onTap: () {},
              isLoading: true,
              child: AppButtonChild.labelIcon(
                label: 'Loading (gradient)',
                icon: IconSource.icon(Icons.hourglass_bottom_rounded),
              ),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: null,
              child: AppButtonChild.label('Disabled (onTap: null)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: () => _toast(context, 'Should not tap'),
              isActive: false,
              child: AppButtonChild.label('Disabled (isActive: false)'),
            ),
          ]),

          _section(context, 'Solid variants', [
            AppButton.primary(
              onTap: () => _toast(context, 'Primary solid'),
              child: AppButtonChild.label('Primary (solid)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.grey(
              onTap: () => _toast(context, 'Grey solid'),
              child: AppButtonChild.label('Grey (solid)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.success(
              onTap: () => _toast(context, 'Success solid'),
              child: AppButtonChild.label('Success (solid)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.warning(
              onTap: () => _toast(context, 'Warning solid'),
              child: AppButtonChild.label('Warning (solid)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.error(
              onTap: () => _toast(context, 'Error solid'),
              child: AppButtonChild.label('Error (solid)'),
            ),
          ]),

          _section(context, 'Gradient variants', [
            AppButton.primaryGradient(
              onTap: () => _toast(context, 'Primary gradient'),
              child: AppButtonChild.label('Primary (gradient)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.greyGradient(
              onTap: () => _toast(context, 'Grey gradient'),
              child: AppButtonChild.label('Grey (gradient)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.successGradient(
              onTap: () => _toast(context, 'Success gradient'),
              child: AppButtonChild.label('Success (gradient)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.warningGradient(
              onTap: () => _toast(context, 'Warning gradient'),
              child: AppButtonChild.label('Warning (gradient)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.errorGradient(
              onTap: () => _toast(context, 'Error gradient'),
              child: AppButtonChild.label('Error (gradient)'),
            ),
          ]),

          _section(context, 'Sizes / layout configuration', [
            AppButton.primary(
              onTap: () => _toast(context, 'Wrap content'),
              child: AppButtonChild.label('Wrap content (default layout)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: () => _toast(context, 'Fixed width'),
              layout: const AppButtonLayout(width: 220),
              child: AppButtonChild.label('Fixed width (220.w)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: () => _toast(context, 'Percent width'),
              layout: const AppButtonLayout(percentageWidth: 1),
              child: AppButtonChild.label('Full width (percentageWidth: 1)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: () => _toast(context, 'Fixed height'),
              layout: const AppButtonLayout(height: 44),
              child: AppButtonChild.label('Fixed height (44.h)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: () => _toast(context, 'Percent height'),
              layout: const AppButtonLayout(percentageHeight: 0.06),
              child: AppButtonChild.label('percentageHeight: 0.06'),
            ),
            AppSpacing.md.verticalSpace,
            Row(
              children: [
                AppButton.primary(
                  onTap: () => _toast(context, 'Circle'),
                  layout: const AppButtonLayout(
                    shape: AppButtonShape.circle,
                    height: 52,
                  ),
                  child: AppButtonChild.icon(
                    IconSource.icon(Icons.add_rounded),
                    size: 22,
                  ),
                ),
                AppSpacing.md.horizontalSpace,
                Expanded(
                  child: AppButton.primary(
                    onTap: () => _toast(context, 'Pill'),
                    layout: const AppButtonLayout(
                      shape: AppButtonShape.pill,
                      percentageWidth: 1,
                    ),
                    child: AppButtonChild.labelIcon(
                      label: 'Pill shape',
                      icon: IconSource.icon(Icons.rounded_corner_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ]),

          _section(context, 'Shadow / custom shadows', [
            AppButton.primary(
              onTap: () => _toast(context, 'Default shadow'),
              child: AppButtonChild.label('Default shadow'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.primary(
              onTap: () => _toast(context, 'No shadow'),
              noShadow: true,
              child: AppButtonChild.label('noShadow: true'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.variant(
              variant: AppButtonVariant.primary,
              fill: AppButtonFill.solid,
              onTap: () => _toast(context, 'Custom shadows'),
              customShadows: [
                BoxShadow(
                  color: context.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              child: AppButtonChild.label('customShadows override'),
            ),
          ]),

          _section(
            context,
            'Maximum config (variant + fill + layout + states)',
            [
              AppButton.variant(
                variant: const CustomButtonVariant(
                  color: Color(0xFF1E293B),
                  gradientColor: LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0EA5E9)],
                  ),
                ),
                fill: AppButtonFill.gradient,
                onTap: () => _toast(context, 'Custom variant pressed'),
                layout: const AppButtonLayout(
                  percentageWidth: 1,
                  height: 52,
                  borderRadius: 18,
                ),
                shadowVariant: AppButtonShadowVariant.primary,
                child: AppButtonChild.labelIcon(
                  label: 'CustomButtonVariant + gradient',
                  icon: IconSource.icon(Icons.auto_awesome_rounded),
                ),
              ),
              AppSpacing.md.verticalSpace,
              AppButton.variant(
                variant: AppButtonVariant.primary,
                fill: AppButtonFill.solid,
                onTap: null,
                isActive: false,
                noShadow: true,
                layout: const AppButtonLayout(percentageWidth: 1),
                child: AppButtonChild.label(
                  'Edge case: disabled + noShadow + full width',
                ),
              ),
            ],
          ),

          AppSpacing.xl.verticalSpace,
        ],
      ),
    );
  }
}
