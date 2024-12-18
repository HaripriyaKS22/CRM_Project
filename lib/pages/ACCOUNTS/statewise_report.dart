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
class StateWiseReport2 extends StatefulWidget {
  const StateWiseReport2({super.key});

  @override
  State<StateWiseReport2> createState() => _StateWiseReport2State();
}

class _StateWiseReport2State extends State<StateWiseReport2> {
  List<Map<String, dynamic>> expensedata = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> filteredOrders = [];
  DateTime? startDate;
  DateTime? endDate;
double totalAmount = 0.0;
        int totalOrdersCount = 0;
  TextEditingController searchController = TextEditingController();
List<Map<String, dynamic>> sta = [];
    int? selectedstaffId;

  @override
  void initState() {
    super.initState();
    getstatewisereport();
    getstaff();
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

  // Method to filter expenses by single date
void _filterOrdersByDateRange() {
  print("Start Date: $startDate");
  print("End Date: $endDate");
  print("Expense Data: $expensedata");

  if (startDate != null && endDate != null) {
    setState(() {
      // Normalize startDate and endDate to remove time components
      startDate = DateTime(startDate!.year, startDate!.month, startDate!.day);
      endDate = DateTime(endDate!.year, endDate!.month, endDate!.day);

      // Filter orders by date range
      filteredData = expensedata.where((order) {
        return order['orders'].any((orderItem) {
          final orderDateString = orderItem['order_date'];
          try {
            final orderDate = DateFormat('yyyy-MM-dd').parse(orderDateString).toLocal();
            print('dateeeeeeeeeeeeeeeeeeeeeeee$orderDate');
            // Include orders between startDate and endDate inclusively
            return (orderDate.isAtSameMomentAs(startDate!) || orderDate.isAfter(startDate!)) &&
                   (orderDate.isAtSameMomentAs(endDate!) || orderDate.isBefore(endDate!));
          } catch (e) {
            print('Error parsing date: $orderDateString');
            return false;
          }
        });
      }).toList();

      print("Filtered Dataaaaaaaaaaaaaaaaaaaaaaaaaaa: $filteredData");

      // Aggregate totals based on the filtered data
      List<Map<String, dynamic>> aggregatedData = [];

      for (var stateData in filteredData) {
        int totalOrdersCount = 0;
        double totalAmount = 0.0;

        int completedOrdersCount = 0;
        double completedAmount = 0.0;

        int cancelledOrdersCount = 0;
        double cancelledAmount = 0.0;

        int refundedOrdersCount = 0;
        double refundedAmount = 0.0;

        int returnedOrdersCount = 0;
        double returnedAmount = 0.0;

        // Iterate through the orders
        List<dynamic> orders = stateData['orders'] ?? [];
        for (var order in orders) {
          List<dynamic> waitingOrders = order['waiting_orders'] ?? [];

          for (var waitingOrder in waitingOrders) {
            // Increment total orders count and amount
            totalOrdersCount += 1;
            totalAmount += (waitingOrder['total_amount'] as num?)?.toDouble() ?? 0.0;

            String status = waitingOrder['status']?.toString() ?? '';

            // Handle different statuses
            switch (status) {
              case 'Completed':
                completedOrdersCount += 1;
                completedAmount += (waitingOrder['total_amount'] as num?)?.toDouble() ?? 0.0;
                break;
              case 'Cancelled':
                cancelledOrdersCount += 1;
                cancelledAmount += (waitingOrder['total_amount'] as num?)?.toDouble() ?? 0.0;
                break;
              case 'Refunded':
                refundedOrdersCount += 1;
                refundedAmount += (waitingOrder['total_amount'] as num?)?.toDouble() ?? 0.0;
                break;
              case 'Return':
                returnedOrdersCount += 1;
                returnedAmount += (waitingOrder['total_amount'] as num?)?.toDouble() ?? 0.0;
                break;
              default:
                print('Unhandled status: $status');
                break;
            }
          }
        }

        // Add the aggregated data for this state
        aggregatedData.add({
          'id': stateData['id'] ?? 'Unknown ID',
          'name': stateData['name'] ?? 'Unknown Name',
          'total_orders_count': totalOrdersCount,
          'total_amount': totalAmount,
          'completed_orders_count': completedOrdersCount,
          'completed_amount': completedAmount,
          'cancelled_orders_count': cancelledOrdersCount,
          'cancelled_amount': cancelledAmount,
          'refunded_orders_count': refundedOrdersCount,
          'refunded_amount': refundedAmount,
          'returned_orders_count': returnedOrdersCount,
          'returned_amount': returnedAmount,
        });
      }

      // Update the state with the aggregated data
      filteredData = aggregatedData;
      print("Processed Data: $filteredData");
    });
  }
}


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

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);

