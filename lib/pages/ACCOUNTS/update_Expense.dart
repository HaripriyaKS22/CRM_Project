
import 'dart:convert';

import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/expense_list.dart';
import 'package:beposoft/pages/ACCOUNTS/update_department.dart';
import 'package:beposoft/pages/ACCOUNTS/update_family.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:beposoft/main.dart';
import 'package:beposoft/pages/ACCOUNTS/add_credit_note.dart';
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
import 'package:beposoft/pages/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class update_expence extends StatefulWidget {
  final id;
  const update_expence({super.key,required this.id});

  @override
  State<update_expence> createState() => _update_expenceState();
}

class _update_expenceState extends State<update_expence> {
 @override
  void initState() {
    super.initState();
initdata();
    getcompany();
    getstaff();
    getbank();
  }
void initdata() async {
    await getexpenselist();
  }
var url = "$api/api/add/department/";
 TextEditingController transactionid = TextEditingController();
  TextEditingController purposes = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController description = TextEditingController();
int? selectedCompanyId;
  TextEditingController name = TextEditingController();
Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
var departments;
  List<Map<String, dynamic>> fam = [];
    List<Map<String, dynamic>> bank = [];
String? selectedpurpose; // Holds the selected value
  final List<String> items = ['water', 'electricity','salary','emi','rent','travel','Others'];

 String selectedstaff='';
    int? selectedstaffId;
        int? selectedbankId;
  Future<void> getbank() async{
  final token=await gettokenFromPrefs();
  try{
    final response= await http.get(Uri.parse('$api/api/banks/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    }
    );
    List<Map<String, dynamic>> banklist = [];
        

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        
        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          banklist.add({
            'id': productData['id'],
            'name': productData['name'],
            'branch':productData['branch']
            
          });
        
        }
        setState(() {
          bank = banklist;
                  

          
        });
      }

  }
  catch(e){
    
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
          });
        }
        setState(() {
          sta = stafflist;
          
        });
      }
    } catch (error) {
      
    }
  }

  void getCurrentTime() {
  // Get current date and time
  DateTime now = DateTime.now();

  // Format the time (e.g., HH:mm:ss)
  String formattedTime = DateFormat('HH:mm:ss').format(now);

  
}
  void removeProduct(int index) {
    setState(() {
      fam.removeAt(index);
    });
  }
 String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
        

 Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
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
        final Data = jsonDecode(response.body);
final productsData=Data['data'];
        
        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
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
DateTime selectedDate = DateTime.now();

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
       // This prints the formatted date
    });
  }
}
String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}







