import 'dart:convert';
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
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

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
import 'package:beposoft/pages/ACCOUNTS/expence.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/new_product.dart';
import 'package:beposoft/pages/ACCOUNTS/order_request.dart';
import 'package:beposoft/pages/ACCOUNTS/purchases_request.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_customer.dart';

class new_product extends StatefulWidget {
  const new_product({super.key});

  @override
  State<new_product> createState() => _new_productState();
}

class _new_productState extends State<new_product> {
  String globalProductId = '';
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

  List<String> type = ["single", 'variant'];
  String selecttype = "single";
  List<String> unit = ["BOX", 'NOS', 'PRS', 'SET'];
  String selectunit = "BOX";
  bool checkbox3 = false;
  bool checkbox1 = false;
  bool checkbox2 = false;
  bool checkbox4 = false;
  List<int> _selectedFamily = [];

  double prate = 0.00;
  double tax = 0.00;
  double spricetax = 0.00;

  TextEditingController name = TextEditingController();
  TextEditingController hsncode = TextEditingController();
  TextEditingController groupID = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController family = TextEditingController();
  TextEditingController types = TextEditingController();
  TextEditingController units = TextEditingController();
  TextEditingController purchaserate = TextEditingController();
  TextEditingController taxx = TextEditingController();
  TextEditingController sellingprice = TextEditingController();
  TextEditingController excludedprice = TextEditingController();
  TextEditingController stock = TextEditingController();

  List<Map<String, dynamic>> fam = [];
  List<bool> _checkboxValues = [];

  @override
  void initState() {
    super.initState();
    getfamily();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  var image;
  final ImagePicker _picker = ImagePicker();
  Future<void> pickImagemain() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        
      });
    }
  }
  
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
  int imagePickerCount = 1; // To keep track of the number of image pickers
  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile
            .path); // Store the selected image in the 'image' variable
      });
      
    }
  }

  // Function to add a new image selection option
  void addImagePicker() {
    setState(() {
      imagePickerCount += 1; // Increment the number of image pickers
    });
  }


Future<void> addProduct(BuildContext scaffoldContext) async {
  final token = await gettokenFromPrefs();

  try {
    // Create the request
    var request = http.Request(
      'POST',
      Uri.parse("$api/api/add/product/"),
    );

    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json', // Specify content type as JSON
    });

    // Prepare the data to send in JSON format
    Map<String, dynamic> data = {
      'name': name.text,
      'hsn_code': hsncode.text,
      'type': selecttype,
      'unit': selectunit,
      'purchase_rate': purchaserate.text,
      'tax': taxx.text,
      'selling_price': sellingprice.text,


    };

    

    // Ensure _selectedFamily is populated correctly and send as a list of numbers
    if (_selectedFamily != null && _selectedFamily.isNotEmpty) {
      // Send family as a list of integers: [1, 2, 3]
      data['family'] = _selectedFamily; // Directly send the list as is
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Please select a valid family.'),
        ),
      );
      return;
    }

    // Convert data to JSON and set the request body
    request.body = jsonEncode(data);

    // Send the request
    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    // Print the response status and body for debugging
    print("Response status: ${responseData.statusCode}");
    print("Response body: ${responseData.body}");

    if (responseData.statusCode == 201) {
      // Parse the response body
      final Map<String, dynamic> responseBody = jsonDecode(responseData.body);

      // Store the product ID in the global variable
      globalProductId = responseBody['data']['id'].toString();

      // Show success message
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        
        SnackBar(
          
          content: Text('Product added successfully.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again later.'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
      ),
    );
  }
}

