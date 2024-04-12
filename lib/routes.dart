import 'package:aniwatch/pages/home.dart';
import 'package:aniwatch/pages/search.dart';
import 'package:aniwatch/pages/watch.dart';

var appRoutes = {
  "/": (context) => const Homepage(),
  "/search": (context) => const Searchpage(),
  "/watch": (content) => const WatchPage(),
};
