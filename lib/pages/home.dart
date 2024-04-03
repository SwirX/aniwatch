import 'package:aniwatch/anifetch.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

TextEditingController controller = TextEditingController();

class _HomepageState extends State<Homepage> {
  List results = [];

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
              child: Text(mode))
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
                  title: Text(animeinfo["name"] ?? "No Name"),
                  onTap: () {
                    animeinfo["mode"] = mode;
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
