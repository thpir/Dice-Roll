/// Domain constants and shared validation helpers for dice.
class DiceValidation {
  DiceValidation._();

  static const minFaces = 2;

  /// The d120 (disdyakis triacontahedron) is the largest mathematically fair
  /// die. 200 leaves headroom above the real-world record.
  static const maxFaces = 200;
}

/// Thrown by [SaveDice] when a dice fails validation. UI layers should catch
/// these and surface the [message] to the user.
class DiceValidationException implements Exception {
  final String message;
  const DiceValidationException(this.message);

  @override
  String toString() => 'DiceValidationException: $message';
}
