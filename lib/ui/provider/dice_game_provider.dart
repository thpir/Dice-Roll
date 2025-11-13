import 'dart:math';

import 'package:dice_roll/ui/domain/dice_model.dart';
import 'package:flutter/material.dart';

class DiceGameProvider extends ChangeNotifier {
  DiceModel currentDice = DiceModel();
  DiceModel oldDice = DiceModel();
  bool isRolling = false;
  int totalRolls = 8;
  int rollsDone = 0;

  void startRolling() {
    isRolling = true;
    totalRolls = Random().nextInt(5) + 8; // Random face updates between 8 and 12
    updateDice();
  }

  void stopRolling() {
    isRolling = false;
    rollsDone = 0;
  }

  void updateDice() {
    oldDice = currentDice;
    currentDice = DiceModel();
    notifyListeners();
  }

  void displayProviderState() {
    debugPrint('isRolling: $isRolling, rollsDone: $rollsDone, totalRolls: $totalRolls');
  }
}