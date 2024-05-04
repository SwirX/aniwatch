import 'package:aniwatch/classes/anime.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePopular extends StatefulWidget {
  const HomePopular({super.key, required this.result});

  final AnimePopularResult? result;

  @override
  State<HomePopular> createState() => _HomePopularState();
}

class _HomePopularState extends State<HomePopular> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: widget.result == null,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () async {
              final animeResult = await widget.result!.convertToSearchResult();
              // ignore: use_build_context_synchronously
              Navigator.pushNamed(context, "/anime", arguments: animeResult);
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
                        imageUrl: widget.result?.thumbnail ?? "",
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
                          widget.result?.name ?? "loading",
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
