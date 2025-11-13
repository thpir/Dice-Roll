import 'package:dice_roll/ui/dice/widgets/dice_view.dart';
import 'package:dice_roll/ui/provider/dice_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider<DiceGameProvider>(
        create: (_) => DiceGameProvider(),
        child: Scaffold(
          body: Consumer<DiceGameProvider>(
            builder: (context, diceGameProvider, child) {
              return InkWell(
                onTap: () {
                  if (!diceGameProvider.isRolling) {
                    diceGameProvider.startRolling();
                  }
                },
                child: DiceView(
                  key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                  onAnimationComplete: () {
                    diceGameProvider.displayProviderState();
                    diceGameProvider.rollsDone++;
                    if (diceGameProvider.rollsDone < diceGameProvider.totalRolls) {
                      diceGameProvider.updateDice();
                    } else {
                      diceGameProvider.stopRolling();
                    }
                  },
                  oldDice: diceGameProvider.oldDice,
                  newDice: diceGameProvider.currentDice,
                  animationSpeed: (diceGameProvider.rollsDone + 1) * 50,
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
