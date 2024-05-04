import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/services/anisearch.dart';
import 'package:aniwatch/services/anilookup.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

const String agent =
    "Mozilla/5.0 (Windows NT 6.1; Win64; rv:109.0) Gecko/20100101 Firefox/109.0";
const String allAnimeBase = "https://allanime.to";
const String allAnimeApi = "https://api.allanime.day";

// var mode = "sub";

// Function to decrypt provider ID
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

// Function to search for anime
Future<List<Anime>> searchAnime(String query) async {
  final headers = {
    'User-Agent': agent,
    'Referer': allAnimeBase,
  };

  final params = {
    'variables': jsonEncode({
      "search": {"allowAdult": false, "allowUnknown": false, "query": query},
      "limit": 40,
      "page": 1,
      "translationType": mode,
      "countryOrigin": "ALL"
    }),
    'query': _searchGql,
  };

  final url = Uri.parse('$allAnimeApi/api').replace(queryParameters: params);

  final allanimeResponse = await http.get(url, headers: headers);
  List<Anime> animelist = [];
  if (allanimeResponse.statusCode == 200) {
    var resp = allanimeResponse.body.replaceAll("'", '"');
    final Map<String, dynamic> allanimeData = json.decode(resp);
    if (allanimeData.containsKey('data') &&
        allanimeData['data'].containsKey('shows')) {
      for (final edge in allanimeData['data']['shows']['edges']) {
        final allanime = edge['_id'];
        if (edge["aniListId"] == null && edge["malId"] == null) {
          continue;
        }
        final mal = int.tryParse(edge["malId"]);
        final anilist = int.tryParse(edge["aniListId"] ?? "");
        final ids = AnimeIds(allanime: allanime, anilist: anilist, mal: mal);
        final epcount = allanimeData["episodesCount"];
        var anime = Anime(
          ids: ids,
          title: AnimeTitle(english: allanimeData["name"]),
          episodeCount: epcount,
          media: AnimeMedia(
              banner: allanimeData["banner"],
              cover: AnimeCover(normal: allanime["thumbnail"])),
        );
        animelist.add(anime);
      }
    }
  }
  return animelist;
}

// Function to fetch anime information
Future<Anime> fetchInfo(Anime anime) async {
  final malId = anime.ids!.mal!;
  final anilistId = anime.ids!.anilist;

  // ignore: prefer_typing_uninitialized_variables
  var anilistData;
  if (anilistId != null) {
    anilistData = await anilistFetch(anilistId);
  }
  final malData = await jikanFetch(malId);

  // Titles
  final title = AnimeTitle(
    normal: malData["title"],
    english: anilistData?["title"]["english"] ?? malData["title_english"],
    native: anilistData?["title"]["native"] ?? malData["title_japanese"],
    romaji: anilistData?["title"]["romaji"] ?? "",
    synonyms: (anilistData?["synonyms"] ?? malData["title_synonyms"])
        .map<String>((dynamic synonym) => synonym.toString())
        .toList(),
  );
  // Cover
  final thumbnail = AnimeThumbnail(
    normal: malData["trailer"]["images"]["image_url"] ?? "",
    small: malData["trailer"]["images"]["small_image_url"] ?? "",
    medium: malData["trailer"]["images"]["medium_image_url"] ?? "",
    large: malData["trailer"]["images"]["marge_image_url"] ?? "",
    max: malData["trailer"]["images"]["maximum_image_url"] ?? "",
  );
  final trailer = AnimeTrailer(
      youtubeId: malData["trailer"]["youtube_id"] ?? "",
      url: malData["trailer"]["url"] ?? "",
      embed: malData["trailer"]["embed_url"] ?? "",
      thumbnail: thumbnail);
  final cover = AnimeCover(
      normal: malData["images"]["webp"]["image_url"],
      small: malData["images"]["webp"]["small_image_url"],
      large: malData["images"]["webp"]["large_image_url"],
      extraLarge: anilistData?["coverImage"]["extraLarge"] ?? "",
      color: anilistData?["coverImage"]["color"] ?? "");
  final media = AnimeMedia(
    banner: anime.media!.banner,
    cover: cover,
    trailer: trailer,
  );
  // Synopsis
  final synopsis = malData["synopsis"] == ""
      ? anilistData["description"]
      : malData["synopsis"];
  final score = malData["score"];
  final popularity = malData["popularity"];
  final duration = anilistData?["duration"] ??
      int.parse(RegExp(r"(\d+)").firstMatch(malData["duration"])?[0] ?? "0");
  final genres = (malData["genres"])
      .map<String>((element) => element["name"].toString())
      .toList();
  List<AnimeTag> tags = [];
  if (anilistData != null) {
    for (var tag in anilistData?["tags"]) {
      tags.add(AnimeTag.fromJson(tag));
    }
  }
  final theme = AnimeTheme.fromJson(malData["theme"]);
  final type = malData["type"];
  final status = malData["status"];
  final source = anilistData?["source"] ?? "none";
  final start = DateTime(
      malData["aired"]["prop"]["from"]["year"],
      malData["aired"]["prop"]["from"]["month"],
      malData["aired"]["prop"]["from"]["day"]);
  final end = DateTime(
      malData["aired"]["prop"]["to"]["year"] ?? 0,
      malData["aired"]["prop"]["to"]["month"] ?? 0,
      malData["aired"]["prop"]["to"]["day"] ?? 0);
  final airing = AnimeAiring(start: start, end: end);
  final season = malData["season"];
  final List<AnimeRelation> relations = [];
  for (var relation in malData["relations"]) {
    final rel = AnimeRelation.fromJson(relation);
    relations.add(rel);
  }
  final nextAiring = AnimeNextAiring(
      airingAt: DateTime.fromMillisecondsSinceEpoch(
          anilistData?["nextAiringEpisode"]?["airingAt"] ?? 0 * 1000),
      episode: anilistData?["nextAiringEpisode"]?["episode"] ?? 0);

  return Anime(
    ids: anime.ids,
    title: title,
    episodeCount: anime.episodeCount,
    media: media,
    description: synopsis,
    score: score,
    popularity: popularity,
    duration: duration,
    genres: genres,
    tags: tags,
    theme: theme,
    type: type,
    status: status,
    source: source,
    airingEvent: airing,
    season: season,
    relations: relations,
    nextAiring: nextAiring,
  );
}

