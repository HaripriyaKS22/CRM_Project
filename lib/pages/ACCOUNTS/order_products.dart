import 'dart:convert';
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_product_variant.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/view_cart.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class order_products extends StatefulWidget {
  const order_products({super.key});

  @override
  State<order_products> createState() => _order_productsState();
}

class _order_productsState extends State<order_products> {
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
  var mainid;
  var varid;
  Map<int, bool> expandedProducts = {}; // Track expanded state for products
  List<Map<String, dynamic>> fam = [];
  List<Map<String, dynamic>> products = [];
  List<bool> _checkboxValues = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> variant= [];

  TextEditingController searchController =TextEditingController(); // Search controller

  @override
  void initState() {
    super.initState();
    initdata();
  }

  Future<void> initdata() async {
    await fetchProductList();
    setState(() {
      filteredProducts = products;
    });
  }

Future<void> _getAndShowVariants(int productId) async {
    await getvariant(productId, "type"); // Call your existing getvariant function
    setState(() {
      expandedProducts[productId] = !(expandedProducts[productId] ?? false);
    });
  }
  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProducts = products; // Show all products if search is cleared
      });
    } else {
      setState(() {
        filteredProducts = products
            .where((product) =>
                product['name'].toLowerCase().contains(query.toLowerCase()))
            .toList(); // Filter products by name (case-insensitive)
      });
    }
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  
//    Future<void> fetchProductList() async {
//   final token = await getTokenFromPrefs();

//   try {
//     final response = await http.get(
//       Uri.parse("$api/api/products/"),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final parsed = jsonDecode(response.body);
//       var productsData = parsed['data'];
//       List<Map<String, dynamic>> productList = [];

//       print("Products Responseeeeeeeeeeeeeeeeeeeeeeeeeee: ${response.body}");

//       for (var productData in productsData) {
//         List<String> familyNames = (productData['family'] as List<dynamic>?)?.map((id) => id as int).map<String>((id) => fam.firstWhere(
//             (famItem) => famItem['id'] == id,
//             orElse: () => {'name': 'Unknown'})['name'] as String).toList() ?? [];
//         var imgurl = '$api/${productData['image']}';
// print("imggggggggg$imgurl");
//         // Check if the product type is 'variant'
//         if (productData['type'] == "variant") {
//                       print("nameeeeeeeeeeeeeeeeeeeeeeee====${productData['name']}");


//           for (var variant in productData['variant_products']) {
//             print("nameeeeeeeeeeeeeeeeeeeeeeee${variant['name']}");

//             if (variant['is_variant'] == true && variant['sizes'] != null) {

//                productList.add({
//               'mainid':productData['id'],
//               'id': variant['id'],
//               'is_vaiant':variant['is_variant'],
//               'name': variant['name'],
//               'color': variant['color'],
//               'stock': variant['stock'],
//               'created_user': variant['created_user'],
//               'family': familyNames,
//               'image': variant['variant_images'].isNotEmpty
//                   ? '${variant['variant_images'][0]['image']}'
//                   : imgurl, // Use variant image or fallback to main image
//                'sizes': variant['sizes'],
//             });

//             }
//             // Process each variant product
//             else{
//             productList.add({
//               'mainid':productData['id'],
//               'type':productData['type'],
//               'id': variant['id'],
//               'name': variant['name'],
//               'color': variant['color'],
//               'is_vaiant':variant['is_variant'],
//               'stock': variant['stock'],
//               'created_user': variant['created_user'],
//               'family': familyNames,
//               'image': variant['variant_images'].isNotEmpty
//                   ? '${variant['variant_images'][0]['image']}'
//                   : imgurl, // Use variant image or fallback to main image
//             });}
//           }
//         } else {
//           // Process non-variant products
//           productList.add({
//             'id': productData['id'],
//             'name': productData['name'],
//             'hsn_code': productData['hsn_code'],
//             'type': productData['type'],
//             'unit': productData['unit'],
//             'purchase_rate': productData['purchase_rate'],
//             'tax': productData['tax'],
//             'exclude_price': productData['exclude_price'],
//             'selling_price': productData['selling_price'],
//             'stock': productData['stock'],
//             'created_user': productData['created_user'],
//             'family': familyNames,
//             'image': imgurl,
//           });
//         }
//       }

