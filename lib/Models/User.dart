
import 'package:json_annotation/json_annotation.dart';

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
