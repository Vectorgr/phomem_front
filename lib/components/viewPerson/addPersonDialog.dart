import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/Models/Person.dart';
import 'package:phomem/api.dart';
import 'package:phomem/components/editDialog/addImageColumn.dart';
import 'package:intl/intl.dart';

class DialogAddPerson extends StatelessWidget {
  const DialogAddPerson({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add person'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                    padding: EdgeInsets.all(10), child: AddPersonColumn())),
            Expanded(
              flex: 2,
              child: Container(),
            ),
          ]),
        ]),
      )),
    );
  }
}

class AddPersonColumn extends StatelessWidget {
  const AddPersonColumn({super.key});
  @override
  Widget build(BuildContext context) {
    String name = "", biography = "", birthDate = "";
    Uint8List? profilePic;
    return Column(
      children: [
         ProfilePic(profilePic: (value) {
          print("imagen");
          print(value.length);
          profilePic = value;
        }),
        Row(children: [
          //title and date
          Expanded(
            child: FormBuilderTextField(
                //title
                name: 'Name',
                onChanged: (val) {
                  if (val != null) {
                    name = val;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Write name',
                )),
          ),
          Padding(padding: EdgeInsets.only(left: 20)),
          Expanded(
            child: FormBuilderDateTimePicker(
                inputType: InputType.date,
                format: DateFormat("d/M/yyyy"),
                name: 'date',
                onChanged: (val) {
                  print(val);
                  if (val != null) {
                    birthDate = DateFormat("dd/MM/yyyy").format(val);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'BirtDate',
                  hintText: 'Birthday',
                )),
          )
        ]),
        Padding(padding: EdgeInsets.only(top: 20)),
        FormBuilderTextField(
            //description
            name: 'biography',
            onChanged: (val) {
              if (val != null) {
                biography = val;
              }
            },
            decoration: InputDecoration(
              labelText: 'Biography',
              hintText: 'Write a biography',
            )),
        Padding(padding: EdgeInsets.only(top: 20)),
        Center(
            child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                }
                return null; // Use the component's default.
              },
            ),
          ),
          child: const Text('Save person'),
          onPressed: () {
            postPerson(name, biography, birthDate, profilePic);
            
          },
        ))
      ],
    );
  }
}
Future<bool> postPerson(name, biography, birthDate, profilePic)async{
    String personid = await Api.postPerson(name, biography, birthDate);
    if(personid!="error"&&profilePic!=null){
      Api.postProfilePic(personid, profilePic);
      return true;
    }
    return false;
}
class ProfilePic extends StatefulWidget {
  const ProfilePic({super.key, required this.profilePic});

  @override
  State<ProfilePic> createState() => _ProfilePicState();

  final ValueChanged<Uint8List> profilePic;

}

class _ProfilePicState extends State<ProfilePic> {
  ImageProvider pic = const AssetImage("icons/LogoPhoMem.png");
  XFile? xfile;

  Future<void> _selectImage() async {
    xfile = await Api.getImageFilesystem();
    if (xfile != null) {
      Uint8List imageBytes = await xfile!.readAsBytes();
      setState(() {
        pic = MemoryImage(imageBytes);
        widget.profilePic(imageBytes);

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectImage,
      child: LayoutBuilder(
         builder: (context, constraints) {
            double size = constraints.maxWidth * 0.1; // Adjust the factor as needed
            return GestureDetector(
              onTap: _selectImage,
              child: CircleAvatar(
                backgroundImage: pic,
                radius: size,
              ),
            );
          },)
    );
  }
}

