import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_icon_button.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_outlined_button.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_primary_button.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_text_button.dart';

List<WidgetbookComponent> buttonsCatalog() => [
  WidgetbookComponent(
    name: 'AppPrimaryButton',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (_) => AppPrimaryButton(
          label: 'Tap to roll',
          icon: Icons.touch_app,
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Without icon',
        builder: (_) => AppPrimaryButton(
          label: 'Save',
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Disabled',
        builder: (_) => const AppPrimaryButton(
          label: 'Tap to roll',
          icon: Icons.touch_app,
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppOutlinedButton',
    useCases: [
      WidgetbookUseCase(
        name: 'Acid (default)',
        builder: (_) => AppOutlinedButton(
          label: 'New dice',
          icon: Icons.add,
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Pink',
        builder: (_) => AppOutlinedButton(
          label: 'Add face',
          icon: Icons.add,
          variant: AppOutlinedButtonVariant.pink,
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'No icon',
        builder: (_) => AppOutlinedButton(
          label: 'Cancel',
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Disabled',
        builder: (_) => const AppOutlinedButton(
          label: 'New dice',
          icon: Icons.add,
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppIconButton',
    useCases: [
      WidgetbookUseCase(
        name: 'Bare',
        builder: (_) => AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Framed acid',
        builder: (context) => AppIconButton(
          icon: Icons.casino_outlined,
          framed: true,
          color: context.appColors.acid,
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Framed pink',
        builder: (context) => AppIconButton(
          icon: Icons.settings,
          framed: true,
          color: context.appColors.pink,
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Destructive',
        builder: (context) => AppIconButton(
          icon: Icons.delete_outline,
          color: context.appColors.pink,
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Disabled',
        builder: (_) => const AppIconButton(
          icon: Icons.arrow_back,
          onPressed: null,
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppTextButton',
    useCases: [
      WidgetbookUseCase(
        name: 'Default (acid)',
        builder: (_) => AppTextButton(
          label: 'Save',
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Pink (destructive)',
        builder: (context) => AppTextButton(
          label: 'Delete',
          color: context.appColors.pink,
          onPressed: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Disabled',
        builder: (_) => const AppTextButton(
          label: 'Save',
          onPressed: null,
        ),
      ),
    ],
  ),
];
