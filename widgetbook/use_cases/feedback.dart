import 'package:widgetbook/widgetbook.dart';

import 'package:dice_roll/ui/core/widgets/buttons/app_outlined_button.dart';
import 'package:dice_roll/ui/core/widgets/feedback/app_dialog.dart';
import 'package:dice_roll/ui/core/widgets/feedback/app_loading_indicator.dart';
import 'package:dice_roll/ui/core/widgets/feedback/app_snackbar.dart';

List<WidgetbookComponent> feedbackCatalog() => [
  WidgetbookComponent(
    name: 'AppSnackbar',
    useCases: [
      WidgetbookUseCase(
        name: 'Show (acid)',
        builder: (context) => AppOutlinedButton(
          label: 'Show snackbar',
          onPressed: () => AppSnackbar.show(context, 'Dice saved.'),
        ),
      ),
      WidgetbookUseCase(
        name: 'Error (pink)',
        builder: (context) => AppOutlinedButton(
          label: 'Show error',
          variant: AppOutlinedButtonVariant.pink,
          onPressed: () => AppSnackbar.error(context, 'Could not save dice.'),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppDialog',
    useCases: [
      WidgetbookUseCase(
        name: 'Confirm',
        builder: (context) => AppOutlinedButton(
          label: 'Open dialog',
          onPressed: () => AppDialog.confirm(
            context,
            title: 'Save dice?',
            message: 'Your changes will be applied immediately.',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Destructive',
        builder: (context) => AppOutlinedButton(
          label: 'Delete dice',
          variant: AppOutlinedButtonVariant.pink,
          onPressed: () => AppDialog.confirm(
            context,
            title: 'Delete dice?',
            message: 'This action cannot be undone.',
            confirmLabel: 'Delete',
            destructive: true,
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'AppLoadingIndicator',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (_) => const AppLoadingIndicator(),
      ),
      WidgetbookUseCase(
        name: 'Large',
        builder: (_) => const AppLoadingIndicator(size: 64, strokeWidth: 5),
      ),
    ],
  ),
];
