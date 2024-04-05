import 'package:aniwatch/classes/history.dart';
import 'package:aniwatch/services/anifetch.dart';
import 'package:aniwatch/services/aniskip.dart';
import 'package:aniwatch/classes/skiptimes.dart';
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
  late SkipTimes skiptimes;
  String multiBtnText = "Skip Intro";
  bool multiBtnVisi = false;
  bool linkfetched = false;

  @override
  void initState() {
    super.initState();
    player.pause();
    player.stream.position.listen(
      (position) async {
        var opstart = skiptimes.op.start;
        var opend = skiptimes.op.end;
        var edstart = skiptimes.ed.start;
        var edend = skiptimes.ed.end;
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
          setState(() {
            multiBtnText = "Next Episode";
            multiBtnVisi = true;
          });
        } else if (position.inSeconds >= edstart - 30 && !linkfetched) {
          link = await play(data[0], data[1] + 1, data[2]);
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
    data = ModalRoute.of(context)!.settings.arguments as List;
    saveEpisodeProgress(data[0], data[1], player.state.position.inSeconds);
    super.dispose();
  }

  void markEpisodeAsWatched(String animeId, int episodeNumber, int lastPosition,
      int episodeLength) async {
    List<Map<String, dynamic>> watchList = await UserHistory.fetch();
    final index = watchList.indexWhere((entry) =>
        entry['anime_id'] == animeId && entry['episode'] == episodeNumber);
    if (index != -1) {
      // Update existing entry
      watchList[index]['progress'] = lastPosition;
      watchList[index]['lenght'] = episodeLength;
    } else {
      // Add new entry
      watchList.add({
        'anime_id': animeId,
        'episode': episodeNumber,
        'progress': lastPosition,
        'lenght': episodeLength,
      });
    }
    await UserHistory.save(watchList);
  }

  void saveEpisodeProgress(String animeId, int episode, int progress) async {
    await UserHistory.saveEpisodeProgress(animeId, episode, progress);
  }

  void saveEpisodeLength(String animeId, int episode, int length) async {
    await UserHistory.saveEpisodeLength(animeId, episode, length);
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
      skiptimes = (await getSkipTimes(data.last, data[1]))!;
      player.open(Media(link));
      saveEpisodeLength(data[0], data[1], skiptimes.epLength.round());
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
                          player.seek(
                              Duration(seconds: skiptimes.op.end.round()));
                          player.play();
                        } else if (multiBtnText == "Next Episode") {
                          markEpisodeAsWatched(
                              data[0],
                              data[1],
                              player.state.position.inSeconds,
                              skiptimes.epLength.round());
                          data[1]++;
                          player.open(Media(link));
                          skiptimes = (await getSkipTimes(data.last, data[1]))!;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16)),
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
