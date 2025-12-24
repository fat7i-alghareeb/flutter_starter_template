import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/injection/injectable.dart';
import '../../../core/services/localization/locale_service.dart';
import '../../../core/config/localization_config.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../flavors.dart';
import '../button/app_button.dart';
import '../button/app_button_child.dart';
import '../button/app_button_variants.dart';
import '../app_icon_source.dart';

typedef StageToolOnPressed = void Function(BuildContext context);

enum StageToolAnchor { topLeft, topRight, bottomLeft, bottomRight }

class StageToolInitialPosition {
  const StageToolInitialPosition({
    required this.anchor,
    this.margin = const EdgeInsets.all(16),
  });

  final StageToolAnchor anchor;
  final EdgeInsets margin;

  Offset resolve(Size screenSize, {required double buttonSize}) {
    final maxX = (screenSize.width - buttonSize).clamp(0, double.infinity);
    final maxY = (screenSize.height - buttonSize).clamp(0, double.infinity);

    return switch (anchor) {
      StageToolAnchor.topLeft => Offset(margin.left, margin.top),
      StageToolAnchor.topRight => Offset(maxX - margin.right, margin.top),
      StageToolAnchor.bottomLeft => Offset(margin.left, maxY - margin.bottom),
      StageToolAnchor.bottomRight => Offset(
        maxX - margin.right,
        maxY - margin.bottom,
      ),
    };
  }
}

class StageToolDefinition {
  const StageToolDefinition({
    required this.id,
    required this.icon,
    required this.onPressed,
    required this.initialPosition,
  });

  final String id;
  final IconSource icon;
  final StageToolOnPressed onPressed;
  final StageToolInitialPosition initialPosition;
}

class StageToolsRegistry {
  const StageToolsRegistry._();

  static List<StageToolDefinition> tools() {
    return <StageToolDefinition>[
      StageToolDefinition(
        id: 'stage_tool_locale',
        icon: IconSource.icon(Icons.language),
        initialPosition: const StageToolInitialPosition(
          anchor: StageToolAnchor.bottomRight,
          margin: EdgeInsets.only(right: 16, bottom: 24 + 56),
        ),
        onPressed: (context) => _showLocaleSheet(context),
      ),
      StageToolDefinition(
        id: 'stage_tool_theme',
        icon: IconSource.icon(Icons.dark_mode),
        initialPosition: const StageToolInitialPosition(
          anchor: StageToolAnchor.bottomRight,
          margin: EdgeInsets.only(right: 16, bottom: 24),
        ),
        onPressed: (context) => _showThemeSheet(context),
      ),
    ];
  }

  static Future<void> _showLocaleSheet(BuildContext context) async {
    final localeService = getIt<LocaleService>();
    final currentCode = context.locale.languageCode.toLowerCase();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: AppLanguage.values.map((lang) {
              final code = lang.code;
              return ListTile(
                title: Text(code.toUpperCase()),
                trailing: currentCode == code ? const Icon(Icons.check) : null,
                onTap: () async {
                  await localeService.changeLanguage(lang, context);
                  if (context.mounted) Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  static Future<void> _showThemeSheet(BuildContext context) async {
    final themeController = getIt<ThemeController>();

    const options = <ThemeMode>[
      ThemeMode.system,
      ThemeMode.light,
      ThemeMode.dark,
    ];

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final current = themeController.themeMode;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: options.map((mode) {
              final label = switch (mode) {
                ThemeMode.system => 'system',
                ThemeMode.light => 'light',
                ThemeMode.dark => 'dark',
              };

              return ListTile(
                title: Text(label.toUpperCase()),
                trailing: current == mode ? const Icon(Icons.check) : null,
                onTap: () {
                  themeController.setThemeMode(mode);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class StageToolsOverlay extends StatefulWidget {
  const StageToolsOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<StageToolsOverlay> createState() => _StageToolsOverlayState();
}

class _StageToolsOverlayState extends State<StageToolsOverlay> {
  double get _buttonSize => 44.w;

  final Map<String, Offset> _positions = <String, Offset>{};

  @override
  Widget build(BuildContext context) {
    if (F.appFlavor != Flavor.stage) return widget.child;

    final tools = StageToolsRegistry.tools();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        for (final tool in tools) {
          _positions.putIfAbsent(
            tool.id,
            () => tool.initialPosition.resolve(size, buttonSize: _buttonSize),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            widget.child,
            ...tools.map((tool) {
              final offset =
                  _positions[tool.id] ??
                  tool.initialPosition.resolve(size, buttonSize: _buttonSize);
              final clamped = Offset(
                offset.dx.clamp(
                  0,
                  (size.width - _buttonSize).clamp(0, double.infinity),
                ),
                offset.dy.clamp(
                  0,
                  (size.height - _buttonSize).clamp(0, double.infinity),
                ),
              );

              return Positioned(
                left: clamped.dx,
                top: clamped.dy,
                child: _DraggableStageToolButton(
                  size: _buttonSize,
                  icon: tool.icon,
                  onTap: () => tool.onPressed(context),
                  onDragDelta: (delta) {
                    setState(() {
                      final next = (_positions[tool.id] ?? clamped) + delta;
                      _positions[tool.id] = Offset(
                        next.dx.clamp(
                          0,
                          (size.width - _buttonSize).clamp(0, double.infinity),
                        ),
                        next.dy.clamp(
                          0,
                          (size.height - _buttonSize).clamp(0, double.infinity),
                        ),
                      );
                    });
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _DraggableStageToolButton extends StatelessWidget {
  const _DraggableStageToolButton({
    required this.size,
    required this.icon,
    required this.onTap,
    required this.onDragDelta,
  });

  final double size;
  final IconSource icon;
  final VoidCallback onTap;
  final void Function(Offset delta) onDragDelta;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (details) => onDragDelta(details.delta),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular((size / 2).r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
          ),
        ),
        child: AppButton.variant(
          variant: AppButtonVariant.grey,
          fill: AppButtonFill.solid,
          shadowVariant: AppButtonShadowVariant.grey,
          layout: AppButtonLayout(
            height: size,
            shape: AppButtonShape.circle,
            contentPadding: EdgeInsets.zero,
          ),
          child: AppButtonChild.icon(icon, size: 18, padding: EdgeInsets.zero),
          onTap: onTap,
        ),
      ),
    );
  }
}
