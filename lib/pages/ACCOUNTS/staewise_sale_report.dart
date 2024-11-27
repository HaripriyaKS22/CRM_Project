import 'dart:convert';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StateWiseReport extends StatefulWidget {
  const StateWiseReport({super.key});

  @override
  State<StateWiseReport> createState() => _StateWiseReportState();
}

class _StateWiseReportState extends State<StateWiseReport> {
  List<Map<String, dynamic>> expensedata = [];
  List<Map<String, dynamic>> filteredData = [];

  @override
  void initState() {
    super.initState();
    getstatewisereport();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

        // Assuming the data is under a specific key, adjust as per your API response
        if (parsed is Map && parsed.containsKey('data')) {
          final List<dynamic> statewiseData = parsed['data'];
          List<Map<String, dynamic>> statewiselist = [];

          for (var stateData in statewiseData) {
            Map<String, dynamic> statusBasedOrders =
                stateData["status_based_orders"];
            statewiselist.add({
              "state": stateData["name"],
              "completed_orders": statusBasedOrders["Completed"]
                  ["total_orders"],
              "completed_amount": statusBasedOrders["Completed"]
                  ["total_amount"],
              "cancelled_orders": statusBasedOrders["Cancelled"]
                  ["total_orders"],
              "cancelled_amount": statusBasedOrders["Cancelled"]
                  ["total_amount"],
              "returned_orders": statusBasedOrders["Return"]["total_orders"],
              "returned_amount": statusBasedOrders["Return"]["total_amount"],
              "rejected_orders": statusBasedOrders["Invoice Rejected"]
                  ["total_orders"],
              "rejected_amount": statusBasedOrders["Invoice Rejected"]
                  ["total_amount"],
            });
          }

          setState(() {
            expensedata = statewiselist;
            filteredData = statewiselist;
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final stateData = filteredData[index];
            return Card(
              elevation: 4, // Adds shadow
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded edges
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Padding inside the card
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
                    const SizedBox(height: 8), // Space between items

                    // Data rows with icons
                    buildDataRow(
                      "Completed Orders",
                      "${stateData["completed_orders"]} | Amount: ${stateData["completed_amount"]}",
                      Icons.check_circle,
                      Colors.green,
                    ),
                    buildDataRow(
                      "Cancelled Orders",
                      "${stateData["cancelled_orders"]} | Amount: ${stateData["cancelled_amount"]}",
                      Icons.cancel,
                      Colors.red,
                    ),
                    buildDataRow(
                      "Returned Orders",
                      "${stateData["returned_orders"]} | Amount: ${stateData["returned_amount"]}",
                      Icons.undo,
                      Colors.orange,
                    ),
                    buildDataRow(
                      "Rejected Orders",
                      "${stateData["rejected_orders"]} | Amount: ${stateData["rejected_amount"]}",
                      Icons.block,
                      Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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
