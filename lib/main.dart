import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'cardview.dart';
import 'model/datum.dart';
import 'model/searchtovar.dart';
import 'model/tovar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final scrollController = ScrollController();
  int page = 1;
  bool isLoadingMore = false;
  List<Datum> zapchastlar = [];
  var myText = TextEditingController();

  @override
  void initState() {
    super.initState();
//    items = Network().getItems(page);
    getItems(1);
    scrollController.addListener(_scrollListener);
    myText.addListener(handleChanges);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              height: 60,
              child: TextField(
                controller: myText,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "qidirish",
                    suffixIcon: IconButton(
                        onPressed: myText.clear, icon: Icon(Icons.clear))),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.black),
                      color: Colors.blue),
                  child: const Center(
                      child: Text(
                    "Nomi",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.black),
                      color: Colors.blue),
                  child: const Center(
                      child: Text(
                    "Olish Narxi",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.black),
                      color: Colors.blue),
                  child: const Center(
                      child: Text(
                    "Foiz",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.black),
                      color: Colors.blue),
                  child: const Center(
                      child: Text(
                    "Sotish Narxi ",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
            ],
          ),
          Expanded(child: getTaskListview())
        ],
      ),
    );
  }

  Future<void> getItems(int page) async {
    var url = "http://umidhoja.ga/api/tovarlar?page=${page}";
    var response = await get(Uri.parse(url));
    print(url);
    if (response.statusCode == 200) {
      final json = tovarFromJson(response.body);
      setState(() {
        zapchastlar = zapchastlar + json.data;
      });
    } else {
      print("object");
    }
    throw Exception("");
  }

  Future<void> search(String text, int page) async {
    var url = "http://umidhoja.ga/api/search?query=${text}&&page=${page}";
    print(url);
    var response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = searchFromJson(response.body);
      print(response.body);
      setState(() {
        zapchastlar = zapchastlar + json.data;
      });
    }
  }

  Future<void> _scrollListener() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      page = page + 1;
      setState(() {
        isLoadingMore = true;
      });
      if (myText.value.text.toString().isEmpty) {
        await getItems(page);
      } else {
        await search(myText.value.text.toString(), page);
      }
      isLoadingMore = false;
    }
  }

  void handleChanges() {
    zapchastlar.clear();
    if (myText.value.text.toString() == "") {
      getItems(1);
    } else {
      page = 1;
      search(myText.value.text.toString(), page);
    }
  }

  Widget getTaskListview() {
    return zapchastlar.isNotEmpty
        ? ListView.builder(
            padding: const EdgeInsets.only(bottom: 12.0),
            controller: scrollController,
            itemCount:
                isLoadingMore ? zapchastlar.length + 1 : zapchastlar.length,
            itemBuilder: (BuildContext context, int index) {
              if (index < zapchastlar.length) {
                return CardView(zapchastlar[index]);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            })
        : Center(
            child: Text("Hech nima topilmadi"),
          );
  }
}
