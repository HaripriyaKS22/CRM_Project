import 'dart:io';


import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';


import 'package:flutter_colorpicker/flutter_colorpicker.dart';



import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/new_grv.dart';
import 'package:beposoft/pages/ACCOUNTS/profile.dart';
import 'package:beposoft/pages/ACCOUNTS/transfer.dart';




import 'package:beposoft/main.dart';
import 'package:beposoft/pages/ACCOUNTS/add_credit_note.dart';
import 'package:beposoft/pages/ACCOUNTS/add_recipts.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/recipts_list.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_stock.dart';
import 'package:beposoft/pages/ACCOUNTS/credit_note_list.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/new_product.dart';
import 'package:beposoft/pages/ACCOUNTS/order_request.dart';
import 'package:beposoft/pages/ACCOUNTS/purchases_request.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
   drower d=drower();
   Widget _buildDropdownTile(BuildContext context, String title, List<String> options) {
    return ExpansionTile(
      title: Text(title),
      children: options.map((option) {
        return ListTile(
          title: Text(option),
          onTap: () {
            Navigator.pop(context);
            d.navigateToSelectedPage(context, option); // Navigate to selected page
          },
        );
      }).toList(),
    );
  }
  int _selectedIndex = 0;

  List<Widget> _forms = [
    Form1(),
    Form2(),
    Form3(),
    Form4(),
  ];
void logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  await prefs.remove('token');

  // Use a post-frame callback to show the SnackBar after the current frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged out successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  });

  // Wait for the SnackBar to disappear before navigating
  await Future.delayed(Duration(seconds: 2));

  // Navigate to the HomePage after the snackbar is shown
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => login()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Image.asset('lib/assets/profile.png'),
            onPressed: () {},
          ),
        ],
      ),
          drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/logo.png",
                        width: 150, // Change width to desired size
                        height: 150, // Change height to desired size
                        fit: BoxFit
                            .contain, // Use BoxFit.contain to maintain aspect ratio
                      ),
                    ],
                  )),
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => dashboard()));
                },
              ),
              
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Company'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_company()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Departments'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => add_department()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Supervisors'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => add_supervisor()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Family'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_family()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Bank'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_bank()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('States'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_state()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Attributes'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_attribute()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Services'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CourierServices()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
               ListTile(
                leading: Icon(Icons.person),
                title: Text('Delivery Notes'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WarehouseOrderView(status: null,)));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              Divider(),
              _buildDropdownTile(context, 'Reports', [
                'Sales Report',
                'Credit Sales Report',
                'COD Sales Report',
                'Statewise Sales Report',
                'Expence Report',
                'Delivery Report',
                'Product Sale Report',
                'Stock Report',
                'Damaged Stock'
              ]),
              _buildDropdownTile(context, 'Customers', [
                'Add Customer',
                'Customers',
              ]),
              _buildDropdownTile(context, 'Staff', [
                'Add Staff',
                'Staff',
              ]),
              _buildDropdownTile(context, 'Credit Note', [
                'Add Credit Note',
                'Credit Note List',
              ]),
              _buildDropdownTile(context, 'Proforma Invoice', [
                'New Proforma Invoice',
                'Proforma Invoice List',
              ]),
              _buildDropdownTile(context, 'Delivery Note',
                  ['Delivery Note List', 'Daily Goods Movement']),
              _buildDropdownTile(
                  context, 'Orders', ['New Orders', 'Orders List']),
              Divider(),
              Text("Others"),
              Divider(),
              _buildDropdownTile(context, 'Product', [
                'Product List',
                'Product Add',
                'Stock',
              ]),
              _buildDropdownTile(context, 'Expence', [
                'Add Expence',
                'Expence List',
              ]),
              _buildDropdownTile(
                  context, 'GRV', ['Create New GRV', 'GRVs List']),
              _buildDropdownTile(context, 'Banking Module',
                  ['Add Bank ', 'List', 'Other Transfer']),
              Divider(),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Methods'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Methods()));
                },
              ),
              ListTile(
                leading: Icon(Icons.chat),
                title: Text('Chat'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () {
                  logout();
                },
              ),
            ],
          ),
        ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Text(
              "PROFILE",
              style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 7.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                height: 65,
                child: Row(children: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(
                            255, 205, 205, 205), // Text color of the button
                        elevation: 5, // Elevation of the button
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10) // Rounded corners
                            ),
                        padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 34), // Padding inside the button
                      ),
                      child: Text("Profile Settings")),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(
                            255, 205, 205, 205), // Text color of the button
                        elevation: 5, // Elevation of the button
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10) // Rounded corners
                            ),
                        padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 34), // Padding inside the button
                      ),
                      child: Text("Informations")),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(
                            255, 205, 205, 205), // Text color of the button
                        elevation: 5, // Elevation of the button
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10) // Rounded corners
                            ),
                        padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 34), // Padding inside the button
                      ),
                      child: Text(" Notiification History")),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(
                            255, 205, 205, 205), // Text color of the button
                        elevation: 5, // Elevation of the button
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10) // Rounded corners
                            ),
                        padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 34), // Padding inside the button
                      ),
                      child: Text("Leave Request")),
                  SizedBox(width: 10),
                ]),
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Swipe for more..",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  width: 8,
                ),
                Icon(Icons.arrow_circle_right_rounded)
              ],
            ),
            SizedBox(height: 20),
            _forms[_selectedIndex],
          ],
        ),
      ),
    );
  }

  void _navigateToSelectedPage(BuildContext context, String selectedOption) {
    switch (selectedOption) {
      case 'Option 1':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => credit_note_list()),
        );
        break;
      case 'Option 2':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => customer_list()),
        );
        break;
      case 'Option 3':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_receipts()),
        );
        break;
      case 'Option 4':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;
      case 'Option 5':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;
      case 'Option 6':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;
      case 'Option 7':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;
      case 'Option 8':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;

      default:
        break;
    }
  }
}

