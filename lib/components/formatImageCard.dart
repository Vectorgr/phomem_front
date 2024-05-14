import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
import 'package:phomem/Models/Memory.dart';

class FormatImageCard extends StatelessWidget {
  const FormatImageCard({
    super.key,
    required this.mem,
  });

  final Memory mem;
  final int maxTextLength = 60;
 
  @override
  Widget build(BuildContext context) {
    String titleText, descriptionText, urlImage;

    if(mem.title.length>maxTextLength){
      titleText = "${mem.title.substring(0, maxTextLength - 3)}...";
      descriptionText = "";
    }else if(mem.title.length + mem.description.length > maxTextLength){
      titleText = mem.title;
      descriptionText = "${mem.description.substring(0, maxTextLength-mem.title.length - 3)}...";
    }else{
      titleText = mem.title;
      descriptionText = mem.description;
    }

    if(mem.imageList==null){
      print("NULL??");
      //Imagen por defecto
      urlImage = 'https://img.freepik.com/foto-gratis/flor-purpura-margarita-osteospermum_1373-16.jpg?size=626&ext=jpg&ga=GA1.1.672697106.1714089600&semt=ais';
    }else{
      //Primera imagen de la lista
      urlImage = 'http://localhost:8000/images/${mem.imageList![0]}';
    }
    return TransparentImageCard(
      width: 300,
      height: 300,
      imageProvider: 
      NetworkImage(urlImage),
      title: Text(
        titleText,
        style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none),
      ),
      description: Text(
        descriptionText,
        style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.normal,
            color: Colors.white,
            decoration: TextDecoration.none),
      ),
    );
  }
}