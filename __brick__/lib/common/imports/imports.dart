// lib/common/import/imports.dart

library imports;

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
export "../../core/theme/app_colors.dart";
export "../../core/theme/app_text_styles.dart";