//111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

class Form1 extends StatefulWidget {
  @override
  State<Form1> createState() => _Form1State();
}

class _Form1State extends State<Form1> {
  List<String> purchasetype = [
    "Raw type",
    'For sale',
  ];
  String selecttype = "Raw type";

  List<String> addedby = ["jeshiya", 'nimitha', 'hanvi', 'sulfi', 'yeshitha'];
  String selectaddby = "jeshiya";
  double number = 0.00;
  double rate = 0.00;
  double margin = 0.00;

  var selectedfile2;
  var selectedfile1;

  void incrementNumber() {
    setState(() {
      number +=
          0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      controller.text = number.toStringAsFixed(2);
    });
  }

  void incrementrate() {
    setState(() {
      rate +=
          0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      controller2.text = rate.toStringAsFixed(2);
    });
  }

  void incrementmargin() {
    setState(() {
      margin +=
          0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      controller3.text = margin.toStringAsFixed(2);
    });
  }

  void decrementNumber() {
    setState(() {
      if (number >= 0.01) {
        number -=
            0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller.text = number.toStringAsFixed(2);
      }
    });
  }

  void decrementrate() {
    setState(() {
      if (rate >= 0.01) {
        rate -=
            0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller2.text = rate.toStringAsFixed(2);
      }
    });
  }

  void decrementmargin() {
    setState(() {
      if (margin >= 0.01) {
        margin -=
            0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller3.text = margin.toStringAsFixed(2);
      }
    });
  }

