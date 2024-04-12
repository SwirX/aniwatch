import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/classes/anime_progress.dart';
import 'package:aniwatch/services/anilookup.dart';
import 'package:aniwatch/services/anisearch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AnimeResumeWiget extends StatefulWidget {
  const AnimeResumeWiget({
    super.key,
    this.data,
  });

  final EpisodeProgress? data;

  @override
  State<AnimeResumeWiget> createState() => _AnimeResumeWigetState();
}

class _AnimeResumeWigetState extends State<AnimeResumeWiget> {
  String? thumbnail;
  late AnimeSearchResult animeRes;

  _fetchThumbs(int id) async {
    final resp = await jikanAnimeImageFetch(id);
    setState(() {
      thumbnail =
          "${resp["data"][1]["jpg"]["large_image_url"] ?? resp["data"].last["jpg"]["large_image_url"]}";
    });
  }

  @override
  Widget build(BuildContext context) {
    _fetchThumbs(widget.data?.animeIds.mal ?? 0);
    return GestureDetector(
      onTap: () async {
        final resp = await aniSearch(widget.data?.animeName ?? "");
        for (var animeres in resp) {
          if (animeres.allanimeId == widget.data!.animeIds.allanime) {
            Navigator.pushNamed(context, "/anime", arguments: animeres);
          }
        }
      },
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              alignment: AlignmentDirectional.center,
              width: 125,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                      width: 105,
                      height: 150,
                      imageUrl: thumbnail ?? "",
                      errorWidget: (context, url, error) => Skeletonizer(
                        enabled: true,
                        child: Bone.button(
                          height: 150,
                          width: 105,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
                    child: Skeleton.shade(
                      child: Text(
                        widget.data?.animeName ?? "",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
                    child: Skeleton.shade(
                      child: Text(
                        "Continue Ep ${widget.data!.episodeNumber}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(.6),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
