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

class Invoice_Report extends StatefulWidget {
  final date;
  const Invoice_Report({super.key, required this.date});

  @override
  State<Invoice_Report> createState() => _Invoice_ReportState();
}

class _Invoice_ReportState extends State<Invoice_Report> {
  List<Map<String, dynamic>> invoicedata = [];
  List<Map<String, dynamic>> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchinvoicereport();
    print("===========================>>>>>>>>${widget.date}");
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

  Future<void> fetchinvoicereport() async {
    try {
      final token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/invoicereport/${widget.date}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("09=------------------------${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        List<Map<String, dynamic>> invoiceList = [];
        for (var productData in productsData) {
          invoiceList.add({
            'staff_name': productData['staff_name'],
            'total_bills': productData['total_bills'],
            'total_amount_': productData['total_amount_'],
            'approved_bills': productData['approved_bills'],
            'rejected_bills': productData['rejected_bills'],
            'approved_amount': productData['approved_amount'],
            'rejected_amount': productData['rejected_amount'],
            'state_name': productData['state_name'],
            'family': productData['family'],
          });
        }
        setState(() {
          invoicedata = invoiceList;
          filteredProducts = invoiceList; // Initially show all data
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch invoice report'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching invoice report'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Method to filter products based on search input
  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(invoicedata); // Show all if search is empty
      } else {
        filteredProducts = invoicedata
            .where((invoice) =>
                invoice['staff_name']
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                invoice['family']
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                invoice['state_name']
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList(); // Filter based on query
      }
    });
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

  Widget _buildRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User: ${invoice['staff_name']} / ${invoice['family']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Divider(color: Colors.grey),
            SizedBox(height: 8),
            _buildRow('Total Bills:', invoice['total_bills']),
            _buildRow('Total Amount:', invoice['total_amount_']),
            _buildRow('Approved Bills:', invoice['approved_bills']),
            _buildRow('Approved Amount:', invoice['approved_amount']),
            _buildRow('Rejected Bills:', invoice['rejected_bills']),
            _buildRow('Rejected Amount:', invoice['rejected_amount']),
            SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                // Handle "View" button action
              },
              child: Text(
                "View",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Invoice Report",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
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
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by State...",
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
                return _buildInvoiceCard(filteredProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
