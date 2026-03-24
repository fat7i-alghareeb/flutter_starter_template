// lib/common/import/imports.dart

library;

// Dart core (safe & common)
export 'dart:async';
export 'dart:math';

export 'package:easy_localization/easy_localization.dart' hide TextDirection;
// Flutter (UI layer)
export 'package:flutter/material.dart';
export 'package:flutter/widgets.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';

export '../../../../../core/injection/injectable.dart';
export "../../core/theme/app_colors.dart";
export "../../core/theme/app_text_styles.dart";
export "../../core/utils/status_builder.dart";
// Design system
export '../../utils/constants/design_constants.dart';
export '../../utils/extensions/context_extensions.dart';
export '../../utils/extensions/date_time_extensions.dart';
export '../../utils/extensions/enum_extensions.dart';
export '../../utils/extensions/iterable_extensions.dart';
export "../../utils/extensions/reactive_forms_extensions.dart";
export '../../utils/extensions/string_extensions.dart';
export '../../utils/extensions/text_direction_extensions.dart';
export '../../utils/extensions/theme_extensions.dart';
// Extensions (UI-safe only)
export '../../utils/extensions/widget_extensions.dart';
//assets
export '../../utils/gen/assets.gen.dart';
// AppStrings
export "../../utils/helpers/app_strings.dart";
export "../../utils/helpers/build_svg_icon.dart";
// helpers
export "../../utils/helpers/colored_print.dart";
export "../../utils/helpers/input_formatters.dart";
export "../widgets/app_bottom_sheet.dart";
export "../widgets/app_dialog.dart";
export "../widgets/app_icon_source.dart";
export "../widgets/app_image_viewer.dart";
export "../widgets/app_shimmer.dart";
// widgets
export "../widgets/button/app_button.dart";
export "../widgets/button/app_button_child.dart";
export "../widgets/button/app_button_variants.dart";
export "../widgets/empty_state_widget.dart";
export "../widgets/failed_state_widget.dart";
export "../widgets/form/app_reactive_text_field.dart";
export "../widgets/form/app_reactive_validation_messages.dart";
export "../widgets/full_screen_image_screen.dart";
export "../widgets/loading_dots.dart";
export "../widgets/main_loading_progress.dart";
