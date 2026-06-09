/// Returns the id of the dice the user last selected, or `null` if no
/// selection has been made yet.
abstract class GetSelectedDiceId {
  Future<String?> call();
}
