enum PetType { cat, dog, rabbit }

enum PetMood { ecstatic, happy, neutral, sad, exhausted, sleeping }

class Pet {
  final PetType type;
  double hunger;      // 0–100  (100 = completely full)
  double happiness;   // 0–100
  double cleanliness; // 0–100
  double energy;      // 0–100
  bool isSleeping;
  DateTime? lastSaved;

  // ── XP & Level system ────────────────────────────────────────────────────
  int xp;
  int level;
  int coins;

  // ── Streak system ────────────────────────────────────────────────────────
  int streak;
  DateTime? lastLoginDate;

  // ── Stats tracking (for achievements & missions) ─────────────────────────
  int totalFeeds;
  int totalWashes;
  int totalPlays;
  int totalGamesPlayed;
  int bestGameScore;

  // ── Achievements ─────────────────────────────────────────────────────────
  List<String> unlockedAchievements;

  // ── Accessories ──────────────────────────────────────────────────────────
  List<String> ownedAccessories;
  String? equippedAccessory;

  // ── Daily missions ───────────────────────────────────────────────────────
  String? lastMissionDate;
  List<int> missionProgress; // progress for each of 3 daily missions

  Pet({
    required this.type,
    this.hunger = 80,
    this.happiness = 80,
    this.cleanliness = 80,
    this.energy = 80,
    this.isSleeping = false,
    this.lastSaved,
    this.xp = 0,
    this.level = 1,
    this.coins = 0,
    this.streak = 0,
    this.lastLoginDate,
    this.totalFeeds = 0,
    this.totalWashes = 0,
    this.totalPlays = 0,
    this.totalGamesPlayed = 0,
    this.bestGameScore = 0,
    List<String>? unlockedAchievements,
    List<String>? ownedAccessories,
    this.equippedAccessory,
    this.lastMissionDate,
    List<int>? missionProgress,
  })  : unlockedAchievements = unlockedAchievements ?? [],
        ownedAccessories = ownedAccessories ?? [],
        missionProgress = missionProgress ?? [0, 0, 0];

  // ── Identity ──────────────────────────────────────────────────────────────

  String get name => _names[type]!;
  String get emoji => _emojis[type]!;
  String get personality => _personalities[type]!;
  String get description => _descriptions[type]!;

  // ── XP & Level helpers ────────────────────────────────────────────────────

  int get xpForNextLevel => level * 100; // 100, 200, 300...
  double get xpProgress => xp / xpForNextLevel;
  String get levelTitle {
    if (level >= 20) return 'Legendary';
    if (level >= 15) return 'Master';
    if (level >= 10) return 'Expert';
    if (level >= 7) return 'Skilled';
    if (level >= 4) return 'Growing';
    return 'Newbie';
  }

  // ── Derived state ─────────────────────────────────────────────────────────

  PetMood get mood {
    if (isSleeping) return PetMood.sleeping;
    final avg = overallHealth;
    if (avg >= 85) return PetMood.ecstatic;
    if (avg >= 65) return PetMood.happy;
    if (avg >= 45) return PetMood.neutral;
    if (avg >= 25) return PetMood.sad;
    return PetMood.exhausted;
  }

  double get overallHealth =>
      (hunger + happiness + cleanliness + energy) / 4.0;

  String get moodEmoji {
    switch (mood) {
      case PetMood.ecstatic:
        return '🥰';
      case PetMood.happy:
        return '😊';
      case PetMood.neutral:
        return '😐';
      case PetMood.sad:
        return '😢';
      case PetMood.exhausted:
        return '😵';
      case PetMood.sleeping:
        return '😴';
    }
  }

