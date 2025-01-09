

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
import 'package:flutter/material.dart';

import 'package:beposoft/main.dart';
import 'package:beposoft/pages/ACCOUNTS/add_credit_note.dart';
import 'package:beposoft/pages/ACCOUNTS/add_recipts.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/recipts_list.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_stock.dart';
import 'package:beposoft/pages/ACCOUNTS/credit_note_list.dart';
import 'package:beposoft/pages/ACCOUNTS/expence.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/new_product.dart';
import 'package:beposoft/pages/ACCOUNTS/order_request.dart';
import 'package:beposoft/pages/ACCOUNTS/purchases_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:beposoft/pages/api.dart';



class add_bank extends StatefulWidget {
  const add_bank({super.key});

  @override
  State<add_bank> createState() => _add_bankState();
}

class _add_bankState extends State<add_bank> {
 
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

TextEditingController name=TextEditingController();
TextEditingController account_number=TextEditingController();
TextEditingController branch=TextEditingController();
TextEditingController ifsc=TextEditingController();
TextEditingController balance=TextEditingController();
  List<Map<String, dynamic>> bank = [];

Future<String?> gettoken()async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  return pref.getString('token');
  
}

   @override
  void initState() {
    super.initState();
    getbank();
  }


  

Future<void> Addbank(BuildContext scaffoldContext,) async{
  final token=await gettoken();
 try{
   final response= await http.post(Uri.parse('$api/api/add/bank/'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body:jsonEncode(
    {
      'name':name.text,
      'account_number':account_number.text,
      'branch':branch.text,
      'ifsc_code':ifsc.text,
      'open_balance':balance.text
    }
  )
  );
   print("Response: ${response.body}");
   print("ressss${response.statusCode}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
             backgroundColor: Colors.green,
            content: Text('Bank added Successfully.'),
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=>add_bank()));
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Adding Bank failed.'),
          ),
        );
      }
 }
 catch(e){
  print("error:$e");
 }
}

Future<void> getbank() async{
  final token=await gettoken();
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

        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$parsed");
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
                  print("bbbbbbbbbbbbbbbbbbbbbbbbbbank$banklist");

          
        });
      }

  }
  catch(e){
    print("error:$e");
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

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(

           title: Text(
          "Add Bank",
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
     
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 15,),
                 Padding(
                      padding: const EdgeInsets.only(right: 10,top:10,left: 10),
                      child: Container(
                        width: 600,
                    
                         decoration: BoxDecoration(
                      color: Color.fromARGB(255, 34, 165, 246),
                     
                      border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                      
                    ),
                        child: Column(
                          children: [
                            SizedBox(height: 10,),
                            Text(" BANK DETAILS ",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                            SizedBox(height: 13,),
                    
                          ],
                        ),
                      ),
                    ),



                Padding(
                  padding: const EdgeInsets.only(top: 25,left: 15,right: 15),
                child:Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                    
                  ),
                  width: 700,

                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                         SizedBox(height: 10,),
                           Text("Bank Name",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                    
                         Padding(
                           padding: const EdgeInsets.only(right: 10),
                           child: Container(
                             child: TextField(
                               controller: name,
                               decoration: InputDecoration(
                                 labelText: 'Bank Name',
                                 
                                 labelStyle: TextStyle(
                                   fontSize: 12.0, // Set your desired font size
                                 ),
                                 border: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(10.0),
                                   borderSide: BorderSide(color: Colors.grey),
                                 ),
                                 contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                               ),
                             ),
                           ),
                         ),

                          


                       
                        SizedBox(height: 10,),
                           Text("Account Number",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        child: TextField(
                          controller: account_number,
                          decoration: InputDecoration(
                            labelText: 'Account Number',
                            labelStyle: TextStyle(
                              fontSize: 12.0, // Set your desired font size
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                          ),
                        ),
                      ),
                    ),

                              SizedBox(height: 10,),
                           Text("Branch",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                    
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                child: TextField(
                                  controller: branch,
                                  decoration: InputDecoration(
                                    labelText: 'Branch',
                                    labelStyle: TextStyle(
                                      fontSize: 12.0, // Set your desired font size
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                  ),
                                ),
                              ),
                            ),
  SizedBox(height: 10,),
                           Text("IFSC Code",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                    
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                child: TextField(
                                  controller: ifsc,
                                  decoration: InputDecoration(
                                    labelText: 'IFSC Code',
                                    labelStyle: TextStyle(
                                      fontSize: 12.0, // Set your desired font size
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                  ),
                                ),
                              ),
                            ),
       SizedBox(height: 10,),
       Text("Opening Balance ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
       SizedBox(height: 5,),
Padding(
  padding: const EdgeInsets.only(right: 10),
  child: Container(
    child: TextField(
      controller: balance,
      decoration: InputDecoration(
        labelText: 'Opening Balance',
        labelStyle: TextStyle(
          fontSize: 12.0, // Set your desired font size
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
      ),
    ),
  ),
),
        SizedBox(height: 15,),

                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                     children:[
                      SizedBox(width: 20,),

                      SizedBox(
                      width: 270,
                       child: ElevatedButton(
                                         onPressed: () {
                        Addbank(context);
                                         },
                                         style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                         Color.fromARGB(255, 64, 176, 251),
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Set your desired border radius
                          ),
                        ),
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size(95, 15), // Set your desired width and heigh
                        ),
                                         ),
                                         child: Text("Submit",style: TextStyle(color: Colors.white)),
                                       ),
                     ),
                     ] 
                   ),
                SizedBox(height: 20,)


                      ],
                    ),
                  )
                  
  
  
),

                ),
