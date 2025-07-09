import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/Today_shipped_orders.dart';
import 'package:beposoft/pages/ACCOUNTS/add_EMI.dart';
import 'package:beposoft/pages/ACCOUNTS/add_category.dart';
import 'package:beposoft/pages/ACCOUNTS/add_purpose_of_payment.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_warehouse.dart';
import 'package:beposoft/pages/ACCOUNTS/assetmanagement.dart';
import 'package:beposoft/pages/ACCOUNTS/assetmanegment2.dart';
import 'package:beposoft/pages/ACCOUNTS/bulk_customer_upload.dart';
// import 'package:beposoft/pages/ACCOUNTS/call_log.dart';
import 'package:beposoft/pages/ACCOUNTS/graph.dart';
import 'package:beposoft/pages/ACCOUNTS/grv_list.dart';
import 'package:beposoft/pages/ACCOUNTS/order_list.dart';
import 'package:beposoft/pages/ACCOUNTS/performa_invoice_list.dart';
import 'package:beposoft/pages/ACCOUNTS/todays_orders_list.dart';
import 'package:beposoft/pages/ACCOUNTS/uploadbulkorders.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_product_approval.dart';
import 'package:intl/intl.dart';

import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/profilepage.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ceo_dashboard extends StatefulWidget {
  @override
  State<ceo_dashboard> createState() => _ceo_dashboardState();
}

class _ceo_dashboardState extends State<ceo_dashboard> {
  List<String> statusOptions = ["pending", "approved", "rejected"];
  List<Map<String, dynamic>> grvlist = [];
  List<Map<String, dynamic>> proforma = [];
  List<Map<String, dynamic>> salesReportList = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  List<Map<String, dynamic>> shippedOrders = [];
  List<Map<String, dynamic>> Finance = [];

