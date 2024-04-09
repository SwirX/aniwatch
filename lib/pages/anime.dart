import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/sevices/anilookup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimePage extends StatefulWidget {
  final AnimeSearchResult animeSearchResult;

  const AnimePage({super.key, required this.animeSearchResult});

  @override
  State<AnimePage> createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  Anime? animeData;
  bool showAllTags = false;
  bool coverVisible = true;
  bool isDescriptionExpanded = false;
  Color? ambiantColor;

  fetchdata() async {
    final anime = await aniInfo(widget.animeSearchResult);
    setState(() {
      animeData = anime;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Color _hexToColor(String hexColor) {
    if (hexColor == "") {
      return const Color(0xffcdcdcd);
    }
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.substring(1);
    }
    int colorValue = int.parse(hexColor, radix: 16);
    return Color(colorValue).withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (animeData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    var colorString = animeData!.media!.cover!.color!.substring(1);
    ambiantColor = _hexToColor(colorString);
    setState(() {});
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            surfaceTintColor: ambiantColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                animeData!.title!.english!,
              ),
              background: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      animeData!.media!.banner!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 250,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xff1e1e23),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: ambiantColor!,
                    spreadRadius: 15,
                    blurRadius: 500,
                  ),
                ],
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 10,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Expanded(
                          flex: 1,
                          child: AnimatedOpacity(
                            opacity: coverVisible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Image.network(
                              animeData!.media!.cover!.extraLarge!,
                              scale: .5,
                              height: 200,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ambiantColor!,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                topRight: Radius.circular(12)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: [
                                Text("${animeData!.score} ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const Icon(
                                  CupertinoIcons.star_fill,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tv, size: 18),
                              const SizedBox(width: 5),
                              Text(
                                "${animeData?.episodeCount}",
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          if (animeData!.airing!)
                            Row(
                              children: [
                                const Icon(Icons.timer, size: 18),
                                const SizedBox(width: 5),
                                Text(
                                  "Next Episode In: ${animeData?.nextAiring?.airingAt!.difference(DateTime.now()).toString() ?? 0}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            children: [
                              const Icon(Icons.timer, size: 18),
                              const SizedBox(width: 5),
                              Text(
                                "${animeData!.duration} min",
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.source, size: 18),
                              const SizedBox(width: 5),
                              Text(
                                "${animeData!.source}",
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.info, size: 18),
                              const SizedBox(width: 5),
                              Text(
                                animeData!.status!,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/watch",
                      arguments: [animeData!, 1]);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: ambiantColor!,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Play Episode 1'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isDescriptionExpanded = !isDescriptionExpanded;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      animeData!.description?.replaceAll("<br><br>", "\n") ??
                          "",
                      style: const TextStyle(fontSize: 16),
                      maxLines: isDescriptionExpanded
                          ? null
                          : 3, // Change the max lines to 3 when not expanded
                      overflow: isDescriptionExpanded
                          ? TextOverflow.visible
                          : TextOverflow
                              .ellipsis, // Change the overflow to ellipsis when not expanded
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Genres:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        animeData?.genres?.length ?? 0,
                        (index) => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Chip(
                            label: Text(
                                animeData?.genres?[index] == ""
                                    ? "loading"
                                    : animeData!.genres![index],
                                style: TextStyle(color: ambiantColor)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Synonyms:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        animeData?.title?.synonyms?.length ?? 0,
                        (index) => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Chip(
                            label: Text(
                                animeData?.title?.synonyms?[index] ?? '',
                                style: TextStyle(color: ambiantColor)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tags:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      showAllTags ? animeData?.tags?.length ?? 0 : 5,
                      (index) => Chip(
                        label: Text(animeData?.tags?[index].name ?? '',
                            style: TextStyle(color: ambiantColor)),
                      ),
                    ),
                  ),
                  if (!showAllTags)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAllTags = true;
                        });
                      },
                      child: Text('Show All Tags',
                          style: TextStyle(color: ambiantColor)),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Trailer:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Image.network(
                            animeData!.media?.trailer?.thumbnail?.max ?? ""),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(.3),
                          ),
                        ),
                        Center(
                            child: IconButton(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                animeData!.media?.trailer?.url ?? ""));
                          },
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 64,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Related Anime:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: animeData!.relations!.map((relation) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${relation.relation}: [${relation.anime!.first.type}]',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: relation.anime!.map((animeRef) {
                              return GestureDetector(
                                onTap: () {
                                  launchUrl(Uri.parse(animeRef.url));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    animeRef.name,
                                    style: TextStyle(
                                      color: ambiantColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Add more widgets if needed
    );
  }
}
