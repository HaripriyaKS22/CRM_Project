import 'dart:convert';

import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_credit_note.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_recipts.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/recipts_list.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beposoft/pages/api.dart';

class add_address extends StatefulWidget {
  const add_address({super.key, required this.customerid,required this.name});

  final int customerid;
  final name;
  @override
  State<add_address> createState() => _add_addressState();
}

class _add_addressState extends State<add_address> {
  double number = 0.00;
   late TextEditingController customer;
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();

  TextEditingController zipcode = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();

  TextEditingController country = TextEditingController();
  TextEditingController phone = TextEditingController();

  TextEditingController email = TextEditingController();
  List<Map<String, dynamic>> statess = [];
  List<Map<String, dynamic>> customers = [];

  String? selectstate;
  int? selectedStateId;
  String? selectedCustomerId;

  final TextEditingController _controller = TextEditingController();
  void incrementNumber() {
    setState(() {
      number +=
          0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      _controller.text = number.toStringAsFixed(2);
    });
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

  void decrementNumber() {
    setState(() {
      if (number >= 0.01) {
        number -=
            0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        _controller.text = number.toStringAsFixed(2);
      }
    });
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

  List<String> categories = ["Joishya", 'Hanvi', 'nimitha', 'Hari'];
  String selectededu = "Hari";
  // List<String> state = ["Kerala", 'Tamilnadu', 'Karnataka', 'Gujarat'];
  // String selectstate = "Kerala";

  @override
  void initState() {
    getstates();
    getcustomers();
      customer = TextEditingController(text: widget.name);
    super.initState();
    
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getcustomers() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/customers/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
    
      List<Map<String, dynamic>> customerlist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

    
        for (var productData in productsData) {
          customerlist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }

        setState(() {
          customers = customerlist;
      

          // After fetching customers, set the customer name and ID
          setCustomerName();
        });
      }
    } catch (error) {
      
    }
  }

  void setCustomerName() {
    // Find the customer with the matching ID
    final selectedCustomer = customers.firstWhere(
      (customer) => customer['id'] == widget.customerid,
      orElse: () => {},
    );

    // If a matching customer is found, set the name in the text field and save the customer ID
    if (selectedCustomer.isNotEmpty) {
      customer.text = selectedCustomer['name'];
      selectedCustomerId =
          selectedCustomer['id'].toString(); // Store the customer ID

          
    }
  }

  Future<void> getstates() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/states/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
   
