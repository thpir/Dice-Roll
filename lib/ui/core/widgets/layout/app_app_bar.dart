import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_icon_button.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final List<Widget> actions;

  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final resolvedTitle = titleWidget ??
        (title != null
            ? Text(
                title!,
                style: AppTypography.titleL.copyWith(color: colors.ink),
              )
            : null);

    return AppBar(
      backgroundColor: colors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: showBackButton && Navigator.canPop(context)
          ? AppIconButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: resolvedTitle,
      actions: actions,
    );
  }
}
