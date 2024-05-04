import "dart:convert";
// import "package:flutter/foundation.dart";
// ignore: depend_on_referenced_packages
import "package:http/http.dart" as http;
// import "package:shared_preferences/shared_preferences.dart";

class AllAnime {
  String agent =
      "Mozilla/5.0 (Windows NT 6.1; Win64; rv:109.0) Gecko/20100101 Firefox/109.0";
  String allanimeApi = "https://api.allanime.day/";
  String allanimeBase = "https://allanime.to";
  String lang = "en";
  String mode = "sub";
  List<String> internalLinks = [
    "Luf-mp4",
    "Sak",
    "Default",
    "S-mp4",
  ];

  String endpoint = "";
  String cacheFileName = "aniwatch.cache.json";

  // Queries

  String popularQuery = r"""
            query(
                $type: VaildPopularTypeEnumType!
                $size: Int!
                $page: Int
                $dateRange: Int
            ) {
                queryPopular(
                    type: $type
                    size: $size
                    dateRange: $dateRange
                    page: $page
                ) {
                    total
                    recommendations {
                        anyCard {
                            _id
                            name
                            thumbnail
                            englishName
                            slugTime
                        }
                    }
                }
            }
        """;

  String searchQuery = r"""
            query(
                $search: SearchInput
                $limit: Int
                $page: Int
                $translationType: VaildTranslationTypeEnumType
                $countryOrigin: VaildCountryOriginEnumType
            ) {
                shows(
                    search: $search
                    limit: $limit
                    page: $page
                    translationType: $translationType
                    countryOrigin: $countryOrigin
                ) {
                    pageInfo {
                        total
                    }
                    edges {
                        _id
                        name
                        thumbnail
                        englishName
                        episodeCount
                        score
                        genres
                        slugTime
                        __typename
                    }
                }
            }
        """;

  String detailsQuery = r"""
            query ($_id: String!) {
                show(
                    _id: $_id
                ) {
                    thumbnail
                    description
                    type
                    season
                    score
                    genres
                    status
                    studios
                }
            }
        """;

  String episodesQuery = r"""
            query ($_id: String!) {
                show(
                    _id: $_id
                ) {
                    _id
                    availableEpisodesDetail
                }
            }
        """;

  String streamsQuery = r"""
            query(
                $showId: String!,
                $translationType: VaildTranslationTypeEnumType!,
                $episodeString: String!
            ) {
                episode(
                    showId: $showId
                    translationType: $translationType
                    episodeString: $episodeString
                ) {
                    sourceUrls
                }
            }
        """;

  String decryptAllanime(String providerId) {
    String decrypted = '';
    for (int i = 0; i < providerId.length; i += 2) {
      String hexValue = providerId.substring(i, i + 2);
      int dec = int.parse(hexValue, radix: 16);
      int xor = dec ^ 56;
      String octValue = xor.toRadixString(8).padLeft(3, '0');
      decrypted += String.fromCharCode(int.parse(octValue, radix: 8));
    }
    return decrypted;
  }

  bool isInternal(String link) {
    return internalLinks.contains(link);
  }

  Future<Map<String, dynamic>> getPopular({int page = 1}) async {
    // final sp = await SharedPreferences.getInstance();
    // final cacheKey = "popular_$page";
    // final cachedDataString = sp.getString(cacheKey);
    // final cachedData = jsonDecode(cachedDataString!);

    // if (cachedData != null) {
    //   if (DateTime.now().millisecondsSinceEpoch - cachedData["timestamp"] <=
    //       60 * 60 * 24) {
    //     return cachedData;
    //   }
    // }

    final params = {
      "variables": jsonEncode({
        "type": "anime",
        "size": 26,
        "dateRange": 7,
        "page": page,
      }),
      "query": popularQuery,
    };

    final uri = Uri.parse("$allanimeApi/api").replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: {
        "Referer": allanimeBase,
        "User-Agent": agent,
      },
    );