//       setState(() {
//         products = productList;
//         print("Products: $products");
//         filteredProducts = products;
//       });
//     }
//   } catch (error) {
//     print("Error: $error");
//   }
// }
 Future<void> fetchProductList() async {
  final token = await getTokenFromPrefs();

  try {
    final response = await http.get(
      Uri.parse("$api/api/products/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['data'];
      List<Map<String, dynamic>> productList = [];

      print("Products Responsehhhhhhhhhhhhhhhhhhhhhhhhh: ${response.body}");

      for (var productData in productsData) {
        // Ensure that 'family', 'single_products', and 'variant_products' are non-null and lists
        List<String> familyNames = (productData['family'] as List<dynamic>?)?.map((id) => id as int).map<String>((id) => fam.firstWhere(
            (famItem) => famItem['id'] == id,
            orElse: () => {'name': 'Unknown'})['name'] as String).toList() ?? [];

        // Add the product data to the list
        productList.add({
          'id': productData['id'],
          'variantIDs':productData['variantIDs'],
          'name': productData['name'],
          'hsn_code': productData['hsn_code'],
          'type': productData['type'],
          'unit': productData['unit'],
          'purchase_rate': productData['purchase_rate'],
          'tax': productData['tax'],
          'exclude_price': productData['exclude_price'],
          'selling_price': productData['selling_price'],
          'stock': productData['stock'],
          'created_user': productData['created_user'],
          'family': familyNames, // Add family names here
          'image': productData['image'], // Main product image
          // Don't process single_products or variant_products
        });
      }

      setState(() {
        products = productList;
      });
    }
  } catch (error) {
    print("Error: $error");
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

Future<void> getvariant(int id, var type) async {
  print("id: $id");
  try {
    final token = await getTokenFromPrefs();
    List<Map<String, dynamic>> productList = [];
    
    var response = await http.get(
      Uri.parse('$api/api/products/$id/variants/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['products'];
      print("Variants: $productsData");

      for (var product in productsData) {
        if (product['is_variant'] == false) {
          // Add product details for non-variant product
          productList.add({
            'name': product['name'],
            'color': product['color'],
            'stock': product['stock'],
          });
        } else {
          // Add product details including the first image and sizes for variant product
          String firstImageUrl = product['variant_images'].isNotEmpty
              ? product['variant_images'][0]['image']
              : '';
          var imgurl = "$firstImageUrl";
          
          // Extract sizes as a list of maps with attribute and stock
          List<Map<String, dynamic>> sizesList = product['sizes'].map<Map<String, dynamic>>((size) {
            return {
              'attribute': size['attribute'],
              'stock': size['stock'],
            };
          }).toList();
          
          productList.add({
            'name': product['name'],
            'color': product['color'],
            'image': imgurl, 
            'is_variant': product['is_variant'],
            'sizes': sizesList, // Add sizes list
          });
        }
      }
      
      setState(() {
        variant = productList;
        print("Variants List: $variant");
      });

      print("Fetched Products: $productList");
    }
  } catch (error) {
    print("Error: $error");
  }
}

Future<void> addtocart(BuildContext scaffoldContext,mainid,varid,sizeid,quantity) async{
    final token = await getTokenFromPrefs();
 try{
   final response= await http.post(Uri.parse('$api/api/cart/product/'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body:jsonEncode(
    {
     'product':mainid,
     'variant':varid,
     'size':sizeid,
     'quantity':quantity
    }
  )
  );
   print("Response: ${response.body}");
   print("ressss${response.statusCode}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
             backgroundColor: Colors.green,
            content: Text('Bank added Successfully.'),
          ),
        );
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>add_bank()));
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Adding Bank failed.'),
          ),
        );
      }
 }
 catch(e){
  print("error:$e");
 }
}

