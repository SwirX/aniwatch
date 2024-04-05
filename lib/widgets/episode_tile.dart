import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/classes/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EpisodeTile extends StatefulWidget {
  const EpisodeTile({super.key, required this.anime, required this.ep});

  final Anime anime;
  final int ep;

  @override
  State<EpisodeTile> createState() => _EpisodeTileState();
}

late List<Map<String, dynamic>> watchList;

class _EpisodeTileState extends State<EpisodeTile> {
  void fetchWatchHistoryByAnimeId(String animeId) async {
    watchList = await UserHistory.fetchByAnimeId(animeId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchWatchHistoryByAnimeId(widget.anime.allanime_id);
  }

  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;
    final ep = widget.ep;

    bool isWatched() {
      var res = false;
      if (watchList == []) {
        return res;
      }
      for (var entry in watchList) {
        if (entry.containsKey("episode")) {
          res = entry["episode"] >= ep;
        }
      }
      return res;
    }

    final watched = isWatched();

    return Stack(
      children: [
        ListTile(
          leading: watched
              ? const Icon(CupertinoIcons.eye_fill, color: Color(0xffcdcdcd))
              : const Icon(CupertinoIcons.play_fill),
          title: Text("Episode $ep"),
          tileColor: watched ? Color(0xff555555) : null,
          textColor: watched ? Color(0xffcdcdcd) : null,
          trailing: Icon(
            CupertinoIcons.arrow_down_to_line_alt,
            color: watched ? Color(0xffcdcdcd) : null,
          ),
          style: ListTileStyle.list,
          onTap: () {
            Navigator.pushNamed(context, "/watch",
                arguments: [anime.allanime_id, ep, anime.mode, anime.name]);
          },
        ),
        anime.lastWatched == ep
            ? Positioned(
                bottom: 0,
                child: Container(
                  width: (anime.lastTimestamp ??
                          0 / anime.episodes[ep - 1]["length"]) *
                      MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.red[700],
                  ),
                ),
              )
            : const SizedBox(
                width: 0,
                height: 0,
              ),
      ],
    );
  }
}
