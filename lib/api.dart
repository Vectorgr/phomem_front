import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:phomem/Models/ImageMem.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:uuid/uuid.dart';

class Api {
  static String host = "http://localhost:8000";
  //Images
  static Future<XFile?> getImageFilesystem() {
    return ImagePicker().pickImage(source: ImageSource.gallery);
  }
  
  static Future<String> postImage(String memoryid, Uint8List imageData) async {
    print(memoryid);
    List<int> imageBytes = imageData;
    var uri = Uri.parse("$host/images");
    var request = http.MultipartRequest('POST', uri);
    request.headers["Content-Type"] = 'application/json';
    request.files.add(http.MultipartFile.fromBytes("image",imageBytes,  filename: "image.png"));
   
    request.fields['parent_memory'] = memoryid;
    var response = await request.send();
    Map<String, dynamic> jsonResponse = json.decode(await response.stream.bytesToString());
    String id = jsonResponse['id'];
    
    print(response.statusCode);
    if(response.statusCode!=200){
      print(response.stream.bytesToString());
    }
    print(id);
    return id; 
  }


  //Memory
  static Future<Memory> getMemory(String id) async {
    final response = await http.get(Uri.parse("$host/$id"));

    String responseData = utf8.decode(response.bodyBytes);
    Memory m = Memory.fromJson(json.decode(responseData));
    print("$id | ${m.title}");
    return m;
  }

  Future<List<Memory>> getMemories() async {
    final response = await http.get(Uri.parse("$host/"));

    if (response.statusCode == 200) {
      String responseData = utf8.decode(response.bodyBytes);
      for (Memory m in (json.decode(responseData) as List)
          .map((i) => Memory.fromJson(i))
          .toList()) {}
      return (json.decode(responseData) as List)
          .map((i) => Memory.fromJson(i))
          .toList();
    } else {
      throw Exception('Failed to load album');
    }
  }

  static Future<String> postMemory(
      String title, String description, String date) async {
    var uri = Uri.parse("$host/");

    // Convertir los datos a formato JSON
    var requestBody = json.encode({
      'title': title,
      'description': description,
      'date': date,
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );
    if (response.statusCode != 200) {
      print("Error in memory upload");
    }
    var responseMemory = jsonDecode(response.body) as Map<String, dynamic>;

    return responseMemory['id'];
  }
static Future<String> updateMemory(
    Memory mem) async {
    var uri = Uri.parse("$host/${mem.id}");
    
    // Convertir los datos a formato JSON
    var requestBody = json.encode({
      'id':mem.id,
      'title': mem.title,
      'description': mem.description,
      'date': DateFormat('dd/MM/yyyy').format(mem.date),
      'images':mem.imageList
    });

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );
    if (response.statusCode != 200) {
      print("Error in memory upload");
      print(response.body);
      return "error";
    }
    
    print(response.body);
    var responseMemory = jsonDecode(response.body) as Map<String, dynamic>;
    
    return responseMemory['id'];
  }
  
}
