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
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_admin.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:flutter/material.dart';
import 'package:beposoft/pages/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class NewGrv extends StatefulWidget {
  const NewGrv({super.key});

  @override
  State<NewGrv> createState() => _NewGrvState();
}

class _NewGrvState extends State<NewGrv> {
  final TextEditingController returnreason = TextEditingController();
  final TextEditingController returnQuantityController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> orderItems = [];
  String orderId = '';
  String? selectedValue;
  String manageStaffName = '';
  String selectedInvoiceAddress = '';
  String createdAtDate = '';
  bool hasItems = true; // Flag to track if items exist

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<String?> getTokenFromPrefs() async {
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

  Future<void> fetchOrders() async {
    final token = await getTokenFromPrefs();
    try {
      final response = await http.get(
        Uri.parse("$api/api/orders/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        List<Map<String, dynamic>> orderList = [];
        for (var order in parsed) {
          orderList.add({
            'id': order['id'],
            'manage_staff': order['manage_staff'] ?? 'Unknown',
            'name': order['customer']['name'] ?? 'Unknown',
            'invoice': order['invoice'] ?? 'Unknown',
            'address': order['billing_address']['address'] ?? 'Unknown Address',
            'created_at': order['customer']['created_at'] ?? 'Unknown Date',
          });
        }
        setState(() {
          orders = orderList;
        });
      } else {
        print("Failed to fetch orders: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching orders: $error");
    }
  }

  Future<void> fetchOrderItems(String orderId) async {
    final token = await getTokenFromPrefs();
    try {
      final response = await http.get(
        Uri.parse("$api/api/order/$orderId/items/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
print("order item ${response.body}");
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed['items'] != null && (parsed['items'] as List).isNotEmpty) {
          List<Map<String, dynamic>> productItems = (parsed['items'] as List).map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'rate': item['rate'],
              'quantity': item['quantity'],
              'discount': item['discount'],
              'images': item['image'],
              'return_quantity': 0 // Initialize return_quantity as 0
            };
          }).toList();

          setState(() {
            orderItems = productItems;
            hasItems = true; // If items are found
          });
          print("Order items fetched successfully.  $orderItems");
        } else {
          setState(() {
            orderItems = [];
            hasItems = false; // No items found
          });
          print("No items found for the order.");
        }
      } else {
        print("Failed to fetch order items: ${response.statusCode}");
        setState(() {
          orderItems = [];
          hasItems = false;
        });
      }
    } catch (error) {
      print("Error fetching order items: $error");
      setState(() {
        hasItems = false;
      });
    }
  }

  Future<void> showReturnQuantityDialog(Map<String, dynamic> item) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Return Quantity for ${item['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: returnQuantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Return Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                int returnQuantity = int.tryParse(returnQuantityController.text) ?? 0;
                if (returnQuantity > 0) {
                  setState(() {
                    item['return_quantity'] = returnQuantity;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter a valid quantity'),
                  ));
                }
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void PostGRV() async {
    print("hbchsbc");
    final token = await getTokenFromPrefs();
    try {
      for (var item in orderItems) {
        var response = await http.post(
          Uri.parse("$api/api/grv/data/"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'order': orderId,
            'product': item['name'],
            'price': item['rate'],
            'quantity': item['return_quantity'], // Use return quantity
            'returnreason': returnreason.text,
          }),
        );

        print("GRV Response: ${response.statusCode}");

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color.fromARGB(255, 49, 212, 4),
            content: Text('GRV posted successfully'),
          ));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewGrv()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text('An error occurred while posting GRV.'),
          ));
        }
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('An error occurred. Please try again.'),
      ));
    }
  }

  @override
  void dispose() {
    returnQuantityController.dispose();
    returnreason.dispose();
    super.dispose();
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


  Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New GRV'),

         leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Custom back arrow
          onPressed: () async{
                    final dep= await getdepFromPrefs();
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
else if(dep=="warehouse admin" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WarehouseAdmin()), // Replace AnotherPage with your target page
            );
}
else {
    Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => dashboard()), // Replace AnotherPage with your target page
            );

}
           
          },
        ),

      ),
     
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height: 15),
              Text(
                "NEW GRV",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Padding(
  padding: const EdgeInsets.only(right: 10),
  child: LayoutBuilder(
    builder: (context, constraints) {
      return Container(
        child: DropdownButtonHideUnderline(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                'Select Invoice',
                style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
              ),
              items: orders.map((order) {
                return DropdownMenuItem<String>(
                  value: '${order['invoice']} / ${order['name']}',
                  child: Text(
                    '${order['invoice']} / ${order['name']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              value: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                  final selectedOrder = orders.firstWhere(
                    (order) => '${order['invoice']} / ${order['name']}' == value,
                    orElse: () => {},
                  );
                  if (selectedOrder != null) {
                    orderId = selectedOrder['id'].toString();
                    manageStaffName = selectedOrder['manage_staff'];
                    selectedInvoiceAddress = selectedOrder['address'];
                    createdAtDate = selectedOrder['created_at'];
                    fetchOrderItems(orderId);
                  }
                });
              },
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 40,
              ),
              dropdownStyleData: const DropdownStyleData(
                maxHeight: 200,
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
              ),
              dropdownSearchData: DropdownSearchData(
                searchController: textEditingController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Container(
                  height: 50,
                  padding: const EdgeInsets.only(top: 8, bottom: 4, right: 8, left: 8),
                  child: TextFormField(
                    expands: true,
                    maxLines: null,
                    controller: textEditingController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      hintText: 'Search for an invoice...',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
                },
              ),
              onMenuStateChange: (isOpen) {
                if (!isOpen) {
                  textEditingController.clear();
                }
              },
            ),
          ),
        ),
      );
    },
  ),
),

                      SizedBox(height: 20),
                      TextFormField(
                        controller: TextEditingController(text: manageStaffName),
                        decoration: InputDecoration(
                          labelText: 'Managed by',
                          suffixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: TextEditingController(text: selectedInvoiceAddress),
                        decoration: InputDecoration(
                          labelText: 'Address',
                          suffixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                        maxLines: null, // Makes it flexible for multiple lines
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: TextEditingController(text: createdAtDate),
                        decoration: InputDecoration(
                          labelText: 'Invoice Date',
                          suffixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: returnreason,
                        decoration: InputDecoration(
                          labelText: 'Reason',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        ),
                      ),
                      if (hasItems) // Show order items if they exist
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: orderItems.length,
                          itemBuilder: (context, index) {
                            final item = orderItems[index];
                            return Card(
                              color: Colors.white,
                              elevation: 5,
                              margin: EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item['images'] != null && item['images'].isNotEmpty)
                                      Image.network(
                                                    "${item['images']}",
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Icon(Icons
                                                          .image_not_supported); // Fallback image or icon
                                                    },
                                                  ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text('Rate: ₹${item['rate']}'),
                                          Text('Quantity: ${item['quantity']}'),
                                          Text('Discount: ${item['discount']}%'),
                                          Text('Return Quantity: ${item['return_quantity']}'),
                                          TextButton(
                                            onPressed: () => showReturnQuantityDialog(item),
                                            child: Text('Enter Return Quantity'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Text('No items available for the selected order.'),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedValue != null && orderItems.isNotEmpty) {
                    PostGRV();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.orange,
                      content: Text('Please select an order and ensure there are items to submit.'),
                    ));
                  }
                },
                child: Text("Submit"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
