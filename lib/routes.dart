import 'package:aniwatch/pages/anime.dart';
import 'package:aniwatch/pages/home.dart';
import 'package:aniwatch/pages/watch.dart';

var appRoutes =  {
  "/": (context) => const Homepage(),
  "/anime": (content) => const Animepage(),
  "/watch": (content) => const Watchpage(),
};