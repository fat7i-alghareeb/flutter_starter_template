import 'package:flutter/widgets.dart';

import '../../../utils/constants/design_constants.dart';

/// Lays form fields out two to a row once there is room, one per row
/// before that.
///
/// Short fields side by side read as one form on a wide screen instead of a
/// tall strip of inputs. The row breaks at [twoColumnWidth] of the space the
/// grid itself gets — a form in a narrow pane stays one column on a desktop
/// too. Order is reading order: the first field starts each row.
///
/// Pass [fullWidth] indexes for fields that should keep a whole row — a
/// multi-line message, a date range.
class AppFormFieldGrid extends StatelessWidget {
  const AppFormFieldGrid({
    super.key,
    required this.children,
    this.fullWidth = const <int>{},
    this.spacing = AppSpacing.md,
    this.twoColumnWidth = 600,
  });

  final List<Widget> children;
  final Set<int> fullWidth;
  final double spacing;
  final double twoColumnWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= twoColumnWidth;
        final rows = <Widget>[];
        var i = 0;
        while (i < children.length) {
          final canPair =
              twoColumns &&
              !fullWidth.contains(i) &&
              i + 1 < children.length &&
              !fullWidth.contains(i + 1);
          if (canPair) {
            rows.add(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: children[i]),
                  SizedBox(width: spacing),
                  Expanded(child: children[i + 1]),
                ],
              ),
            );
            i += 2;
          } else {
            rows.add(children[i]);
            i += 1;
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (var r = 0; r < rows.length; r++) ...<Widget>[
              if (r > 0) SizedBox(height: spacing),
              rows[r],
            ],
          ],
        );
      },
    );
  }
}
