import 'package:flutter/material.dart';
import '../screens/onboarding_screen.dart';
import '../screens/pet_selection_screen.dart';
import '../screens/main_screen.dart';
import '../screens/mini_game_screen.dart';
import '../screens/game_result_screen.dart';

class Routes {
  static const String onboarding = '/';
  static const String petSelection = '/pet-selection';
  static const String main = '/main';
  static const String miniGame = '/mini-game';
  static const String gameResult = '/game-result';

  static Map<String, WidgetBuilder> get all => {
        onboarding: (_) => const OnboardingScreen(),
        petSelection: (_) => const PetSelectionScreen(),
        main: (_) => const MainScreen(),
        miniGame: (_) => const MiniGameScreen(),
        gameResult: (ctx) => GameResultScreen(
              score: (ModalRoute.of(ctx)!.settings.arguments as int?) ?? 0,
            ),
      };
}