// Function to toggle mode
void toggleMode() {
  mode = (mode == "sub") ? "dub" : "sub";
}

// Private GraphQL query for anime search
const String _searchGql = r'''
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
            edges {
                _id
                malId
                aniListId
                name
                availableEpisodes
                banner
                thumbnail
                episodeCount
                rating
                score
                status
                genres
                tags
                __typename
            }
        }
    }
    ''';

Future<List> episodesList(String id) async {
  String episodesListGql = r'''
        query ($showId: String!) {
            show(
                _id: $showId
            ) {
                _id
                availableEpisodesDetail
            }
        }
    ''';
  final payload = {
    "variables": {"showId": id},
    "query": episodesListGql
  };

  final headers = {
    "User-Agent": agent,
    "Referer": allAnimeBase,
    'Content-Type': 'application/json',
  };

  final resp = await http.post(Uri.parse("$allAnimeApi/api"),
      headers: headers, body: jsonEncode(payload));
  Map<String, dynamic> respData = jsonDecode(resp.body);

  var episodes = [];
  if (respData.keys.contains("data") &&
      respData["data"]!.keys.contains("show")) {
    final availableEps = respData["data"]!["show"]["availableEpisodesDetail"];
    episodes = availableEps[mode];
    episodes.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  }
  return episodes;
}

Future<Map> getSourcesUrl(String id, int ep) async {
  String episodeEmbedGql = '''
        query (\$showId: String!, \$translationType: VaildTranslationTypeEnumType!, \$episodeString: String!) {
            episode(
                showId: \$showId
                translationType: \$translationType
                episodeString: \$episodeString
            ) {
                episodeString
                sourceUrls
            }
        }
    ''';
  final payload = {
    "query": episodeEmbedGql,
    "variables": {"showId": id, "translationType": mode, "episodeString": "$ep"}
  };

  final headers = {"User-Agent": agent, "Content-Type": "application/json"};

  final resp = await http.post(Uri.parse("$allAnimeApi/api"),
      headers: headers, body: jsonEncode(payload));

  final respData = jsonDecode(resp.body);

  var sources = {};
  if (respData.keys.contains("data") &&
      respData["data"].keys.contains("episode")) {
    for (var episode in respData["data"]["episode"]["sourceUrls"]) {
      var url = episode["sourceUrl"];
      if (url.startsWith("--")) {
        url = url.replaceAll("--", "");
        url = decryptAllanime(url);
        url = url.replaceAll("clock", "clock.json");
        url = "https://embed.ssbcontent.site$url";
        sources[episode["sourceName"]] = {
          "url": url,
          "priority": episode["priority"],
        };
      }
    }
  }
  if (sources.isEmpty) {
    if (kDebugMode) {
      print("Episode not released!");
    }
    exit(0);
  }
  return sources;
}

Future<List> fetchLinks(sources) async {
  var links = [];
  for (var source in sources.keys) {
    source = sources[source];
    try {
      final resp = jsonDecode((await http.get(Uri.parse(source["url"]))).body);
      if (resp.keys.contains("links")) {
        for (var entry in resp["links"]) {
          final link = entry["link"];
          if (link.contains("anicdnstream") ||
              link.contains("vipanicdn") ||
              link.contains("dropbox")) {
            links.add(link);
            if (entry.keys.contains("src")) {
              links.add(entry["src"]);
            }
          }
        }
      }
    } catch (e) {
      continue;
    }
  }
  return links;
}

Future<String> play(String id, int ep, String mode) async {
  print("loading link");
  var sources = {};
  try {
    print("trying to get sources");
    sources = await getSourcesUrl(id, ep);
  } catch (e) {
    var timeout = 5;
    if (kDebugMode) {
      print("no reponse when fetching sources");
    }
    if (kDebugMode) {
      print("timeout for ${timeout}s before retrying");
    }
    Timer(Duration(seconds: timeout), () async {
      sources = await getSourcesUrl(id, ep);
    });
  }
  final linksList = await fetchLinks(sources);
  print(linksList);
  final link = linksList.first;
  print("got link");
  print(link);
  return link;
}
