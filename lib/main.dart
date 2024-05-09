import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_card/image_card.dart';
import 'package:phomem/memory.dart';
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
      home: Inicio(),
    );
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("PhotoMemories",
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none)),
          backgroundColor: theme.colorScheme.primary,
        ),
        body: const MaterialApp(
          title: 'Navigation Basics',
          home: MemoriesListView(),
        ));
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
    log(MediaQuery.of(context).size.width.toString() + "");
    return SafeArea(
        child: SingleChildScrollView(
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
            }else{
              return  ListViewMemory(snapshot: snapshot);
            }
          } else {
            return Center(
              child: Text("No hay datos"),
            );
          }
        },
      ),
    ));
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
              child: TransparentImageCard(
                width: 300,
                height: 300,
                imageProvider: NetworkImage(
                    'https://img.freepik.com/foto-gratis/flor-purpura-margarita-osteospermum_1373-16.jpg?size=626&ext=jpg&ga=GA1.1.672697106.1714089600&semt=ais'),
                title: Text(
                  mem.title,
                  style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none),
                ),
                description: Text(
                  formatDescription(mem.description),
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      decoration: TextDecoration.none),
                ),
              ),
            )
            );
          }
    );
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
    return 
    Padding(padding: EdgeInsets.all(16.0), child:
    GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            columnsCount, 
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        final mem = snapshot.data![index];
        return TransparentImageCard(
          width: 300,
          height: 300,
          imageProvider: NetworkImage(
            'https://img.freepik.com/foto-gratis/flor-purpura-margarita-osteospermum_1373-16.jpg?size=626&ext=jpg&ga=GA1.1.672697106.1714089600&semt=ais',
          ),
          title: Text(
            mem.title,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          description: Text(
            formatDescription(mem.description),
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        );
      },
    )
    );
  }
}

Future<List<Memory>> fetchMemory() async {
  final response = await http.get(Uri.parse('http://localhost:8000/'));

  if (response.statusCode == 200) {
    String responseData = utf8.decode(response.bodyBytes);
    for (Memory m in (json.decode(responseData) as List)
        .map((i) => Memory.fromJson(i))
        .toList()) {}
    return (json.decode(responseData) as List)
        .map((i) => Memory.fromJson(i))
        .toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

String formatDescription(String description) {
  const maxLength = 75;
  if (description.length > maxLength) {
    return ("${description.substring(0, maxLength - 3)}...");
  }
  return description;
}
