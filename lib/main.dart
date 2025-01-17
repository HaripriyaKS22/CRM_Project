import 'dart:convert';

import 'package:beposoft/pages/ADMIN/admin_dashboard.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_dashboard.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;

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
    getbank();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
 Future<void> storeUserData(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

bool tokenn=true;
  var department;
  void check() async {
    final token = await gettokenFromPrefs();
    final dep= await getdepFromPrefs();
    print("depppppppppp$dep");
    try {
          final jwt = JWT.decode(token!);
          var dep = jwt.payload['dep'];
          print("Decoded Token Payload: ${jwt.payload}");
          print("User ID: $dep");

        } catch (e) {
          print("Token decode error: $e");
        }
    print("$token");
    setState(() {
      department=dep;
      tok = token != null;
      print(tok);
    });
  }
Future<void> getbank() async{
  final token=await gettokenFromPrefs();
  try{
    final response= await http.get(Uri.parse('$api/api/banks/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
    List<Map<String, dynamic>> banklist = [];
print("mainnnnnnnnnnnnnnnnnnnnnnn:${response.body}");
final parsed = jsonDecode(response.body);
print('mssssssssssggggggggggggggggg${parsed['message']}');
if(parsed['message']=="Token has expired"){
  tokenn=false;

}
     

  }
  catch(e){
    print("error:$e");
  }
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      home:tok
          ? department == "BDM"
              ? bdm_dashbord()  // Navigate to IT Dashboard if department is "it"

              : department == "warehouse"
                  ? WarehouseDashboard()  // Navigate to Warehouse Dashboard if department is "warehouse"
                  : department == "BDO"
                  ? bdo_dashbord() 
                  : department == "Admin"
                  ? admin_dashboard()
                  : department == "Accounts / Accounting "
                  ? admin_dashboard()
                   : department == "IT"
                  ? admin_dashboard()
                  : dashboard()   // Else, navigate to the normal Dashboard
          : login(), 
    );
  }
}
