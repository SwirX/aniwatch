import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AniListAuthScreen extends StatefulWidget {
  @override
  _AniListAuthScreenState createState() => _AniListAuthScreenState();
}

class _AniListAuthScreenState extends State<AniListAuthScreen> {
  final String clientId = '17986';
  final String clientSecret = 'Bq3hgUexx5R4FbGXpf1jwpCTDEqNIbQtqmUPry2X';
  final String redirectUri = 'http://localhost:3000/auth';

  Future<void> authenticate() async {
    final String authorizationUrl =
        'https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code';
    // Redirect user for authorization
    // Launch the authorization URL in a webview or open it in an external browser
    // Example: launch authorizationUrl in webview

    // After user approves, handle the redirect URI to get the authorization code
    // This can be done by listening to the URL changes in your app

    // Once you get the authorization code, exchange it for an access token
    // You can use a package like `flutter_web_auth` for handling the redirection and getting the code

    // After getting the code, exchange it for an access token
    final String code = '{authorization_code}';
    final String tokenUrl = 'https://anilist.co/api/v2/oauth/token';
    final http.Response response = await http.post(
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
        'code': code,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String accessToken = responseData['access_token'];
      // Now you have the access token, you can use it to make authenticated requests to AniList's API
      print('Access Token: $accessToken');
    } else {
      print('Failed to get access token: ${response.statusCode}');
    }
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
