import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/widgets/display/app_badge.dart';
import 'package:dice_roll/ui/core/widgets/display/app_divider.dart';
import 'package:dice_roll/ui/core/widgets/display/app_drag_handle.dart';
import 'package:dice_roll/ui/core/widgets/display/app_section_label.dart';
import 'package:dice_roll/ui/core/widgets/display/app_status_dot.dart';

List<WidgetbookComponent> displayCatalog() => [
  WidgetbookComponent(
    name: 'AppBadge',
    useCases: [
      WidgetbookUseCase(
        name: 'Acid (default)',
        builder: (_) => const AppBadge(label: 'Active'),
      ),
      WidgetbookUseCase(
        name: 'Pink',
        builder: (context) => AppBadge(
          label: 'Built-in',
          color: context.appColors.pink,
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppSectionLabel',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (_) => const AppSectionLabel(label: 'Faces'),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppStatusDot',
    useCases: [
      WidgetbookUseCase(
        name: 'Bare',
        builder: (context) => AppStatusDot(color: context.appColors.acid),
      ),
      WidgetbookUseCase(
        name: 'With label',
        builder: (context) => AppStatusDot(
          color: context.appColors.acid,
          label: 'Active dice',
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppDivider',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (_) => const SizedBox(
          width: 320,
          child: AppDivider(),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppDragHandle',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (_) => const AppDragHandle(),
      ),
    ],
  ),
];
