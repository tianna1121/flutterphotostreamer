import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Photo Streamer",
        theme: new ThemeData(primarySwatch: Colors.green),
        home: PhotoList());
  }
}

class PhotoList extends StatefulWidget {
  @override
  _PhotoListState createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  StreamController<Photo> streamController;
  List<Photo> list = [];

  @override
  void initState() {
    super.initState();
    streamController = new StreamController.broadcast();

    streamController.stream.listen((p) => setState(() => list.add(p)));
    load(streamController);
  }

  load(StreamController sc) async {
    String url = "https://jsonplaceholder.typicode.com/photos";
    var client = new http.Client();

    var req = new http.Request('get', Uri.parse(url));
    var streamdRes = await client.send(req);

    streamdRes.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .expand((e) => e)
        .map((map) => Photo.fromJsonMap(map))
        .pipe(streamController);
  }

  @override
  void dispose() {
    super.dispose();
    streamController?.close();
    streamController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Photo Streams"),
      ),
      body: new Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) => _makeElement(index),
        ),
      ),
    );
  }

  Widget _makeElement(int index) {
    if (index >= list.length) {
      return null;
    }
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Padding(
        padding: EdgeInsets.only(top: 200.0),
        child: Column(
          children: <Widget>[
            Image.network(
              list[index].url,
              width: 150.0,
              height: 150.0,
            ),
            Text(
              list[index].title,
            ),
          ],
        ),
      ),
    );
  }
}

class Photo {
  final String title;
  final String url;

  Photo.fromJsonMap(Map map)
      : title = map['title'],
        url = map['url'];
}
