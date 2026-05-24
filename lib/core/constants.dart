class Constants {
  // Stat changes per action
  static const double feedHunger = 25.0;
  static const double feedHappiness = 5.0;

  static const double washCleanliness = 30.0;
  static const double washHappiness = 5.0;
  static const double washEnergyDrain = 5.0;

  static const double playHappiness = 20.0;
  static const double playEnergyDrain = 15.0;
  static const double playHungerDrain = 10.0;
  static const double playMinEnergy = 15.0;

  // Decay per 30-second tick (real-time)
  static const double tickHungerDecay = 1.5;
  static const double tickHappinessDecay = 1.0;
  static const double tickCleanlinessDecay = 1.2;
  static const double tickEnergyDecay = 0.8;

  // Sleep tick
  static const double sleepEnergyGain = 5.0;
  static const double sleepHungerDecay = 0.5;

  // Offline decay cap (minutes)
  static const double maxOfflineMinutes = 60.0;

  // Mini-game happiness per caught item
  static const double gameHappinessPerCatch = 0.8;

  // XP rewards
  static const int xpPerFeed = 8;
  static const int xpPerWash = 8;
  static const int xpPerPlay = 12;
  static const int xpPerMission = 30;

  // Accessory prices
  static const Map<String, int> accessoryPrices = {
    'tophat': 50,
    'bowtie': 35,
    'sunglasses': 40,
    'crown': 100,
    'scarf': 45,
    'flower': 25,
    'headband': 30,
    'wizard_hat': 80,
  };

  static const Map<String, String> accessoryNames = {
    'tophat': 'Top Hat 🎩',
    'bowtie': 'Bow Tie 🎀',
    'sunglasses': 'Sunglasses 🕶️',
    'crown': 'Crown 👑',
    'scarf': 'Scarf 🧣',
    'flower': 'Flower 🌸',
    'headband': 'Headband 💫',
    'wizard_hat': 'Wizard Hat 🧙',
  };

  static const Map<String, String> accessoryEmojis = {
    'tophat': '🎩',
    'bowtie': '🎀',
    'sunglasses': '🕶️',
    'crown': '👑',
    'scarf': '🧣',
    'flower': '🌸',
    'headband': '💫',
    'wizard_hat': '🧙',
  };
}
