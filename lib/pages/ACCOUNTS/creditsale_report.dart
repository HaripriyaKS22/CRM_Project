import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/creditsale_date_report.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Creditsalereport2 extends StatefulWidget {
  const Creditsalereport2({super.key});

  @override
  State<Creditsalereport2> createState() => _Creditsalereport2State();
}

class _Creditsalereport2State extends State<Creditsalereport2> {
  List<Map<String, dynamic>> allSalesReportList = [];
  List<Map<String, dynamic>> fam = [];
  List<Map<String, dynamic>> sta = [];
  String? selectedFamily;
  String? selectedStaff;

  @override
  void initState() {
    super.initState();
    getfamily();
    getCreditsaleReport();
    getstaff();
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch staff list from the API
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
      // Handle error
    }
  }

  // Fetch family list from the API
  Future<void> getfamily() async {
    try {
      final token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/familys/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      List<Map<String, dynamic>> familylist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          familylist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          fam = familylist;
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  // Fetch sales report
  Future<void> getCreditsaleReport() async {
    setState(() {});
    try {
      final token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/credit/sales/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final salesData = jsonDecode(response.body);

        List<Map<String, dynamic>> salesReportDataList = [];

        for (var reportData in salesData) {
          // Filter orders based on the selected family and staff name
          if (selectedFamily != null) {
            reportData['orders'] = reportData['orders'].where((order) {
              return order['family_name'] == selectedFamily;
            }).toList();
          }

          if (selectedStaff != null) {
            reportData['orders'] = reportData['orders'].where((order) {
              return order['staff_name'] == selectedStaff;
            }).toList();
          }

          double totalAmount = 0.0;
          int totalOrders = 0;
          double totalPaidAmount = 0.0;
          double balanceAmount = 0.0;

          for (var order in reportData['orders']) {
            totalAmount += order['total_amount'];
          }

          totalOrders = reportData['orders'].length;
          totalPaidAmount = reportData['orders']
              .fold(0.0, (sum, order) => sum + order['total_paid_amount']);
          balanceAmount = reportData['orders']
              .fold(0.0, (sum, order) => sum + order['balance_amount']);

          salesReportDataList.add({
            'date': reportData['date'],
            'total_amount': totalAmount,
            'total_orders': totalOrders,
            'total_paid_amount': totalPaidAmount,
            'balance_amount': balanceAmount,
          });
        }

        setState(() {
          allSalesReportList = salesReportDataList;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch sales report data'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching sales report data'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {});
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Credit Sale Report',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
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
          // Dropdown for selecting a family
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Select Family',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select Family"),
                  value: selectedFamily,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFamily = newValue;
                    });
                    getCreditsaleReport();
                  },
                  items: fam.map((family) {
                    return DropdownMenuItem<String>(
                      value: family['name'],
                      child: Text(family['name']),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // Dropdown for selecting staff
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Select Staff',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select Staff"),
                  value: selectedStaff,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStaff = newValue;
                    });
                    getCreditsaleReport();
                  },
                  items: sta.map((staff) {
                    return DropdownMenuItem<String>(
                      value: staff['name'],
                      child: Text(staff['name']),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // Displaying the sales report data
          allSalesReportList.isEmpty
              ? Center(child: CircularProgressIndicator()) // Loading indicator
              : Expanded(
                  child: ListView.builder(
                    itemCount: allSalesReportList.length,
                    itemBuilder: (context, index) {
                      final report = allSalesReportList[index];
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.all(8.0),
                        elevation: 5.0,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            'Date: ${report['date']}',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: Colors.grey),
                              Text(
                                'Total Orders: ${report['total_orders']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total Amount: ₹${report['total_amount']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total Paid Amount: ₹${report['total_paid_amount']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Balance Amount: ₹${report['balance_amount']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10,),
                               ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreditsaleDateReport(date: report['date']),
                          ),
                        );
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
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
