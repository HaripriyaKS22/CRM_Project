
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
import 'package:beposoft/pages/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class add_expence extends StatefulWidget {
  const add_expence({super.key});

  @override
  State<add_expence> createState() => _add_expenceState();
}

class _add_expenceState extends State<add_expence> {
 @override
  void initState() {
    super.initState();
    getcompany();
    getstaff();
    getbank();
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
 Future<void> deletefamily(int Id) async {
    final token = await gettokenFromPrefs();

    try {
      final response = await http.delete(
        Uri.parse('$api/api/family/update/$Id/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    
    if(response.statusCode == 200){
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 49, 212, 4),
          content: Text('Deleted sucessfully'),
        ),
      );
         Navigator.push(context, MaterialPageRoute(builder: (context)=>add_expence()));
    }

      if (response.statusCode == 204) {
      } else {
        throw Exception('Failed to delete wishlist ID: $Id');
      }
    } catch (error) {
    }
  }

  void removeProduct(int index) {
    setState(() {
      fam.removeAt(index);
    });
  }

 drower d=drower();
   Widget _buildDropdownTile(BuildContext context, String title, List<String> options) {
    return ExpansionTile(
      title: Text(title),
      children: options.map((option) {
        return ListTile(
          title: Text(option),
          onTap: () {
            Navigator.pop(context);
            d.navigateToSelectedPage(context, option); // Navigate to selected page
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
    });
  }
}
String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
        MaterialPageRoute(builder: (context) => add_expence()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(
           title: Text(
          "Add Expence",
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


                   Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          
                          height: 49,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
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
                                    hintText: '',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 1),
                                  ),
                                  child: DropdownButton<int>(
                                    value: selectedstaffId,
                                      isExpanded: true,
                                    underline: Container(), // This removes the underline
                                     hint: Text('Select a Paid by',style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedstaffId = newValue!;
                                        
                                      });
                                    },
                                    items: sta.map<DropdownMenuItem<int>>((staff) {
                                      return DropdownMenuItem<int>(
                                        value:staff['id'],
                                        child: Text(staff['name'],style: TextStyle(fontSize: 12),),
                                      );
                                    }).toList(),
                                    icon: Container(
                                      alignment: Alignment.centerRight,
                                      child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                    hintText: 'Select',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 1),
                                  ),
                                  child:DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                        hint: Text(
                                          'Select Bank',
                                          
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                          
                                        ),
                                        value: selectedbankId,
                                        isExpanded: true,
                                        dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                                        icon: Icon(Icons.arrow_drop_down, color:const Color.fromARGB(255, 107, 107, 107)),
                                        onChanged: (int? newValue) {
                                          setState(() {
                                            selectedbankId = newValue; // Store the selected family ID
                                            
                                          });
                                        },
                                        items: bank.map<DropdownMenuItem<int>>((bank) {
                                          return DropdownMenuItem<int>(
                                            value: bank['id'],
                                            child: Text(
                                              bank['name'],
                                              style: TextStyle(color: Colors.black87, fontSize: 12),
                                            ),
                                          );
                                        }).toList(),
                                      ),)
                                      
                                    
                                  
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
                addexpense();
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


  void _navigateToSelectedPage(BuildContext context, String selectedOption) {
    
    switch (selectedOption) {
      case 'Option 1':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => credit_note_list()),
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