  String? username = '';
  @override
  void initState() {
    super.initState();
     _getUsername(); // Get the username when the page loads
      getGrvList();
    fetchproformaData();
     getSalesReport();
   fetchOrderData();
   fetchshippedorders();
   getexpenselist();
   getFinancialReport();
   fetchorders();
  }
Map<String, Map<String, dynamic>> familyWiseSummary = {};
Map<String, Map<String, dynamic>> todayFamilyWiseSummary = {};
int approval=0;
int confirm=0;
int approvalcount=0;
int confirmcount=0;
Future<void> fetchOrderData() async {
  try {
    final token = await getTokenFromPrefs();
    var response = await http.get(
      Uri.parse('$api/api/orders/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );


    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['results'];

      if (productsData != null && productsData is Iterable) {
        List<Map<String, dynamic>> orderList = [];
        Map<String, Map<String, dynamic>> familySummary = {};
        Map<String, Map<String, dynamic>> todayFamilySummary = {};

        int approval = 0;
        int confirm = 0;

        DateTime today = DateTime.now();
        String formattedToday = DateFormat('yyyy-MM-dd').format(today);

        for (var productData in productsData) {
          // Parse order_date
          String rawOrderDate = productData['order_date'];
          String formattedOrderDate = rawOrderDate;
          try {
            DateTime parsedOrderDate = DateTime.parse(rawOrderDate);
            formattedOrderDate = DateFormat('yyyy-MM-dd').format(parsedOrderDate);
          } catch (e) {
            // Handle parsing error if needed
          }

          // Build order entry
          var order = {
            'id': productData['id'],
            'invoice': productData['invoice'],
            'manage_staff': productData['manage_staff'],
            'customer': {
              'id': productData['customer']['id'],
              'name': productData['customer']['name'],
              'address': productData['billing_address']?['address'] ?? '',
            },
            'status': productData['status'],
            'order_date': formattedOrderDate,
            'updated_at': productData['updated_at'],
            'total_amount': productData['total_amount'],
            'family': productData['family'],
          };

          orderList.add(order);

          // Count invoice statuses
          if (productData['status'] == 'Invoice Created') {
            approval++;
          } else if (productData['status'] == 'Invoice Approved') {
            confirm++;
          }

          // All-time Family-wise Summary
          String family = productData['family'];
          double amount = double.tryParse(productData['total_amount'].toString()) ?? 0.0;

          familySummary.putIfAbsent(family, () => {
            'total_amount': 0.0,
            'order_count': 0,
          });
          familySummary[family]!['total_amount'] += amount;
          familySummary[family]!['order_count'] += 1;

          // Today's Family-wise Summary
          if (formattedOrderDate == formattedToday) {
            todayFamilySummary.putIfAbsent(family, () => {
              'total_amount': 0.0,
              'order_count': 0,
            });
            todayFamilySummary[family]!['total_amount'] += amount;
            todayFamilySummary[family]!['order_count'] += 1;
          }
        }

        // Shipped Orders Today (using updated_at)
        var shippedOrdersToday = orderList.where((order) {
          return order['status'] == 'Shipped' && order['updated_at'].startsWith(formattedToday);
        }).toList();

        // Set all states
        setState(() {
          orders = orderList;
          filteredOrders = orderList;
          shippedOrders = shippedOrdersToday;
          approvalcount = parsed['invoice_created_count'];
          confirmcount = parsed['invoice_approved_count'];
          familyWiseSummary = familySummary;
          todayFamilyWiseSummary = todayFamilySummary;
        });

    
      }
    }
  } catch (error) {
    // Optionally show a snackbar or alert here
  }
}

 List<Map<String, dynamic>> expensedata = [];
  double totalAmount = 0;

Future<void> getexpenselist() async {
  try {
    final token = await getTokenFromPrefs();

    final response = await http.get(
      Uri.parse('$api/api/expense/add/'), // Ensure the endpoint is correct
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);

      if (parsed['data'] != null && parsed['data'] is List) {
        final productsdata = parsed['data'];
        
        

        List<Map<String, dynamic>> expenselist = [];
        double total = 0.0;

        for (var productData in productsdata) {
          try {
            double amount = productData['amount'] != null
                ? double.tryParse(productData['amount'].toString()) ?? 0.0
                : 0.0;
            total += amount;

            expenselist.add({
              'id': productData['id']?.toString() ?? '',
              'purpose_of_payment': productData['purpose_of_payment']?.toString() ?? '',
               'purpose_of_pay': productData['purpose_of_pay'],
              // 'bank': productData['bank']?.toString() ?? '',
              'amount': amount,
              'company': productData['company']['name']?.toString() ?? '',
              'added_by': productData['added_by']?.toString() ?? '',
              'transaction_id': productData['transaction_id']?.toString() ?? '',
              'payed_by': productData['payed_by']['name']?.toString() ?? '',
              'expense_date': productData['expense_date']?.toString() ?? '',
              'catrgory':productData['categoryname']?.toString() ?? '',
              'name':productData['name']?.toString() ?? '',
              'quantity':productData['quantity']?.toString() ?? '',
            });
          } catch (e) {
            
          }
        }

        setState(() {
          expensedata = expenselist;
          totalAmount = total;
         
        });

        
      } else {
        
      }
    } else {
      
    }
  } catch (error) {
    
  }
}

int todayShippedCount = 0;
int todayOrdersTotalAmount = 0; // Add this to your state

Future<void> fetchshippedorders() async {
  try {
    final token = await getTokenFromPrefs();
    String url = '$api/api/orders/';

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
 
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List ordersData = responseData['results'];

      DateTime currentDate = DateTime.now();
      String today = DateFormat('yyyy-MM-dd').format(currentDate);

      int shippedTodayCount = 0;
      double totalAmount = 0.0;

      for (var orderData in ordersData) {
        String rawOrderDate = orderData['order_date'] ?? "";
        try {
          DateTime parsedOrderDate = DateFormat('yyyy-MM-dd').parse(rawOrderDate);
          String formattedOrderDate = DateFormat('yyyy-MM-dd').format(parsedOrderDate);

          if (formattedOrderDate == today) {
            // Sum total_amount for today's orders
            totalAmount += (orderData['total_amount'] ?? 0).toDouble();
            if (orderData['status'] == "Shipped") {
              shippedTodayCount++;
            }
          }
        } catch (e) {
          continue;
        }
      }

      setState(() {
        todayShippedCount = shippedTodayCount;
        todayOrdersTotalAmount = totalAmount.toInt(); // Store as int, or keep as double if needed
      });
    } else {
      throw Exception("Failed to load order data");
    }
  } catch (error) {
    // Handle error if needed
  }
}
  double totalAdjustedOpeningBalance = 0.0;
      double totalClosingBalance = 0.0;
      double totalTodayPayments = 0.0;
      double totalTodayBanksAmount = 0.0;
