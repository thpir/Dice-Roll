import 'package:dice_roll/ui/core/widgets/layout/app_app_bar.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_scaffold.dart';
import 'package:dice_roll/ui/features/dice_selector/dice_selector_view.dart';
import 'package:flutter/material.dart';

class DiceSelectorScreen extends StatelessWidget {
  static const routeName = '/dice_selector';

  const DiceSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppScaffold(
    appBar: AppAppBar(title: 'Choose a dice'),
    body: DiceSelectorView());
}

