import 'package:aniwatch/anifetch.dart';
import 'package:aniwatch/aniskip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String link = "";
  late List data;
  late List<double> skiptimes;
  String multiBtnText = "Skip Intro";
  bool multiBtnVisi = false;

  @override
  void initState() {
    super.initState();
    player.stream.position.listen(
      (position) async {
        var opstart = skiptimes[0];
        var opend = skiptimes[1];
        var edstart = skiptimes[2];
        var edend = skiptimes[3];
        if (position.inSeconds >= opstart && position.inSeconds <= opend - 1) {
          setState(() {
            multiBtnText = "Skip Intro";
            multiBtnVisi = true;
          });
        } else if (position.inSeconds != 0 &&
            position.inSeconds >= edstart &&
            position.inSeconds <= edend - 1) {
        }
        // get the next episode link ready
        else if (position.inSeconds != 0 &&
            position.inSeconds >= edstart - 10) {
              print("\n\n\n\n\n\ngetting the next link ready\n\n\n\n\n\n\n");
          link = await play(data[0], data[1] + 1, data[2]);
          player.add(Media(link));
          setState(() {
            multiBtnText = "Next Episode";
            multiBtnVisi = true;
          });
        } else {
          setState(() {
            multiBtnText = "";
            multiBtnVisi = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    // Unlock the rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    player.dispose();
    super.dispose();
  }

  _initialisation() async {
    // Lock the phone horizontally
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // get the video link
    data = ModalRoute.of(context)!.settings.arguments as List;
    if (link.isEmpty) {
      link = await play(data[0], data[1], data[2]);
      print("link loaded");
      skiptimes = await getSkipTimes(data.last, data[1]);
      player.open(Media(link));
    }
  }

  @override
  Widget build(BuildContext context) {
    // calling init function in build because when put into initState I get errors
    _initialisation();
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 9.0 / 16.0,
              child: Video(controller: controller),
            ),
          ),
          multiBtnVisi
              ? Positioned(
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                      onPressed: () async {
                        if (multiBtnText == "Skip Intro") {
                          print("\n\n\n\n\n\n${skiptimes[1]}\n\n\n\n\n\n\n");
                          player.seek(Duration(seconds: skiptimes[1].round()));
                        } else if (multiBtnText == "Next Episode") {
                          player.next();
                          skiptimes = await getSkipTimes(data.last, data[1]);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              multiBtnText,
                            ),
                          ),
                        ),
                      ),
                    ),
                ),
              )
              : const SizedBox(
                  width: 0,
                  height: 0,
                ),
        ],
      ),
    );
  }
}
