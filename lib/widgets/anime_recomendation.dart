import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/services/anilookup.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AnimeRecommandationWidget extends StatefulWidget {
  const AnimeRecommandationWidget({super.key, this.data, this.name});

  final Map? data;
  final String? name;

  @override
  State<AnimeRecommandationWidget> createState() =>
      _AnimeRecommandationWidgetState();
}

class _AnimeRecommandationWidgetState extends State<AnimeRecommandationWidget> {
  late AnimeSearchResult animeRes;

  _fetchRes(String name, String id, bool mal) async {
    final resp = await aniSearch(name);
    for (var animeres in resp) {
      if (mal == true) {
        if (animeres.malId == int.parse(id)) {
          setState(() {
            animeRes = animeres;
          });
        }
      }
      if (animeres.allanimeId == id) {
        setState(() {
          animeRes = animeres;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: widget.data == null,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () async {
              final resp = await aniSearch(widget.name!);
              for (var animeres in resp) {
                if (animeres.malId == widget.data!["mal_id"]) {
                  Navigator.pushNamed(context, "/anime",
                      arguments: animeres);
                }
              }
            },
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
                        imageUrl:
                            "${widget.data?["images"]?["jpg"]["large_image_url"] ?? widget.data?["images"]["webp"]["large_image_url"]}",
                        placeholder: (context, url) => Bone.button(
                          height: 150,
                          width: 105,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorWidget: (context, url, error) => Bone.button(
                          height: 150,
                          width: 105,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
                      child: Skeleton.shade(
                        child: Text(
                          widget.name ?? "",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
