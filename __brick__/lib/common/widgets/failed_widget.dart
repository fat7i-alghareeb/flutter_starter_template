// // 🌎 Project imports:

// import 'dart:ui' show VoidCallback;

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// /// FailedWidget
// /// ------------
// ///
// /// A polished, reusable failure UI widget with:
// /// - Prominent visual state (icon inside gradient badge)
// /// - Localized title and message areas
// /// - Optional details section (expandable) for debugging or advanced messages
// /// - Primary retry action and optional secondary support action
// /// - Responsive paddings and accessible text sizes
// ///
// /// Usage:
// /// ```dart
// /// FailedWidget(
// ///   title: AppStrings.somethingWentWrong,
// ///   message: errorMessage,
// ///   details: stackOrDetails,
// ///   onRetry: reload,
// ///   onContact: () => context.beamToNamed(ContactUsScreen.pagePath),
// /// )
// /// ```
// class FailedWidget extends StatelessWidget {
//   const FailedWidget({
//     super.key,
//     this.title,
//     required this.message,
//     this.details,
//     this.onRetry,
//     this.onContact,
//     this.dense = false,
//   });

//   /// //! Title shown above the main message
//   /// //? Defaults to a generic localized error title
//   final String? title;

//   /// //! Main user-facing error message
//   final String message;

//   /// //! Optional expandable technical details (e.g., stack, raw message)
//   final String? details;

//   /// //! Retry callback
//   final VoidCallback? onRetry;

//   /// //! Secondary action (e.g., contact support)
//   final VoidCallback? onContact;

//   /// //! Dense mode for embedding inside tight layouts
//   final bool dense;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final Color fg = theme.colorScheme.onSurface;
//     final Color badgeBg = AppColors.danger.withValues(alpha: 0.12);
//     const Color badgeIcon = AppColors.danger;

//     return Center(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: 560.w),
//         child: Container(
//           padding: REdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: dense ? 16 : 28,
//           ),
//           margin: REdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: theme.scaffoldBackgroundColor,
//             borderRadius: BorderRadius.circular(16.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.04),
//                 blurRadius: 12,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _Badge(iconColor: badgeIcon, bgColor: badgeBg),
//               dense ? 10.verticalSpace : 16.verticalSpace,
//               Text(
//                 title?.trim().isNotEmpty == true
//                     ? title!
//                     : AppStrings.somethingWentWrong,
//                 textAlign: TextAlign.center,
//                 style: theme.textTheme.headlineLarge?.copyWith(
//                   fontWeight: FontWeight.w700,
//                   color: fg,
//                 ),
//               ),
//               8.verticalSpace,
//               Text(
//                 message,
//                 textAlign: TextAlign.center,
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   color: fg.withValues(alpha: 0.8),
//                 ),
//               ),
//               if (details != null && details!.trim().isNotEmpty) ...[
//                 1.verticalSpace,
//                 _DetailsTile(details: details!),
//               ],
//               dense ? 12.verticalSpace : 20.verticalSpace,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (onRetry != null)
//                     Flexible(
//                       child: AuthButton.danger(
//                         title: AppStrings.tryAgain,
//                         onPressed: onRetry!,
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _Badge extends StatelessWidget {
//   const _Badge({required this.iconColor, required this.bgColor});
//   final Color iconColor;
//   final Color bgColor;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 64.r,
//       height: 64.r,
//       decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
//       alignment: Alignment.center,
//       child: Icon(Icons.error_rounded, size: 36.r, color: iconColor),
//     );
//   }
// }

// class _DetailsTile extends StatefulWidget {
//   const _DetailsTile({required this.details});
//   final String details;
//   @override
//   State<_DetailsTile> createState() => _DetailsTileState();
// }

// class _DetailsTileState extends State<_DetailsTile> {
//   bool _expanded = false;
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeInOut,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.r),
//         color: theme.colorScheme.surfaceContainerHighest,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12.r),
//         child: ExpansionTile(
//           tilePadding: REdgeInsets.symmetric(horizontal: 12, vertical: 2),
//           childrenPadding: REdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           title: Text(
//             _expanded ? AppStrings.showLess : AppStrings.showMore,
//             style: theme.textTheme.labelLarge?.copyWith(
//               color: AppColors.primary,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           trailing: Icon(
//             _expanded ? Icons.expand_less : Icons.expand_more,
//             color: AppColors.primary,
//           ),
//           onExpansionChanged: (v) => setState(() => _expanded = v),
//           children: [
//             SelectableText(
//               widget.details,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
