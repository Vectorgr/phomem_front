import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phomem/api.dart';

class DialogAddLocation extends StatelessWidget {
  const DialogAddLocation({super.key});

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
                    padding: EdgeInsets.all(10), child: AddDialogColumn())),
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

class AddDialogColumn extends StatelessWidget {
  const AddDialogColumn({super.key});
  @override
  Widget build(BuildContext context) {
    String? name;
    String description = "";
    double? longitude, latitude;
    Uint8List? locationPic;
    return Column(
      children: [
        ProfilePic(profilePic: (value) {
          locationPic = value;
        }),
        Row(children: [
          Expanded(
            child: FormBuilderTextField(
              name: 'Name',
              onChanged: (val) {
                if (val != null) {
                  name = val;
                }
              },
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Write a name',
              ),
            ),
          ),
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
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Row(
          children: [
            
            Expanded(
              child: FormBuilderTextField(
                name: 'Latitude',
                onChanged: (val) {
                  if (val != null) {
                    try {
                      latitude = double.tryParse(val);
                    } catch (e) {
                      latitude = null;
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'Write latitude',
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 20)),
            Expanded(
              child: FormBuilderTextField(
                name: 'Longitude',
                onChanged: (val) {
                  if (val != null) {
                    try {
                      longitude = double.tryParse(val);
                    } catch (e) {
                      longitude = null;
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'Write longitude',
                ),
              ),
            ),
            
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        
        Center(
            child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                }
                return null;
              },
            ),
          ),
          child: const Text('Save location'),
          onPressed: () {
            if (name != null) {
              if (checkCoords(latitude, longitude)) {
                postLocation(
                    name!, description, latitude, longitude, locationPic);
              } else {
                postLocation(name!, description, null, null, locationPic);
              }
            }
          },
        ))
      ],
    );
  }
}

Future<bool> postLocation(
    name, description, longitude, latitude, locationPic) async {
  String locationid =
      await Api.postLocation(name, description, longitude, latitude);
      print("creando loc");
  if (locationid != "error" && locationPic != null) {
    Api.postLocationImage(locationid, locationPic);
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

            return GestureDetector(
                onTap: _selectImage,
                child: Container(
                    width: 250, // Ancho específico
                    height: 250, // Alto específico
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:pic, // Ruta de tu imagen
                        fit: BoxFit
                            .cover, // Ajusta cómo se muestra la imagen dentro del contenedor
                      ),
                    )));
          },
        ));
  }
}

bool checkCoords(double? lat, double? lon) {
  print("$lat! + $lon!");
  if (lat != null && lon != null) {
    print("NOTNUULL");
    if (lat < -90 || lat > 90) {
      print("a");
      return false;
    }
    if (lon < -180 || lon > 180) {
      return false;
    }
  }

  return true;
}
