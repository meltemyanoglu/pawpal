import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

// ── Event bus for UI reactions ──────────────────────────────────────────────
enum PetEvent { levelUp, achievementUnlocked, streakReward, missionComplete }

class PetEventData {
  final PetEvent type;
  final String? payload;
  PetEventData(this.type, {this.payload});
}

class PetNotifier extends StateNotifier<Pet?> {
  Timer? _decayTimer;

  // Stream for UI events (level-up, achievements, etc.)
  final _eventController = StreamController<PetEventData>.broadcast();
  Stream<PetEventData> get events => _eventController.stream;

  PetNotifier() : super(null) {
    _tryRestorePet();
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  void _tryRestorePet() {
    var saved = StorageService.loadPet();
    if (saved == null) return;

    // Migrate any legacy dog/rabbit save → cat (only cat is active now)
    if (saved.type != PetType.cat) {
      saved = Pet(type: PetType.cat);
      StorageService.savePet(saved);
    }

    // Apply offline time decay (capped to avoid punishing long absences)
    if (saved.lastSaved != null) {
      final elapsed = DateTime.now().difference(saved.lastSaved!);
      final minutes =
          elapsed.inMinutes.clamp(0, Constants.maxOfflineMinutes).toDouble();

      if (saved.isSleeping) {
        saved.energy = (saved.energy + minutes * 0.8).clamp(0, 100);
        saved.hunger = (saved.hunger - minutes * 0.3).clamp(0, 100);
        saved.isSleeping = false;
      } else {
        saved.hunger = (saved.hunger - minutes * 0.5).clamp(0, 100);
        saved.happiness = (saved.happiness - minutes * 0.3).clamp(0, 100);
        saved.cleanliness = (saved.cleanliness - minutes * 0.4).clamp(0, 100);
        saved.energy = (saved.energy - minutes * 0.2).clamp(0, 100);
      }
    }

    // Check daily streak
    _checkStreak(saved);

    state = saved;
    _startDecay();
  }

  // ── Streak ───────────────────────────────────────────────────────────────

  void _checkStreak(Pet pet) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (pet.lastLoginDate != null) {
      final lastLogin = DateTime(
        pet.lastLoginDate!.year,
        pet.lastLoginDate!.month,
        pet.lastLoginDate!.day,
      );
      final diff = today.difference(lastLogin).inDays;
      if (diff == 1) {
        // Consecutive day — increase streak
        pet.streak++;
        pet.coins += 5 + (pet.streak * 2); // streak bonus coins
        _eventController.add(PetEventData(PetEvent.streakReward,
            payload: '${pet.streak}'));
      } else if (diff > 1) {
        // Streak broken
        pet.streak = 1;
      }
      // diff == 0 means same day, do nothing
    } else {
      pet.streak = 1;
    }
    pet.lastLoginDate = now;
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  void selectPet(PetType type) {
    state = Pet(type: type);
    StorageService.savePet(state!);
    _startDecay();
  }

  // ── Periodic decay ────────────────────────────────────────────────────────

  void _startDecay() {
    _decayTimer?.cancel();
    _decayTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _tick());
  }