    // if (kDebugMode) {
    print(response.body);
    // }
    final data =
        jsonDecode(response.body)["data"]["queryPopular"]["recommendations"];
    data["timestamp"] = DateTime.now().millisecondsSinceEpoch;
    // sp.setString(cacheKey, jsonEncode(data));
    return data;
  }

  Future<Map<String, dynamic>> getLatestUpdate({int page = 1}) async {
    // final sp = await SharedPreferences.getInstance();
    // final cacheKey = "latestUpdate_$page";
    // final cacheDataString = sp.getString(cacheKey);
    // final cacheData = jsonDecode(cacheDataString ?? "{}");

    // if (cacheDataString != null) {
    //   if (DateTime.now().millisecondsSinceEpoch - cacheData["timestamp"] <=
    //       60 * 60 * 24) {
    //     return cacheData;
    //   }
    // }

    final params = {
      "variables": jsonEncode({
        "search": {
          "allowAdult": false,
          "allowUnknown": false,
        },
        "limit": 26,
        "page": page,
        "translationType": mode,
        "countryOrigin": "ALL"
      }),
      "query": searchQuery
    };

    final headers = {
      "Referer": allanimeBase,
      "User-Agent": agent,
    };

    final uri = Uri.parse("$allanimeApi/api").replace(queryParameters: params);

    final response = await http.get(uri, headers: headers);
    // if (kDebugMode) {
    print(response.body);
    // }

    final data = jsonDecode(response.body)["data"]["shows"]["edges"];
    data["timestamp"] = DateTime.now().millisecondsSinceEpoch;
    // sp.setString(cacheKey, jsonEncode(data));
    return data;
  }

  Future<List<AnimeV2>> search(String query, {int page = 1}) async {
    // final sp = await SharedPreferences.getInstance();
    // final cacheKey = "search_$query";
    // final cacheDataString = sp.getString(cacheKey);
    // final cacheData = jsonDecode(cacheDataString ?? "{}");

    // if (cacheDataString != null) {
    //   final List<AnimeV2> animeList = [];
    //   for (var edge in cacheData) {
    //     animeList.add(AnimeV2(
    //         edge["_id"], edge["name"], int.parse(edge["episodeCount"]), []));
    //   }
    //   return animeList;
    // }

    final params = {
      "variables": jsonEncode({
        "search": {
          "query": query,
          "allowAdult": false,
          "allowUnknown": false,
        },
        "limit": 26,
        "page": page,
        "translationType": mode,
        "countryOrigin": "ALL",
      }),
      "query": searchQuery,
    };

    final headers = {
      "Referer": allanimeBase,
      "User-Agent": agent,
    };

    final uri = Uri.parse("$allanimeApi/api").replace(queryParameters: params);

    final response = await http.get(uri, headers: headers);

    // if (kDebugMode) {
    print(response.body);
    // }

    final data = jsonDecode(response.body)["data"]["shows"]["edges"];
    // sp.setString(cacheKey, jsonEncode(data));
    final List<AnimeV2> animeList = [];
    for (var edge in data) {
      animeList.add(AnimeV2(
          edge["_id"], edge["name"], int.parse(edge["episodeCount"]), []));
    }
    return animeList;
  }

  Future<Map<String, dynamic>> getAnimeDetails(String animeId) async {
    final params = {
      "variables": jsonEncode({
        "_id": animeId,
      }),
      "query": detailsQuery,
    };

    final headers = {
      "Referer": allanimeBase,
      "User-Agent": agent,
    };

    final uri = Uri.parse("$allanimeApi/api").replace(queryParameters: params);

    final response = await http.get(uri, headers: headers);

    // if (kDebugMode) {
    print(response.body);
    // }

    final data = jsonDecode(response.body)["data"]["show"];
    //sp.setString(cacheKey, jsonEncode(data));
    return data;
  }

  Future<List> getEpisodesStreams(String animeId, int episodeNumber) async {
    final params = {
      "variables": jsonEncode({
        "showId": animeId,
        "translationType": mode,
        "episodeString": "$episodeNumber",
      }),
      "query": streamsQuery,
    };

    final headers = {
      "Referer": allanimeBase,
      "User-Agent": agent,
    };

    final uri = Uri.parse("$allanimeApi/api").replace(queryParameters: params);

    final response = await http.get(uri, headers: headers);

    // if (kDebugMode) {
    print(response.body);
    // }

    final data = jsonDecode(response.body)["data"]["episode"]["sourceUrls"];
    // sp.setString(cacheKey, jsonEncode(data));
    return data;
  }

  Future<List> getVideoFromUrl(String url, String name) async {
    final decryptedUrl = decryptAllanime(url.replaceAll("--", ""));
    if (endpoint == "") {
      endpoint = jsonDecode(
          (await http.get(Uri.parse("$allanimeBase/getVersion")))
              .body)["episodeIframeHead"];
    }
    final response = await http.get(Uri.parse(
        "$endpoint${decryptedUrl.replaceAll('/clock?', '/clock.json?')}"));
    if (response.statusCode != 200) {
      return [];
    }
    return jsonDecode(response.body)["links"];
  }

  Future<List<VideoLink>> getVideoList(String animeId, int episodeNum) async {
    final episodesStreams = await getEpisodesStreams(animeId, episodeNum);
    final videoList = [];
    for (var stream in episodesStreams) {
      if (isInternal(stream["sourceName"])) {
        final links =
            await getVideoFromUrl(stream["sourceUrl"], stream["sourceName"]);
        videoList.add(links);
      }
    }
    final List<VideoLink> videoLinks = [];
    for (var video in videoList) {
      if (video == {}) {
        // if (kDebugMode) {
        print("skipping");
        // }
        continue;
      }
      video = video.first;
      // if (kDebugMode) {
      print(video);
      // }
      final link = video["link"];
      final hls =
          video["hls"] ?? (video["mp4"] != null ? !video["mp4"] : false);
      final mp4 =
          video["mp4"] ?? (video["hls"] != null ? !video["hls"] : false);
      final resolution = video["resolutionStr"];
      final src = video["rawUrls"] ?? "";
      final rawUrls = video["rawUrls"] ?? {};
      videoLinks.add(VideoLink(
        link: link,
        hls: hls,
        mp4: mp4,
        resolution: resolution,
        src: src,
        rawUrls: rawUrls,
      ));
    }

    return videoLinks;
  }
}

