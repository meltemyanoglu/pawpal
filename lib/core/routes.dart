import 'package:flutter/material.dart';
import '../screens/onboarding_screen.dart';
import '../screens/pet_selection_screen.dart';
import '../screens/main_screen.dart';
// import '../screens/mini_game_screen.dart';   // geçici olarak devre dışı
// import '../screens/game_result_screen.dart'; // geçici olarak devre dışı
import '../screens/achievements_screen.dart';
import '../screens/accessory_shop_screen.dart';
import 'page_transitions.dart';

class Routes {
  static const String onboarding = '/';
  static const String petSelection = '/pet-selection';
  static const String main = '/main';
  // static const String miniGame = '/mini-game';
  // static const String gameResult = '/game-result';
  // geçici olarak devre dışı — mini oyunlar ileride geri gelecek
  static const String miniGame = '/mini-game';
  static const String gameResult = '/game-result';
  static const String achievements = '/achievements';
  static const String shop = '/shop';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return PawPalPageRoute(page: const OnboardingScreen());
      case petSelection:
        return PawPalPageRoute(page: const PetSelectionScreen());
      case main:
        return PawPalPageRoute(page: const MainScreen());
      case achievements:
        return PawPalPageRoute(page: const AchievementsScreen());
      case shop:
        return PawPalPageRoute(page: const AccessoryShopScreen());
      default:
        return PawPalPageRoute(page: const OnboardingScreen());
    }
  }
}
