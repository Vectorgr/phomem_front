
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:phomem/Models/Location.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/Models/Person.dart';
import 'package:phomem/api.dart';
import 'package:intl/intl.dart';

class EditMemoryColumn extends StatefulWidget {
  const EditMemoryColumn(
      {super.key, required this.mem, required this.onChangedMem});
  final Memory mem;
  final ValueChanged<Memory> onChangedMem;
  @override
  State<EditMemoryColumn> createState() => _EditMemoryColumnState();
}

class _EditMemoryColumnState extends State<EditMemoryColumn> {
  List<DropdownMenuItem<dynamic>> locationList = [];
  List<FormBuilderFieldOption> peopleList = [];
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    List<DropdownMenuItem<dynamic>> locations = await getLocations();
    List<FormBuilderFieldOption> people = await getPeople();
    
    setState(() {
      locationList = locations;
      peopleList = people;
    });
  }

  @override
  Widget build(BuildContext context) {
    Memory newMemory = widget.mem;
    return Column(
      children: [
        Row(children: [
          //title and date
          Expanded(
            child: FormBuilderTextField(
                //title
                name: 'title',
                initialValue: widget.mem.title,
                onChanged: (val) {
                  print(val);
                  if (val != null) {
                    newMemory.title = val;
                    widget.onChangedMem(newMemory);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Write a title',
                )),
          ),
          Padding(padding: EdgeInsets.only(left: 20)),
          Expanded(
            child: FormBuilderDateTimePicker(
                inputType: InputType.date,
                initialValue: widget.mem.date,
                format: DateFormat("d/M/yyyy"),
                name: 'date',
                onChanged: (val) {
                  print(val);
                  if (val != null) {
                    newMemory.date = val;
                    widget.onChangedMem(newMemory);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText: 'Write memory date',
                )),
          )
        ]),
        Padding(padding: EdgeInsets.only(top: 20)),
        FormBuilderTextField(
            //description
            name: 'description',
            initialValue: widget.mem.description,
            onChanged: (val) {
              if (val != null) {
                newMemory.description = val;
                widget.onChangedMem(newMemory);
              }
            },
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Write a description',
            )),
        Padding(padding: EdgeInsets.only(top: 20)),
        FormBuilderDropdown(
          name: "LocationsMenu",
          items: locationList,
           decoration: InputDecoration(
              labelText: 'Location',
            )
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        FormBuilderCheckboxGroup(name: "peopleMenu", options: peopleList, decoration: InputDecoration(
              labelText: 'People',
            )),
        
      ],
    );
  }
}

Future<List<DropdownMenuItem<dynamic>>> getLocations() async {
  List<Location> locationList = await Api.getLocationList();
  return locationList
      .map((loc) => DropdownMenuItem(
            value: loc,
            child: Text(loc.name),
          ))
      .toList();
}

Future<List<FormBuilderFieldOption>> getPeople() async {
  List<Person> people = await Api.getPersonList();
  return people
      .map((per) => FormBuilderFieldOption(
            value: per,
            child: Text(per.name),
          ))
      .toList();
}
