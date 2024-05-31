
import 'package:flutter/material.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/api.dart';
import 'package:phomem/components/formatImageCard.dart';
import 'package:phomem/components/viewLocation/locationViewPage.dart';
import 'package:phomem/components/viewPerson/peopleViewPage.dart';
import 'package:phomem/components/viewsettings/settingsViewPage.dart';
import 'package:phomem/components/viewMemoryDialog/memoryFormPage.dart';

void main() {
  runApp(PhomemApp());
}

class PhomemApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    Api.configureDio(); // Configurar Dio al inicio de la app
    return MaterialApp(
      title: "PhomemApp",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 77, 199, 255)),
      ),
      home: MyHomePage(),
      navigatorKey: navigatorKey,
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
        page = PeopleViewPage();
        break;
      case 2:
        page = LocationViewPage();
        break;
      case 3:
        page = Placeholder();
        break;
      case 4:
        page = MemoryFormPage();
        break;
      case 5:
        page = SettingsViewPage();
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
                      icon: Icon(Icons.location_on),
                      label: Text('Locations'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.image),
                      label: Text('Images'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.add),
                      label: Text('Add memory'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
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
    final columnsCount = (screenWidth / memoryWidth).floor();
    return SingleChildScrollView(
      child: FutureBuilder(
        future: Api.getMemories(),
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
    Api.configureDio();
    return ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final mem = snapshot.data![index];
          return Center(
              child: Padding(
            padding: EdgeInsets.only(top: 10.0),
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
