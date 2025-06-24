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
import 'package:beposoft/pages/ACCOUNTS/call_log.dart';
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

class admin_dashboard extends StatefulWidget {
  @override
  State<admin_dashboard> createState() => _admin_dashboardState();
}

class _admin_dashboardState extends State<admin_dashboard> {
  List<String> statusOptions = ["pending", "approved", "rejected"];
  List<Map<String, dynamic>> grvlist = [];
  List<Map<String, dynamic>> proforma = [];
  List<Map<String, dynamic>> salesReportList = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  List<Map<String, dynamic>> shippedOrders = [];

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
  }

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
      var productsData = parsed['results'];  // Corrected: Extracting orders from 'results'

      if (productsData != null && productsData is Iterable) {
        List<Map<String, dynamic>> orderList = [];

        for (var productData in productsData) {
          String rawOrderDate = productData['updated_at'];
          String formattedOrderDate = rawOrderDate;

          try {
            DateTime parsedOrderDate = DateFormat('yyyy-MM-dd').parse(rawOrderDate);
            formattedOrderDate = DateFormat('yyyy-MM-dd').format(parsedOrderDate);
          } catch (e) {
            ;
          }

          orderList.add({
            'id': productData['id'],
            'invoice': productData['invoice'],
            'manage_staff': productData['manage_staff'],
            'customer': {
              'id': productData['customer']['id'],
              'name': productData['customer']['name'],
             
              'address': productData['customer']['address'],
            },
            
           
            'status': productData['status'],
            'order_date': formattedOrderDate,
            'total_amount': productData['total_amount'],
          });

          if (productData['status'] == 'Invoice Created') {
            approval++;
          } else if (productData['status'] == 'Invoice Approved') {
            confirm++;
          }

        }
        ;

        DateTime today = DateTime.now();
        String formattedToday = DateFormat('yyyy-MM-dd').format(today);

        var shippedOrdersToday = orderList.where((order) {
          return order['status'] == 'Shipped' && order['updated_at'] == formattedToday;
        }).toList();

        setState(() {
          orders = orderList;
          filteredOrders = orderList;
          shippedOrders = shippedOrdersToday;
          
          approvalcount = parsed['invoice_created_count'];
          confirmcount =parsed['invoice_approved_count'];
          ;
          ;
        });
      } else {
        ;
        
      }
    }
  } catch (error) {
    
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error fetching order data: $error')),
    //   );
    // });
  }
}
int todayShippedCount = 0;
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

      for (var orderData in ordersData) {
        String rawOrderDate = orderData['order_date'] ?? "";
        try {
          DateTime parsedOrderDate = DateFormat('yyyy-MM-dd').parse(rawOrderDate);
          String formattedOrderDate = DateFormat('yyyy-MM-dd').format(parsedOrderDate);

          if (formattedOrderDate == today && orderData['status'] == "Shipped") {
            shippedTodayCount++;
          }
        } catch (e) {
          continue;
        }
      }

      // Now you can use `shippedTodayCount` as needed

      setState(() {
        todayShippedCount = shippedTodayCount; // ← Make sure to define this in your state
      });
    } else {
      throw Exception("Failed to load order data");
    }
  } catch (error) {
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
          ;
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

 void logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  await prefs.remove('token');
  await prefs.remove('username');
    await prefs.remove('department');

  

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
              ]),
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Call Report'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CallLog()));
                },
              ),
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
        body: SafeArea(
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
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector
                      (
                        onTap: () {
                           Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => today_OrderList(status: null,)),
        );
                          

                        },
                        child: _buildInfoCard(totalbills, 'Todays Bills', 0)),
                      GestureDetector(
                        onTap: () {
                           Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderList(status: "Invoice Created",)),
        );
                        },
                        child: _buildInfoCard(approvalcount.toString(), 'Approve Bills', 0)),
                      GestureDetector(
                        onTap: () {

                           Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderList(status: "Waiting For Confirmation",)),
        );
                          

                        },
                        child: _buildInfoCard(confirmcount.toString(), 'Confirm Bills',0)),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      // Display the count of today's shipped orders
                      GestureDetector(
                          onTap: () {
                         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => today_shipped_OrderList(status: "Shipped",)),
        );
                      },
                        child: _buildGridItem(
                          Icons.local_shipping,
                          'Todays Shipped Orders',
                          todayShippedCount
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProformaInvoiceList()),
        );
                      },

                        child: _buildGridItem(Icons.request_quote, 'Proforma Invoice',
                            proforma.length),
                      ),
                    GestureDetector(
                      onTap: () {
                         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GrvList(status:null,)),
        );
                      },
                        child: _buildGridItem(
                            Icons.receipt_long, 'GRV Created', grvlist.length),
                      ),
                      GestureDetector(
                         onTap: () {
                         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GrvList(status:"pending",)),
        );
                      },
                        child: _buildGridItem(
                            Icons.pending_actions, 'GRV Waiting For Approval',grv),
                      ),
                    ],
                  ),
                ),
              ],
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
