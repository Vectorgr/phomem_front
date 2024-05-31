import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/api.dart';
import 'package:phomem/components/editDialog/addImageColumn.dart';
import 'package:phomem/components/editDialog/editMemoryColumn.dart';

class DialogEditMemory extends StatelessWidget {
  final Memory memory;
  const DialogEditMemory({
    super.key,
    required this.memory,
  });

  @override
  Widget build(BuildContext context) {
    Memory newMemory = memory;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit memory'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),

            onPressed: () =>
                { deleteMemory(memory.id)},
            child: Row(
              children: [
                Text("Delete memory"),
                Icon(
                  Icons.delete,
                  size: 30.0,
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(right: 20))
        ],
      ),
      body: SafeArea(
          child: FormBuilder(
        child: Column(children: [
          Padding(padding: EdgeInsets.only(top: 20)),
          Row(children: [
            Expanded(
              flex: 2,
              child: Container(),
            ),
            Expanded(
                flex: 8,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: EditMemoryColumn(
                        mem: memory,
                        onChangedMem: (Memory value) => newMemory))),
            Expanded(
              flex: 2,
              child: Container(),
            ),
            Expanded(
                //ADDIMAGE
                flex: 8,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: AddImageColumn(
                      memory: memory,
                      onChangedMem: (Memory value) => newMemory,
                    ))),
            Expanded(
              flex: 2,
              child: Container(),
            ),
          ]),
          Padding(padding: EdgeInsets.only(top: 20)),
          Center(
              child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
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
            onPressed: () {
              print("imprime:");
              print(newMemory.imageList);
              Api.updateMemory(newMemory);
            },
          ))
        ]),
      )),
    );
  }
}

Future<void> deleteMemory(memoryID) async {
  print("TEST");
  await Api.deleteMemory(memoryID);
}
