import 'dart:convert';
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/update_expence.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
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

  @override
  void initState() {
    super.initState();
    getexpenselist();
    getbank();
    getcompany();
    getstaff();
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
        expensedata = expensedata.where((order) {
          final orderDate = _parseDate(order['expense_date']);
          final normalizedOrderDate = _normalizeDate(orderDate);
          final normalizedSelectedDate = _normalizeDate(selectedDate!);

          print("Comparing orderDate: $normalizedOrderDate with selectedDate: $normalizedSelectedDate");

          return normalizedOrderDate == normalizedSelectedDate;
        }).toList();
      });

      print(expensedata);
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      // Attempt to parse the date in 'yyyy-MM-dd' format
      return DateFormat('yyyy-MM-dd').parseStrict(dateString);
    } catch (e) {
      try {
        // If the first attempt fails, try parsing it as an ISO8601 string
        return DateTime.parse(dateString).toLocal(); // Ensure it is in local time
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
        print("selectedDate$selectedDate");
      });
      _filterOrdersBySingleDate();
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
  print("Fetching expense list...");
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
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      final productsDatas = parsed['data'];

      for (var productData in productsDatas) {
        expenselist.add({
          'id': productData['id'],
          'purpose_of_payment': productData['purpose_of_payment'],
          'bank': productData['bank']?['id'], // Extract bank ID
          'amount': productData['amount'],
          'company': productData['company']?['id'], // Extract company ID
          'company_name': productData['company']?['name'], // For direct use
          'payed_by': productData['payed_by']?['id'], // Extract payed_by ID
          'payed_by_name': productData['payed_by']?['name'], // For direct use
          'transaction_id': productData['transaction_id'],
          'expense_date': productData['expense_date'],
          'added_by': productData['added_by'],
        });
      }
      setState(() {
        expensedata = expenselist;
      });
    } else {
      print("Failed to fetch expense list. Status code: ${response.statusCode}");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          "Expense List",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectSingleDate(context),
          ),
          IconButton(
            icon: Image.asset('lib/assets/profile.png'),
            onPressed: () {},
          ),
        ],
      ),
    
      body: expensedata.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder( 
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
                        SizedBox(height: 8),
                        Text(
                          'Expense Date: ${expense['expense_date']}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Expense_Update(id:expense['id'])));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, 
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            "View",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
