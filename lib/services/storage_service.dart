import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/itinerary.dart';

class StorageService {
  static const _key = 'saved_trips';

  Future<List<Itinerary>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => Itinerary.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveTrip(Itinerary itinerary) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(itinerary.toJson()));
    await prefs.setStringList(_key, raw);
  }

  Future<void> deleteTrip(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) {
      final map = jsonDecode(e);
      return map['id'] == id;
    });
    await prefs.setStringList(_key, raw);
  }
}