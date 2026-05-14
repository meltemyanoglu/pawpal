import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

class PetNotifier extends StateNotifier<Pet?> {
  Timer? _decayTimer;

  PetNotifier() : super(null) {
    _tryRestorePet();
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  void _tryRestorePet() {
    final saved = StorageService.loadPet();
    if (saved == null) return;

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

    state = saved;
    _startDecay();
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
    );
  }

  void wash() {
    if (state == null || state!.isSleeping) return;
    final p = state!;
    _update(
      cleanliness: (p.cleanliness + Constants.washCleanliness).clamp(0, 100),
      happiness: (p.happiness + Constants.washHappiness).clamp(0, 100),
      energy: (p.energy - Constants.washEnergyDrain).clamp(0, 100),
    );
  }

  void play() {
    if (state == null || state!.isSleeping) return;
    if (state!.energy < Constants.playMinEnergy) return;
    final p = state!;
    _update(
      happiness: (p.happiness + Constants.playHappiness).clamp(0, 100),
      energy: (p.energy - Constants.playEnergyDrain).clamp(0, 100),
      hunger: (p.hunger - Constants.playHungerDrain).clamp(0, 100),
    );
  }

  void toggleSleep() {
    if (state == null) return;
    _update(isSleeping: !state!.isSleeping);
  }

  void addHappiness(double amount) {
    if (state == null) return;
    _update(happiness: (state!.happiness + amount).clamp(0, 100));
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _update({
    double? hunger,
    double? happiness,
    double? cleanliness,
    double? energy,
    bool? isSleeping,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      hunger: hunger,
      happiness: happiness,
      cleanliness: cleanliness,
      energy: energy,
      isSleeping: isSleeping,
    );
    StorageService.savePet(state!);
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    super.dispose();
  }
}

final petProvider = StateNotifierProvider<PetNotifier, Pet?>(
  (ref) => PetNotifier(),
);
