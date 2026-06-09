import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';
import 'package:dice_roll/ui/core/widgets/surfaces/app_card.dart';

List<WidgetbookComponent> surfacesCatalog() => [
  WidgetbookComponent(
    name: 'AppCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (context) => SizedBox(
          width: 320,
          child: AppCard(
            child: Text(
              'Card content',
              style: AppTypography.bodyM.copyWith(
                color: context.appColors.ink,
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'With acid border',
        builder: (context) => SizedBox(
          width: 320,
          child: AppCard(
            borderColor: context.appColors.acid,
            child: Text(
              'Active card',
              style: AppTypography.bodyM.copyWith(
                color: context.appColors.ink,
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Tappable',
        builder: (context) => SizedBox(
          width: 320,
          child: AppCard(
            onTap: () {},
            child: Text(
              'Tap me',
              style: AppTypography.bodyM.copyWith(
                color: context.appColors.ink,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
];
