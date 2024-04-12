import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/services/anilookup.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AnimeReferenceWidget extends StatefulWidget {
  const AnimeReferenceWidget(
      {super.key,
      this.data,
      this.relation,
      this.icon,
      this.name,
      this.type,
      this.id});

  final Map? data;
  final String? relation;
  final IconData? icon;
  final String? type;
  final String? name;
  final int? id;

  @override
  State<AnimeReferenceWidget> createState() => _AnimeReferenceWidgetState();
}

class _AnimeReferenceWidgetState extends State<AnimeReferenceWidget> {
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
    _fetchRes(widget.name ?? "", "${widget.id!}", true);
    return Skeletonizer(
      enabled: widget.data == null,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.popAndPushNamed(context, "/anime", arguments: animeRes);
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
                        imageUrl: widget.type == "manga"
                            ? "${widget.data?["data"][1]["jpg"]["large_image_url"] ?? widget.data?["data"].last["jpg"]["large_image_url"]}"
                            : "${widget.data?["data"].last["jpg"]["large_image_url"] ?? ""}",
                        // placeholder: (context, url) => Container(
                        //   height: 150,
                        //   width: 105,
                        // ),
                        progressIndicatorBuilder: (context, url, progress) =>
                            Bone.button(
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
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            widget.icon,
                            size: 16,
                            color: const Color(0xff555577),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.relation ?? "",
                            style: const TextStyle(
                              color: Color(0xff555577),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
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
