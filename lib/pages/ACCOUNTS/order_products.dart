import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/add_product_variant.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
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
        print("Productsssssssssssss$products");
      });
    }
  } catch (error) {
    print("Error: $error");
  }
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
          var imgurl = "$api/$firstImageUrl";
          
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
            'image': imgurl, // Add the first image URL for variants
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(246, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          "Product List",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
       
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
          final isExpanded = expandedProducts[product['id']] ?? false;

          return Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 80,
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
                            '$api${product['image']}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                          )
                        : Icon(Icons.image_not_supported),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${product['name']}",
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        product['type'] == 'single'
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  // Add functionality for Add button
                                },
                                icon: Icon(
                                  Icons.add,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                label: Text("Add", style: TextStyle(color: Colors.white, fontSize: 10)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: const Size(60, 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () => _getAndShowVariants(product['id']),
                                icon: Icon(Icons.view_agenda, size: 14),
                                label: Text("View", style: TextStyle(color: Colors.white, fontSize: 10)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: const Size(60, 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                // Display variant list if expanded
                if (isExpanded && variant.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 10, right: 10),
                    child: Column(
                      children: variant.map((variantProduct) {
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
                                  width: 50,
                                  height: 50,
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
