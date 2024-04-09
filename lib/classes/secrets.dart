import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class Secret {
  final String apiKey;
  final String userToken;
  Secret({this.apiKey = "", this.userToken = ""});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return Secret(apiKey: jsonMap["clientid"], userToken: jsonMap["usertoken"]);
  }
}

class SecretLoader {
  final String? secretPath;
  SecretLoader({this.secretPath});
  Future<Secret> load() {
    return rootBundle.loadStructuredData<Secret>(
      secretPath!,
      (jsonStr) async {
        final secret = Secret.fromJson(json.decode(jsonStr));
        return secret;
      },
    );
  }
}
