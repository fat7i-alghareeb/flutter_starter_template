import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../../common/imports/imports.dart';
import 'showcase_layout.dart';

class RootTabDialogsSheetsShowcase extends StatelessWidget {
  const RootTabDialogsSheetsShowcase({super.key});

  Future<void> _showBasicDialog(BuildContext context) {
    return AppDialog.show(
      context,
      dialog: AppDialog.basic(
        icon: IconSource.svg(AppIcons.info),
        title: AppStrings.showcaseDialogsBasicTitle,
        message: AppStrings.showcaseDialogsBasicMessage,
        primaryAction: AppDialogAction.primary(
          label: AppStrings.showcaseDialogsOk,
          icon: IconSource.svg(AppIcons.check),
          onPressed: () => Navigator.of(context).pop(),
        ),
        secondaryAction: AppDialogAction.secondary(
          label: AppStrings.cancel,
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
        title: AppStrings.showcaseDialogsCustomTitle,
        message: AppStrings.showcaseDialogsCustomMessage,
        primaryAction: AppDialogAction.primary(
          label: AppStrings.actionClose,
          onPressed: () => Navigator.of(context).pop(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppReactiveTextField.text(
              formGroup: FormGroup(<String, AbstractControl<dynamic>>{
                'a': FormControl<String>(),
              }),
              formControlName: 'a',
              title: AppStrings.showcaseDialogsCustomField,
              hintText: AppStrings.showcaseDialogsCustomHint,
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
        title: AppStrings.showcaseDialogsManyTitle,
        message: AppStrings.showcaseDialogsManyMessage,
        secondaryAction: AppDialogAction.secondary(
          label: AppStrings.actionBack,
          onPressed: () => Navigator.of(context).pop(),
        ),
        primaryAction: AppDialogAction.primary(
          label: AppStrings.showcaseDialogsConfirm,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <AppDialogAction>[
          AppDialogAction.success(
            label: AppStrings.showcaseDialogsExtra1,
            icon: IconSource.svg(AppIcons.star),
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppDialogAction.primary(
            label: AppStrings.showcaseDialogsExtra2,
            icon: IconSource.svg(AppIcons.power),
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
        title: AppStrings.showcaseDialogsSheetTitle,
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.showcaseDialogsSheetBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              AppSpacing.md.verticalSpace,
              AppButton.primary(
                onTap: () => Navigator.of(context).pop(),
                child: AppButtonChild.label(AppStrings.actionClose),
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
        title: AppStrings.showcaseDialogsLockedTitle,
        showDragHandle: false,
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              AppStrings.showcaseDialogsLockedHeader,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppButton.primary(
              onTap: () => Navigator.of(context).pop(),
              layout: const AppButtonLayout(
                shape: AppButtonShape.circle,
                height: 44,
              ),
              child: AppButtonChild.icon(IconSource.svg(AppIcons.close)),
            ),
          ],
        ),
        scrollable: false,
        actions: <Widget>[
          AppButton.error(
            onTap: () => Navigator.of(context).pop(),
            child: AppButtonChild.label(AppStrings.cancel),
            layout: const AppButtonLayout(width: 100),
          ),
          AppSpacing.sm.verticalSpace,
          AppButton.primaryGradient(
            onTap: () => Navigator.of(context).pop(),
            child: AppButtonChild.label(AppStrings.showcaseDialogsApply),
            layout: const AppButtonLayout(width: 100),
          ),
        ],
        child: Text(
          AppStrings.showcaseDialogsLockedMessage,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: AppStrings.showcaseDialogsTitle,
      subtitle: AppStrings.showcaseDialogsSubtitle,
      children: <Widget>[
        ShowcaseSection(
          title: AppStrings.navDialogs,
          children: <Widget>[
            AppButton.primary(
              onTap: () => _showBasicDialog(context),
              child: AppButtonChild.labelIcon(
                label: AppStrings.showcaseDialogsShowBasic,
                icon: IconSource.svg(AppIcons.externalLink),
              ),
            ),
            AppButton.success(
              onTap: () => _showCustomChildDialog(context),
              child: AppButtonChild.label(AppStrings.showcaseDialogsShowCustom),
            ),
            AppButton.warning(
              onTap: () => _showMultiActionsDialog(context),
              child: AppButtonChild.label(AppStrings.showcaseDialogsShowMany),
            ),
          ],
        ),

        ShowcaseSection(
          title: AppStrings.showcaseDialogsSectionSheets,
          children: <Widget>[
            AppButton.primaryGradient(
              onTap: () => _showBasicSheet(context),
              child: AppButtonChild.label(AppStrings.showcaseDialogsShowSheet),
            ),
            AppButton.errorGradient(
              onTap: () => _showSheetWithHeaderActions(context),
              child: AppButtonChild.label(
                AppStrings.showcaseDialogsShowSheetLocked,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
