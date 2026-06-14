import 'dart:math';

import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_icon_button.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_primary_button.dart';
import 'package:dice_roll/ui/core/widgets/dice_face_precache.dart';
import 'package:dice_roll/ui/core/widgets/display/app_section_label.dart';
import 'package:dice_roll/ui/core/widgets/display/app_status_dot.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_app_bar.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_scaffold.dart';
import 'package:dice_roll/ui/features/roll/roll_view.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/providers/die_slot.dart';
import 'package:dice_roll/ui/screens/dice_list_screen.dart';
import 'package:dice_roll/ui/screens/dice_selector_screen.dart';
import 'package:dice_roll/utils/dice_fit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RollScreen extends StatefulWidget {
  static const routeName = '/roll';

  const RollScreen({super.key});

  @override
  State<RollScreen> createState() => _RollScreenState();
}

class _RollScreenState extends State<RollScreen> {
  String? _precachedKey;
  Size? _lastRollArea;
  Size? _lastScreenSize;

  /// Warms the image cache for the faces of every dice type in the tray. Keyed
  /// by the sorted set of dice ids so the repeated notifications during a roll
  /// don't re-trigger it, and scheduled post-frame so precaching never runs
  /// during build.
  void _maybePrecache(DiceGameProvider game) {
    final uniqueDice = <String, DiceEntity>{
      for (final slot in game.slots) slot.dice.id: slot.dice,
    };
    final key = (uniqueDice.keys.toList()..sort()).join(',');
    if (key == _precachedKey) {
      return;
    }
    _precachedKey = key;
    final faces = [for (final dice in uniqueDice.values) ...dice.faces];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        precacheDiceFaces(context, faces);
      }
    });
  }

  /// Reports the roll area and full screen size to the provider so it can
  /// (re)compute how many dice fit in *both* orientations. Guarded so identical
  /// layouts don't schedule redundant updates, and deferred post-frame because
  /// [DiceGameProvider.setAvailableArea] may notify.
  void _maybeUpdateArea(DiceGameProvider game, Size rollArea, Size screenSize) {
    if (rollArea == _lastRollArea && screenSize == _lastScreenSize) {
      return;
    }
    _lastRollArea = rollArea;
    _lastScreenSize = screenSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        game.setAvailableArea(rollArea, screenSize: screenSize);
      }
    });
  }

  String _trayTitle(int count) {
    if (count == 0) {
      return 'No dice';
    }
    return count == 1 ? '1 die' : '$count dice';
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<DiceGameProvider>();
    final screenSize = MediaQuery.sizeOf(context);
    _maybePrecache(game);
    final slots = game.slots;

    return AppScaffold(
      appBar: AppAppBar(
        showBackButton: false,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppStatusDot(color: context.appColors.acid, label: 'tray'),
            Text(
              _trayTitle(slots.length),
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
                    _maybeUpdateArea(game, constraints.biggest, screenSize);
                    if (slots.isEmpty) {
                      return const _EmptyTray();
                    }
                    return _DiceGrid(
                      slots: slots,
                      area: constraints.biggest,
                      isRolling: game.isRolling,
                      onRoll: game.rollAll,
                      onToggleLock: game.toggleLock,
                      onSlotAnimationComplete: game.onSlotAnimationComplete,
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
                      // Disabled while a roll is in flight (re-taps ignored) and
                      // when there's nothing to roll (empty tray / all locked).
                      onPressed: (game.isRolling || !game.canRoll)
                          ? null
                          : game.rollAll,
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

/// Lays out the tray as a grid of square cells sized to fill the available
/// area, picking the column count that lets the dice grow as large as possible.
class _DiceGrid extends StatelessWidget {
  final List<DieSlot> slots;
  final Size area;
  final bool isRolling;
  final VoidCallback onRoll;
  final void Function(String slotId) onToggleLock;
  final void Function(String slotId) onSlotAnimationComplete;

  const _DiceGrid({
    required this.slots,
    required this.area,
    required this.isRolling,
    required this.onRoll,
    required this.onToggleLock,
    required this.onSlotAnimationComplete,
  });

  @override
  Widget build(BuildContext context) {
    final columns = gridColumnsFor(slots.length, area);
    final rows = (slots.length / columns).ceil();
    final tile = min(area.width / columns, area.height / rows);

    final gridRows = <Widget>[];
    for (var row = 0; row < rows; row++) {
      final cells = <Widget>[];
      for (var col = 0; col < columns; col++) {
        final index = row * columns + col;
        if (index >= slots.length) {
          break;
        }
        final slot = slots[index];
        cells.add(
          _DieCell(
            key: ValueKey(slot.slotId),
            slot: slot,
            tile: tile,
            isRolling: isRolling,
            onRoll: onRoll,
            onToggleLock: onToggleLock,
            onAnimationComplete: onSlotAnimationComplete,
          ),
        );
      }
      gridRows.add(Row(mainAxisSize: MainAxisSize.min, children: cells));
    }

    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: gridRows),
    );
  }
}

/// A single tappable die cell: tap rolls the whole tray, long-press locks just
/// this die, and a lock overlay marks it when locked.
class _DieCell extends StatelessWidget {
  final DieSlot slot;
  final double tile;
  final bool isRolling;
  final VoidCallback onRoll;
  final void Function(String slotId) onToggleLock;
  final void Function(String slotId) onAnimationComplete;

  const _DieCell({
    super.key,
    required this.slot,
    required this.tile,
    required this.isRolling,
    required this.onRoll,
    required this.onToggleLock,
    required this.onAnimationComplete,
  });

  @override
  Widget build(BuildContext context) {
    final dieSize = max(0.0, tile - 2 * AppSpacing.s);
    return SizedBox.square(
      dimension: tile,
      child: Center(
        child: SizedBox.square(
          dimension: dieSize,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isRolling ? null : onRoll,
            onLongPress: () => onToggleLock(slot.slotId),
            child: Stack(
              children: [
                RollView(
                  key: ValueKey('${slot.slotId}-${slot.currentFace.id}'),
                  oldFace: slot.oldFace,
                  newFace: slot.currentFace,
                  animationSpeed: slot.currentAnimationSpeed(),
                  onAnimationComplete: () => onAnimationComplete(slot.slotId),
                  size: dieSize,
                ),
                if (slot.locked)
                  Positioned.fill(child: _LockOverlay(size: dieSize)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dims a locked die and frames it in pink with a lock glyph. Ignores pointers
/// so a long-press still reaches the cell beneath to unlock it.
class _LockOverlay extends StatelessWidget {
  final double size;

  const _LockOverlay({required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          color: colors.bg.withValues(alpha: 0.55),
          border: Border.all(color: colors.pink, width: 2),
          borderRadius: AppRadii.sBR,
        ),
        child: Center(
          child: Icon(
            Icons.lock,
            color: colors.pink,
            size: max(16.0, size * 0.22),
          ),
        ),
      ),
    );
  }
}

/// Shown when the tray has been emptied from the selector.
class _EmptyTray extends StatelessWidget {
  const _EmptyTray();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.casino_outlined, size: 48, color: colors.inkMute),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Your tray is empty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          const AppSectionLabel(label: 'add dice from the selector'),
        ],
      ),
    );
  }
}
