import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:phomem/Models/Person.dart';
import 'package:phomem/api.dart';
import 'package:phomem/components/viewPerson/addPersonDialog.dart';

class PeopleViewPage extends StatefulWidget {
  const PeopleViewPage({super.key});

  @override
  State<PeopleViewPage> createState() => _PeopleViewPageState();
}

class _PeopleViewPageState extends State<PeopleViewPage> {
  @override
  Widget build(BuildContext context) {
    //Adapt columns with Screen size
    const memoryWidth = 400;
    final screenWidth = MediaQuery.of(context).size.width;
    final columnsCount = (screenWidth / memoryWidth).floor();
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("People list",
                  style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.underline)),
            ])),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
              onPressed: () => _addPerson(context), child: Text("Add person"))
        ]),
        FutureBuilder(
          future: Api.getPersonList(),
          builder: (context, AsyncSnapshot<List<Person>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: ListViewPeople(
                      columnsCount: columnsCount, snapshot: snapshot));
            } else {
              return Center(
                child: Text("No hay datos"),
              );
            }
          },
        ),
      ],
    );
  }
}

void _addPerson(context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return DialogAddPerson();
    },
  ));
}

class ListViewPeople extends StatelessWidget {
  const ListViewPeople({
    super.key,
    required this.columnsCount,
    required this.snapshot,
  });

  final int columnsCount;
  final AsyncSnapshot<List<Person>> snapshot;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(snapshot.data![index].name),
                      subtitle: Text(snapshot.data![index].biography),
                      leading: FutureBuilder(
                        future: Api.getProfilePic(snapshot.data![index].id),
                        builder: (BuildContext context,
                            AsyncSnapshot<ImageProvider> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else {
                            return CircleAvatar(
                              backgroundImage: snapshot.data,
                            );
                          }
                        },
                      ),
                    )
                  ],
                ));
          },
        ));
  }
}
