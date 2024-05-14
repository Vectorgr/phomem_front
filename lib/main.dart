import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_card/image_card.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/components/formatImageCard.dart';
import 'package:phomem/memoryFormPage.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer';

void main() {
  runApp(PhomemApp());
}

class PhomemApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PhomemApp",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 77, 199, 255)),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MemoriesListView();
        break;
      case 1:
        page = Placeholder();
        break;
      case 2:
        page = MemoryFormPage();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: Text("PhotoMemories",
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none)),
          backgroundColor: Colors.blue,
        ),
        body: Row(
          children: [
            if (constraints.maxWidth >= 300)
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people),
                      label: Text('People'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.add),
                      label: Text('Add Memory'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class MemoriesListView extends StatefulWidget {
  const MemoriesListView({super.key});

  @override
  State<MemoriesListView> createState() => _MemoriesListViewState();
}

class _MemoriesListViewState extends State<MemoriesListView> {
  @override
  Widget build(BuildContext context) {
    //Adapt columns with Screen size
    const memoryWidth = 280;
    final screenWidth = MediaQuery.of(context).size.width;
    final columnsCount = (screenWidth / memoryWidth)
        .floor(); // Ancho de cada elemento (ejemplo: 200)
    return SingleChildScrollView(
      child: FutureBuilder(
        future: fetchMemory(),
        builder: (context, AsyncSnapshot<List<Memory>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
              
            );
          } else if (snapshot.hasData) {
            if (columnsCount > 1) {
              return GridViewMemory(
                  columnsCount: columnsCount, snapshot: snapshot);
            } else {
              return ListViewMemory(snapshot: snapshot);
            }
          } else {
            return Center(
              child: Text("No hay datos"),
            );
          }
        },
      ),
    );
  }
}

class ListViewMemory extends StatelessWidget {
  const ListViewMemory({
    super.key,
    required this.snapshot,
  });
  final AsyncSnapshot<List<Memory>> snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final mem = snapshot.data![index];
          return Center(
              child: Padding(
            padding: EdgeInsets.only(top: 10.0),

            //// Wrap the ListTile with Card Widget...
            child: FormatImageCard(mem: mem),
          ));
        });
  }
}



class GridViewMemory extends StatelessWidget {
  const GridViewMemory({
    super.key,
    required this.columnsCount,
    required this.snapshot,
  });

  final int columnsCount;
  final AsyncSnapshot<List<Memory>> snapshot;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsCount,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final mem = snapshot.data![index];
            return FormatImageCard(mem: mem);
          },
        ));
  }
}

Future<List<Memory>> fetchMemory() async {
  final response = await http.get(Uri.parse('http://localhost:8000/'));
  if (response.statusCode == 200) {
    String responseData = utf8.decode(response.bodyBytes);
    return (json.decode(responseData) as List)
        .map((i) => Memory.fromJson(i))
        .toList();
  } else {
    throw Exception('Failed to load album');
  }
}

