import 'dart:async';
import 'dart:convert';
import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/services/anisearch.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

const String agent =
    "Mozilla/5.0 (Windows NT 6.1; Win64; rv:109.0) Gecko/20100101 Firefox/109.0";
const String allAnimeBase = "https://allanime.to";
const String allAnimeApi = "https://api.allanime.day";
var mode = "sub";

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

Future<List<AnimeSearchResult>> aniSearch(String query) async {
  const searchGql = r'''
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
    'query': searchGql,
  };

  final url = Uri.parse('$allAnimeApi/api').replace(queryParameters: params);

  final searchResponse = await http.get(url, headers: headers);

  List<AnimeSearchResult> animeResults = [];

  if (searchResponse.statusCode == 200) {
    final responseData = jsonDecode(searchResponse.body);
    final results = responseData["data"]["shows"]["edges"];

    for (final result in results) {
      if (result["malId"] == null || result["aniListId"] == null) {
        continue;
      }

      final allanimeId = result["_id"];
      final malId = result["malId"];
      final aniListId = result["aniListId"];
      final name = result["name"];
      final episodes = result["episodeCount"];
      final score = result["score"];
      final primaryGenre = result["genres"].first;
      final cover = result["thumbnail"];
      final banner = result["banner"];

      final resultObject = AnimeSearchResult(
        allanimeId: allanimeId,
        anilistId: int.parse(aniListId ?? "-1"),
        malId: int.parse(malId ?? "-1"),
        episode: int.parse(episodes ?? "0"),
        banner: banner ?? "",
        cover: cover ?? "",
        name: name ?? "",
        genre: primaryGenre ?? "",
        score: double.parse("${score ?? "0"}"),
      );

      animeResults.add(resultObject);
    }
  }

  return animeResults;
}



Future<Anime> aniInfo(AnimeSearchResult animeResult) async {
  final malId = animeResult.malId;
  final aniListId = animeResult.anilistId;

  final malResults = await jikanFetch(malId);
  final aniListResults = await anilistFetch(aniListId);

  final idsObj = AnimeIds(
    allanime: animeResult.allanimeId,
    mal: malId,
    anilist: aniListId,
  );

  final titleMap = aniListResults["title"];
  final titleObj = AnimeTitle(
      english: titleMap?["english"] ?? malResults["title_english"] ?? "",
      romaji: titleMap?["romaji"] ?? malResults["title"] ?? "",
      native: titleMap?["native"] ?? malResults["title_japanese"] ?? "",
      synonyms: List<String>.generate(aniListResults["synonyms"].length,
          (index) => aniListResults["synonyms"][index]));

  final coverMap = aniListResults["coverImage"];
  final coverObj = AnimeCover(
    normal: coverMap["medium"] ?? malResults["images"]["webp"]["image_url"],
    large: coverMap["large"] ?? malResults["images"]["webp"]["large_image_url"],
    extraLarge: coverMap["extraLarge"] ?? "",
    color: coverMap["color"] ?? "",
  );

  final banner = aniListResults["bannerImage"];
  final mediaObj = AnimeMedia(
    cover: coverObj,
    banner: banner ?? animeResult.banner,
  );

  final source = aniListResults["source"] ?? malResults["source"];
  final genres = List<String>.generate(aniListResults["genres"].length,
      (index) => aniListResults["genres"][index]);
  final description = aniListResults["description"];
  if (kDebugMode) {
    print("description: $description");
  }
  final duration = aniListResults["duration"];

  final tagsObj = List<AnimeTag>.generate(
      aniListResults["tags"].length,
      (index) => AnimeTag(
          name: aniListResults["tags"][index]["name"],
          category: aniListResults["tags"][index]["category"],
          rank: aniListResults["tags"][index]["rank"]));

  final smallCoverUrl = malResults["images"]["webp"]["small_image_url"];
  coverObj.small = smallCoverUrl;

  final trailerMap = malResults["trailer"];
  final thumbnailMap = trailerMap["images"];
  final thumbnailObj = AnimeThumbnail(
    normal: thumbnailMap["image_url"],
    small: thumbnailMap["small_image_url"],
    medium: thumbnailMap["medium_image_url"],
    large: thumbnailMap["large_image_url"],
    max: thumbnailMap["maximum_image_url"],
  );
  final trailerObj = AnimeTrailer(
    youtubeId: trailerMap["youtube_id"],
    url: trailerMap["url"],
    embed: trailerMap["embed_url"],
    thumbnail: thumbnailObj,
  );
  mediaObj.trailer = trailerObj;

  final type = malResults["type"];
  final status = malResults["status"];
  final score = double.parse("${malResults["score"]}");
  final popularity = malResults["popularity"];
  final synopsis = malResults["synopsis"];
  final genre2 = List<String>.generate(malResults["genres"].length,
      (index) => malResults["genres"][index]["name"]);
  final duration2 =
      int.parse(RegExp(r"(\d+)").firstMatch(malResults["duration"])![0] ?? "");

  final relationsList = malResults["relations"];
  final simpleRelationsObj = List<AnimeRelation>.generate(relationsList.length,
      (index) => AnimeRelation.fromJson(relationsList[index]));

  final themeMap = malResults["theme"];
  final themeObj = AnimeTheme(
    openings: List<String>.generate(
        themeMap["openings"].length, (index) => themeMap["openings"][index]),
    endings: List<String>.generate(
        themeMap["endings"].length, (index) => themeMap["endings"][index]),
  );

  return Anime(
    ids: idsObj,
    title: titleObj,
    media: mediaObj,
    theme: themeObj,
    relations: simpleRelationsObj,
    source: source,
    genres: genres.isEmpty ? genre2 : genres,
    episodeCount: animeResult.episode,
    description: description ?? synopsis,
    type: type,
    status: status,
    score: score,
    popularity: popularity,
    duration: duration ?? duration2,
    tags: tagsObj,
    season: "",
    airing: malResults["airing"],
  );
}

Future<AnimeReference> aniref(AnimeReference anime) async {
  final malId = anime.id;

  final malResults = await jikanFetch(malId);

  final coverUrl = malResults["images"]["webp"]["large_image_url"];

  return AnimeReference(
      id: malId,
      name: anime.name,
      type: anime.type,
      url: anime.url,
      cover: coverUrl);
}
