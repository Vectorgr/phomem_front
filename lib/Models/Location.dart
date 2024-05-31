import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

@JsonSerializable()
class Location {
  final String id;
  final String name;
  final String description;
  final double? latitude;
  final double? longitude;
  final Image? locationImage;

  Location(
      {required this.id,
      required this.name,
      required this.description,
      this.latitude,
      this.longitude,
      this.locationImage});


  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        latitude: json['latitude'],
        longitude: json['longitude']
    );
  }
  static List<Location> fromJsonList(List<dynamic> jsonList) {
    final locationList = <Location>[];
    
    for (final json in jsonList) {
        locationList.add(
          Location.fromJson(json),
        );
    }
    return locationList;
  }
  
}
