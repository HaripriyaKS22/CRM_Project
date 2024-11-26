import 'dart:convert';
import 'dart:io';

import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/update_product_variant.dart';
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

class add_product_variant extends StatefulWidget {
  final id;
  final type;
  const add_product_variant({super.key, required this.id, required this.type});

  @override
  State<add_product_variant> createState() => _add_product_variantState();
}

class _add_product_variantState extends State<add_product_variant> {
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

  Widget buildProductTable() {
    if (widget.type == 'single') {
      // Display single products
      if (singleProducts.isNotEmpty) {
        final product = singleProducts.first;

        return DataTable(
          columnSpacing: 20,
          headingRowHeight: 40,
          columns: const <DataColumn>[
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          rows: [
            DataRow(
              cells: <DataCell>[
                DataCell(
                  Text(
                    product['name'] ?? '',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Image.network(
                    '$api${product['image']}',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  ),
                ),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                     print("dhfgjk");
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>update_product_variant(id: product['id'])));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(50, 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      deleteProduct(product['id'], context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(50, 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      } else {
        return const Text('No products available');
      }
    } else if (widget.type == 'variant') {
      // Display variant products
      return DataTable(
        columnSpacing: 20,
        headingRowHeight: 40,
        columns: const <DataColumn>[
          DataColumn(
            label: Text(
              'Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Image',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
        rows: variantProducts.map((variant) {
          return DataRow(
            cells: <DataCell>[
              DataCell(
                Text(
                  variant['name'] ?? '',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                variant['variant_images']?.isNotEmpty == true
                    ? Image.network(
                        '$api${variant['variant_images'][0]['image']}',
                        width: 50,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported);
                        },
                      )
                    : const Icon(Icons.image_not_supported),
              ),
              DataCell(
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>update_product_variant(id: variant['id'])));

                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(50, 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              DataCell(
                ElevatedButton(
                  onPressed: () {
                    deleteProduct(variant['id'], context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(50, 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      );
    } else {
      return const Text('No products available');
    }
  }

// Method to handle editing a product
  void _editProduct(Map<String, dynamic> product) {
    // Add your edit functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing: ${product['name']}'),
      ),
    );
  }

  TextEditingController name = TextEditingController();
  TextEditingController product = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  List<Map<String, dynamic>> fam = [];
  List<bool> _checkboxValues = [];
  List<Map<String, dynamic>> attribute = [];
  List<Map<String, dynamic>> valuess = [];
  List<Map<String, dynamic>> variantProducts = [];
  List<Map<String, dynamic>> singleProducts = [];

  @override
  void initState() {
    super.initState();
    getfamily();
    getprofiledata();
    getvariant();
    getattributes();

    print(widget.type);

    print("PPPPPPPPROOOOOOOOOOOOOOIDDDDDD${widget.id}");
  }

  @override
  void dispose() {
    name.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  List<File> selectedImagesList =
      []; // Single list to store all selected images

  bool flag = false;
  List<String> selectedValues = [];
  String? selectedAttributeName; // Store the selected attribute name
  int? selectedAttributeId; // Store the selected attribute ID
  Future<void> getattributes() async {
    try {
      final token = await gettokenFromPrefs();
      final response = await http.get(
        Uri.parse('$api/api/product/attributes/'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      print("ressssssssssssssssssssssssssssssssssssss${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        List<Map<String, dynamic>> attributelist = [];

        for (var productData in parsed) {
          attributelist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }

        setState(() {
          attribute = attributelist;
          print("Updated attributes: $attribute");
        });
      }
    } catch (error) {
      print("Error fetching attributes: $error");
    }
  }

  var image;
  final ImagePicker _picker = ImagePicker();
  int imagePickerCount = 1; // To keep track of the number of image pickers
  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImagesList
            .add(File(pickedFile.path)); // Store image in the single list
      });
    }
  }

  void addimage(
    BuildContext scaffoldContext,
  ) async {
    var slug = name.text.toUpperCase().replaceAll(' ', '-');

    final token = await gettokenFromPrefs();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$api/api/add/product/variant/"),
      );

      // Add headers
      request.headers.addAll({
        "Content-Type": "multipart/form-data",
        'Authorization': 'Bearer $token',
      });

      request.fields['product'] = widget.id;
      for (File imageFile in selectedImagesList) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'images', // The name 'images' must match your backend field name
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );

        print("multiiiiiiiiiiiiiiiiiiiiiiiii${multipartFile.filename}");
        request.files.add(multipartFile);
      }

      // Send the request
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      print(responseData.body);

      if (responseData.statusCode == 201) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Product added successfully.'),
          ),
        );
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => add_product()));
      } else if (responseData.statusCode == 500) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Session expired.'),
          ),
        );
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => Login_Page()));
      } else if (responseData.statusCode == 400) {
        Map<String, dynamic> responseDataBody = jsonDecode(responseData.body);
        Map<String, dynamic> data = responseDataBody['data'];
        String errorMessage =
            data.entries.map((entry) => entry.value[0]).join('\n');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
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

        print("===============================hariii${response.body}");

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

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  var viewprofileurl = "$api/api/profile/";
  String? selectedValue;
  Future<void> getprofiledata() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$viewprofileurl'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("==============0000000000000000000000000${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("profileeeeeee$parsed");

        setState(() {
          name.text = productsData['name'] ?? '';
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<void> getvariant() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/products/${widget.id}/variants/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("haiiiiiiiiiiiiiiiiiiiiiiiiiiii: ${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['products'];

        setState(() {
          // Handle response based on widget.type
          if (widget.type == 'single') {
            // Handle single product response
            singleProducts = List<Map<String, dynamic>>.from(productsData);
            if (productsData.isNotEmpty) {
              product.text = productsData[0]['name'] ?? '';

              print(
                  "AAAAAAAAAAAAA======================P${productsData[0]['name']}");
            }
          } else if (widget.type == 'variant') {
            // Handle variant product response
            variantProducts = List<Map<String, dynamic>>.from(productsData);
            if (productsData.isNotEmpty) {
              product.text = productsData[0]['name'] ?? '';
            }
          }
        });

        print("Fetched Products: $productsData");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  void addvariant(BuildContext scaffoldContext) async {
    try {
      final token = await gettokenFromPrefs();

      // Check if selectedAttributeName is null or if selectedValues is empty
      if (selectedAttributeName == null || selectedValues.isEmpty) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(content: Text('Please select an attribute and its values.')),
        );
        return; // Exit the function if there's no attribute or values selected
      }

      // Prepare the data for sending as a JSON string
      // Convert the attributes to JSON string before sending
      String attributesToSend = jsonEncode([
        {
          'attribute': selectedAttributeName,
          'values': selectedValues, // Ensure this is a list of selected values
        }
      ]);

      // Prepare the final JSON body
      String jsonString =
          jsonEncode({'product': widget.id, 'attributes': attributesToSend});

      print(jsonString);

      // Sending the request to the backend
      var response = await http.post(
        Uri.parse('$api/api/add/product/variant/'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonString, // Use the valid JSON string
      );

      // Debugging output
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Product added successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => add_product_variant(
                      id: widget.id,
                      type: widget.type,
                    )));
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Adding product failed: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Enter valid information: ${e.toString()}'),
        ),
      );
    }
  }

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

  Future<void> deleteProduct(int productId, BuildContext context) async {
    final token = await gettokenFromPrefs();

    try {
      final url = widget.type == 'single'
          ? '$api/api/product/$productId/variant/data/'
          : '$api/api/variant/$productId/images/';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Deleted successfully'),
          ),
        );

        // Refresh the products after deletion
        setState(() {
          if (widget.type == 'single') {
            singleProducts.removeWhere((product) => product['id'] == productId);
          } else {
            variantProducts
                .removeWhere((variant) => variant['id'] == productId);
          }
        });
      } else {
        throw Exception('Failed to delete variant product with ID: $productId');
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to delete variant product. Please try again.'),
        ),
      );
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
                      "Create Variant Product",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
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
                            Text(
                              "Managed User",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: name,
                              decoration: InputDecoration(
                                hintText: name.text,
                                enabled: false,

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
                              "product",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: product,
                              decoration: InputDecoration(
                                hintText: product.text,
                                enabled: false,

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

                            if (widget.type != "single")
                              Column(
                                children:
                                    List.generate(imagePickerCount, (index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelText: 'Select Image',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.image),
                                            onPressed: () =>
                                                pickImage(), // Trigger image picker for this index
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  );
                                }),
                              ),

                            // Display all selected images with a cross icon to remove
                            if (selectedImagesList.isNotEmpty &&
                                widget.type != "single")
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: selectedImagesList
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  File image = entry.value;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Image.file(
                                          image,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(width: 10),
                                        Text(image.path.split('/').last),
                                        Spacer(),
                                        IconButton(
                                          icon: Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed:
                                              () {}, // Remove image on click
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              if(widget.type!='single')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            flag = !flag;
                            print(flag);
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.white), // Set background color to white
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue), // Set text color to blue
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Set your desired border radius
                              side: BorderSide(
                                  color: Colors
                                      .blue), // Set the border color to blue
                            ),
                          ),
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(120, 15), // Set your desired width and height
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add, // Use the add icon
                              color: Colors.blue, // Set icon color to blue
                              size: 15, // Set the desired size of the icon
                            ),
                            Text(
                              "Attribute",
                              style: TextStyle(
                                  color: Colors.blue), // Set text color to blue
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if(widget.type!='single')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: DropdownButtonHideUnderline(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'Select Item',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor),
                            ),
                            items: attribute.asMap().entries.map((entry) {
                              var attr = entry.value; // Get the attribute value

                              return DropdownMenuItem<String>(
                                value: attr['name'],
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(attr['name'],
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              );
                            }).toList(),
                            value: selectedAttributeName,
                            onChanged: (value) {
                              setState(() {
                                var selectedAttr = attribute.firstWhere(
                                  (attr) =>
                                      attr['name'].toLowerCase() ==
                                      value!.toLowerCase(),
                                  orElse: () => {'id': null, 'name': 'Unknown'},
                                );
                                selectedAttributeName = selectedAttr['name'];
                                selectedAttributeId = selectedAttr['id'];
                                print(
                                    "Selected Attribute Name: $selectedAttributeName");
                                print(
                                    "Selected Attribute ID: $selectedAttributeId");

                                getvalues(selectedAttributeId!);
                              });
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                            ),
                            dropdownStyleData:
                                const DropdownStyleData(maxHeight: 200),
                            menuItemStyleData:
                                const MenuItemStyleData(height: 40),
                            dropdownSearchData: DropdownSearchData(
                              searchController: textEditingController,
                              searchInnerWidgetHeight: 50,
                              searchInnerWidget: Container(
                                height: 50,
                                padding: const EdgeInsets.only(
                                    top: 8, bottom: 4, right: 8, left: 8),
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  controller: textEditingController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    hintText: 'Search for an item...',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              searchMatchFn: (item, searchValue) {
                                return item.value
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchValue.toLowerCase());
                              },
                            ),
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {
                                textEditingController.clear();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                if(widget.type!='single')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 46,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Text(
                                'Select Items',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor),
                              ),
                              items: valuess.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item['value'],
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item['value'],
                                          style: const TextStyle(fontSize: 14)),
                                      if (selectedValues
                                          .contains(item['value']))
                                        Icon(Icons.check,
                                            color: Colors
                                                .blue), // Indicate selected items
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  if (selectedValues.contains(value)) {
                                    selectedValues.remove(
                                        value); // Remove value if already selected
                                  } else {
                                    selectedValues.add(
                                        value!); // Add value if not selected
                                  }
                                  print("Selected Values: $selectedValues");
                                });
                              },
                              buttonStyleData: const ButtonStyleData(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                height: 40,
                              ),
                              dropdownStyleData:
                                  const DropdownStyleData(maxHeight: 200),
                              menuItemStyleData:
                                  const MenuItemStyleData(height: 40),
                            ),
                          ),
                        ),
                        SizedBox(height: 10), // Spacing
                        // Display selected values
                        Wrap(
                          spacing: 8.0,
                          children: selectedValues.map((value) {
                            return Chip(
                              label: Text(value),
                              deleteIcon: Icon(Icons.close),
                              onDeleted: () {
                                setState(() {
                                  selectedValues.remove(value);
                                  print(
                                      "Updated Selected Values: $selectedValues");
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                ),
                SizedBox(
                  height: 13,
                ),
              if(widget.type!='single')
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Row(
                    children: [
                      SizedBox(width: 13),
                      ElevatedButton(
                        onPressed: () {
                          addvariant(context);
                          addimage(context);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 238, 57, 16),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.type == 'single'
                            ? "Single Product Images"
                            : "Variant Products",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  // scrollDirection: Axis.vertical,
                  child: buildProductTable(),
                ),
                SizedBox(
                  height: 30,
                ),
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
