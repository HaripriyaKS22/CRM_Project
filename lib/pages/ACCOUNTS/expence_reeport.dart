import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/update_expence.dart';
import 'package:intl/intl.dart'; 
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Expence_Report extends StatefulWidget {
  const Expence_Report({super.key});

  @override
  State<Expence_Report> createState() => _Expence_ReportState();
}

class _Expence_ReportState extends State<Expence_Report> {
  List<Map<String, dynamic>> expensedata = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> bank = [];
  DateTime? selectedDate;
  DateTime? startDate;
  DateTime? endDate;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    getexpenselist(); // Fetch the full list of expenses only once
    getbank();
    getcompany();
    getstaff();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Method to filter expenses by the selected date
  void _filterOrdersByDateRange() {
    if (startDate != null && endDate != null) {
      setState(() {
        filteredData = expensedata.where((order) {
          // Parse the 'expense_date' from string to DateTime if needed
          final orderDate = DateFormat('yyyy-MM-dd').parse(order['expense_date']); // Adjust format if needed

          // Check if the order date is within the selected range
          return orderDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
              orderDate.isBefore(endDate!.add(Duration(days: 1)));
        }).toList();
      });
    }
  }

  // Method to filter expenses by single date
  void _filterOrdersBySingleDate() {
    if (selectedDate != null) {
      setState(() {
        filteredData = expensedata.where((order) {
          // Parse the 'expense_date' from string to DateTime if needed
          final orderDate = DateFormat('yyyy-MM-dd').parse(order['expense_date']); // Adjust format if needed

          // Compare only the date part (ignoring time)
          return orderDate.year == selectedDate!.year &&
              orderDate.month == selectedDate!.month &&
              orderDate.day == selectedDate!.day;
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

  Future<void> getbank() async {
    final token = await gettokenFromPrefs();
    try {
      final response = await http.get(Uri.parse('$api/api/banks/'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      List<Map<String, dynamic>> banklist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          banklist.add({
            'id': productData['id'],
            'name': productData['name'],
            'branch': productData['branch']
          });
        }
        setState(() {
          bank = banklist;
        });
      }
    } catch (e) {
      print("error:$e");
    }
  }

  List<Map<String, dynamic>> company = [];

  Future<void> getcompany() async {
    try {
      final token = await gettokenFromPrefs();
      var response = await http.get(
        Uri.parse('$api/api/company/data/'),
        headers: {
          'Authorization': ' Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      List<Map<String, dynamic>> companylist = [];

      if (response.statusCode == 200) {
        final productsData = jsonDecode(response.body);

        for (var productData in productsData) {
          companylist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          company = companylist;
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  List<Map<String, dynamic>> sta = [];
  Future<void> getstaff() async {
    try {
      final token = await gettokenFromPrefs();
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
            'allocated_states': productData['allocated_states']
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

  Future<void> getexpenselist() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/expense/get/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      List<Map<String, dynamic>> expenselist = [];
      double total = 0;
print(response.body);
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        for (var productData in parsed) {
          double amount = productData['amount'] != null
              ? double.tryParse(productData['amount'].toString()) ?? 0.0
              : 0.0;
          total += amount; // Add to total
          expenselist.add({
            'id': productData['id'],
            'purpose_of_payment': productData['purpose_of_payment'],
            'bank': productData['bank'],
            'amount': productData['amount'],
            'company': productData['company'],
            'added_by': productData['added_by'],
            'transaction_id': productData['transaction_id'],
            'payed_by': productData['payed_by'],
            'expense_date': productData['expense_date'],
          });
        }
        setState(() {
          expensedata = expenselist; // Store the full list of expenses
          filteredData = expenselist; // Initially, show all expenses
          totalAmount = total;
        });
      }
    } catch (error) {
      print("Error: $error");
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
      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          "Expense Report",
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[/* Add drawer items here */],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredData.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final expense = filteredData[index];
                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Purpose of Payment: ${expense['purpose_of_payment']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Amount: ₹${expense['amount']}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Company: ${getNameById(company, expense['company'])}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Bank: ${getNameById(bank, expense['bank'])}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Payed By: ${getNameById(sta, expense['payed_by'] ?? -1)}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Added By: ${expense['added_by'] ?? 'Unknown'}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Transaction Id: ${expense['transaction_id']}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Expense Date: ${expense['expense_date']}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Expense_Update(id: expense['id'])),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                child: const Text(
                                  "View",
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getNameById(List<Map<String, dynamic>> dataList, dynamic id) {
    if (id == null || dataList.isEmpty) return 'Unknown';
    final item = dataList.firstWhere(
      (element) => element['id'] == id,
      orElse: () => {},
    );
    return item != null ? item['name'] : 'Unknown';
  }
}
