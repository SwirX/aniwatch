import 'dart:convert';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart' as o_file;

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
    print("no updates available");
    return "no updates available";
  } else {
    var apkurl;
    for (var asset in assets) {
      if (asset["content_type"] == "application/vnd.android.package-archive") {
        apkurl = asset["browser_download_url"];
      }
    }
    final apkPath = "/sdcard/Download/aniwatch-$version.apk";
    res = await http.get(Uri.parse(apkurl));
    final bytes = res.bodyBytes;
    final file = await File(apkPath).create();
    await file.writeAsBytes(bytes);
    o_file.OpenFile.open(apkPath);
    return "Updated successfully";
  }
}