/// Persists the id of the dice the user has just selected.
abstract class SetSelectedDiceId {
  Future<void> call(String id);
}
