import 'dart:convert';

import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_admin.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_dashboard.dart';
import 'package:intl/intl.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/update_bank.dart';
import 'package:beposoft/pages/ADMIN/admin_dashboard.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:beposoft/pages/api.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class add_receipt extends StatefulWidget {
  const add_receipt({super.key});

  @override
  State<add_receipt> createState() => _add_receiptState();
}

class _add_receiptState extends State<add_receipt> {
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

  TextEditingController uname = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController transactionid = TextEditingController();
  TextEditingController Remark = TextEditingController();
  List<Map<String, dynamic>> bank = [];
  List<Map<String, dynamic>> orders = [];
  DateTime selectedDate = DateTime.now();
  String? selectedInvoiceId; // Variable to store the selected invoice ID
  String? selectedBankId; // Variable to store the selected bank ID
// Add this variable to your _add_receiptState class:
String? selectedReceiptType;
final List<String> receiptTypes = ['Order Receipt', 'Advance receipt', 'other Receipt'];
  Future<String?> gettoken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('token');
  }

  @override
  void initState() {
    super.initState();
    fetchOrderData();
    getbank();
 getcustomer();
    // getNameFromJWT(); // Fetch the name from JWT
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  List<Map<String, dynamic>> customer = [];
String? selectedCustomerId;
  Future<void> getcustomer() async {
  try {
    final dep = await getdepFromPrefs();
    final token = await getTokenFromPrefs();

    final jwt = JWT.decode(token!);
    var name = jwt.payload['name'];
    

    var response = await http.get(
      Uri.parse('$api/api/customers/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    ;

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['data']; // Directly accessing 'data' since no pagination

      List<Map<String, dynamic>> newCustomers = [];

      for (var productData in productsData) {
        newCustomers.add({
          'id': productData['id'],
          'name': productData['name'],
          'created_at': productData['created_at'],
        });
      }

      // Update UI
      setState(() {
        customer = newCustomers;
        
      });
    } else {
      throw Exception("Failed to load customer data");
    }
  } catch (error) {
    ;
  }
}

  Future<void> fetchOrderData() async {
    try {
      final token = await getTokenFromPrefs();
      final dep = await getdepFromPrefs();
      final jwt = JWT.decode(token!);
      var name = jwt.payload['name'];
      ;

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

        List<Map<String, dynamic>> newOrders = [];

        for (var orderData in ordersData) {
          newOrders.add({
            'id': orderData['id'],
            'invoice': orderData['invoice'],
            'customer': orderData['customer']['name'],
          });
        }

        setState(() {
          orders = newOrders;
          uname.text=name;
          // filteredOrders = newOrders;
          ;
        });
      } else {
        throw Exception("Failed to load order data");
      }
    } catch (error) {
      ;
    }
  }

  Future<void> getbank() async {
    final token = await gettoken();
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
      
    }
  }

  Future<void> AddReceipt(
    BuildContext scaffoldContext,
  ) async {
    final token = await gettoken();
    try {
      final token = await getTokenFromPrefs();
      final jwt = JWT.decode(token!);
      var name = jwt.payload['name'];
    

      // Format the selectedDate as a string
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      final response = await http.post(
          Uri.parse('$api/api/payment/$selectedInvoiceId/reciept/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'amount': amount.text,
            'bank': selectedBankId,
            'transactionID': transactionid.text,
            'received_at': formattedDate, // Use the formatted date string
            'created_by': name,
            'remark': Remark.text
          }));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Receipt added Successfully.'),
          ),
        );

        Navigator.push(context, MaterialPageRoute(builder: (context)=>add_receipt()));
      } 
      else 
      {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Adding receipt failed.'),
          ),
        );
      }
    } catch (e) {
      
    }
  }

  Future<void> AddReceipt2(
    BuildContext scaffoldContext,
  ) async {
    final token = await gettoken();
    try {
      final token = await getTokenFromPrefs();
      final jwt = JWT.decode(token!);
      var name = jwt.payload['name'];
    

      // Format the selectedDate as a string
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      final response = await http.post(
          Uri.parse('$api/api/advancereceipt/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'customer': selectedCustomerId,
            'amount': amount.text,
            'bank': selectedBankId,
            'transactionID': transactionid.text,
            'received_at': formattedDate, // Use the formatted date string
            'remark': Remark.text
          }));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Receipt added Successfully.'),
          ),
        );

        Navigator.push(context, MaterialPageRoute(builder: (context)=>add_receipt()));
      } 
      else 
      {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Adding receipt failed.'),
          ),
        );
      }
    } catch (e) {
      
    }
  }
