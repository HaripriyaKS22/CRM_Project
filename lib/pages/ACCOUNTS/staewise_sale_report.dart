import 'dart:convert';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
class StateWiseReport extends StatefulWidget {
  const StateWiseReport({super.key});

  @override
  State<StateWiseReport> createState() => _StateWiseReportState();
}

class _StateWiseReportState extends State<StateWiseReport> {
  List<Map<String, dynamic>> expensedata = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> filteredOrders = [];
  DateTime? startDate;
  DateTime? endDate;
double totalAmount = 0.0;
        int totalOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    getstatewisereport();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

void _filterOrdersByDateRange() {
  print("Start Date: $startDate");
  print("End Date: $endDate");
  print("exxxxxxxxxx$expensedata");

  if (startDate != null && endDate != null) {
    setState(() {
      // Initialize the filtered data list
      filteredData = expensedata.where((stateData) {
        // Loop through each order type
        List completedOrders = stateData['completed_orders_details'] ?? [];
        List cancelledOrders = stateData['cancelled_orders_details'] ?? [];
        List returnedOrders = stateData['returned_orders_details'] ?? [];
        List rejectedOrders = stateData['rejected_orders_details'] ?? [];

        // Initialize filtered totals and counts for each order type
        double filteredCompletedTotalAmount = 0.0;
        int filteredCompletedOrdersCount = 0;

        double filteredCancelledTotalAmount = 0.0;
        int filteredCancelledOrdersCount = 0;

        double filteredReturnedTotalAmount = 0.0;
        int filteredReturnedOrdersCount = 0;

        double filteredRejectedTotalAmount = 0.0;
        int filteredRejectedOrdersCount = 0;

        // Initialize aggregate totals for all types
        
        bool isOrderInRange = false;

        // Function to process orders based on their type
        void processOrders(List orders, String orderType) {
          print("orderrrrrrrrrrrrrrrrrr$orders");
          print("Statusssssssssssssss$orderType");
          for (var order in orders) {
            String? orderDateStr = order['order_date'];
            print("$orderType order date: $orderDateStr");

            // Check if order_date is valid
            if (orderDateStr == null || orderDateStr.isEmpty) {
              print("Skipping $orderType order with null or empty date");
              continue;
            }

            DateTime? orderDate;
            try {
              // Parse the order date string
              orderDate = DateFormat('yyyy-MM-dd').parse(orderDateStr); 
            } catch (e) {
              print("Error parsing date for $orderType: $e");
              continue;
            }

            // Debug print to check orderDate and the range
            print("Parsed order date: $orderDate");

            // Check if the order date is within the selected range, including exact start and end dates
            if ((orderDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
                 orderDate.isBefore(endDate!.add(Duration(days: 1)))) ||
                 orderDate.isAtSameMomentAs(startDate!) ||
                 orderDate.isAtSameMomentAs(endDate!)) {
              print("$orderType order is in range: $orderDate");

              isOrderInRange = true;

              // Update counts and amounts based on the order type
              if (orderType == 'Completed') {
                filteredCompletedOrdersCount++;
                filteredCompletedTotalAmount += order['total_amount'];
              } else if (orderType == 'Cancelled') {
                filteredCancelledOrdersCount++;
                filteredCancelledTotalAmount += order['total_amount'];
              } else if (orderType == 'Return') {
                filteredReturnedOrdersCount++;
                filteredReturnedTotalAmount += order['total_amount'];
              } else if (orderType == 'Invoice Rejectd') {
                filteredRejectedOrdersCount++;
                filteredRejectedTotalAmount += order['total_amount'];
              }
            } else {
              print("$orderType order is not in range: $orderDate");
            }
          }
        }

        // Process each order type
        processOrders(completedOrders, 'Completed');
        processOrders(cancelledOrders, 'Cancelled');
        processOrders(returnedOrders, 'Return');
        processOrders(rejectedOrders, 'Invoice Rejectd');

        // Update the stateData with the new filtered counts and amounts
        if (isOrderInRange) {
          stateData['completed_orders'] = filteredCompletedOrdersCount;
          stateData['completed_amount'] = filteredCompletedTotalAmount;
          stateData['cancelled_orders'] = filteredCancelledOrdersCount;
          stateData['cancelled_amount'] = filteredCancelledTotalAmount;
          stateData['returned_orders'] = filteredReturnedOrdersCount;
          stateData['returned_amount'] = filteredReturnedTotalAmount;
          stateData['rejected_orders'] = filteredRejectedOrdersCount;
          stateData['rejected_amount'] = filteredRejectedTotalAmount;

          // Aggregate totals
          totalOrdersCount = filteredCompletedOrdersCount + filteredCancelledOrdersCount +
              filteredReturnedOrdersCount + filteredRejectedOrdersCount;
          totalAmount = filteredCompletedTotalAmount + filteredCancelledTotalAmount +
              filteredReturnedTotalAmount + filteredRejectedTotalAmount;

          // Print the aggregated totals
          print("Total Orders Count: $totalOrdersCount");
          print("Total Amount: $totalAmount");
        }

        // Only include the stateData if any of its orders match the date range
        return isOrderInRange;
      }).toList();
    });
  }
}

Future<void> getstatewisereport() async {
  try {
    final token = await gettokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/statewise/report/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);

      // Debugging the API response
      print("API Response: $parsed");

      // Assuming the data is under a specific key, adjust as per your API response
      if (parsed is Map && parsed.containsKey('data')) {
        final List<dynamic> statewiseData = parsed['data'];
        List<Map<String, dynamic>> statewiselist = [];

        for (var stateData in statewiseData) {
          // Get the status_based_orders, defaulting to an empty map if not found
          Map<String, dynamic> statusBasedOrders = stateData["status_based_orders"] ?? {};

          // Extract completed orders and their order_date
          List<Map<String, dynamic>> completedOrders = [];
          double completedOrdersTotalAmount = 0.0;
          int completedOrdersCount = 0;

          // Safely access "Completed" orders
          var completed = statusBasedOrders["Completed"] ?? {};
          for (var order in completed["orders"] ?? []) {
            completedOrders.add({
              "invoice": order["invoice"],
              "order_date": order["order_date"], // Include the order_date
              "total_amount": order["total_amount"],
            });

            completedOrdersTotalAmount += order["total_amount"]; // Sum the total_amount
            completedOrdersCount++; // Count the number of completed orders
          }

          // Initialize cancelled orders variables
          List<Map<String, dynamic>> cancelledOrders = [];
          double cancelledOrdersTotalAmount = 0.0;
          int cancelledOrdersCount = 0;

          // Safely access "Cancelled" orders
          var cancelled = statusBasedOrders["Cancelled"] ?? {};
          for (var order in cancelled["orders"] ?? []) {
            cancelledOrders.add({
              "invoice": order["invoice"],
              "order_date": order["order_date"],
              "total_amount": order["total_amount"],
            });
            cancelledOrdersTotalAmount += order["total_amount"];
            cancelledOrdersCount++;
          }

          // Initialize returned orders variables
          List<Map<String, dynamic>> returnedOrders = [];
          double returnedOrdersTotalAmount = 0.0;
          int returnedOrdersCount = 0;

          // Safely access "Return" orders
          var returned = statusBasedOrders["Return"] ?? {};
          for (var order in returned["orders"] ?? []) {
            returnedOrders.add({
              "invoice": order["invoice"],
              "order_date": order["order_date"],
              "total_amount": order["total_amount"],
            });
            returnedOrdersTotalAmount += order["total_amount"];
            returnedOrdersCount++;
          }

          // Initialize rejected orders variables
          List<Map<String, dynamic>> rejectedOrders = [];
          double rejectedOrdersTotalAmount = 0.0;
          int rejectedOrdersCount = 0;

          // Safely access "Invoice Rejected" orders
          var rejected = statusBasedOrders["Invoice Rejectd"] ?? {};
          for (var order in rejected["orders"] ?? []) {
            rejectedOrders.add({
              "invoice": order["invoice"],
              "order_date": order["order_date"],
              "total_amount": order["total_amount"],
            });
            rejectedOrdersTotalAmount += order["total_amount"];
            rejectedOrdersCount++;
          }
totalOrdersCount=rejectedOrdersCount+returnedOrdersCount+cancelledOrdersCount+completedOrdersCount;
totalAmount=rejectedOrdersTotalAmount+returnedOrdersTotalAmount+cancelledOrdersTotalAmount+completedOrdersTotalAmount;
          // Add the processed data to the list
          statewiselist.add({
            "state": stateData["name"],
            "completed_orders": completedOrdersCount,
            "completed_amount": completedOrdersTotalAmount,
            "completed_orders_details": completedOrders,
            "cancelled_orders_details":cancelledOrders,
            "returned_orders_details":rejectedOrders,
            "rejected_orders_details":rejectedOrders,
            "cancelled_orders": cancelledOrdersCount,
            "cancelled_amount": cancelledOrdersTotalAmount,
            "returned_orders": returnedOrdersCount,
            "returned_amount": returnedOrdersTotalAmount,
            "rejected_orders": rejectedOrdersCount,
            "rejected_amount": rejectedOrdersTotalAmount,
          });
        }

        setState(() {
          expensedata = statewiselist;
          filteredData = statewiselist; // Initialize filteredData
          print(expensedata);
        });
      } else {
        print("Unexpected data structure: ${parsed.runtimeType}");
      }
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  } catch (error) {
    print("Error: $error");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "State Wise Report",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () => _selectDateRange(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: filteredData.length, // Use filteredData here
            itemBuilder: (context, index) {
              final stateData = filteredData[index];
              return Card(
                color: Colors.white,
                elevation: 4, // Adds shadow
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded edges
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(16.0), // Padding inside the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // State name with a bold header
                      Text(
                        stateData["state"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Highlight color
                        ),
                      ),
                      const Divider(), // Separator line
                      const SizedBox(height: 4), // Space between items

                      // Data rows with icons
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: 
                            Colors.green,
                            
                          ),
                                                    SizedBox(width: 5,),

                        Text(
                            "Completed Orders: ${stateData["completed_orders"]} "),
                            Spacer(),
                            Text("₹ ${stateData["completed_amount"]}")
                        ],
                      ),
                      SizedBox(height: 5,),
                       Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: 
                            Colors.red,
                            
                          ),
                                                    SizedBox(width: 5,),

