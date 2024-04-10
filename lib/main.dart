import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/pages/anime.dart';
import 'package:aniwatch/routes.dart';
import 'package:aniwatch/services/check_update.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  checkForUpdates();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark(),
        title: 'AniWatch',
        routes: appRoutes,
        initialRoute: "/",
        onGenerateRoute: (settings) {
          if (settings.name == '/anime') {
            final anime = settings.arguments as AnimeSearchResult;
            return MaterialPageRoute(
              builder: (context) => AnimePage(animeSearchResult: anime),
            );
          }
          return null;
        });
  }
}
