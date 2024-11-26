import 'dart:convert';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 


class COD_Sales_Report extends StatefulWidget {
  const COD_Sales_Report({super.key});

  @override
  State<COD_Sales_Report> createState() => _COD_Sales_ReportState();
}

class _COD_Sales_ReportState extends State<COD_Sales_Report> {
  List<Map<String, dynamic>> cod = [];
  double totalAmount = 0.0;
  num totalOrders = 0;  // Changed to num to handle both int and double values
  double totalPaid = 0.0;
  double totalPending = 0.0;
   DateTime? selectedDate;
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> filteredData = [];


  @override
  void initState() {
    super.initState();
    getcodsales();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getcodsales() async {
    try {
      final token = await gettokenFromPrefs();
      var response = await http.get(
        Uri.parse('$api/api/COD/sales/'),
        headers: {
          'Authorization': ' Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      List<Map<String, dynamic>> codsaleslist = [];

      if (response.statusCode == 200) {
        final productsData = jsonDecode(response.body);

        // Clear previous totals
        totalAmount = 0.0;
        totalOrders = 0;
        totalPaid = 0.0;
        totalPending = 0.0;

        for (var productData in productsData) {
          double amount = productData['total_amount'] != null
              ? double.tryParse(productData['total_amount'].toString()) ?? 0.0
              : 0.0;
          double paid = productData['total_paid'] != null
              ? double.tryParse(productData['total_paid'].toString()) ?? 0.0
              : 0.0;
          double pending = productData['total_pending'] != null
              ? double.tryParse(productData['total_pending'].toString()) ?? 0.0
              : 0.0;

          setState(() {
            totalAmount += amount;
            totalPaid += paid;
            totalPending += pending;
            totalOrders += productData['total_orders'] != null
                ? productData['total_orders']
                : 0;
          });

          codsaleslist.add({
            'date': productData['date'],
            'total_amount': amount,
            'total_orders': productData['total_orders'],
            'total_paid': paid,
            'total_pending': pending,
          });
        }

        setState(() {
          cod = codsaleslist;
          filteredData = codsaleslist;

        });
      } else {
        print('Failed to load COD sales');
      }
    } catch (error) {
      print("Error: $error");
    }
  }

void _filterOrdersByDateRange() {
  if (startDate != null && endDate != null) {
    setState(() {
      filteredData = cod.where((order) {
        // Check if 'expense_date' is not null before parsing
        if (order['expense_date'] != null && order['expense_date'] is String) {
          try {
            // Parse the 'expense_date' from string to DateTime
            final orderDate = DateFormat('yyyy-MM-dd').parse(order['expense_date']);

            // Check if the order date is within the selected range
            return orderDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
                orderDate.isBefore(endDate!.add(Duration(days: 1)));
          } catch (e) {
            // If parsing fails, return false (exclude this entry)
            return false;
          }
        }
        return false; // If 'expense_date' is null or not a String, exclude this entry
      }).toList();
    });
  }
}

 void _filterOrdersBySingleDate() {
  if (selectedDate != null) {
    setState(() {
      filteredData = cod.where((order) {
        // Check if 'expense_date' is not null before parsing
        if (order['expense_date'] != null) {
          // Parse the 'expense_date' from string to DateTime
          final orderDate = DateFormat('yyyy-MM-dd').parse(order['expense_date']); // Adjust format if needed

          // Compare only the date part (ignoring time)
          return orderDate.year == selectedDate!.year &&
              orderDate.month == selectedDate!.month &&
              orderDate.day == selectedDate!.day;
        }
        return false; // If 'expense_date' is null, do not include this order
      }).toList();
    });
  }
}

  // Method to select a single date
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
      _filterOrdersBySingleDate(); // Re-filter after selecting a new date
    }
  }

  // Method to select a date range (start date and end date)
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _filterOrdersByDateRange(); // Re-filter after selecting a date range
    }
  }


  // Method for showing total amount with two decimal places
  Widget _buildRowWithTwoColumns(String label1, double amount) {
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
                  '₹${amount.toStringAsFixed(2)}', // Format totalAmount to two decimal places
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
      appBar: AppBar(
        title: Text(
          "COD Sales Report",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
         actions: [
          // Icon button to open start date picker
          IconButton(
            icon: Icon(Icons.calendar_today),  // Calendar icon
            onPressed: () => _selectSingleDate(context), // Call the method to select start date
          ),
          // Icon button to open date range picker
          IconButton(
            icon: Icon(Icons.date_range),  // Date range icon
            onPressed: () => _selectDateRange(context), // Call the method to select date range
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredData.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final salesData = filteredData[index];
                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${salesData['date']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 8),
                              Divider(color: Colors.blue),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount: ₹${salesData['total_amount']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Total Orders: ${salesData['total_orders']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Paid: ₹${salesData['total_paid']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Total Pending: ₹${salesData['total_pending']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>codsalereport_datewise_view(date:salesData['date'])));
                                  // Add your view action here
                                  print("View button pressed for ${salesData['date']}");
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
                    ),
                    SizedBox(height: 8),
                    _buildRowWithTwoColumns('Total Amount:', totalAmount),
                    _buildRowWithTwoColumns('Total Orders:', totalOrders.toDouble()),
                    _buildRowWithTwoColumns('Total Paid:', totalPaid),
                    _buildRowWithTwoColumns('Total Pending:', totalPending),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
