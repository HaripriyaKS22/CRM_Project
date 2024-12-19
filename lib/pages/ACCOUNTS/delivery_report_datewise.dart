import 'dart:convert';

import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryReportDatewise extends StatefulWidget {
  final String date;
  const DeliveryReportDatewise({super.key, required this.date});

  @override
  State<DeliveryReportDatewise> createState() => _DeliveryReportDatewiseState();
}

class _DeliveryReportDatewiseState extends State<DeliveryReportDatewise> {
  List<Map<String, dynamic>> deliverydate = [];

  @override
  void initState() {
    super.initState();
    getdeliverydatewise();
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


  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getdeliverydatewise() async {
    try {
      final token = await gettokenFromPrefs();
      var response = await http.get(
        Uri.parse('$api/api/deliverylist/report/${widget.date}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      List<Map<String, dynamic>> deliverylist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          deliverylist.add({
            'invoice_name': productData['invoice'],
            'customer': productData['customer'],
            'order_date': productData['order_date'],
            'weight': productData['weight'],
            'volume_weight': productData['volume_weight'],
            'shipping_charge': productData['shipping_charge'],
            'tracking_id': productData['tracking_id'],
            'status': productData['status'],
          });
        }
        setState(() {
          deliverydate = deliverylist;
        });
      }
    } catch (error) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Delivery Report Date Wise",
          style: TextStyle(fontSize: 14, color: Colors.grey),
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
                      SizedBox(width: 70,),
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>dashboard()));
              },
            ),
                  ListTile(
              leading: Icon(Icons.person),
              title: Text('Customer'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>customer_list()));
                // Navigate to the Settings page or perform any other action
              },
            ),
             Divider(),
            _buildDropdownTile(context, 'Credit Note', ['Add Credit Note', 'Credit Note List',]),
            _buildDropdownTile(context, 'Recipts', ['Add recipts', 'Recipts List']),
            _buildDropdownTile(context, 'Proforma Invoice', ['New Proforma Invoice', 'Proforma Invoice List',]),
            _buildDropdownTile(context, 'Delivery Note', ['Delivery Note List', 'Daily Goods Movement']),
            _buildDropdownTile(context, 'Orders', ['New Orders', 'Orders List']),
             Divider(),

             Text("Others"),
             Divider(),

            _buildDropdownTile(context, 'Product', ['Product List', 'Stock',]),
            _buildDropdownTile(context, 'Purchase', [' New Purchase', 'Purchase List']),
            _buildDropdownTile(context, 'Expence', ['Add Expence', 'Expence List',]),
            _buildDropdownTile(context, 'Reports', ['Sales Report', 'Credit Sales Report','COD Sales Report','Statewise Sales Report','Expence Report','Delivery Report','Product Sale Report','Stock Report','Damaged Stock']),
            _buildDropdownTile(context, 'GRV', ['Create New GRV', 'GRVs List']),
             _buildDropdownTile(context, 'Banking Module', ['Add Bank ', 'List','Other Transfer']),
               Divider(),




            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Methods'),
              onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context)=>Methods()));

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


      body: ListView.builder(
        itemCount: deliverydate.length,
        itemBuilder: (context, index) {
          var delivery = deliverydate[index];

          return Card(
            elevation: 5,
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${delivery['invoice_name']}/${delivery['order_date']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        '${delivery['status']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: delivery['status'] == 'Delivered'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 1, color: Colors.grey),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${delivery['customer']}',
                        style: TextStyle(fontSize: 16),
                      ),
                        SizedBox(height: 8),
                      Text(
                        'Tracking ID: ${delivery['tracking_id']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Weight: ${delivery['weight']} kg',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Volume Weight: ${delivery['volume_weight']} kg',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Shipping Charge: ₹${delivery['shipping_charge']}',
                        style: TextStyle(fontSize: 16),
                      ),
                    
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
