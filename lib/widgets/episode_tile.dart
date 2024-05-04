import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EpisodeTile extends StatefulWidget {
  const EpisodeTile({super.key, required this.data, required this.imageData});

  final Map<String, dynamic> data;
  final Map<String, dynamic> imageData;

  @override
  State<EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final imageData = widget.imageData;
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          imageData["jpg"]?["image_url"] != null ? CachedNetworkImage(imageUrl: imageData["jpg"]["image_url"]) : const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(data["title"]),
                if (data["filler"]) const Text("Filler"),
                if (data["recap"]) const Text("Recap"),
                Text("${(data["duration"] / 60).round()} min"),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
