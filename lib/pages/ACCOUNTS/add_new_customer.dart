import 'dart:convert';

import 'package:beposoft/functions.dart';
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ADMIN/admin_dashboard.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class add_new_customer extends StatefulWidget {
  const add_new_customer({super.key});

  @override
  State<add_new_customer> createState() => _add_new_customerState();
}

class _add_new_customerState extends State<add_new_customer> {

  List<Map<String, dynamic>> manager = [];
  List<Map<String, dynamic>> statess = [];

  String? selectedManagerName;
  int? selectedManagerId;
  String? selectstate;
  int? selectedStateId;

  List<String> categories = ["customer", "warehouse"];
String selectedCategory = "customer"; // Default value

  TextEditingController gstno = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController altphone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController zipcode = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController states = TextEditingController();
  TextEditingController comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
   
    
  }
var tok;
var id;
  Functions functions= Functions();
Future<void> _initData() async {
         tok = await functions.gettokenFromPrefs(); 
         id= await functions.getidFromPrefs();
selectedManagerId=id;
        
         getmanagers();
        getprofiledata();
  }
var allocatedstates;

 Future<void> getprofiledata() async {
    try {

      var response = await http.get(
        Uri.parse("$api/api/profile/"),
        headers: {
          'Authorization': 'Bearer $tok',
          'Content-Type': 'application/json',
        },
      );
print("response.body profileeeeeeeeeeeeeeeeeeeeeeee${response.body}");
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        setState(() {
          
          allocatedstates=productsData['allocated_states'];
          print("allovatedstatesallovatedstatesallovatedstates$allocatedstates");
        });
                getstates();

      }
    } catch (error) {}
  }
  void addcustomer(
      String gstno,
      String name,
      String selectedManagerId,
      String selectedStateId,
      String phone,
      String altphone,
      String email,
      String address,
      String zipcode,
      String city,
      String states,
      String comment,
      BuildContext scaffoldContext) async {
    try {

      var response = await http.post(
        Uri.parse('$api/api/add/customer/'),
        headers: {
          'Authorization': 'Bearer $tok',
          "Content-Type": "application/json"},
        body: jsonEncode({
          "gst": gstno,
          "name": name,
          "manager": selectedManagerId,
          "state": selectedStateId,
          "phone": phone,
          "alt_phone": altphone,
          "email": email,
          "address": address,
          "zip_code": zipcode,
          "city": city,
          "comment": comment,
          "customer_status":selectedCategory
        }),
      );

  print(response.body)   ;
  print(response.statusCode) ;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Customer Added Successfully.'),
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=>add_new_customer()));
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Adding Customer failed.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('An error occurred.'),
        ),
      );
    }
  }

  // Future<String?> gettokenFromPrefs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('token');
  // }
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

  Future<void> getmanagers() async {
    try {
     

      var response = await http.get(
        Uri.parse('$api/api/staffs/'),
        headers: {
          'Authorization': 'Bearer $tok',
          'Content-Type': 'application/json',
        },
      );
  
      List<Map<String, dynamic>> managerlist = [];

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

  Future<void> getstates() async {
    try {

      var response = await http.get(
        Uri.parse('$api/api/states/'),
        headers: {
          'Authorization': 'Bearer $tok',
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
        print("allocatedstatesallocatedstatesallocatedstates$allocatedstates");
        // Filter to keep only allocated states
        if(allocatedstates.isNotEmpty){
      List<Map<String, dynamic>> filteredStates = stateslist
          .where((state) => allocatedstates.contains(state['id']))
          .toList();
        setState(() {
          statess = filteredStates;

          print("statessstatessstatess$statess");
        });}
        else{
          setState(() {
            
          statess = stateslist;
          });
        }
      }
    } catch (error) {
      
    }
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

  String selectededu = "Hari";
  List<String> state = [
    "Kerala",
    'Tamilnadu',
    'Karnataka',
    'Gujarat',
  ];
  Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
  // String selectstate = "Kerala";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          "Add Customer",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Custom back arrow
          onPressed: () async {
            final dep = await getdepFromPrefs();
            if (dep == "BDO") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        bdo_dashbord()), // Replace AnotherPage with your target page
              );
            } else if (dep == "BDM") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        bdm_dashbord()), // Replace AnotherPage with your target page
              );
            }

            else if (dep == "ADMIN") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        admin_dashboard()), // Replace AnotherPage with your target page
              );
            }
            
            
            else {
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
        child: Padding(
          padding: const EdgeInsets.only(top: 30, left: 12, right: 12),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 75),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Add New Customer ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
               SizedBox(
  height: 400, // Increased height to accommodate new dropdown
  width: 340,
  child: Card(
    elevation: 4,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Color.fromARGB(255, 236, 236, 236)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New Dropdown added here
            Text(
              "Select Type",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child:DropdownButton<String>(
  value: categories.contains(selectedCategory) ? selectedCategory : null, // Ensure valid selection
  isExpanded: true,
  underline: SizedBox(),
  onChanged: (String? newValue) {
    setState(() {
      selectedCategory = newValue!;
    });
  },
  items: categories.map<DropdownMenuItem<String>>((String category) {
    return DropdownMenuItem<String>(
      value: category,
      child: Text(category),
    );
  }).toList(),
  icon: Icon(Icons.arrow_drop_down),
),

            ),

            SizedBox(height: 15),

            Text(
              "GSTIN Number",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: gstno,
              decoration: InputDecoration(
                labelText: 'AAA00',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Name of Customer",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: 'Name of customer',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Technical Manager",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              width: 310,
              height: 49,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Flexible(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 1),
                      ),
                      child: DropdownButton<Map<String, dynamic>>(
                        value: manager.isNotEmpty
                            ? manager.firstWhere(
                                (element) => element['id'] == selectedManagerId,
                                orElse: () => manager[0],
                              )
                            : null,
                        underline: Container(),
                        onChanged: manager.isNotEmpty
                            ? (Map<String, dynamic>? newValue) {
                                setState(() {
                                  selectedManagerName = newValue!['name'];
                                  selectedManagerId = newValue['id'];
                                });
                              }
                            : null,
                        items: manager.isNotEmpty
                            ? manager.map<DropdownMenuItem<Map<String, dynamic>>>(
                                (Map<String, dynamic> manager) {
                                  return DropdownMenuItem<Map<String, dynamic>>(
                                    value: manager,
                                    child: Text(manager['name']),
                                  );
                                },
                              ).toList()
                            : [
                                DropdownMenuItem(
                                  child: Text('No managers available'),
                                  value: null,
                                ),
                              ],
                        icon: Container(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),


                SizedBox(height: 5),
                // SizedBox(
                //   height: 200,
                //   width: 340,
                //   child: Card(
                //     elevation: 3,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10.0),
                //     ),
                //     child: Container(
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(10.0),
                //         border: Border.all(
                //             color: Color.fromARGB(255, 236, 236, 236)),
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.all(10.0),
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text("Administrative information ",
                //                 style: TextStyle(
                //                     fontSize: 15, fontWeight: FontWeight.bold)),
                //             SizedBox(height: 20),
                //             TextField(
                //               decoration: InputDecoration(
                //                 labelText: 'Naf code',
                //                 border: OutlineInputBorder(
                //                   borderRadius: BorderRadius.circular(10.0),
                //                   borderSide: BorderSide(color: Colors.grey),
                //                 ),
                //                 contentPadding:
                //                     EdgeInsets.symmetric(vertical: 8.0),
                //               ),
                //             ),
                //             SizedBox(height: 10),
                //             TextField(
                //               decoration: InputDecoration(
                //                 labelText: 'VAT number',
                //                 border: OutlineInputBorder(
                //                   borderRadius: BorderRadius.circular(10.0),
                //                   borderSide: BorderSide(color: Colors.grey),
                //                 ),
                //                 contentPadding:
                //                     EdgeInsets.symmetric(vertical: 8.0),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 15),
                // Continue adding form elements here
                SizedBox(height: 15),
                SizedBox(
                  height: 690,
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
                            Text("Client information ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            // Text("Discount : ",
                            //     style: TextStyle(
                            //         fontSize: 15, fontWeight: FontWeight.bold)),
                            // SizedBox(height: 10),
                            // TextField(
                            //   decoration: InputDecoration(
                            //     labelText: 'Discount ',
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(10.0),
                            //       borderSide: BorderSide(color: Colors.grey),
                            //     ),
                            //     contentPadding:
                            //         EdgeInsets.symmetric(vertical: 8.0),
                            //   ),
                            // ),
                            // SizedBox(height: 10),
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
                            Text("Alternate Number : ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextField(
                              controller: altphone,
                              decoration: InputDecoration(
                                labelText: 'Alternate Number',
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
  width: double.infinity, // Use full width available
  height: 49,
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(10),
  ),
  child: InputDecorator(
    decoration: InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 10), // Adjust padding as needed
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<Map<String, dynamic>>(
        value: statess.isNotEmpty
            ? statess.firstWhere(
                (element) => element['name'] == selectstate,
                orElse: () => statess[0],
              )
            : null,
        onChanged: statess.isNotEmpty
            ? (Map<String, dynamic>? newValue) {
                setState(() {
                  selectstate = newValue!['name'];
                  selectedStateId = newValue['id']; // Store the selected state's ID
                  
                  
                });
              }
            : null,
        items: statess.isNotEmpty
            ? statess.map<DropdownMenuItem<Map<String, dynamic>>>(
                (Map<String, dynamic> state) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: state,
                    child: Text(state['name']),
                  );
                },
              ).toList()
            : [
                DropdownMenuItem(
                  child: Text('No states available'),
                  value: null,
                ),
              ],
        icon: Icon(Icons.arrow_drop_down),
        isExpanded: true, // Ensure dropdown takes full width
      ),
    ),
  ),
),

                            // SizedBox(height: 20),
                            // Text("Country ",
                            //     style: TextStyle(
                            //         fontSize: 15, fontWeight: FontWeight.bold)),
                            // SizedBox(height: 10),
                            // TextField(
                            //   decoration: InputDecoration(
                            //     labelText: 'Country',
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(10.0),
                            //       borderSide: BorderSide(color: Colors.grey),
                            //     ),
                            //     contentPadding:
                            //         EdgeInsets.symmetric(vertical: 8.0),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  height: 150,
                  width: 340,
                  child: Card(
                    elevation: 3,
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
                            Text("Comment ",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            TextField(
                              controller: comment,
                              decoration: InputDecoration(
                                labelText: 'Enter',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                              maxLines: null,
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
                  padding: const EdgeInsets.only(left: 120),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Your onPressed logic goes here
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 164, 164, 164),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(85, 15),
                          ),
                        ),
                        child: Text("Close",
                            style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 13),
                     ElevatedButton(
  onPressed: () {
    if (selectedManagerId != null && selectedStateId != null) {
      addcustomer(
        gstno.text,
        name.text,
        selectedManagerId!.toString(),
        selectedStateId!.toString(),
        phone.text,
        altphone.text,
        email.text,
        address.text,
        zipcode.text,
        city.text,
        states.text,
        comment.text,
        context,
      );
    } else {
      // Show an error message if either ID is null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please select both manager and state.'),
        ),
      );
    }
  },
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(
      Color.fromARGB(255, 244, 66, 66),
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    fixedSize: MaterialStateProperty.all<Size>(
      Size(95, 15),
    ),
  ),
  child: Text("Submit", style: TextStyle(color: Colors.white)),
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


}