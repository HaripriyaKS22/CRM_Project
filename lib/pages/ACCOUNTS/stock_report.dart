import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/invoice_report.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Stock_Report extends StatefulWidget {
  const Stock_Report({super.key});

  @override
  State<Stock_Report> createState() => _Stock_ReportState();
}

class _Stock_ReportState extends State<Stock_Report> {
  List<Map<String, dynamic>> salesReportList = [];
    List<Map<String, dynamic>> allSalesReportList = []; // Original data
  double totalstock = 0.0;
  double totalsold = 0.0;
  double remaingitem = 0.0;
  double approvedAmount = 0.0;
  double rejectedBills = 0.0;
  double rejectedAmount = 0.0;
 TextEditingController searchController = TextEditingController();
  DateTime? selectedDate; // For single date filter
  DateTime? startDate; // For date range filter
  DateTime? endDate; // For date range filter

  @override
  void initState() {
    super.initState();
    getStockReport();
  }

  // Method to filter orders by single date
  void _filterOrdersBySingleDate() {
    if (selectedDate != null) {
      setState(() {
        salesReportList = salesReportList.where((order) {
          final orderDate = _parseDate(order['date']);
          return orderDate.year == selectedDate!.year &&
              orderDate.month == selectedDate!.month &&
              orderDate.day == selectedDate!.day;
        }).toList();
        _updateTotals();
      });
    }
  }

  // Method to filter orders between two dates, inclusive of start and end dates
  void _filterOrdersByDateRange() {
    if (startDate != null && endDate != null) {
      setState(() {
        salesReportList = salesReportList.where((order) {
          final orderDate = _parseDate(order['date']);
          return (orderDate.isAtSameMomentAs(startDate!) ||
              orderDate.isAtSameMomentAs(endDate!) ||
              (orderDate.isAfter(startDate!) && orderDate.isBefore(endDate!)));
        }).toList();
        _updateTotals();
      });
    }
  }

  // Function to parse both MM/dd/yy and yyyy-MM-dd formats
  DateTime _parseDate(String dateString) {
    try {
      return DateFormat('MM/dd/yy').parseStrict(dateString);
    } catch (e) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        throw FormatException('Invalid date format: $dateString');
      }
    }
  }

  // Function to update totals based on filtered data
  void _updateTotals() {
    double tempTotalstock = 0.0;
    double tempTotalsold = 0.0;
    double tempremaining = 0.0;
    double tempApprovedAmount = 0.0;
    double tempRejectedBills = 0.0;
    double tempRejectedAmount = 0.0;

    for (var reportData in salesReportList) {
      tempTotalstock += reportData['stock_quantity'];
            print("temptotalstock:$tempTotalstock");

      tempTotalsold += reportData['items_sold'];
      tempremaining += reportData['remaining_stock'];
      // tempApprovedAmount += reportData['approved']['amount'];
      // tempRejectedBills += reportData['rejected']['bills'];
      // tempRejectedAmount += reportData['rejected']['amount'];
    }

    setState(() {
      totalstock = tempTotalstock;
      print("totalstock:$totalstock");
      totalsold = tempTotalsold;
      remaingitem = tempremaining;
      // approvedAmount = tempApprovedAmount;
      // rejectedBills = tempRejectedBills;
      // rejectedAmount = tempRejectedAmount;
    });
  }

  Future<void> _selectSingleDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        print("selectedDate:$selectedDate");
      });
      _filterOrdersBySingleDate();
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _filterOrdersByDateRange();
    }
  }

  drower d = drower();

  // Get token from SharedPreferences
  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getStockReport() async {
    setState(() {});
    try {
      final token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/stock/products/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Response:${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var salesData = parsed['data'];
        print(salesData);

        List<Map<String, dynamic>> salesReportDataList = [];
        for (var reportData in salesData) {
          salesReportDataList.add({
            'date': reportData['date'],
            'product_title': reportData['product_title'],
            'stock_quantity': reportData['stock_quantity'],
            'items_sold': reportData['items_sold'],
            'remaining_stock': reportData['remaining_stock'],            
          });
        }
        setState(() {
              allSalesReportList = salesReportDataList; // Save original data
          salesReportList = allSalesReportList;
          _updateTotals();
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

 void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        salesReportList = List.from(salesReportList); // Show all if search is empty
      } else {
        salesReportList = salesReportList
            .where((product) =>
                product['product_title'].toLowerCase().contains(query.toLowerCase()))
            .toList(); // Filter based on query
      }
    });
    _updateTotals();
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
          "Stock Report",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          IconButton(
            icon: Image.asset('lib/assets/profile.png'),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              print("presseddd");
               _selectSingleDate(context);
            }
          ),
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
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
      body:Column(
  children: [
    // Search bar
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search Staff...",
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
        onChanged: _filterProducts, // Filtering logic
      ),
    ),

    // Main content in Stack
    Expanded(
      child: Stack(
        children: [
          // Main content: Sales report list
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 260),
            child: Column(
              children: salesReportList.map((reportData) {
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${reportData['date']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        Divider(color: Colors.grey),
                        SizedBox(height: 8),
                        _buildRow('Product Title :', reportData['product_title']),
                        _buildRow('Stock :', reportData['stock_quantity']),
                        _buildRow('Items Sold :', reportData['items_sold']),
                        _buildRow('Remaining Stock :', reportData['remaining_stock']),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom summary card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 12,
              color: const Color.fromARGB(255, 12, 80, 163),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: const Color.fromARGB(255, 12, 80, 163),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Report Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.5),
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Total Stocks: ', style: TextStyle(color: Colors.white)),
                        Spacer(),
                        Text('$totalstock', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Total Item Sold: ', style: TextStyle(color: Colors.white)),
                        Spacer(),
                        Text('$totalsold', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Remaining Item: ', style: TextStyle(color: Colors.white)),
                        Spacer(),
                        Text('$remaingitem', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
)

    );
  }
}