import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:aniwatch/classes/skiptimes.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

String cleanString(String s) {
  s = s.replaceAll("%20", " ");
  s = s.replaceAll(RegExp(r'[^\x20-\x7E]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ');

  return s;
}

List<double> buildOptions(String skipType, Map<String, dynamic> skipMetadata) {
  double start = 0;
  double end = 0;
  List<dynamic> results = skipMetadata["results"];

  for (dynamic result in results) {
    if (result["skip_type"] == skipType) {
      start = result["interval"]["start_time"].round();
      end = result["interval"]["end_time"].round();
    }
  }

  return [start, end];
}

Future<int> fetchMalId(String term) async {
  String query = term.replaceAll(' ', '%20');
  Map<String, String> params = {
    'type': 'anime',
    'keyword': query,
  };

  Uri url = Uri.parse('https://myanimelist.net/search/prefix.json')
      .replace(queryParameters: params);
  http.Response response = await http.get(url);

  Map<String, dynamic> metadata =
      jsonDecode(response.body.replaceAll(r'\', ''));

  String name = cleanString(query);
  int? id;
  for (dynamic result in metadata['categories'][0]['items']) {
    if (kDebugMode) {
      print(result);
    }
    if (result['name'] == name) {
      id = result['id'];
      break;
    }
  }

  return id ?? -1;
}

Future<SkipTimes?> getSkipTimes(String title, int ep) async {
  String agent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3';

  int malId = await fetchMalId(title);
  Map<String, dynamic> skipMd = {};
  try {
    final response = await http.get(
      Uri.parse(
          'https://api.aniskip.com/v1/skip-times/$malId/$ep?types=op&types=ed'),
      headers: {
        'User-Agent': agent,
      },
    );
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      skipMd = json.decode(response.body);
      if (!skipMd.keys.contains("found")) {
        if (kDebugMode) {
          print("Skip times not found!");
        }
        return null;
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("An error occurred while fetching skip times: $e");
    }
    return null;
  }

  List<double> op = buildOptions("op", skipMd);
  List<double> ed = buildOptions("ed", skipMd);
  double eplen = skipMd["results"][0]["episode_length"];

  return SkipTimes(op: Opening(start: op[0], end: op[1]), ed: Ending(start: ed[0], end: ed[1]), epLength: eplen);
}
