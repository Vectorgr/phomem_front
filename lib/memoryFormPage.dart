import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/components/editDialog/dialogEditMemory.dart';
import 'package:phomem/api.dart';
import 'package:phomem/components/editDialog/editMemoryColumn.dart';

class MemoryFormPage extends StatefulWidget {
  const MemoryFormPage({super.key});
  @override
  State<MemoryFormPage> createState() => _MemoryFormPageState();
}

class _MemoryFormPageState extends State<MemoryFormPage> {
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: NewFormBuilder());
  }
}

class NewFormBuilder extends StatelessWidget {
  const NewFormBuilder({
    super.key,
    
  });

  @override
  Widget build(BuildContext context) {
    String title = "", description = "", date = "";
    return FormBuilder(
        child: Row(
          children: [
    Expanded(
      flex: 2,
      child: Container(),
    ),
    Expanded(
        flex: 6,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text("Add memory",
                    style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Row(children: [
                  Expanded(
                    child: FormBuilderTextField(
                        name: 'title',
                        onChanged: (val) {
                          if (val != null) {
                            title = val;
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
                        format: DateFormat("d/M/yyyy"),
                        name: 'date',
                        onChanged: (val) {
                          if (val != null) {
                            date = DateFormat("dd/MM/yyyy").format(val);
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
                    name: 'description',
                    onChanged: (val) {
                      if (val != null) {
                        description = val;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Write a description',
                    )),
                Padding(padding: EdgeInsets.only(top: 20)),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5);
                        }
                        return null; // Use the component's default.
                      },
                    ),
                  ),
                  child: const Text('Save memory'),
                  onPressed: () async {
                    String memoryID = await Api.postMemory(title, description, date);
                    Memory mem = await Api.getMemory(memoryID);
                   _showFullScreenDialog(context, mem);
                    
                  },
                )
              ],
            ))),
    Expanded(flex: 2, child: Container())
          ],
        ));
  }
}
void _showFullScreenDialog(BuildContext context, Memory memory) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return DialogEditMemory(memory: memory,);
    },
  ));
}

