import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const _petKey = 'saved_pet';
  static const _hasSelectedKey = 'has_selected_pet';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get hasSelectedPet => _prefs.getBool(_hasSelectedKey) ?? false;

  static Future<void> savePet(Pet pet) async {
    await _prefs.setString(_petKey, jsonEncode(pet.toJson()));
    await _prefs.setBool(_hasSelectedKey, true);
  }

  static Pet? loadPet() {
    final raw = _prefs.getString(_petKey);
    if (raw == null) return null;
    try {
      return Pet.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearPet() async {
    await _prefs.remove(_petKey);
    await _prefs.remove(_hasSelectedKey);
  }
}
