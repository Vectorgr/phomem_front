import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/api.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class EditMemoryColumn extends StatefulWidget {
  const EditMemoryColumn({super.key,required this.mem, required this.onChangedMem});
  final Memory mem;

  final ValueChanged<Memory> onChangedMem;
  @override
  State<EditMemoryColumn> createState() => _EditMemoryColumnState();
}

class _EditMemoryColumnState extends State<EditMemoryColumn> {
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
                  if(val!=null){
                    newMemory.title=val;
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
                initialDate: widget.mem.date,
                format: DateFormat("d/M/yyyy"),
                name: 'date',
                onChanged: (val) {
                  print(val);
                  if(val!=null){
                    newMemory.date=val;
                    widget.onChangedMem(newMemory);
                  }

                },
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText: 'Write memory date',
                )
            ),
          )
        ]),
        Padding(padding: EdgeInsets.only(top: 20)),
        FormBuilderTextField(
            //description
            name: 'description',
            initialValue: widget.mem.description,
            onChanged: (val) {
              if(val!=null){
                    newMemory.description=val;
                    widget.onChangedMem(newMemory);
                  }
            },
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Write a description',
            )),
       
      ],
    );
  }
}
