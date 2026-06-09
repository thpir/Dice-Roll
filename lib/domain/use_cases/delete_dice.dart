/// Deletes a custom dice and any face images it owned. The built-in dice
/// cannot be deleted.
abstract class DeleteDice {
  Future<void> call(String id);
}
