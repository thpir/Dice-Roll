import 'package:dice_roll/ui/core/theme/tokens/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';

class AppImageSlot extends StatelessWidget {
  final ImageProvider? image;
  final Widget? imageChild;
  final IconData? placeholderIcon;
  final String? label;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final double? size;
  final double? width;
  final double? height;

  const AppImageSlot({
    super.key,
    this.image,
    this.imageChild,
    this.placeholderIcon,
    this.label,
    this.onTap,
    this.onClear,
    this.size,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasImage = imageChild != null || image != null;
    final showClear = hasImage && onClear != null;
    final resolvedWidth = width ?? size;
    final resolvedHeight = height ?? size;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.smBR,
      child: InkWell(
        onTap: onTap,
        onLongPress: showClear ? onClear : null,
        borderRadius: AppRadii.smBR,
        child: SizedBox(
          width: resolvedWidth,
          height: resolvedHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                ClipRRect(
                  child: imageChild ?? Image(image: image!, fit: BoxFit.cover),
                )
              else
                CustomPaint(
                  painter: _DashedBorderPainter(
                    color: colors.inkMute,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final shortest = constraints.biggest.shortestSide;
                      final side = shortest.isFinite ? shortest : 48.0;
                      return Center(
                        child: Icon(
                          placeholderIcon ?? Icons.image_outlined,
                          color: colors.inkMute,
                          size: side * 0.4,
                        ),
                      );
                    },
                  ),
                ),
              if (label != null)
                Positioned(
                  left: 4,
                  top: 4,
                  child: _SlotLabel(label: label!),
                ),
              if (showClear)
                Positioned(
                  right: 2,
                  top: 2,
                  child: _SlotClearButton(onTap: onClear!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotLabel extends StatelessWidget {
  final String label;

  const _SlotLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SlotClearButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SlotClearButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withAlpha(200),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(2),
          child: Icon(
            Icons.close,
            size: 14,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height)
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        dashPath.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color;
}
