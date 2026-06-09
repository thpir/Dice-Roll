import 'package:dice_roll/ui/features/dice_editor/widgets/dice_editor_view.dart';
import 'package:flutter/material.dart';

class DiceEditorScreen extends StatelessWidget {
  static const routeName = '/settings/dice/edit';

  const DiceEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final diceId = args is DiceEditorArguments ? args.diceId : null;
    return DiceEditorView(diceId: diceId);
  }
}

class DiceEditorArguments {
  /// `null` means "create a new dice".
  final String? diceId;

  const DiceEditorArguments({this.diceId});
}
