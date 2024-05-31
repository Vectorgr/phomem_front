import 'package:flutter/material.dart';
import 'package:phomem/Models/Location.dart';
import 'package:phomem/api.dart';
import 'package:phomem/components/viewLocation/addLocationDialog.dart';
import 'package:phomem/main.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationViewPage extends StatefulWidget {
  const LocationViewPage({super.key});

  @override
  State<LocationViewPage> createState() => _LocationViewPageState();
}

class _LocationViewPageState extends State<LocationViewPage> {
  @override
  Widget build(BuildContext context) {
    const memoryWidth = 450;
    final screenWidth = MediaQuery.of(context).size.width;
    final columnsCount = (screenWidth / memoryWidth).floor();

    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Location list",
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
              onPressed: () => _addLocation(context),
              child: Text("Add location"))
        ]),
        Expanded(
          child: FutureBuilder<List<Location>>(
            future: Api.getLocationList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: GridViewLocation(
                    columnsCount: columnsCount,
                    snapshot: snapshot,
                  ),
                );
              } else {
                return Center(
                  child: Text("No hay datos"),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class LocationViewCard extends StatelessWidget {
  const LocationViewCard({super.key, required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 5,
            child: FutureBuilder(
              future: Api.getLocationImage(location),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  return SizedBox(
                      height: 200, child: Image.new(image: snapshot.data!));
                } else {
                  return Center(child: Text("No image available"));
                }
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: ListTile(
              title: Text(location.name),
              subtitle: Text(location.description),
            ),
          ),
          Expanded(
            flex: 1,
            child: ButtonBar(
              children: [
                TextButton(
                  child: const Text('Edit'),
                  onPressed: () {
                    // Acción del botón 1
                  },
                ),
                TextButton(
                  child: const Text('Search in Google maps'),
                  onPressed: () {
                    if (location.latitude != null) {
                      print(location.latitude);
                      _openMaps(location.latitude, location.longitude);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _addLocation(context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return DialogAddLocation();
    },
  ));
}

class GridViewLocation extends StatelessWidget {
  const GridViewLocation({
    super.key,
    required this.columnsCount,
    required this.snapshot,
  });

  final int columnsCount;
  final AsyncSnapshot<List<Location>> snapshot;

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
          final location = snapshot.data![index];
          return LocationViewCard(location: location);
        },
      ),
    );
  }
}

Future<void> _openMaps(latitude, longitude) async {
  print(latitude);
  print("https://www.google.es/maps/@${latitude},${longitude},20z");
  await launchUrl(
      Uri.parse("https://www.google.es/maps/@$latitude,$longitude,20z"));
}
