import 'package:dice_roll/ui/domain/dice_model.dart';
import 'package:flutter/material.dart';

class DiceView extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final DiceModel oldDice;
  final DiceModel newDice;
  final int animationSpeed;
  const DiceView({
    super.key,
    this.onAnimationComplete,
    required this.oldDice,
    required this.newDice,
    required this.animationSpeed,
  });

  @override
  State<DiceView> createState() => _DiceViewState();
}

class _DiceViewState extends State<DiceView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.animationSpeed),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final orientation = MediaQuery.orientationOf(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                color: widget.newDice.selectedDiceColor,
                height: double.infinity,
                width: screenWidth * (1 - _animation.value),
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
                  child: Image.asset(
                    widget.newDice.selectedDiceFace,
                    width: orientation == Orientation.portrait
                        ? screenWidth * 0.8 * (1 - _animation.value)
                        : screenHeight * 0.8 * (1 - _animation.value),
                    height: orientation == Orientation.portrait
                        ? screenWidth * 0.8
                        : screenHeight * 0.8,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                color: widget.oldDice.selectedDiceColor,
                height: double.infinity,
                width: screenWidth * _animation.value,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
                  child: Image.asset(
                    widget.oldDice.selectedDiceFace,
                    width: orientation == Orientation.portrait
                        ? screenWidth * 0.8 * _animation.value
                        : screenHeight * 0.8 * _animation.value,
                    height: orientation == Orientation.portrait
                        ? screenWidth * 0.8
                        : screenHeight * 0.8,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
