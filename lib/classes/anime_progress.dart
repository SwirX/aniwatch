import 'dart:convert';
import 'dart:io';
import 'package:aniwatch/classes/anime.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

Future<File> getFileInCache(String path) async {
  try {
    // Get the directory for the app's cache
    Directory cacheDir = await getTemporaryDirectory();
    // Construct the complete file path
    String filePath = '${cacheDir.path}/$path';
    // Check if the file exists
    bool exists = await File(filePath).exists();
    if (!exists) {
      // If the file doesn't exist, create it
      File newFile = File(filePath);
      await newFile.create();
      return newFile;
    } else {
      // If the file exists, return it
      return File(filePath);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error getting file in cache: $e');
    }
    rethrow; // Rethrow the error
  }
}

class EpisodeProgress {
  final AnimeIds animeIds;
  final String animeName;
  final int episodeNumber;
  final String episodeUrl;
  final Duration progress;
  final bool watched;
  final String? episodeTitle;
  final String? synopsis;
  final String? thumbnail;

  EpisodeProgress({
    required this.animeIds,
    required this.animeName,
    required this.episodeNumber,
    required this.episodeUrl,
    required this.progress,
    required this.watched,
    this.episodeTitle,
    this.synopsis,
    this.thumbnail,
  });

  factory EpisodeProgress.fromJson(Map<String, dynamic> json) {
    return EpisodeProgress(
      animeIds: AnimeIds(
        allanime: json['animeIds']['allanime'] as String,
        anilist: json['animeIds']['anilist'] as int?,
        mal: json['animeIds']['mal'] as int?,
      ),
      animeName: json["animeName"] as String,
      episodeNumber: json['episodeNumber'] as int,
      episodeUrl: json['episodeUrl'] as String,
      progress: Duration(seconds: json["progress"]),
      watched: json['watched'] as bool,
      episodeTitle: json['episodeTitle'] as String?,
      thumbnail: json["thumbnail"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animeIds': {
        'allanime': animeIds.allanime,
        'anilist': animeIds.anilist,
        'mal': animeIds.mal,
      },
      'episodeNumber': episodeNumber,
      'episodeUrl': episodeUrl,
      'watched': watched,
      'episodeTitle': episodeTitle ?? "",
      'thumbnail': thumbnail ?? ""
    };
  }
}

class UserAnimeProgress {
  final String _progressFilePath = Platform.operatingSystem == "android"
      ? '/data/data/com.aniwatch/user_progress.json'
      : "D:\\Docs\\user_progress.json";

  List<Map<String, dynamic>> _progressData = [];

  UserAnimeProgress() {
    _loadProgress();
  }

  void _loadProgress() {
    try {
      final file = File(_progressFilePath);
      if (file.existsSync()) {
        final jsonString = file.readAsStringSync();
        _progressData = jsonDecode(jsonString).cast<Map<String, dynamic>>();
      } else {
        file.createSync();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user progress: $e');
      }
    }
  }

  void _saveProgress() {
    try {
      final file = File(_progressFilePath);
      file.writeAsStringSync(jsonEncode(_progressData));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user progress: $e');
      }
    }
  }

  void saveProgress({
    required AnimeIds animeIds,
    required String animeName,
    required String episodeUrl,
    required int episodeNumber,
    required Duration progress,
    required bool watched,
    String? thumb,
    String? episodeTitle,
  }) {
    // Check if anime entry already exists in progress data
    int existingIndex = _progressData.indexWhere(
        (entry) => entry['animeIds']['allanime'] == animeIds.allanime);

    // Create a new episode entry
    final episodeData = {
      'episodeUrl': episodeUrl,
      'episodeNumber': episodeNumber,
      'progress': progress.inSeconds,
      'watched': watched,
      'thumbnail': thumb ?? "",
      'episodeTitle': episodeTitle ?? "",
    };

    if (existingIndex != -1) {
      // Anime entry already exists, add the episode to its episodes list
      int episodeindex = _progressData[existingIndex]["episodes"].indexWhere(
          (entry) => entry['episodeNumber'] == episodeData["episodeNumber"]);
      if (episodeindex != -1) {
        _progressData[existingIndex]['episodes'][1]["progress"] ==
            progress.inSeconds;
        _progressData[existingIndex]['episodes'][1]["watched"] == watched;
      }
      _progressData[existingIndex]['episodes'].add(episodeData);
    } else {
      // Anime entry doesn't exist, create a new entry with the episode
      final animeData = {
        'animeIds': {
          'allanime': animeIds.allanime,
          'anilist': animeIds.anilist,
          'mal': animeIds.mal,
        },
        'animeName': animeName,
        'episodes': [episodeData], // Create a list with the new episode
      };
      _progressData.add(animeData);
    }

    // Save progress data to file
    _saveProgress();
  }

  List<EpisodeProgress>? getWatchList() {
    List<EpisodeProgress> watchList = [];
    _progressData.forEach((entry) {
      List<Map<String, dynamic>> episodes =
          List<Map<String, dynamic>>.from(entry['episodes']);
      watchList.addAll(episodes
          .map((e) => EpisodeProgress.fromJson({
                "animeIds": {
                  "allanime": entry["animeIds"]["allanime"],
                  "anilist": entry["animeIds"]["anilist"],
                  "mal": entry["animeIds"]["mal"],
                },
                "animeName": entry["animeName"],
                "episodeUrl": e["episodeUrl"],
                "episodeNumber": e["episodeNumber"],
                "progress": e["progress"],
                "watched": e["watched"]
              }))
          .toList());
    });
    return watchList;
  }

  EpisodeProgress? getLatestEpisodeProgress(String allanimeId) {
    Map<String, dynamic> progressData = {};
    Map<String, dynamic> tmpProgressData = {};

    // If _progressData is empty, load data from the file
    if (_progressData.isEmpty) {
      try {
        final jsonString = File(_progressFilePath).readAsStringSync();
        progressData = jsonDecode(jsonString).cast<Map<String, dynamic>>();
      } catch (e) {
        if (kDebugMode) {
          print('Error loading user progress: $e');
        }
      }
    } else {
      // Otherwise, filter the data based on the animeId
      tmpProgressData = _progressData
              .where((entry) => entry['animeIds']['allanime'] == allanimeId)
              .lastOrNull ??
          {};
      if (tmpProgressData.isEmpty) {
        return null;
      }
      if (kDebugMode) {
        print("progress data: $tmpProgressData");
      }
    }

    if (tmpProgressData.isEmpty) {
      return null;
    }

    final episodes = tmpProgressData["episodes"];

    episodes.sort((a, b) =>
        (a['episodeNumber'] as int).compareTo(b['episodeNumber'] as int));

    for (int i = episodes.length - 1; i >= 0; i--) {
      if (kDebugMode) {
        print("progress data on index $i: ${episodes[i]}");
      }
      if ((episodes[i]['watched'] as bool || episodes[i]["progress"] != 0)) {
        if (kDebugMode) {
          print("Found unwatched episode at index $i");
        }

        progressData = {
          "animeIds": {
            "allanime": tmpProgressData["animeIds"]["allanime"],
            "anilist": tmpProgressData["animeIds"]["anilist"],
            "mal": tmpProgressData["animeIds"]["mal"]
          },
          "animeName": tmpProgressData["animeName"],
          "episodeUrl": episodes[i]["episodeUrl"],
          "episodeNumber": episodes[i]["episodeNumber"],
          "progress": episodes[i]["progress"],
          "watched": episodes[i]["watched"]
        };

        print(progressData);

        return EpisodeProgress.fromJson(progressData);
      }
    }

    // If all episodes are watched, return null
    return null;
  }
}
