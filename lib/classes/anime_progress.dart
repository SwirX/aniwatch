import 'dart:convert';
import 'dart:io';
import 'package:aniwatch/classes/anime.dart';
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
    print('Error getting file in cache: $e');
    throw e; // Rethrow the error
  }
}

class EpisodeProgress {
  final AnimeIds animeIds;
  final int episodeNumber;
  final String episodeUrl;
  final bool watched;
  final String? episodeTitle;

  EpisodeProgress({
    required this.animeIds,
    required this.episodeNumber,
    required this.episodeUrl,
    required this.watched,
    this.episodeTitle,
  });

  factory EpisodeProgress.fromJson(Map<String, dynamic> json) {
    return EpisodeProgress(
      animeIds: AnimeIds(
        allanime: json['animeIds']['allanime'] as String,
        anilist: json['animeIds']['anilist'] as int?,
        mal: json['animeIds']['mal'] as int?,
      ),
      episodeNumber: json['episodeNumber'] as int,
      episodeUrl: json['episodeUrl'] as String,
      watched: json['watched'] as bool,
      episodeTitle: json['episodeTitle'] as String?,
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
      'episodeTitle': episodeTitle,
    };
  }
}

class UserAnimeProgress {
  final String _progressFilePath =
      '/data/data/com.example.aniwatch/user_progress.json';

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
      print('Error loading user progress: $e');
    }
  }

  void _saveProgress() {
    try {
      final file = File(_progressFilePath);
      file.writeAsStringSync(jsonEncode(_progressData));
    } catch (e) {
      print('Error saving user progress: $e');
    }
  }

  void saveProgress({
    required AnimeIds animeIds,
    required String episodeUrl,
    required int episodeNumber,
    required bool watched,
  }) {
    final episodeData = {
      'animeIds': {
        'allanime': animeIds.allanime,
        'anilist': animeIds.anilist,
        'mal': animeIds.mal,
      },
      'episodeNumber': episodeNumber,
      'episodeUrl': episodeUrl,
      'watched': watched,
    };
    _progressData.add(episodeData);
    _saveProgress();
  }

  EpisodeProgress? getLatestEpisodeProgress(String allanimeId) {
    List<Map<String, dynamic>> progressData = [];

    // If _progressData is empty, load data from the file
    if (_progressData.isEmpty) {
      try {
        final jsonString = File(_progressFilePath).readAsStringSync();
        progressData = jsonDecode(jsonString).cast<Map<String, dynamic>>();
      } catch (e) {
        print('Error loading user progress: $e');
      }
    } else {
      // Otherwise, filter the data based on the animeId
      progressData = _progressData
          .where((entry) => entry['animeIds']['allanime'] == allanimeId)
          .toList();
      print("progress data: $progressData");
    }

    if (progressData.isEmpty) {
      return null;
    }

    progressData.sort((a, b) =>
        (a['episodeNumber'] as int).compareTo(b['episodeNumber'] as int));

    for (int i = progressData.length - 1; i >= 0; i--) {
      print("progress data on index $i: ${progressData[i]}");
      if ((progressData[i]['watched'] as bool)) {
        print("Found unwatched episode at index $i");
        return EpisodeProgress.fromJson(progressData[i]);
      }
    }

    // If all episodes are watched, return null
    return null;
  }
}
