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
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Product_List extends StatefulWidget {
  const Product_List({super.key});

  @override
  State<Product_List> createState() => _Product_ListState();
}

class _Product_ListState extends State<Product_List> {
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

  List<Map<String, dynamic>> fam = [];
  List<Map<String, dynamic>> products = [];
  List<bool> _checkboxValues = [];
  List<Map<String, dynamic>> filteredProducts = [];
  TextEditingController searchController =
      TextEditingController(); // Search controller

  @override
  void initState() {
    super.initState();
    getFamily();
    initdata();
  }
var warehouse;
  Future<void> initdata() async {
    
    await fetchProductList();
    setState(() {
      filteredProducts = products;
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


   Future<String?> getwarwhouseFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('warehouse').toString();
  }

  Future<void> getFamily() async {
    try {
      final token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/familys/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Family Data Response: ${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];
        List<Map<String, dynamic>> familyList = [];

        for (var productData in productsData) {
          familyList.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }

        setState(() {
          fam = familyList;
          _checkboxValues = List<bool>.filled(fam.length, false);
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
      });
    }
  } catch (error) {
    print("Error: $error");
  }
}
Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Custom back arrow
          onPressed: () async{
                    final dep= await getdepFromPrefs();
if(dep=="BDO" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => bdo_dashbord()), // Replace AnotherPage with your target page
            );

}
else if(dep=="BDM" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => bdm_dashbord()), // Replace AnotherPage with your target page
            );
}
else {
    Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => dashboard()), // Replace AnotherPage with your target page
            );

}
           
          },
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
             child: RefreshIndicator(
              onRefresh: fetchProductList,
               child: ListView.builder(
                 itemCount: filteredProducts.length, // Show filtered products
                 itemBuilder: (context, index) {
                   final product = filteredProducts[index];
                   return Padding(
                 padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                 child: Container(
                   height: 80,
                   decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0), // Add border radius here
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 210, 209, 209).withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                   ),
                   child: ListTile(
                leading: product['image'] != null && product['image'].isNotEmpty
                    ? Image.network(
                        '${product['image']}', // Display product image
                        width: 50, // Set width for the image
                        height: 50, // Set height for the image
                        fit: BoxFit.cover, // Adjust the image aspect ratio
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.error), // Handle image load error
                      )
                    : Icon(Icons.image_not_supported), // Placeholder if no image
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${product['name']}",
                        style: TextStyle(fontSize: 14),
                        maxLines: 1, // Ensures the text only takes up one line
                        overflow: TextOverflow.ellipsis, // Adds ellipsis if the text is too long
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => add_product_variant(id: product['id'], type: product['type']),
                          ),
                        );
                      },
                      label: Text(
                        "View",
                        style: TextStyle(color: Colors.white, fontSize: 10), // White text with smaller font size
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Blue background color
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Smaller padding
                        minimumSize: const Size(60, 24), // Set a smaller minimum size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                        ),
                      ),
                    ),
                  ],
                ),
                   ),
                 ),
               );
               
                 },
               ),
             ),
           ),
           SizedBox(height: 20,)
         ],
       ),
     ),

    );
  }
}
