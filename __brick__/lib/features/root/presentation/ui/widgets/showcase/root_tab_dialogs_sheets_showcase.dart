import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../../common/imports/imports.dart';

class RootTabDialogsSheetsShowcase extends StatelessWidget {
  const RootTabDialogsSheetsShowcase({super.key});

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

  Future<void> _showBasicDialog(BuildContext context) {
    return AppDialog.show(
      context,
      dialog: AppDialog.basic(
        icon: IconSource.icon(Icons.info_outline_rounded),
        title: 'Basic dialog',
        message: 'This is a basic AppDialog with primary/secondary actions.',
        primaryAction: AppDialogAction.primary(
          label: 'OK',
          icon: IconSource.icon(Icons.check_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        secondaryAction: AppDialogAction.secondary(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Future<void> _showCustomChildDialog(BuildContext context) {
    return AppDialog.show(
      context,
      barrierDismissible: false,
      dialog: AppDialog.basic(
        title: 'Custom child',
        message: 'This dialog uses the child slot (barrierDismissible=false).',
        primaryAction: AppDialogAction.primary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppReactiveTextField.text(
              formGroup: FormGroup({'a': FormControl<String>()}),
              formControlName: 'a',
              title: 'Inline field',
              hintText: 'type here...',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMultiActionsDialog(BuildContext context) {
    return AppDialog.show(
      context,
      dialog: AppDialog.basic(
        title: 'Multiple actions',
        message: 'Primary/secondary + extra actions list.',
        secondaryAction: AppDialogAction.secondary(
          label: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        primaryAction: AppDialogAction.primary(
          label: 'Confirm',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          AppDialogAction.secondary(
            label: 'Extra 1',
            icon: IconSource.icon(Icons.star_outline_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppDialogAction.secondary(
            label: 'Extra 2',
            icon: IconSource.icon(Icons.bolt_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _showBasicSheet(BuildContext context) {
    return AppBottomSheet.show(
      context,
      sheet: AppBottomSheet.basic(
        title: 'Bottom sheet',
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This is AppBottomSheet.basic',
                style: AppTextStyles.s14w400,
              ),
              AppSpacing.md.verticalSpace,
              AppButton.primary(
                onTap: () => Navigator.of(context).pop(),
                child: AppButtonChild.label('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSheetWithHeaderActions(BuildContext context) {
    return AppBottomSheet.show(
      context,
      isDismissible: false,
      enableDrag: false,
      sheet: AppBottomSheet.basic(
        title: 'Header + actions',
        showDragHandle: false,
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Custom header', style: AppTextStyles.s16w600),
            AppButton.primary(
              onTap: () => Navigator.of(context).pop(),
              layout: const AppButtonLayout(
                shape: AppButtonShape.circle,
                height: 44,
              ),
              child: AppButtonChild.icon(IconSource.icon(Icons.close_rounded)),
            ),
          ],
        ),
        scrollable: false,
        actions: [
          AppButton.grey(
            onTap: () => Navigator.of(context).pop(),
            child: AppButtonChild.label('Cancel'),
            layout: const AppButtonLayout(width: 100),
          ),
          AppSpacing.sm.verticalSpace,
          AppButton.primaryGradient(
            onTap: () => Navigator.of(context).pop(),
            child: AppButtonChild.label('Apply'),
            layout: const AppButtonLayout(width: 100),
          ),
        ],
        child: Text(
          'Dismiss is disabled for this modal. Use the close button.',
          style: AppTextStyles.s14w400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.standardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dialogs & Bottom Sheets Showcase',
            style: AppTextStyles.s22w700,
          ),
          AppSpacing.sm.verticalSpace,
          Text(
            'Buttons below demonstrate different AppDialog and AppBottomSheet configurations.',
            style: AppTextStyles.s14w400.copyWith(
              color: context.onSurface.withValues(alpha: 0.75),
            ),
          ),
          AppSpacing.lg.verticalSpace,

          _section(context, 'AppDialog', [
            AppButton.primary(
              onTap: () => _showBasicDialog(context),
              child: AppButtonChild.labelIcon(
                label: 'Show basic dialog',
                icon: IconSource.icon(Icons.open_in_new_rounded),
              ),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.success(
              onTap: () => _showCustomChildDialog(context),
              child: AppButtonChild.label('Dialog with custom child'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.warning(
              onTap: () => _showMultiActionsDialog(context),
              child: AppButtonChild.label('Dialog with many actions'),
            ),
          ]),

          _section(context, 'AppBottomSheet', [
            AppButton.primaryGradient(
              onTap: () => _showBasicSheet(context),
              child: AppButtonChild.label('Show basic bottom sheet'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.errorGradient(
              onTap: () => _showSheetWithHeaderActions(context),
              child: AppButtonChild.label('Bottom sheet (no dismiss, no drag)'),
            ),
          ]),

          AppSpacing.xl.verticalSpace,
        ],
      ),
    );
  }
}
