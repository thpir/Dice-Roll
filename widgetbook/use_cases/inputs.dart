import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:dice_roll/ui/core/widgets/inputs/app_color_swatch.dart';
import 'package:dice_roll/ui/core/widgets/inputs/app_image_slot.dart';
import 'package:dice_roll/ui/core/widgets/inputs/app_text_field.dart';

List<WidgetbookComponent> inputsCatalog() => [
  WidgetbookComponent(
    name: 'AppTextField',
    useCases: [
      WidgetbookUseCase(
        name: 'Empty',
        builder: (_) => const SizedBox(
          width: 320,
          child: AppTextField(hintText: 'Title'),
        ),
      ),
      WidgetbookUseCase(
        name: 'With value',
        builder: (_) => SizedBox(
          width: 320,
          child: AppTextField(
            controller: TextEditingController(text: 'Decision dice'),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Multiline',
        builder: (_) => const SizedBox(
          width: 320,
          child: AppTextField(
            hintText: 'Describe the dice...',
            maxLines: 4,
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppColorSwatch',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (_) => AppColorSwatch(
          color: const Color(0xFFE5523B),
          onTap: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Selected',
        builder: (_) => AppColorSwatch(
          color: const Color(0xFF2E6BE6),
          selected: true,
          onTap: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Large',
        builder: (_) => AppColorSwatch(
          color: const Color(0xFFF6C84D),
          size: 96,
          onTap: () {},
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppImageSlot',
    useCases: [
      WidgetbookUseCase(
        name: 'Empty',
        builder: (_) => AppImageSlot(size: 48, onTap: () {}),
      ),
      WidgetbookUseCase(
        name: 'Large',
        builder: (_) => AppImageSlot(size: 120, onTap: () {}),
      ),
      WidgetbookUseCase(
        name: 'With label',
        builder: (_) => AppImageSlot(
          size: 96,
          label: 'BG',
          placeholderIcon: Icons.wallpaper_outlined,
          onTap: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'With image and clear',
        builder: (_) => AppImageSlot(
          size: 96,
          label: 'FG',
          imageChild: const ColoredBox(color: Color(0xFFE5523B)),
          onTap: () {},
          onClear: () {},
        ),
      ),
      WidgetbookUseCase(
        name: 'Flex width',
        builder: (_) => SizedBox(
          width: 240,
          child: AppImageSlot(
            height: 56,
            label: 'BG',
            placeholderIcon: Icons.wallpaper_outlined,
            onTap: () {},
          ),
        ),
      ),
    ],
  ),
];
