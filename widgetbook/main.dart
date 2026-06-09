import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:dice_roll/ui/core/theme/app_theme.dart';

import 'use_cases/buttons.dart';
import 'use_cases/display.dart';
import 'use_cases/feedback.dart';
import 'use_cases/inputs.dart';
import 'use_cases/layout.dart';
import 'use_cases/surfaces.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Arcade Dark', data: AppTheme.dark),
          ],
        ),
      ],
      directories: [
        WidgetbookFolder(name: 'Buttons', children: buttonsCatalog()),
        WidgetbookFolder(name: 'Layout', children: layoutCatalog()),
        WidgetbookFolder(name: 'Inputs', children: inputsCatalog()),
        WidgetbookFolder(name: 'Surfaces', children: surfacesCatalog()),
        WidgetbookFolder(name: 'Feedback', children: feedbackCatalog()),
        WidgetbookFolder(name: 'Display', children: displayCatalog()),
      ],
    );
  }
}