Future<void> addtocart2(BuildContext scaffoldContext,mainid,varid,quantity) async{
    final token = await getTokenFromPrefs();
 try{
   final response= await http.post(Uri.parse('$api/api/cart/product/'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body:jsonEncode(
    {
     'product':mainid,
     'variant':varid,
     'quantity':quantity
    }
  )
  );
   print("Response: ${response.body}");
   print("ressss${response.statusCode}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
             backgroundColor: Colors.green,
            content: Text('Bank added Successfully.'),
          ),
        );
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>add_bank()));
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Adding Bank failed.'),
          ),
        );
      }
 }
 catch(e){
  print("error:$e");
 }
}
Future<void> addtocart3(BuildContext scaffoldContext,mainid,quantity) async{
    final token = await getTokenFromPrefs();
 try{
   final response= await http.post(Uri.parse('$api/api/cart/product/'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body:jsonEncode(
    {
     'product':mainid,
     'quantity':quantity
    }
  )
  );
   print("Response: ${response.body}");
   print("ressss${response.statusCode}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
             backgroundColor: Colors.green,
            content: Text('Bank added Successfully.'),
          ),
        );
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>add_bank()));
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Adding Bank failed.'),
          ),
        );
      }
 }
 catch(e){
  print("error:$e");
 }
}
void showSizeDialog(BuildContext context, List<String> colors, List<Map<String, dynamic>> sizes, mainid, varid) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      String selectedColor = '';
      String selectedSize = '';
      int? selectedSizeId;
      int? selectedStock; // Variable to store the selected stock
      TextEditingController quantityController = TextEditingController(); // Controller for quantity input

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView( // Make the content scrollable if needed
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (selectedStock != null) // Show stock info only if a size is selected
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Available Stock: $selectedStock',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                    Wrap(
                      spacing: 10,
                      children: colors.map((color) {
                        return ChoiceChip(
                          label: Text(color),
                          selected: selectedColor == color,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedColor = selected ? color : '';
                            });
                          },
                          selectedColor: Colors.green,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 5,
                      children: sizes.map((sizeMap) {
                        String sizeAttribute = sizeMap['attribute'];
                        int sizeId = sizeMap['id'];
                        int stock = sizeMap['stock'];

                        return ChoiceChip(
                          label: Text(sizeAttribute),
                          selected: selectedSize == sizeAttribute,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedSize = sizeAttribute;
                                selectedSizeId = sizeId;
                                selectedStock = stock; // Update stock based on selected size
                                quantityController.clear(); // Clear quantity input when selecting a new size
                              } else {
                                selectedSize = '';
                                selectedSizeId = null;
                                selectedStock = null;
                              }
                            });
                          },
                          selectedColor:const Color.fromARGB(223, 229, 230, 231),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    if (selectedSize.isNotEmpty) // Show quantity input field only if a size is selected
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8),
                       child: SizedBox(
                         width: 300, // Set the desired width here
                         height: 40,
                         child: TextField(
                           controller: quantityController,
                           keyboardType: TextInputType.number,
                           decoration: InputDecoration(
                             labelText: 'Enter Quantity',
                             border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(10),
                             ),
                           ),
                         ),
                       ),
                     ),

                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          // Get the entered quantity value
                          int quantity = int.tryParse(quantityController.text) ?? 1;
                      
                          // Add logic for adding to cart, using selectedSizeId and quantity
                          print("Selected Size ID: $selectedSizeId");
                          print("Quantity: $quantity");
                      
                          // Call add to cart function
                          addtocart(context, mainid, varid, selectedSizeId, quantity);
                      
                          // Close the dialog after adding to cart
                          Navigator.of(context).pop();
                        },
                        child: Text("ADD TO CART", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}



