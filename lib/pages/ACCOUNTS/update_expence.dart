import 'dart:convert';

import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/expense_list.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
import 'package:beposoft/pages/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Expense_Update extends StatefulWidget {
  final id;
  const Expense_Update({super.key, required this.id});

  @override
  State<Expense_Update> createState() => _Expense_UpdateState();
}

class _Expense_UpdateState extends State<Expense_Update> {
  List<Map<String, dynamic>> expensedata = [];
  List<Map<String, dynamic>> bank = [];
  List<Map<String, dynamic>> company = [];
  List<Map<String, dynamic>> sta = [];

  String selectcompanyId = "";
  String selectpaybyId = "";
  String LoanId = "";
  String selectbankId = "";
  TextEditingController transactionid = TextEditingController();
  TextEditingController purposes = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController description = TextEditingController();

  DateTime selectedDate = DateTime.now();

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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

  @override
  void initState() {
    super.initState();
    getExpenseList();
    getbank();
    getcompany();
    getstaff();
    getemi();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
var selectedExpense;
Future<void> getExpenseList() async {
  print('Fetching expense list for ID: ${widget.id}');
  try {
    final token = await gettokenFromPrefs();
    final response = await http.get(
      Uri.parse('$api/api/expense/add/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);

      if (parsed is Map && parsed.containsKey('data')) {
        List<Map<String, dynamic>> expenselist = List<Map<String, dynamic>>.from(parsed['data']);

        // Find the selected expense
       
        for(int i=0;i<expenselist.length;i++){
          print('Expense ID: ${expenselist[i]['id']}  == ${widget.id}' );
          var expenseid=expenselist[i]['id'].toString();
          var id=widget.id.toString();

          print('Expense ID: $expenseid  == $id' );
          if(id==expenseid){
                      print('innnnnnnnnnnnnnnnnnnr ${expenselist[i]['id']}  == ${widget.id}' );

            selectedExpense=expenselist[i];
          }
        }

        print('Selected Expense: $selectedExpense');

        // Ensure selectedExpense is valid before updating UI
        if (selectedExpense.isNotEmpty && mounted) {
          setState(() {
            transactionid.text = selectedExpense['transaction_id']?.toString() ?? '';
            purposes.text = selectedExpense['purpose_of_payment'] ?? '';
            LoanId = selectedExpense['loan']?.toString() ?? '';
            amount.text = selectedExpense['amount']?.toString() ?? '';
            description.text = selectedExpense['description'] ?? '';
            selectcompanyId = selectedExpense['company']?['id']?.toString() ?? '';
            selectpaybyId = selectedExpense['payed_by']?['id']?.toString() ?? '';
            selectbankId = selectedExpense['bank']?['id']?.toString() ?? '';
            selectedDate = selectedExpense['expense_date'] != null
                ? DateTime.tryParse(selectedExpense['expense_date']) ?? DateTime.now()
                : DateTime.now();
          });
        }
        print("LoanIddddddddddddddddddd$LoanId");

      } else {
        print('Error: "data" key not found in response');
      }
    } else {
      print('Error fetching expenses: ${response.statusCode}');
    }
  } catch (error) {
    print('Error getting expense list: $error');
  }
}
 List<Map<String, dynamic>> emiList = [];

    Future<void> getemi() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/apis/emi/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      List<Map<String, dynamic>> emiDataList = [];
      print(response.statusCode);
      print("emiiiiiiiiiiiiiiiiiiiiiiiiiiiiii${response.body}");
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          emiDataList.add({
            'id': productData['id'],
            'emi_name': productData['emi_name'],
            'emi': productData['emi'],
            'principal': productData['principal'],
            'annual_interest_rate': productData['annual_interest_rate'],
            'tenure_months': productData['tenure_months'],
            'down_payment': productData['down_payment'],
          });
        }
        setState(() {
          emiList = emiDataList;
          print("emiList$emiList");
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  Future<void> getbank() async {
    final token = await gettokenFromPrefs();
    try {
      final response = await http.get(
        Uri.parse('$api/api/banks/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
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

  Future<void> getcompany() async {
  try {
    final token = await gettokenFromPrefs();
    var response = await http.get(
      Uri.parse('$api/api/company/data/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    List<Map<String, dynamic>> companylist = [];
    print("Company response: ${response.body}");

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['data'];

      for (var productData in productsData) {
        companylist.add({
          'id': productData['id'],
          'name': productData['name'],
        });
      }
      setState(() {
        company = companylist;
      });
      print("Company list: $company");
    } else {
      print("Failed to fetch company data: ${response.statusCode}");
    }
  } catch (error) {
    print("Error fetching company data: $error");
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
      List<Map<String, dynamic>> stafflist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
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
Future<void> updatexpense() async {
  try {
    final token = await gettokenFromPrefs();
      SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username'); 

    
    

    if (username == null) {
      
      return;
    }


    var response = await http.put(
      Uri.parse('$api/api/expense/get/${widget.id}/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'transaction_id': transactionid.text,
        'purpose_of_payment': purposes.text,
        'amount': amount.text,
        'expense_date': formatDate(selectedDate), // Convert DateTime to String
        'description': description.text,
        'company': selectcompanyId,
        'payed_by': selectpaybyId,
        'bank': selectbankId,
        "added_by": username, 

      }),
    );

    
    

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => expence_list()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update expense'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (error) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating expense'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

  // _navigateToSelectedPage method
  void _navigateToSelectedPage(BuildContext context, String selectedOption) {
    switch (selectedOption) {
      case 'Credit Note':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => credit_note_list()),
        );
        break;
      case 'Customer':
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => customer_list()),
        // );
        break;
      case 'Add Receipts':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_receipts()),
        );
        break;
      case 'Receipts List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => receips()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(
         title: Text(
            'Update Expense',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
            Navigator.pop(context);
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
                          Padding(
                            padding: const EdgeInsets.only(right: 10, top: 10),
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
                                  SizedBox(height: 10),
                                  Text(
                                    "Update Expense",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  SizedBox(height: 13),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text("Select Company"),
                         Container(
  width: MediaQuery.of(context).size.width * 0.9, // Adjust width
  height: 49, // Set the desired height
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Row(
    children: [
      SizedBox(width: 20), // Padding on the left for better alignment
      Expanded(  // Wrap DropdownButton with Expanded
        child: DropdownButton<String>(
          value: selectcompanyId.isEmpty ? null : selectcompanyId,
          hint: Text("Select Company"),
          onChanged: (String? newValue) {
            setState(() {
              selectcompanyId = newValue!;
              
            });
          },
          items: company.map<DropdownMenuItem<String>>((companyData) {
            return DropdownMenuItem<String>(
              value: companyData['id'].toString(),
              child: Text(companyData['name']),
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

                          SizedBox(height: 10),
                          TextField(
                            controller: amount,
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              prefixIcon: Icon(Icons.currency_rupee_sharp),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: purposes,
                            decoration: InputDecoration(    
                              labelText: 'Purpose',
                              prefixIcon: Icon(Icons.mail_lock),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),

if(purposes.text=="emi")
                          SizedBox(height: 10),
                          if(purposes.text=="emi")

                          Text("Emi Plan"),
                          if(purposes.text=="emi")

if (emiList.isNotEmpty)
  Container(
    width: MediaQuery.of(context).size.width * 0.9, // Adjust width
    height: 49, // Set the desired height
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        SizedBox(width: 20), // Padding on the left for better alignment
        Expanded(  // Wrap DropdownButton with Expanded
          child: DropdownButton<String>(
            value: LoanId.isEmpty ? null : LoanId,
            hint: Text("Emi Plan"),
            onChanged: (String? newValue) {
              setState(() {
                LoanId = newValue!;
              });
            },
            items: emiList.map<DropdownMenuItem<String>>((emiData) {
              return DropdownMenuItem<String>(
                value: emiData['id'].toString(),
                child: Text(emiData['emi_name'] ?? 'Unknown'),
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

                          SizedBox(height: 10),
                         Text("Payment Date"),
GestureDetector(
  onTap: () {
    _selectDate(context);  // Open the date picker when tapped
  },
  child: Container(
    width: 350,
    height: 46,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Row(
      children: [
        SizedBox(width: 30),  // Left padding for alignment
        Text(
          // Display the selected date in dd/MM/yyyy format
          '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',

          style: TextStyle(
            fontSize: 15,
            color: Color.fromARGB(255, 116, 116, 116),
          ),
        ),
        
        SizedBox(width: 162),  // Spacing to right-align the icon
        Icon(Icons.date_range),  // Date picker icon
      ],
    ),
  ),
),

                          SizedBox(height: 20),
                          TextField(
                            controller: transactionid,
                            decoration: InputDecoration(
                              labelText: 'Transaction Id',
                              prefixIcon: Icon(Icons.mail_lock),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: description,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.mail_lock),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text("Paid By"),
                          Container(
                            width: MediaQuery.of(context).size.width *
                                0.9, // Adjust width
                            height: 49, // Set the desired height
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey), // Border color
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                    width:
                                        20), // Padding on the left for better alignment
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: selectpaybyId.isEmpty
                                        ? null
                                        : selectpaybyId,
                                    hint: Text("Select Paid By"),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectpaybyId = newValue!;
                                      
                                      });
                                    },
                                    items: sta.map<DropdownMenuItem<String>>(
                                        (staffData) {
                                      return DropdownMenuItem<String>(
                                        value: staffData['id'].toString(),
                                        child: Text(staffData['name']),
                                      );
                                    }).toList(),
                                    icon: Container(
                                      padding: EdgeInsets.only(
                                          left:
                                              150), // Adjusts the position of the dropdown icon
                                      alignment: Alignment
                                          .centerRight, // Right-aligns the icon
                                      child: Icon(Icons.arrow_drop_down),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text("Bank Name"),
                          Container(
                            width: MediaQuery.of(context).size.width *
                                0.9, // Adjust width
                            height: 49, // Set the desired height
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey), // Border color
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                    width:
                                        20), // Padding on the left for better alignment
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: selectbankId.isEmpty
                                        ? null
                                        : selectbankId,
                                    hint: Text("Select Bank"),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectbankId = newValue!;
                                     
                                      });
                                    },
                                    items: bank.map<DropdownMenuItem<String>>(
                                        (bankData) {
                                      return DropdownMenuItem<String>(
                                        value: bankData['id'].toString(),
                                        child: Text(bankData['name']),
                                      );
                                    }).toList(),
                                    icon: Container(
                                      padding: EdgeInsets.only(
                                          left:
                                              150), // Adjusts the position of the dropdown icon
                                      alignment: Alignment
                                          .centerRight, // Right-aligns the icon
                                      child: Icon(Icons.arrow_drop_down),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              updatexpense();
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
                                Size(
                                    95, 15), // Set your desired width and heigh
                              ),
                            ),
                            child: Text("Update",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
