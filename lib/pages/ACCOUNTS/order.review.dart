import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/order_list.dart';
import 'package:beposoft/pages/api.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class OrderReview extends StatefulWidget {
  final id;
  final customer;
  const OrderReview({super.key, required this.id,required this.customer});

  @override
  State<OrderReview> createState() => _OrderReviewState();
}

class _OrderReviewState extends State<OrderReview> {
  Drawer d = Drawer();
  var ord;
  List<Map<String, dynamic>> warehouse = [];

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> bank = [];
  String? selectedBank;
  String? createdBy;
  String? companyname;
  DateTime selectedDate = DateTime.now();
  TextEditingController amountController = TextEditingController();
  TextEditingController transactionIdController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController receivedDateController = TextEditingController();
  String? selectedStatus;
   List<Map<String, dynamic>> ledgerEntries = [];
  List<Map<String, dynamic>> filteredEntries = [];
    double totalDebit = 0.0;
  double totalCredit = 0.0;
  final TextEditingController noteController = TextEditingController();
  TextEditingController actualweightController = TextEditingController();
  TextEditingController postofficeamountController = TextEditingController();
  TextEditingController shippingchargeController = TextEditingController();
   TextEditingController codamount = TextEditingController();
  TextEditingController shippingmethod = TextEditingController();
            TextEditingController trackingIdController = TextEditingController();

var selectedserviceId;
  List<String> statuses = [];
  @override
  void initState() {
    super.initState();
    initData();
    getbank();
    getcourierservices();
    fetchCustomerLedgerDetails();
  
    receivedDateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  }
var dep;
  Future<void> initData() async {
    await fetchOrderItems();
     dep = await getdepFromPrefs();
     ;
    if (dep == "BDM") {
      statuses = [
        'Invoice Approved',
        'Invoice Rejectd',
      ];
    } else if (dep == "Accounts / Accounting") {
      statuses = [
        'Shipped',
        'Waiting For Confirmation',
        'Invoice Rejectd',
      ];
    } else if (dep == "Admin") {
      statuses = [
        'To Print',
        'Invoice Rejectd',
      ];
    } else if (dep == "warehouse") {
      statuses = [
        'Packing under progress',
        'Packing',
        'Ready to ship'
            'Invoice Rejectd',
      ];
    } else {
      statuses = [
        'Invoice Approved',
        'Waiting For Confirmation',
        'To Print',
        'Packing under progress',
        'Packed',
        'Ready to ship',
        'Shipped',
        'Invoice Rejected',
      ];
    }
  }

