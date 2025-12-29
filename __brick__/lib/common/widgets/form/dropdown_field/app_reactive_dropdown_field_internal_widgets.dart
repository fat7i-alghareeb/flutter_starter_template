part of 'app_reactive_dropdown_field.dart';

/// Internal title widget used by [AppReactiveDropdownField].
///
/// Kept private to keep the public API small and consistent with other form
/// widgets.
class _FieldTitle extends StatelessWidget {
  const _FieldTitle({
    required this.title,
    required this.isRequired,
    required this.style,
  });

  final String title;
  final bool isRequired;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            title,
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Required indicator is shown next to the title.
        if (isRequired) ...[
          AppSpacing.xs.horizontalSpace,
          Text('*', style: style.copyWith(color: AppColors.error)),
        ],
      ],
    );
  }
}

/// A small hit-target wrapper used for the dropdown tap areas.
///
/// This mimics the pattern used by other form widgets in the project.
class _TapArea extends StatelessWidget {
  const _TapArea({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Using GestureDetector with opaque behavior makes the whole area tappable
    // (including empty padding).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

/// The clear icon shown when there is a selected value and allowClear is true.
class _ClearIcon extends StatelessWidget {
  const _ClearIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.close, size: 20.sp, color: context.grey);
  }
}

/// The default arrow icon shown when there is no selected value.
class _ArrowIcon extends StatelessWidget {
  const _ArrowIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.keyboard_arrow_down, size: 24.sp, color: context.grey);
  }
}

/// Displays either the selected value text or the hint text.
class _DropdownValueText extends StatelessWidget {
  const _DropdownValueText({
    required this.text,
    required this.hintText,
    required this.textStyle,
    required this.hintStyle,
  });

  final String text;
  final String? hintText;
  final TextStyle textStyle;
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) {
    // Treat whitespace as empty.
    final hasText = text.trim().isNotEmpty;
    return Text(
      hasText ? text : (hintText ?? ''),
      style: hasText ? textStyle : (hintStyle ?? textStyle),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _DropdownPicker<T> extends StatefulWidget {
  const _DropdownPicker({
    required this.options,
    required this.selected,
    required this.enableSearch,
    required this.optionsTextStyle,
    required this.onSelect,
  });

  final List<AppDropdownOption<T>> options;
  final AppDropdownOption<T>? selected;
  final bool enableSearch;
  final TextStyle? optionsTextStyle;
  final ValueChanged<AppDropdownOption<T>> onSelect;

  @override
  State<_DropdownPicker<T>> createState() => _DropdownPickerState<T>();
}

class _DropdownPickerState<T> extends State<_DropdownPicker<T>> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppDropdownOption<T>> _filteredOptions() {
    final q = _query.trim().toLowerCase();
    if (!widget.enableSearch || q.isEmpty) return widget.options;
    return widget.options
        .where((o) => o.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final options = _filteredOptions();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.enableSearch)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
            child: Container(
              decoration: BoxDecoration(
                color: context.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(AppRadii.sm.r),
                border: Border.all(color: context.grey.withValues(alpha: 0.35)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm.w,
                vertical: 10.h,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.search,
                    size: 18.sp,
                    color: context.grey.withValues(alpha: 0.9),
                  ),
                  AppSpacing.sm.horizontalSpace,
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        setState(() {
                          _query = v;
                        });
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: AppStrings.search,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.trim().isNotEmpty)
                    _TapArea(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: context.grey.withValues(alpha: 0.9),
                      ),
                    ),
                ],
              ),
            ),
          ),
        Flexible(
          child: options.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
                  child: Text(
                    AppStrings.noResultsFound,
                    style: AppTextStyles.s14w400.copyWith(
                      color: context.grey.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, _) => AppSpacing.xs.verticalSpace,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = widget.selected?.id == option.id;

                    final enabled = option.enable;
                    final bg = isSelected
                        ? context.primary.withValues(alpha: 0.12)
                        : Colors.transparent;

                    final borderColor = isSelected
                        ? context.primary
                        : context.grey.withValues(alpha: 0.25);

                    final color = !enabled
                        ? context.grey.withValues(alpha: 0.7)
                        : (isSelected ? context.primary : context.onSurface);

                    final textStyle =
                        (widget.optionsTextStyle ?? AppTextStyles.s14w400)
                            .copyWith(color: color);

                    return _TapArea(
                      onTap: enabled ? () => widget.onSelect(option) : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm.w,
                          vertical: AppSpacing.sm.h,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(AppRadii.sm.r),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          option.name,
                          style: textStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
