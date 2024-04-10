import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:android_package_installer/android_package_installer.dart';

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
  if (currentversion != version) {
    if (kDebugMode) {
      print("no updates available");
    }
    return "no updates available";
  } else {
    // ignore: prefer_typing_uninitialized_variables
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
    int? statusCode = await AndroidPackageInstaller.installApk(
        apkFilePath: apkPath);
    if (statusCode != null) {
      PackageInstallerStatus installationStatus =
          PackageInstallerStatus.byCode(statusCode);
      print(installationStatus.name);
    }
    return "Updated successfully";
  }
}
