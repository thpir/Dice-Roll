import 'dart:math';

import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/widgets/dice_face_precache.dart';
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

    // Build each face preview once at full dice size. Keeping these widget
    // instances stable across animation frames lets Flutter reuse their
    // elements (and image cache entries) instead of re-resolving/re-decoding
    // the image every frame — the animation below only scales them.
    final newPreview = _facePreview(widget.newFace, diceSize);
    final oldPreview = _facePreview(widget.oldFace, diceSize);

    // The corners and border chrome don't depend on the animation, so they go
    // into AnimatedBuilder's `child` and are built once rather than per frame.
    final chrome = _Chrome(
      cornerSize: cornerSize,
      borderSize: borderSize,
      borderPadding: borderPadding,
    );

    return AnimatedBuilder(
      animation: _animation,
      child: chrome,
      builder: (context, child) {
        final t = _animation.value;
        return Stack(
          children: [
            child!,
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
                    // New face grows in from the right as t: 1 -> 0.
                    Transform.scale(
                      scaleX: 1 - t,
                      scaleY: 1,
                      alignment: Alignment.centerRight,
                      child: newPreview,
                    ),
                    // Old face shrinks out to the left as t: 1 -> 0.
                    Transform.scale(
                      scaleX: t,
                      scaleY: 1,
                      alignment: Alignment.centerLeft,
                      child: oldPreview,
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

  /// A full-size face preview. The foreground is sized to 80% of the dice and
  /// stretched (`BoxFit.fill`); the horizontal squash during a roll comes from
  /// the [Transform.scale] in [build], not from resizing this widget.
  Widget _facePreview(DiceFaceEntity face, double diceSize) {
    return SizedBox(
      width: diceSize,
      height: diceSize,
      child: DiceFacePreview(
        face: face,
        foregroundConstraints: const BoxConstraints(
          maxWidth: 300,
          maxHeight: 300,
        ),
        foregroundWidth: diceSize * 0.8,
        foregroundHeight: diceSize * 0.8,
        foregroundFit: BoxFit.fill,
        foregroundCacheWidth: kDiceFaceDecodeWidth,
        backgroundCacheWidth: kDiceFaceDecodeWidth,
      ),
    );
  }
}

/// Static corner ticks and border accents around the dice. Animation-free, so
/// it can be built once and reused across frames via AnimatedBuilder's child.
class _Chrome extends StatelessWidget {
  final double cornerSize;
  final double borderSize;
  final double borderPadding;

  const _Chrome({
    required this.cornerSize,
    required this.borderSize,
    required this.borderPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: _Corner(position: _CornerPosition.topLeft, size: cornerSize),
        ),
        Align(
          alignment: Alignment.topRight,
          child: _Corner(position: _CornerPosition.topRight, size: cornerSize),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child:
              _Corner(position: _CornerPosition.bottomLeft, size: cornerSize),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child:
              _Corner(position: _CornerPosition.bottomRight, size: cornerSize),
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
      ],
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
