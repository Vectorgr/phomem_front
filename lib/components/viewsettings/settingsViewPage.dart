import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:phomem/Models/User.dart';
import 'package:phomem/api.dart';

class SettingsViewPage extends StatefulWidget {
  const SettingsViewPage({super.key});

  @override
  State<SettingsViewPage> createState() => _SettingsViewPageState();
}

class _SettingsViewPageState extends State<SettingsViewPage> {
  @override
  Widget build(BuildContext context) {
    void reloadPage() {
      setState(() {});
    }

    return Center(
      child: Row(
        children: [
          Expanded(flex: 2, child: Container()),
          Expanded(
              flex: 6,
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Text(
                    "Settings:",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Account:",
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(children: [
                    Padding(padding: EdgeInsets.only(left: 50)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        onPressed: () {Api.logout();},
                        child: Row(
                          children: [
                            Text("Logout"),
                            Padding(padding: EdgeInsets.only(left: 25)),
                            Icon(Icons.logout_outlined)
                          ],
                        ))
                  ]),
                  SizedBox(height: 20),
                  
                  Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "Users manager:",
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      AddUserTextFields(refresh: reloadPage),
                      SizedBox(height: 20),
                      Row(children: [
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                        Expanded(
                            flex: 6,
                            child: Text(
                              "Name",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w100,
                                color: Colors.black,
                              ),
                            )),
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                        Expanded(
                            flex: 2,
                            child: Text(
                              "Admin",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w100,
                                color: Colors.black,
                              ),
                            )),
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                      ]),
                      FutureBuilder(
                          future: Api.getUsers(),
                          builder:
                              (context, AsyncSnapshot<List<User>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text("Error: ${snapshot.error}"),
                              );
                            } else if (snapshot.hasData) {
                              return UserList(
                                users: snapshot.data!,
                                refresh: reloadPage,
                              );
                            } else {
                              return Center(
                                child: Text("No data available"),
                              );
                            }
                          })
                    ],
                  ),
                ],
              )),
          Expanded(flex: 2, child: Container()),
        ],
      ),
    );
  }
}

class AddUserTextFields extends StatelessWidget {
  final VoidCallback refresh;

  const AddUserTextFields({
    super.key,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    String? name;
    String? pass;

    return Row(children: [
      Expanded(
        flex: 2,
        child: Container(),
      ),
      Expanded(
        flex: 4,
        child: FormBuilderTextField(
          onChanged: (val) {
            name = val;
          },
          decoration: InputDecoration(
            labelText: 'Name',
            hintText: 'Write a name',
          ),
          name: "UserNametf",
        ),
      ),
      Expanded(
        flex: 1,
        child: Container(),
      ),
      Expanded(
        flex: 4,
        child: FormBuilderTextField(
          onChanged: (val) {
            pass = val;
          },
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Write a password',
          ),
          name: "UserPasswordtf",
        ),
      ),
      Expanded(
        flex: 1,
        child: Container(),
      ),
      Expanded(
        flex: 3,
        child: ElevatedButton(
          onPressed: () async {
            if (name != null && pass != null) {
              await Api.addUser(name!, pass!);
              refresh();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Name and Password cannot be empty')),
              );
            }
          },
          child: Text("Add user"),
        ),
      ),
    ]);
  }
}

class UserList extends StatefulWidget {
  final List<User> users;
  final VoidCallback refresh;

  UserList({required this.users, required this.refresh});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.users.length,
      itemBuilder: (context, index) {
        User user = widget.users[index];
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 6,
                  child: Text(user.name),
                ),
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: Checkbox(
                    value: user.admin,
                    onChanged: (value) async {
                      setState(() {
                        user.admin = value!;
                      });
                      await Api.updateUser(user.id, user.name, user.admin);
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: IconButton(
                    iconSize: 30,
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Api.deleteUser(user.id);
                      widget.refresh();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool getAdmin(User user) {
    return user.admin;
  }
}
