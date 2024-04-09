import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/services/check_update.dart';
import 'package:aniwatch/sevices/anilookup.dart';
import 'package:aniwatch/widgets/results_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  // ignore: use_super_parameters
  const Homepage({key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

TextEditingController controller = TextEditingController();

class _HomepageState extends State<Homepage> {
  List<AnimeSearchResult> results = [];
  String? updateStatus;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                if (mode == "sub") {
                  mode = "dub";
                } else {
                  mode = "sub";
                }
                setState(() {});
              },
              child: Text(mode)),
          IconButton(
            onPressed: () async {
              if (kDebugMode) {
                print(await checkForUpdates());
              }
            },
            icon: const Icon(CupertinoIcons.cloud_download),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 32,
          ),
          const Text(
            "Search: ",
            style: TextStyle(fontSize: 32),
          ),
          TextFormField(
            controller: controller,
          ),
          TextButton(
            onPressed: () async {
              var res = await aniSearch(controller.text);
              if (kDebugMode) {
                print(res);
              }
              setState(() {
                results = res;
              });
            },
            child: const Text("Search"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                var animeinfo = results[index];
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ResultsTile(anime: animeinfo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}