class VideoLink {
  final String link;
  final bool hls;
  final bool mp4;
  final String resolution;
  final String src;
  Map rawUrls = {};

  VideoLink({
    required this.link,
    required this.hls,
    required this.mp4,
    required this.resolution,
    required this.src,
    this.rawUrls = const {},
  });
}

class EpisodeV2 {
  final int number;
  final String title;
  final List streams;

  EpisodeV2(this.number, this.title, this.streams);
}

class AnimeV2 {
  final String id;
  final String title;
  final int episodesCount;
  final List<EpisodeV2> episodes;
  late String thumbnail;
  late String type;
  late double score;
  late List genres;
  late String status;
  late String description;

  AnimeV2(this.id, this.title, this.episodesCount, this.episodes) {
    getDetails();
  }

  void getDetails() async {
    final info = await AllAnime().getAnimeDetails(id);
    thumbnail = info["thumbnail"];
    type = info["type"];
    score = info["score"];
    genres = info["genres"];
    status = info["status"];
    description = info["description"];
  }

  Future<EpisodeV2> getEpisode(int episodeNum) async {
    final streams = await AllAnime().getVideoList(id, episodeNum);
    final episodeTitle = "Episode $episodeNum";
    final ep = EpisodeV2(episodeNum, episodeTitle, streams);
    episodes.add(ep);
    return ep;
  }
}

void main() async {
  final a = AllAnime();
  final anime = await a.search("mha");
  (await anime[0].getEpisode(1));
  print(anime[0].episodes.first.streams.first.link);
}
