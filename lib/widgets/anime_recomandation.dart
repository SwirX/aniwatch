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
                      imageUrl:
                          "${widget.data?["images"]?["jpg"]["large_image_url"] ?? widget.data?["images"]["webp"]["large_image_url"]}",
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
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
