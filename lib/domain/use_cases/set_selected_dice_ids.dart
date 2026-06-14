/// Persists the ordered list of dice ids that make up the user's tray.
///
/// Quantities are encoded by repetition and order is preserved
/// (e.g. `[A, A, B]` means 2×A then 1×B).
abstract class SetSelectedDiceIds {
  Future<void> call(List<String> ids);
}
