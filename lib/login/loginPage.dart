import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/Models/Person.dart';
import 'package:phomem/api.dart';
import 'package:intl/intl.dart';
import 'package:phomem/main.dart';
import 'package:phomem/store/sharedPreferences.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: FormBuilder(
        child: Column(children: [
          Padding(padding: EdgeInsets.only(top: 20)),
          Row(children: [
            Expanded(
              flex: 2,
              child: Container(),
            ),
            Expanded(
                flex: 6,
                child: Padding(
                    padding: EdgeInsets.all(10), child: LoginColumn())),
            Expanded(
              flex: 2,
              child: Container(),
            ),
          ]),
        ]),
      )),
    );
  }
}

class LoginColumn extends StatefulWidget {
  const LoginColumn({super.key});

  @override
  State<LoginColumn> createState() => _LoginColumnState();
}

class _LoginColumnState extends State<LoginColumn> {
  final SharedPrefsHelper prefsHelper = SharedPrefsHelper();
  String? url;
  String? initURL;
  @override
  void initState() {
    super.initState();
    getUrl(); //Get url initial value if not null
    
  }

  Future<void> getUrl() async{
    String? url = await prefsHelper.getUrl();
    if(url!=null){
      initURL = url;
    }
    initURL = "";
  }
  @override
  Widget build(BuildContext context) {

    String name = "", password = "";
    return Column(
      children: [
        Container(
            width: 200,
            height: 200,
            foregroundDecoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('icons/LogoPhoMem.png'), fit: BoxFit.fill),
            )),
        Text("PhotoMemories",
            style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                decoration: TextDecoration.none)),
        FormBuilderTextField(
          //title
          name: 'Url',
          initialValue: initURL,
          onChanged: (val) {
            if (val != null) {
              url = val;
            }
          },

          decoration: InputDecoration(
            labelText: 'API URL',
            hintText: 'http://api.phomem.app',
            labelStyle: TextStyle(fontSize: 20.0, color: Colors.blue),
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.blue),
          ),
          style: TextStyle(
              color: Colors.blue, fontSize: 20 // Cambia el color del texto aquí
              ),
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        FormBuilderTextField(
          //title
          name: 'Name',
          onChanged: (val) {
            if (val != null) {
              name = val;
            }
          },
          decoration: InputDecoration(
            labelStyle: TextStyle(fontSize: 20.0, color: Colors.blue),
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.blue),
            labelText: 'Username',
          ),
          style: TextStyle(
              color: Colors.blue, fontSize: 20 // Cambia el color del texto aquí
              ),
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        FormBuilderTextField(
          //description
          name: 'Password',
          obscureText: true,
          onChanged: (val) {
            if (val != null) {
              password = val;
            }
          },
          decoration: InputDecoration(
            labelStyle: TextStyle(fontSize: 20.0, color: Colors.blue),
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.blue),
            labelText: 'Password',
          ),
          style: TextStyle(
              color: Colors.blue, fontSize: 20 // Cambia el color del texto aquí
              ),
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Center(
            child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                }
                return null; // Use the component's default.
              },
            ),
          ),
          child: const Text('Login'),
          onPressed: () async {
            if (url != null) {
              prefsHelper.saveUrl(url!);
              String? response = await Api.login(name, password, url!);
              if (response.isNotEmpty) {
                await prefsHelper.saveToken(response);
                await Api.configureDio();
                PhomemApp.navigatorKey.currentState?.pop();
              }
            }
          },
        ))
      ],
    );
  }
}
Widget logOut(){
    final SharedPrefsHelper prefsHelper = SharedPrefsHelper();
    prefsHelper.removeToken();
    return LoginPage();

}
