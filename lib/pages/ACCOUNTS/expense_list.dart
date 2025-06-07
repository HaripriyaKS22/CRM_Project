import 'dart:convert';
import 'package:beposoft/loginpage.dart';

import 'package:beposoft/pages/ACCOUNTS/update_Expense.dart';
import 'package:beposoft/pages/ADMIN/admin_dashboard.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_admin.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_dashboard.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class expence_list extends StatefulWidget {
  const expence_list({super.key});

  @override
  State<expence_list> createState() => _expence_listState();
}

class _expence_listState extends State<expence_list> {
  List<Map<String, dynamic>> expensedata = [];
  List<Map<String, dynamic>> bank = [];
  DateTime? selectedDate;
  DateTime? startDate; // For date range filter
  DateTime? endDate; // For date range filter
  String? selectedpurpose; // Holds the selected value
  final List<String> items = [
    'water',
    'electricity',
    'salary',
    'emi',
    'rent',
    'travel',
    'Others'
  ];
  List<Map<String, dynamic>> originalExpensedata = [];
  List<Map<String, dynamic>> purposesofpay = [];

  @override
  void initState() {
    super.initState();
    getexpenselist();
    getbank();
    getcompany();
    getstaff();
    getpurpose();
  }

  Future<void> getpurpose() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/apis/add/purpose/'),
        headers: {
          'Authorization': ' Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      ;
      List<Map<String, dynamic>> purposelist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        for (var productData in parsed) {
          purposelist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          purposesofpay = purposelist;
        });
      }
    } catch (error) {}
  }

  Future<String?> gettokenFromPrefs() async {
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

  void _filterOrdersBySingleDate() {
    if (selectedDate != null) {
      setState(() {
        expensedata = originalExpensedata.where((order) {
          final orderDate = _parseDate(order['expense_date']);
          final normalizedOrderDate = _normalizeDate(orderDate);
          final normalizedSelectedDate = _normalizeDate(selectedDate!);

          return normalizedOrderDate == normalizedSelectedDate;
        }).toList();
      });
    }
  }

  void _filterOrdersByDateRange() {
    if (startDate != null && endDate != null) {
      setState(() {
        expensedata = originalExpensedata.where((order) {
          try {
            // Safely parse the 'expense_date' only if it's not null
            final expenseDate = order['expense_date'];
            if (expenseDate == null || expenseDate.isEmpty) {
              return false; // Exclude items with missing or null dates
            }

            // Parse the date using the correct format
            final orderDate = DateFormat('yyyy-MM-dd').parse(expenseDate);

            // Check if the date is within the range
            return orderDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
                orderDate.isBefore(endDate!.add(Duration(days: 1)));
          } catch (e) {
            return false; // Exclude items with invalid dates
          }
        }).toList();
      });
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      // Attempt to parse the date in 'yyyy-MM-dd' format
      return DateFormat('yyyy-MM-dd').parseStrict(dateString);
    } catch (e) {
      try {
        // If the first attempt fails, try parsing it as an ISO8601 string
        return DateTime.parse(dateString)
            .toLocal(); // Ensure it is in local time
      } catch (e) {
        throw FormatException('Invalid date format: $dateString');
      }
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day); // Normalize to midnight
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
    } catch (e) {}
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
    } catch (error) {}
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
    } catch (error) {}
  }

  Future<void> getexpenselist() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/expense/add/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      List<Map<String, dynamic>> expenselist = [];

      print(response.body);
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final productsDatas = parsed['data'];

        for (var productData in productsDatas) {
          expenselist.add({
            'id': productData['id'],
            'purpose_of_payment': productData['purpose_of_payment'],
            'purpose_of_pay': productData['purpose_of_pay'], // For direct use
            'bank': productData['bank']?['id'], // Extract bank ID
            'amount': productData['amount'],
            'company': productData['company']?['id'], // Extract company ID
            'company_name': productData['company']?['name'], // For direct use
            'payed_by': productData['payed_by']?['id'], // Extract payed_by ID
            'payed_by_name': productData['payed_by']?['name'], // For direct use
            'transaction_id': productData['transaction_id'],
            'expense_date': productData['expense_date'],
            'added_by': productData['added_by'],
            'asset_types': productData['asset_types'],
            'name': productData['name'],
            'loanname': productData['loanname'],
          });
        }
        setState(() {
          expensedata = expenselist;
          originalExpensedata =
              List.from(expenselist); // Update the backup here
              print("Expense data fetched: $originalExpensedata");
        });
      } else {}
    } catch (error) {}
  }

  Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
