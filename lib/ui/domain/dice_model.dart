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

  DiceModel() {
    _initDice();
  }

  void _initDice() {
    final randomDiceIndex = Random().nextInt(DiceModel.diceImages.length);
    selectedDiceFace = DiceModel.diceImages[randomDiceIndex];
    selectedDiceColor = DiceModel.diceColors[randomDiceIndex];
  }
}