import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AnimeReferenceWidget extends StatefulWidget {
  const AnimeReferenceWidget(
      {super.key, this.data, this.relation, this.icon, this.name, this.type});

  final Map? data;
  final String? relation;
  final IconData? icon;
  final String? type;
  final String? name;

  @override
  State<AnimeReferenceWidget> createState() => _AnimeReferenceWidgetState();
}

class _AnimeReferenceWidgetState extends State<AnimeReferenceWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {},
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
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
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
    );
  }
}