  final TextEditingController controller = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = number.toStringAsFixed(2);
  }

  Color currentColor = Colors.black;

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<String> gender = ["male", 'female', 'other'];
  String selectgender = "male";

  List<String> status = ["single", 'married', 'divorced'];
  String selectstatus = "single";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                width: 700,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 10),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 38, 156, 235),
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
                                "Account setup",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              // Add more widgets here as needed
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Name",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Username",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "New Password(Only if you want to change password)",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Confirm New Password",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Password (only for confirm changes)",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(children: [
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 270,
                          child: ElevatedButton(
                            onPressed: () {
                              // Your onPressed logic goes here
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 64, 176, 251),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Set your desired border radius
                                ),
                              ),
                              fixedSize: MaterialStateProperty.all<Size>(
                                Size(
                                    95, 15), // Set your desired width and heigh
                              ),
                            ),
                            child: Text("Update",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                width: 700,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 10),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 38, 156, 235),
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
                                "Personal information",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              // Add more widgets here as needed
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Personal phone number:",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',
                            prefixIcon: Icon(Icons.phone),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Personal email:",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',
                            prefixIcon: Icon(Icons.email),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Born date",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedDate != null
                                ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                : "",
                          ),
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            labelText: 'Select Date',
                            suffixIcon: Icon(Icons.calendar_today),
                            border:
                                InputBorder.none, // This removes the underline
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Nationality :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Gender",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 20),
                            Container(
                              width: 276,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 1),
                                ),
                                child: DropdownButton<String>(
                                  value: selectgender,
                                  underline:
                                      Container(), // This removes the underline
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectgender = newValue!;
                                      
                                    });
                                  },
                                  items: gender.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  icon: Container(
                                    padding: EdgeInsets.only(
                                        left: 170), // Adjust padding as needed
                                    alignment: Alignment.centerRight,
                                    child: Icon(Icons
                                        .arrow_drop_down), // Dropdown arrow icon
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Marital status",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 20),
                            Container(
                              width: 276,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 1),
                                ),
                                child: DropdownButton<String>(
                                  value: selectstatus,
                                  underline:
                                      Container(), // This removes the underline
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectstatus = newValue!;
                                      
                                    });
                                  },
                                  items: status.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  icon: Container(
                                    padding: EdgeInsets.only(
                                        left: 170), // Adjust padding as needed
                                    alignment: Alignment.centerRight,
                                    child: Icon(Icons
                                        .arrow_drop_down), // Dropdown arrow icon
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: 300,
                            color: Color.fromARGB(255, 215, 201, 201),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Driving license :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Driving license exp date",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedDate != null
                                ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                : "",
                          ),
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            labelText: 'Select Date',
                            suffixIcon: Icon(Icons.calendar_today),
                            border:
                                InputBorder.none, // This removes the underline
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "SSN num:",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "NIC num:",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                width: 700,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Adress section ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: 300,
                            color: Color.fromARGB(255, 215, 201, 201),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Address 1 :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Address 2 :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "City :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Postal code :",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Province :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Country:",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                width: 700,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        " Custom section",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: 300,
                            color: Color.fromARGB(255, 215, 201, 201),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Custom 1 ::",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Address 2 :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Custom 3 :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Custom 4:",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                width: 700,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: 300,
                            color: Color.fromARGB(255, 215, 201, 201),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Upload Signature:",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 310,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Icon(Icons.image),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              width: 145,
                              child: Text("Choose file"),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                imageupload2();
                              },
                              child: Text("Browse"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color.fromARGB(255, 176,
                                    176, 177), // Text color of the button
                                elevation: 5, // Elevation of the button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10),
                                      topRight: Radius.circular(
                                          10)), // Rounded corners
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal:
                                        30), // Padding inside the button
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Upload Image:",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 310,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Icon(Icons.image),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              width: 145,
                              child: Text("Choose file"),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                imageupload();
                              },
                              child: Text("Browse"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color.fromARGB(255, 176,
                                    176, 177), // Text color of the button
                                elevation: 5, // Elevation of the button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10),
                                      topRight: Radius.circular(
                                          10)), // Rounded corners
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 30),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "About you",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        child: TextField(
                          maxLines: null, // Allows multiple lines
                          decoration: InputDecoration(
                            labelText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal:
                                    12.0), // Set vertical and horizontal padding
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void imageupload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          selectedfile1 = File(result.files.single.path!);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("file selected succesfully"),
          backgroundColor: Color.fromARGB(173, 120, 249, 126),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("error while selecting the file"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void imageupload2() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          selectedfile2 = File(result.files.single.path!);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("file selected succesfully"),
          backgroundColor: Color.fromARGB(173, 120, 249, 126),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("error while selecting the file"),
        backgroundColor: Colors.red,
      ));
    }
  }
}

class Form2 extends StatefulWidget {
  @override
  State<Form2> createState() => _Form2State();
}

class _Form2State extends State<Form2> {
  var selectedfile2;
  @override
  void initState() {
    super.initState();
  }

  Color currentColor = Colors.black;

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                width: 700,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 10),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 38, 156, 235),
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
                                "Information",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              // Add more widgets here as needed
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Account created at : 16 March 2024",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Employment status : 1",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Job title : BDO",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Pay grade :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Work station id :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Joined date :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Confirmation date : :",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void imageupload2() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          selectedfile2 = File(result.files.single.path!);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("file selected succesfully"),
          backgroundColor: Color.fromARGB(173, 120, 249, 126),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("error while selecting the file"),
        backgroundColor: Colors.red,
      ));
    }
  }
}

class Form3 extends StatefulWidget {
  @override
  State<Form3> createState() => _Form3State();
}

class _Form3State extends State<Form3> {
  List<String> purchasetype = [
    "Raw type",
    'For sale',
  ];
  String selecttype = "Raw type";

