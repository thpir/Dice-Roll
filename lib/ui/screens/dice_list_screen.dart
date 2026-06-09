import 'package:dice_roll/ui/core/widgets/layout/app_app_bar.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_scaffold.dart';
import 'package:dice_roll/ui/features/dice_list/dice_list_view.dart';
import 'package:flutter/material.dart';

class DiceListScreen extends StatelessWidget {
  static const routeName = '/settings/dice';

  const DiceListScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppScaffold(
    appBar: AppAppBar(
        title: 'Manage dices',
      ),
    body: DiceListView());
}
