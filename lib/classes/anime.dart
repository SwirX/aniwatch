import 'dart:convert';
import 'package:aniwatch/services/anifetch.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class AnimeSearchResult {
  String allanimeId;
  int anilistId;
  int malId;
  int episode;
  String banner;
  String cover;
  String name;
  double score;
  String genre;

  AnimeSearchResult({
    required this.allanimeId,
    required this.anilistId,
    required this.malId,
    required this.episode,
    required this.banner,
    required this.cover,
    required this.name,
    required this.score,
    required this.genre,
  });
}

class AnimeMedia {
  String? banner;
  AnimeCover? cover;
  AnimeTrailer? trailer;

  AnimeMedia({
    this.banner,
    this.cover,
    this.trailer,
  });
}

class AnimeCover {
  String? normal;
  String? small;
  String? large;
  String? extraLarge;
  String? color;

  AnimeCover({
    this.normal,
    this.small,
    this.large,
    this.extraLarge,
    this.color,
  });
}

class AnimeTitle {
  String? normal;
  String? english;
  String? native;
  String? romaji;
  List<String>? synonyms = [];

  AnimeTitle(
      {this.normal, this.english, this.native, this.romaji, this.synonyms});
}

class AnimeAiring {
  DateTime? start;
  DateTime? end;

  AnimeAiring({this.start, this.end});
}

class AnimeThumbnail {
  String? normal;
  String? small;
  String? medium;
  String? large;
  String? max;

  AnimeThumbnail({
    this.normal,
    this.small,
    this.medium,
    this.large,
    this.max,
  });
}

class AnimeTrailer {
  String? youtubeId;
  String? url;
  String? embed;
  AnimeThumbnail? thumbnail;

  AnimeTrailer({
    this.youtubeId,
    this.url,
    this.embed,
    this.thumbnail,
  });
}

class AnimeIds {
  String allanime;
  int? anilist;
  int? mal;

  AnimeIds({required this.allanime, this.anilist, this.mal});
}

class AnimeReference {
  int id;
  String name;
  String type;
  String url;

  AnimeReference({required this.id, required this.name, required this.type, required this.url});
}

class AnimeRelation {
  String? relation;
  List<AnimeReference>? anime = [];

  AnimeRelation({this.relation, this.anime});

  factory AnimeRelation.fromJson(Map<String, dynamic> json) {
    List<AnimeReference> refs = [];
    for (var entry in json["entry"]) {
      final ref = AnimeReference(
          id: entry["mal_id"], name: entry["name"], type: entry["type"], url: entry["url"]);
      refs.add(ref);
    }
    return AnimeRelation(relation: json['relation'], anime: refs);
  }
}

class AnimeTheme {
  List<String>? openings = [];
  List<String>? endings = [];

  AnimeTheme({this.openings, this.endings});

  factory AnimeTheme.fromJson(Map<String, dynamic> json) {
    return AnimeTheme(
        openings: (json["openings"] as List<dynamic>)
            .map<String>((dynamic opening) => opening.toString())
            .toList(),
        endings: (json["endings"] as List<dynamic>)
            .map<String>((dynamic opening) => opening.toString())
            .toList());
  }
}

class AnimeTag {
  String? name;
  String? category;
  int? rank;

  AnimeTag({this.name, this.category, this.rank});

  factory AnimeTag.fromJson(Map<String, dynamic> json) {
    return AnimeTag(
        name: json["name"], category: json["category"], rank: json["rank"]);
  }
}

class AnimeNextAiring {
  int? episode;
  DateTime? airingAt;

  AnimeNextAiring({this.airingAt, this.episode});
}

class Anime {
  AnimeIds? ids;
  AnimeTitle? title;
  List<Map>? episodes = [];
  int? episodeCount;
  AnimeMedia? media;
  AnimeAiring? airingEvent;
  String? description;
  String? season;
  double? score;
  int? popularity;
  int? duration;
  List<String>? genres = [];
  List<AnimeTag>? tags = [];
  AnimeTheme? theme;
  String? type;
  String? status;
  String? source;
  AnimeNextAiring? nextAiring;
  bool? airing = false;
  List<AnimeRelation>? relations = [];

  String? mode;
  int? lastWatched = 1;
  int? lastTimestamp = 0;

  Anime({
    // ignore: non_constant_identifier_names
    this.ids,
    this.title,
    this.episodes,
    this.episodeCount,
    this.media,
    this.description,
    this.score,
    this.popularity,
    this.duration,
    this.genres,
    this.tags,
    this.theme,
    this.type,
    this.status,
    this.source,
    this.airing,
    this.season,
    this.relations,
    this.nextAiring,
    this.airingEvent,
    this.mode = "sub",
    this.lastWatched,
    this.lastTimestamp,
  });

  setWatched(int ep) {
    episodes![ep - 1]["watched"] = true; // corrected assignment
  }

  setTimestamp(Duration duration) {
    var seconds = duration.inSeconds;
    lastTimestamp = seconds;
  }

  Future<void> fetchEpisodes() async {
    episodes!.clear(); // clear episodes list
    var eps = await episodesList(ids!.allanime);
    var length = 0;
    for (var ep in eps) {
      if (ep == lastWatched) {
        final response = await http.get(
          Uri.parse(
              'https://api.aniskip.com/v1/skip-times/${ids!.mal}/$ep?types=op&types=ed'),
          headers: {
            'User-Agent': agent, // agent variable should be defined/imported
          },
        );
        var skipMd = json.decode(response.body);
        length = skipMd["results"][0]["episode_length"];
      }
      episodes!.add({"length": length, "skipTimes": null, "watched": false});
    }
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'allanime_id': allanime_id,
  //     'name': name,
  //     'episodes': episodes,
  //     'thumb': thumb,
  //     'lastWatched': lastWatched,
  //     'lastTimestamp': lastTimestamp,
  //     'mode': mode,
  //   };
  // }
}