Future<void> getexpenselist() async {
  try {
    final token = await gettokenFromPrefs();
    var response = await http.get(
      Uri.parse('$api/api/expense/add/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    List<Map<String, dynamic>> expenselist = [];
    

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      final productsData = parsed['data'];

      for (var productData in productsData) {
        // Parse the expense_date string into a DateTime object
        DateTime expenseDate = DateTime.parse(productData['expense_date']);
        
        expenselist.add({
          'id': productData['id'],
          'purpose_of_payment': productData['purpose_of_payment'],
          'amount': productData['amount'],
          'expense_date': expenseDate, // Store as DateTime
          'transaction_id': productData['transaction_id'],
          'description': productData['description'],
          'added_by': productData['added_by'],
          'company': productData['company'], // Handle as a map or ID
          'payed_by': productData['payed_by'], // Handle as a map or ID
          'bank': productData['bank'], // Handle as a map or ID
        });
      }

    final selectedExpense = expenselist.firstWhere(
  (expense) => expense['id'] == widget.id,
  orElse: () => {}, // Return an empty map instead of null
);
      if (selectedExpense != null) {
        setState(() {
          transactionid.text = selectedExpense['transaction_id']?.toString() ?? '';
          purposes.text = selectedExpense['purpose_of_payment'] ?? '';
          amount.text = selectedExpense['amount']?.toString() ?? '';
          description.text = selectedExpense['description'] ?? '';

          // Parse nested objects (if necessary)
          selectedCompanyId = selectedExpense['company']?['id'] as int? ?? selectedExpense['company'] as int?;
          
          selectedstaffId = selectedExpense['payed_by']?['id'] as int? ?? selectedExpense['payed_by'] as int?;
          
          selectedbankId = selectedExpense['bank']?['id'] as int? ?? selectedExpense['bank'] as int?;
          
          selectedDate = selectedExpense['expense_date']; // Should already be DateTime
        });
      }
    } else {
      
    }
  } catch (error) {
    
  }
}


void updateexpense() async {
  
  final token = await gettokenFromPrefs();

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username'); 

    
    

    if (username == null) {
      
      return;
    }

    var response = await http.put(
      Uri.parse('$api/api/expense/get/${widget.id}/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        "company": selectedCompanyId.toString(),
        "payed_by": selectedstaffId.toString(),
        "bank": selectedbankId.toString(),
        "purpose_of_payment": selectedpurpose,
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
        MaterialPageRoute(builder: (context) => expence_list()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 49, 212, 4),
          content: Text('Expense Updated successfully'),
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
                   Navigator.pop(context);
           
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
 
        body: LayoutBuilder(
  builder: (context, constraints) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 15),
           
            Padding(
  padding: EdgeInsets.symmetric(horizontal: 1),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
    ),
    width: constraints.maxWidth * 0.9,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: constraints.maxWidth * 0.9,
            decoration: BoxDecoration(
              color:const Color.fromARGB(255, 2, 65, 96),
              border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
            ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "New Expence",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 13),
              ],
            ),
          ),
              Padding(
  padding: const EdgeInsets.only(right: 10),
  child: Column(
    children: [
      SizedBox(height: 10,),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: DropdownButton<int>(
          isExpanded: true,
          underline: SizedBox(), // Removes default underline
          hint: Text('Select a company',style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),),
          value: selectedCompanyId,
          items: company.map((item) {
            return DropdownMenuItem<int>(
              value: item['id'],
              child: Text(item['name']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCompanyId = value;
            });
            
          },
        ),
      ),
     
    ],
  ),
),

          Text(
            "Amount",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          SizedBox(height: 5),
          Container(
            child: TextField(
              controller: amount,
              
              decoration: InputDecoration(
                labelText: 'Amount',
                                hintText: amount.text.isNotEmpty ? amount.text : 'Enter your amount',

                labelStyle: TextStyle(
        fontSize: 13.0, // Adjust the font size as needed
      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ),
                    SizedBox(height: 5),

          Text(
            "Purpose Of Payment",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          SizedBox(height: 5),
     Container(
  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: .0),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.circular(10.0),
  ),
  child: DropdownButton<String>(
    value: selectedpurpose,
    hint: Text('Select an option'),
    isExpanded: true,
    underline: SizedBox(), // Removes the default underline
    items: items.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );
    }).toList(),
    onChanged: (String? newValue) {
      setState(() {
        selectedpurpose = newValue;
      });
    },
  ),
),


          SizedBox(
                      height: 5,
                    ),
           Text(
                      "Payment Date",
                      style: TextStyle(
                          fontSize: 13, ),
                    ),
                    SizedBox(
                      height: 5,
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
                      height: 5,
                    ),
           Text(
                      "Paid By",
                      style: TextStyle(
                          fontSize: 13, ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

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
            hintText: '',
            contentPadding: EdgeInsets.symmetric(horizontal: 1),
          ),
          child: DropdownButton<Map<String, dynamic>>(
  value: sta.isNotEmpty
      ? sta.firstWhere(
          (element) => element['id'] == selectedstaffId,
          orElse: () => {'id': null, 'name': 'Select a Staff'}, // Default value
        )
      : null,
  underline: Container(),
  onChanged: sta.isNotEmpty
      ? (Map<String, dynamic>? newValue) {
          setState(() {
            selectedstaffId = newValue?['id']; // Update the selected ID
          });
        }
      : null,
  items: sta.isNotEmpty
      ? sta.map<DropdownMenuItem<Map<String, dynamic>>>(
          (Map<String, dynamic> staff) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: staff,
              child: Text(staff['name'], // Display the bank's `name`
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),), // Display the name of the staff
            );
          },
        ).toList()
      : [
          DropdownMenuItem(
            child: Text('No staff available'),
            value: {'id': null, 'name': 'No staff available'}, // Default map
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

                       SizedBox(height: 5,),
                     Text("Bank",style: TextStyle(fontSize: 12),),
                      SizedBox(height: 5,),
              
Padding(
  padding: const EdgeInsets.only(right: 10),
  child: Container(
    height: 49,
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromARGB(255, 206, 206, 206)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        SizedBox(width: 20),
        Container(
          width: 270,
          child: InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Select Bank',
              contentPadding: EdgeInsets.symmetric(horizontal: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                hint: Text(
                  'Select Bank',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                value: selectedbankId, // Selected bank ID
                isExpanded: true,
                dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: const Color.fromARGB(255, 107, 107, 107),
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedbankId = newValue; // Update the selected bank ID
                    
                  });
                },
                items: bank.map<DropdownMenuItem<int>>((bankItem) {
                  return DropdownMenuItem<int>(
                    value: bankItem['id'], // Use the bank's `id`
                    child: Text(
                      bankItem['name'], // Display the bank's `name`
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),

   Text(
            "Transaction Id",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          SizedBox(height: 5),
          Container(
            child: TextField(
              controller: transactionid,
              decoration: InputDecoration(
                labelText: 'No.',
                labelStyle: TextStyle(
        fontSize: 13.0, // Adjust the font size as needed
      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ),
                    SizedBox(height: 5),

          Text(
            "Description",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          SizedBox(height: 5),
          Container(
            child: TextField(
              controller: description,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(
        fontSize: 13.0, // Adjust the font size as needed
      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              setState(() {

                updateexpense();

              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.blue,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              fixedSize: MaterialStateProperty.all<Size>(
                Size(constraints.maxWidth * 0.4, 50),
              ),
            ),
            child: Text("Submit", style: TextStyle(color: Colors.white)),
          ),
         
          // Displaying the list of departments as a table
          SizedBox(height: 10),

        ],
      ),
    ),
  ),
),
 SizedBox(height: 15),
          ],
        ),
      ),
    );
  },
)
    );
  }

}