import 'dart:convert';

import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/update_department.dart';
import 'package:beposoft/pages/ACCOUNTS/update_state.dart';
import 'package:flutter/material.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

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
import 'package:beposoft/pages/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class add_attribute extends StatefulWidget {
  const add_attribute({super.key});

  @override
  State<add_attribute> createState() => _add_attributeState();
}

class _add_attributeState extends State<add_attribute> {
  List<Map<String, dynamic>> attributes = [];
  List<Map<String, dynamic>> valuess = [];

  String? selectedAttribute;
  int? selectedAttributeId;

  @override
  void initState() {
    super.initState();
    getattribute();
  }

  TextEditingController attribute = TextEditingController();
  TextEditingController values = TextEditingController();
  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void addattribute(String attributeName, BuildContext context) async {
    var attributeUpperCase = attributeName.toUpperCase();
    print("Attribute being added: $attributeUpperCase");

    final token = await gettokenFromPrefs();

    // Fetch the existing attributes
    List<Map<String, dynamic>> existingAttributes = await getattribute();

    // Check if the attribute already exists
    bool attributeExists = existingAttributes
        .any((attr) => attr['name'].toUpperCase() == attributeUpperCase);

    if (attributeExists) {
      // Show SnackBar if it already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Attribute already exists.'),
        ),
      );
      return; // Exit the function
    }

    // Proceed with adding the attribute
    try {
      var response = await http.post(
        Uri.parse('$api/api/add/product/attributes/'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": attributeUpperCase // Encode the body as JSON
        }),
      );

      print("Response Status Code: ${response.statusCode}");

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        print("Response Data: $responseData");

        // Navigate or perform other actions upon successful response
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_attribute()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 49, 212, 4),
            content: Text('Attribute added successfully'),
          ),
        );
      } else {
        print(
            "Error: Failed to add attribute. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to add attribute. Please try again.'),
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

  Future<List<Map<String, dynamic>>> getattribute() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/product/attributes/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      List<Map<String, dynamic>> attributelist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        for (var productData in parsed) {
          attributelist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }

        setState(() {
          attributes = attributelist;
          print("Attributes: $attributes");
        });

        return attributelist; // Return the list of attributes
      } else {
        throw Exception("Failed to load attributes");
      }
    } catch (error) {
      print("Error: $error");
      return []; // Return an empty list in case of error
    }
  }

  Future<void> deleteattributes(int attributeId, BuildContext context) async {
    final token = await gettokenFromPrefs();

    try {
      final response = await http.delete(
        Uri.parse('$api/api/product/attribute/$attributeId/delete/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 49, 212, 4),
            content: Text('Deleted successfully'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => add_attribute()),
        );
      } else {
        throw Exception('Failed to delete attribute ID: $attributeId');
      }
    } catch (error) {
      // Handle any errors and show a failure message
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to delete attribute. Please try again.'),
        ),
      );
    }
  }

  void removeProduct(int index) {
    setState(() {
      attributes.removeAt(index);
    });
  }
