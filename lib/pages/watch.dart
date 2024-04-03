import 'package:aniwatch/anifetch.dart';
import 'package:aniwatch/aniskip.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class Watchpage extends StatefulWidget {
  const Watchpage({super.key});

  @override
  State<Watchpage> createState() => _WatchpageState();
}

class _WatchpageState extends State<Watchpage> {
  late final player = Player();
  late final controller = VideoController(player);
  late final link;
  late List skiptimes;

  @override
  void initState() {
    super.initState();
  }

  _initialisation() async {
    var data = ModalRoute.of(context)!.settings.arguments as List;
    link = await play(data[0], data[1], data[2]);
    print("link loaded");
    skiptimes = await getSkipTimes(data.last, data[1]);
    player.open(Media(link));
    player.stream.position.listen((position) {
      var opstart = skiptimes[0];
      var opend = skiptimes[1];
      var edstart = skiptimes[2];
      var edend = skiptimes[3];
      if (position.inSeconds >= opstart && position.inSeconds <= opend-1) {
        player.seek(Duration(seconds: opend.round()));
      }
      if (position.inSeconds >= edstart && position.inSeconds <= edend-1) {
        player.seek(Duration(seconds: edend.round()));
      }
      if (position.inSeconds >= edend-10) {
        link = play(data[0], data[1]+1, data[2]);
        player.add(Media(link));
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initialisation();
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 9.0 / 16.0,
          child: Video(controller: controller),
        ),
      ),
    );
  }
}