  bool showAllProducts = false;
  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
  var customerledgertotal;
  var customerledgerreceived;
  var difference;
  bool ledger=false;
Future<void> fetchCustomerLedgerDetails() async {
  try {
    ;
    
    final token = await getTokenFromPrefs();
    final response = await http.get(
      Uri.parse('$api/api/customer/${widget.customer}/ledger/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    ;
    ;

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      final data = parsed['data'] as List;

      double totalAmountSum = 0;
      double receivedPaymentSum = 0;

      for (var order in data) {
        totalAmountSum += (order['total_amount'] as num).toDouble();

        if (order['recived_payment'] != null) {
          for (var payment in order['recived_payment']) {
            receivedPaymentSum += double.tryParse(payment['amount'].toString()) ?? 0.0;
          }
        }
      }
      var dif;
      if(receivedPaymentSum>totalAmountSum){
;
         dif=receivedPaymentSum-totalAmountSum;
         ledger=true;

      }
      else{
         dif=totalAmountSum-receivedPaymentSum;
         ledger=false;
      }
      setState(() {
        customerledgertotal = totalAmountSum;
        customerledgerreceived = receivedPaymentSum;
        difference=dif;
        
      });

      ;
      ;
      ;

    } else {
      ;
    }
  } catch (error) {
    ;
  }
}

void showParcelServiceDialog(BuildContext context, var id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Parcel Service'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                isExpanded: true,
                underline: SizedBox(), // Removes default underline
                hint: Text('Select a Parcel Service'),
                value: selectedserviceId,
                items: courierdata.map((item) {
                  return DropdownMenuItem<int>(
                    value: item['id'],
                    child: Text(item['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedserviceId = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // Set the background color
  ),
  child: Text('Submit', style: TextStyle(color: Colors.white)),
  onPressed: () {
    updateparcel(selectedserviceId, id);
  },
),
        ],
      );
    },
  );
}



void _showShippingChargeDialog(BuildContext context, Map<String, dynamic> boxDetails) {
  final shippingController = TextEditingController(text: boxDetails['shipping_charge']?.toString() ?? '');
  final actualWeightController = TextEditingController(text: boxDetails['actual_weight']?.toString() ?? '');
  final postOfficeAmountController = TextEditingController(text: boxDetails['parcel_amount']?.toString() ?? '');
  final dateController = TextEditingController(text: boxDetails['postoffice_date']?.toString() ?? '');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Box Details'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Shipping Charge
              TextField(
                controller: shippingController,
                decoration: InputDecoration(
                  labelText: 'Shipping Charge',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Actual Weight
              TextField(
                controller: actualWeightController,
                decoration: InputDecoration(
                  labelText: 'Actual Weight',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Post Office Amount
              TextField(
                controller: postOfficeAmountController,
                decoration: InputDecoration(
                  labelText: 'Post Office Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Date Picker
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Select Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (shippingController.text.isNotEmpty &&
                  actualWeightController.text.isNotEmpty &&
                  postOfficeAmountController.text.isNotEmpty &&
                  dateController.text.isNotEmpty) {
                updateactualweight(
                  boxDetails['id'],
                  double.parse(shippingController.text),
                  double.parse(actualWeightController.text),
                  double.parse(postOfficeAmountController.text),
                  dateController.text, // Pass selected date
                );
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill out all fields.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}
  // final List<String> statuses = [
  //   'Pending',
  //   'Approved',
  //   'Invoice Created',
  //   'Invoice Approved',
  //   'Waiting For Confirmation',
  //   'To Print',
  //   'Invoice Rejectd',
  //   'Processing',
  //   'Refunded',
  //   'Return',
  //   'Completed',
  //   'Cancelled',
  //   'Shipped'
  // ];
  double netAmountBeforeTax = 0.0; // Define at the class level
  double totalTaxAmount = 0.0; // Define at the class level
  double payableAmount = 0.0; // Define at the class level
  double Balance = 0.0; // Define at the class level
  double paymentreceipt = 0.0; // Define at the class level
  int? selectedAddressId; // Variable to store the selected address ID

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        receivedDateController.text =
            DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }
  

Future<void> updateboxstatus( var orderId) async {
  try {
    final token = await getTokenFromPrefs();

;
    var response = await http.put(
      Uri.parse('$api/api/warehouse/detail/$orderId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          'status': selectedStatus,

        },
      ),
    );
    ;
    ;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shipping charge updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
fetchOrderItems();


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update shipping charge'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (error) {
    ;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating shipping charge'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}



void showStatusDialog(BuildContext context,var order) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStatus,
              hint: Text('Select Status'),
              items: statuses.map((status) {
                return DropdownMenuItem<String>(
                    value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value; // This will store the selected status
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await updateboxstatus(order['id']);
                  Navigator.of(context).pop(); // Close the dialog after saving
                },
                label: Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  foregroundColor: Colors.white, // Text color
                ),
                icon: Icon(Icons.save),
              ),
            ),
          ],
        ),
      );
    },
  );
}
    List<Map<String, dynamic>> courierdata = [];

Future<void> getcourierservices() async {
  try {
    final token = await getTokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/parcal/service/'),
      headers: {
        'Authorization': ' Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    
    
    // Ensure the response is in the expected format
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      
      // Access the 'data' field which contains the list of courier services
      List<Map<String, dynamic>> Courierlist = [];

      // Check if 'data' exists in the response
      if (parsed.containsKey('data')) {
        for (var productData in parsed['data']) {
          Courierlist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
      }

      setState(() {
        courierdata = Courierlist;
        
      });
;
    }
  } catch (error) {
    
  }
}

Future<void> SendTrackingId(BuildContext scaffoldContext,var trackingId,var Orderid) async {
    final token = await gettoken();
    try {
      final response = await http.post(Uri.parse('$api/api/sendtrackingid/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': ord['customer']['name'],
            'tracking_id':trackingId,
            'order_id': Orderid,
            'phone': ord['customer']['phone'],
          }));
;
          ;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Tracking Id Sent Successfully.'),
          ),
        );
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => OrderReview()));
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Sending Tracking Id failed.'),
          ),
        );
      }
    } catch (e) {
       ;
    }
  }
  Future<void> updatestatus() async {
    try {
      final token = await getTokenFromPrefs();

      String formattedTime = DateFormat("HH:mm").format(DateTime.now());

      
      

      var response = await http.put(
        Uri.parse('$api/api/order/status/update/${widget.id}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'status': selectedStatus,
            'time': formattedTime,
            'updated_at': DateTime.now().toIso8601String().split('T')[0],
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('status updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
       Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OrderList(status:null)),
          );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> updateactualweight(
    var warehouseId,
    double shippingController,
    double actualWeight,
    double postOfficeAmount,
    var selectedDate,

  ) async {
    try {
      final token = await getTokenFromPrefs();

   

      var response = await http.put(
        Uri.parse('$api/api/warehouse/detail/$warehouseId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'shipping_charge': shippingController,
            'actual_weight': actualWeight,
            'parcel_amount': postOfficeAmount,
            'postoffice_date': selectedDate,
          },
        ),
      );
;
      ;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update '),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating '),
          duration: Duration(seconds: 2),
        ),
      );
      
    }
  }