void showSizeDialog2(BuildContext context, mainid,varid, stock) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      String selectedColor = '';
      String selectedSize = '';
      int? selectedSizeId;
      int? selectedStock; // Variable to store the selected stock
      TextEditingController quantityController = TextEditingController(); // Controller for quantity input

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView( // Make the content scrollable if needed
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (stock != null) // Show stock info only if a size is selected
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Available Stock: $stock',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                  
                    SizedBox(height: 10),
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8),
                       child: SizedBox(
                         width: 300, // Set the desired width here
                         height: 40,
                         child: TextField(
                           controller: quantityController,
                           keyboardType: TextInputType.number,
                           decoration: InputDecoration(
                             labelText: 'Enter Quantity',
                             border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(10),
                             ),
                           ),
                         ),
                       ),
                     ),

                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          // Get the entered quantity value
                          int quantity = int.tryParse(quantityController.text) ?? 1;
                      
                          // Add logic for adding to cart, using selectedSizeId and quantity
                          print("Selected Size ID: $selectedSizeId");
                          print("Quantity: $quantity");
                      
                          // Call add to cart function
                          addtocart2(context, mainid, varid,quantity);
                      
                          // Close the dialog after adding to cart
                          Navigator.of(context).pop();
                        },
                        child: Text("ADD TO CART", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
void showSizeDialog3(BuildContext context, mainid, stock) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      String selectedColor = '';
      String selectedSize = '';
      int? selectedSizeId;
      int? selectedStock; // Variable to store the selected stock
      TextEditingController quantityController = TextEditingController(); // Controller for quantity input

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView( // Make the content scrollable if needed
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (stock != null) // Show stock info only if a size is selected
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Available Stock: $stock',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                  
                    SizedBox(height: 10),
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8),
                       child: SizedBox(
                         width: 300, // Set the desired width here
                         height: 40,
                         child: TextField(
                           controller: quantityController,
                           keyboardType: TextInputType.number,
                           decoration: InputDecoration(
                             labelText: 'Enter Quantity',
                             border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(10),
                             ),
                           ),
                         ),
                       ),
                     ),

                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          // Get the entered quantity value
                          int quantity = int.tryParse(quantityController.text) ?? 1;
                      
                          // Add logic for adding to cart, using selectedSizeId and quantity
                          print("Selected Size ID: $selectedSizeId");
                          print("Quantity: $quantity");
                      
                          // Call add to cart function
                          addtocart2(context, mainid, varid,quantity);
                      
                          // Close the dialog after adding to cart
                          Navigator.of(context).pop();
                        },
                        child: Text("ADD TO CART", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

List<Map<String, dynamic>> extractSizeList(List<dynamic> sizes) {
  return sizes.map((size) {
    return {
      'id': size['id'],
      'attribute': size['attribute'],
      'stock': size['stock'],
    };
  }).toList();
}
List<String> extractStringList(List<dynamic> list, String key) {
  if (list is List) {
    return list.map((item) {
      if (item is Map && item.containsKey(key)) {
        return item[key]?.toString() ?? '';
      }
      return '';
    }).toList();
  }
  return [];
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(246, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          "Product List",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
          actions: [
          // Cart icon with badge
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.grey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => View_Cart()),
                    );
                  },
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(2),
                 
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                                   ),
                ),
              ],
            ),
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
     body: Container(
       child: Column(
         children: [
Padding(
  padding: const EdgeInsets.all(8.0),
  child: TextField(
    controller: searchController,
    decoration: InputDecoration(
      hintText: "Search products...",
      prefixIcon: Icon(Icons.search),
      fillColor: Colors.white, // Set your desired background color
      filled: true, // Enable background color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Colors.blue,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
    ),
    onChanged: (query) {
      _filterProducts(query); // Filter the products as the user types
    },
  ),
),



     Expanded(
  child: ListView.builder(
    itemCount: filteredProducts.length,
    itemBuilder: (context, index) {
      final product = filteredProducts[index];
      print('producttttttttttt$product');
      final isExpanded = expandedProducts[product['id']] ?? false;

      return Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 210, 209, 209).withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: product['image'] != null && product['image'].isNotEmpty
                    ? Image.network(
                        '${product['image']}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                      )
                    : Icon(Icons.image_not_supported),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${product['name']}",
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product['color'] != null && product['color'].isNotEmpty) // Display color if it exists
                      Text(
                        "Color: ${product['color']}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      
                  ],
                ),
                trailing: ElevatedButton.icon(
                onPressed: () {
  if (product['is_vaiant'] == true) {
    print("Product sizes data: ${product['sizes']}");
    // Ensure colors are non-null before passing to extractStringList
    List<String> colors = extractStringList(product['colors'] ?? [], 'color_name');
    List<Map<String, dynamic>> sizes = extractSizeList(product['sizes'] ?? []);
    print("Extracted sizes: $sizes");
    showSizeDialog(
      context,
      colors,
      sizes,
      product['mainid'],
      product['id'],
    );
  }
  else if(product['type'] == 'variant'){
        print("typeeeeeeeeeeeeeeeeeeeeeeeee${product['type']}");

    showSizeDialog2(
      context,
      product['mainid'],
      product['id'],
      product['stock'],
    );

  }
  else if(product['type']=='single'){
    print("typeeeeeeeeeeeeeeeeeeeeeeeee${product['type']}");
    showSizeDialog3(
      context,
      product['mainid'],
      product['stock'],
      );
  }

},

                  icon: Icon(
                    product['type'] == 'single' ? Icons.add : Icons.view_agenda,
                    size: 14,
                    color: Colors.white,
                  ),
                  label: Text(
                    product['type'] == 'single' ? "Add" : "View",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: product['type'] == 'single' || product['is_vaiant'] == false ? Colors.green : Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(60, 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ),
            // Display variant list if expanded
            if (isExpanded && product['variant_products'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 10, right: 10),
                child: Column(
                  children: product['variant_products'].map<Widget>((variantProduct) {
                    return Container(
                      height: 70,
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (variantProduct['image'] != null && variantProduct['image'].isNotEmpty)
                            Image.network(
                              variantProduct['image'],
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                            )
                          else
                            Icon(Icons.image_not_supported),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${variantProduct['name']} - ${variantProduct['color']} - Stock: ${variantProduct['stock']}",
                              style: TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      );
    },
  ),
),

         ],
       ),
     ),

    );
  }
}
