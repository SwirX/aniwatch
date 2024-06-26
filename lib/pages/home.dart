import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/classes/anime_progress.dart';
import 'package:aniwatch/providers/allanime.dart';
import 'package:aniwatch/services/anilookup.dart';
import 'package:aniwatch/widgets/anime_resume.dart';
import 'package:aniwatch/widgets/home_popular.dart';
import 'package:aniwatch/widgets/home_recommendation.dart';
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
  final allanime = AllAnime();

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
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/anilist'),
            icon: const Icon(CupertinoIcons.person_solid),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: double.maxFinite,
          width: double.maxFinite,
          child: Column(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .25,
            ),
            if (watchlist.isNotEmpty)
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text("Continue Watching: "),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: watchlist.map((anime) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AnimeResumeWiget(data: anime),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            FutureBuilder(
              future: allanime.getPopular(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Popular: "),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: data.map((animedata) {
                                  return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: HomePopular(result: animedata));
                                }).toList(),
                              )),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            FutureBuilder(
              future: allanime.getLatestUpdate(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Last Updated: "),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: data.map((animedata) {
                                  return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          HomeLastUpdated(result: animedata));
                                }).toList(),
                              )),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          ]),
        ),
      ),
    );
  }
}
