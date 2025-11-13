import 'dart:math';

import 'package:dice_roll/ui/domain/dice_model.dart';
import 'package:flutter/material.dart';

class DiceGameProvider extends ChangeNotifier {
  DiceModel currentDice = DiceModel();
  DiceModel oldDice = DiceModel();
  bool isRolling = false;
  int totalRolls = 0;
  int rollsDone = 0;

  void startRolling() {
    isRolling = true;
    /// Random face updates between 8 and 12
    totalRolls = Random().nextInt(5) + 8;
    updateDice();
  }

  void stopRolling() {
    isRolling = false;
    rollsDone = 0;
  }

  void updateDice() {
    oldDice = currentDice;
    currentDice = DiceModel(impossibleDiceFace: oldDice.selectedDiceFace);
    notifyListeners();
  }

  void displayProviderState() {
    debugPrint('isRolling: $isRolling, rollsDone: $rollsDone, totalRolls: $totalRolls');
  }
}