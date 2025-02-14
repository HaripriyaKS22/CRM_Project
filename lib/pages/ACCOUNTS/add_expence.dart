import 'dart:convert';

import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';

import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/new_grv.dart';
import 'package:beposoft/pages/ACCOUNTS/profile.dart';
import 'package:beposoft/pages/ACCOUNTS/transfer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beposoft/main.dart';
import 'package:beposoft/pages/ACCOUNTS/add_credit_note.dart';
import 'package:beposoft/pages/ACCOUNTS/add_recipts.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/recipts_list.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_stock.dart';
import 'package:beposoft/pages/ACCOUNTS/credit_note_list.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/new_product.dart';
import 'package:beposoft/pages/ACCOUNTS/order_request.dart';
import 'package:beposoft/pages/ACCOUNTS/purchases_request.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_customer.dart';

class expence extends StatefulWidget {
  const expence({super.key});

  @override
  State<expence> createState() => _expenceState();
}

class _expenceState extends State<expence> {
  @override
  void initState() {
    super.initState();
    getbank();
    getcompany();
    getstaff();
  }

 String selectcompanyId = ""; 
  String selectpaybyId = ""; 
  String selectbankId = "";
  String selectbank = "";
  List<Map<String, dynamic>> bank = [];
  TextEditingController transactionid = TextEditingController();
  TextEditingController purposes = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController description = TextEditingController();

  String selectpayedby = "";
  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
   
  Future<void> getbank() async {
    final token = await gettokenFromPrefs();
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

  List<Map<String, dynamic>> company = [];

  Future<void> getcompany() async {
    try {
      final token = await gettokenFromPrefs();

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
          companylist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          company = companylist;
        });
      }
    } catch (error) {
      
    }
  }

  List<Map<String, dynamic>> sta = [];
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
  
      List<Map<String, dynamic>> stafflist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        
        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          stafflist.add({
            'id': productData['id'],
            'name': productData['name'],
            'allocated_states': productData['allocated_states']
          });
        }
        setState(() {
          sta = stafflist;
          
        });
      }
    } catch (error) {
      
    }
  }


void addexpense() async {
  
  final token = await gettokenFromPrefs();

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username'); 

    
    

    if (username == null) {
      
      return;
    }

    var response = await http.post(
      Uri.parse('$api/api/expense/add/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        "company": selectcompanyId.toString(),
        "payed_by": selectpaybyId.toString(),
        "bank": selectbankId.toString(),
        "purpose_of_payment": purposes.text,
        "amount": amount.text,
        "expense_date": formatDate(selectedDate), 
        "transaction_id": transactionid.text,
        "description": description.text,
        "added_by": username, 
      },
    );

    
    

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => expence()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 49, 212, 4),
          content: Text('Expense added successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to add expense. Please try again.'),
        ),
      );
    }
  } catch (e) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('An error occurred. Please try again.'),
      ),
    );
  }
}

DateTime selectedDate = DateTime.now();

// Function to format the DateTime to "YYYY-MM-DD"
String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
    });
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

  //searchable dropdown

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  String selectcomp = "";
Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(242, 255, 255, 255),
        appBar: AppBar(
          title: Text(
          "Add Expense",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
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
else {
    Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => dashboard()), // Replace AnotherPage with your target page
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
            Text(
              "EXPENCE ",
              style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 9.0,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                        top: 10,
                      ),
                      child: Container(
                        width: 600,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 2, 65, 96),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          border: Border.all(
                              color: Color.fromARGB(255, 2, 65, 96)),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              " New Expence ",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 13,
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                      Text("Select Company"),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9, // Adjust width
                              height: 49,
                              decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectcompanyId.isEmpty ? null : selectcompanyId,
                    hint: Text("Select Company"),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectcompanyId = newValue!;
                        
                      });
                    },
                    items: company.map<DropdownMenuItem<String>>(
                      (companyData) {
                        return DropdownMenuItem<String>(
                          value: companyData['id'].toString(),
                          child: Text(companyData['name']),
                        );
                      },
                    ).toList(),
                    icon: Container(
                      padding: EdgeInsets.only(left: 150),
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ],
                              ),
                            ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Amount",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 350,
                      child: TextField(
                        controller: amount,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: Icon(Icons.currency_rupee_sharp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8.0), // Set vertical padding
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Purpose Of Payment",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 350,
                      child: TextField(
                        controller: purposes,
                        decoration: InputDecoration(
                          labelText: 'Purpose',
                          prefixIcon: Icon(Icons.mail_lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 6.0), // Set vertical padding
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Payement Date",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 350, // Set the desired width here
                          height: 46, // Set the desired height here
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors
                                  .grey, // You can set the border color here
                              width:
                                  1.0, // You can adjust the border width here
                            ),
                            borderRadius: BorderRadius.circular(
                                8.0), // You can adjust the border radius here
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        Color.fromARGB(255, 116, 116, 116)),
                              ),
                              SizedBox(
                                width: 162,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _selectDate(context);
                                  
                                },
                                child: Icon(Icons.date_range),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
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
                    SizedBox(
                      height: 10,
                    ),
                    // Paid By Dropdown (Staff)
                            Text("Paid By"),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8, // Adjust width
                              height: 49,
                              decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectpaybyId.isEmpty ? null : selectpaybyId,
                    hint: Text("Select Paid By"),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectpaybyId = newValue!;
                        
                      });
                    },
                    items: sta.map<DropdownMenuItem<String>>((staffData) {
                      return DropdownMenuItem<String>(
                        value: staffData['id'].toString(),
                        child: Text(staffData['name']),
                      );
                    }).toList(),
                    icon: Container(
                      padding: EdgeInsets.only(left: 150),
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ],
                              ),
                            ),
              
                    SizedBox(
                      height: 10,
                    ),
                   Text("Bank Name"),
                           Container(
                width: MediaQuery.of(context).size.width * 0.8, // Adjust width
                height: 49,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10), // Adds padding inside the container
                  child: DropdownButtonHideUnderline( // Hides the default underline
                    child: DropdownButton<String>(
                      value: selectbankId.isEmpty ? null : selectbankId,
                      hint: Text("Select Bank"),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectbankId = newValue!;
                          
                        });
                      },
                      items: bank.map<DropdownMenuItem<String>>((bankData) {
                        return DropdownMenuItem<String>(
                          value: bankData['id'].toString(),
                          child: Text(bankData['name']),
                        );
                      }).toList(),
                      icon: Icon(Icons.arrow_drop_down), // Correctly positions the dropdown icon
                      isExpanded: true, // Ensures the dropdown covers the full width
                    ),
                  ),
                ),
              ),
              
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 1,
                          width: 350,
                          color: Color.fromARGB(255, 215, 201, 201),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Transaction Details",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Transaction Id",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 350,
                      child: TextField(
                        controller: transactionid,
                        decoration: InputDecoration(
                          labelText: '',
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Description",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 350,
                      child: TextField(
                        controller: description,
                        decoration: InputDecoration(
                          labelText: 'Enter Description',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8.0), // Set vertical padding
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 20,
                    ),
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
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        addexpense();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 244, 66, 66),
                        ),
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Set your desired border radius
                          ),
                        ),
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size(95, 15), // Set your desired width and heigh
                        ),
                      ),
                      child: Text("Submit",
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

}
