import 'package:aniwatch/routes.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniWatch',
      routes: appRoutes,
      initialRoute: "/",
    );
  }
}