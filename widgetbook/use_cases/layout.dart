import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_text_button.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_app_bar.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_scaffold.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_screen_padding.dart';

List<WidgetbookComponent> layoutCatalog() => [
  WidgetbookComponent(
    name: 'AppScaffold',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (context) => AppScaffold(
          appBar: const AppAppBar(
            title: 'Manage dice',
            showBackButton: false,
          ),
          body: Center(
            child: Text(
              'Body content',
              style: AppTypography.bodyM.copyWith(
                color: context.appColors.ink,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppAppBar',
    useCases: [
      WidgetbookUseCase(
        name: 'Title only',
        builder: (_) => const Scaffold(
          appBar: AppAppBar(title: 'Manage dice', showBackButton: false),
          body: SizedBox.shrink(),
        ),
      ),
      WidgetbookUseCase(
        name: 'With trailing action',
        builder: (_) => Scaffold(
          appBar: AppAppBar(
            title: 'New dice',
            showBackButton: false,
            actions: [
              AppTextButton(label: 'Save', onPressed: () {}),
            ],
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppScreenPadding',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (context) => Container(
          color: context.appColors.outline,
          height: 200,
          child: AppScreenPadding(
            child: Container(color: context.appColors.acid),
          ),
        ),
      ),
    ],
  ),
];
