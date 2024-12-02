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

class Sales_Report extends StatefulWidget {
  const Sales_Report({super.key});

  @override
  State<Sales_Report> createState() => _Sales_ReportState();
}

class _Sales_ReportState extends State<Sales_Report> {
  List<Map<String, dynamic>> salesReportList = [];
    List<Map<String, dynamic>> filterdata = [];
List<Map<String, dynamic>> sta = [];

  double totalBills = 0.0;
  double totalAmount = 0.0;
  double approvedBills = 0.0;
  double approvedAmount = 0.0;
  double rejectedBills = 0.0;
  double rejectedAmount = 0.0;
    int? selectedstaffId;

  DateTime? selectedDate; // For single date filter
  DateTime? startDate; // For date range filter
  DateTime? endDate; // For date range filter

  @override
  void initState() {
    super.initState();
    getSalesReport();
    getstaff();
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
      print(
          "RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD${response.body}");
      List<Map<String, dynamic>> stafflist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$parsed");
        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          stafflist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          sta = stafflist;
          print("sataffffffffffff$sta");
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }

void _filterOrdersBySingleDate() {
  print(selectedDate);
    if (selectedDate != null) {
      setState(() {
        filterdata = salesReportList.where((order) {
          // Parse the 'expense_date' from string to DateTime if needed
          final orderDate = DateFormat('yyyy-MM-dd').parse(order['date']); // Adjust format if needed

          // Compare only the date part (ignoring time)
          return orderDate.year == selectedDate!.year &&
              orderDate.month == selectedDate!.month &&
              orderDate.day == selectedDate!.day;
        }).toList();
      });
    }
  }
  // Method to filter orders between two dates, inclusive of start and end dates
   void _filterOrdersByDateRange() {
    if (startDate != null && endDate != null) {
      setState(() {
        filterdata = salesReportList.where((order) {
          // Parse the 'expense_date' from string to DateTime if needed
          final orderDate = DateFormat('yyyy-MM-dd').parse(order['date']); // Adjust format if needed

          // Check if the order date is within the selected range
          return orderDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
              orderDate.isBefore(endDate!.add(Duration(days: 1)));
        }).toList();
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
    double tempTotalBills = 0.0;
    double tempTotalAmount = 0.0;
    double tempApprovedBills = 0.0;
    double tempApprovedAmount = 0.0;
    double tempRejectedBills = 0.0;
    double tempRejectedAmount = 0.0;

    for (var reportData in salesReportList) {
      tempTotalBills += reportData['total_bills_in_date'];
      tempTotalAmount += reportData['amount'];
      tempApprovedBills += reportData['approved']['bills'];
      tempApprovedAmount += reportData['approved']['amount'];
      tempRejectedBills += reportData['rejected']['bills'];
      tempRejectedAmount += reportData['rejected']['amount'];
    }

    setState(() {
      totalBills = tempTotalBills;
      totalAmount = tempTotalAmount;
      approvedBills = tempApprovedBills;
      approvedAmount = tempApprovedAmount;
      rejectedBills = tempRejectedBills;
      rejectedAmount = tempRejectedAmount;
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

  void _filterDataByStaff(int staffId) {
  setState(() {
    // Ensure salesReportList is not null
    if (salesReportList == null || salesReportList.isEmpty) {
      print("salesReportList == null || salesReportList.isEmpty");
      filterdata = [];
      return;
    }

    filterdata = salesReportList
        .map((report) {
          // Guard against null in report['staff_orders']
          List<dynamic> staffOrders = report['staff_orders'] ?? [];
          List<dynamic> filteredOrders = staffOrders
              .where((order) => order['manage_staff_id'] == staffId)
              .toList();

          // If no orders match, exclude this report
          if (filteredOrders.isEmpty) return null;

          // Initialize metrics
          int approvedBills = 0;
          double approvedAmount = 0.0;
          int rejectedBills = 0;
          double rejectedAmount = 0.0;
          int totalBillsInDate = 0;  // Total number of bills for the staff in this report
          double totalAmount = 0.0;  // Total amount for the staff in this report

          // Define statuses
          List<String> approvedStatuses = [
            "Completed",
            "Shipped",
            "Waiting For Confirmation",
            "Invoice Created",
            "Invoice Approved",
            "To Print",
            "Processing"
          ];
          List<String> rejectedStatuses = [
            "Cancelled",
            "Refunded",
            "Return",
            "Invoice Rejectd"
          ];

          // Calculate totals for the filtered orders
          for (var order in filteredOrders) {
            // Accumulate total bills and amounts for the staff
            totalBillsInDate++;  // Each filtered order corresponds to a bill
            totalAmount += order['total_amount'] ?? 0.0;

            // Calculate approved and rejected bills
            if (approvedStatuses.contains(order['status'])) {
              approvedBills++;
              approvedAmount += order['total_amount'] ?? 0.0;
            } else if (rejectedStatuses.contains(order['status'])) {
              rejectedBills++;
              rejectedAmount += order['total_amount'] ?? 0.0;
            }
          }

          // Return the filtered report with calculated metrics
          return {
            'date': report['date'],
            'total_bills_in_date': totalBillsInDate,
            'amount': totalAmount,
            'approved': {
              'bills': approvedBills,
              'amount': approvedAmount,
            },
            'rejected': {
              'bills': rejectedBills,
              'amount': rejectedAmount,
            },
            'filteredOrders': filteredOrders,
          };
        })
        .where((report) => report != null) // Filter out null values
        .cast<Map<String, dynamic>>() // Ensure type safety
        .toList();
  });
  print("filterdatafilterdata:$filterdata");
}

var staff;
  Future<void> getSalesReport() async {
  setState(() {});
  try {
    final token = await getTokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/salesreport'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var salesData = parsed['Sales report'];
print("salesData:$salesData");
      List<Map<String, dynamic>> salesReportDataList = [];
      List<String> approvedStatuses = [
        "Completed",
        "Shipped",
        "Waiting For Confirmation",
        "Invoice Created",
        "Invoice Approved",
        "To Print",
        "Processing"
      ];
      List<String> rejectedStatuses = ["Cancelled", "Refunded", "Return","Invoice Rejectd"];

      for (var reportData in salesData) {
        List<dynamic> staffOrders = reportData['staff_orders'] ?? [];
        int totalApprovedBills = 0;
        double totalApprovedAmount = 0.0;
        int totalRejectedBills = 0;
        double totalRejectedAmount = 0.0;

        for (var order in staffOrders) {
          if (approvedStatuses.contains(order['status'])) {
            totalApprovedBills++;
            totalApprovedAmount += order['total_amount'] ?? 0.0;
          } else if (rejectedStatuses.contains(order['status'])) {
            totalRejectedBills++;
            totalRejectedAmount += order['total_amount'] ?? 0.0;
          }

        }

        salesReportDataList.add({
          'date': reportData['date'],
          "staff_orders":reportData['staff_orders'],
          'total_bills_in_date': reportData['total_bills_in_date'],
          'amount': reportData['amount'],
          'approved': {
            'bills': totalApprovedBills,
            'amount': totalApprovedAmount,
            
          },
          'rejected': {
            'bills': totalRejectedBills,
            'amount': totalRejectedAmount,
          },
        });
      }

      setState(() {
        salesReportList = salesReportDataList;
        filterdata = salesReportDataList;
        print("salesReportList$salesReportList");
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

  Widget _buildRowWithTwoColumns(
      String label1, dynamic value1, String label2, dynamic value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  value1.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label2,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  value2.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Sales Report",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          IconButton(
            icon: Image.asset('lib/assets/profile.png'),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectSingleDate(context),
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
      body: Column(
        children: [
            Padding(
  padding: const EdgeInsets.all(10),
  child: Container(
    height: 49,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blue),
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
            child: DropdownButton<int>(
              value: selectedstaffId,
              isExpanded: true,
              hint: Text( // Add hint text here
                "Select Staff",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              underline: Container(), // This removes the underline
              onChanged: (int? newValue) {
                setState(() {
                  selectedstaffId = newValue!;
                  print(selectedstaffId);
                });
                _filterDataByStaff(selectedstaffId!);
              },
              items: sta.map<DropdownMenuItem<int>>((staff) {
                return DropdownMenuItem<int>(
                  value: staff['id'],
                  child: Text(staff['name'], style: TextStyle(fontSize: 12)),
                );
              }).toList(),
              icon: Container(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
          Expanded(
            child: Stack(
              children: [
                // Main content: Sales report list
              SingleChildScrollView(
  padding: EdgeInsets.only(bottom: 260),
  child: Column(
    children: filterdata.map((reportData) {
      // Handle case where 'filteredOrders' might be null
      List<dynamic> orders = reportData['filteredOrders'] ?? [];

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
                  color: Colors.black87,
                ),
              ),
              Divider(color: Colors.grey),
              SizedBox(height: 8),
              
               _buildRow('Total Bills:', reportData['total_bills_in_date']?? 0),
               _buildRow('Total Amount:', reportData['amount']?? 0),

              _buildRow('Approved Bills:', reportData['approved']['bills'] ?? 0),
              _buildRow('Approved Amount:', reportData['approved']['amount'] ?? 0.0),
              _buildRow('Rejected Bills:', reportData['rejected']['bills'] ?? 0),
              _buildRow('Rejected Amount:', reportData['rejected']['amount'] ?? 0.0),
              SizedBox(height: 12),
              Text(
                'Orders:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // Safely map over orders
              ...orders.map((order) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: _buildRow('Invoice: ${order['invoice']}', 'Amount: ${order['total_amount']}'),
                );
              }).toList(),
            ],
          ),
        ),
      );
    }).toList(),
  ),
),

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
                          _buildRowWithTwoColumns('Total Bills:', totalBills,
                              'Total Amount:', totalAmount),
                          _buildRowWithTwoColumns('Approved Bills:', approvedBills,
                              'Approved Amount:', approvedAmount),
                          _buildRowWithTwoColumns('Rejected Bills:', rejectedBills,
                              'Rejected Amount:', rejectedAmount),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
