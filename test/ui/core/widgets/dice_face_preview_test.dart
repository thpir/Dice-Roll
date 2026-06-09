import 'package:dice_roll/data/services/image_storage_service.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/ui/core/widgets/dice_face_preview.dart';
import 'package:dice_roll/ui/core/widgets/stored_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Pins what [DiceFacePreview] renders for each combination of background
/// colour, background image, and foreground image.
class _FakeImageStorage extends ImageStorageService {
  @override
  Future<String?> absolutePathFor(String relativePath) async =>
      relativePath.startsWith('assets/') ? null : '/docs/$relativePath';
}

void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: Provider<ImageStorageService>.value(
          value: _FakeImageStorage(),
          child: Scaffold(body: Center(child: SizedBox.square(
            dimension: 200,
            child: child,
          ))),
        ),
      );

  DiceFaceEntity face({String? bg, String? fg}) => DiceFaceEntity(
        id: 'f',
        order: 0,
        backgroundColor: 0xFF112233,
        backgroundImagePath: bg,
        imagePath: fg,
      );

  testWidgets('always paints the background colour', (tester) async {
    await tester.pumpWidget(wrap(DiceFacePreview(face: face())));
    await tester.pump();
    expect(find.byType(ColoredBox), findsWidgets);
  });

  testWidgets('renders no StoredImage when face has no image paths',
      (tester) async {
    await tester.pumpWidget(wrap(DiceFacePreview(face: face())));
    await tester.pump();
    expect(find.byType(StoredImage), findsNothing);
  });

  testWidgets('renders a background StoredImage when backgroundImagePath set',
      (tester) async {
    await tester.pumpWidget(
      wrap(DiceFacePreview(face: face(bg: 'dice_faces/bg.png'))),
    );
    await tester.pump();
    expect(find.byType(StoredImage), findsOneWidget);
  });

  testWidgets('renders a foreground StoredImage when imagePath set',
      (tester) async {
    await tester.pumpWidget(
      wrap(DiceFacePreview(face: face(fg: 'dice_faces/fg.png'))),
    );
    await tester.pump();
    expect(find.byType(StoredImage), findsOneWidget);
  });

  testWidgets('renders both images when both paths set', (tester) async {
    await tester.pumpWidget(
      wrap(DiceFacePreview(
        face: face(bg: 'dice_faces/bg.png', fg: 'dice_faces/fg.png'),
      )),
    );
    await tester.pump();
    expect(find.byType(StoredImage), findsNWidgets(2));
  });
}
