// import 'dart:convert';
// import 'package:beposoft/pages/ACCOUNTS/codsale_date_report.dart';
// import 'package:beposoft/pages/api.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart'; 


// class COD_Sales_Report extends StatefulWidget {
//   const COD_Sales_Report({super.key});

//   @override
//   State<COD_Sales_Report> createState() => _COD_Sales_ReportState();
// }

// class _COD_Sales_ReportState extends State<COD_Sales_Report> {
//   List<Map<String, dynamic>> cod = [];
//   double totalAmount = 0.0;
//   num totalOrders = 0;  // Changed to num to handle both int and double values
//   double totalPaid = 0.0;
//   double totalPending = 0.0;
//    DateTime? selectedDate;
//   DateTime? startDate;
//   DateTime? endDate;
//   List<Map<String, dynamic>> filteredData = [];


//   @override
//   void initState() {
//     super.initState();
//     getcodsales();
//   }

//   Future<String?> gettokenFromPrefs() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   Future<void> getcodsales() async {
//     try {
//       final token = await gettokenFromPrefs();
//       var response = await http.get(
//         Uri.parse('$api/api/COD/sales/'),
//         headers: {
//           'Authorization': ' Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       List<Map<String, dynamic>> codsaleslist = [];

//       if (response.statusCode == 200) {
//         final productsData = jsonDecode(response.body);

//         // Clear previous totals
//         totalAmount = 0.0;
//         totalOrders = 0;
//         totalPaid = 0.0;
//         totalPending = 0.0;

//         for (var productData in productsData) {
//           double amount = productData['total_amount'] != null
//               ? double.tryParse(productData['total_amount'].toString()) ?? 0.0
//               : 0.0;
//           double paid = productData['total_paid'] != null
//               ? double.tryParse(productData['total_paid'].toString()) ?? 0.0
//               : 0.0;
//           double pending = productData['total_pending'] != null
//               ? double.tryParse(productData['total_pending'].toString()) ?? 0.0
//               : 0.0;

//           setState(() {
//             totalAmount += amount;
//             totalPaid += paid;
//             totalPending += pending;
//             totalOrders += productData['total_orders'] != null
//                 ? productData['total_orders']
//                 : 0;
//           });

//           codsaleslist.add({
//             'date': productData['date'],
//             'total_amount': amount,
//             'total_orders': productData['total_orders'],
//             'total_paid': paid,
//             'total_pending': pending,
//           });
//         }

//         setState(() {
//           cod = codsaleslist;
//           filteredData = codsaleslist;

//         });
//       } else {
//         print('Failed to load COD sales');
//       }
//     } catch (error) {
//       print("Error: $error");
//     }
//   }

// void _filterOrdersByDateRange() {
//   if (startDate != null && endDate != null) {
//     setState(() {
//       filteredData = cod.where((order) {
//         // Check if 'expense_date' is not null before parsing
//         if (order['expense_date'] != null && order['expense_date'] is String) {
//           try {
//             // Parse the 'expense_date' from string to DateTime
//             final orderDate = DateFormat('yyyy-MM-dd').parse(order['expense_date']);

//             // Check if the order date is within the selected range
//             return orderDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
//                 orderDate.isBefore(endDate!.add(Duration(days: 1)));
//           } catch (e) {
//             // If parsing fails, return false (exclude this entry)
//             return false;
//           }
//         }
//         return false; // If 'expense_date' is null or not a String, exclude this entry
//       }).toList();
//     });
//   }
// }

//  void _filterOrdersBySingleDate() {
//   if (selectedDate != null) {
//     setState(() {
//       filteredData = cod.where((order) {
//         // Check if 'expense_date' is not null before parsing
//         if (order['expense_date'] != null) {
//           // Parse the 'expense_date' from string to DateTime
//           final orderDate = DateFormat('yyyy-MM-dd').parse(order['expense_date']); // Adjust format if needed

//           // Compare only the date part (ignoring time)
//           return orderDate.year == selectedDate!.year &&
//               orderDate.month == selectedDate!.month &&
//               orderDate.day == selectedDate!.day;
//         }
//         return false; // If 'expense_date' is null, do not include this order
//       }).toList();
//     });
//   }
// }

//   // Method to select a single date
//   Future<void> _selectSingleDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//       _filterOrdersBySingleDate(); // Re-filter after selecting a new date
//     }
//   }

