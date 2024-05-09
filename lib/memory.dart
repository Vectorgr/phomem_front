import 'dart:convert';
import 'dart:developer';

import 'package:uuid/uuid.dart';

class Memory {
  final String id;
  final String title;
  final String description;

  const Memory({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
  static List<Memory> fromJsonList(List<dynamic> jsonList) {
    final memoryList = <Memory>[];
    
    for (final json in jsonList) {
        memoryList.add(
          Memory.fromJson(json),
        );
        log(json);
    }
    return memoryList;
  }
  @override
  String toString() {
    return '{ ${this.title}, ${this.description} }';
  }
}
