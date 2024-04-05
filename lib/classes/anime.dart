import 'dart:convert';
import 'package:aniwatch/services/anifetch.dart';
import 'package:aniwatch/services/aniskip.dart';
import 'package:http/http.dart' as http;

class Anime {
  String allanime_id;
  int? malId;
  String name;
  List<Map> episodes;
  String mode;
  String? thumb = "";
  int? lastWatched = 0;
  int? lastTimestamp = 0;

  Anime({
    required this.allanime_id,
    required this.name,
    required this.episodes,
    this.thumb,
    this.lastWatched,
    this.lastTimestamp,
    this.mode = "sub",
  });

  setWatched(int ep) {
    episodes[ep - 1]["watched"] = true; // corrected assignment
  }

  setTimestamp(Duration duration) {
    var seconds = duration.inSeconds;
    lastTimestamp = seconds;
  }

  Future<void> getId() async {
    malId = await fetchMalId(name);
  }

  Future<void> fetchEpisodes() async {
    if (malId == null) {
      await getId(); // await fetching MAL ID
    }
    episodes.clear(); // clear episodes list
    var eps = await episodesList(allanime_id);
    var length = 0;
    for (var ep in eps) {
      if (ep == lastWatched) {
        final response = await http.get(
          Uri.parse(
              'https://api.aniskip.com/v1/skip-times/$malId/$ep?types=op&types=ed'),
          headers: {
            'User-Agent': agent, // agent variable should be defined/imported
          },
        );
        var skipMd = json.decode(response.body);
        length = skipMd["results"][0]["episode_length"];
      }
      episodes.add({"length": length, "skipTimes": null, "watched": false});
    }
  }

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      allanime_id: json['allanime_id'],
      name: json['name'],
      episodes: List<Map>.from(json['episodes']),
      thumb: json['thumb'],
      lastWatched: json['lastWatched'],
      lastTimestamp: json['lastTimestamp'],
      mode: json['mode'] ?? "sub",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allanime_id': allanime_id,
      'name': name,
      'episodes': episodes,
      'thumb': thumb,
      'lastWatched': lastWatched,
      'lastTimestamp': lastTimestamp,
      'mode': mode,
    };
  }
}
