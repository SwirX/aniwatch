import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const agent =
    "Mozilla/5.0 (Windows NT 6.1; Win64; rv:109.0) Gecko/20100101 Firefox/109.0";
const allanime_base = "https://allanime.to";
const allanime_api = "https://api.allanime.day";
var mode = "sub";
var quality = "best";
var download_dir = ".";
var aniCliNonInteractive = false;
var version_number = "4.6.1";
var histfile = "ani-hsts";

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

Future<List<Map<String, dynamic>>> searchAnime(String query) async {
  String searchGql = '''
    query(
        \$search: SearchInput
        \$limit: Int
        \$page: Int
        \$translationType: VaildTranslationTypeEnumType
        \$countryOrigin: VaildCountryOriginEnumType
    ) {
        shows(
            search: \$search
            limit: \$limit
            page: \$page
            translationType: \$translationType
            countryOrigin: \$countryOrigin
        ) {
            edges {
                _id
                name
                availableEpisodes
                __typename
            }
        }
    }
    ''';

  final headers = {
    'User-Agent': agent,
    'Referer': allanime_base,
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

  final url = Uri.parse('$allanime_api/api').replace(queryParameters: params);

  final response = await http.get(url, headers: headers);

  List<Map<String, dynamic>> animeList = [];
  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData.containsKey('data') &&
        responseData['data'].containsKey('shows')) {
      for (final edge in responseData['data']['shows']['edges']) {
        final animeId = edge['_id'];
        final animeName = edge['name'];
        final availableEpisodes = edge['availableEpisodes'];
        animeList.add({
          'id': animeId,
          'name': animeName,
          'availableEpisodes': availableEpisodes,
        });
      }
    }
  }
  return animeList;
}

Future<List> episodesList(String id) async {
  String episodes_list_gql = '''
        query (\$showId: String!) {
            show(
                _id: \$showId
            ) {
                _id
                availableEpisodesDetail
            }
        }
    ''';
  final payload = {
    "variables": {"showId": id},
    "query": episodes_list_gql
  };

  final headers = {
    "User-Agent": agent,
    "Referer": allanime_base,
    'Content-Type': 'application/json',
  };

  final resp = await http.post(Uri.parse("$allanime_api/api"),
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

  final resp = await http.post(Uri.parse("$allanime_api/api"),
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
    print("Episode not released!");
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

Future<String> play(String anime, int ep, String mode) async {
  final search_res = await searchAnime(anime);
  final id = search_res.first["id"];
  var sources = {};
  try {
    sources = await getSourcesUrl(id, ep);
  } catch (e) {
    var timeout = 5;
    print("no reponse when fetching sources");
    print("timeout for ${timeout}s before retrying");
    Timer(Duration(seconds: timeout), () async {
      sources = await getSourcesUrl(id, ep);
    });
  }
  final links_list = await fetchLinks(sources);
  final link = links_list.first;
  return link;
}

void toggleMode() {
  if (mode == "sub") {
    mode = "dub";
  } else {
    mode = "sub";
  }
}