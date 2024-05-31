
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/api.dart';

class AddImageColumn extends StatefulWidget {
  const AddImageColumn({super.key, required this.memory, required this.onChangedMem});

  final Memory memory;

  @override
  State<AddImageColumn> createState() => _AddImageColumnState();
  
  final ValueChanged<Memory> onChangedMem;
}

class _AddImageColumnState extends State<AddImageColumn> {
  @override
  Widget build(BuildContext context) {
    Memory newMemory = widget.memory;
    return Column(
      children: [
        Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                   //TODO cambiar imagen
                    "https://t4.ftcdn.net/jpg/04/81/13/43/360_F_481134373_0W4kg2yKeBRHNEklk4F9UXtGHdub3tYk.jpg"),
                fit: BoxFit.fitHeight,
              ),
            )),
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
              },
            ),
          ),
          child: const Text('Add image'),
          onPressed: () async {
            XFile? image = await Api.getImageFilesystem();
            if(image!=null){
              String id = await Api.postImage(widget.memory.id, await image.readAsBytes());
              print("Imagen: $id");
              newMemory.addImage(id);
              print("LISTA:${newMemory.imageList}");
              widget.onChangedMem(newMemory);
              
            }
          },
        )
      ],
    );
  }
}




