import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

@JsonSerializable()
class ImageMem {
  final Uuid id;
  final ByteBuffer image_data;
  final Uuid parent_id;

  ImageMem({required this.id, required this.image_data, required this.parent_id});

}