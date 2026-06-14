import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_icon_button.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_outlined_button.dart';
import 'package:dice_roll/ui/core/widgets/dice_face_preview.dart';
import 'package:dice_roll/ui/core/widgets/display/app_badge.dart';
import 'package:dice_roll/ui/core/widgets/display/app_section_label.dart';
import 'package:dice_roll/ui/core/widgets/feedback/app_loading_indicator.dart';
import 'package:dice_roll/ui/features/dice_selector/view_model/dice_selector_view_model.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiceSelectorView extends StatelessWidget {
  const DiceSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    // The view model is a stateless coordinator over the app-wide
    // DiceGameProvider, so a plain Provider (not ChangeNotifierProvider) is the
    // right fit — the body listens to DiceGameProvider itself for rebuilds.
    return Provider<DiceSelectorViewModel>(
      create: (context) =>
          DiceSelectorViewModel(context.read<DiceGameProvider>()),
      child: const _DiceSelectorBody(),
    );
  }
}

class _DiceSelectorBody extends StatelessWidget {
  const _DiceSelectorBody();

  @override
  Widget build(BuildContext context) {
    final management = context.watch<DiceManagementProvider>();
    // Rebuild whenever the tray (quantities / maxDice) changes.
    context.watch<DiceGameProvider>();
    final vm = context.read<DiceSelectorViewModel>();

    if (management.isLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    return Column(
      children: [
        _SelectorHeader(
          selectedCount: vm.selectedCount,
          maxDice: vm.maxDice,
          onReset: vm.resetToDefault,
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.l),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisSpacing: AppSpacing.l,
              crossAxisSpacing: AppSpacing.l,
              childAspectRatio: 0.62,
            ),
            itemCount: management.dice.length,
            itemBuilder: (context, index) {
              final dice = management.dice[index];
              return _DiceCard(
                dice: dice,
                quantity: vm.quantityOf(dice),
                canIncrement: vm.canIncrement(dice),
                onIncrement: () => vm.increment(dice),
                onDecrement: () => vm.decrement(dice),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SelectorHeader extends StatelessWidget {
  final int selectedCount;
  final int maxDice;
  final VoidCallback onReset;

  const _SelectorHeader({
    required this.selectedCount,
    required this.maxDice,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionLabel(label: 'tray'),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '$selectedCount / $maxDice dice',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          AppOutlinedButton(
            label: 'Reset',
            icon: Icons.refresh,
            variant: AppOutlinedButtonVariant.pink,
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}

class _DiceCard extends StatelessWidget {
  final DiceEntity dice;
  final int quantity;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _DiceCard({
    required this.dice,
    required this.quantity,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selected = quantity > 0;
    final preview = dice.faces.first;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(
              color: selected ? colors.acid : colors.outline,
            ),
            boxShadow: selected
                ? [BoxShadow(color: colors.acid, offset: const Offset(4, 4))]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DiceFacePreview(
                    face: preview,
                    borderRadius: AppRadii.sBR,
                    backgroundCacheWidth: 240,
                    foregroundCacheWidth: 160,
                    foregroundConstraints: const BoxConstraints(
                      maxWidth: 80,
                      maxHeight: 80,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  dice.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSectionLabel(label: '${dice.faces.length} faces'),
                const SizedBox(height: AppSpacing.s),
                _QuantityStepper(
                  quantity: quantity,
                  onIncrement: canIncrement ? onIncrement : null,
                  onDecrement: quantity > 0 ? onDecrement : null,
                ),
              ],
            ),
          ),
        ),
        if (selected)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: AppBadge(
                label: '×$quantity',
                color: colors.acid,
                textColor: colors.onPink,
              ),
            ),
          ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppIconButton(
          icon: Icons.remove,
          onPressed: onDecrement,
          framed: true,
          color: colors.pink,
          size: 18,
        ),
        Text(
          '$quantity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AppIconButton(
          icon: Icons.add,
          onPressed: onIncrement,
          framed: true,
          color: colors.acid,
          size: 18,
        ),
      ],
    );
  }
}