  void _tick() {
    if (state == null) return;
    final p = state!;

    if (p.isSleeping) {
      _update(
        energy: (p.energy + Constants.sleepEnergyGain).clamp(0, 100),
        hunger: (p.hunger - Constants.sleepHungerDecay).clamp(0, 100),
        isSleeping: p.energy >= 95 ? false : null, // auto-wake when full
      );
    } else {
      _update(
        hunger: (p.hunger - Constants.tickHungerDecay).clamp(0, 100),
        happiness: (p.happiness - Constants.tickHappinessDecay).clamp(0, 100),
        cleanliness:
            (p.cleanliness - Constants.tickCleanlinessDecay).clamp(0, 100),
        energy: (p.energy - Constants.tickEnergyDecay).clamp(0, 100),
      );
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void feed() {
    if (state == null || state!.isSleeping) return;
    final p = state!;
    _update(
      hunger: (p.hunger + Constants.feedHunger).clamp(0, 100),
      happiness: (p.happiness + Constants.feedHappiness).clamp(0, 100),
      totalFeeds: p.totalFeeds + 1,
    );
    _addXP(Constants.xpPerFeed);
    _advanceMission(0); // mission slot 0 = feed missions
    _checkAchievements();
  }

  void wash() {
    if (state == null || state!.isSleeping) return;
    final p = state!;
    _update(
      cleanliness: (p.cleanliness + Constants.washCleanliness).clamp(0, 100),
      happiness: (p.happiness + Constants.washHappiness).clamp(0, 100),
      energy: (p.energy - Constants.washEnergyDrain).clamp(0, 100),
      totalWashes: p.totalWashes + 1,
    );
    _addXP(Constants.xpPerWash);
    _advanceMission(1); // mission slot 1 = wash missions
    _checkAchievements();
  }

  void play() {
    if (state == null || state!.isSleeping) return;
    if (state!.energy < Constants.playMinEnergy) return;
    final p = state!;
    _update(
      happiness: (p.happiness + Constants.playHappiness).clamp(0, 100),
      energy: (p.energy - Constants.playEnergyDrain).clamp(0, 100),
      hunger: (p.hunger - Constants.playHungerDrain).clamp(0, 100),
      totalPlays: p.totalPlays + 1,
    );
    _addXP(Constants.xpPerPlay);
    _advanceMission(2); // mission slot 2 = play missions
    _checkAchievements();
  }

  void toggleSleep() {
    if (state == null) return;
    _update(isSleeping: !state!.isSleeping);
  }

  void addHappiness(double amount) {
    if (state == null) return;
    _update(happiness: (state!.happiness + amount).clamp(0, 100));
  }

  void recordGameResult(int score) {
    if (state == null) return;
    final p = state!;
    _update(
      totalGamesPlayed: p.totalGamesPlayed + 1,
      bestGameScore: score > p.bestGameScore ? score : null,
    );
    _addXP(score * 2); // 2 XP per food caught
    _checkAchievements();
  }

  // ── XP & Level ───────────────────────────────────────────────────────────

  void _addXP(int amount) {
    if (state == null) return;
    var newXP = state!.xp + amount;
    var newLevel = state!.level;
    var newCoins = state!.coins;

    while (newXP >= newLevel * 100) {
      newXP -= newLevel * 100;
      newLevel++;
      newCoins += 10 + (newLevel * 5); // level-up coin reward
      _eventController.add(PetEventData(PetEvent.levelUp,
          payload: '$newLevel'));
    }

    _update(xp: newXP, level: newLevel, coins: newCoins);
  }

  // ── Coins ────────────────────────────────────────────────────────────────

  bool spendCoins(int amount) {
    if (state == null || state!.coins < amount) return false;
    _update(coins: state!.coins - amount);
    return true;
  }

  // ── Accessories ──────────────────────────────────────────────────────────

  void buyAccessory(String id, int cost) {
    if (state == null) return;
    if (state!.ownedAccessories.contains(id)) return;
    if (!spendCoins(cost)) return;
    final owned = List<String>.from(state!.ownedAccessories)..add(id);
    _update(ownedAccessories: owned);
  }

  void equipAccessory(String? id) {
    if (state == null) return;
    // Directly mutate and reassign to trigger state update
    final pet = state!;
    pet.equippedAccessory = id;
    state = pet.copyWith(); // force state change
    StorageService.savePet(state!);
  }

  // ── Daily Missions ───────────────────────────────────────────────────────

  void _advanceMission(int slot) {
    if (state == null) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    var progress = List<int>.from(state!.missionProgress);

    // Reset missions if new day
    if (state!.lastMissionDate != today) {
      progress = [0, 0, 0];
    }

    progress[slot]++;
    _update(missionProgress: progress, lastMissionDate: today);

    // Check if mission completed (each mission requires 3 actions)
    if (progress[slot] == 3) {
      _addXP(Constants.xpPerMission);
      state = state!.copyWith(coins: state!.coins + 15);
      StorageService.savePet(state!);
      _eventController.add(PetEventData(PetEvent.missionComplete,
          payload: '$slot'));
    }
  }

  List<DailyMission> getDailyMissions() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final progress = (state?.lastMissionDate == today)
        ? state!.missionProgress
        : [0, 0, 0];
    return [
      DailyMission('Feed 3 times', '🍎', progress[0], 3),
      DailyMission('Wash 3 times', '🛁', progress[1], 3),
      DailyMission('Play 3 times', '🎮', progress[2], 3),
    ];
  }

  // ── Achievements ─────────────────────────────────────────────────────────

  void _checkAchievements() {
    if (state == null) return;
    final p = state!;
    final unlocked = List<String>.from(p.unlockedAchievements);
    bool changed = false;

    for (final a in Achievement.all) {
      if (!unlocked.contains(a.id) && a.check(p)) {
        unlocked.add(a.id);
        changed = true;
        _eventController.add(PetEventData(PetEvent.achievementUnlocked,
            payload: a.id));
      }
    }

    if (changed) {
      _update(unlockedAchievements: unlocked);
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _update({
    double? hunger,
    double? happiness,
    double? cleanliness,
    double? energy,
    bool? isSleeping,
    int? xp,
    int? level,
    int? coins,
    int? totalFeeds,
    int? totalWashes,
    int? totalPlays,
    int? totalGamesPlayed,
    int? bestGameScore,
    List<String>? unlockedAchievements,
    List<String>? ownedAccessories,
    String? lastMissionDate,
    List<int>? missionProgress,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      hunger: hunger,
      happiness: happiness,
      cleanliness: cleanliness,
      energy: energy,
      isSleeping: isSleeping,
      xp: xp,
      level: level,
      coins: coins,
      totalFeeds: totalFeeds,
      totalWashes: totalWashes,
      totalPlays: totalPlays,
      totalGamesPlayed: totalGamesPlayed,
      bestGameScore: bestGameScore,
      unlockedAchievements: unlockedAchievements,
      ownedAccessories: ownedAccessories,
      lastMissionDate: lastMissionDate,
      missionProgress: missionProgress,
    );
    StorageService.savePet(state!);
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    _eventController.close();
    super.dispose();
  }
}

final petProvider = StateNotifierProvider<PetNotifier, Pet?>(
  (ref) => PetNotifier(),
);

// ── Achievement definitions ──────────────────────────────────────────────────

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool Function(Pet) check;

  const Achievement(this.id, this.title, this.description, this.icon, this.check);

  static final all = [
    Achievement('first_feed', 'First Bite', 'Feed your pet for the first time', '🍎',
        (p) => p.totalFeeds >= 1),
    Achievement('feed_10', 'Foodie', 'Feed your pet 10 times', '🍕',
        (p) => p.totalFeeds >= 10),
    Achievement('feed_50', 'Master Chef', 'Feed your pet 50 times', '👨‍🍳',
        (p) => p.totalFeeds >= 50),
    Achievement('first_wash', 'Squeaky Clean', 'Wash your pet for the first time', '🛁',
        (p) => p.totalWashes >= 1),
    Achievement('wash_10', 'Spa Day', 'Wash your pet 10 times', '🧼',
        (p) => p.totalWashes >= 10),
    Achievement('first_play', 'Playtime!', 'Play with your pet for the first time', '🎮',
        (p) => p.totalPlays >= 1),
    Achievement('play_25', 'Best Friend', 'Play with your pet 25 times', '🤝',
        (p) => p.totalPlays >= 25),
    Achievement('level_5', 'Growing Up', 'Reach level 5', '⭐',
        (p) => p.level >= 5),
    Achievement('level_10', 'Rising Star', 'Reach level 10', '🌟',
        (p) => p.level >= 10),
    Achievement('level_20', 'Legend', 'Reach level 20', '👑',
        (p) => p.level >= 20),
    Achievement('streak_3', 'Dedicated', '3-day login streak', '🔥',
        (p) => p.streak >= 3),
    Achievement('streak_7', 'Committed', '7-day login streak', '💎',
        (p) => p.streak >= 7),
    Achievement('streak_30', 'Unstoppable', '30-day login streak', '🏆',
        (p) => p.streak >= 30),
    Achievement('game_master', 'Game Master', 'Score 25+ in a mini game', '🎯',
        (p) => p.bestGameScore >= 25),
    Achievement('full_health', 'Perfect Care', 'All stats above 90', '💖',
        (p) => p.hunger >= 90 && p.happiness >= 90 && p.cleanliness >= 90 && p.energy >= 90),
    Achievement('coin_100', 'Saver', 'Collect 100 coins', '💰',
        (p) => p.coins >= 100),
  ];
}

// ── Daily Mission model ──────────────────────────────────────────────────────

class DailyMission {
  final String title;
  final String icon;
  final int current;
  final int target;

  DailyMission(this.title, this.icon, this.current, this.target);

  bool get isComplete => current >= target;
  double get progress => (current / target).clamp(0, 1);
}