//   // Method to select a date range (start date and end date)
//   Future<void> _selectDateRange(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       initialDateRange: DateTimeRange(
//         start: DateTime.now(),
//         end: DateTime.now(),
//       ),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         startDate = picked.start;
//         endDate = picked.end;
//       });
//       _filterOrdersByDateRange(); // Re-filter after selecting a date range
//     }
//   }


//   // Method for showing total amount with two decimal places
//   Widget _buildRowWithTwoColumns(String label1, double amount) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label1,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   '₹${amount.toStringAsFixed(2)}', // Format totalAmount to two decimal places
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "COD Sales Report",
//           style: TextStyle(fontSize: 14, color: Colors.grey),
//         ),
//          actions: [
//           // Icon button to open start date picker
//           IconButton(
//             icon: Icon(Icons.calendar_today),  // Calendar icon
//             onPressed: () => _selectSingleDate(context), // Call the method to select start date
//           ),
//           // Icon button to open date range picker
//           IconButton(
//             icon: Icon(Icons.date_range),  // Date range icon
//             onPressed: () => _selectDateRange(context), // Call the method to select date range
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: filteredData.isEmpty
//                 ? Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: filteredData.length,
//                     itemBuilder: (context, index) {
//                       final salesData = filteredData[index];
//                       return Card(
//                         color: Colors.white,
//                         elevation: 4,
//                         margin: EdgeInsets.symmetric(vertical: 10),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Date: ${salesData['date']}',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Divider(color: Colors.blue),
//                               SizedBox(height: 8),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Total Amount: ₹${salesData['total_amount']}',
//                                     style: TextStyle(fontSize: 14),
//                                   ),
//                                   Text(
//                                     'Total Orders: ${salesData['total_orders']}',
//                                     style: TextStyle(fontSize: 14),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 8),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Total Paid: ₹${salesData['total_paid']}',
//                                     style: TextStyle(fontSize: 14),
//                                   ),
//                                   Text(
//                                     'Total Pending: ₹${salesData['total_pending']}',
//                                     style: TextStyle(fontSize: 14),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 20),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   Navigator.push(context, MaterialPageRoute(builder: (context)=>codsalereport_datewise_view(date:salesData['date'])));
//                                   // Add your view action here
//                                   print("View button pressed for ${salesData['date']}");
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor: Colors.blue,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 12),
//                                 ),
//                                 child: Text(
//                                   'View',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Material(
//               elevation: 12,
//               color: const Color.fromARGB(255, 12, 80, 163),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                   color: const Color.fromARGB(255, 12, 80, 163),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Total Report Summary',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Divider(
//                       color: Colors.white.withOpacity(0.5),
//                       thickness: 1,
//                     ),
//                     SizedBox(height: 8),
//                     _buildRowWithTwoColumns('Total Amount:', totalAmount),
//                     _buildRowWithTwoColumns('Total Orders:', totalOrders.toDouble()),
//                     _buildRowWithTwoColumns('Total Paid:', totalPaid),
//                     _buildRowWithTwoColumns('Total Pending:', totalPending),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/creditsale_date_report.dart';
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

class COD_Sales_Report extends StatefulWidget {
  const COD_Sales_Report({super.key});

  @override
  State<COD_Sales_Report> createState() => _COD_Sales_ReportState();
}

class _COD_Sales_ReportState extends State<COD_Sales_Report> {
  List<Map<String, dynamic>> salesReportList = [];
    List<Map<String, dynamic>> allSalesReportList = []; // Original data
  double totalorder = 0.0;
  double totalAmount = 0.0;
  double totalpaid = 0.0;
  double pending = 0.0;
  double rejectedBills = 0.0;
  double rejectedAmount = 0.0;
 TextEditingController searchController = TextEditingController();
  DateTime? selectedDate; // For single date filter
  DateTime? startDate; // For date range filter
  DateTime? endDate; // For date range filter
 List<Map<String, dynamic>> cod = [];
  num totalOrders = 0;  // Changed to num to handle both int and double values
  double totalPaid = 0.0;
  double totalPending = 0.0;

