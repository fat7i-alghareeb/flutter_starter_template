import 'package:flutter/material.dart';
import 'package:test_name_to_delete/common/widgets/app_icon_source.dart';

class AppAffixes {
  const AppAffixes({
    this.prefixIcon,
    this.suffixIcon,
    this.onPrefixTap,
    this.onSuffixTap,
  });

  final IconSource? prefixIcon;
  final IconSource? suffixIcon;
  final VoidCallback? onPrefixTap;
  final VoidCallback? onSuffixTap;
}
