import 'package:json_annotation/json_annotation.dart';
import 'package:phomem/Models/Person.dart';
import 'package:intl/intl.dart';


@JsonSerializable()
class Memory {
  final String id;
  String title;
  String description;
  DateTime date;
  List<String>? personList =  List.empty();
  List<String>? imageList =  List.empty();

  Memory( 
      {required this.id,
      required this.title,
      required this.description,
      required this.date,
      this.personList,
      this.imageList});
  static List<Memory> fromJsonList(List<dynamic> jsonList) {
    final memoryList = <Memory>[];
    
    for (final json in jsonList) {
        memoryList.add(
          Memory.fromJson(json),
        );
    }
    return memoryList;
  }
  void addImage(String id){
    imageList ??= List.empty(growable: true); //If imagelist is null
    imageList!.add(id);
  }
  factory Memory.fromJson(Map<String, dynamic> json) {
    String? dateString = json['date']; // Suponiendo que 'date' es la clave en tu objeto JSON que contiene la fecha como una cadena de texto
    DateTime datet = DateFormat('dd/MM/yyyy').parse(json['date']);
    List<String>? imageList;

    if(json['images']!=null){
      imageList = List<String>.from(json['images']);
    }
    return Memory(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: datet,
      personList: json['people'],
      imageList: imageList
    );
  }

  
}
