import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

@JsonSerializable()
class Person {
  final String id;
  final String name;
  final String biography;
  final DateTime? birthDate;
  final Image? profilePic;

  Person(
      {required this.id,
      required this.name,
      required this.biography,
      this.birthDate,
      this.profilePic});


  factory Person.fromJson(Map<String, dynamic> json) {
        DateTime datet = DateFormat('dd/MM/yyyy').parse(json['birthDate']);
    return Person(
        id: json['id'],
        name: json['name'],
        biography: json['biography'],
        birthDate: datet);
  }
  static List<Person> fromJsonList(List<dynamic> jsonList) {
    final peopleList = <Person>[];
    
    for (final json in jsonList) {
        peopleList.add(
          Person.fromJson(json),
        );
    }
    return peopleList;
  }
  
}
