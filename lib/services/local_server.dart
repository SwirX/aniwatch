import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';

class AniListAuthScreen extends StatefulWidget {
  @override
  _AniListAuthScreenState createState() => _AniListAuthScreenState();
}

class _AniListAuthScreenState extends State<AniListAuthScreen> {
  final String clientId = '17986';
  final String clientSecret = 'Bq3hgUexx5R4FbGXpf1jwpCTDEqNIbQtqmUPry2X';
  final String redirectUri = 'http://localhost:3000/auth';

  late final http.Client _httpClient;
  late final HttpServer _server;
  late final StreamSubscription _serverSub;

  _setup() async {
    _httpClient = http.Client();
    _server = await HttpServer.bind('localhost', 3000);
    _serverSub = _server.listen((request) async {
      if (request.uri.path == '/auth') {
        final authCode = request.uri.queryParameters['code'];
        if (authCode != null) {
          final accessToken = await exchangeAuthCodeForAccessToken(authCode);
          //TODO: Send accessToken back to Flutter app
          request.response.write('Authorization successful!');
        } else {
          request.response.write('Invalid authorization code!');
        }
      } else {
        request.response.write('Invalid endpoint!');
      }
      await request.response.close();
    });
  }

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    _httpClient.close();
    _server.close();
    _serverSub.cancel();
    super.dispose();
  }

  Future<String> exchangeAuthCodeForAccessToken(String authCode) async {
    final String tokenUrl =
        'https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code';
    final http.Response response = await _httpClient.post(
      Uri.parse(tokenUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'code': authCode,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String accessToken = responseData['access_token'];
      print(accessToken);
      return accessToken;
    } else {
      throw Exception(
          'Failed to get access token: ${response.statusCode}\n${response.body}');
    }
  }

  Future<void> authenticate() async {
    final String authorizationUrl =
        'https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code';

    launchUrlString(authorizationUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AniList Authorization'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: authenticate,
          child: Text('Authorize with AniList'),
        ),
      ),
    );
  }
}
