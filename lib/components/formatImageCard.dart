import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/api.dart';
import 'package:phomem/components/viewMemoryDialog/dialogViewMemory.dart';

class FormatImageCard extends StatelessWidget {
  const FormatImageCard({
    super.key,
    required this.mem,
  });

  final Memory mem;
  final int maxTextLength = 60;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider>(
        future: Api.getImage(mem.imageList?[0]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error al cargar la imagen'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No se encontró la imagen'));
          } else {
            return GestureDetector(
              onTap: () => _showFullScreenImage(context, mem),
              child: TransparentImageCard(
                width: 300,
                height: 300,
                imageProvider: snapshot.data!,
                title: Text(
                  mem.title,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                description: Text(
                  mem.description,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            );
          }
        });
  }
}



void _showFullScreenImage(BuildContext context, Memory memory) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return DialogViewMemory(
        memory: memory,
      );
    },
  ));
}
