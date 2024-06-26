import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/classes/anime_progress.dart';
import 'package:aniwatch/pages/watch.dart';
import 'package:aniwatch/services/anisearch.dart';
import 'package:aniwatch/services/anilookup.dart';
import 'package:aniwatch/widgets/anime_recomendation.dart';
import 'package:aniwatch/widgets/anime_reference.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimePage extends StatefulWidget {
  final AnimeSearchResult animeSearchResult;

  const AnimePage({super.key, required this.animeSearchResult});

  @override
  State<AnimePage> createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  final userProgress = UserAnimeProgress();
  Anime? animeData;
  bool showAllTags = false;
  bool coverVisible = true;
  bool isDescriptionExpanded = false;
  Color? ambiantColor;
  EpisodeProgress? latestProgress;

  int initialRecommendationsCount = 10;
  bool recommendationVisible = true;
  bool episodesVisible = false;

  fetchdata() async {
    final anime = await aniInfo(widget.animeSearchResult);
    setState(() {
      animeData = anime;
    });
  }

  Future<Map> imagefetch(int id) async {
    await Future.delayed(const Duration(seconds: 3));
    return (await jikanAnimeImageFetch(id));
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
      return Scaffold(
        body: Skeletonizer(
          enabled: animeData == null,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                surfaceTintColor: ambiantColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Bone.text(
                    words: 3,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  background: const Bone.button(height: 200, width: 500),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: ambiantColor ?? const Color(0xffcdcdcd),
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
                            child: AnimatedOpacity(
                              opacity: coverVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: Bone.button(
                                height: 200,
                                width: 140,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ambiantColor,
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    topRight: Radius.circular(12)),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Row(
                                  children: [
                                    Bone.text(
                                      words: 1,
                                    ),
                                    Icon(
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
                      const Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.tv, size: 18),
                                  SizedBox(width: 5),
                                  Bone.text(words: 1),
                                ],
                              ),
                              Bone.text(words: 2),
                              Bone.text(words: 2),
                              Bone.text(words: 1),
                              Bone.text(words: 2),
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
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Bone.button(
                            words: 3,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Bone.button(
                              words: 1,
                              height: 25,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  child: Visibility(
                    visible: episodesVisible,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Episodes: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            elevation: 5,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                    animeData?.episodeCount ?? 5,
                                    (index) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: animeData == null
                                              ? Bone.button(
                                                  words: 2,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                )
                                              : ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16),
                                                    foregroundColor:
                                                        ambiantColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                        context, "/watch",
                                                        arguments: [
                                                          animeData,
                                                          index + 1,
                                                          0,
                                                          "",
                                                        ]);
                                                  },
                                                  child: Text(
                                                      "Episode ${index + 1}")),
                                        )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        animeData == null
                            ? const Bone.multiText(
                                lines: 3,
                              )
                            : Text(
                                (animeData?.description ?? "")
                                    .replaceAll("<br><br>", "\n"),
                                style: const TextStyle(fontSize: 16),
                                maxLines: isDescriptionExpanded ? null : 3,
                                overflow: isDescriptionExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
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
                            animeData?.genres?.length ?? 5,
                            (index) => animeData == null
                                ? Bone.button(
                                    words: 1,
                                    borderRadius: BorderRadius.circular(8))
                                : Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Chip(
                                      label: Text(
                                          animeData?.genres?[index] == ""
                                              ? "loading"
                                              : "${animeData?.genres?[index]}",
                                          style:
                                              TextStyle(color: ambiantColor)),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    var colorString = animeData!.media!.cover!.color!.substring(1);
    ambiantColor = _hexToColor(colorString);

    latestProgress =
        userProgress.getLatestEpisodeProgress(animeData!.ids!.allanime);
    setState(() {});
    if (latestProgress != null) {
      print('Latest episode progress:');
      print('Anime ID (AllAnime): ${latestProgress!.animeIds.allanime}');
      print('Anime ID (AniList): ${latestProgress!.animeIds.anilist}');
      print('Anime ID (MAL): ${latestProgress!.animeIds.mal}');
      print('Episode Number: ${latestProgress!.episodeNumber}');
      print('Episode URL: ${latestProgress!.episodeUrl}');
      print('Watched: ${latestProgress!.watched}');
      print('Episode Title: ${latestProgress!.episodeTitle ?? "N/A"}');
    } else {
      print('No latest episode progress found.');
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
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
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: animeData!.media!.banner!,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Skeletonizer(
                            child: Bone.button(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                            ),
                          ),
                          errorWidget: (context, url, error) => Skeletonizer(
                            child: Bone.button(
                                width: MediaQuery.of(context).size.width - 32,
                                height:
                                    (MediaQuery.of(context).size.width - 32) /
                                        1.7),
                          ),
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
                            child: AnimatedOpacity(
                              opacity: coverVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: Hero(
                                tag: "${animeData!.ids!.allanime}#cover",
                                child: CachedNetworkImage(
                                  height: 200,
                                  fit: BoxFit.fitHeight,
                                  imageUrl:
                                      animeData!.media!.cover!.extraLarge!,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Skeletonizer(
                                    child: Bone.button(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                32,
                                        height:
                                            (MediaQuery.of(context).size.width -
                                                    32) /
                                                1.7),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Skeletonizer(
                                    child: Bone.button(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                32,
                                        height:
                                            (MediaQuery.of(context).size.width -
                                                    32) /
                                                1.7),
                                  ),
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
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              final lastep = latestProgress?.watched == false
                                  ? latestProgress!.episodeNumber
                                  : latestProgress != null
                                      ? latestProgress!.episodeNumber + 1
                                      : 1;
                              final ts = latestProgress == null
                                  ? Duration.zero
                                  : latestProgress!.progress;
                              final url = latestProgress == null
                                  ? ""
                                  : latestProgress!.episodeUrl;
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return WatchPage(
                                  anime: animeData!,
                                  animeLink: url,
                                  lastEp: lastep,
                                  timestamp: ts,
                                );
                              }));
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
                            child: Text(latestProgress?.watched == false
                                ? 'Resume Episode ${latestProgress!.episodeNumber}'
                                : latestProgress != null
                                    ? 'Resume Episode ${latestProgress!.episodeNumber + 1}'
                                    : "Play Episode 1"),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                episodesVisible = !episodesVisible;
                              });
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
                            child: const Icon(CupertinoIcons.square_list,
                                size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  child: Visibility(
                    visible: episodesVisible,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Episodes: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            elevation: 5,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                    animeData!.episodeCount!,
                                    (index) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                foregroundColor: ambiantColor!,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return WatchPage(
                                                        anime: animeData!,
                                                        animeLink: "",
                                                        lastEp: index + 1,
                                                        timestamp:
                                                            Duration.zero,
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              child:
                                                  Text("Episode ${index + 1}")),
                                        )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          animeData!.description
                                  ?.replaceAll("<br><br>", "\n") ??
                              "",
                          style: const TextStyle(fontSize: 16),
                          maxLines: isDescriptionExpanded ? null : 3,
                          overflow: isDescriptionExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
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
                            CachedNetworkImage(
                              imageUrl:
                                  animeData!.media?.trailer?.thumbnail?.max ??
                                      "",
                              placeholder: (context, url) => Skeletonizer(
                                child: Bone.button(
                                    width:
                                        MediaQuery.of(context).size.width - 32,
                                    height: (MediaQuery.of(context).size.width -
                                            32) /
                                        1.7),
                              ),
                              errorWidget: (context, url, error) =>
                                  Skeletonizer(
                                child: Bone.button(
                                    width:
                                        MediaQuery.of(context).size.width - 32,
                                    height: (MediaQuery.of(context).size.width -
                                            32) /
                                        1.7),
                              ),
                            ),
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: animeData!.relations!.map((relation) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: relation.anime!.map((animeRef) {
                                    return FutureBuilder(
                                      future: animeRef.type == "anime"
                                          ? imagefetch(animeRef.id)
                                          : jikanMangaImageFetch(animeRef.id),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData ||
                                            snapshot.data?["data"] == null) {
                                          return Skeletonizer.zone(
                                            enabled: snapshot.connectionState ==
                                                ConnectionState.waiting,
                                            child: const AnimeReferenceWidget(),
                                          );
                                        } else {
                                          return AnimeReferenceWidget(
                                            data: snapshot.data,
                                            name: animeRef.name,
                                            type: animeRef.type,
                                            icon: CupertinoIcons.play_rectangle,
                                            relation: relation.relation,
                                            id: animeRef.id,
                                          );
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // other code....
              // Recommendation
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // IconButton(
                          //     onPressed: () {
                          //       setState(() {
                          //         recommendationVisible = !recommendationVisible;
                          //       });
                          //     },
                          //     icon: recommendationVisible
                          //         ? const Icon(CupertinoIcons.chevron_up)
                          //         : const Icon(CupertinoIcons.chevron_down)),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Recommandations:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to the page that displays all recommendations
                                  Navigator.pushNamed(
                                      context, '/recommendations');
                                },
                                child: const Icon(CupertinoIcons.ellipsis)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Visibility(
                        visible: recommendationVisible,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: animeData!.relations!
                                .take(initialRecommendationsCount)
                                .map((relation) {
                              return FutureBuilder<List>(
                                future: jikanRelatedAnimeRecommendations(
                                  animeData!.ids!.mal!,
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Skeletonizer.zone(
                                      enabled: snapshot.connectionState ==
                                          ConnectionState.waiting,
                                      child: const AnimeRecommandationWidget(),
                                    );
                                  } else {
                                    return Row(
                                      children: snapshot.data!.map((entry) {
                                        entry = entry["entry"]
                                            as Map<String, dynamic>;
                                        return AnimeRecommandationWidget(
                                          data: entry,
                                          name: entry["title"],
                                        );
                                      }).toList(),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      // Add more widgets if needed
    );
  }
}
