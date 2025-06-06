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
import 'package:beposoft/pages/ACCOUNTS/product_list.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';


class update_product extends StatefulWidget {
  final id;
  final type;
  update_product({super.key, required this.id, required this.type});

  @override
  State<update_product> createState() => _update_productState();
}

class _update_productState extends State<update_product> {
  String globalProductId = '';
  double landingPriceValue = 0.0;

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
    List<String> purchasetype = ["International", 'Local'];
  String selectpurchasetype = "International";

  List<String> type = ["single", 'variant'];
  
  List<String> unit = ["BOX", 'NOS', 'PRS', 'SET'];
  String selectunit = "BOX";
  bool checkbox3 = false;
  bool checkbox1 = false;
  bool checkbox2 = false;
  bool checkbox4 = false;
  List<int> _selectedFamily = [];
  String? selectedManagerName;
  int? selectedManagerId;
  int? selectedwarehouseId; // Variable to store the selected department's ID
  String? selectedwarehouseName;
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
  TextEditingController color = TextEditingController();
  TextEditingController size = TextEditingController();
  TextEditingController retailprice = TextEditingController();
  TextEditingController landingprice = TextEditingController();

  List<Map<String, dynamic>> manager = [];

  List<Map<String, dynamic>> fam = [];
  List<bool> _checkboxValues = [];
  List<Map<String, dynamic>> variantProducts = [];
  List<Map<String, dynamic>> singleProducts = [];
  List<Map<String, dynamic>> Warehouses = [];
var selecttype;
  @override
  void initState() {
    super.initState();
initdata();
    getfamily();
    getmanagers();
    getvariant();
    getwarehouse();
  }
void initdata(){
  if(widget.type=='variant'){
    setState(() {
      selecttype='variant';
    });
  }
  else{
    setState(() {
      selecttype='single';
    });
  }

}
  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getwarehouse() async {
    final token = await gettokenFromPrefs();
    try {
      final response =
          await http.get(Uri.parse('$api/api/warehouse/add/'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      List<Map<String, dynamic>> warehouselist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        
        for (var productData in parsed) {
          warehouselist.add({
            'id': productData['id'],
            'name': productData['name'],
            'location': productData['location']
          });
        }
        setState(() {
          Warehouses = warehouselist;
          
        });
      }
    } catch (e) {
      
    }
  }

  void calculateLandingPrice() {
    double purchaseRate = double.tryParse(purchaserate.text) ?? 0.0;
    double taxPercentage = tax; // From taxx TextField

    // Calculate the tax amount
    double taxAmount = (purchaseRate * taxPercentage) / 100;

    // Calculate the landing price
    double landingPrice = purchaseRate + taxAmount;

    // Update the landing price TextField
    landingprice.text =
        landingPrice.toStringAsFixed(2); // Set to 2 decimal places
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


  var fami;
  Future<void> getvariant() async {
    try {
      final token = await gettokenFromPrefs();
      ;
      var response = await http.get(
        Uri.parse('$api/api/products/${widget.id}/variants/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productData = parsed['products']; // Map of the product
        var variantIDs = productData['variantIDs']; // List of variants
;
        if (variantIDs is List) {
          setState(() {
            selectedwarehouseId = productData[
                'warehouse']; // Set the warehouse ID from the response

            
            


            selectedwarehouseName = productData['warehouse_name'];
            ;
            // Handle response based on widget.type
            if (widget.type == 'single') {
              singleProducts = [productData]; // Single prduct as a list
              
              if (singleProducts.isNotEmpty) {
                name.text = singleProducts[0]['name']?.toString() ?? '';
                hsncode.text = singleProducts[0]['hsn_code']?.toString() ?? '';
                sellingprice.text =
                    singleProducts[0]['selling_price']?.toString() ?? '';
                purchaserate.text =
                    singleProducts[0]['purchase_rate']?.toString() ?? '';
                stock.text = singleProducts[0]['stock']?.toString() ?? '';
                color.text = singleProducts[0]['color']?.toString() ?? '';
                size.text = singleProducts[0]['size']?.toString() ?? '';
                taxx.text = singleProducts[0]['tax']?.toString() ?? '';
                landingprice.text =
                    singleProducts[0]['landing_cost']?.toString() ?? '';
                retailprice.text =
                    singleProducts[0]['retail_price']?.toString() ?? '';
                fami = singleProducts[0]['family'];

            
              }
            } else if (widget.type == 'variant') {
              variantProducts = List<Map<String, dynamic>>.from(
                  variantIDs); // List of variants
              singleProducts = [productData]; // Single product as a list
              ;
              // Handle response based on widget.type
;
              if (singleProducts.isNotEmpty) {
                name.text = singleProducts[0]['name']?.toString() ?? '';
                hsncode.text = singleProducts[0]['hsn_code']?.toString() ?? '';
                sellingprice.text =
                    singleProducts[0]['selling_price']?.toString() ?? '';
                purchaserate.text =
                    singleProducts[0]['purchase_rate']?.toString() ?? '';
                stock.text = singleProducts[0]['stock']?.toString() ?? '';
                color.text = singleProducts[0]['color']?.toString() ?? '';
                size.text = singleProducts[0]['size']?.toString() ?? '';
                taxx.text = singleProducts[0]['tax']?.toString() ?? '';
                landingprice.text =
                    singleProducts[0]['landing_cost']?.toString() ?? '';
                retailprice.text =
                    singleProducts[0]['retail_price']?.toString() ?? '';
                fami = singleProducts[0]['family'];

                ;
            

                
              }
            }
          });
          
        } else {
          
        }
      } else {
        
      }
    } catch (error) {
      
    }
  }

  Future<void> updateProduct(BuildContext scaffoldContext) async {
    final token = await gettokenFromPrefs();

    try {
      // Create the request
      var request = http.Request(
        'PUT',
        Uri.parse("$api/api/product/update/${widget.id}/"),
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
        'purchase_type': selectpurchasetype,
        'unit': selectunit,
        'purchase_rate': purchaserate.text,
        'tax': taxx.text,
        'color': color.text,
        'size': size.text,
        'selling_price': sellingprice.text,
        'retail_price': retailprice.text,
        'landing_cost': landingPriceValue,
        'warehouse': selectedwarehouseId,
        'stock': stock.text,
        'approval_status': 'Disapproved', // Set approval status to 'Disapproved'
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
      
      
      var res = responseData.body;

      if (responseData.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> responseBody = jsonDecode(responseData.body);

        // Store the product ID in the global variable
        globalProductId = responseBody['data']['id'].toString();

        // Show success message
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Product updated successfully.'),
            backgroundColor: Colors.green, // Replace with your desired color
          ),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Product_List()));
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('${responseData.body}'),
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

  Future<void> updateProductImage(
      BuildContext scaffoldContext, File? newImage) async {
    final token = await gettokenFromPrefs();

    try {
      // Validate if the image is provided
      if (newImage == null) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Please select a valid image.'),
            backgroundColor: Colors.red, // Optional: Add background color
          ),
        );
        return;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            "$api/api/product/update/${widget.id}/"), // Use the global product ID
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add the image file to the request
      request.files
          .add(await http.MultipartFile.fromPath('image', newImage.path));

      // Send the request
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      // Print the response status and body for debugging
      ;
      ;
      

      if (responseData.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Image updated successfully.'),
            backgroundColor: Colors.green, // Optional: Add background color
          ),
        );
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again later.'),
            backgroundColor: Colors.orange, // Optional: Add background color
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red, // Optional: Add background color
        ),
      );
    }
  }

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
        setState(() {
          manager = managerlist;

          
        });
      }
    } catch (error) {
      
    }
  }

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

          // Correctly initialize `_checkboxValues` with the same length as `fam`
          _checkboxValues = List<bool>.filled(fam.length, false);

          // Automatically select checkboxes for `fami` items
          for (int i = 0; i < fam.length; i++) {
            if (fami.contains(fam[i]['id'])) {
              _checkboxValues[i] = true;
              _selectedFamily.add(fam[i]['id']);
            }
          }
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
        title: Text(
          'Update Product',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset('lib/assets/profile.png'),
            onPressed: () {},
          ),
        ],
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
                  height: 320,
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

                            Text("Purchase Type",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Container(
                              width: 310,
                              height: 39,
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
                                        value: selectpurchasetype,
                                        underline:
                                            Container(), // This removes the underline
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectpurchasetype = newValue!;
                                          });
                                        },
                                        items: purchasetype
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
                            Text(
                              "Product Name ",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: name,
                              decoration: InputDecoration(
                                labelText: 'Label',
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
                               keyboardType: TextInputType.number,
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
                            // SizedBox(
                            //   height: 10,
                            // ),
                            // Text(
                            //   "Created User",
                            //   style: TextStyle(
                            //       fontSize: 15, fontWeight: FontWeight.bold),
                            // ),
                            // SizedBox(height: 10),
                            // Container(
                            //   width: 310,
                            //   height: 49,
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey),
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       SizedBox(width: 20),
                            //       Flexible(
                            //         child: InputDecorator(
                            //           decoration: InputDecoration(
                            //             border: InputBorder.none,
                            //             hintText: '',
                            //             contentPadding:
                            //                 EdgeInsets.symmetric(horizontal: 1),
                            //           ),
                            //           child:
                            //               DropdownButton<Map<String, dynamic>>(
                            //             value: manager.isNotEmpty
                            //                 ? manager.firstWhere(
                            //                     (element) =>
                            //                         element['id'] ==
                            //                         selectedManagerId,
                            //                     orElse: () => manager[0],
                            //                   )
                            //                 : null,
                            //             underline: Container(),
                            //             onChanged: manager.isNotEmpty
                            //                 ? (Map<String, dynamic>? newValue) {
                            //                     setState(() {
                            //                       selectedManagerName =
                            //                           newValue!['name'];
                            //                       selectedManagerId =
                            //                           newValue['id'];
                                               
                            //                     });
                            //                   }
                            //                 : null,
                            //             items: manager.isNotEmpty
                            //                 ? manager.map<
                            //                     DropdownMenuItem<
                            //                         Map<String, dynamic>>>(
                            //                     (Map<String, dynamic> manager) {
                            //                       return DropdownMenuItem<
                            //                           Map<String, dynamic>>(
                            //                         value: manager,
                            //                         child:
                            //                             Text(manager['name']),
                            //                       );
                            //                     },
                            //                   ).toList()
                            //                 : [
                            //                     DropdownMenuItem(
                            //                       child: Text(
                            //                           'No managers available'),
                            //                       value: null,
                            //                     ),
                            //                   ],
                            //             icon: Container(
                            //               alignment: Alignment.centerRight,
                            //               child: Icon(Icons.arrow_drop_down),
                            //             ),
                            //           ),
                            //         ),
                            //       )
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
                            Text(
                              "Attribute",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: color,
                              decoration: InputDecoration(
                                labelText: '',
                                prefixIcon: Icon(Icons.mode_edit),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0), // Set vertical padding
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Values",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: size,
                              decoration: InputDecoration(
                                labelText: '',
                                prefixIcon: Icon(Icons.mode_edit),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0), // Set vertical padding
                              ),
                            ),
                            SizedBox(height: 10),

                            Text("Product Type ",
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

                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value:
                                    selectedwarehouseId, // Use selected warehouse ID
                                hint: Text('Select a Warehouse'),
                                underline: SizedBox(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedwarehouseId = newValue;
                                    selectedwarehouseName = Warehouses
                                            .firstWhere((element) =>
                                                element['id'] == newValue)[
                                        'name']; // Update the warehouse name
                                  });
                                },
                                items: Warehouses.map<DropdownMenuItem<int>>(
                                    (Warehouses) {
                                  return DropdownMenuItem<int>(
                                    value: Warehouses['id'],
                                    child: Text(Warehouses['name']),
                                  );
                                }).toList(),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),

                           SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Family",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 20),
      fam.isEmpty
          ? CircularProgressIndicator() // Show a loading indicator while the data is being fetched
          : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling
              itemCount: fam.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(fam[index]['name']),
                  value: _checkboxValues[index],
                  onChanged: (bool? value) {
                    setState(() {
                      _checkboxValues[index] = value ?? false;
                      if (_checkboxValues[index]) {
                        _selectedFamily.add(fam[index]['id']);
                      } else {
                        _selectedFamily.remove(fam[index]['id']);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
    ],
  ),
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
                                 keyboardType: TextInputType.number,
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
                                onChanged: (value) {
                                  setState(() {
                                    // Recalculate landing price whenever purchase rate changes
                                    calculateLandingPrice();
                                  });
                                },
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
                                                  calculateLandingPrice();
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
                            Text(
                              "Landing Price ",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: landingprice,
                              decoration: InputDecoration(
                                labelText: ' ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                              enabled: false, // Make the field non-editable
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Wholesale Price",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: sellingprice,
                               keyboardType: TextInputType.number,
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
                              "Retail Price",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: retailprice,
                               keyboardType: TextInputType.number,
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
                              height: 20,
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
                        onPressed: () async {
                          // Parse the values
                          landingPriceValue =
                              double.tryParse(landingprice.text) ?? 0.0;
                          double wholesaleRate =
                              double.tryParse(sellingprice.text) ?? 0.0;
                          double retailRate =
                              double.tryParse(retailprice.text) ?? 0.0;
                          
                          // Check if values are valid
                          if (wholesaleRate < landingPriceValue) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Wholesale Rate cannot be less than Landing Price"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return; // Stop further execution if invalid
                          }

                          if (retailRate < landingPriceValue) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Retail Rate cannot be less than Landing Price"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return; // Stop further execution if invalid
                          }

                          // If validation passes, proceed with submission
                          await updateProduct(context);
                          updateProductImage(context, image);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 244, 66, 66),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(95, 15),
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

 
}
