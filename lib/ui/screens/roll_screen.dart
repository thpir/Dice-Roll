import 'dart:math';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_icon_button.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_primary_button.dart';
import 'package:dice_roll/ui/core/widgets/display/app_status_dot.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_app_bar.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_scaffold.dart';
import 'package:dice_roll/ui/features/roll/roll_view.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/screens/dice_list_screen.dart';
import 'package:dice_roll/ui/screens/dice_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RollScreen extends StatelessWidget {
  static const routeName = '/roll';

  const RollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<DiceGameProvider>();

    return AppScaffold(
      appBar: AppAppBar(
        showBackButton: false,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppStatusDot(color: context.appColors.acid, label: 'active dice'),
            Text(
              game.activeDice.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          AppIconButton(
            icon: Icons.casino_outlined,
            onPressed: () =>
                Navigator.of(context).pushNamed(DiceSelectorScreen.routeName),
            framed: true,
            color: context.appColors.acid,
          ),
          const SizedBox(width: AppSpacing.s),
          AppIconButton(
            icon: Icons.settings_outlined,
            onPressed: () =>
                Navigator.of(context).pushNamed(DiceListScreen.routeName),
            framed: true,
            color: context.appColors.pink,
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
          child: Column(
            spacing: AppSpacing.l,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    final smallestDimension = min(size.width, size.height);
                    final squareSize = smallestDimension * 0.8;

                    return Center(
                      child: SizedBox.square(
                        dimension: squareSize,
                        child: GestureDetector(
                          onTap: () {
                            if (!game.isRolling) {
                              game.startRolling();
                            }
                          },
                          child: RollView(
                            key: ValueKey(
                              '${game.activeDice.id}-${game.currentFace.id}',
                            ),
                            oldFace: game.oldFace,
                            newFace: game.currentFace,
                            animationSpeed: game.currentAnimationSpeed(),
                            onAnimationComplete: game.onAnimationComplete,
                            size: squareSize,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                      label: 'Tap to Roll',
                      onPressed: game.startRolling,
                      icon: Icons.touch_app,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