Future<void> getFinancialReport() async {
  final token = await getTokenFromPrefs();
  totalAdjustedOpeningBalance = 0.0;
  totalClosingBalance = 0.0;
  totalTodayPayments = 0.0;
  totalTodayBanksAmount = 0.0;

  try {
    final response = await http.get(
      Uri.parse('$api/api/finance-report/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      final DateTime currentDate = DateTime.now();
      final DateTime today = DateTime(currentDate.year, currentDate.month, currentDate.day);

      List<Map<String, dynamic>> financeList = [];

      for (var bankData in parsed['bank_data'] ?? []) {
        String bankName = bankData['name'] ?? 'Unknown Bank';

        // Base opening balance
        double openBalance = (bankData['open_balance'] as num?)?.toDouble() ?? 0.0;

        // Calculate total payments before today
        double totalPaymentsBeforeDate = (bankData['payments'] as List<dynamic>?)
                ?.where((payment) {
                  final receivedAt = DateTime.tryParse(payment['received_at'] ?? '');
                  if (receivedAt == null) return false;

                  // Normalize the date (remove time)
                  final paymentDate = DateTime(receivedAt.year, receivedAt.month, receivedAt.day);

                  return paymentDate.isBefore(today);
                })
                .fold<double>(0.0, (sum, payment) {
                  return sum + (double.tryParse(payment['amount'] ?? '') ?? 0.0);
                }) ??
            0.0;

        double totalBankExpensesBeforeDate = (bankData['banks'] as List<dynamic>?)
                ?.where((bank) {
                  final expenseDate = DateTime.tryParse(bank['expense_date'] ?? '');
                  if (expenseDate == null) return false;

                  final expenseDay = DateTime(expenseDate.year, expenseDate.month, expenseDate.day);

                  return expenseDay.isBefore(today);
                })
                .fold<double>(0.0, (sum, bank) {
                  return sum + (double.tryParse(bank['amount'] ?? '') ?? 0.0);
                }) ??
            0.0;

        // Adjusted opening balance
        double adjustedOpeningBalance = openBalance + totalPaymentsBeforeDate - totalBankExpensesBeforeDate;
        totalAdjustedOpeningBalance += adjustedOpeningBalance;

        // Calculate today's payments
        double todayPayments = (bankData['payments'] as List<dynamic>?)
                ?.where((payment) {
                  final receivedAt = DateTime.tryParse(payment['received_at'] ?? '');
                  if (receivedAt == null) return false;

                  final paymentDate = DateTime(receivedAt.year, receivedAt.month, receivedAt.day);
                  return paymentDate.isAtSameMomentAs(today);
                })
                .fold<double>(0.0, (sum, payment) {
                  return sum + (double.tryParse(payment['amount'] ?? '') ?? 0.0);
                }) ??
            0.0;

        ;
        totalTodayPayments += todayPayments;

        // Handle `banks` for today's expenses
        double todayBanksAmount = (bankData['banks'] as List<dynamic>?)
                ?.where((bank) {
                  final expenseDate = DateTime.tryParse(bank['expense_date'] ?? '');
                  if (expenseDate == null) return false;

                  final expenseDay = DateTime(expenseDate.year, expenseDate.month, expenseDate.day);
                  return expenseDay.isAtSameMomentAs(today);
                })
                .fold<double>(0.0, (sum, bank) {
                  return sum + (double.tryParse(bank['amount'] ?? '') ?? 0.0);
                }) ??
            0.0;

        ;
        totalTodayBanksAmount += todayBanksAmount;

        // Calculate closing balance
        double closingBalance = adjustedOpeningBalance + todayPayments - todayBanksAmount;
      
        totalClosingBalance += closingBalance;

        // Add to finance list
        financeList.add({
          'Bank Name': bankName,
          'Opening Balance': adjustedOpeningBalance.toStringAsFixed(2),
          'Closing Balance': closingBalance.toStringAsFixed(2),
          'Credit': todayPayments.toStringAsFixed(2),
          'Debit': todayBanksAmount.toStringAsFixed(2),
        });
      }

      // Update state to reflect the finance list in UI
      setState(() {
  Finance = List<Map<String, dynamic>>.from(financeList);
  
  // Ensure totals are updated in UI
  totalAdjustedOpeningBalance = totalAdjustedOpeningBalance;
  totalClosingBalance = totalClosingBalance;
  totalTodayPayments = totalTodayPayments;
  totalTodayBanksAmount = totalTodayBanksAmount;
});

    } else {
    
      // Handle error response
      setState(() {
        Finance = [];
      });
    }
  } catch (e) {
    ;
  }
}

 Future<void> getSalesReport() async {
  setState(() {});  // Keep the loading state if needed
  try {
    final token = await getTokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/salesreport/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);

      // Corrected the key
      var salesData = parsed['sales_report'];  

      if (salesData != null && salesData is Iterable) {
        List<Map<String, dynamic>> salesReportDataList = [];
        for (var reportData in salesData) {
          salesReportDataList.add({
            'date': reportData['date'],
            'total_bills_in_date': reportData['total_bills_in_date'],
            'amount': reportData['amount'],
            'approved': {
              'bills': reportData['approved']['bills'],
              'amount': reportData['approved']['amount']
            },
            'rejected': {
              'bills': reportData['rejected']['bills'],
              'amount': reportData['rejected']['amount']
            }
          });
        }

        setState(() {
          salesReportList = salesReportDataList;
          
        });
        getTodaysBills();  // Get today's bills count
      }
    } 
  } catch (error) {
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('An error occurred while fetching data')),
      // );
    });
  } finally {
    setState(() {});  // End loading state
  }
}