Future<void> addvalues(String value, int? attributeId) async {
  if (attributeId == null || value.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please select an attribute and enter a value.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final token = await gettokenFromPrefs();

  // Step 1: Fetch existing values for the selected attribute
  try {
    var response = await http.get(
      Uri.parse('$api/api/product/attribute/$attributeId/values/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> existingValues = [];
      final parsed = jsonDecode(response.body);

      for (var valueData in parsed) {
        existingValues.add({
          'id': valueData['id'],
          'value': valueData['value'],
          'attribute': valueData['attribute'],
        });
      }

      // Step 2: Check if the entered value already exists
      bool valueExists = existingValues.any((existingValue) => 
          existingValue['value'].toString().toLowerCase() == value.toLowerCase());

      if (valueExists) {
        // If the value already exists, show a SnackBar and stop the function
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This value already exists for the selected attribute.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Step 3: If value does not exist, proceed to add the new value
      var addResponse = await http.post(
        Uri.parse('$api/api/add/product/attribute/values/'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "attribute": attributeId, // Send the selected attribute ID
          "value": value, // Send the entered value
        }),
      );

      if (addResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attribute value added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add attribute value.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      throw Exception("Failed to fetch existing values for attribute $attributeId");
    }
  } catch (error) {
    print("Error adding attribute value: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<void> getvalues(int attributeId) async {
    final token = await gettokenFromPrefs();

    try {
      // Fetch values for the selected attribute ID
      var response = await http.get(
        Uri.parse('$api/api/product/attribute/$attributeId/values/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      List<Map<String, dynamic>> valuesList = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        print("===============================h${response.body}");

        // Iterate through the fetched data and only include values with the correct attribute ID
        for (var valueData in parsed) {
          if (valueData['attribute'] == attributeId) {
            valuesList.add({
              'id': valueData['id'],
              'value': valueData['value'],
              'attribute': valueData['attribute'],
            });
          }
        }

        // Update the state with the fetched values
        setState(() {
          valuess = valuesList;
          print("Values for attribute $attributeId: $valuess");
        });
      } else {
        throw Exception("Failed to load values for attribute $attributeId");
      }
    } catch (error) {
      print("Error fetching values: $error");
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

  //searchable dropdown

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
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
                  Navigator.pop(context); // Close the drawer
                  // Perform logout action
                },
              ),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Text(
                      "ADD ATTRIBUTES",
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 9.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                              color: Color.fromARGB(255, 202, 202, 202)),
                        ),
                        width: constraints.maxWidth * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: constraints.maxWidth * 0.9,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(255, 202, 202, 202)),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      "New Attributes",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 13),
                                  ],
                                ),
                              ),
                              Text(
                                "Attributes",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: attribute,
                                  decoration: InputDecoration(
                                    labelText: 'Enter Attribute',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    addattribute(attribute.text, context);
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 244, 66, 66),
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  fixedSize: MaterialStateProperty.all<Size>(
                                    Size(constraints.maxWidth * 0.4, 50),
                                  ),
                                ),
                                child: Text("Submit",
                                    style: TextStyle(color: Colors.white)),
                              ),

                              // Displaying the list of departments as a table
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                              color: Color.fromARGB(255, 202, 202, 202)),
                        ),
                        width: constraints.maxWidth * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: constraints.maxWidth * 0.9,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(255, 202, 202, 202)),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      "Add Attributes Values",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 13),
                                  ],
                                ),
                              ),

                              Text(
                                "Select Attribute",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),

                              // Dropdown to select an attribute
                              Container(
                                width: constraints.maxWidth * 0.9,
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  hint: Text("Select Attribute"),
                                  value: selectedAttribute,
                                  items: attributes.map((attr) {
                                    return DropdownMenuItem<String>(
                                      value: attr['name'],
                                      child: Text(attr['name']),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedAttribute = value;
                                      selectedAttributeId =
                                          attributes.firstWhere((attr) =>
                                              attr['name'] == value)['id'];

                                      // Now that an attribute is selected, fetch the values for that attribute
                                      getvalues(selectedAttributeId!);
                                    });
                                  },
                                ),
                              ),
                              Text(
                                "Values",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: values,
                                  decoration: InputDecoration(
                                    labelText: 'Enter Value',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () {
                                  addvalues(values.text, selectedAttributeId);
 Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_attribute()),
        );                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 244, 66, 66),
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  fixedSize: MaterialStateProperty.all<Size>(
                                    Size(constraints.maxWidth * 0.4, 50),
                                  ),
                                ),
                                child: Text("Submit",
                                    style: TextStyle(color: Colors.white)),
                              ),

                              // Displaying the list of departments as a table
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Available Attributes",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 15, left: 15),
                      child: Container(
                        color: Colors.white,
                        child: Table(
                          border: TableBorder.all(
                              color: Color.fromARGB(255, 214, 213, 213)),
                          columnWidths: {
                            0: FixedColumnWidth(
                                40.0), // Fixed width for the first column (No.)
                            1: FlexColumnWidth(
                                2), // Flex width for the second column (Department Name)
                            // 2: FixedColumnWidth(
                            //     50.0), // Fixed width for the third column (Edit)
                            3: FixedColumnWidth(
                                50.0), // Fixed width for the fourth column (Delete)
                          },
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 234, 231, 231),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "No.",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Attribute Name",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Values",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.all(8.0),
                                //   child: Text(
                                //     "Edit",
                                //     style:
                                //         TextStyle(fontWeight: FontWeight.bold),
                                //   ),
                                // ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Delete",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            for (int i = 0; i < attributes.length; i++)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text((i + 1).toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(attributes[i]['name']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        // Call the function to fetch values for the selected attribute
                                        await getvalues(attributes[i]['id']);

                                        // If no values are found, show a SnackBar
                                        if (valuess.isEmpty ||
                                            valuess[0]['attribute'] !=
                                                attributes[i]['id']) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'No values to display for this attribute.'),
                                              backgroundColor: Colors
                                                  .red, // You can customize the color
                                            ),
                                          );
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Check if there are any values for this attribute and display them
                                          valuess.isNotEmpty &&
                                                  valuess[0]['attribute'] ==
                                                      attributes[i]['id']
                                              ? Column(
                                                  children:
                                                      valuess.map((value) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0),
                                                      child:
                                                          Text(value['value']),
                                                    );
                                                  }).toList(),
                                                )
                                              : Image.asset(
                                                  "lib/assets/view.png",
                                                  width: 20,
                                                  height: 20,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: GestureDetector(
                                  //     onTap: () {
                                  //       // Call the function to fetch values for the selected attribute
                                  //       getvalues(attributes[i]['id']);
                                  //     },
                                  //     child: Image.asset(
                                  //       "lib/assets/view.png",
                                  //       width: 20,
                                  //       height: 20,
                                  //     ),
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        deleteattributes(
                                            attributes[i]['id'], context);
                                        removeProduct(i);
                                      },
                                      child: Image.asset(
                                        "lib/assets/delete.gif",
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
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
