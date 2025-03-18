import 'dart:convert';
import 'dart:io';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/api.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class WarehouseOrderReview extends StatefulWidget {
  final id;
  const WarehouseOrderReview({super.key, required this.id});

  @override
  State<WarehouseOrderReview> createState() => _WarehouseOrderReviewState();
}

class _WarehouseOrderReviewState extends State<WarehouseOrderReview> {
  Drawer d = Drawer();
  var ord;
  List<Map<String, dynamic>> courierdata = [];

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> bank = [];
  String? selectedBank;
  int? selectedserviceId;

  String? createdBy;
  var loginid;
  String? companyname;
  DateTime selectedDate = DateTime.now();
  TextEditingController amountController = TextEditingController();
  TextEditingController transactionIdController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController receivedDateController = TextEditingController();
  String? selectedStatus;
  final TextEditingController noteController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initData();
    getbank();
    
    receivedDateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  }

  Future<void> initData() async {
    await fetchOrderItems();
    await getmanagers();
    await getcourierservices();
  }

  List<Map<String, dynamic>> manager = [];
  String? selectedManagerName;
  int? selectedManagerId;

  final TextEditingController box = TextEditingController();

  final TextEditingController length = TextEditingController();
  final TextEditingController height = TextEditingController();

  final TextEditingController breadth = TextEditingController();
  final TextEditingController weight = TextEditingController();

  final TextEditingController service = TextEditingController();
  final TextEditingController transactionid = TextEditingController();
  final TextEditingController shippingcharge = TextEditingController();



 double? totalVolume; // Variable to store calculated volume

  // Function to calculate volume
  void calculateVolume() {
    final lengthValue = double.tryParse(length.text) ?? 0.0;
    final breadthValue = double.tryParse(breadth.text) ?? 0.0;
    final heightValue = double.tryParse(height.text) ?? 0.0;

    setState(() {
      totalVolume = (lengthValue * breadthValue * heightValue) / 6000;
    });
  }
  File? selectedImage;

  void imageSelect() async {
    try {
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          selectedImage = File(result.files.single.path!);

          
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("image1 selected successfully."),
          backgroundColor: Color.fromARGB(173, 120, 249, 126),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while selecting the file."),
        backgroundColor: Colors.red,
      ));
    }
  }

  bool showAllProducts = false;
  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  final List<String> statuses = [
   'Packing under Progress',
   'Ready To Ship',
    'Packed',
    'Shipped',
    
  ];
  double netAmountBeforeTax = 0.0; // Define at the class level
  double totalTaxAmount = 0.0; // Define at the class level
  double payableAmount = 0.0; // Define at the class level
  double Balance = 0.0; // Define at the class level
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
            backgroundColor: Colors.green,
          ),
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

  List<Map<String, dynamic>> company = [];

  Future<void> getcompany(id) async {
    try {
      final token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/company/getadd/'),
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

    }
  } catch (error) {
    
  }
}
Future<void> updateverifiedby( var orderId,selectedManagerId) async {
  try {
    print('selectedManagerId in functionnnnnnnnnnnnnnnnnn: $selectedManagerId');
    final token = await getTokenFromPrefs();

print('$api/api/warehouse/detail/$orderId/');
    var response = await http.put(
      Uri.parse('$api/api/warehouse/detail/$orderId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          'verified_by': selectedManagerId,

        },
      ),
    );
    print('responsessssssssssssssss shippeddddddddddddddddddd${response.body}');
    print('responsessssssssssssssss${response.statusCode}');
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
    print("Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating shipping charge'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}


Future<void> updateboxstatus( var orderId) async {
  try {
    final token = await getTokenFromPrefs();

print('$api/api/warehouse/detail/$orderId/');
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
    print('responsessssssssssssssss shippeddddddddddddddddddd${response.body}');
    print('responsessssssssssssssss${response.statusCode}');
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
    print("Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating shipping charge'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}



Future<void> deletebox( var orderId) async {
  try {
    print('selectedManagerId in functionnnnnnnnnnnnnnnnnn: $selectedManagerId');
    final token = await getTokenFromPrefs();

print('$api/api/warehouse/detail/$orderId/');
    var response = await http.delete(
      Uri.parse('$api/api/warehouse/detail/$orderId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      
    );
    print('responsessssssssssssssss shippeddddddddddddddddddd${response.body}');
    print('responsessssssssssssssss${response.statusCode}');
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
    print("Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating shipping charge'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
  Future<void> getmanagers() async {
    try {
      final token = await getTokenFromPrefs();
    
      var response = await http.get(
        Uri.parse('$api/api/staffs/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      List<Map<String, dynamic>> managerlist = [];
print('https://rising-regression-canada-intensity.trycloudflare.com/${response.body}');
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

     
        for (var productData in productsData) {
          managerlist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          manager = managerlist;

          
        });
      }
    } catch (error) {
      
    }
  }
void showBoxDetailsDialog(BuildContext context, Map<String, dynamic> boxDetails) {
  int? selectedManagerId;
  String? selectedManagerName;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Box Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Box: ${boxDetails['box'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Packed By: ${boxDetails['packed_by'] ?? 'N/A'}'),
              SizedBox(height: 8),
              
              Text('Shipping Charge: ${boxDetails['shipping_charge'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Parcel Service: ${boxDetails['parcel_service'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Tracking ID: ${boxDetails['tracking_id'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Status: ${boxDetails['status'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Shipped Date: ${boxDetails['shipped_date'] ?? 'N/A'}'),
              SizedBox(height: 8),
              if (boxDetails['image'] != null)
                Image.network(
                  '$api${boxDetails['image']}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
                  },
                ),

                
              SizedBox(height: 12),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedManagerId != null
                    ? manager.firstWhere(
                        (element) => element['id'] == selectedManagerId,
                        orElse: () => manager[0],
                      )
                    : null,
                hint: Text('Select here...'),
                items: manager.map((Map<String, dynamic> manager) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: manager,
                    child: Text(manager['name']),
                  );
                }).toList(),
                onChanged: (Map<String, dynamic>? newValue) {
                  setState(() {
                    selectedManagerName = newValue!['name'];
                    selectedManagerId = newValue['id'];
                    print('selectedManagerId: $selectedManagerId');

                  });
                },
                decoration: InputDecoration(
                  labelText: 'Verify By',
                  border: OutlineInputBorder(),
                ),
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
              backgroundColor: Colors.blue,
            ),
            onPressed: () {
              updateverifiedby(boxDetails['id'],selectedManagerId);
              
              Navigator.of(context).pop();
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
  void addboxdetails(
    File? image1,
    DateTime selectedDate,
    BuildContext scaffoldContext,
  ) async {
    final token = await getTokenFromPrefs();
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$api/api/warehouse/data/'));

      // Add headers to the request
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields directly
      request.fields['shipped_date'] =
          selectedDate.toIso8601String().substring(0, 10);

      // Convert selectedManagerId (int) to String
      // if (selectedManagerId == null) {
      //   ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      //     SnackBar(
      //       content: Text('Please select a manager before submitting.'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }

      // Add other form fields with proper conversion to String
      request.fields['order'] =
          widget.id.toString(); // Ensure widget.id is a string
      request.fields['box'] = box.text; // Assuming box.text is already a string
      request.fields['length'] =
          length.text.toString(); // Ensure length is a string
      request.fields['height'] =
          height.text.toString(); // Ensure length is a string
      request.fields['weight'] =
          weight.text.toString(); // Ensure weight is a string
      request.fields['breadth'] =
          breadth.text.toString(); // Ensure breadth is a string
      request.fields['parcel_service'] =
         selectedserviceId.toString(); // Ensure selectedserviceId is not null
      request.fields['tracking_id'] =
          transactionid.text; // Assuming transactionid.text is already a string
      // request.fields['shipping_charge'] =
      //     shippingcharge.text.toString(); // Ensure shipping charge is a string
      request.fields['status'] =
          selectedStatus ?? ''; // Ensure selectedStatus is not null

      if (selectedManagerId == null) {
        request.fields['packed_by'] =
            loginid.toString(); // Convert selectedManagerId to String
      } else {
        request.fields['packed_by'] =
            selectedManagerId.toString(); // Convert selectedManagerId to String
      }

      // Add images to the request if they are not null
      if (image1 != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image1.path));
      }

      
      
      
      

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print("ress>>>>>>>>>>>>>stta>>>>${response.statusCode}");
print("resssssssssssssssssssssssssss>>>>>>>>>>>>>>>>>>${response.body}");
      // Handle response based on status code
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Data Added Successfully.'),
          ),
        );
        Navigator.pushReplacement(
          scaffoldContext,
          MaterialPageRoute(
            builder: (context) => WarehouseOrderReview(
              id: widget.id,
            ),
          ),
        );
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                'Something went wrong. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(content: Text('Network error. Please check your connection.')),
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
  void showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
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
                      selectedBank = value; // Update selected bank
                    });
                  },
                  decoration: InputDecoration(labelText: 'Bank'),
                ),
                TextField(
                  controller: transactionIdController,
                  decoration: InputDecoration(
                      labelText: 'Tracking ID',
                      prefixIcon: Icon(Icons.receipt)),
                ),
                TextField(
                  readOnly: true, // Make this field non-editable
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText:
                        createdBy ?? 'Loading...', // Display the creator's name
                  ),
                ),

                TextField(
                  controller: remarkController,
                  decoration: InputDecoration(labelText: 'Remark (optional)'),
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
            'status': selectedStatus,
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
          MaterialPageRoute(
              builder: (context) => WarehouseOrderReview(id: widget.id)),
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
                builder: (context) => WarehouseOrderReview(
                      id: widget.id,
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

  bool flag = false;

  double totalDiscount = 0.0; // Define at the class level
  Future<void> fetchOrderItems() async {
      try {
        
        final token = await getTokenFromPrefs();
        final jwt = JWT.decode(token!);
        var name = jwt.payload['name'];
        setState(() {
          createdBy = name;
        });
        
        print('$api/api/order/${widget.id}/items/');
        var response = await http.get(
          Uri.parse('$api/api/order/${widget.id}/items/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

                print('Token:resssssssssssssssssssssss??????? ${response.body}');

  
        if (response.statusCode == 200) {
          final parsed = jsonDecode(response.body);
          ord = parsed['order'];
          
          List<dynamic> itemsData = parsed['items'];
          getaddress(ord['customer']['id']);

          List<Map<String, dynamic>> orderList = [];
          double calculatedNetAmount = 0.0;
          double calculatedTotalTax = 0.0;
          double calculatedPayableAmount = 0.0;
          double calculatedTotalDiscount = 0.0;

          // Process each item and calculate totals
          for (var item in itemsData) {
            orderList.add({
              'id': item['id'],
              'name': item['name'],
              'quantity': item['quantity'],
              'rate': item['rate'],
              'tax': item['tax'],
              'discount': item['discount'],
              'actual_price': item['actual_price'],
              'exclude_price': item['exclude_price'],
              'images': item['image'],
            });

            // Convert values to double for safe calculation
            double excludePrice = (item['exclude_price'] ?? 0).toDouble();
            double actualPrice = (item['actual_price'] ?? 0).toDouble();
            double discount = (item['discount'] ?? 0).toDouble();
            final quantity = int.tryParse(item['quantity'].toString()) ?? 1; // Ensure it's an integer

            // Add the exclude_price to net amount
            calculatedNetAmount += excludePrice;

            // Calculate and add the tax amount for each product
            double taxAmountForItem = actualPrice - excludePrice;
            calculatedTotalTax += taxAmountForItem;

            // Add discount amount for each product
            calculatedTotalDiscount += discount * quantity;

            // Calculate payable amount after subtracting discount
            double payableForItem = (actualPrice - discount) * quantity;
            calculatedPayableAmount += payableForItem;
          }

          // Calculate the sum of payment receipts
          double paymentReceiptsSum = 0.0;
          for (var receipt in parsed['order']['recived_payment']) {
            paymentReceiptsSum +=
                double.tryParse(receipt['amount'].toString()) ?? 0.0;
            
          }

          // Calculate remaining amount after comparing with calculatedPayableAmount
          double remainingAmount = 0.0;
          if (paymentReceiptsSum > calculatedPayableAmount) {
            remainingAmount = paymentReceiptsSum - calculatedPayableAmount;
            flag = true;
          } else {
            remainingAmount = calculatedPayableAmount - paymentReceiptsSum;
            flag = false;
          }
         // getcompany(ord['company']);

          setState(() {
            items = orderList;
            netAmountBeforeTax = calculatedNetAmount;
            totalTaxAmount = calculatedTotalTax;
            payableAmount = calculatedPayableAmount;
            totalDiscount = calculatedTotalDiscount;
            Balance = remainingAmount;
            
            
            
            
            
            
          });
        } else {
          
        }
      } catch (error) {
        
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

  @override
  Widget build(BuildContext context) {
    final visibleItems = showAllProducts ? items : items.take(2).toList();
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
                        
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                   Text(
                            ord != null
                                ? ord['company']['name'] ?? 'Company'
                                : 'Loading...',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(height: 5,)
                ],
              ),
            ),

            SizedBox(height: 10,),
            Container(
      color: Colors.white, // Background color
      padding: EdgeInsets.all(10), // Add padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly space buttons
        children: [
          ElevatedButton.icon(
            onPressed: () async{

              final Uri url = Uri.parse('$api/deliverynote/${ord['id']}/');

        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          // Handle error case
        }



            },
            icon: Icon(Icons.download,color: Colors.white,), // Download icon
            label: Text("Delivery"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Button color
              foregroundColor: Colors.white, // Text color
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async{

              final Uri url = Uri.parse('$api/shippinglabel/${ord['id']}/');

        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          // Handle error case
        }



            },
            icon: Icon(Icons.download,color: Colors.white), // Download icon
            label: Text("Address"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Button color
              foregroundColor: Colors.white, // Text color
            ),
          ),
        ],
      ),
    ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
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
                          if (ord != null && ord['shipping_mode'] != null)
                            Row(
                              children: [
                                Text(
                                  'Shipping Mode',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                Spacer(),
                                Text(
                                  '${ord['shipping_mode']}',
                                  style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          if (ord != null &&
                              ord['code_charge'] != null &&
                              ord['code_charge'] != 0)
                            SizedBox(height: 4.0),
                          if (ord != null &&
                              ord['code_charge'] != null &&
                              ord['code_charge'] != 0)
                            Row(
                              children: [
                                Text(
                                  'Code Charge',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                Spacer(),
                                Text(
                                  ' ${ord['code_charge']}',
                                  style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12,top: 10),
              child: DropdownButtonFormField<String>(
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
                            
                          ),
                        ),
            ),
            SizedBox(height: 5,),
             Padding(
               padding: const EdgeInsets.only(left: 12),
               child: ElevatedButton.icon(
                           onPressed: () async{
                updatestatus();
               
                           },
                           label: Text("Save"),
                           style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                foregroundColor: Colors.white, // Text color
                           ),
                         ),
             ),
            SizedBox(height: 10),
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
                                    image: NetworkImage(
                                        '$api${item["images"]}'),
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
                                          'Excluded price: ${item["exclude_price"]}',
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
                                      'Tax Amount: ${item["rate"] - item["exclude_price"]}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Total: ${item["actual_price"] * item["quantity"]}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        ),
                                        Spacer(),
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
            SizedBox(
              height: 10,
            ),
            SizedBox(height: 10),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Reduced padding
                child: Container(
                  padding: const EdgeInsets.all(12.0), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(8.0), // Reduced border radius
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 40, // Reduced height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.blue,
                        ),
                        alignment: Alignment.center, // Simplified layout
                        child: Text(
                          "Box Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Reduced font size
                          ),
                        ),
                      ),
                      SizedBox(height: 8), // Reduced spacing
                      Container(
                        height: 45, // Reduced height
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0), // Added padding
                        child: DropdownButton<Map<String, dynamic>>(
                          value: manager.isNotEmpty
                              ? manager.firstWhere(
                                  (element) =>
                                      element['id'] ==
                                      (selectedManagerId ?? manager[0]['id']),
                                  orElse: () => manager[0],
                                )
                              : null,
                          underline: SizedBox(),
                          onChanged: manager.isNotEmpty
                              ? (Map<String, dynamic>? newValue) {
                                  setState(() {
                                    selectedManagerName = newValue!['name'];
                                    selectedManagerId = newValue['id'];
                                    print(selectedManagerId);
                                    print(selectedManagerName);

                                  });
                                }
                              : null,
                          items: manager
                              .map<DropdownMenuItem<Map<String, dynamic>>>(
                                  (Map<String, dynamic> manager) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: manager,
                              child: Text(
                                manager['name'],
                                style: TextStyle(
                                    fontSize: 13), // Reduced font size
                              ),
                            );
                          }).toList(),
                          isExpanded: true, // Added to expand dropdown
                        ),
                      ),

                      SizedBox(height: 8),
                      TextField(
                        controller: box,
                        decoration: InputDecoration(
                          labelText: 'Boxes',
                          labelStyle: TextStyle(fontSize: 13),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                        ),
                      ),
                      SizedBox(height: 8), // Reduced spacing
                       Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: length,
                      decoration: InputDecoration(
                        labelText: 'Length',
                        labelStyle: TextStyle(fontSize: 13),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calculateVolume(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: breadth,
                      decoration: InputDecoration(
                        labelText: 'Breadth',
                        labelStyle: TextStyle(fontSize: 13),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calculateVolume(),
                    ),
                  ),
                ],
              ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                           Expanded(
                    child: TextField(
                      controller: height,
                      decoration: InputDecoration(
                        labelText: 'Height',
                        labelStyle: TextStyle(fontSize: 13),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calculateVolume(),
                    ),
                  ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: weight,
                              decoration: InputDecoration(
                                labelText: 'Weight(g)',
                                labelStyle: TextStyle(fontSize: 13),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3),
                       if (totalVolume != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Total Volume: ${totalVolume!.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                                        SizedBox(height: 5),

                      // TextField(
                      //   controller: service,
                      //   decoration: InputDecoration(
                      //     labelText: 'Service',
                      //     labelStyle: TextStyle(fontSize: 13),
                      //     border: OutlineInputBorder(),
                      //     contentPadding:
                      //         EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      //   ),
                      // ),

                      Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1.0),
                              ),
                              child: DropdownButton<int>(
                                isExpanded: true,
                                underline:
                                    SizedBox(), // Removes default underline
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
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: transactionid,
                        decoration: InputDecoration(
                          labelText: 'Transaction Id',
                          labelStyle: TextStyle(fontSize: 13),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                        ),
                      ),
                      SizedBox(height: 8),
                      // TextField(
                      //   controller: shippingcharge,
                      //   decoration: InputDecoration(
                      //     labelText: 'Shipping Charge',
                      //     labelStyle: TextStyle(fontSize: 13),
                      //     border: OutlineInputBorder(),
                      //     contentPadding: EdgeInsets.symmetric(
                      //         horizontal: 8.0, vertical: 8.0),
                      //   ),
                      // ),
                      SizedBox(height: 8),
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
                      Container(
                        height: 50, // Reduced height
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(fontSize: 13),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Icon(Icons.date_range,
                                  size: 20), // Reduced icon size
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => imageSelect(),
                        child: Container(
                          height: 120, // Reduced height
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: selectedImage == null
                              ? Center(
                                  child: Text(
                                    'Tap to select an image',
                                    style: TextStyle(
                                        fontSize: 13), // Reduced font size
                                  ),
                                )
                              : Image.file(
                                  File(selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(height: 12), // Reduced spacing

                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         ElevatedButton(
                           onPressed: () {
                             addboxdetails(selectedImage, selectedDate, context);
                             //updatestatus();
                           },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.blue, // Button background color
                             foregroundColor: Colors.white, // Text color
                             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Padding inside the button
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(10), // Rounded corners
                             ),
                             elevation: 5, // Shadow effect
                             fixedSize: Size(200, 50), // Width and height of the button
                           ),
                           child: Text(
                             "Submit",
                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Text styling
                           ),
                         ),
                       ],
                     ),

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
                          children:
                              ord['warehouse'].map<Widget>((order) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: GestureDetector(
                                onTap: (){

                                   showBoxDetailsDialog(
                                      context, order);

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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    errorBuilder: (context, error,
                                                        stackTrace) {
                                                      return Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 40,
                                                          color: Colors.grey);
                                                    },
                                                  )
                                                : Icon(Icons.image_not_supported,
                                                    size: 40, color: Colors.grey),
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
                                          // Delete Button
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
                                            'Checked by:',
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
                                
                                      // Shipping Charge
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
                                
                                      // Parcel Service
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Parcel Service:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            order['parcel_service'] ?? 'N/A',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                
                                      // Tracking ID
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tracking ID:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            order['tracking_id']?.toString() ??
                                                'N/A',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                
                                      // Status
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
                                
                                      // Shipped Date
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Shipped Date:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            order['shipped_date'] ?? 'N/A',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
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

void showBoxDetailsDialog(BuildContext context, Map<String, dynamic> boxDetails) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Box Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Box: ${boxDetails['box'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Packed By: ${boxDetails['packed_by'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Shipping Charge: ${boxDetails['shipping_charge'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Parcel Service: ${boxDetails['parcel_service'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Tracking ID: ${boxDetails['tracking_id'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Status: ${boxDetails['status'] ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Shipped Date: ${boxDetails['shipped_date'] ?? 'N/A'}'),
              SizedBox(height: 8),
              if (boxDetails['image'] != null)
                Image.network(
                  '$api${boxDetails['image']}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
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
        ],
      );
    },
  );
}
