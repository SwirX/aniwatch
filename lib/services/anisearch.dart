import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const oauthUrl = "https://anilist.co/api/v2/oauth/authorize?";

Future<Map> getMediaFromSearch(String searchTerm) async {
  var query = r"""
query ($title: String)  {
    Media(search: $title, type: ANIME){
        id
        idMal
        title {
        english
        romaji
        native
      }
        episodes
        chapters
        season
        description
        startDate {
          year
          month
          day
        }
        endDate {
          year
          month
          day
        }
        duration
        status
        popularity
        averageScore
        meanScore
        source
        isAdult
        bannerImage
        trailer {
          id
          site
          thumbnail
        }
        synonyms
        popularity
        nextAiringEpisode {
          airingAt
          timeUntilAiring
          episode
        }
        genres
        tags {
          name
          category
          rank
        }
        coverImage {
          extraLarge
          large
          medium
          color
            }

    }
}
""";
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  var variables = {
    "title": searchTerm,
  };
  var url = "https://graphql.anilist.co";

  final res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(
      {
        "query": query,
        "variables": variables,
      },
    ),
  );
  if (kDebugMode) {
    print(res.body);
  }
  return jsonDecode(res.body);
}

Future<Map<String, dynamic>> anilistFetch(int id) async {
  var query = r"""
query ($id: Int)  {
    Media(id: $id, type: ANIME){
        id
        idMal
        title {
        english
        romaji
        native
      }
        duration
        averageScore
        source
        isAdult
        synonyms
        nextAiringEpisode {
          mediaId
          episode
          airingAt
      }
        genres
        tags {
          name
          category
          rank
        }
        coverImage {
          extraLarge
          color
        }

    }
}
""";
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  var variables = {
    "id": id,
  };
  var url = "https://graphql.anilist.co";

  final res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(
      {
        "query": query,
        "variables": variables,
      },
    ),
  );
  if (kDebugMode) {
    print(res.body);
  }
  return jsonDecode(res.body)["data"]["Media"];
}

Future<Map<String, dynamic>> jikanFetch(int id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheKey = 'jikan_$id';

  // Check if data is cached
  if (prefs.containsKey(cacheKey)) {
    print("loading from cache");
    final String cachedData = prefs.getString(cacheKey)!;
    return jsonDecode(cachedData)["data"];
  }

  // If not cached, fetch data from API
  final Map<String, dynamic> responseData = jsonDecode((await http.get(
    Uri.parse("https://api.jikan.moe/v4/anime/$id/full"),
    headers: {"ContentType": "application/json"},
  ))
      .body);

  // Cache the fetched data
  prefs.setString(cacheKey, jsonEncode(responseData));

  return responseData["data"];
}

Future<Map<String, dynamic>> jikanAnimeImageFetch(int id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheKey = 'anime_$id';

  // Check if data is cached
  if (prefs.containsKey(cacheKey)) {
    final String cachedData = prefs.getString(cacheKey)!;
    return jsonDecode(cachedData);
  }

  // If not cached, fetch data from API
  final Map<String, dynamic> responseData = await _fetchData(id, "anime");

  // Cache the fetched data
  prefs.setString(cacheKey, jsonEncode(responseData));

  return responseData;
}

Future<Map<String, dynamic>> jikanMangaImageFetch(int id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheKey = 'manga_$id';

  // Check if data is cached
  if (prefs.containsKey(cacheKey)) {
    final String cachedData = prefs.getString(cacheKey)!;
    return jsonDecode(cachedData);
  }

  // If not cached, fetch data from API
  final Map<String, dynamic> responseData = await _fetchData(id, "manga");

  // Cache the fetched data
  prefs.setString(cacheKey, jsonEncode(responseData));

  return responseData;
}

