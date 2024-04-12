import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/services/anilookup.dart';
import 'package:aniwatch/widgets/results_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Searchpage extends StatefulWidget {
  // ignore: use_super_parameters
  const Searchpage({key}) : super(key: key);

  @override
  State<Searchpage> createState() => _SearchpageState();
}

TextEditingController controller = TextEditingController();

class _SearchpageState extends State<Searchpage> {
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
            onFieldSubmitted: (value) async {
              var res = await aniSearch(value);
              if (kDebugMode) {
                print(res);
              }
              setState(() {
                results = res;
              });
            },
            onEditingComplete: () async {
              var res = await aniSearch(controller.text);
              if (kDebugMode) {
                print(res);
              }
              setState(() {
                results = res;
              });
            },
            onChanged: (value) async {
              var res = await aniSearch(value);
              if (kDebugMode) {
                print(res);
              }
              setState(() {
                results = res;
              });
            },
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
