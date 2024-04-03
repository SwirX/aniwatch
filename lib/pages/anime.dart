import 'package:aniwatch/anifetch.dart';
import 'package:flutter/material.dart';

class Animepage extends StatefulWidget {
  const Animepage({super.key});

  @override
  State<Animepage> createState() => _AnimepageState();
}

class _AnimepageState extends State<Animepage> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map;
    final name = arguments["name"];
    final id = arguments["id"];
    final _mode = arguments["mode"];
    // final availableEps = arguments["availableEpisodes"];
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: FutureBuilder(
        future: episodesList(id),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(itemCount: snapshot.data!.length,itemBuilder: ((context, index) {
              return ListTile(
                title: Text("Episode ${snapshot.data![index]}"),
                onTap: () async {
                  final ep = int.parse(snapshot.data![index]);
                  Navigator.pushNamed(context, "/watch", arguments: [id, ep, _mode]);
                  // final shell = Shell();
                  // var res = await shell.start('nohup am start -a android.intent.action.VIEW -d "$link" -n is.xyz.mpv/.MPVActivity &');
                },
              );
            }));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }),
      ),
    );
  }
}