      List<Map<String, dynamic>> stateslist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

      
        for (var productData in productsData) {
          stateslist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          statess = stateslist;

          
        });
      }
    } catch (error) {
      
    }
  }

  void addaddress(
    String name,
    String address,
    String email,
    String phone,
    String zipcode,
    String city,
    String state,
    String country,
    BuildContext scaffoldContext,
  ) async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.post(
        
        Uri.parse('$api/api/add/customer/address/${widget.customerid}/'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "customer": widget.customerid,
          "name": name,
          "address": address,
          "zipcode": zipcode,
          "city": city,
          "state": selectedStateId,
          "country": country,
          "phone": phone,
          "email": email,
        }),
      );

      

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
                        backgroundColor: Colors.green,

            content: Text('Address added Successfully.'),
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=>add_address(customerid:widget.customerid,name:widget.name)));
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Adding address failed.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Enter valid information'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(
         title: Text(
          "Add Address",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Custom back arrow
          onPressed: () async{
            Navigator.push(context, MaterialPageRoute(builder: (context)=>customer_list()));
                       
          },
        ),
        actions: [
          
          IconButton(
            icon: Image.asset('lib/assets/profile.png'),
            onPressed: () {

            },
          ),
        ],
      ),
     
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, left: 12, right: 12),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 95),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Add Address",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  height: 230,
                  width: 340,
                  child: Card(
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                            color: Color.fromARGB(255, 236, 236, 236)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   "Customer ",
                            //   style: TextStyle(
                            //       fontSize: 15, fontWeight: FontWeight.bold),
                            // ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            // Container(
                            //   width: 310,
                            //   height: 49,
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey),
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Expanded(
                            //         child: Container(
                            //           child: Row(
                            //             children: [
                            //               Expanded(
                            //                 child: TextField(
                            //                   controller: _controller,
                            //                   keyboardType: TextInputType
                            //                       .numberWithOptions(
                            //                           decimal: true),
                            //                   decoration: InputDecoration(
                            //                     prefixIcon:
                            //                         Icon(Icons.line_weight),
                            //                     border: InputBorder.none,
                            //                     hintText: '',
                            //                     // Adjust horizontal padding
                            //                   ),
                            //                   onChanged: (value) {
                            //                     setState(() {
                            //                       number =
                            //                           double.tryParse(value) ??
                            //                               0.00;
                            //                     });
                            //                   },
                            //                 ),
                            //               ),
                            //               Container(
                            //                 width: 30,
                            //                 color: Color.fromARGB(
                            //                     255, 88, 184, 248),
                            //                 child: IconButton(
                            //                   icon: Icon(
                            //                       Icons
                            //                           .keyboard_arrow_down_rounded,
                            //                       size: 20,
                            //                       color: Colors
                            //                           .white), // Down arrow icon with size 20
                            //                   onPressed: decrementNumber,
                            //                 ),
                            //               ),
                            //               Container(
                            //                 width: 30,
                            //                 decoration: BoxDecoration(
                            //                     color: Color.fromARGB(
                            //                         255, 64, 176, 251),
                            //                     border: Border.all(
                            //                         color: Color.fromARGB(
                            //                             255, 64, 176, 251)),
                            //                     borderRadius: BorderRadius.only(
                            //                         bottomRight:
                            //                             Radius.circular(10),
                            //                         topRight:
                            //                             Radius.circular(10))),
                            //                 child: IconButton(
                            //                   icon: Icon(
                            //                       Icons
                            //                           .keyboard_arrow_up_rounded,
                            //                       size: 20,
                            //                       color: Colors
                            //                           .white), // Up arrow icon with size 20
                            //                   onPressed: incrementNumber,
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // Text("Customer Name",
                            //     style: TextStyle(
                            //         fontSize: 15, fontWeight: FontWeight.bold)),
                            // SizedBox(height: 10),
                            TextField(
                              controller: customer,
                              decoration: InputDecoration(
                                labelText: 'Customer Name',
                                prefixIcon: Icon(Icons.local_offer),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Shipping Address Name",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextField(
                              controller: name,
                              decoration: InputDecoration(
                                labelText: 'name',
                                prefixIcon: Icon(Icons.local_offer),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  height: 650,
                  width: 340,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                            color: Color.fromARGB(255, 236, 236, 236)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text("Address/Building Name/ Building Number ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 13),
                            TextField(
                              controller: address,
                              decoration: InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Zip code",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 10),
                                    Container(
                                      width: 144,
                                      child: TextField(
                                        controller: zipcode,
                                        decoration: InputDecoration(
                                          labelText: 'Zip code',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 13,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("City",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 10),
                                    Container(
                                      width: 144,
                                      child: TextField(
                                        controller: city,
                                        decoration: InputDecoration(
                                          labelText: 'City',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Text("State *:",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Container(
                              width:
                                  double.infinity, // Use full width available
                              height: 49,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          10), // Adjust padding as needed
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Map<String, dynamic>>(
                                    value: statess.isNotEmpty
                                        ? statess.firstWhere(
                                            (element) =>
                                                element['name'] == selectstate,
                                            orElse: () => statess[0],
                                          )
                                        : null,
                                    onChanged: statess.isNotEmpty
                                        ? (Map<String, dynamic>? newValue) {
                                            setState(() {
                                              selectstate = newValue!['name'];
                                              selectedStateId = newValue[
                                                  'id']; // Store the selected state's ID
                                            
                                            });
                                          }
                                        : null,
                                    items: statess.isNotEmpty
                                        ? statess.map<
                                            DropdownMenuItem<
                                                Map<String, dynamic>>>(
                                            (Map<String, dynamic> state) {
                                              return DropdownMenuItem<
                                                  Map<String, dynamic>>(
                                                value: state,
                                                child: Text(state['name']),
                                              );
                                            },
                                          ).toList()
                                        : [
                                            DropdownMenuItem(
                                              child:
                                                  Text('No states available'),
                                              value: null,
                                            ),
                                          ],
                                    icon: Icon(Icons.arrow_drop_down),
                                    isExpanded:
                                        true, // Ensure dropdown takes full width
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text("Country ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextField(
                              controller: country,
                              decoration: InputDecoration(
                                labelText: 'Country',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 1,
                                  width: 300,
                                  color: Color.fromARGB(255, 215, 201, 201),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text("Phone Number * : ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextField(
                              controller: phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Mail Id : ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextField(
                              controller: email,
                              decoration: InputDecoration(
                                labelText: 'Mail Id',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 1,
                      width: 300,
                      color: Color.fromARGB(255, 215, 201, 201),
                    ),
                  ],
                ),
                SizedBox(height: 13),
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      SizedBox(width: 13),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () {
                            addaddress(
                             
                              name.text,
                              address.text,
                              email.text,
                              phone.text,
                              zipcode.text,
                              city.text,
                              state.text,
                              country.text,
                              context,
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue,
                            ),
                            shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            fixedSize: MaterialStateProperty.all<Size>(
                              Size(95, 15),
                            ),
                          ),
                          child: Text("Submit",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSelectedPage(BuildContext context, String selectedOption) {
    switch (selectedOption) {
      case 'Option 1':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_credit_note()),
        );
        break;
      case 'Option 2':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => customer_list()),
        );
        break;
      case 'Option 3':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_receipts()),
        );
        break;
      case 'Option 4':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;
      case 'Option 5':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;
      case 'Option 6':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;
      case 'Option 7':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;
      case 'Option 8':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;

      default:
        break;
    }
  }
}