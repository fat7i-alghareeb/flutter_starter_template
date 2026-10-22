import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../../common/imports/imports.dart';
import '../../../../../../common/widgets/form/app_form_field_grid.dart';
import '../../../../../../common/widgets/form/date_time_field/app_reactive_date_time_field.dart';
import '../../../../../../common/widgets/form/dropdown_field/app_reactive_dropdown_field.dart';
import 'showcase_layout.dart';

class RootTabFormsShowcase extends StatefulWidget {
  const RootTabFormsShowcase({super.key});

  @override
  State<RootTabFormsShowcase> createState() => _RootTabFormsShowcaseState();
}

class _RootTabFormsShowcaseState extends State<RootTabFormsShowcase> {
  late final FormGroup _form;

  /// The country the bottom-sheet dropdown refuses, to show `onSelectReturn`.
  static const int _blockedCountryId = 2;

  @override
  void initState() {
    super.initState();

    _form = FormGroup(<String, AbstractControl<dynamic>>{
      'text': FormControl<String>(validators: <Validator<dynamic>>[
        Validators.required,
      ]),
      'email': FormControl<String>(validators: <Validator<dynamic>>[
        Validators.email,
      ]),
      'password': FormControl<String>(validators: <Validator<dynamic>>[
        Validators.required,
      ]),
      'phone': FormControl<String>(),
      'decimal': FormControl<String>(),
      'integer': FormControl<String>(),
      'stringOnly': FormControl<String>(),
      'countryId': FormControl<int>(validators: <Validator<dynamic>>[
        Validators.required,
      ]),
      'countryIdDialog': FormControl<int>(),
      'countryIdSheet': FormControl<int>(),
      'dateTime': FormControl<DateTime>(),
      'dateIso': FormControl<String>(),
      'date': FormControl<DateTime>(),
      'time': FormControl<DateTime>(),
      'dateRange': FormControl<String>(),
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countries = <AppDropdownOption<int>>[
      AppDropdownOption(id: 1, name: AppStrings.showcaseFormsCountryEgypt),
      AppDropdownOption(
        id: _blockedCountryId,
        name: AppStrings.showcaseFormsCountrySaudi,
      ),
      AppDropdownOption(id: 3, name: AppStrings.showcaseFormsCountryUae),
      AppDropdownOption(id: 4, name: AppStrings.showcaseFormsCountryUk),
      AppDropdownOption(
        id: 5,
        name: AppStrings.showcaseFormsCountryUs,
        enable: false,
      ),
      AppDropdownOption(id: 6, name: AppStrings.showcaseFormsCountryCanada),
      AppDropdownOption(id: 7, name: AppStrings.showcaseFormsCountryGermany),
      AppDropdownOption(id: 8, name: AppStrings.showcaseFormsCountryFrance),
      AppDropdownOption(id: 9, name: AppStrings.showcaseFormsCountryJapan),
    ];

    return ShowcasePage(
      title: AppStrings.showcaseFormsTitle,
      subtitle: AppStrings.showcaseFormsSubtitle,
      children: <Widget>[
        ReactiveForm(
          formGroup: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ShowcaseSection(
                title: AppStrings.showcaseFormsSectionText,
                flow: false,
                children: <Widget>[
                  AppFormFieldGrid(
                    children: <Widget>[
                      AppReactiveTextField.text(
                        formControlName: 'text',
                        title: AppStrings.showcaseFormsText,
                        isRequired: true,
                        hintText: AppStrings.showcaseFormsTextHint,
                        onChangedDebounced: (value, _) {},
                      ),
                      AppReactiveTextField.email(
                        formControlName: 'email',
                        title: AppStrings.authEmail,
                        hintText: 'email@example.com',
                      ),
                      AppReactiveTextField.password(
                        formControlName: 'password',
                        title: AppStrings.authPassword,
                        isRequired: true,
                      ),
                      AppReactiveTextField.phone(
                        formControlName: 'phone',
                        title: AppStrings.showcaseFormsPhone,
                        phoneDefaultIsoCode: 'EG',
                      ),
                      AppReactiveTextField.decimal(
                        formControlName: 'decimal',
                        title: AppStrings.showcaseFormsDecimal,
                        allowNegative: true,
                        removeTrailingDotZero: true,
                      ),
                      AppReactiveTextField.integer(
                        formControlName: 'integer',
                        title: AppStrings.showcaseFormsInteger,
                      ),
                      AppReactiveTextField.stringOnly(
                        formControlName: 'stringOnly',
                        title: AppStrings.showcaseFormsLettersOnly,
                        hintText: AppStrings.showcaseFormsLettersOnlyHint,
                      ),
                      AppReactiveTextField.text(
                        formControlName: 'text',
                        title: AppStrings.showcaseFormsDisabled,
                        enabled: false,
                        hintText: AppStrings.showcaseFormsDisabledHint,
                      ),
                    ],
                  ),
                ],
              ),

              ShowcaseSection(
                title: AppStrings.showcaseFormsSectionDropdown,
                flow: false,
                children: <Widget>[
                  AppFormFieldGrid(
                    children: <Widget>[
                      AppReactiveDropdownField<int>.menu(
                        formControlName: 'countryId',
                        title: AppStrings.showcaseFormsDropdownMenu,
                        isRequired: true,
                        options: countries,
                        enableSearch: true,
                      ),
                      AppReactiveDropdownField<int>.dialog(
                        formControlName: 'countryIdDialog',
                        title: AppStrings.showcaseFormsDropdownDialog,
                        options: countries,
                        enableSearch: true,
                      ),
                      AppReactiveDropdownField<int>.bottomSheet(
                        formControlName: 'countryIdSheet',
                        title: AppStrings.showcaseFormsDropdownSheet,
                        options: countries,
                        enableSearch: true,
                        allowClear: false,
                        onSelectReturn: (selected) {
                          if (selected.id == _blockedCountryId) {
                            return AppStrings.showcaseFormsBlocked;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ],
              ),

              ShowcaseSection(
                title: AppStrings.showcaseFormsSectionDate,
                flow: false,
                children: <Widget>[
                  AppFormFieldGrid(
                    fullWidth: const <int>{4},
                    children: <Widget>[
                      AppReactiveDateTimeField.dateTime(
                        formControlName: 'dateTime',
                        title: AppStrings.showcaseFormsDateTime,
                      ),
                      AppReactiveDateTimeField.date(
                        formControlName: 'dateIso',
                        title: AppStrings.showcaseFormsDateIso,
                      ),
                      AppReactiveDateTimeField.date(
                        formControlName: 'date',
                        title: AppStrings.showcaseFormsDate,
                      ),
                      AppReactiveDateTimeField.time(
                        formControlName: 'time',
                        title: AppStrings.showcaseFormsTime,
                      ),
                      AppReactiveDateTimeField.dateRange(
                        formControlName: 'dateRange',
                        title: AppStrings.showcaseFormsDateRange,
                        acceptSameDay: false,
                      ),
                      AppReactiveDateTimeField.month(
                        formControlName: 'date',
                        title: AppStrings.showcaseFormsMonth,
                      ),
                      AppReactiveDateTimeField.year(
                        formControlName: 'date',
                        title: AppStrings.showcaseFormsYear,
                      ),
                      AppReactiveDateTimeField.yearMonth(
                        formControlName: 'date',
                        title: AppStrings.showcaseFormsYearMonth,
                      ),
                    ],
                  ),
                ],
              ),

              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  AppButton.primaryGradient(
                    onTap: () {
                      _form.validateAll();
                    },
                    child: AppButtonChild.label(
                      AppStrings.showcaseFormsValidate,
                    ),
                  ),
                  AppButton.error(
                    onTap: () {
                      _form.reset();
                    },
                    child: AppButtonChild.label(AppStrings.showcaseFormsReset),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
