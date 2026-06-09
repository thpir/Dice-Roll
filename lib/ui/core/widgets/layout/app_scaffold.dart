import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool safeArea;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomBar,
    this.floatingActionButton,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: appBar,
      body: safeArea ? SafeArea(child: body) : body,
      bottomNavigationBar: bottomBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
