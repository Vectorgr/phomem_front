import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

@JsonSerializable()
class Person {
  final Uuid id;
  final String name;
  final String biography;
  final DateTime birthDate;
  final ByteBuffer profilePic;

  Person(
      {required this.id,
      required this.name,
      required this.biography,
      required this.birthDate,
      required this.profilePic});
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
        id: json['id'],
        name: json['name'],
        biography: json['biography'],
        birthDate: json['birthDate'],
        profilePic: json['profilePic']);
  }
}