Future<void> AddReceipt3(
    BuildContext scaffoldContext,
  ) async {
    final token = await gettoken();
    try {
      final token = await getTokenFromPrefs();
      final jwt = JWT.decode(token!);
      var name = jwt.payload['name'];
    

      // Format the selectedDate as a string
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      final response = await http.post(
          Uri.parse('$api/api/bank-receipts/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'amount': amount.text,
            'bank': selectedBankId,
            'transactionID': transactionid.text,
            'received_at': formattedDate, // Use the formatted date string
            'remark': Remark.text
          }));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Receipt added Successfully.'),
          ),
        );

        Navigator.push(context, MaterialPageRoute(builder: (context)=>add_receipt()));
      } 
      else 
      {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Adding receipt failed.'),
          ),
        );
      }
    } catch (e) {
      
    }
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

  Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
  Future<String?> getusername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // void getNameFromJWT() async {
  //   final token = await getTokenFromPrefs();
  //   if (token != null) {
  //     final jwt = JWT.decode(token);
  //     setState(() {
  //       name = jwt.payload['name']; // Extract and set the name
  //       ;
  //     });
  //   }
  // }
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
            "Add Bank",
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
              icon: Image.asset('lib/assets/profile.png'),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 10, left: 10),
                child: Container(
                  width: 600,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 34, 165, 246),
                    border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Add Receipt",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 13,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border:
                          Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                    ),
                    width: 700,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
  Text(
        "Receipt Type",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 5),
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedReceiptType,
            hint: Text(
              'Select Receipt Type',
              style: TextStyle(fontSize: 12.0),
            ),
             items: receiptTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: TextStyle(fontSize: 12.0),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedReceiptType = value;
              });
            },
            underline: SizedBox(),
          ),
        ),
      ),

      SizedBox(height: 10),


                      if(selectedReceiptType =='Order Receipt') 
                          Text(
                            "Select Invoice",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          if(selectedReceiptType =='Order Receipt') 
                          SizedBox(height: 5),
                          if(selectedReceiptType =='Order Receipt')
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedInvoiceId,
                                hint: Text(
                                  'Select Invoice',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                                items: orders.map((order) {
                                  return DropdownMenuItem<String>(
                                    value: order['id'].toString(),
                                    child: Text(
                                      '${order['invoice']} - ${order['customer']}',
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedInvoiceId =
                                        value; // Store the selected invoice ID
      
                                        
                                  });
                                },
                                underline: SizedBox(),
                              ),
                            ),
                          ),

                        if(selectedReceiptType =='Advance receipt')
                          Text(
                              "Select Customer",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            if(selectedReceiptType =='Advance receipt')
                            SizedBox(height: 5),
                            if(selectedReceiptType =='Advance receipt')
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedCustomerId,
                                  hint: Text(
                                    'Select Customer',
                                    style: TextStyle(fontSize: 12.0),
                                  ),

  items: customer.map((cust) {
                                    return DropdownMenuItem<String>(
                                      value: cust['id'].toString(),
                                      child: Text(
                                        cust['name'],
                                        style: TextStyle(fontSize: 12.0),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCustomerId = value;
                                    });
                                  },
                                  underline: SizedBox(),
                                ),
                              ),
                            ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Amount",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              child: TextField(
                                controller: amount,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  labelStyle: TextStyle(
                                    fontSize: 12.0, // Set your desired font size
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8.0), // Set vertical padding
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Transaction Id",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              child: TextField(
                                controller: transactionid,
                                decoration: InputDecoration(
                                  labelText: 'Transaction Id',
                                  labelStyle: TextStyle(
                                    fontSize: 12.0, // Set your desired font size
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8.0), // Set vertical padding
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Bank",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedBankId,
                                hint: Text(
                                  'Select Bank',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                                items: bank.map((bankItem) {
                                  return DropdownMenuItem<String>(
                                    value: bankItem['id'].toString(),
                                    child: Text(
                                      '${bankItem['name']}',
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedBankId = value; // Store the selected bank ID
                                    ;
                                  });
                                },
                                underline: SizedBox(),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Remark",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              child: TextField(
                                controller:Remark ,
                                decoration: InputDecoration(
                                  labelText: 'Remark',
                                  labelStyle: TextStyle(
                                    fontSize: 12.0, // Set your desired font size
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8.0), // Set vertical padding
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Date",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              child: TextField(
                                controller: TextEditingController(
                                    text: DateFormat('yyyy-MM-dd').format(selectedDate)), // Default date
                                readOnly: true, // Make the field read-only
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  labelStyle: TextStyle(
                                    fontSize: 12.0, // Set your desired font size
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8.0), // Set vertical padding
                                ),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000), // Earliest date
                                    lastDate: DateTime(2100), // Latest date
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDate = pickedDate; // Update the selected date
                                      ;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Name",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              child: TextField(
                                controller: TextEditingController(
                                    text: uname.text), // Display the name extracted from JWT
                                readOnly: true, // Make the field non-editable
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: TextStyle(
                                    fontSize: 12.0, // Set your desired font size
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8.0), // Set vertical padding
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 270,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if(selectedReceiptType=='Order Receipt'){
                                       AddReceipt(context);}
                                        else if(selectedReceiptType=='Advance receipt'){
                                          AddReceipt2(context);
                                        }
                                        else if(selectedReceiptType=='other Receipt'){
                                          AddReceipt3(context);
                                        }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Color.fromARGB(255, 64, 176, 251),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Set your desired border radius
                                        ),
                                      ),
                                      fixedSize: MaterialStateProperty.all<Size>(
                                        Size(95,
                                            15), // Set your desired width and heigh
                                      ),
                                    ),
                                    child: Text("Submit",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ]),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    )),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
