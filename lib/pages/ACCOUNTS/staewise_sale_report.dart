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
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
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
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getstatewisereport();
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
          
          
          for (var order in orders) {
            String? orderDateStr = order['order_date'];
            

            // Check if order_date is valid
            if (orderDateStr == null || orderDateStr.isEmpty) {
              
              continue;
            }

            DateTime? orderDate;
            try {
              // Parse the order date string
              orderDate = DateFormat('yyyy-MM-dd').parse(orderDateStr); 
            } catch (e) {
              
              continue;
            }

            // Debug print to check orderDate and the range
            

            // Check if the order date is within the selected range, including exact start and end dates
            if ((orderDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
                 orderDate.isBefore(endDate!.add(Duration(days: 1)))) ||
                 orderDate.isAtSameMomentAs(startDate!) ||
                 orderDate.isAtSameMomentAs(endDate!)) {
              

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
          stateData['totalcount'] = totalOrdersCount;
          stateData['totalamount'] = totalAmount;


          // Print the aggregated totals
          
          
        }

        // Only include the stateData if any of its orders match the date range
        return isOrderInRange;
      }).toList();
    });
  }
}
var count;
var amount;
Future<void> getstatewisereport() async {
  try {
    final token = await gettokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/state/wise/report/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
print(response.body);
print(response.statusCode);
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);

      // Debugging the API response
      

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

          var completed = statusBasedOrders["Completed"] ?? {};
          for (var order in completed["orders"] ?? []) {
            completedOrders.add({
              "invoice": order["invoice"],
              "order_date": order["order_date"], // Include the order_date
              "total_amount": order["total_amount"],
            });

            completedOrdersTotalAmount += order["total_amount"];
            completedOrdersCount++;
          }

          // Initialize cancelled orders variables
          List<Map<String, dynamic>> cancelledOrders = [];
          double cancelledOrdersTotalAmount = 0.0;
          int cancelledOrdersCount = 0;

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

          // Calculate the total orders and amount for this state
          int count = rejectedOrdersCount + returnedOrdersCount + cancelledOrdersCount + completedOrdersCount;
          double amount = rejectedOrdersTotalAmount + returnedOrdersTotalAmount + cancelledOrdersTotalAmount + completedOrdersTotalAmount;

          

          // Add the processed data to the list
          statewiselist.add({
            "state": stateData["name"],
            "completed_orders": completedOrdersCount,
            "completed_amount": completedOrdersTotalAmount,
            "completed_orders_details": completedOrders,
            "cancelled_orders_details": cancelledOrders,
            "returned_orders_details": returnedOrders,
            "rejected_orders_details": rejectedOrders,
            "cancelled_orders": cancelledOrdersCount,
            "cancelled_amount": cancelledOrdersTotalAmount,
            "returned_orders": returnedOrdersCount,
            "returned_amount": returnedOrdersTotalAmount,
            "rejected_orders": rejectedOrdersCount,
            "rejected_amount": rejectedOrdersTotalAmount,
            "totalcount":count,
            "totalamount":amount
          });

          
        }

        setState(() {
          // Set the final totals after processing all states

          expensedata = statewiselist;
          filteredData = statewiselist; // Initialize filteredData
                    

        });
      } else {
        
      }
    } else {
      
    }
  } catch (error) {
    print(error);
    
  }
}
 void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredData = List.from(expensedata); // Show all if search is empty
      } else {
        filteredData = expensedata
            .where((product) =>
                product['state'].toLowerCase().contains(query.toLowerCase()))
            .toList(); // Filter based on query
      }
    });
  }
  Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
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
                title: Text('Company'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_company()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
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
                title: Text('Family'),
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
               ListTile(
                leading: Icon(Icons.person),
                title: Text('Delivery Notes'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WarehouseOrderView(status: null,)));
                  // Navigate to the Settings page or perform any other action
                },
              ),
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
                'Damaged Stock'
              ]),
              _buildDropdownTile(context, 'Customers', [
                'Add Customer',
                'Customers',
              ]),
              _buildDropdownTile(context, 'Staff', [
                'Add Staff',
                'Staff',
              ]),
              _buildDropdownTile(context, 'Credit Note', [
                'Add Credit Note',
                'Credit Note List',
              ]),
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
                'Product Add',
                'Stock',
              ]),
              _buildDropdownTile(context, 'Expence', [
                'Add Expence',
                'Expence List',
              ]),
              _buildDropdownTile(
                  context, 'GRV', ['Create New GRV', 'GRVs List']),
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
                  Navigator.pop(context); // Close the drawer
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () {
                  logout();
                },
              ),
            ],
          ),
        ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search...",
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
            onChanged: _filterProducts,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: getstatewisereport, // Trigger data reload when the user swipes down
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
                      padding: const EdgeInsets.all(12.0), // Padding inside the card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // State name with a bold header
                          Text(
                            stateData["state"],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Highlight color
                            ),
                          ),
                          const Divider(), // Separator line
                          const SizedBox(height: 0), // Space between items
                          
                          // Data rows with icons
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 5),
                              Text("Completed Orders: ${stateData["completed_orders"]} "),
                              Spacer(),
                              Text("₹ ${stateData["completed_amount"]}")
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.cancel,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 5),
                              Text("Cancelled Orders: ${stateData["cancelled_orders"]} "),
                              Spacer(),
                              Text("₹ ${stateData["cancelled_amount"]}")
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.undo,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 5),
                              Text("Returned Orders: ${stateData["returned_orders"]} "),
                              Spacer(),
                              Text("₹ ${stateData["returned_amount"]}")
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.block,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 5),
                              Text("Rejected Orders: ${stateData["rejected_orders"]} "),
                              Spacer(),
                              Text("₹ ${stateData["rejected_amount"]}")
                            ],
                          ),
                          SizedBox(height: 2),
                          Divider(),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.summarize,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 5),
                              Text("Total Orders: ${stateData["totalcount"]} "),
                              Spacer(),
                              Text("₹ ${stateData["totalamount"]}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
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
        ),
      ],
    ),
  );
}

}
