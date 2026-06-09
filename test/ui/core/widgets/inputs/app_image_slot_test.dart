import 'package:dice_roll/ui/core/theme/app_theme.dart';
import 'package:dice_roll/ui/core/widgets/inputs/app_image_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// These tests pin the behavioural contract that the legacy
/// `_FaceImageSlotWidget` in `dice_editor_view.dart` provides today, so the
/// refactor onto `AppImageSlot` can be validated against it.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: Center(child: child)),
      );

  group('AppImageSlot — placeholder mode', () {
    testWidgets('renders default placeholder icon when empty',
        (tester) async {
      await tester.pumpWidget(wrap(AppImageSlot(size: 48, onTap: () {})));
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('uses custom placeholderIcon when provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          AppImageSlot(
            size: 48,
            placeholderIcon: Icons.wallpaper_outlined,
            onTap: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.wallpaper_outlined), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsNothing);
    });

    testWidgets('does not show clear button when empty even if onClear is set',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          AppImageSlot(
            size: 48,
            onTap: () {},
            onClear: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('AppImageSlot — label chip', () {
    testWidgets('renders the label string in a corner chip', (tester) async {
      await tester.pumpWidget(
        wrap(AppImageSlot(size: 48, label: 'BG', onTap: () {})),
      );
      expect(find.text('BG'), findsOneWidget);
    });

    testWidgets('renders label over the image when an imageChild is provided',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          AppImageSlot(
            size: 48,
            label: 'FG',
            imageChild: const ColoredBox(color: Colors.red),
            onTap: () {},
          ),
        ),
      );
      expect(find.text('FG'), findsOneWidget);
      expect(find.byType(ColoredBox), findsWidgets);
    });
  });

  group('AppImageSlot — image content', () {
    testWidgets('imageChild replaces the placeholder', (tester) async {
      await tester.pumpWidget(
        wrap(
          AppImageSlot(
            size: 48,
            imageChild: const ColoredBox(color: Colors.green),
            onTap: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.image_outlined), findsNothing);
      expect(find.byType(ColoredBox), findsWidgets);
    });

    testWidgets('clear button is shown when imageChild and onClear are set',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          AppImageSlot(
            size: 48,
            imageChild: const ColoredBox(color: Colors.green),
            onTap: () {},
            onClear: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('clear button is hidden when onClear is null', (tester) async {
      await tester.pumpWidget(
        wrap(
          AppImageSlot(
            size: 48,
            imageChild: const ColoredBox(color: Colors.green),
            onTap: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('AppImageSlot — callbacks', () {
    testWidgets('onTap fires when the slot is tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(AppImageSlot(size: 48, onTap: () => taps++)),
      );
      await tester.tap(find.byType(AppImageSlot));
      expect(taps, 1);
    });

    testWidgets('clear button tap fires onClear and not onTap', (tester) async {
      var taps = 0;
      var clears = 0;
      await tester.pumpWidget(
        wrap(
          AppImageSlot(
            size: 48,
            imageChild: const ColoredBox(color: Colors.green),
            onTap: () => taps++,
            onClear: () => clears++,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(clears, 1);
      expect(taps, 0);
    });

    testWidgets('long-press fires onClear when an image is shown',
        (tester) async {
      var clears = 0;
      await tester.pumpWidget(
        wrap(
          AppImageSlot(
            size: 48,
            imageChild: const ColoredBox(color: Colors.green),
            onTap: () {},
            onClear: () => clears++,
          ),
        ),
      );
      await tester.longPress(find.byType(AppImageSlot));
      expect(clears, 1);
    });

    testWidgets('long-press does not fire onClear when empty', (tester) async {
      var clears = 0;
      await tester.pumpWidget(
        wrap(
          AppImageSlot(
            size: 48,
            onTap: () {},
            onClear: () => clears++,
          ),
        ),
      );
      await tester.longPress(find.byType(AppImageSlot));
      expect(clears, 0);
    });
  });

  group('AppImageSlot — sizing', () {
    testWidgets('honours explicit width and height (flex mode)',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 200,
            child: Row(
              children: [
                Expanded(
                  child: AppImageSlot(
                    height: 56,
                    label: 'BG',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final size = tester.getSize(find.byType(AppImageSlot));
      expect(size.height, 56);
      expect(size.width, 200);
    });

    testWidgets('falls back to square size when set', (tester) async {
      await tester.pumpWidget(
        wrap(AppImageSlot(size: 72, onTap: () {})),
      );
      final size = tester.getSize(find.byType(AppImageSlot));
      expect(size.width, 72);
      expect(size.height, 72);
    });
  });
}
