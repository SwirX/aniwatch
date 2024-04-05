import 'package:aniwatch/services/anifetch.dart';
import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/widgets/episode_tile.dart';
import 'package:flutter/material.dart';

class Animepage extends StatefulWidget {
  const Animepage({super.key});

  @override
  State<Animepage> createState() => _AnimepageState();
}

class _AnimepageState extends State<Animepage> {
  @override
  Widget build(BuildContext context) {
    final anime = ModalRoute.of(context)?.settings.arguments as Anime;
    final name = anime.name;
    final id = anime.allanime_id;
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: FutureBuilder(
        future: episodesList(id),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(itemCount: snapshot.data!.length,itemBuilder: ((context, index) {
              return EpisodeTile(anime: anime, ep: int.parse(snapshot.data![index]));
            }));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }),
      ),
    );
  }
}
