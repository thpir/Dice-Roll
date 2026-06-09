import 'package:dice_roll/data/services/image_storage_service.dart';
import 'package:dice_roll/ui/core/widgets/stored_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Pins the behavioural contract of [StoredImage] so the move to synchronous
/// path resolution and precaching can be validated against it.
///
/// The fake overrides only the async [ImageStorageService.absolutePathFor].
/// After the refactor, `StoredImage` first tries the synchronous resolver,
/// which returns `null` in tests (the docs dir is never warmed), so it falls
/// back to the async path these tests stub — keeping them valid throughout.
class _FakeImageStorage extends ImageStorageService {
  final String? Function(String) resolve;
  _FakeImageStorage(this.resolve);

  @override
  Future<String?> absolutePathFor(String relativePath) async =>
      resolve(relativePath);
}

void main() {
  Widget wrap(Widget child, {ImageStorageService? images}) {
    return MaterialApp(
      home: Provider<ImageStorageService>.value(
        value: images ?? _FakeImageStorage((p) => '/abs/$p'),
        child: Scaffold(body: child),
      ),
    );
  }

  ImageProvider providerOf(WidgetTester tester) =>
      tester.widget<Image>(find.byType(Image)).image;

  group('StoredImage — asset paths', () {
    testWidgets('renders an AssetImage for assets/ paths without touching '
        'the storage service', (tester) async {
      await tester.pumpWidget(
        // No provider needed for asset paths.
        const MaterialApp(
          home: Scaffold(body: StoredImage(path: 'assets/images/1.png')),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(providerOf(tester), isA<AssetImage>());
    });
  });

  group('StoredImage — relative file paths', () {
    testWidgets('resolves the path and renders a FileImage', (tester) async {
      await tester.pumpWidget(
        wrap(
          const StoredImage(path: 'dice_faces/abc.png'),
          images: _FakeImageStorage((p) => '/docs/$p'),
        ),
      );
      // Resolution is async; let the FutureBuilder settle.
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      final provider = providerOf(tester);
      expect(provider, isA<FileImage>());
      expect((provider as FileImage).file.path, '/docs/dice_faces/abc.png');
    });

    testWidgets('shows the placeholder while/if the path does not resolve',
        (tester) async {
      const placeholder = Text('loading');
      await tester.pumpWidget(
        wrap(
          const StoredImage(
            path: 'dice_faces/abc.png',
            placeholder: placeholder,
          ),
          images: _FakeImageStorage((_) => null),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('loading'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
