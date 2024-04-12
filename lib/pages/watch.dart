import 'package:aniwatch/classes/anime_progress.dart';
import 'package:aniwatch/classes/skiptimes.dart';
import 'package:aniwatch/services/anifetch.dart';
import 'package:aniwatch/services/aniskip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WatchPageState createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  final userProgress = UserAnimeProgress();

  late final VideoController controller;
  late final Player player;

  String multiBtnText = "Skip Intro";
  bool multiBtnVisible = false;
  bool linkfetched = false;
  bool seeked = false;
  late SkipTimes skipTimes;
  String link = "";
  String oldlink = "";
  // ignore: prefer_typing_uninitialized_variables
  late final data;
  late int episode;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    player.pause();

    player.stream.position.listen((position) async {
      var opstart = skipTimes.op.start;
      var opend = skipTimes.op.end;
      var edstart = skipTimes.ed.start;
      var edend = skipTimes.ed.end;

      setState(() {});
      if (position.inSeconds >= opstart && position.inSeconds <= opend - 1) {
        setState(() {
          multiBtnText = "Skip Intro";
          multiBtnVisible = true;
        });
      } else if (position.inSeconds != 0 &&
          position.inSeconds >= edstart &&
          position.inSeconds <= edend - 1) {
      } else if (position.inSeconds != 0 &&
          position.inSeconds >= edstart - 10) {
        setState(() {
          multiBtnText = "Next Episode";
          multiBtnVisible = true;
        });
      } else if (position.inSeconds >= edstart - 30 && !linkfetched) {
        oldlink = link;
        link = await play(data[0].ids!.allanime, data[1] + 1, data[2]!);
      } else {
        setState(() {
          multiBtnText = "";
          multiBtnVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    player.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initialize();
  }

  void initialize() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (link.isEmpty) {
      data = ModalRoute.of(context)!.settings.arguments as List;
      episode = data[1];
      link = data[3] ?? await play(data[0].ids!.allanime!, data[1], "sub");
      oldlink = link;
      if (kDebugMode) {
        print("link loaded");
      }
      skipTimes = (await getSkipTimes(data[0].ids!.mal!, data[1]))!;
      player.open(Media(link));
    }
    // player.stream.buffering.listen((event) {
    //   if (!event && !seeked) {
    //     player.seek(data[2]);
    //     setState(() {
    //       seeked = true;
    //     });
    //     print("seeked");
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final videoTheme = MaterialVideoControlsThemeData(
      volumeGesture: true,
      brightnessGesture: true,
      seekBarThumbColor: const Color(0xff0000ff),
      seekBarPositionColor: const Color(0xff0000ff),
      seekBarHeight: 5,
      seekBarMargin: const EdgeInsets.all(8),
      primaryButtonBar: const [
        Spacer(),
        MaterialPlayOrPauseButton(iconSize: 48.0),
        Spacer(),
      ],
      bottomButtonBar: [],
      topButtonBar: [
        MaterialDesktopCustomButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.chevron_back)),
        const Spacer(),
      ],
    );
    return PopScope(
      onPopInvoked: (didPop) {
        userProgress.saveProgress(
          animeIds: data[0].ids!,
          animeName: data[0].title!.english,
          episodeUrl: oldlink,
          progress: player.state.position,
          episodeNumber: episode,
          watched: false,
        );
        return;
      },
      child: MaterialVideoControlsTheme(
        normal: videoTheme,
        fullscreen: videoTheme,
        child: Scaffold(
          body: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                  child: Video(
                    controller: controller,
                  ),
                ),
              ),
              if (multiBtnVisible)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 64, 32),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (multiBtnText == "Skip Intro") {
                          player.seek(
                              Duration(seconds: skipTimes.op.end.round()));
                          player.play();
                        }
                        if (multiBtnText == "Next Episode") {
                          userProgress.saveProgress(
                            animeIds: data[0].ids!,
                            animeName: data[0].title!.english,
                            episodeUrl: oldlink,
                            progress: player.state.position,
                            episodeNumber: episode,
                            watched: true,
                          );
                          if (kDebugMode) {
                            print(" \n \n \n \n \n \n \n \n \n");
                            print("saving the progress");
                            print(" \n \n \n \n \n \n \n \n \n");
                          }
                          episode++;
                          player.open(Media(link));
                          skipTimes =
                              (await getSkipTimes(data[0].ids!.mal, data[1]))!;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          multiBtnText,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
