import 'package:aniwatch/classes/anime_progress.dart';
import 'package:aniwatch/widgets/anime_resume.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<EpisodeProgress> watchlist = [];
  final userProgress = UserAnimeProgress();
  @override
  Widget build(BuildContext context) {
    setState(() {
      watchlist = userProgress.getWatchList() ?? [];
    });
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/search'),
            icon: const Icon(CupertinoIcons.search),
          ),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * .1,
        ),
        if (watchlist.isNotEmpty)
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text("Continue Watching: "),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: watchlist.map((anime) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimeResumeWiget(data: anime),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          )
      ]),
    );
  }
}
