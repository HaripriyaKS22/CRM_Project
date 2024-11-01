import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/order_request.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class View_Cart extends StatefulWidget {
  const View_Cart({super.key});

  @override
  State<View_Cart> createState() => _View_CartState();
}

class _View_CartState extends State<View_Cart> {
  List<Map<String, dynamic>> cartdata = [];

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
            d.navigateToSelectedPage(context, option);
          },
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCartData();
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchCartData() async {
    try {
      final token = await getTokenFromPrefs();

      final response = await http.get(
        Uri.parse("$api/api/cart/products/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> cartsData = parsed['data'];
        List<Map<String, dynamic>> cartList = [];

        for (var cartData in cartsData) {
          String imageUrl = cartData['images'][0];
          cartList.add({
            'id': cartData['id'],
            'name': cartData['name'],
            'image': imageUrl,
            'slug': cartData['slug'],
            'size': cartData['size'],
            'quantity': cartData['quantity'],
            'price': cartData['price']
          });
        }

        setState(() {
          cartdata = cartList;
        });
      } else {
        throw Exception('Failed to load cart data');
      }
    } catch (error) {
      print(error); // Consider adding error handling in the UI
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
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
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 70),
                Text(
                  'BepoSoft',
                  style: TextStyle(
                    color: Color.fromARGB(236, 255, 255, 255),
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
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
            },
          ),
          Divider(),
          _buildDropdownTile(context, 'Credit Note', [
            'Add Credit Note',
            'Credit Note List',
          ]),
          _buildDropdownTile(context, 'Recipts', ['Add recipts', 'Recipts List']),
          _buildDropdownTile(context, 'Proforma Invoice', [
            'New Proforma Invoice',
            'Proforma Invoice List',
          ]),
          _buildDropdownTile(context, 'Delivery Note',
              ['Delivery Note List', 'Daily Goods Movement']),
          _buildDropdownTile(context, 'Orders', ['New Orders', 'Orders List']),
          Divider(),
          Text("Others"),
          Divider(),
          _buildDropdownTile(context, 'Product', [
            'Product List',
            'Stock',
          ]),
          _buildDropdownTile(context, 'Purchase', [' New Purchase', 'Purchase List']),
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
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          cartdata.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: cartdata.length,
                  itemBuilder: (context, index) {
                    final item = cartdata[index];
                    return Card(
                      elevation: 4,
                      color: Colors.white,
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Image.network(
                              "$api${item['image']}", // Ensure the API base URL is added
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("Size: ${item['size']}"),
                                  Text("Quantity: ${item['quantity']}"),
                                  Text("Price: ₹${item['price']}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>order_request()));
                  // Add your onPressed action here
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded edges
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Text(
                  'Continue', // Customize the text here
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
