import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Sold_pro_report extends StatefulWidget {
  const Sold_pro_report({super.key});

  @override
  State<Sold_pro_report> createState() => _Sold_pro_reportState();
}

class _Sold_pro_reportState extends State<Sold_pro_report> {
  List<Map<String, dynamic>> groupedData = [];
  List<Map<String, dynamic>> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  String? selectedstaff;
  List<Map<String, dynamic>> sta = [];

  @override
  void initState() {
    super.initState();
    getSoldReport();
    getstaff();
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getstaff() async {
    try {
      final token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/staffs/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      List<Map<String, dynamic>> stafflist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          stafflist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          sta = stafflist;
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<void> getSoldReport() async {
    try {
      final token = await getTokenFromPrefs();
      var response = await http.get(
        Uri.parse('$api/api/sold/products/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> soldProducts = parsed;

        List<Map<String, dynamic>> orderList = [];

        for (var dateGroup in soldProducts) {
          String date = dateGroup['date'];
          int stock = dateGroup['stock'] ?? 0;
          List products = dateGroup['data'];

          for (var product in products) {
            orderList.add({
              'date': date,
              'product': product['product'],
              'order': product['order'],
              'manage_staff': product['manage_staff'],
              'total_sold': product['total_sold'],
              'total_amount': product['total_amount'],
              'stock': stock,
            });
          }
        }

        setState(() {
          groupedData = orderList;
          filteredProducts = orderList; // Initialize filteredProducts
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch sold product report data'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching sold product report data'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty && selectedstaff == null && startDateController.text.isEmpty && endDateController.text.isEmpty) {
      setState(() {
        filteredProducts = groupedData; // Reset to all products when no filters are applied
      });
    } else {
      setState(() {
        filteredProducts = groupedData.where((order) {
          bool matchesProduct = order['product']
              .toLowerCase()
              .contains(query.toLowerCase());
          bool matchesStaff = selectedstaff == null ||
              order['manage_staff']
                  .toLowerCase()
                  .contains(selectedstaff!.toLowerCase());

          // Date filtering logic
          bool matchesDate = true;
          if (startDateController.text.isNotEmpty && endDateController.text.isNotEmpty) {
            DateTime startDate = DateTime.parse(startDateController.text);
            DateTime endDate = DateTime.parse(endDateController.text);
            DateTime orderDate = DateTime.parse(order['date']);
            matchesDate = orderDate.isAfter(startDate.subtract(Duration(days: 1))) &&
                          orderDate.isBefore(endDate.add(Duration(days: 1)));
          } else if (startDateController.text.isNotEmpty) {
            DateTime startDate = DateTime.parse(startDateController.text);
            DateTime orderDate = DateTime.parse(order['date']);
            matchesDate = orderDate.isAfter(startDate.subtract(Duration(days: 1)));
          } else if (endDateController.text.isNotEmpty) {
            DateTime endDate = DateTime.parse(endDateController.text);
            DateTime orderDate = DateTime.parse(order['date']);
            matchesDate = orderDate.isBefore(endDate.add(Duration(days: 1)));
          }

          return matchesProduct && matchesStaff && matchesDate;
        }).toList();
      });
    }
  }

  // This function will be triggered when the user pulls to refresh
  Future<void> _refreshData() async {
    await getSoldReport(); // Reload the data by fetching it again
    setState(() {
      filteredProducts = groupedData; // Ensure the data is refreshed
    });
  }

  // Date range picker function
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: 7)),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedRange != null) {
      setState(() {
        startDateController.text = "${pickedRange.start.toLocal()}".split(' ')[0];
        endDateController.text = "${pickedRange.end.toLocal()}".split(' ')[0];
      });
      _filterProducts(searchController.text); // Apply filters after selecting the date range
    }
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sold Product Report",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              await _selectDateRange(context); // Select date range when clicked
            },
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => add_department()));
                // Navigate to the Settings page or perform any other action
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Supervisors'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => add_supervisor()));
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CourierServices()));
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
                        builder: (context) => WarehouseOrderView(
                              status: null,
                            )));
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
                hintText: "Search products...",
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.white, 
                filled: true, 
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
                _filterProducts(query); 
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              height: 59,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Container(
                    width: 276,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 1),
                      ),
                      child: DropdownButton<String>(
                        value: selectedstaff,
                        isExpanded: true,
                        hint: Text(
                          "Select Staff",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        underline: Container(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedstaff = newValue;
                            _filterProducts(searchController.text); 
                          });
                        },
                        items: sta.map<DropdownMenuItem<String>>((staff) {
                          return DropdownMenuItem<String>( 
                            value: staff['name'],
                            child: Text(staff['name'], style: TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        icon: Container(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData, // Trigger the refresh
              child: filteredProducts.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        var order = filteredProducts[index];
                        String date = order['date'];
                        int stock = order['stock'];

                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.all(8),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sold Product on $date',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Stock: $stock',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Card(
                                  color: Colors.white,
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Order: ${order['order']}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Divider(),
                                              Text(
                                                'Staff: ${order['manage_staff']}',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Divider(),
                                              Text(
                                                'Product: ${order['product']}',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text('Total Sold: ${order['total_sold']}'),
                                              Text('Amount: ${order['total_amount']}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
