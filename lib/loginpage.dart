import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ADMIN/admin_dashboard.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_dashboard.dart';
import 'package:beposoft/registerationpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beposoft/pages/api.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'dart:convert';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  var url = "$api/api/login/";

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(api);
  }
  
  

  Future<void> storeUserData(String token,String department,String username) async {
    print("username$username");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
        await prefs.setString('department', department);
                await prefs.setString('username', username);
  }
void login(String email, String password, BuildContext context) async {
  print("eeeeeeeeeeeeeeeeeeeeeeeeee$email");
  print("PPPPPPPPPPPPPPPPPPPPPPPPPPPPP$password");
  try {
    var response = await http.post(
      Uri.parse(url),
      body: {"email": email, "password": password},
    );

    print("RRRRRRRRRRRRRRRRRRRREEEEEEEEEEEESSSSSSS${response.body}");

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var status = responseData['status'];


      print("RRRRRRRRRRRRRRDDDDDDDDDDDDDDDDDDDDDDDDDDDD$responseData");
      print(status);

      if (status == 'success') {
        var token = responseData['token'];
        var active = responseData['active'];
                var name = responseData['name'];


        print(token);
        print("DDDDDDDEEEEEEPPPPPPPPPPPPPAAAAARRRRRRRTTTTTTMEEEEENNTTTT===========$active");

        // Decode the token and store the ID in SharedPreferences
        try {
          final jwt = JWT.decode(token);
          var id = jwt.payload['id'];
          print("Decoded Token Payload: ${jwt.payload}");
          print("User ID: $id");

          // Save ID in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', id); // Store user ID
          await storeUserData(token,active,name); // Store token as needed

        } catch (e) {
          print("Token decode error: $e");
        }

        if (active == 'IT') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully logged in.'),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => dashboard()),
          );
        }

        if (active == 'warehouse') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully logged in.'),
            ),
          );
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => WarehouseDashboard()),
          );
        }
        if (active == 'BDO') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully logged in.'),
            ),
          );
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => bdo_dashbord()),
          );
        }
        if (active == 'COO') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully logged in.'),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => admin_dashboard()),
          );
        } 
        
         if (active == 'BDM')
         
          {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully logged in.'),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => bdm_dashbord()),
          );

        } 
        if (active == 'Accounts / Accounting') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully logged in.'),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => dashboard()),
          );
        } 
      } 
      
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Login failed.'),
          ),
        );
      }
    }
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('An error occurred. Please try again.'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Image.asset(
                "lib/assets/logo.png",
                width: 100, // Change width to desired size
                height: 100, // Change height to desired size
                fit: BoxFit
                    .contain, // Use BoxFit.contain to maintain aspect ratio
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        10), // Adjust the radius as needed
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 15, 195, 219),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            border: Border.all(
                                color: Color.fromARGB(255, 202, 202, 202)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 254, 252, 252)
                                    .withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                " Sign in",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              // Add more widgets here as needed
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: email,
                          decoration: InputDecoration(
                            labelText: 'email',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: password,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              login(email.text, password.text, context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 15, 195, 219),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      1), // Set your desired border radius
                                ),
                              ),
                              fixedSize: MaterialStateProperty.all<Size>(
                                Size(300,
                                    15), // Set your desired width and heigh
                              ),
                            ),
                            child: Text(
                              'Sign in',
                              style: TextStyle(color: Colors.white),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Register()));
                                },
                                child: Text(
                                  "I forgot my password",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 15, 195, 219)),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Register()));
                                },
                                child: Text(
                                  "Register a new membership",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 15, 195, 219)),
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}