import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';
import 'package:phomem/Models/Location.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/Models/Person.dart';
import 'package:phomem/Models/User.dart';
import 'package:phomem/login/loginPage.dart';
import 'package:phomem/main.dart';
import 'package:phomem/store/sharedPreferences.dart';

class Api {
  static String host = "";
  static Dio dio = Dio();

  static Future<void> configureDio() async {
    final SharedPrefsHelper prefsHelper = SharedPrefsHelper();
    print("SHARED:");
    print(await prefsHelper.getToken());
    print(await prefsHelper.getUrl());
    String? url = await prefsHelper.getUrl();
    if (url == null || url == "") {
      openLoginPage();
      return; //Sale para que no se convierta en bucle
    } else {
      host = url;
    }
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = await prefsHelper.getToken();
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        if ((e.response?.statusCode == 403 || e.response?.statusCode == 404)) {
          openLoginPage();
        }
        return handler.next(e);
      },
    ));
  }

  static Future<void> logout() async {
    final SharedPrefsHelper prefsHelper = SharedPrefsHelper();
    await prefsHelper.removeToken();
    configureDio();
    openLoginPage();
  }

  //Images
  static Future<XFile?> getImageFilesystem() {
    return ImagePicker().pickImage(source: ImageSource.gallery);
  }

  static Future<String> postImage(String memoryid, Uint8List imageData) async {
    print(memoryid);
    List<int> imageBytes = imageData;
    var formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(imageBytes, filename: "image.png"),
      'parent_memory': memoryid,
    });

    try {
      var response = await dio.post("$host/images", data: formData);
      String id = response.data['id'];
      print(response.statusCode);
      print(id);
      return id;
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      return 'error';
    }
  }

  static Future<List<ImageProvider>?> getImagesFromMemory(Memory memory) async {
    List<ImageProvider>? imageDataList = [];

    if (memory.imageList == null) {
      return imageDataList;
    }

    for (var imageId in memory.imageList!) {
      try {
        var response = await dio.get("$host/images/$imageId",
            options: Options(responseType: ResponseType.bytes));
        if (response.statusCode == 200) {
          imageDataList.add(MemoryImage(Uint8List.fromList(response.data)));
        }
      } catch (e) {
        // Handle the exception appropriately
        print('Error fetching image $imageId: $e');
      }
    }
    return imageDataList;
  }

  static Future<ImageProvider> getImage(String? id) async {
    if (id == null) {
      return AssetImage("icons/LogoPhoMem.png");
    }
    try {
      //getImage
      print("Peticion: $host/images/$id");
      var response = await dio.get("$host/images/$id",
          options: Options(responseType: ResponseType.bytes));
      if (response.data.isNotEmpty) {
        return MemoryImage(Uint8List.fromList(response.data));
      }
    } on DioException catch (e) {
      print(
          'Error getImage(100): ${e.response?.statusCode} ${e.response?.statusMessage}');
    }
    return AssetImage("icons/LogoPhoMem.png");
  }

  // Memory
  static Future<Memory> getMemory(String id) async {
    try {
      final response = await dio.get("$host/$id");
      Memory m = Memory.fromJson(response.data);
      print("$id | ${m.title}");
      return m;
    } on DioException catch (e) {
      print(
          'Error getMemory(117): ${e.response?.statusCode} ${e.response?.statusMessage}');
      throw Exception('Failed to load memory');
    }
  }

  static Future<List<Memory>> getMemories() async {
    final SharedPrefsHelper prefsHelper = SharedPrefsHelper();

    try {
      print("$host");
      print(await prefsHelper.getToken());
      final response = await dio.get("$host/");
      return (response.data as List).map((i) => Memory.fromJson(i)).toList();
    } on DioException catch (e) {
      print(
          'Error getMemories(131): ${e.response?.statusCode} ${e.response?.statusMessage}');
      throw Exception('Failed to load memories');
    }
  }

  static Future<String> postMemory(
      String title, String description, String date) async {
    var requestBody = json.encode({
      'title': title,
      'description': description,
      'date': date,
    });

    try {
      final response = await dio.post("$host/", data: requestBody);
      if (response.statusCode != 200) {
        print("Error in memory upload");
        return "error";
      }
      var responseMemory = response.data as Map<String, dynamic>;
      return responseMemory['id'];
    } on DioException catch (e) {
      print(
          'Error postMemory(153): ${e.response?.statusCode} ${e.response?.statusMessage}');
      return 'error';
    }
  }

  static Future<bool> deleteMemory(String id) async {
    print("$host/$id");
    try {
      final response = await dio.delete("$host/$id");
      if (response.statusCode != 200) {
        print("Error in memory deletion");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print(
          'Error deleteMemory: ${e.response?.statusCode} ${e.response?.statusMessage}');
      return false;
    }
  }

  static Future<String> updateMemory(Memory mem) async {
    var requestBody = json.encode({
      'id': mem.id,
      'title': mem.title,
      'description': mem.description,
      'date': DateFormat('dd/MM/yyyy').format(mem.date),
      'images': mem.imageList,
    });

    try {
      final response = await dio.put("$host/${mem.id}", data: requestBody);
      if (response.statusCode != 200) {
        print("Error in memory upload");
        return "error";
      }
      var responseMemory = response.data as Map<String, dynamic>;
      return responseMemory['id'];
    } on DioException catch (e) {
      print(
          'Error updateMemory(176): ${e.response?.statusCode} ${e.response?.statusMessage}');
      return 'error';
    }
  }

  // Person list
  static Future<List<Person>> getPersonList() async {
    try {
      final response = await dio.get("$host/people");
      return (response.data as List).map((i) => Person.fromJson(i)).toList();
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      throw Exception('Failed to load persons');
    }
  }

  static Future<ImageProvider> getProfilePic(String personid) async {
    var response = await dio.get("$host/people/$personid/image",
        options: Options(responseType: ResponseType.bytes));
    if (response.data.isNotEmpty) {
      return MemoryImage(Uint8List.fromList(response.data));
    }
    return AssetImage("icons/LogoPhoMem.png");
  }

  static Future<String> postProfilePic(
      String locationId, Uint8List imageBytes) async {
    String imageUrl = "$host/people/$locationId/image";
    var formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(imageBytes, filename: "image.png"),
    });

    try {
      var response = await dio.post(imageUrl, data: formData);
      String id = response.data['id'];

      return id;
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      return 'error';
    }
  }

  static Future<String> postPerson(
      String name, String biography, String date) async {
    var requestBody = json.encode({
      'name': name,
      'biography': biography,
      'birthDate': date,
    });

    try {
      final response = await dio.post("$host/people", data: requestBody);
      if (response.statusCode != 200) {
        print("Error in person upload");
        return "error";
      }
      var responsePerson = response.data as Map<String, dynamic>;
      return responsePerson['id'];
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      return 'error';
    }
  }

  static Future<bool> deletePerson(String personid) async {
    final response = await dio.delete("$host/people/$personid");
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

// LOCATION
  static Future<List<Location>> getLocationList() async {
    try {
      final response = await dio.get("$host/locations");
      return (response.data as List).map((i) => Location.fromJson(i)).toList();
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      throw Exception('Failed to load locations');
    }
  }

  static Future<ImageProvider> getLocationImage(Location location) async {
    String imageUrl = "${Api.host}/locations/${location.id}/image";
    try {
      var response = await dio.get(imageUrl,
          options: Options(responseType: ResponseType.bytes));

      if (response.data.isNotEmpty) {
        return MemoryImage(response.data);
      }
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      throw Exception('Failed to load locations');
    }

    return NetworkImage("https://via.placeholder.com/300x1000");
  }

  static Future<String> postLocationImage(
      String locationId, Uint8List imageBytes) async {
    String imageUrl = "${Api.host}/locations/$locationId/image";
    var formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(imageBytes, filename: "image.png"),
    });

    try {
      var response = await dio.post(imageUrl, data: formData);
      String id = response.data['id'];

      return id;
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      return 'error';
    }
  }

  static Future<String> postLocation(String name, String description,
      double? latitude, double? longitude) async {
    String requestBody;
    if (latitude != null || longitude != null) {
      requestBody = json.encode({
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
      });
    } else {
      requestBody = json.encode({'name': name, 'description': description});
    }

    try {
      final response = await dio.post("$host/locations", data: requestBody);
      if (response.statusCode != 200) {
        print("Error in location upload");
        return "error";
      }
      var responseLocation = response.data as Map<String, dynamic>;
      return responseLocation['id'];
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      return 'error';
    }
  }

