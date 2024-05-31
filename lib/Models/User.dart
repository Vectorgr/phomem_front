import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  bool admin;

  User(
      {required this.id,
      required this.name,
      required this.admin});


  factory User.fromJson(Map<String, dynamic> json) {
    bool admin = false;
    if (json['admin'] == "true") {
      admin = true;
    }
    return User(
        id: json['id'],
        name: json['name'],
        admin: admin);
  }
  static List<User> fromJsonList(List<dynamic> jsonList) {
    final userList = <User>[];
    
    for (final json in jsonList) {
        userList.add(
          User.fromJson(json),
        );
    }
    return userList;
  }
  
}
