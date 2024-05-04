import 'package:aniwatch/services/local_server.dart';
import 'package:aniwatch/pages/home.dart';
import 'package:aniwatch/pages/search.dart';

var appRoutes = {
  "/": (context) => const Homepage(),
  "/search": (context) => const Searchpage(),
  "/anilist": (context) => AniListAuthScreen(),
};