//LOGIN
  static Future<String> login(String name, String password, String url) async {
    var requestBody = json.encode({
      'name': name,
      'pass': password,
    });
    final response = await dio.post("$url/login", data: requestBody);
    return response.data;
  }

  //REGISTER USER
  static Future<String> addUser(String name, String password) async {
    var requestBody = json.encode({
      'name': name,
      'pass': password,
    });
    final response = await dio.post("$host/users", data: requestBody);
    var responseUser = response.data as Map<String, dynamic>;
    return responseUser['id'];
  }

  static Future<List<User>> getUsers() async {
    try {
      final response = await dio.get("$host/users");
      print(response.data);
      return (response.data as List).map((i) => User.fromJson(i)).toList();
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      throw Exception('Failed to load users');
    }
  }

  static Future<String> postUser(String name, bool isAdmin) async {
    String requestBody = json.encode({'name': name, 'admin': isAdmin});

    try {
      final response = await dio.post("$host/users", data: requestBody);
      if (response.statusCode != 200) {
        print("Error in location upload");
        return "error";
      }
      var responseUser = response.data as Map<String, dynamic>;
      return responseUser['id'];
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      return 'error';
    }
  }

  static Future<bool> deleteUser(String userid) async {
    final response = await dio.delete("$host/users/$userid");
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<String> updateUser(
      String userid, String name, bool isAdmin) async {
    String requestBody =
        json.encode({'id': userid, 'name': name, 'admin': isAdmin});

    try {
      final response = await dio.put("$host/users/$userid", data: requestBody);
      if (response.statusCode != 200) {
        print("Error in location upload");
        return "error";
      }
      var responseUser = response.data as Map<String, dynamic>;
      return responseUser['id'];
    } on DioException catch (e) {
      print('Error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      return 'error';
    }
  }
}

bool openLoginPage() {
  PhomemApp.navigatorKey.currentState?.push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return LoginPage();
    },
  ));

  return true;
}
