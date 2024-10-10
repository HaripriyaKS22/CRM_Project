import 'dart:convert';

import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beposoft/main.dart';
import 'package:beposoft/pages/ACCOUNTS/add_credit_note.dart';
import 'package:beposoft/pages/ACCOUNTS/add_recipts.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/recipts_list.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_stock.dart';
import 'package:beposoft/pages/ACCOUNTS/credit_note_list.dart';
import 'package:beposoft/pages/ACCOUNTS/expence.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/new_product.dart';
import 'package:beposoft/pages/ACCOUNTS/order_request.dart';
import 'package:beposoft/pages/ACCOUNTS/purchases_request.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_customer.dart';

class view_customer extends StatefulWidget {
  const view_customer({super.key, required this.customerid});
  final int customerid;

  @override
  State<view_customer> createState() => _view_customerState();
}

class _view_customerState extends State<view_customer> {
  List<Map<String, dynamic>> manager = [];
  List<Map<String, dynamic>> statess = [];
  List<Map<String, dynamic>> customer = [];

  String? selectedManagerName;
  int? selectedManagerId;
  String? selectstate;
  int? selectedStateId;

  TextEditingController gstno = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController altphone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController zipcode = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController states = TextEditingController();
  TextEditingController comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    getcustomers();
    getmanagers();
    getstates();


    print("CCCCCCCCCCCCUUUUUSSSSSSSSSSIIIIIIIIIDDDDDDDDDD${widget.customerid}");
  }