Future<void> updateshippeddate(DateTime pickedDate, var orderId) async {
  try {
    final token = await getTokenFromPrefs();

    var formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

    var response = await http.put(
      Uri.parse('$api/api/warehouse/detail/$orderId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          'shipped_date': formattedDate,
        },
      ),
    );
    ;
    ;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
fetchOrderItems();


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update '),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (error) {
    ;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating '),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

Future<void> updateparcel(var parcel , var orderId) async {
  try {
    final token = await getTokenFromPrefs();


    var response = await http.put(
      Uri.parse('$api/api/warehouse/detail/$orderId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          'parcel_service': parcel,
        },
      ),
    );
    ;
    ;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
fetchOrderItems();


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update '),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (error) {
    ;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating '),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
Future<void> updatetrackid(var track , var orderId) async {
  try {
    final token = await getTokenFromPrefs();


    var response = await http.put(
      Uri.parse('$api/api/warehouse/detail/$orderId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          'tracking_id': track,
        },
      ),
    );
    ;
    ;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
fetchOrderItems();


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (error) {
    ;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating '),
        duration: Duration(seconds: 2),
      ),
    );
  }
}


  List<Map<String, dynamic>> company = [];

  Future<void> getcompany(id) async {
    try {
      final token = await getTokenFromPrefs();

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
          String imageUrl = "${productData['image']}";
          companylist.add({
            'id': productData['id'],
            'name': productData['name'],
          });

          if (id == productData['id']) {
            companyname = productData['name'];
          }
        }

        setState(() {
          company = companylist;
        });
      }
    } catch (error) {
      
    }
  }

  void showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Receipt Against Invoice Generate'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Received Date field with default today's date
                    TextField(
                      readOnly: true,
                      controller: receivedDateController,
                      decoration: InputDecoration(
                        labelText: 'Received Date',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                    ),
                    SizedBox(height: 10), // Add spacing between fields
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedBank,
                      items: bank
                          .map((bankItem) => DropdownMenuItem<String>(
                                value: bankItem['id'].toString(),
                                child: Text(bankItem['name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBank = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Bank',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 10.0,
                        ),
                        border: OutlineInputBorder(),
                        isDense: true, // Makes the dropdown compact
                      ),
                      isExpanded:
                          true, // Ensures the dropdown text fits properly
                    ),

                    SizedBox(height: 10),
                    TextField(
                      controller: transactionIdController,
                      decoration: InputDecoration(
                        labelText: 'Transaction ID',
                        prefixIcon: Icon(Icons.receipt),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      readOnly: true, // Make this field non-editable
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: createdBy ??
                            'Loading...', // Display the creator's name
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: remarkController,
                      decoration: InputDecoration(
                        labelText: 'Remark',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle save action here
                    AddReceipt(context);
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<String?> gettoken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('token');
  }

  Future<void> updateaddress() async {
    if (noteController != null && selectedAddressId != null) {
      try {
        final token = await gettoken();

        var response = await http.put(
          Uri.parse('$api/api/shipping/${widget.id}/order/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(
            {
              'billing_address': selectedAddressId,
              'note': noteController.text,
            },
          ),
        );

        

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Address updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OrderReview(id: widget.id,customer: widget.customer,)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to update Address'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (error) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }



  Future<void> updatecod() async {
    
      try {
        final token = await gettoken();

        var response = await http.put(
          Uri.parse('$api/api/orders/update/${widget.id}/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(
            {
              'cod_amount': codamount.text,
              'shipping_mode': shippingmethod.text,
            },
          ),
        );

        ;
        ;

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Address updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OrderReview(id: widget.id,customer: widget.customer)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to update Address'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (error) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    
  }

  List<Map<String, dynamic>> addres = [];

  Future<void> getaddress(var id) async {
    try {
      final token = await gettoken();
      
      var response = await http.get(
        Uri.parse('$api/api/add/customer/address/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      List<Map<String, dynamic>> addresslist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        
        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          addresslist.add({
            'id': productData['id'],
            'name': productData['name'],
            'email': productData['email'],
            'zipcode': productData['zipcode'],
            'address': productData['address'],
            'phone': productData['phone'],
            'country': productData['country'],
            'city': productData['city'],
            'state': productData['state'],
          });
        }
        setState(() {
          addres = addresslist;
          
        });
      }
    } catch (error) {
      
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
          String imageUrl = "${productData['image']}";
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
      String formattedReceivedDate =
          DateFormat('yyyy-MM-dd').format(selectedDate);
      final response =
          await http.post(Uri.parse('$api/api/payment/${widget.id}/reciept/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'amount': amountController.text,
                'bank': selectedBank,
                'transactionID': transactionIdController.text,
                'received_at': formattedReceivedDate,
                'created_by': createdBy,
                'remark': remarkController.text
              }));
      
      

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Receipt added Successfully.'),
          ),
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderReview(
                      id: widget.id,customer: widget.customer
                    )));
      } else {
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


Future<void> deletebox( var orderId) async {
  try {
    final token = await getTokenFromPrefs();

;
    var response = await http.delete(
      Uri.parse('$api/api/warehouse/detail/$orderId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      
    );
    ;
    ;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shipping charge updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update shipping charge'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    fetchOrderItems();

  } catch (error) {
    ;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating shipping charge'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
  // bool flag = false;

  double totalDiscount = 0.0; // Define at the class level
 Future<void> fetchOrderItems() async {
  try {
    ;
    final token = await getTokenFromPrefs();

    if (token == null) {
      ;
      return;
    }

    final jwt = JWT.decode(token);
    var name = jwt.payload['name'] ?? 'Unknown'; // Provide a default value
    setState(() {
      createdBy = name;
    });

    ;
    ;
    ;

    var response = await http.get(
      Uri.parse('$api/api/order/${widget.id}/items/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

  
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);

      ord = parsed['order'] ?? {};
      ;
codamount.text = ord['cod_amount']?.toString() ?? '';
      shippingmethod.text = ord['shipping_mode'] ?? '';

      List<dynamic> itemsData = parsed['items'] ?? [];
      List<dynamic> warehouseData = (parsed['order'] != null && parsed['order']['warehouse'] is List) ? parsed['order']['warehouse'] : [];

      ;

      getaddress(ord['customer']?['id']);

      List<Map<String, dynamic>> orderList = [];
      List<Map<String, dynamic>> warehouseList = [];
      double calculatedNetAmount = 0.0;
      double calculatedTotalTax = 0.0;
      double calculatedPayableAmount = 0.0;
      double calculatedTotalDiscount = 0.0;

      // Process each item and calculate totals
      for (var item in itemsData) {
        orderList.add({
          'id': item['id'],
          'name': item['name'] ?? '',
          'quantity': item['quantity'] ?? 0,
          'rate': item['rate'] ?? 0.0,
          'tax': item['tax'] ?? 0.0,
          'discount': item['discount'] ?? 0.0,
          'actual_price': item['actual_price'] ?? 0.0,
          'exclude_price': item['exclude_price'] ?? 0.0,
          'images': item['image'] ?? '',
        });
        double price=(item['rate'] ?? 0).toDouble();

        double price_discount=(item['price_discount'] ?? 0).toDouble();
        double excludePrice = (item['exclude_price'] ?? 0).toDouble();
        double actualPrice = (item['actual_price'] ?? 0).toDouble();
        double discount = (item['discount'] ?? 0).toDouble();
        final quantity = int.tryParse(item['quantity'].toString()) ?? 1;

        calculatedNetAmount += excludePrice* quantity;
        calculatedTotalTax += (price_discount - excludePrice)* quantity;
        calculatedTotalDiscount += discount * quantity;
        calculatedPayableAmount += price* quantity;
      }

      // Process each warehouse item
      for (var warehouse in warehouseData) {
        warehouseList.add({
          'id': warehouse['id'],
          'box': warehouse['box'] ?? '',
          'weight': warehouse['weight'] ?? '0',
          'length': warehouse['length'] ?? '0',
          'breadth': warehouse['breadth'] ?? '0',
          'height': warehouse['height'] ?? '0',
          'image': warehouse['image'] ?? '',
          'parcel_service': warehouse['parcel_service'] ?? '',
          'tracking_id': warehouse['tracking_id'] ?? '',
          'shipping_charge': warehouse['shipping_charge'] ?? '0.0',
          'status': warehouse['status'] ?? '',
          'shipped_date': warehouse['shipped_date'] ?? '',
          'actual_weight': warehouse['actual_weight'] ?? '0.0',
          'parcel_amount': warehouse['parcel_amount'] ?? '0.0',
          'postoffice_date': warehouse['postoffice_date'] ?? '',
          'message_status': warehouse['message_status'] ?? '',
        });
      }

      double paymentReceiptsSum = 0.0;

      for (var receipt in parsed['order']['recived_payment'] ?? []) {
        paymentReceiptsSum += double.tryParse(receipt['amount'].toString()) ?? 0.0;
        ;
      }
;
double remainingAmount;
if(calculatedNetAmount>paymentReceiptsSum){
       remainingAmount = calculatedNetAmount - paymentReceiptsSum;
     
}
else{
  remainingAmount=paymentReceiptsSum-calculatedNetAmount;
}
      setState(() {

        items = orderList;
        warehouse = warehouseList;
        netAmountBeforeTax = calculatedNetAmount;
        totalTaxAmount = calculatedTotalTax;
        payableAmount = calculatedPayableAmount;
        totalDiscount = calculatedTotalDiscount;
        Balance = remainingAmount;
        paymentreceipt=remainingAmount;
      });
;
      ;
      ;
      ;
      ;
      ;
      ;
    } else {
      ;
    }
  } catch (error) {
    ;
  }
}
Future<void> updatemsg(var orderId) async {
    try {
      final token = await getTokenFromPrefs();

      var response = await http.put(
        Uri.parse('$api/api/warehouse/detail/$orderId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'message_status': 'sent',
          },
        ),
      );
  
      ;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message send successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        fetchOrderItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send msg'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error in send message'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  Future<void> removeproduct(int Id) async {
    final token = await getTokenFromPrefs();

    try {
      final response = await http.delete(
        Uri.parse('$api/api/remove/order/$Id/item/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 49, 212, 4),
            content: Text('Deleted sucessfully'),
          ),
        );
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderReview(id:widget.id)));
        await fetchOrderItems();
      }

      if (response.statusCode == 204) {
      } else {
        throw Exception('Failed to delete wishlist ID: $Id');
      }
    } catch (error) {}
  }

  void removeProductindex(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void showPopupDialog(BuildContext context, Map<String, dynamic> item) {
    TextEditingController quantityController =
        TextEditingController(text: item['quantity']?.toString() ?? '');
    TextEditingController discountController =
        TextEditingController(text: item['discount']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Item Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: discountController,
                decoration: InputDecoration(
                    labelText: 'Discount (in Rs for each product)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final quantity =
                    int.tryParse(quantityController.text) ?? item['quantity'];
                final discount = double.tryParse(discountController.text) ??
                    item['discount'];

                updatedetails(item['id'], quantity, discount);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updatedetails(int id, int quantity, double discount) async {
    try {
      final token = await getTokenFromPrefs();
      final response = await http.put(
        Uri.parse('$api/api/remove/order/$id/item/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'quantity': quantity,
          'discount': discount,
        }),
      );

      

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cart item updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await fetchOrderItems();
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderReview(id: widget.id)));
      } else {
        throw Exception('Failed to update cart item');
      }
    } catch (error) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update cart item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDatePicker(BuildContext context, int orderId) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      updateshippeddate( picked, orderId);
      ;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = showAllProducts ? items : items.take(3).toList();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              height: 160,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Row(
                    children: [
                      SizedBox(width: 13),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 220, 220, 220),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.local_shipping,
                            size: 40, color: Colors.blue),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      ord != null
          ? ord['invoice'] ?? 'Invoice Number'
          : 'Loading...',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 0, 0, 0),
      ),
    ),

  if( dep != "BDO")
    IconButton(
      onPressed: () async {
        final Uri url = Uri.parse('$api/invoice/${ord['id']}/');

        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          // Handle error case
        }
      },
      icon: Icon(
        Icons.download,
        color: Colors.blue,
        size: 24,
      ),
    ),
  ],
),

                         
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                   Text(
                            ord != null
                                ? ord['company']['name'] ?? 'Company'
                                : 'Loading...',
                            style: TextStyle(color: const Color.fromARGB(255, 0, 77, 141)),
                          ),
                                            SizedBox(height: 5,)

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.white,
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ord != null
                                ? ord['manage_staff'] ?? 'manage_staff'
                                : 'Loading...',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ord != null
                                ? ord["order_date"] ?? 'Date Not Available'
                                : '',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: .0),
                          Row(
                            children: [
                              Text(
                                'Status: ',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              Spacer(),
                              Text(
                                ord != null ? '${ord["status"]}' : 'Loading...',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Family',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Text(
                                ord != null ? '${ord["family"]}' : 'Loading...',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.0),
                          SizedBox(height: 4.0),
                          // if (ord != null && ord['shipping_mode'] != null)
                          //   Row(
                          //     children: [
                          //       Text(
                          //         'Shipping Mode',
                          //         style: TextStyle(
                          //             fontSize: 12,
                          //             fontWeight: FontWeight.w600),
                          //       ),
                          //       Spacer(),
                          //       Text(
                          //         '${ord['shipping_mode']}',
                          //         style: TextStyle(
                          //             color: const Color.fromARGB(255, 0, 0, 0),
                          //             fontSize: 12),
                          //       ),
                          //     ],
                          //   ),
                          // if (ord != null &&
                          //     ord['cod_amount'] != null &&
                          //     ord['cod_amount'] != 0)
                          //   SizedBox(height: 4.0),
                          // if (ord != null &&
                          //     ord['cod_amount'] != null &&
                          //     ord['cod_amount'] != 0)
                          //   Row(
                          //     children: [
                          //       Text(
                          //         'Code Charge',
                          //         style: TextStyle(
                          //             fontSize: 12,
                          //             fontWeight: FontWeight.w600),
                          //       ),
                          //       Spacer(),
                          //       Text(
                          //         ' ${ord['cod_amount']}',
                          //         style: TextStyle(
                          //             color: const Color.fromARGB(255, 0, 0, 0),
                          //             fontSize: 12),
                          //       ),
                          //     ],
                          //   ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
SizedBox(height: 5,),

          
if (dep != "BDM" && dep != "BDO")
  Padding(
    padding: const EdgeInsets.only(right: 10, left: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: shippingmethod,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0), // Add border radius
                  ),
                  labelText: 'Shipping Mode',
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: codamount,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0), // Add border radius
                  ),
                  labelText: 'COD Amount',
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              updatecod();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Set background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Add border radius
              ),
            ),
            child: Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    ),
  ),

           Padding(
              padding: const EdgeInsets.only(right: 15, left: 15),
              child: Divider(),
            ),


            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Billing Address',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    ord != null ? '${ord["customer"]["name"]}' : 'Loading...',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    ord != null
                        ? '${ord["customer"]["address"]}, ${ord["customer"]["city"]}, ${ord["customer"]["state"]}, ${ord["customer"]["zip_code"]}'
                        : 'Loading...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    ord != null
                        ? 'Phone: ${ord["customer"]["phone"]}'
                        : 'Loading...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    ord != null
                        ? 'Email: ${ord["customer"]["email"]}'
                        : 'Loading...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15, left: 15),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shipping Address',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    ord != null
                        ? '${ord["billing_address"]["name"]}'
                        : 'Loading...',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    ord != null
                        ? '${ord["billing_address"]["address"]}, ${ord["billing_address"]["city"]}, ${ord["billing_address"]["state"]}, ${ord["billing_address"]["zipcode"]}'
                        : 'Loading...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    ord != null
                        ? 'Phone: ${ord["billing_address"]["phone"]}'
                        : 'Loading...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    ord != null
                        ? 'Email: ${ord["billing_address"]["email"]}'
                        : 'Loading...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 15, left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Display each item in the visibleItems list within a card
                  for (var item in visibleItems)
                    GestureDetector(
                      onTap: () {
                        
                        showPopupDialog(context, item);
                      },
                      child: Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display the first image in a small container
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage('$api${item["images"]}'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Display product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Quantity: ${item["quantity"]}, Rate: ${item["rate"]}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'discount: ${item["discount"]}',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        if (item["tax"] != 0)
                                          Text(
                                            'Tax: ${item["tax"]}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          )
                                      ],
                                    ),
                                     Text(
                                      'Rate After Discount: ${item["rate"] - item["discount"]}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),

                                   Text(
  'Tax Amount: ${((item["rate"] - item["discount"]) - item["exclude_price"]).toStringAsFixed(2)}',
  style: TextStyle(
      fontSize: 12, color: Colors.grey),
),
                                     // ...existing code...
Text(
  'Excluded price: ${item["exclude_price"]}',
  style: TextStyle(
      fontSize: 12, color: Colors.grey),
),
// ...existing code...
                                    Row(
                                      children: [
                                       Text(
  'Total: ${((item["exclude_price"] )  * item["quantity"]).toStringAsFixed(2)}',
  style: TextStyle(
      fontSize: 12,
      color: Colors.black),
),
                                        Spacer(),
                                      if(dep != "BDM" && dep != "BDO")

                                        GestureDetector(
                                          onTap: () {
                                            removeproduct(item["id"]);
                                          },
                                          child: Image.asset(
                                              height: 25,
                                              width: 25,
                                              "lib/assets/delete.png"),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // "See More" or "See Less" Button
                  if (items.length >
                      3) // Show button only if there are more than 3 items
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAllProducts =
                              !showAllProducts; // Toggle the visibility
                        });
                      },
                      child: Text(
                        showAllProducts ? 'See Less' : 'See More',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 2, 65, 96),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bank Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          ord != null ? ord["bank"]["name"] : 'Loading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 2,
                          ),
                        ),
                        Spacer(),
                        Image.asset(
                            height: 40, width: 40, 'lib/assets/money.png')
                      ],
                    ),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(
                        //       'Account Holder',
                        //       style: TextStyle(
                        //         color: Colors.grey[400],
                        //         fontSize: 12,
                        //       ),
                        //     ),
                        //     Text(
                        //       ord != null
                        //           ? ord["customer"]["name"]
                        //           : 'Loading...',
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Account No: ',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ord != null
                                      ? ord["bank"]["account_number"]
                                      : 'Loading...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'IFSC CODE: ',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ord != null
                                      ? ord["bank"]["ifsc_code"]
                                      : 'Loading...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Branch: ',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ord != null
                                      ? ord["bank"]["branch"]
                                      : 'Loading...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Open Balance: ',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ord != null
                                      ? ord["bank"]["open_balance"]
                                          .toStringAsFixed(
                                              2) // Formats to 2 decimal places
                                      : 'Loading...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Billing Summary',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Amount Before Tax',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${payableAmount.toStringAsFixed(2)}', // Format to 2 decimal places
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Discount',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${totalDiscount.toStringAsFixed(2)}', // Format to 2 decimal places
                          style: TextStyle(
                            color: const Color.fromARGB(255, 3, 3, 3),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Tax Amount',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${totalTaxAmount.toStringAsFixed(2)}', // Format to 2 decimal places
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Payable Amount ',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${netAmountBeforeTax.toStringAsFixed(2)}', // Format to 2 decimal places
                          style: TextStyle(
                            color: const Color.fromARGB(255, 1, 155, 24),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.white,
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Informations',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: .0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Balance Payment Amount: ',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              Text(
                               
                                    '\$${Balance.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.green),
                              )
                            ],
                          ),
                          SizedBox(height: 4.0),
                          
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      ledger
          ? 'Customer Ledger Credit:'
          : 'Customer Ledger Debit:',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
    
  ],
),
                             Text(
  '\$${(difference ?? 0).toStringAsFixed(2)}', // Use null-coalescing operator to handle null
)
                              ],
                            ),
                          // if (flag == false)
                          //   Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Text(
                          //         'Customer Ledger Debit:',
                          //         style: TextStyle(
                          //             fontSize: 12,
                          //             fontWeight: FontWeight.bold),
                          //       ),
                          //       Text(
                          //         Balance == 0
                          //             ? '\$${payableAmount.toStringAsFixed(2)}'
                          //             : '\$${Balance.toStringAsFixed(2)}',
                          //       )
                          //     ],
                          //   ),
                          SizedBox(height: 8.0),
                          if(dep != "BDM" && dep != "BDO")

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.blue, // Text color (white)
                              ),
                              onPressed: () {
                                if (createdBy != null) {
                                  showAddDialog(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Loading data, please wait...")),
                                  );
                                }
                              },
                              child: Text("Add"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ord != null && ord["recived_payment"].isNotEmpty)
                    Text(
                      'Receipt Details',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (ord != null && ord["recived_payment"].isNotEmpty)
                    SizedBox(height: 10),
                  // Check if ord and ord["recived_payment"] are not null
                  if (ord != null && ord["recived_payment"].isNotEmpty)
                    Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: const <int, TableColumnWidth>{
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                        2: FlexColumnWidth(),
                        3: FlexColumnWidth(),
                        4: FlexColumnWidth(),
                      },
                      children: [
                        // Header Row
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Receipt No',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Amount',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Transaction ID',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Received Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Remark',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        // Data Rows
                        for (var receipt in ord["recived_payment"])
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Text(receipt["payment_receipt"] ?? 'N/A'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(receipt["amount"] ?? 'N/A'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(receipt["transactionID"] ?? 'N/A'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(receipt["received_at"] ?? 'N/A'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(receipt["remark"] ?? 'N/A'),
                              ),
                            ],
                          ),
                      ],
                    )
                  else
                    // Display a loading or empty message if ord["recived_payment"] is null
                    Text(
                      'No receipt details available.',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
            SizedBox(height: 10),
          if(dep != "BDO")

            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 4,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Update Informations',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        hint: Text('Select Status'),
                        items: statuses.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus =
                                value; // This will store the selected status
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Status',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("Shipping Address",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                    Padding(
  padding: const EdgeInsets.only(),
  child: Container(
    height: 50,
    width: MediaQuery.of(context).size.width * 0.9, // Adjust width based on device size
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
    ),
    child: Row(
      children: [
        SizedBox(width: 20),
        Container(
          width: MediaQuery.of(context).size.width * 0.7, // Adjust width based on device size
          child: InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '',
              contentPadding: EdgeInsets.symmetric(horizontal: 1),
            ),
            child: DropdownButton<int>(
              hint: Text(
                'Address',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
              value: selectedAddressId,
              isExpanded: true,
              underline: Container(), // This removes the underline
              onChanged: (int? newValue) {
                setState(() {
                  selectedAddressId = newValue!;
                });
              },
              items: addres.map<DropdownMenuItem<int>>((address) {
                return DropdownMenuItem<int>(
                  value: address['id'],
                  child: Text(
                    "${address['address']}",
                    style: TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return addres.map<Widget>((address) {
                  return Text(
                    selectedAddressId != null && selectedAddressId == address['id']
                        ? "${address['address']}"
                        : "Address",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  );
                }).toList();
              },
              icon: Container(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_drop_down,
                  color: const Color.fromARGB(255, 151, 150, 150),
                ), // Dropdown arrow icon
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
                      SizedBox(height: 16.0),
                      //  TextField(
                      //   controller: actualweightController,

                      //   decoration: InputDecoration(
                      //     border: OutlineInputBorder(),
                      //     labelText: 'Add Actual Weight',
                      //   ),
                      // ),

                      // SizedBox(height: 16.0),

                      //  TextField(
                      //   controller: postofficeamountController,

                      //   decoration: InputDecoration(
                      //     border: OutlineInputBorder(),
                      //     labelText: 'Add Post Office Amount',
                      //   ),
                      // ),
                      // SizedBox(height: 16.0),
                    if(dep != "BDM" && dep != "BDO")

                      TextField(
                        controller: shippingchargeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Add Shipping Charge',
                        ),
                      ),
                      if(dep != "BDM" && dep != "BDO")
                      SizedBox(height: 16.0),
                      TextField(
                        controller: noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Add a Note',
                        ),
                      ),
                      SizedBox(height: 16.0),

                      ElevatedButton(
                        onPressed: () {
                          updateaddress();
                          updatestatus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Change background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // Add border radius
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BOX Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  ord == null || ord['warehouse'] == null
                      ? Center(
                          child: Text(
                            'No BOX Details Available',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Column(
                          children: ord['warehouse'].map<Widget>((order) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                    if(dep != "BDM" && dep != "BDO"){
                                  _showShippingChargeDialog(context, order);
                                    }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: Offset(0, 2), // Shadow position
                                      ),
                                    ],
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image and Box Details
                                      Row(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey[200],
                                            ),
                                            child: order['image'] != null
                                                ? Image.network(
                                                    '$api${order['image']}',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 40,
                                                          color: Colors.grey);
                                                    },
                                                  )
                                                : Icon(
                                                    Icons.image_not_supported,
                                                    size: 40,
                                                    color: Colors.grey),
                                          ),
                                          SizedBox(width: 10),
                                        
                                          Expanded(
                                            child: Text(
                                              ' ${order['box'] ?? 'N/A'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        if(dep != "BDM" && dep != "BDO")
                                         order['status'] == "Shipped" &&
                                                  order['message_status'] ==
                                                      "pending"
                                              ? ElevatedButton(
                                                  onPressed: () {
                                                    SendTrackingId(
                                                        context,
                                                        order['tracking_id'],
                                                        order['invoice']);
                                                    updatemsg(order['id']);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blue, // Blue button color
                                                    foregroundColor: Colors
                                                        .white, // White text color
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12), // Curved border
                                                    ),
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical:
                                                            12), // Button padding
                                                  ),
                                                  child: Text(
                                                    "Send Tracking ID",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )
                                              : Text(
                                                  "Message Status: ${order['message_status']}",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                                ),
                                          // Delete Button
                                          SizedBox(width: 5),
                                        if(dep != "BDM" && dep != "BDO")
                                          GestureDetector(
                                            onTap: () {
                                               deletebox(order['id']);
                                            },
                                            child: Image.asset(
                                              "lib/assets/close.png",
                                              height: 15,
                                              width: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      SizedBox(height: 12),

                                      // Shipping Charge
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Packed By:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            order['packed_by'] ?? 'N/A',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),


                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Verified by:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            order['verified_by'] ?? 'N/A',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),

                                       Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Final confirmation:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            order['checked_by'] ?? 'N/A',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Shipping Charge:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            order['shipping_charge'] ?? 'N/A',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Actual Weight:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            order['actual_weight'] != null
                                                ? '${order['actual_weight']} kg'
                                                : 'N/A',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Parcel Amount:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            order['parcel_amount'] ?? 'N/A',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),

                                      // Parcel Service
                                    
                                      SizedBox(height: 6),

                                  

                                     GestureDetector(
  onTap: () {
    if (dep != "BDM" && dep != "BDO") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Tracking ID'),
            content: TextField(
              controller: trackingIdController,
              decoration: InputDecoration(
                labelText: '${order['tracking_id']}',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button background color
                  foregroundColor: Colors.white, // Button text color
                ),
                onPressed: () {
                  String trackingId = trackingIdController.text.trim();
                  if (trackingId.isNotEmpty) {
                updatetrackid(trackingId,order['id']);
                    ;
                    Navigator.of(context).pop(); // Close the dialog
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid Tracking ID'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          );
        },
      );
    }
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 220, 220, 220), // Background color
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        child: Text(
          'Tracking ID',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white, // Text color
          ),
        ),
      ),
      Text(
        order['tracking_id'] ?? 'N/A',
        style: TextStyle(fontSize: 14),
      ),
    ],
  ),
),
  SizedBox(height: 5,),
                                       GestureDetector(
                                        onTap: () {
                                           showStatusDialog(context,order);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 220, 220, 220), // Background color
      borderRadius: BorderRadius.circular(8), // Rounded corners
    ),
    child: Text(
      'Status',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.white, // Text color
      ),
    ),
  ),
                                            Text(
                                              order['status'] ?? 'N/A',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 6),

                                        GestureDetector(
                                        onTap: (){
                                          if(dep != "BDM" && dep != "BDO"){
                                          showParcelServiceDialog(context,order['id']);
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                             Container(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 220, 220, 220), // Background color
      borderRadius: BorderRadius.circular(8), // Rounded corners
    ),
    child: Text(
      'Parcel Service',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.white, // Text color
      ),
    ),
  ),
                                            Text(
                                              order['parcel_service'] ?? 'N/A',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
  SizedBox(height: 5,),

                                      // Shipped Date
                                      GestureDetector(
                                        onTap: ()  {
                                          if(dep != "BDM" && dep != "BDO"){
                                          _showDatePicker(context, order['id']);
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                           Container(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 220, 220, 220), // Background color
      borderRadius: BorderRadius.circular(8), // Rounded corners
    ),
    child: Text(
      'Shipped DAte',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.white, // Text color
      ),
    ),
  ),
                                            Text(
                                              order['shipped_date'] ?? 'N/A',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),


            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
