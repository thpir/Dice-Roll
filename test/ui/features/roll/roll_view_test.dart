import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/ui/core/theme/app_theme.dart';
import 'package:dice_roll/ui/core/widgets/dice_face_preview.dart';
import 'package:dice_roll/ui/features/roll/roll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the rolling-swap animation contract: both faces are shown during the
/// swap and [RollView.onAnimationComplete] fires when the controller finishes.
///
/// Uses colour-only faces (no image paths), so the preview never reaches the
/// storage service and no provider is required.
void main() {
  DiceFaceEntity colourFace(String id, int colour) =>
      DiceFaceEntity(id: id, order: 0, backgroundColor: colour);

  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(child: SizedBox.square(dimension: 300, child: child)),
        ),
      );

  testWidgets('shows both old and new faces during the swap', (tester) async {
    await tester.pumpWidget(
      wrap(RollView(
        oldFace: colourFace('old', 0xFFFF0000),
        newFace: colourFace('new', 0xFF00FF00),
        animationSpeed: 200,
        size: 300,
      )),
    );
    // Mid-animation.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(DiceFacePreview), findsNWidgets(2));
  });

  testWidgets('fires onAnimationComplete when the animation finishes',
      (tester) async {
    var completed = 0;
    await tester.pumpWidget(
      wrap(RollView(
        oldFace: colourFace('old', 0xFFFF0000),
        newFace: colourFace('new', 0xFF00FF00),
        animationSpeed: 200,
        size: 300,
        onAnimationComplete: () => completed++,
      )),
    );
    await tester.pumpAndSettle();
    expect(completed, 1);
  });
}