var totalbills="0";
  void getTodaysBills() {

    // Get today's date in the same format as in the response (yyyy-MM-dd)
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Find today's report entry
    var todaysReport = salesReportList.firstWhere(
      (report) => report['date'] == currentDate,
      orElse: () => {}, // Return null if no report for today
    );
setState(() {
  if (todaysReport['total_bills_in_date'] != null) {
      totalbills= todaysReport['total_bills_in_date'].toString();
      ;
    } else {

      totalbills= '0'; // Return '0' if no report is found for today
    }
  
});
    
  }

  Future<void> fetchproformaData() async {
    try {
      final token = await getTokenFromPrefs();
      final response = await http.get(
        Uri.parse('$api/api/perfoma/invoices/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final data = parsed['data'] as List;

        List<Map<String, dynamic>> performaInvoiceList = [];

        for (var productData in data) {
          performaInvoiceList.add({
            'id': productData['id'],
            'invoice': productData['invoice'],
            'manage_staff': productData['manage_staff'],
            'customer_name': productData['customer']['name'],
            'status': productData['status'],
            'total_amount': productData['total_amount'],
            'order_date': productData['order_date'],
            'created_at': productData['customer']['created_at'],
          });
        }

        setState(() {
          proforma = performaInvoiceList;
        });
        int proformalistcount = proforma.length;
        
      } else {
        
      }
    } catch (error) {
      
    }
  }

// Get token from SharedPreferences
  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
int grv=0;
int grvcount=0;
// Function to fetch GRV data
  Future<void> getGrvList() async {
    try {
      final token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/grv/data/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
;
;
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        List<Map<String, dynamic>> grvDataList = [];
        for (var productData in productsData) {
          grvDataList.add({
            'id': productData['id'],
            'product': productData['product'],
            'returnreason': productData['returnreason'],
            'invoice': productData['invoice'],
            'customer': productData['customer'],
            'staff': productData['staff'],
            'remark': productData['remark'],
            'status': productData['status'] ?? statusOptions[0],
            'order_date': productData['order_date'],
          });
          if(productData['status']=="pending"){
            grv=grv+1;
          }
        }
        setState(() {
          grvlist = grvDataList;
          grvcount=grv;
        });

        // Get the count of grvlist
        int grvListCount = grvlist.length;
        
      } else {
     
      }
    } catch (error) {
    
      
    }
  }

  // Retrieve the username from SharedPreferences
  Future<void> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ??
          'Guest'; // Default to 'Guest' if no username
    });
  }
    List<Map<String, dynamic>> parcel = [];
     Map<String, Map<String, double>> parcelData = {};
  String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  DateTime? selectedDate; // For single date filter
 Future<void> fetchorders() async {
    ;
    final token = await getTokenFromPrefs();
    try {
      final response = await http.get(
        Uri.parse('$api/api/warehouse/get/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
     
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final orderdata=parsed['results'];
        List<Map<String, dynamic>> orderlist = [];
        parcelData.clear();

        for (var orderData in orderdata) {
          if (orderData['warehouses'] != null && orderData['warehouses'] is List) {
            for (var warehouse in orderData['warehouses']) {
              String? parcelService = warehouse['parcel_service'];
              String? postofficeDate = warehouse['postoffice_date'];
;
              // Convert selectedDate to String format for comparison
              String selectedDateString = selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                  : todayDate;


              // Check if postofficeDate is not null and matches the selected date
if(postofficeDate == selectedDateString){
  
}
              if (parcelService != null &&
                  parcelService.isNotEmpty &&
                  postofficeDate != null &&
                  postofficeDate == selectedDateString) {
                double actualWeight =
                    double.tryParse(warehouse['actual_weight'].toString()) ??
                        0.0;
                double parcelAmount =
                    double.tryParse(warehouse['parcel_amount'].toString()) ??
                        0.0;
                           double weight=
                    double.tryParse(warehouse['weight'].toString()) ??
                        0.0;

                if (!parcelData.containsKey(parcelService)) {
                  parcelData[parcelService] = {
                    'total_actual_weight': 0.0,
                    'total_parcel_amount': 0.0,
                    'weight':0.0
                  };
                }

                parcelData[parcelService]!['total_actual_weight'] =
                    (parcelData[parcelService]!['total_actual_weight'] ?? 0) +
                        actualWeight;
                parcelData[parcelService]!['total_parcel_amount'] =
                    (parcelData[parcelService]!['total_parcel_amount'] ?? 0) +
                        parcelAmount;

                         parcelData[parcelService]!['total_weight'] =
                    (parcelData[parcelService]!['total_weight'] ?? 0) +
                        weight;
              }
            }
          }
        }

        setState(() {
          parcel = orderlist;
        });
      }
    } catch (e) {
      
    }
  }
 void logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.remove('userId');
  // await prefs.remove('token');
  // await prefs.remove('username');
  //   await prefs.remove('department');

  

  // Use a post-frame callback to show the SnackBar after the current frame
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   if (ScaffoldMessenger.of(context).mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Logged out successfully'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // });

  // // Wait for the SnackBar to disappear before navigating
  // await Future.delayed(Duration(seconds: 2));

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          // leading: Icon(Icons.arrow_back, color: Colors.black),
          actions: [
            //  IconButton(
            //     icon: Image.asset('lib/assets/profile.png'),

            //     onPressed: () {
            //       Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfileScreen()));

            //     },
            //   ),
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
              // ListTile(
              //   leading: Icon(Icons.dashboard),
              //   title: Text('Dashboard'),
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => Graph()));
              //   },
              // ),

               _buildDropdownTile(context, 'Customers', [
                'Add Customer',
                'Customers',
              ]),
                _buildDropdownTile(context, 'Recipt', [
                'Add Recipt',
                'Recipt List',
                'Bank Recipt',
                'Advance Recipt',
                'Order Recipt',
                
              ]),
             
              // ListTile(
              //   leading: Icon(Icons.dashboard),
              //   title: Text('Call Report'),
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => CallLog()));
              //   },
              // ),
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
              _buildDropdownTile(context, 'Purchase', [
                'Product List',
                'Product Add',
               
              ]),
              _buildDropdownTile(context, 'Expence', [
                'Add Expence',
                'Expence List',
              ]),
              _buildDropdownTile(
                  context, 'GRV', ['Create New GRV', 'GRVs List']),
           
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
                title: Text('Approve Products'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Approve_products()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Add EMI'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_Emi()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
               ListTile(
                leading: Icon(Icons.person),
                title: Text('Asset Management'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AssetManegment()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
             
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Category'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_categories()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
               ListTile(
                leading: Icon(Icons.person),
                title: Text('Bulk Upload Orders'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UploadBulkProducts()));
                  // Navigate to the Settings page or perform any other action
                },
              ),

               ListTile(
                leading: Icon(Icons.person),
                title: Text('Bulk Upload Customers'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UploadBulkcustomer()));
                  // Navigate to the Settings page or perform any other action
                },
              ),

               ListTile(
                leading: Icon(Icons.person),
                title: Text('Add Purpose of payment'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_purpose_of_payment()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              //   ListTile(
              //   leading: Icon(Icons.person),
              //   title: Text('Bulk Upload'),
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => OrderBulkUpload()));
              //     // Navigate to the Settings page or perform any other action
              //   },
              // ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Departments'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => add_department()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Supervisors'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => add_supervisor()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Division'),
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
                title: Text('Warehouse'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_warehouse()));
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CourierServices()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              //  ListTile(
              //   leading: Icon(Icons.person),
              //   title: Text('Delivery Notes'),
              //   onTap: () {
              //     Navigator.push( 
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => WarehouseOrderView(status: null,)));
              //     // Navigate to the Settings page or perform any other action
              //   },
              // ),
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
                'Damaged Stock',
                'Finance Report',
                'Actual Delivery Report',
              ]),
             
              _buildDropdownTile(context, 'Staff', [
                'Add Staff',
                'Staff',
              ]),
              // _buildDropdownTile(context, 'Credit Note', [
              //   'Add Credit Note',
              //   'Credit Note List',
              // ]),
             
              Divider(),
              
              
              
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () {
                  logout();
                },
              ),
              SizedBox(height: 50), // Add some space at the bottom
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfileScreen()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage(
                              'lib/assets/female.jpeg'), // Replace with your new image
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        '$username',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
          
                  // Discount/Bonus Section
             Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 6),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Icon Row
                Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
          ],
                ),
                SizedBox(height: 12),
          
                // Divider
                Container(
          height: 1,
          color: Colors.white.withOpacity(0.3),
                ),
                SizedBox(height: 16),
          
                // Info Cards Row
                Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => today_OrderList(status: null)),
                );
              },
              child: _buildCardWithIcon(
             
                label: 'Today\'s Bills',
                value: totalbills.toString(),
                color: Colors.white,
              ),
            ),
            _buildCardWithIcon(
             
              label: 'Total Volume',
              value: todayOrdersTotalAmount.toString(),
              color: Colors.white,
            ),
            _buildCardWithIcon(
             
              label: 'Total Expense',
              value: totalAmount.toString(),
              color: Colors.white,
            ),
          ],
                ),
              ],
            ),
          ),
                  SizedBox(height: 10),
          
          // Add this after your info cards in the build method, e.g. after SizedBox(height: 10),
          if (todayFamilyWiseSummary.isNotEmpty) ...[
           
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: todayFamilyWiseSummary.length,
              itemBuilder: (context, index) {
                String family = todayFamilyWiseSummary.keys.elementAt(index);
                var summary = todayFamilyWiseSummary[family]!;
          
                return TweenAnimationBuilder<Offset>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0)),
          curve: Curves.easeOut,
          builder: (context, offset, child) {
            return Transform.translate(
              offset: offset * 20,
              child: child,
            );
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.today, color: Colors.blue),
              ),
              title: Text(
                family,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.list_alt, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("Orders: ${summary['order_count']}"),
                    SizedBox(width: 16),
                    Icon(Icons.currency_rupee, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("₹${summary['total_amount'].toStringAsFixed(2)}"),
                  ],
                ),
              ),
            ),
          ),
                );
              },
            ),
          ],
          Card(
            margin: EdgeInsets.symmetric(vertical: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                columnWidths: const {
          0: FlexColumnWidth(),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
          3: FlexColumnWidth(),
                },
                children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              _buildTableHeader('Opening'),
            
              _buildTableHeader('Today Credit'),
              _buildTableHeader('Today Debit'),
          
                _buildTableHeader('Closing'),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('₹${totalAdjustedOpeningBalance.toStringAsFixed(2)}', Colors.blueAccent),
              _buildTableCell('₹${totalTodayPayments.toStringAsFixed(2)}', Colors.orange),
              _buildTableCell('₹${totalTodayBanksAmount.toStringAsFixed(2)}', Colors.red),
                          _buildTableCell('₹${totalClosingBalance.toStringAsFixed(2)}', Colors.green),
          
            ],
          ),
                ],
              ),
            ),
          ),
 Padding(
   padding: const EdgeInsets.all(8.0),
   child: Text("Parcel Service Report", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
 ),
          parcelData.isEmpty
  ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text(
            "data is Fetching....",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    )
  : SizedBox(
      height: 350, // or MediaQuery.of(context).size.height * 0.5
      child: RefreshIndicator(
        onRefresh: fetchorders,
        child: ListView.builder(
          itemCount: parcelData.length,
          itemBuilder: (context, index) {
            String parcelService = parcelData.keys.elementAt(index);
            double totalWeight =
                parcelData[parcelService]!['total_actual_weight'] ?? 0.0;
                double totWeight =
                parcelData[parcelService]!['total_weight'] ?? 0.0;
            double totalAmount =
                parcelData[parcelService]!['total_parcel_amount'] ?? 0.0;
            double average =
                totalAmount > 0 ? totalWeight / totalAmount : 0.0;

            return Card(
              margin: EdgeInsets.all(1),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 100, 180, 216),
                      const Color.fromARGB(255, 64, 170, 251)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping,
                            color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          parcelService.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.white70),
                    SizedBox(height: 10),
                   Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    _buildInfoColumn("A/W", "$totalWeight kg"),
    _buildInfoColumn("Amount", "₹$totalAmount"),
    _buildInfoColumn("T/W", "$totWeight kg"),
    _buildInfoColumn("Average", average.toStringAsFixed(2)),
  ],
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String value, String label, int notificationCount) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (notificationCount > 0)
              Positioned(
                top: -8,
                right: -8,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    notificationCount.toString(),
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(IconData icon, String title, [int? count]) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          clipBehavior: Clip.none, // Prevents the badge from clipping the card
          children: [
            // Main content of the card - Center the text and icon
            Center(
              // Wrap the Column in a Center widget
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Vertically center
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Horizontally center
                children: [
                  Icon(icon, size: 36, color: Colors.blue),
                  SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Notification Badge
            if (count != null && count > 0)
              Positioned(
                top: -8,
                right: -8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[600],
                  child: Text(
                    count.toString(),
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
Widget _buildCardWithIcon({
  
  required String label,
  required String value,
  Color color = Colors.white,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
     
      SizedBox(height: 6),
      Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color.withOpacity(0.9),
        ),
      ),
    ],
  );
}
 Widget _buildRowWithTwoColumns(
      String label1, dynamic value1, String label2, dynamic value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                Text(
                  value1.toString(),
                  style: TextStyle(
                    fontSize: 13,
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
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                Text(
                  value2.toString(),
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildTableHeader(String label) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget _buildTableCell(String value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: Text(
        value,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