      // Debugging the API response
      print("API Response: $parsed");

      if (parsed is Map && parsed.containsKey('data')) {
        final List<dynamic> statewiseData = parsed['data'];
        List<Map<String, dynamic>> statewiselist = [];
print("statewiseData:::::::::::::$statewiseData");
        for (var stateData in statewiseData) {
          int totalOrdersCount = 0;
          double totalAmount = 0.0;

          int completedOrdersCount = 0;
          double completedAmount = 0.0;

          int cancelledOrdersCount = 0;
          double cancelledAmount = 0.0;

          int refundedOrdersCount = 0;
          double refundedAmount = 0.0;

          int returnedOrdersCount = 0;
          double returnedAmount = 0.0;

          // Loop through each state's orders list
          List<dynamic> orders = stateData['orders'] ?? [];
          print('orderssssssssssssssssssssss$orders');
          for (var order in orders) {
            List<dynamic> waitingOrders = order['waiting_orders'] ?? [];

            for (var waitingOrder in waitingOrders) {
              // Aggregate totals
              totalOrdersCount += 1;
              // totalAmount += (waitingOrder['total_amount'] as num).toDouble();
 totalAmount = (waitingOrder['total_amount'] as num?)?.toDouble() ?? 0.0;
              String status = waitingOrder['status'];

              switch (status) {
                case 'Completed':
                  completedOrdersCount += 1;
                  completedAmount += (waitingOrder['total_amount'] as num).toDouble();
                  break;

                case 'Cancelled':
                  cancelledOrdersCount += 1;
                  cancelledAmount += (waitingOrder['total_amount'] as num).toDouble();
                  break;

                case 'Refunded':
                  refundedOrdersCount += 1;
                  refundedAmount += (waitingOrder['total_amount'] as num).toDouble();
                  break;

                case 'Return':
                  returnedOrdersCount += 1;
                  returnedAmount += (waitingOrder['total_amount'] as num).toDouble();
                  break;
              }
            }
          }
print("stateData: $stateData");  // Check for any null or unexpected values
          // Add calculated data to the list
         statewiselist.add({
            'orders':orders,

  'id': stateData['id'] ?? 'Unknown ID',  // Default value if null
  'name': stateData['name'] ?? 'Unknown Name',  // Default value if null
  'total_orders_count': totalOrdersCount ?? 0,  // Ensure it defaults to 0
  'total_amount': totalAmount ?? 0.0,  // Ensure it defaults to 0.0
  'completed_orders_count': completedOrdersCount ?? 0,
  'completed_amount': completedAmount ?? 0.0,
  'cancelled_orders_count': cancelledOrdersCount ?? 0,
  'cancelled_amount': cancelledAmount ?? 0.0,
  'refunded_orders_count': refundedOrdersCount ?? 0,
  'refunded_amount': refundedAmount ?? 0.0,
  'returned_orders_count': returnedOrdersCount ?? 0,
  'returned_amount': returnedAmount ?? 0.0,
});


        }

        setState(() {
          expensedata = statewiselist;
          filteredData = statewiselist;
          print("Processed Data=============================: $filteredData");
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

 void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredData = List.from(expensedata); // Show all if search is empty
      } else {
        filteredData = expensedata
            .where((product) =>
                product['name'].toLowerCase().contains(query.toLowerCase()))
            .toList(); // Filter based on query
      }
    });
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
          Padding(
                        padding: const EdgeInsets.only(right: 10,left: 10),
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
                                    hintText: '',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 1),
                                  ),
                                  child: DropdownButton<int>(
                                    value: selectedstaffId,
                                      isExpanded: true,
                                    underline: Container(), // This removes the underline
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedstaffId = newValue!;
                                        print(selectedstaffId);
                                      });
                                    },
                                    items: sta.map<DropdownMenuItem<int>>((staff) {
                                      return DropdownMenuItem<int>(
                                        value:staff['id'],
                                        child: Text(staff['name'],style: TextStyle(fontSize: 12),),
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
                            stateData["name"],
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
                              Text("Completed Orders: ${stateData["completed_orders_count"]} "),
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
                              Text("Cancelled Orders: ${stateData["cancelled_orders_count"]} "),
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
                              Text("Returned Orders: ${stateData["refunded_orders_count"]} "),
                              Spacer(),
                              Text("₹ ${stateData["refunded_amount"]}")
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
                              Text("Rejected Orders: ${stateData["returned_orders_count"]} "),
                              Spacer(),
                              Text("₹ ${stateData["returned_amount"]}")
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
                              Text("Total Orders: ${stateData["total_orders_count"]} "),
                              Spacer(),
                              Text("₹ ${stateData["total_amount"]}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
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
