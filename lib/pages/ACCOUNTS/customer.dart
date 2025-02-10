import 'dart:convert';

import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_address.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/customer_ledger.dart';
import 'package:beposoft/pages/ACCOUNTS/customer_singleview.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/view_customer.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

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

class customer_list extends StatefulWidget {
  const customer_list({super.key});

  @override
  State<customer_list> createState() => _customer_listState();
}

class _customer_listState extends State<customer_list> {
  List<Map<String, dynamic>> fam = [];
  List<bool> _checkboxValues = [];
  String? _selectedFamily;
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    getcustomer();
  }

  List<String> categories = ["cycling", 'skating', 'fitness', 'bepocart'];
  String selectededu = "cycling";
  
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

  List<Map<String, dynamic>> customer = [];
  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
 Future<void> getcustomer() async {
  try {
    final dep = await getdepFromPrefs();
    final token = await gettokenFromPrefs();

    final jwt = JWT.decode(token!);
    var name = jwt.payload['name'];
    print("Name: $name");
    print("Decoded Token Payload: ${jwt.payload}");

    String? nextPageUrl = '$api/api/customers/';
    List<Map<String, dynamic>> managerlist = [];

    while (nextPageUrl != null) {
      var response = await http.get(
        Uri.parse(nextPageUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Customer data response: ${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['results']['data'];

        List<Map<String, dynamic>> newCustomers = [];

        for (var productData in productsData) {
          newCustomers.add({
            'id': productData['id'],
            'name': productData['name'],
            'created_at': productData['created_at'],
          });
        }

        // Append new data and update UI in each iteration
        setState(() {
          customer.addAll(newCustomers);
          filteredProducts.addAll(newCustomers);
        });

        // Update nextPageUrl to continue fetching next pages
        nextPageUrl = parsed['next'];
      } else {
        throw Exception("Failed to load customer data");
      }
    }
  } catch (error) {
    print("Error fetching customers: $error");
  }
}
  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(customer); // Show all if search is empty
      } else {
        filteredProducts = customer
            .where((product) =>
                product['name'].toLowerCase().contains(query.toLowerCase()))
            .toList(); // Filter based on query
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
       appBar: AppBar(
        title: Text(
          "Customer List",
          style: TextStyle(fontSize: 14, color: Colors.grey),
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
        actions: [
          IconButton(
            icon: Image.asset('lib/assets/profile.png'),
            onPressed: () {},
          ),
        ],
      ),
      //  drawer: Drawer(
      //     child: ListView(
      //       padding: EdgeInsets.zero,
      //       children: <Widget>[
      //         DrawerHeader(
      //             decoration: BoxDecoration(
      //               color: Colors.grey[200],
      //             ),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Image.asset(
      //                   "lib/assets/logo.png",
      //                   width: 150, // Change width to desired size
      //                   height: 150, // Change height to desired size
      //                   fit: BoxFit
      //                       .contain, // Use BoxFit.contain to maintain aspect ratio
      //                 ),
      //               ],
      //             )),
      //         ListTile(
      //           leading: Icon(Icons.dashboard),
      //           title: Text('Dashboard'),
      //           onTap: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => dashboard()));
      //           },
      //         ),
             
      //         ListTile(
      //           leading: Icon(Icons.person),
      //           title: Text('Company'),
      //           onTap: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => add_company()));
      //             // Navigate to the Settings page or perform any other action
      //           },
      //         ),
      //         ListTile(
      //           leading: Icon(Icons.person),
      //           title: Text('Departments'),
      //           onTap: () {
      //             Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (context) => add_department()));
      //             // Navigate to the Settings page or perform any other action
      //           },
      //         ),
      //         ListTile(
      //           leading: Icon(Icons.person),
      //           title: Text('Supervisors'),
      //           onTap: () {
      //             Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (context) => add_supervisor()));
      //             // Navigate to the Settings page or perform any other action
      //           },
      //         ),
      //         ListTile(
      //           leading: Icon(Icons.person),
      //           title: Text('Family'),
      //           onTap: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => add_family()));
      //             // Navigate to the Settings page or perform any other action
      //           },
      //         ),
      //         ListTile(
      //           leading: Icon(Icons.person),
      //           title: Text('Bank'),
      //           onTap: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => add_bank()));
      //             // Navigate to the Settings page or perform any other action
      //           },
      //         ),
      //         ListTile(
      //           leading: Icon(Icons.person),
      //           title: Text('States'),
      //           onTap: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => add_state()));
      //             // Navigate to the Settings page or perform any other action
      //           },
      //         ),
      //         ListTile(
      //           leading: Icon(Icons.person),
      //           title: Text('Attributes'),
      //           onTap: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => add_attribute()));
      //             // Navigate to the Settings page or perform any other action
      //           },
      //         ),
      //         ListTile(
      //           leading: Icon(Icons.person),
      //           title: Text('Services'),
      //           onTap: () {
      //             Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (context) => CourierServices()));
      //             // Navigate to the Settings page or perform any other action
      //           },
      //         ),
      //          ListTile(
      //           leading: Icon(Icons.person),
      //           title: Text('Delivery Notes'),
      //           onTap: () {
      //             Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (context) => WarehouseOrderView(status: null,)));
      //             // Navigate to the Settings page or perform any other action
      //           },
      //         ),
      //         Divider(),
      //         _buildDropdownTile(context, 'Reports', [
      //           'Sales Report',
      //           'Credit Sales Report',
      //           'COD Sales Report',
      //           'Statewise Sales Report',
      //           'Expence Report',
      //           'Delivery Report',
      //           'Product Sale Report',
      //           'Stock Report',
      //           'Damaged Stock'
      //         ]),
      //         _buildDropdownTile(context, 'Customers', [
      //           'Add Customer',
      //           'Customers',
      //         ]),
      //         _buildDropdownTile(context, 'Staff', [
      //           'Add Staff',
      //           'Staff',
      //         ]),
      //         _buildDropdownTile(context, 'Credit Note', [
      //           'Add Credit Note',
      //           'Credit Note List',
      //         ]),
      //         _buildDropdownTile(context, 'Proforma Invoice', [
      //           'New Proforma Invoice',
      //           'Proforma Invoice List',
      //         ]),
      //         _buildDropdownTile(context, 'Delivery Note',
      //             ['Delivery Note List', 'Daily Goods Movement']),
      //         _buildDropdownTile(
      //             context, 'Orders', ['New Orders', 'Orders List']),
      //         Divider(),
      //         Text("Others"),
      //         Divider(),
      //         _buildDropdownTile(context, 'Product', [
      //           'Product List',
      //           'Product Add',
      //           'Stock',
      //         ]),
      //         _buildDropdownTile(context, 'Expence', [
      //           'Add Expence',
      //           'Expence List',
      //         ]),
      //         _buildDropdownTile(
      //             context, 'GRV', ['Create New GRV', 'GRVs List']),
      //         _buildDropdownTile(context, 'Banking Module',
      //             ['Add Bank ', 'List', 'Other Transfer']),
      //         Divider(),
      //         ListTile(
      //           leading: Icon(Icons.settings),
      //           title: Text('Methods'),
      //           onTap: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => Methods()));
      //           },
      //         ),
      //         ListTile(
      //           leading: Icon(Icons.chat),
      //           title: Text('Chat'),
      //           onTap: () {
      //             Navigator.pop(context); // Close the drawer
      //           },
      //         ),
      //         Divider(),
      //         ListTile(
      //           leading: Icon(Icons.exit_to_app),
      //           title: Text('Logout'),
      //           onTap: () {
      //             logout();
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      body:Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
   Padding(
  padding: const EdgeInsets.all(8.0),
  child: TextField(
    controller: searchController,
    decoration: InputDecoration(
      hintText: "Search customers...",
      prefixIcon: Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Colors.blue, // Set your desired border color here
          width: 2.0, // Set the border width
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Colors.blue, // Border color when TextField is not focused
          width: 2.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Colors.blueAccent, // Border color when TextField is focused
          width: 2.0,
        ),
      ),
    ),
    onChanged: _filterProducts,
  ),
),

    Expanded(
      child: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final customerData = filteredProducts[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerData['name'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Created on: ${customerData['created_at']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,color:Colors.blue),
                    onSelected: (value) {
                      if (value == 'View') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => view_customer(customerid:customerData['id']),
                          ),
                        );
                      } else if (value == 'Add Address') {
                       Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => add_address(customerid:customerData['id'],name:customerData['name']),
                          ),
                        );
                      }
                      else if (value == 'View Ledger') {
                       Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerLedger(customerid:customerData['id'],customerName:customerData['name']),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'View',
                        child: Text('View'),
                      ),
                      PopupMenuItem<String>(
                        value: 'Add Address',
                        child: Text('Add Address'),
                      ),
                       PopupMenuItem<String>(
                        value: 'View Ledger',
                        child: Text('View Ledger'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ],
)

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
          MaterialPageRoute(builder: (context) => add_credit_note()),
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
        // Handle default case or unexpected options
        break;
    }
  }
}
