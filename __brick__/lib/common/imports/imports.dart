// lib/common/import/imports.dart

library;

// Flutter (UI layer)
export 'package:flutter/material.dart';
export 'package:flutter/widgets.dart';

// Dart core (safe & common)
export 'dart:async';
export 'dart:math';

// Design system
export '../../utils/constants/design_constants.dart';

// Extensions (UI-safe only)
export '../../utils/extensions/widget_extensions.dart';
export '../../utils/extensions/context_extensions.dart';
export '../../utils/extensions/string_extensions.dart';
export '../../utils/extensions/date_time_extensions.dart';
export '../../utils/extensions/enum_extensions.dart';
export '../../utils/extensions/iterable_extensions.dart';
export '../../utils/extensions/text_direction_extensions.dart';
export '../../utils/extensions/theme_extensions.dart';

// AppStrings
export "../../utils/helpers/app_strings.dart";

// helpers
export "../../utils/helpers/colored_print.dart";
export "../../utils/helpers/build_svg_icon.dart";
export "../../utils/helpers/input_formatters.dart";
export "../../core/theme/app_colors.dart";
export "../../core/theme/app_text_styles.dart";
export "../../utils/extensions/reactive_forms_extensions.dart";

// widgets
export "../widgets/button/app_button.dart";
export "../widgets/button/app_button_child.dart";
export "../widgets/app_icon_source.dart";
export "../widgets/button/app_button_variants.dart";
export "../widgets/form/app_reactive_text_field.dart";
export "../widgets/form/app_reactive_validation_messages.dart";
export "../widgets/app_shimmer.dart";
export "../widgets/app_image_viewer.dart";
export "../widgets/full_screen_image_screen.dart";
export "../widgets/app_dialog.dart";
export "../widgets/app_bottom_sheet.dart";
export "../widgets/empty_state_widget.dart";
export "../widgets/failed_state_widget.dart";
export "../widgets/loading_dots.dart";
export "../widgets/main_loading_progress.dart";
export 'package:flutter_screenutil/flutter_screenutil.dart';

//assets
export '../../utils/gen/assets.gen.dart';
export 'package:easy_localization/easy_localization.dart' hide TextDirection;