Future<void> updateProductImage(BuildContext scaffoldContext, File newImage) async {
  final token = await gettokenFromPrefs();

  try {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse("$api/api/product/update/$globalProductId/"), // Use the global product ID
    );

    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // Check if new image is provided
    if (newImage != null) {
      // Add the image file to the request
      request.files.add(await http.MultipartFile.fromPath('image', newImage.path));
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Please select a valid image.'),
        ),
      );
      return;
    }

    // Send the request
    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    // Print the response status and body for debugging
    print("Response status: ${responseData.statusCode}");
    print("Response body: ${responseData.body}");

    if (responseData.statusCode == 200) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Image updated successfully.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Image is not Updated'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
      ),
    );
  }
}
  List<File> selectedImagesList =[]; // Single list to store all selected images

  Future<void> getfamily() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/familys/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];
        List<Map<String, dynamic>> familylist = [];

        for (var productData in productsData) {
          familylist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }

        setState(() {
          fam = familylist;
          _checkboxValues = List<bool>.filled(fam.length, false);
        });
      }
    } catch (error) {
      
    }
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
        child: Padding(
          padding: const EdgeInsets.only(top: 30, left: 12, right: 12),
          child: Container(
            color: Colors.white,
            width: 700,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "New Product ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 299,
                  width: 340,
                  child: Card(
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            10.0), // Set border radius for Container
                        border: Border.all(
                            color: Color.fromARGB(255, 236, 236,
                                236)), // Add border to Container if needed
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   "ID ",
                            //   style: TextStyle(
                            //       fontSize: 15, fontWeight: FontWeight.bold),
                            // ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            // TextField(
                            //   decoration: InputDecoration(
                            //     labelText: 'AAA00',
                            //     prefixIcon: Icon(Icons.numbers),
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(10.0),
                            //       borderSide: BorderSide(color: Colors.grey),
                            //     ),
                            //     contentPadding: EdgeInsets.symmetric(
                            //         vertical: 8.0), // Set vertical padding
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            Text(
                              "Product Name * ",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: name,
                              decoration: InputDecoration(
                                labelText: 'Label/Description of prodct',
                                prefixIcon: Icon(Icons.mode_edit),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0), // Set vertical padding
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "HSN Code",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: hsncode,
                              decoration: InputDecoration(
                                labelText: 'Index',

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10.0),

                                // Set vertical padding
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Group ID",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: groupID,
                              decoration: InputDecoration(
                                labelText: 'Index',

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10.0),

                                // Set vertical padding
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: 340,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Set border radius
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            10.0), // Set border radius for Container
                        border: Border.all(
                            color: Color.fromARGB(255, 236, 236,
                                236)), // Add border to Container if needed
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Product Type * ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
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
                                        items: type
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        icon: Container(
                                          padding: EdgeInsets.only(
                                              left:
                                                  137), // Adjust padding as needed
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

                            SizedBox(height: 10),
                            Text("Checkbox Family",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            fam.isEmpty
                                ? CircularProgressIndicator() // Show a loading indicator while the data is being fetched
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: fam.length,
                                    itemBuilder: (context, index) {
                                      return CheckboxListTile(
                                        title: Text(fam[index]['name']),
                                        value: _checkboxValues[index],
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _checkboxValues[index] =
                                                value ?? false;
                                            if (_checkboxValues[index]) {
                                              _selectedFamily
                                                  .add(fam[index]['id']);
                                            } else {
                                              _selectedFamily
                                                  .remove(fam[index]['id']);
                                            }
                                            
                                          });
                                        },
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      );
                                    },
                                  ),

                            SizedBox(height: 10),
                            Text("Unit * ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
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
                                        value: selectunit,
                                        underline:
                                            Container(), // This removes the underline
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectunit = newValue!;
                                            
                                          });
                                        },
                                        items: unit
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        icon: Container(
                                          padding: EdgeInsets.only(
                                              left:
                                                  167), // Adjust padding as needed
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

// Conditionally show the TextField if `selecttype` is "single"
                            if (selecttype == 'single') ...[
                              SizedBox(height: 10),
                              Text("Stock for Single Product *",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              TextField(
                                controller: stock,
                                decoration: InputDecoration(
                                  labelText: 'Enter stock quantity',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8.0),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: 340,
                  child: Card(
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            10.0), // Set border radius for Container
                        border: Border.all(
                            color: Color.fromARGB(255, 236, 236,
                                236)), // Add border to Container if needed
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Other Information",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Purchase Rate (Including Tax): ",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 310,
                              height: 49,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 158, 157, 157),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: purchaserate,
                                keyboardType: TextInputType
                                    .number, // Ensures the keyboard shows numbers
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.rate_review),
                                  border: InputBorder.none,
                                  hintText:
                                      'Enter purchase rate', // Added a hint text
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Selling Price (Excluding Tax) ",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: sellingprice,
                              decoration: InputDecoration(
                                labelText: ' ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Tax Amount (in %) ",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
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
                                  Expanded(
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: taxx,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    Icon(Icons.monetization_on),
                                                border: InputBorder.none,
                                                hintText: '',
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  tax =
                                                      double.tryParse(value) ??
                                                          0.00;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Select Main Image',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.image),
                                  onPressed: () =>
                                      pickImagemain(), // Trigger image picker for this index
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            if (image != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.file(
                                    File(image
                                        .path), // Use the file path obtained from the picked image
                                    width: 100, // Set the desired width
                                    height: 100, // Set the desired height
                                    fit: BoxFit.cover, // Set the fit style
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),

                            // SizedBox(
                            //   height: 10,
                            // ),
                            // Text(
                            //   "Actual Selling Price (Including Tax)",
                            //   style: TextStyle(
                            //       fontSize: 15, fontWeight: FontWeight.bold),
                            // ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            // Container(
                            //   width: 310,
                            //   height: 49,
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey),
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Expanded(
                            //         child: Container(
                            //           child: Row(
                            //             children: [
                            //               Expanded(
                            //                 child: TextField(
                            //                   controller: controller14,
                            //                   keyboardType: TextInputType
                            //                       .numberWithOptions(
                            //                           decimal: true),
                            //                   decoration: InputDecoration(
                            //                     prefixIcon:
                            //                         Icon(Icons.local_offer),
                            //                     border: InputBorder.none,
                            //                     hintText: '',
                            //                   ),
                            //                   onChanged: (value) {
                            //                     setState(() {
                            //                       spricetax =
                            //                           double.tryParse(value) ??
                            //                               0.00;
                            //                     });
                            //                   },
                            //                 ),
                            //               ),
                            //               Container(
                            //                 width: 30,
                            //                 color: Color.fromARGB(
                            //                     255, 88, 184, 248),
                            //                 child: IconButton(
                            //                   icon: Icon(
                            //                       Icons
                            //                           .keyboard_arrow_down_rounded,
                            //                       size: 20,
                            //                       color: Colors
                            //                           .white), // Down arrow icon with size 20
                            //                   onPressed: decrementspricetax,
                            //                 ),
                            //               ),
                            //               Container(
                            //                 width: 30,
                            //                 decoration: BoxDecoration(
                            //                     color: Color.fromARGB(
                            //                         255, 64, 176, 251),
                            //                     border: Border.all(
                            //                         color: Color.fromARGB(
                            //                             255, 64, 176, 251)),
                            //                     borderRadius: BorderRadius.only(
                            //                         bottomRight:
                            //                             Radius.circular(10),
                            //                         topRight:
                            //                             Radius.circular(10))),
                            //                 child: IconButton(
                            //                   icon: Icon(
                            //                       Icons
                            //                           .keyboard_arrow_up_rounded,
                            //                       size: 20,
                            //                       color: Colors
                            //                           .white), // Up arrow icon with size 20
                            //                   onPressed: incrementspricetax,
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
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
                  height: 13,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 120),
                  child: Row(
                    children: [
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => View_newproduct()));
                      //   },
                      //   style: ButtonStyle(
                      //     backgroundColor: MaterialStateProperty.all<Color>(
                      //       Color.fromARGB(255, 164, 164, 164),
                      //     ),
                      //     shape:
                      //         MaterialStateProperty.all<RoundedRectangleBorder>(
                      //       RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(
                      //             10), // Set your desired border radius
                      //       ),
                      //     ),
                      //     fixedSize: MaterialStateProperty.all<Size>(
                      //       Size(85, 15), // Set your desired width and heigh
                      //     ),
                      //   ),
                      //   child:
                      //       Text("View", style: TextStyle(color: Colors.white)),
                      // ),
                      SizedBox(width: 13),
                      ElevatedButton(
                        onPressed: () async{
                         await addProduct(context);
updateProductImage(context, image);                          // add_family_list(context);
                          // addOrUpdateProduct(context);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 244, 66, 66),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                    ],
                  ),
                ),
                SizedBox(
                  height: 35,
                )
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
