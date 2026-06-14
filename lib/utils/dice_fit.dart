import 'dart:math';
import 'dart:ui';

/// Minimum edge length (logical px) a single die tile is allowed to occupy on
/// the roll screen. Used by [maxDiceFor] to derive how many dice fit.
const double kMinDiceTile = 100;

/// How many dice fit in [area] given a minimum tile size of [minTile].
///
/// The roll area is treated as a simple grid: as many whole [minTile]-wide
/// columns as fit horizontally times as many fit vertically. Always at least
/// one — a tray never has zero slots.
int maxDiceFor(Size area, {double minTile = kMinDiceTile}) {
  final cols = (area.width / minTile).floor();
  final rows = (area.height / minTile).floor();
  return max(1, cols * rows);
}

/// The largest dice count that fits in *both* orientations, so rotating the
/// device never forces the tray to shrink.
///
/// [rollArea] is the roll area as measured in the current orientation and
/// [screenSize] is the full (logical) screen. The chrome — app bar, button,
/// padding, safe-area insets — is taken to be whatever currently sits between
/// the screen and the roll area, and is assumed to keep its vertical/horizontal
/// share when the screen is rotated (the app bar stays a top band, side insets
/// stay on the sides). The result is the smaller of the current orientation's
/// capacity and the rotated orientation's predicted capacity.
///
/// Predicting the rotated orientation by simply transposing [rollArea] would be
/// wrong: the chrome doesn't rotate, so in landscape the fixed vertical chrome
/// eats a far larger share of the (now short) vertical axis. Deriving the
/// chrome from the screen and re-applying it after the swap accounts for that.
int orientationStableMaxDice(
  Size rollArea,
  Size screenSize, {
  double minTile = kMinDiceTile,
}) {
  double atLeastZero(double value) => value < 0 ? 0 : value;
  final chromeWidth = atLeastZero(screenSize.width - rollArea.width);
  final chromeHeight = atLeastZero(screenSize.height - rollArea.height);
  // Rotating swaps the screen's width and height; the chrome keeps its place.
  final rotatedArea = Size(
    atLeastZero(screenSize.height - chromeWidth),
    atLeastZero(screenSize.width - chromeHeight),
  );
  return min(
    maxDiceFor(rollArea, minTile: minTile),
    maxDiceFor(rotatedArea, minTile: minTile),
  );
}

/// The number of columns that lets [count] dice grow to the largest possible
/// square tile within [area].
///
/// For every candidate column count we compute the implied row count and the
/// largest square that fits, then keep whichever column count yields the
/// biggest tile. This is what lets a 2-dice tray spread out and fill the space
/// instead of clustering into a single small column.
int gridColumnsFor(int count, Size area) {
  if (count <= 1) {
    return 1;
  }
  var bestColumns = 1;
  var bestTile = double.negativeInfinity;
  for (var columns = 1; columns <= count; columns++) {
    final rows = (count / columns).ceil();
    final tile = min(area.width / columns, area.height / rows);
    if (tile > bestTile) {
      bestTile = tile;
      bestColumns = columns;
    }
  }
  return bestColumns;
}
