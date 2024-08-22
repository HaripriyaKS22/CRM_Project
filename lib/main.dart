import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';

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

  void check() async {
    final token = await gettokenFromPrefs();
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