Future<Map<String, dynamic>> _fetchData(int id, String type) async {
  int maxRetries = 3;
  int currentRetry = 0;

  while (currentRetry < maxRetries) {
    var res = await http.get(
      Uri.parse("https://api.jikan.moe/v4/$type/$id/pictures"),
      headers: {"ContentType": "application/json"},
    );

    if (kDebugMode) {
      print(res.body);
    }

    if (res.statusCode == 429) {
      // If rate limited, wait for a moment and then retry
      await Future.delayed(
          const Duration(seconds: 2)); // Adjust delay as needed
      currentRetry++;
    } else {
      // If successful response, parse and return the data
      final resp = jsonDecode(res.body.replaceAll("\\/", "/"));
      return resp;
    }
  }

  // If all retries fail, throw an error or handle it as needed
  throw Exception('Exceeded maximum retries for API request.');
}

Future<List> jikanAnimeRecomandationFetch(int id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheKey = 'jikan_recomndation_$id';

  // Check if data is cached
  if (prefs.containsKey(cacheKey)) {
    print("loading from cache");
    final String cachedData = prefs.getString(cacheKey)!;
    // print("recommandation: $cachedData");
    return jsonDecode(cachedData)["data"];
  }

  final res = await http.get(
    Uri.parse("https://api.jikan.moe/v4/anime/$id/recommendations"),
    headers: {"ContentType": "application/json"},
  );

  final resp = res.body;
  // print("recommandation: $resp");

  // If not cached, fetch data from API
  final Map<String, dynamic> responseData = jsonDecode(resp);

  // Cache the fetched data
  // print("recommandation: ${jsonEncode(responseData)}");
  prefs.setString(cacheKey, jsonEncode(responseData));

  return responseData["data"];
}

Future<Map<String, dynamic>> jikanAnimeEpisodeFetch(int id, int ep) async {
  int maxRetries = 3;
  int currentRetry = 0;

  while (currentRetry < maxRetries) {
    var res = await http.get(
      Uri.parse("https://api.jikan.moe/v4/anime/$id/episodes/$ep"),
      headers: {"ContentType": "application/json"},
    );

    if (kDebugMode) {
      print(res.body);
    }

    if (res.statusCode == 429) {
      // If rate limited, wait for a moment and then retry
      await Future.delayed(
          const Duration(seconds: 2)); // Adjust delay as needed
      currentRetry++;
    } else {
      // If successful response, parse and return the data
      final resp = jsonDecode(res.body.replaceAll("\\/", "/"));
      return resp;
    }
  }

  // If all retries fail, throw an error or handle it as needed
  throw Exception('Exceeded maximum retries for API request.');
}


Future<List> jikanAnimeEpisodesFetch(int id, int eps) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheKey = 'episodesInfo_$id';

  // Check if data is cached
  if (prefs.containsKey(cacheKey)) {
    final String cachedData = prefs.getString(cacheKey)!;
    return jsonDecode(cachedData);
  }

  List<Map<String, dynamic>> episodesInfo = [];

  for (var i = 0; i < eps; i++) {
    final info = await jikanAnimeEpisodeFetch(id, i+1);
    episodesInfo.add(info);
  }

  // Cache the fetched data
  prefs.setString(cacheKey, jsonEncode(episodesInfo));

  return episodesInfo;
}

Future<Map> animeSearch(String searchTerm) async {
  var query = r"""
query ($id: Int, $page: Int, $perPage: Int, $search: String) {
  Page (page: $page, perPage: $perPage) {
    pageInfo {
      total
      currentPage
      lastPage
      hasNextPage
      perPage
    }
    media (id: $id, search: $search) {
      id
      title {
        english
        romaji
        native
      }
      averageScore
      episodes
      bannerImage
      coverImage {
          extraLarge
          medium
          color
            }
    }
  }
}
""";
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  var variables = {"search": searchTerm, "page": 1, "perPage": 50};
  var url = "https://graphql.anilist.co";

  final res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(
      {
        "query": query,
        "variables": variables,
      },
    ),
  );
  if (kDebugMode) {
    print(res.body.replaceAll("\\/", "/"));
  }
  return jsonDecode(res.body.replaceAll("\\/", "/"));
}

// void main() async {
//   await jikanImageFetch(30276);
// }