import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

void main() {
  runApp(beposoftmain());
}

class beposoftmain extends StatefulWidget {
  const beposoftmain({super.key});

  @override
  State<beposoftmain> createState() => _beposoftmainState();
}

class _beposoftmainState extends State<beposoftmain> {
  bool tok = false;

  @override
  void initState() {
    super.initState();
    check();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
 Future<void> storeUserData(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  void check() async {
    final token = await gettokenFromPrefs();
    try {
          final jwt = JWT.decode(token!);
          var id = jwt.payload['id'];
          print("Decoded Token Payload: ${jwt.payload}");
          print("User ID: $id");

          // Save ID in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', id); // Store user ID
          await storeUserData(token); // Store token as needed
        } catch (e) {
          print("Token decode error: $e");
        }
    print("$token");
    setState(() {
      tok = token != null;
      print(tok);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: tok ? dashboard() : login(),
    );
  }
}
