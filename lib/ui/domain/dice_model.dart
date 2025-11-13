import 'dart:math';

import 'package:flutter/material.dart';

class DiceModel {
  static List<String> diceImages = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
    'assets/images/4.png',
    'assets/images/5.png',
    'assets/images/6.png',
  ];
  static List<MaterialColor> diceColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  late String selectedDiceFace;
  late MaterialColor selectedDiceColor;
  String? impossibleDiceFace;

  DiceModel({this.impossibleDiceFace}) {
    _initDice();
  }

  void _initDice() {
    /// First, create mutable copies of the static lists
    final availableDiceImages = List<String>.from(diceImages);
    final availableDiceColors = List<MaterialColor>.from(diceColors);

    // Remove the impossible dice face if specified, ensuring no repetition
    if (impossibleDiceFace != null) {
      final unavailableIndex = impossibleDiceFace != null
        ? diceImages.indexOf(impossibleDiceFace!)
        : -1;
      availableDiceImages.removeAt(unavailableIndex);
      availableDiceColors.removeAt(unavailableIndex);
    }

    /// Then, randomly select a dice face and color from the available options
    final randomDiceIndex = Random().nextInt(availableDiceImages.length);
    selectedDiceFace = availableDiceImages[randomDiceIndex];
    selectedDiceColor = availableDiceColors[randomDiceIndex];
  }
}