                        Text(
                            "Cancelled Orders: ${stateData["cancelled_orders"]} "),
                            Spacer(),
                            Text("₹ ${stateData["cancelled_amount"]}")
                        ],
                      ),
                                            SizedBox(height: 5,),

                      Row(
                        children: [
                          Icon(
                            Icons.undo,
                            color: 
                            Colors.yellow,
                            
                          ),
                                                    SizedBox(width: 5,),

                          
                        Text(
                            "Returned Orders: ${stateData["returned_orders"]} "),
                            Spacer(),
                            Text("₹ ${stateData["returned_amount"]}")
                        ],
                      ),
                                            SizedBox(height: 5,),

Row(
                        children: [
                          Icon(
                            Icons.block,
                            color: 
                            Colors.grey,
                            
                          ),
                          SizedBox(width: 5,),
                          
                        Text(
                            "Rejected Orders: ${stateData["rejected_orders"]} "),
                            Spacer(),
                            Text("₹ ${stateData["rejected_amount"]}")
                        ],
                      ),
                                              SizedBox(height: 2,),

                      Divider(),

                        SizedBox(height: 5,),

Row(
                        children: [
                          Icon(
                            Icons.summarize,
                            color: 
                            Colors.grey,
                            
                          ),
                          SizedBox(width: 5,),
                          
                        Text(
                            "Total Orders: $totalOrdersCount "),
                            Spacer(),
                            Text("₹ $totalAmount")
                        ],
                      ),

                      


                     
                    
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }

  /// Helper widget for each row with an icon and text
  Widget buildDataRow(
      String title, String value, IconData icon, Color iconColor) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 4.0), // Spacing between rows
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 8), // Space between icon and text
          Expanded(
            child: Text(
              "$title: $value",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
