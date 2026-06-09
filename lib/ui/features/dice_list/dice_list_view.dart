import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_colors.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_icon_button.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_outlined_button.dart';
import 'package:dice_roll/ui/core/widgets/dice_face_preview.dart';
import 'package:dice_roll/ui/core/widgets/display/app_divider.dart';
import 'package:dice_roll/ui/core/widgets/display/app_section_label.dart';
import 'package:dice_roll/ui/core/widgets/feedback/app_dialog.dart';
import 'package:dice_roll/ui/core/widgets/feedback/app_loading_indicator.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:dice_roll/ui/screens/dice_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiceListView extends StatelessWidget {
  const DiceListView({super.key});

  @override
  Widget build(BuildContext context) => const _DiceListBody();
}

class _DiceListBody extends StatelessWidget {
  const _DiceListBody();

  Future<void> _confirmDelete(BuildContext context, DiceEntity dice) async {
    final management = context.read<DiceManagementProvider>();
    final activeDice = context.read<DiceGameProvider>();
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Delete "${dice.title}"?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      destructive: true,
    );
    if (confirmed != true) {
      return;
    }
    await management.delete(dice.id);
    await activeDice.refresh();
  }

  Future<void> _openEditor(BuildContext context, {String? diceId}) async {
    // The management provider reloads its list on save, so the list rebuilds
    // automatically when the editor pops.
    await Navigator.of(context).pushNamed(
      DiceEditorScreen.routeName,
      arguments: DiceEditorArguments(diceId: diceId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiceManagementProvider>();
    return Stack(
      children: [
        vm.isLoading
            ? const Center(child: AppLoadingIndicator())
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                itemCount: vm.dice.length,
                separatorBuilder: (_, _) => const AppDivider(height: 0),
                itemBuilder: (context, index) {
                  final dice = vm.dice[index];
                  return Padding(
                    padding: index == vm.dice.length - 1
                        ? const EdgeInsets.only(bottom: 80)
                        : EdgeInsets.zero,
                    child: _DiceTile(
                      dice: dice,
                      onTap: dice.isBuiltIn
                          ? null
                          : () => _openEditor(context, diceId: dice.id),
                      onDelete: dice.isBuiltIn
                          ? null
                          : () => _confirmDelete(context, dice),
                    ),
                  );
                },
              ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.l),
                child: AppOutlinedButton(
                  label: 'New dice',
                  icon: Icons.add,
                  onPressed: () => _openEditor(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiceTile extends StatelessWidget {
  final DiceEntity dice;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _DiceTile({
    required this.dice,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final preview = dice.faces.first;
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 48,
        height: 48,
        child: DiceFacePreview(
          face: preview,
          borderRadius: AppRadii.sBR,
          backgroundCacheWidth: 96,
          foregroundCacheWidth: 80,
          foregroundConstraints: const BoxConstraints(
            maxWidth: 40,
            maxHeight: 40,
          ),
        ),
      ),
      title: Text(dice.title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: AppSectionLabel(
        label: dice.isBuiltIn
            ? '${dice.faces.length} faces · Built-in'
            : '${dice.faces.length} faces',
      ),
      trailing: AppIconButton(
        icon: onDelete == null
            ? Icons.lock_outline
            : Icons.delete_forever_outlined,
        color: onDelete == null ? null : AppColors.pink,
        onPressed: onDelete,
      ),
    );
  }
}