  String get moodText {
    switch (mood) {
      case PetMood.ecstatic:
        return 'Over the moon!';
      case PetMood.happy:
        return 'Feeling great!';
      case PetMood.neutral:
        return 'Just okay…';
      case PetMood.sad:
        return 'Needs some love';
      case PetMood.exhausted:
        return 'Please help me!';
      case PetMood.sleeping:
        return 'Zzz…';
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void clamp() {
    hunger = hunger.clamp(0, 100);
    happiness = happiness.clamp(0, 100);
    cleanliness = cleanliness.clamp(0, 100);
    energy = energy.clamp(0, 100);
  }

  Pet copyWith({
    PetType? type,
    double? hunger,
    double? happiness,
    double? cleanliness,
    double? energy,
    bool? isSleeping,
    DateTime? lastSaved,
    int? xp,
    int? level,
    int? coins,
    int? streak,
    DateTime? lastLoginDate,
    int? totalFeeds,
    int? totalWashes,
    int? totalPlays,
    int? totalGamesPlayed,
    int? bestGameScore,
    List<String>? unlockedAchievements,
    List<String>? ownedAccessories,
    String? equippedAccessory,
    String? lastMissionDate,
    List<int>? missionProgress,
  }) =>
      Pet(
        type: type ?? this.type,
        hunger: hunger ?? this.hunger,
        happiness: happiness ?? this.happiness,
        cleanliness: cleanliness ?? this.cleanliness,
        energy: energy ?? this.energy,
        isSleeping: isSleeping ?? this.isSleeping,
        lastSaved: lastSaved ?? this.lastSaved,
        xp: xp ?? this.xp,
        level: level ?? this.level,
        coins: coins ?? this.coins,
        streak: streak ?? this.streak,
        lastLoginDate: lastLoginDate ?? this.lastLoginDate,
        totalFeeds: totalFeeds ?? this.totalFeeds,
        totalWashes: totalWashes ?? this.totalWashes,
        totalPlays: totalPlays ?? this.totalPlays,
        totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
        bestGameScore: bestGameScore ?? this.bestGameScore,
        unlockedAchievements: unlockedAchievements ?? List.from(this.unlockedAchievements),
        ownedAccessories: ownedAccessories ?? List.from(this.ownedAccessories),
        equippedAccessory: equippedAccessory ?? this.equippedAccessory,
        lastMissionDate: lastMissionDate ?? this.lastMissionDate,
        missionProgress: missionProgress ?? List.from(this.missionProgress),
      );

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'hunger': hunger,
        'happiness': happiness,
        'cleanliness': cleanliness,
        'energy': energy,
        'isSleeping': isSleeping,
        'lastSaved': DateTime.now().toIso8601String(),
        'xp': xp,
        'level': level,
        'coins': coins,
        'streak': streak,
        'lastLoginDate': lastLoginDate?.toIso8601String(),
        'totalFeeds': totalFeeds,
        'totalWashes': totalWashes,
        'totalPlays': totalPlays,
        'totalGamesPlayed': totalGamesPlayed,
        'bestGameScore': bestGameScore,
        'unlockedAchievements': unlockedAchievements,
        'ownedAccessories': ownedAccessories,
        'equippedAccessory': equippedAccessory,
        'lastMissionDate': lastMissionDate,
        'missionProgress': missionProgress,
      };

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        type: PetType.values[json['type'] as int],
        hunger: (json['hunger'] as num).toDouble(),
        happiness: (json['happiness'] as num).toDouble(),
        cleanliness: (json['cleanliness'] as num).toDouble(),
        energy: (json['energy'] as num).toDouble(),
        isSleeping: json['isSleeping'] as bool? ?? false,
        lastSaved: json['lastSaved'] != null
            ? DateTime.tryParse(json['lastSaved'] as String)
            : null,
        xp: json['xp'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        coins: json['coins'] as int? ?? 0,
        streak: json['streak'] as int? ?? 0,
        lastLoginDate: json['lastLoginDate'] != null
            ? DateTime.tryParse(json['lastLoginDate'] as String)
            : null,
        totalFeeds: json['totalFeeds'] as int? ?? 0,
        totalWashes: json['totalWashes'] as int? ?? 0,
        totalPlays: json['totalPlays'] as int? ?? 0,
        totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
        bestGameScore: json['bestGameScore'] as int? ?? 0,
        unlockedAchievements: (json['unlockedAchievements'] as List<dynamic>?)
                ?.cast<String>() ??
            [],
        ownedAccessories:
            (json['ownedAccessories'] as List<dynamic>?)?.cast<String>() ?? [],
        equippedAccessory: json['equippedAccessory'] as String?,
        lastMissionDate: json['lastMissionDate'] as String?,
        missionProgress:
            (json['missionProgress'] as List<dynamic>?)?.cast<int>() ??
                [0, 0, 0],
      );

  // ── Static data ───────────────────────────────────────────────────────────

  static const _names = {
    PetType.cat: 'Mochi',
    PetType.dog: 'Boba',
    PetType.rabbit: 'Lumi',
  };

  static const _emojis = {
    PetType.cat: '🐱',
    PetType.dog: '🐶',
    PetType.rabbit: '🐰',
  };

  static const _personalities = {
    PetType.cat: 'Mysterious & Elegant',
    PetType.dog: 'Energetic & Loyal',
    PetType.rabbit: 'Shy & Curious',
  };

  static const _descriptions = {
    PetType.cat: 'Loves peaceful naps\nand knocking things off shelves.',
    PetType.dog: 'Always ready to play!\nYour most loyal companion.',
    PetType.rabbit: 'Hops into adventure\nwith wide, curious eyes.',
  };

  static const _thoughts = {
    PetMood.ecstatic: [
      'I am SO happy right now!',
      'Best day ever!!!',
      'Life is purrfect! ✨',
      'I love you so much!',
    ],
    PetMood.happy: [
      'Feeling great today!',
      'This is nice 😊',
      'You take such good care of me!',
      'Can we play soon?',
    ],
    PetMood.neutral: [
      'Could be better...',
      'Hmm, I\'m okay I guess.',
      'Maybe a snack would help?',
      'What should we do?',
    ],
    PetMood.sad: [
      'I need some attention...',
      'Please play with me 😢',
      'A little love goes a long way.',
      'I\'m not feeling so good.',
    ],
    PetMood.exhausted: [
      'Please help me! 😵',
      'I\'m so hungry...',
      'I really need some rest.',
      'Feed me, please!',
    ],
    PetMood.sleeping: [
      'Zzz... zzz...',
      'Dreaming of fish... 🐟',
      'Do not disturb! 😴',
      'Purr... purr...',
    ],
  };

  List<String> get thoughtMessages => _thoughts[mood]!;
}