void initdata()async{
  await getmanagers();
   await getstates();
}

  Future<void> storeUserData(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void updateCustomer(
  String gst,
  String name,
  String manager,
  String phone,
  String altPhone,
  String email,
  String address,
  String zipcode,
  String city,
  String state,
  String comment,
  BuildContext context,
) async {
  print("Updating customer: $name");
  print("API URL: $api/api/customer/update/${widget.customerid}/");

  final token = await gettokenFromPrefs();

  try {
    var response = await http.put(
      Uri.parse("$api/api/customer/update/${widget.customerid}/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "gst": gst,
        "name": name,
        'manager': selectedManagerId,
        'phone': phone,
        'alt_phone': altPhone,
        'email': email,
        'address': address,
        'zip_code': zipcode,
        'city': city,
        'state': state,
        'comment': comment,
      }),
    );

    print("RRRRRRRRRRRRRRRRREEEEEEEEESSSSSSPPPPPPPPOOOOOONNNNNNNNNSSSE${response.body}");

    print("Response Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 49, 212, 4),
          content: Text('Success'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to update customer. Please try again.'),
        ),
      );
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
var managerfetchid;
var statefetchid;
  Future<void> getcustomers() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/customers/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      List<Map<String, dynamic>> managerlist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

print("custoooooooooooooooooooooooooooo$productsData");
        for (var productData in productsData) {
          managerlist.add({
            'id': productData['id'],
            'gst': productData['gst'],
            'name': productData['name'],
            'created_at': productData['created_at'],
            'manager': productData['manager'],
            'phone': productData['phone'],
            'alt_phone': productData['alt_phone'],
            'email': productData['email'],
            'address': productData['address'],
            'zip_code': productData['zip_code'],
            'city': productData['city'],
            'state': productData['state'],
            'comment': productData['comment'],
          });

          if (widget.customerid == productData['id']) {
            gstno.text = productData['gst'] ?? '';
            name.text = productData['name'] ?? '';
            managerfetchid=productData['manager'];
            statefetchid=productData['state'];
            phone.text = productData['phone'] ?? '';
            altphone.text = productData['alt_phone'] ?? '';
            email.text = productData['email'] ?? '';
            address.text = productData['address'] ?? '';
            zipcode.text = productData['zip_code'].toString() ?? '';
            city.text = productData['city'] ?? '';
            selectstate = statess.firstWhere(
                (state) => state['id'] == productData['state'],
                orElse: () => {'name': ''})['name']; // Set selectstate

             selectedManagerName = manager.firstWhere(
                (manager) => manager['id'] == productData['manager'],
                orElse: () => {'name': ''})['name']; 
            comment.text = productData['comment'] ?? '';

          }
        }

        print("SSSSSSSSSSSSSSSSSSSSSSSSSSSSLLLLLLLLLLLLLLLLLLLL$selectedManagerName");
        getstates();
        setState(() {
          customer = managerlist;
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  // Future<String?> gettokenFromPrefs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('token');
  // }

  Future<void> getmanagers() async {
  try {
    final token = await gettokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/staffs/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    List<Map<String, dynamic>> managerlist = [];

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['data'];

      for (var productData in productsData) {
        managerlist.add({
          'id': productData['id'],
          'name': productData['name'],
        });
      }
print(managerlist);

      // Reorder the list to have the manager with managerfetchid first
      managerlist.sort((a, b) {
        if (a['id'] == managerfetchid) return -1;
        if (b['id'] == managerfetchid) return 1;
        return 0;
      });
print(managerlist);

      setState(() {
        manager = managerlist;
        selectedManagerName = managerlist[0]['name'];
        selectedManagerId = managerlist[0]['id'];
        print("Selected Manager Name: $selectedManagerName");
        print("Selected Manager ID: $selectedManagerId");
      });
    }
  } catch (error) {
    print("Error: $error");
  }
}


Future<void> getstates() async {
  try {
    final token = await gettokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/states/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    List<Map<String, dynamic>> stateslist = [];

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['data'];

      for (var productData in productsData) {
        stateslist.add({
          'id': productData['id'],
          'name': productData['name'],
        });
      }
      print("Original stateslist: $stateslist");

      // Convert statefetchid to match the type of id in stateslist
      final convertedStatefetchid = statefetchid is String
          ? int.tryParse(statefetchid)
          : statefetchid;

      // Reorder the list to have the state with statefetchid first
      stateslist.sort((a, b) {
        if (a['id'] == convertedStatefetchid) return -1;
        if (b['id'] == convertedStatefetchid) return 1;
        return 0;
      });
      print("Sorted stateslist: $stateslist");

      setState(() {
        statess = stateslist;
        selectstate = stateslist[0]['name'];
        selectedStateId = stateslist[0]['id'];
        print("Selected State Name: $selectstate");
        print("Selected State ID: $selectedStateId");
      });
    }
  } catch (error) {
    print("Error: $error");
  }
}


  drower d = drower();
  Widget _buildDropdownTile(
      BuildContext context, String title, List<String> options) {
    return ExpansionTile(
      title: Text(title),
      children: options.map((option) {
        return ListTile(
          title: Text(option),
          onTap: () {
            Navigator.pop(context);
            d.navigateToSelectedPage(
                context, option); // Navigate to selected page
          },
        );
      }).toList(),
    );
  }

  List<String> categories = ["Joishya", 'Hanvi', 'nimitha', 'Hari'];
  String selectededu = "Hari";
  List<String> state = [
    "Kerala",
    'Tamilnadu',
    'Karnataka',
    'Gujarat',
  ];
  // String selectstate = "Kerala";
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
                  color: const Color.fromARGB(255, 110, 110, 110),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "lib/assets/logo-white.png",
                      width: 100, // Change width to desired size
                      height: 100, // Change height to desired size
                      fit: BoxFit
                          .contain, // Use BoxFit.contain to maintain aspect ratio
                    ),
                    SizedBox(
                      width: 70,
                    ),
                    Text(
                      'BepoSoft',
                      style: TextStyle(
                        color: Color.fromARGB(236, 255, 255, 255),
                        fontSize: 20,
                      ),
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
              title: Text('Customer'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => customer_list()));
                // Navigate to the Settings page or perform any other action
              },
            ),
            Divider(),
            _buildDropdownTile(context, 'Credit Note', [
              'Add Credit Note',
              'Credit Note List',
            ]),
            _buildDropdownTile(
                context, 'Recipts', ['Add recipts', 'Recipts List']),
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
              'Stock',
            ]),
            _buildDropdownTile(
                context, 'Purchase', [' New Purchase', 'Purchase List']),
            _buildDropdownTile(context, 'Expence', [
              'Add Expence',
              'Expence List',
            ]),
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
            _buildDropdownTile(context, 'GRV', ['Create New GRV', 'GRVs List']),
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
                Navigator.pop(context); // Close the drawer
                // Perform logout action
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, left: 12, right: 12),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 75),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Add New Customer ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  height: 300,
                  width: 340,
                  child: Card(
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                            color: Color.fromARGB(255, 236, 236, 236)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("GSTIN Number ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextField(
                              controller: gstno,
                              decoration: InputDecoration(
                                labelText: 'AAA00',
                                hintText: gstno.text.isNotEmpty
                                    ? gstno.text
                                    : 'Enter your gstno',
                                prefixIcon: Icon(Icons.numbers),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Name of customer ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextField(
                              controller: name,
                              decoration: InputDecoration(
                                labelText: 'Name of customer',
                                hintText: name.text.isNotEmpty
                                    ? name.text
                                    : 'Enter your name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Technical manager",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Container(
                              width: 310,
                              height: 49,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 20),
                                  Flexible(
                                    child: InputDecorator(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '',
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 1),
                                        ),
                                        child: DropdownButton<
                                            Map<String, dynamic>>(
                                          value: manager.isNotEmpty
                                              ? manager.firstWhere(
                                                  (element) =>
                                                      element['name'] ==
                                                      selectedManagerName,
                                                  orElse: () => manager[0],
                                                )
                                              : null,
                                          underline: Container(),
                                          onChanged: manager.isNotEmpty
                                              ? (Map<String, dynamic>?
                                                  newValue) {
                                                  setState(() {
                                                    selectedManagerName =
                                                        newValue!['name'];
                                                    selectedManagerId =
                                                        newValue['id'];
                                                    print(
                                                        'Selected Manager Name: $selectedManagerName');
                                                    print(
                                                        'Selected Manager ID: $selectedManagerId');
                                                  });
                                                }
                                              : null,
                                          items: manager.isNotEmpty
                                              ? manager.map<
                                                  DropdownMenuItem<
                                                      Map<String, dynamic>>>(
                                                  (Map<String, dynamic>
                                                      manager) {
                                                    return DropdownMenuItem<
                                                        Map<String, dynamic>>(
                                                      value: manager,
                                                      child:
                                                          Text(manager['name']),
                                                    );
                                                  },
                                                ).toList()
                                              : [
                                                  DropdownMenuItem(
                                                    child: Text(
                                                        'No managers available'),
                                                    value: null,
                                                  ),
                                                ],
                                          icon: Container(
                                            alignment: Alignment.centerRight,
                                            child: Icon(Icons.arrow_drop_down),
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 5),

                SizedBox(height: 15),
                // Continue adding form elements here
                SizedBox(height: 15),
                SizedBox(
                  height: 690,
                  width: 340,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                            color: Color.fromARGB(255, 236, 236, 236)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Client information ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            // Text("Discount : ",
                            //     style: TextStyle(
                            //         fontSize: 15, fontWeight: FontWeight.bold)),
                            // SizedBox(height: 10),
                            // TextField(
                            //   decoration: InputDecoration(
                            //     labelText: 'Discount ',
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(10.0),
                            //       borderSide: BorderSide(color: Colors.grey),
                            //     ),
                            //     contentPadding:
                            //         EdgeInsets.symmetric(vertical: 8.0),
                            //   ),
                            // ),
                            // SizedBox(height: 10),
                            Text("Phone Number * : ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextField(
                              controller: phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: phone.text.isNotEmpty
                                    ? phone.text
                                    : 'Enter your phone number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Alternate Number : ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextField(
                              controller: altphone,
                              decoration: InputDecoration(
                                labelText: 'Alternate Number',
                                hintText: altphone.text.isNotEmpty
                                    ? altphone.text
                                    : 'Enter your alternate phone number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Mail Id : ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextField(
                              controller: email,
                              decoration: InputDecoration(
                                labelText: 'Mail Id',
                                hintText: email.text.isNotEmpty
                                    ? email.text
                                    : 'Enter your email Id',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 30),
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
                            SizedBox(height: 20),
                            Text("Address/Building Name/ Building Number ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 13),
                            TextField(
                              controller: address,
                              decoration: InputDecoration(
                                labelText: 'Address',
                                hintText: address.text.isNotEmpty
                                    ? address.text
                                    : 'Enter your Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Zip code",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 10),
                                    Container(
                                      width: 144,
                                      child: TextField(
                                        controller: zipcode,
                                        decoration: InputDecoration(
                                          labelText: 'Zip code',
                                          hintText: zipcode.text.isNotEmpty
                                              ? zipcode.text
                                              : 'Enter your zipcode',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 13,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("City",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 10),
                                    Container(
                                      width: 144,
                                      child: TextField(
                                        controller: city,
                                        decoration: InputDecoration(
                                          labelText: 'City',
                                          hintText: city.text.isNotEmpty
                                              ? city.text
                                              : 'Enter your city',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Text("State *:",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              height: 49,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Map<String, dynamic>>(
                                    value: statess.isNotEmpty
                                        ? statess.firstWhere(
                                            (element) =>
                                                element['name'] == selectstate,
                                            orElse: () => statess[0],
                                          )
                                        : null,
                                    onChanged: statess.isNotEmpty
                                        ? (Map<String, dynamic>? newValue) {
                                            setState(() {
                                              selectstate = newValue!['name'];
                                              selectedStateId = newValue[
                                                  'id']; // Store the selected state's ID
                                            });
                                          }
                                        : null,
                                    items: statess.isNotEmpty
                                        ? statess.map<
                                            DropdownMenuItem<
                                                Map<String, dynamic>>>(
                                            (Map<String, dynamic> state) {
                                              return DropdownMenuItem<
                                                  Map<String, dynamic>>(
                                                value: state,
                                                child: Text(state['name']),
                                              );
                                            },
                                          ).toList()
                                        : [
                                            DropdownMenuItem(
                                              child:
                                                  Text('No states available'),
                                              value: null,
                                            ),
                                          ],
                                    icon: Icon(Icons.arrow_drop_down),
                                    isExpanded: true,
                                  ),
                                ),
                              ),
                            ),

                            // SizedBox(height: 20),
                            // Text("Country ",
                            //     style: TextStyle(
                            //         fontSize: 15, fontWeight: FontWeight.bold)),
                            // SizedBox(height: 10),
                            // TextField(
                            //   decoration: InputDecoration(
                            //     labelText: 'Country',
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(10.0),
                            //       borderSide: BorderSide(color: Colors.grey),
                            //     ),
                            //     contentPadding:
                            //         EdgeInsets.symmetric(vertical: 8.0),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  height: 150,
                  width: 340,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                            color: Color.fromARGB(255, 236, 236, 236)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Comment ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            TextField(
                              controller: comment,
                              decoration: InputDecoration(
                                labelText: 'Enter comment',
                                hintText: comment.text.isNotEmpty
                                    ? comment.text
                                    : 'Enter your comment',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                              maxLines: null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
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
                SizedBox(height: 13),
                Padding(
                  padding: const EdgeInsets.only(left: 120),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Your onPressed logic goes here
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 164, 164, 164),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(85, 15),
                          ),
                        ),
                        child: Text("Close",
                            style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 13),
                     ElevatedButton(
  onPressed: () {
    updateCustomer(
      gstno.text,
      name.text,
selectedManagerId.toString(),
      phone.text,
      altphone.text,
      email.text,
      address.text,
      zipcode.text,
      city.text,
      selectedStateId.toString(), // Use selectedStateId instead of states.text
      comment.text,
      context,
    );
  },
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(
      Color.fromARGB(255, 244, 66, 66),
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    fixedSize: MaterialStateProperty.all<Size>(
      Size(95, 15),
    ),
  ),
  child: Text("Update", style: TextStyle(color: Colors.white)),
),

                    ],
                  ),
                ),
                SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSelectedPage(BuildContext context, String selectedOption) {
    switch (selectedOption) {
      case 'Option 1':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_credit_note()),
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