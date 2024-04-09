import 'dart:convert';

// ignore: depend_on_referenced_packages
// import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

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
  // if (kDebugMode) {
  //   print(res.body);
  // }
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
  // if (kDebugMode) {
  //   print(res.body);
  // }
  return jsonDecode(res.body)["data"]["Media"];
}

Future<Map> jikanFetch(int id) async {
  final res = await http.get(
      Uri.parse("https://api.jikan.moe/v4/anime/$id/full"),
      headers: {"ContentType": "application/json"});
  if (kDebugMode) {
    print(res.body);
  }
  return jsonDecode(res.body.replaceAll("\\/", "/"))["data"];
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
  // searchTerm = searchTerm.replaceAll(" ", "+");
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
  // if (kDebugMode) {
  //   print(res.body.replaceAll("\\/", "/"));
  // }
  return jsonDecode(res.body.replaceAll("\\/", "/"));
}

// void main() async {
//   await jikanFetch(30276);
// }
