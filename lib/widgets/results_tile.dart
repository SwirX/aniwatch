import 'package:aniwatch/classes/anime.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResultsTile extends StatefulWidget {
  const ResultsTile({super.key, required this.anime});

  final AnimeSearchResult anime;

  @override
  State<ResultsTile> createState() => _ResultsTileState();
}

class _ResultsTileState extends State<ResultsTile> {
  late String bannerUrl;
  late String coverUrl;
  late String largeCoverUrl;
  late String title;
  late double rating;
  late int episodes;

  Color hexToColor(String hexColor) {
    if (hexColor == "") {
      return Colors.transparent;
    } else {
      if (hexColor.startsWith('#')) {
        hexColor = hexColor.substring(1);
      }
      int colorValue = int.parse(hexColor, radix: 16);
      return Color(colorValue).withOpacity(1);
    }
  }

  Future<void> _fetchData() async {
    final anime = widget.anime;
    setState(() {
      bannerUrl = anime.banner;
      coverUrl = anime.cover;
      title = anime.name;
      rating = anime.score;
      episodes = anime.episode;
    });
    if (kDebugMode) {
      print(title);
    }
    if (kDebugMode) {
      print(bannerUrl);
    }
    if (kDebugMode) {
      print(coverUrl);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _fetchData();
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, "/anime", arguments: widget.anime),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              bannerUrl,
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: "${widget.anime.allanimeId}#cover",
                      child: CachedNetworkImage(
                        imageUrl: coverUrl,
                        height: 75,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("$episodes Episodes"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
