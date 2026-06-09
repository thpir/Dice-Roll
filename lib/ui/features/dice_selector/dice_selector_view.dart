import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_colors.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/widgets/dice_face_preview.dart';
import 'package:dice_roll/ui/core/widgets/display/app_badge.dart';
import 'package:dice_roll/ui/core/widgets/display/app_section_label.dart';
import 'package:dice_roll/ui/core/widgets/feedback/app_loading_indicator.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiceSelectorView extends StatelessWidget {
  const DiceSelectorView({super.key});

  @override
  Widget build(BuildContext context) => const _DiceSelectorBody();
}

class _DiceSelectorBody extends StatelessWidget {
  const _DiceSelectorBody();

  Future<void> _select(BuildContext context, DiceEntity dice) async {
    final active = context.read<DiceGameProvider>();
    final navigator = Navigator.of(context);
    await active.select(dice);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiceManagementProvider>();
    final activeId = context.watch<DiceGameProvider>().activeDice.id;
    return vm.isLoading
        ? const Center(child: AppLoadingIndicator())
        : GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.l),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisSpacing: AppSpacing.l,
              crossAxisSpacing: AppSpacing.l,
              childAspectRatio: 0.85,
            ),
            itemCount: vm.dice.length,
            itemBuilder: (context, index) {
              final dice = vm.dice[index];
              return _DiceCard(
                dice: dice,
                isActive: dice.id == activeId,
                onTap: () => _select(context, dice),
              );
            },
          );
  }
}

class _DiceCard extends StatelessWidget {
  final DiceEntity dice;
  final bool isActive;
  final VoidCallback onTap;

  const _DiceCard({
    required this.dice,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = dice.faces.first;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                color: isActive ? AppColors.acid : AppColors.outline,
              ),
              boxShadow: isActive
                  ? [
                      const BoxShadow(
                        color: AppColors.acid,
                        offset: Offset(4, 4),
                      ),
                    ]
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
                  const SizedBox(height: 8),
                  Text(
                    dice.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSectionLabel(label: '${dice.faces.length} faces'),
                ],
              ),
            ),
          ),
          isActive
              ? const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s),
                    child: AppBadge(
                      label: 'Active',
                      color: AppColors.acid,
                      textColor: AppColors.onPink,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
