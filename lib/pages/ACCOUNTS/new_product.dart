import 'dart:convert';
import 'dart:io';

import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
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
        print("iiiiiiiiiiiiiiiiiiiiiiiii$image");
      });
    }
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
      print("Selected image path: ${image.path}");
    }
  }

  // Function to add a new image selection option
  void addImagePicker() {
    setState(() {
      imagePickerCount += 1; // Increment the number of image pickers
    });
  }

Future<void> addOrUpdateProduct(BuildContext scaffoldContext) async {
  final token = await gettokenFromPrefs();

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$api/api/add/product/'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // Add common fields to the request
    request.fields['name'] = name.text;
    request.fields['hsn_code'] = hsncode.text;
    request.fields['type'] = selecttype;
    request.fields['unit'] = selectunit;
    request.fields['purchase_rate'] = purchaserate.text;
    request.fields['tax'] = taxx.text;
    request.fields['selling_price'] = sellingprice.text;

    // Ensure _selectedFamily is populated correctly
    if (_selectedFamily != null && _selectedFamily.isNotEmpty) {
      // Add each family ID as a separate entry with the key 'family[]'
      for (var familyId in _selectedFamily) {
        request.fields['family[]'] = familyId.toString();
      }
      print("Sending family IDs: $_selectedFamily");
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Please select a valid family.'),
        ),
      );
      return;
    }


    if (selecttype == 'single') {
      print("Stock value from TextField: ${stock.text}");

      if (stock.text.isNotEmpty && int.tryParse(stock.text) != null) {
        int stockValue = int.parse(stock.text);
        request.fields['stock'] = stockValue.toString();
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid stock value.'),
          ),
        );
        return;
      }
    }

    // Add the image file if available
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Please select an image.'),
        ),
      );
      return;
    }

    print("Final request fields: ${request.fields}");

    // Send the request
    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    // Log the response status and body for debugging
    print("Response status: ${responseData.statusCode}");
    print("Response body: ${responseData.body}");

    if (responseData.statusCode == 201) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Product added successfully.'),
        ),
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => new_product()));
    } else if (responseData.statusCode == 400) {
      // Handle the case of a 400 response, typically indicating validation errors
      final Map<String, dynamic> responseDataBody = jsonDecode(responseData.body);
      if (responseDataBody.containsKey('errors')) {
        final errors = responseDataBody['errors'];
        String errorMessage = errors.entries
            .map((entry) => "${entry.key}: ${entry.value.join(', ')}")
            .join('\n');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Validation Error"),
              content: Text(errorMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Invalid response format.'),
          ),
        );
      }
    } else if (responseData.statusCode == 500) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Session expired.'),
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
    print(e);
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        content: Text('Enter valid information'),
      ),
    );
  }
}
  // void addProduct(
  //   BuildContext scaffoldContext,
  // ) async {
  //   final token = await gettokenFromPrefs();

  //   print("object $token");
  //   // var slug = name.text.toUpperCase().replaceAll(' ', '-');
  //   // print(slug);
  //   // print("$url/vendor/vendor-create-product/");

  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse("$api/api/add/product/"),
  //     );

  //     // Add headers
  //     request.headers.addAll({
  //       "Content-Type": "multipart/form-data",
  //       'Authorization': 'Bearer $token',
  //     });

  //     // Add other fields
  //     request.fields['name'] = name.text;
  //     request.fields['hsn_code'] = hsncode.text;
  //     request.fields['type'] = selecttype;
  //     request.fields['unit'] = selectunit;
  //     request.fields['purchase_rate'] = purchaserate.text;
  //     request.fields['tax'] = taxx.text;
  //     request.fields['selling_price'] = sellingprice.text;

  //     if (image != null) {
  //       request.files
  //           .add(await http.MultipartFile.fromPath('image', image.path));
  //     }

  //     // Add image files to request

  //     // Send the request
  //     var response = await request.send();
  //     var responseData = await http.Response.fromStream(response);

  //     print(responseData.body);

  //     if (responseData.statusCode == 201) {
  //       ScaffoldMessenger.of(scaffoldContext).showSnackBar(
  //         SnackBar(
  //           content: Text('Product added successfully.'),
  //         ),
  //       );
  //       // Navigator.push(
  //       //     context, MaterialPageRoute(builder: (context) => add_product()));
  //     } else if (responseData.statusCode == 500) {
  //       ScaffoldMessenger.of(scaffoldContext).showSnackBar(
  //         SnackBar(
  //           content: Text('Session expired.'),
  //         ),
  //       );
  //       // Navigator.push(
  //       //     context, MaterialPageRoute(builder: (context) => Login_Page()));
  //     } else if (responseData.statusCode == 400) {
  //       Map<String, dynamic> responseDataBody = jsonDecode(responseData.body);
  //       Map<String, dynamic> data = responseDataBody['data'];
  //       String errorMessage =
  //           data.entries.map((entry) => entry.value[0]).join('\n');
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text("Error"),
  //             content: Text(errorMessage),
  //             actions: <Widget>[
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text("OK"),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     } else {
  //       ScaffoldMessenger.of(scaffoldContext).showSnackBar(
  //         SnackBar(
  //           content: Text('Something went wrong. Please try again later.'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print(e);
  //     ScaffoldMessenger.of(scaffoldContext).showSnackBar(
  //       SnackBar(
  //         content: Text('Enter valid information'),
  //       ),
  //     );
  //   }
  // }

  // void add_family_list(
  //   BuildContext scaffoldContext,
  // ) async {
  //   try {
  //     final token = await gettokenFromPrefs();
  //     print("AAAAAAAAAZZZZZZSSSSSSSSSSSSWWWWWWWWWWW$_selectedFamily");

  //     // Build the product data, excluding "stock" when the product type is "variant"
  //     Map<String, dynamic> productData = {
  //       "family": _selectedFamily,
  //     };

  //     // Add "stock" only if the product type is "single"
  //     if (selecttype == "single") {
  //       productData["stock"] = stock;
  //     }
  //     var response = await http.post(
  //       Uri.parse('$api/api/add/product/'),
  //       headers: {
  //         "Content-Type": "application/json",
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: jsonEncode(productData),
  //     );

  //     print(
  //         "Responsessssssssssssssssssssssssssssssssssssssssytytttttttttttqqqqqq: ${response.body}");

  //     print("SSSSSSSSSELLLLLLLLLLLLLLLLL$selectedImagesList");

  //     if (response.statusCode == 201) {
  //       ScaffoldMessenger.of(scaffoldContext).showSnackBar(
  //         SnackBar(
  //           content: Text('Product added Successfully.'),
  //         ),
  //       );

  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => new_product()));
  //     } else {
  //       ScaffoldMessenger.of(scaffoldContext).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.red,
  //           content: Text('Adding product failed.'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(scaffoldContext).showSnackBar(
  //       SnackBar(
  //         content: Text('Enter valid information'),
  //       ),
  //     );
  //   }
  // }

  List<File> selectedImagesList =
      []; // Single list to store all selected images

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
      print("Error: $error");
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
                  height: 260,
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
                                            print(selecttype);
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
                                            print(_selectedFamily);
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
                                            print(selectunit);
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
                        onPressed: () {
                          // addProduct(context);
                          // add_family_list(context);
                          addOrUpdateProduct(context);
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
