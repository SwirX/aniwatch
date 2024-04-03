import 'package:aniwatch/anifetch.dart';
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
  late final prev_link;
  late final next_link;

  @override
  void initState() {
    super.initState();
  }

  _initialisation() async {
    var data = ModalRoute.of(context)!.settings.arguments as List;
    link = await play(data[0], data[1], data[2]);
    print("link loaded");
    player.open(
      Media(link)
    );
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
