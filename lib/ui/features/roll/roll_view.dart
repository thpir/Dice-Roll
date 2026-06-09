import 'dart:math';

import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/widgets/dice_face_preview.dart';
import 'package:flutter/material.dart';

/// Renders the cross-fading swap between two dice faces. The animation slides
/// the new face in from the right while the old face shrinks out to the left.
class RollView extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final DiceFaceEntity oldFace;
  final DiceFaceEntity newFace;
  final int animationSpeed;
  final double size;

  const RollView({
    super.key,
    this.onAnimationComplete,
    required this.oldFace,
    required this.newFace,
    required this.animationSpeed,
    required this.size,
  });

  @override
  State<RollView> createState() => _RollViewState();
}

class _RollViewState extends State<RollView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.animationSpeed),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1,
      end: 0,
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
    final diceSize = widget.size * 0.8; 
    final borderSize = widget.size * 0.9;
    final borderPadding = widget.size * 0.05;
    final cornerSize = widget.size * 0.08; 
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        return Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: _Corner(
                position: _CornerPosition.topLeft,
                size: cornerSize,
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: _Corner(
                position: _CornerPosition.topRight,
                size: cornerSize,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: _Corner(
                position: _CornerPosition.bottomLeft,
                size: cornerSize,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _Corner(
                position: _CornerPosition.bottomRight,
                size: cornerSize,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: 0.2,
                child: _DiceBorderSize(
                  position: _CornerPosition.topLeft,
                  size: borderSize,
                  padding: borderPadding,
                  color: context.appColors.acid,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _DiceBorderSize(
                position: _CornerPosition.bottomRight,
                size: borderSize,
                padding: borderPadding,
                color: context.appColors.pink,
              ),
            ),
            Center(
              child: Container(
                width: diceSize,
                height: diceSize,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  borderRadius: AppRadii.sBR,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: diceSize,
                        width: diceSize * (1 - t),
                        child: DiceFacePreview(
                          face: widget.newFace,
                          foregroundConstraints: const BoxConstraints(
                            maxWidth: 300,
                            maxHeight: 300,
                          ),
                          foregroundWidth: diceSize * 0.8 * (1 - t),
                          foregroundHeight: diceSize * 0.8,
                          foregroundFit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: diceSize,
                        width: diceSize * t,
                        child: DiceFacePreview(
                          face: widget.oldFace,
                          foregroundConstraints: const BoxConstraints(
                            maxWidth: 300,
                            maxHeight: 300,
                          ),
                          foregroundWidth: diceSize * 0.8 * t,
                          foregroundHeight: diceSize * 0.8,
                          foregroundFit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class _Corner extends StatelessWidget {
  final _CornerPosition position;
  final double size;

  const _Corner({required this.position, required this.size});

  @override
  Widget build(BuildContext context) {
    double getRotationAngle(_CornerPosition position) {
      switch (position) {
        case _CornerPosition.topLeft:
          return 0;
        case _CornerPosition.topRight:
          return pi / 2;
        case _CornerPosition.bottomRight:
          return pi;
        case _CornerPosition.bottomLeft:
          return 3 * pi / 2;
      }
    }

    return Transform.rotate(
      angle: getRotationAngle(position),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          children: [
            Container(
              width: size,
              height: size * .1,
              decoration: BoxDecoration(
                color: context.appColors.acid,
              ),
            ),
            Container(
              width: size * .1,
              height: size,
              decoration: BoxDecoration(
                color: context.appColors.acid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiceBorderSize extends StatelessWidget {
  final _CornerPosition position;
  final double size;
  final double padding;
  final Color color;

  const _DiceBorderSize({required this.position, required this.size, required this.padding, required this.color});

  @override
  Widget build(BuildContext context) {
    final length = size - size * 0.02;
    final thickness = size * 0.02;
    double getRotationAngle(_CornerPosition position) {
      switch (position) {
        case _CornerPosition.topLeft:
          return 0;
        default:
          return pi;
      }
    }

    return Transform.rotate(
      angle: getRotationAngle(position),
      child: Padding(
        padding: EdgeInsets.only(left: padding, top: padding),
        child: Stack(
          children: [
            Container(
              width: length,
              height: thickness,
              decoration: BoxDecoration(
                color: color,
              ),
            ),
            Container(
              width: thickness,
              height: length,
              decoration: BoxDecoration(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