Future<void> _navigateBack() async {
    final dep = await getdepFromPrefs();
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
else if(dep=="warehouse" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WarehouseDashboard()), // Replace AnotherPage with your target page
            );
}
else if(dep=="Warehouse Admin" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WarehouseAdmin()), // Replace AnotherPage with your target page
            );
}else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => dashboard()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
       onWillPop: () async {
        // Prevent the swipe-back gesture (and back button)
        _navigateBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(242, 255, 255, 255),
        appBar: AppBar(
          title: Text(
            "Expense List",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // Custom back arrow
            onPressed: () async {
              final dep = await getdepFromPrefs();
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
else if(dep=="warehouse" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WarehouseDashboard()), // Replace AnotherPage with your target page
            );
}
else if(dep=="Warehouse Admin" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WarehouseAdmin()), // Replace AnotherPage with your target page
            );
} else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          dashboard()), // Replace AnotherPage with your target page
                );
              }
            },
          ),
          actions: [
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: .0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: DropdownButton<String>(
                  value: selectedpurpose,
                  hint: Text('Select an option'),
                  isExpanded: true,
                  underline: SizedBox(),
                  items: purposesofpay.map((purpose) {
                    return DropdownMenuItem<String>(
                      value: purpose['name'],
                      child: Text(purpose['name']),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedpurpose = newValue;
      
                      if (selectedpurpose == null ||
                          selectedpurpose!.isEmpty ||
                          selectedpurpose == "Others") {
                        expensedata = List.from(originalExpensedata);
                      } else {
                        print("Filtering expenses by purpose: $selectedpurpose");
                        expensedata = originalExpensedata.where((expense) {
                          return expense['purpose_of_payment']
                              .toString()
                              .toLowerCase()
                              .contains(selectedpurpose!.toLowerCase());
                        }).toList();
                      }
                      print("Filtered expenses: $expensedata");
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: expensedata.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await getexpenselist();
                      },
                      child: ListView.builder(
                        itemCount: expensedata.length,
                        itemBuilder: (context, index) {
                          final expense = expensedata[index];
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
                                    'Purpose of Payment: ${expense['purpose_of_pay']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                   Row(
                                     children: [
                                       Text(
                                        '${expense['asset_types']?? ''}:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(255, 0, 0, 0),
                                        ),
                                                                         ),
                                                                         SizedBox(width: 2),
                                                                         Text(
                                                                           '${expense['loanname'] ?? '${expense['name'] ?? ''}'}',
                                                                           style: TextStyle(
                                                                             fontSize: 16,
                                                                             fontWeight: FontWeight.bold,
                                                                             color: const Color.fromARGB(255, 16, 176, 1),
                                                                           ),
                                                                         ),
                                     ],
                                   ),
                                   Divider(
                                    color: Colors.grey,
                                    thickness: 1,),
                                  SizedBox(height: 2),
                                 

                                  Text(
                                    'Amount: ₹${expense['amount']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
      
                                  Text(
                                    'Company: ${expense['company_name'] ?? 'Unknown'}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Payed By: ${expense['payed_by_name'] ?? 'Unknown'}',
                                    style: TextStyle(fontSize: 14),
                                  ),
      
                                  Text(
                                    'Bank: ${getNameById(bank, expense['bank'])}',
                                    style: TextStyle(fontSize: 14),
                                  ),
      
                                  // Text(
                                  //   'Payed By: ${getNameById(sta, expense['payed_by'] ?? -1)}',
                                  //   style: TextStyle(fontSize: 14),
                                  // ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Added By: ${expense['added_by'] ?? 'Unknown'}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Transaction Id: ${expense['transaction_id']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                 
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
                                                  update_expence(
                                                      id: expense['id'])));
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  String getNameById(List<Map<String, dynamic>> dataList, dynamic id) {
    if (id == null || dataList.isEmpty) return 'Unknown';

    if (id is Map<String, dynamic>) {
      // If `id` is a map, extract the name directly
      return id['name'] ?? 'Unknown';
    }

    // For standard cases with an ID
    final item = dataList.firstWhere(
      (element) => element['id'] == id,
      orElse: () => {},
    );
    return item.isNotEmpty ? item['name'] : 'Unknown';
  }
}
