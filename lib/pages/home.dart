import 'package:aniwatch/services/anifetch.dart';
import 'package:aniwatch/classes/anime.dart';
import 'package:aniwatch/services/check_update.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

TextEditingController controller = TextEditingController();

class _HomepageState extends State<Homepage> {
  List<Anime> results = [];
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
                toggleMode();
                setState(() {});
              },
              child: Text(mode)),
          IconButton(
            onPressed: () async {
              print(await checkForUpdates());
            },
            icon: Icon(CupertinoIcons.cloud_download),
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
              var res = await searchAnime(controller.text);
              print(res);
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
                return ListTile(
                  title: Text(animeinfo.name),
                  onTap: () {
                    animeinfo.mode = mode;
                    Navigator.pushNamed(context, "/anime",
                        arguments: animeinfo);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