  List<String> user = ["jeshiya", 'nimitha', 'hanvi', 'sulfi', 'yeshitha'];
  String selectuser = "jeshiya";
  double number = 0.00;
  double rate = 0.00;
  double margin = 0.00;

  void incrementNumber() {
    setState(() {
      number +=
          0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      controller.text = number.toStringAsFixed(2);
    });
  }

  void incrementrate() {
    setState(() {
      rate +=
          0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      controller2.text = rate.toStringAsFixed(2);
    });
  }

  void incrementmargin() {
    setState(() {
      margin +=
          0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      controller3.text = margin.toStringAsFixed(2);
    });
  }

  void decrementNumber() {
    setState(() {
      if (number >= 0.01) {
        number -=
            0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller.text = number.toStringAsFixed(2);
      }
    });
  }

  void decrementrate() {
    setState(() {
      if (rate >= 0.01) {
        rate -=
            0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller2.text = rate.toStringAsFixed(2);
      }
    });
  }

  void decrementmargin() {
    setState(() {
      if (margin >= 0.01) {
        margin -=
            0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller3.text = margin.toStringAsFixed(2);
      }
    });
  }

  final TextEditingController controller = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  var selectedfile;
  @override
  void initState() {
    super.initState();
  }

  Color currentColor = Colors.black;

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                width: 700,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 10),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 38, 156, 235),
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
                                "Unread List",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              // Add more widgets here as needed
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

class Form4 extends StatefulWidget {
  @override
  State<Form4> createState() => _Form4State();
}

class _Form4State extends State<Form4> {
  List<String> type = [
    "Absence in hour",
    'Full day absence',
    'First half  absence',
    'Second  Half Absence'
  ];
  String selecttype = "Absence in hour";

  List<String> day = ["Calander", 'Workable day', 'Worked day'];
  String selectday = "Calander";

  List<String> user = [
    "",
  ];
  String selectuser = "";

  DateTime? _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  DateTime? _selectedDate2 = DateTime.now();

  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate2 ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate2) {
      setState(() {
        _selectedDate2 = picked;
      });
    }
  }

  var selectedfile;
  @override
  void initState() {
    super.initState();
  }

  Color currentColor = Colors.black;

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                width: 700,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 10),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 38, 156, 235),
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
                                "New absence request",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              // Add more widgets here as needed
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Absence type",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 20),
                            Container(
                              width: 276,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 1),
                                ),
                                child: DropdownButton<String>(
                                  value: selecttype,
                                  underline:
                                      Container(), // This removes the underline
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selecttype = newValue!;
                                      
                                    });
                                  },
                                  items: type.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  icon: Container(
                                    padding: EdgeInsets.only(
                                        left: 85), // Adjust padding as needed
                                    alignment: Alignment.centerRight,
                                    child: Icon(Icons
                                        .arrow_drop_down), // Dropdown arrow icon
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Absence type day",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 20),
                            Container(
                              width: 276,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 1),
                                ),
                                child: DropdownButton<String>(
                                  value: selectday,
                                  underline:
                                      Container(), // This removes the underline
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectday = newValue!;
                                      
                                    });
                                  },
                                  items: day.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  icon: Container(
                                    padding: EdgeInsets.only(
                                        left: 150), // Adjust padding as needed
                                    alignment: Alignment.centerRight,
                                    child: Icon(Icons
                                        .arrow_drop_down), // Dropdown arrow icon
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Start date",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedDate != null
                                ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                : "",
                          ),
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            labelText: '',
                            suffixIcon: Icon(Icons.calendar_today),
                            border:
                                InputBorder.none, // This removes the underline
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "End date",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 304,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedDate2 != null
                                ? "${_selectedDate2!.day}/${_selectedDate2!.month}/${_selectedDate2!.year}"
                                : "",
                          ),
                          onTap: () => _selectDate2(context),
                          decoration: InputDecoration(
                            labelText: '',
                            suffixIcon: Icon(Icons.calendar_today),
                            border:
                                InputBorder.none, // This removes the underline
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: 300,
                            color: Color.fromARGB(255, 215, 201, 201),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () {
                            // Your onPressed logic goes here
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 64, 176, 251),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Set your desired border radius
                              ),
                            ),
                            fixedSize: MaterialStateProperty.all<Size>(
                              Size(95, 15), // Set your desired width and heigh
                            ),
                          ),
                          child: Text("Submit",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
