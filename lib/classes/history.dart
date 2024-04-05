import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserHistory {
  static const _key = 'watch_history';

  static Future<List<Map<String, dynamic>>> fetch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
    }
    return [];
  }

  static Future<void> save(List<Map<String, dynamic>> watchList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(watchList);
    await prefs.setString(_key, jsonString);
  }

  static Future<List<Map<String, dynamic>>> fetchByAnimeId(
      String animeId) async {
    final List<Map<String, dynamic>> watchList = await fetch();
    return watchList.where((entry) => entry['anime_id'] == animeId).toList();
  }

  static Future<void> saveEpisodeProgress(
      String animeId, int episode, int progress) async {
    final List<Map<String, dynamic>> watchList = await fetch();
    final index = watchList.indexWhere(
        (entry) => entry['anime_id'] == animeId && entry['episode'] == episode);
    if (index != -1) {
      watchList[index]['progress'] = progress;
    } else {
      watchList
          .add({'anime_id': animeId, 'episode': episode, 'progress': progress});
    }
    await save(watchList);
  }

  static Future<void> saveEpisodeLength(
      String animeId, int episode, int length) async {
    final List<Map<String, dynamic>> watchList = await fetch();
    final index = watchList.indexWhere(
        (entry) => entry['anime_id'] == animeId && entry['episode'] == episode);
    if (index != -1) {
      watchList[index]['length'] = length;
    } else {
      watchList
          .add({'anime_id': animeId, 'episode': episode, 'length': length});
    }
    await save(watchList);
  }
}
