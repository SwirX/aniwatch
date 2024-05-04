import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

const endpoint = "https://api.github.com/repos/SwirX/aniwatch/releases";

Future<String?> checkForUpdates() async {
  var res = await http.get(Uri.parse(endpoint));
  if (res.statusCode != 200) {
    return "Couldn't update";
  }
  final releaselink = jsonDecode(res.body).first["url"];
  res = await http.get(Uri.parse(releaselink));
  if (res.statusCode != 200) {
    return "Couldn't update";
  }
  final response = jsonDecode(res.body);
  final assets = response["assets"];
  final version = response["tag_name"];
  final currentversion = (await PackageInfo.fromPlatform()).version;
  if (currentversion == version) {
    if (kDebugMode) {
      print("no updates available");
    }
    return "no updates available";
  } else {
    if (kDebugMode) {
      print("fetching update link");
    }
    // ignore: prefer_typing_uninitialized_variables
    var apkurl;
    for (var asset in assets) {
      if (asset["content_type"] == "application/vnd.android.package-archive") {
        apkurl = asset["browser_download_url"];
      }
    }
    launchUrlString(apkurl);
    return "launched";
    // final apkPath = "/sdcard/Download/aniwatch-$version.apk";
    // res = await http.get(Uri.parse(apkurl));
    // final bytes = res.bodyBytes;
    // if (kDebugMode) {
    //   print("update downloaded");
    //   print("saving the file");
    // }
    // final file = await File(apkPath).create();
    // await file.writeAsBytes(bytes);

    // if (kDebugMode) {
    //   print("returning the path");
    // }
    // return apkPath;
  }
}