  List<Map<String, dynamic>> filteredData = [];
  @override
  void initState() {
    super.initState();
    getcodsales();
  }
// Method to filter orders by single date
// void _filterOrdersBySingleDate() {
//   if (selectedDate != null) {
//     setState(() {
//       salesReportList = allSalesReportList.where((order) { // Use allSalesReportList
//         final orderDate = _parseDate(order['date']);
//         return orderDate.year == selectedDate!.year &&
//             orderDate.month == selectedDate!.month &&
//             orderDate.day == selectedDate!.day;
//       }).toList();
//       _updateTotals();
//     });
//   }
// }

// // Method to filter orders between two dates, inclusive of start and end dates
// void _filterOrdersByDateRange() {
//   if (startDate != null && endDate != null) {
//     setState(() {
//       salesReportList = allSalesReportList.where((order) { // Use allSalesReportList
//         final orderDate = _parseDate(order['date']);
//         return (orderDate.isAtSameMomentAs(startDate!) ||
//             orderDate.isAtSameMomentAs(endDate!) ||
//             (orderDate.isAfter(startDate!) && orderDate.isBefore(endDate!)));
//       }).toList();
//       _updateTotals();
//     });
//   }
// }


  // Method to filter expenses by the selected date
  void _filterOrdersByDateRange() {
    if (startDate != null && endDate != null) {
      setState(() {
        filteredData = cod.where((order) {
          // Parse the 'expense_date' from string to DateTime if needed
          final orderDate = DateFormat('yyyy-MM-dd').parse(order['date']); // Adjust format if needed

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
        filteredData = cod.where((order) {
          // Parse the 'expense_date' from string to DateTime if needed
          final orderDate = DateFormat('yyyy-MM-dd').parse(order['date']); // Adjust format if needed
print(orderDate);
          // Compare only the date part (ignoring time)
          return orderDate.year == selectedDate!.year &&
              orderDate.month == selectedDate!.month &&
              orderDate.day == selectedDate!.day;
        }).toList();
      });
      print("filteredData$filteredData");
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
        print("selectedDtae$selectedDate");
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

// Function to reset filters
void _resetFilters() {
  setState(() {
    salesReportList = List.from(allSalesReportList); // Reset to original data
    _updateTotals();
  });
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
      tempTotalstock += reportData['total_orders'];
            print("temptotalstock:$tempTotalstock");

      tempTotalsold += reportData['total_paid'];
      tempremaining += reportData['total_pending'];
      tempApprovedAmount += reportData['total_amount'];
      // tempRejectedBills += reportData['rejected']['bills'];
      // tempRejectedAmount += reportData['rejected']['amount'];
    }

    setState(() {
      totalorder = tempTotalstock;
      print("totalstock:$totalorder");
      totalAmount = tempApprovedAmount;
      totalpaid = tempTotalsold;
      pending = tempremaining;
      // rejectedBills = tempRejectedBills;
      // rejectedAmount = tempRejectedAmount;
    });
  }

  // Future<void> _selectSingleDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //       print("selectedDate:$selectedDate");
  //     });
  //     _filterOrdersBySingleDate();
  //   }
  // }

  // Future<void> _selectDateRange(BuildContext context) async {
  //   final DateTimeRange? picked = await showDateRangePicker(
  //     context: context,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //     initialDateRange: startDate != null && endDate != null
  //         ? DateTimeRange(start: startDate!, end: endDate!)
  //         : null,
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       startDate = picked.start;
  //       endDate = picked.end;
  //     });
  //     _filterOrdersByDateRange();
  //   }
  // }

  drower d = drower();

  // Get token from SharedPreferences
  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

Future<void> getcodsales() async {
  try {
    final token = await getTokenFromPrefs();
    var response = await http.get(
      Uri.parse('$api/api/COD/sales/'),
      headers: {
        'Authorization': ' Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("coddddddddddddddd${response.body}");

    if (response.statusCode == 200) {
      final productsData = jsonDecode(response.body);

      // Ensure `data` is a list
      final data = productsData is List ? productsData : productsData['data'];

      // Clear previous totals
      totalAmount = 0.0;
      totalOrders = 0;
      totalPaid = 0.0;
      totalPending = 0.0;

      List<Map<String, dynamic>> codsaleslist = [];

      for (var productData in data) {
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
              ? int.tryParse(productData['total_orders'].toString()) ?? 0
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
        print("coooooooooooooooo$cod");
      });
    } else {
      print('Failed to load COD sales');
    }
  } catch (error) {
    print("Error: $error");
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
          icon: Icon(Icons.calendar_today), // Calendar icon
          onPressed: () => _selectSingleDate(context), // Call the method to select start date
        ),
        // Icon button to open date range picker
        IconButton(
          icon: Icon(Icons.date_range), // Date range icon
          onPressed: () => _selectDateRange(context), // Call the method to select date range
        ),
      ],
    ),
    body: Stack(
      children: [
        Column(
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
          ],
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