SizedBox(height: 15),
 Padding(
   padding: const EdgeInsets.only(left: 15),
   child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
     children: [
       Text(
                  "Available Bank",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
     ],
   ),
 ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 15,left: 15),
            child: Container(
              color: Colors.white,
              child: Table(
                
                border: TableBorder.all(color: Color.fromARGB(255, 214, 213, 213)),
                columnWidths: {
                     0: FixedColumnWidth(40.0), // Fixed width for the first column (No.)
                  1: FlexColumnWidth(2),     // Flex width for the second column (Department Name)
                  2: FixedColumnWidth(50.0), // Fixed width for the third column (Edit)
              
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(
                      color:   Color.fromARGB(255, 64, 176, 251),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "No.",
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Department Name",
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                      ),
                        Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Edit",
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                      ),
                     
                    ],
                  ),
                  for (int i = 0; i < bank.length; i++)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text((i + 1).toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(bank[i]['name']),
                        ),
                                     Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: GestureDetector(
                                            onTap: () {
                                        // Navigator.push(context, MaterialPageRoute(builder: (context)=>update_family(id:fam[i]['id'])));
                                       
                                            },
                                            child: Image.asset(
                                                            "lib/assets/edit.jpg",
                                       
                                              width: 20,
                                              height: 20,
                                             
                                            ),
                                          ),
                                     ),
                        
                      ],
                    ),
                ],
              ),
            ),
          ),
              SizedBox(height: 20,) 

              ],
            ),
          )
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
          MaterialPageRoute(builder: (context) =>credit_note_list()),
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
          MaterialPageRoute(builder: (context) => order_request()),
        );
        break;
         case 'Option 8':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new_product()),
        );
        break;
        case 'Option 9':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new_product()),
        );
        break;
        case 'Option 10':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_new_stock()),
        );
        break;
        case 'Option 11':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  Purchases_request()),
        );
        break;
        case 'Option 12':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  Purchases_request()),
        );
        break;
        case 'Option 13':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  expence()),
        );
        break;
        case 'Option 13':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  expence()),
        );
        break;
        
        
    
      
      default:
        // Handle default case or unexpected options
        break;
    }
  }


   
}
