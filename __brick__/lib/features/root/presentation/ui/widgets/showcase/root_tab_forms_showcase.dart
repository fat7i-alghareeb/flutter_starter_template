import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../../common/imports/imports.dart';
import '../../../../../../common/widgets/form/date_time_field/app_reactive_date_time_field.dart';
import '../../../../../../common/widgets/form/dropdown_field/app_reactive_dropdown_field.dart';

class RootTabFormsShowcase extends StatefulWidget {
  const RootTabFormsShowcase({super.key});

  @override
  State<RootTabFormsShowcase> createState() => _RootTabFormsShowcaseState();
}

class _RootTabFormsShowcaseState extends State<RootTabFormsShowcase> {
  late final FormGroup _form;

  @override
  void initState() {
    super.initState();

    _form = FormGroup({
      'text': FormControl<String>(validators: [Validators.required]),
      'email': FormControl<String>(validators: [Validators.email]),
      'password': FormControl<String>(validators: [Validators.required]),
      'phone': FormControl<String>(),
      'decimal': FormControl<String>(),
      'integer': FormControl<String>(),
      'stringOnly': FormControl<String>(),
      'countryId': FormControl<int>(validators: [Validators.required]),
      'countryIdDialog': FormControl<int>(),
      'countryIdSheet': FormControl<int>(),
      'dateTime': FormControl<DateTime>(),
      'dateIso': FormControl<String>(),
      'date': FormControl<DateTime>(),
      'time': FormControl<DateTime>(),
      'dateRange': FormControl<String>(),
    });
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
    final countries = <AppDropdownOption<int>>[
      const AppDropdownOption(id: 1, name: 'Egypt'),
      const AppDropdownOption(id: 12322, name: 'Saudi Arabia'),
      const AppDropdownOption(id: 24, name: 'UAE'),
      const AppDropdownOption(id: 123, name: 'UK'),
      const AppDropdownOption(id: 3, name: 'UAE', enable: false),
      const AppDropdownOption(id: 145, name: 'United states'),
      const AppDropdownOption(id: 14523, name: 'United states2'),
      const AppDropdownOption(id: 1454122, name: 'United states3'),
      const AppDropdownOption(id: 14123215, name: 'United states4'),
    ];

    return SingleChildScrollView(
      padding: AppSpacing.standardPadding,
      child: ReactiveForm(
        formGroup: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Form Widgets Showcase', style: AppTextStyles.s22w700),
            AppSpacing.sm.verticalSpace,
            Text(
              'This page showcases reactive form fields (text fields, dropdowns, and date/time pickers) with different configurations.',
              style: AppTextStyles.s14w400.copyWith(
                color: context.onSurface.withValues(alpha: 0.75),
              ),
            ),
            AppSpacing.lg.verticalSpace,

            _section(context, 'AppReactiveTextField variants', [
              AppReactiveTextField.text(
                formControlName: 'text',
                title: 'Text (required)',
                isRequired: true,
                hintText: 'Type something...',
                onChangedDebounced: (value, _) {},
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveTextField.email(
                formControlName: 'email',
                title: 'Email',
                hintText: 'email@example.com',
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveTextField.password(
                formControlName: 'password',
                title: 'Password',
                isRequired: true,
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveTextField.phone(
                formControlName: 'phone',
                title: 'Phone',
                phoneUseEmojiFlags: true,
                phoneDefaultIsoCode: 'EG',
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveTextField.decimal(
                formControlName: 'decimal',
                title: 'Decimal',
                allowNegative: true,
                removeTrailingDotZero: true,
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveTextField.integer(
                formControlName: 'integer',
                title: 'Integer',
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveTextField.stringOnly(
                formControlName: 'stringOnly',
                title: 'String only',
                hintText: 'letters only',
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveTextField.text(
                formControlName: 'text',
                title: 'Disabled text field',
                enabled: false,
                hintText: 'disabled',
              ),
            ]),

            _section(context, 'AppReactiveDropdownField presentations', [
              AppReactiveDropdownField<int>.menu(
                formControlName: 'countryId',
                title: 'Dropdown (menu)',
                isRequired: true,
                options: countries,
                enableSearch: true,
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveDropdownField<int>.dialog(
                formControlName: 'countryIdDialog',
                title: 'Dropdown (dialog)',
                options: countries,
                enableSearch: true,
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveDropdownField<int>.bottomSheet(
                formControlName: 'countryIdSheet',
                title: 'Dropdown (bottom sheet)',
                options: countries,
                enableSearch: true,
                allowClear: false,
                onSelectReturn: (selected) {
                  if (selected.id == 2) return 'Saudi Arabia is blocked (demo)';
                  return null;
                },
              ),
            ]),

            _section(context, 'AppReactiveDateTimeField variants', [
              AppReactiveDateTimeField.dateTime(
                formControlName: 'dateTime',
                title: 'DateTime (stored as DateTime)',
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveDateTimeField.date(
                formControlName: 'dateIso',
                title: 'Date (stored as ISO string)',
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveDateTimeField.date(
                formControlName: 'date',
                title: 'Date',
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveDateTimeField.time(
                formControlName: 'time',
                title: 'Time',
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveDateTimeField.dateRange(
                formControlName: 'dateRange',
                title: 'Date range (stored as ISO json string)',
                acceptSameDay: false,
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveDateTimeField.month(
                formControlName: 'date',
                title: 'Month',
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveDateTimeField.year(
                formControlName: 'date',
                title: 'Year',
              ),
              AppSpacing.lg.verticalSpace,
              AppReactiveDateTimeField.yearMonth(
                formControlName: 'date',
                title: 'Year / Month',
              ),
            ]),

            AppButton.primaryGradient(
              onTap: () {
                _form.validateAll();
              },
              child: AppButtonChild.label('Validate (markAllAsTouched)'),
            ),
            AppSpacing.md.verticalSpace,
            AppButton.grey(
              onTap: () {
                _form.reset();
              },
              child: AppButtonChild.label('Reset form'),
            ),
            AppSpacing.xl.verticalSpace,
          ],
        ),
      ),
    );
  }
}
