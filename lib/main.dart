import 'package:dice_roll/data/repositories/dice_repository.dart';
import 'package:dice_roll/data/repositories/selected_dice_repository.dart';
import 'package:dice_roll/data/services/hive_service.dart';
import 'package:dice_roll/data/services/image_storage_service.dart';
import 'package:dice_roll/data/services/preferences_service.dart';
import 'package:dice_roll/domain/use_cases/roll_dice.dart';
import 'package:dice_roll/ui/core/theme/app_theme.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:dice_roll/ui/screens/dice_editor_screen.dart';
import 'package:dice_roll/ui/screens/dice_list_screen.dart';
import 'package:dice_roll/ui/screens/dice_selector_screen.dart';
import 'package:dice_roll/ui/screens/roll_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();
  final preferencesService = PreferencesService();
  await preferencesService.init();
  final imageStorageService = ImageStorageService();
  // Cache the documents directory up front so stored image paths resolve
  // synchronously on hot paths (e.g. the roll animation).
  await imageStorageService.warmUp();

  final diceRepository = DiceRepository(
    hive: hiveService,
    images: imageStorageService,
  );
  final selectedDiceRepository = SelectedDiceRepository(preferencesService);

  // Management provider spins up first and loads every available dice into
  // memory.
  final diceManagementProvider = DiceManagementProvider(
    getDiceList: GetDiceListImpl(diceRepository),
    saveDice: SaveDiceImpl(diceRepository),
    deleteDice: DeleteDiceImpl(diceRepository),
  );
  await diceManagementProvider.load();

  // Game provider spins up next, resolving the previously-selected dice from
  // the loaded list and falling back to the built-in dice when needed.
  final diceGameProvider = DiceGameProvider(
    management: diceManagementProvider,
    getSelectedDiceId: GetSelectedDiceIdImpl(selectedDiceRepository),
    setSelectedDiceId: SetSelectedDiceIdImpl(selectedDiceRepository),
    rollDice: RollDice(),
  );
  await diceGameProvider.loadInitial();

  runApp(
    DiceRollApp(
      imageStorageService: imageStorageService,
      diceManagementProvider: diceManagementProvider,
      diceGameProvider: diceGameProvider,
    ),
  );
}

class DiceRollApp extends StatelessWidget {
  final ImageStorageService imageStorageService;
  final DiceManagementProvider diceManagementProvider;
  final DiceGameProvider diceGameProvider;

  const DiceRollApp({
    super.key,
    required this.imageStorageService,
    required this.diceManagementProvider,
    required this.diceGameProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ImageStorageService>.value(value: imageStorageService),
        ChangeNotifierProvider<DiceManagementProvider>.value(
          value: diceManagementProvider,
        ),
        ChangeNotifierProvider<DiceGameProvider>.value(value: diceGameProvider),
      ],
      child: MaterialApp(
        title: 'Dice Roll',
        theme: AppTheme.dark,
        initialRoute: RollScreen.routeName,
        routes: {
          RollScreen.routeName: (_) => const RollScreen(),
          DiceListScreen.routeName: (_) => const DiceListScreen(),
          DiceSelectorScreen.routeName: (_) => const DiceSelectorScreen(),
          DiceEditorScreen.routeName: (_) => const DiceEditorScreen(),
        },
      ),
    );
  }
}
