
import 'dart:convert';

import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';



import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/new_grv.dart';
import 'package:beposoft/pages/ACCOUNTS/profile.dart';
import 'package:beposoft/pages/ACCOUNTS/transfer.dart';




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
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_customer.dart';
import 'package:beposoft/pages/api.dart';






class order_request extends StatefulWidget {
  const order_request({super.key});

  @override
  State<order_request> createState() => _order_requestState();
}

class _order_requestState extends State<order_request> {
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

  List<String>  manager= ["jeshiya",'hanvi','nimitha','sandheep','sulfi'];
  String selectmanager="jeshiya";
  List<String>  address= ["empty",];
  String selectaddress="empty";
  List<Map<String, dynamic>> fam = [];
    List<Map<String, dynamic>> customer = [];

    int? selectedFamilyId;
    String selectedstaff='';
    int? selectedstaffId;
    int? selectedstateId;


    var famid;
    var staffid;

 @override
  void initState() {
    super.initState();
    initdata();
    
  }
  void initdata() async{
    await getprofiledata();
    getfamily();
    selectedFamilyId=famid;
    print("famiddd$selectedFamilyId");
    getstaff();
    selectedstaffId=staffid;
    getcustomer();
     getstate();
     getaddress();

  }

//dateselection
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

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
 Future<void> getcustomer() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/customers/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
          "=============================================hoiii${response.body}");
      List<Map<String, dynamic>> managerlist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print(
            "RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDhaaaii$parsed");
        for (var productData in productsData) {
          managerlist.add({
            'id': productData['id'],
            'name': productData['name'],
            'created_at': productData['created_at'],
            'manager':productData['manager']
          });
        }
        setState(() {
          customer = managerlist;

          print("cutomerrrr$customer");
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }
List<Map<String, dynamic>> stat = [];

    Future<void> getstate() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/states/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
        print("state${response.body}");
        List<Map<String, dynamic>> statelist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("stateeeeeeeeeeeee$parsed");
 for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          statelist.add({
            'id': productData['id'],
            'name': productData['name'],
            
          });
        
        }
        setState(() {
          stat = statelist;
                  print("stateeeeeeee$stat");

          
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }


  List<Map<String, dynamic>> addres = [];

    Future<void> getaddress() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/add/customer/address/$selectedValue/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
        print("addresres${response.body}");
        List<Map<String, dynamic>> addresslist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("addreseeeeeeeeeeeee$parsed");
 for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          addresslist.add({
            'id': productData['id'],
            'name': productData['name'],
            
          });
        
        }
        setState(() {
          addres = addresslist;
                  print("addres$addres");

          
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }


 Future<void> getfamily() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/familys/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];
        List<Map<String, dynamic>> familylist = [];

        for (var productData in productsData) {
          familylist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }

        setState(() {
          fam = familylist;
          print("fammmmmmmmmmmmmm$fam");
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }
  //searchable dropdown


  Future<void> getprofiledata() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse("$api/api/profile/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("==============0000000000000000000000000${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("profileeeeeee$productsData");

        setState(() {
          famid=productsData['family'];
          staffid=productsData['id'];

          print("fammmmmmmmmmmmmmid$famid");
        });
      }
    } catch (error) {
      print("Error: $error");
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
      print(
          "RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD${response.body}");
      List<Map<String, dynamic>> stafflist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$parsed");
        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          stafflist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          sta = stafflist;
          print("sataffffffffffff$sta");
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }


 final List<String> items = [
    'A_Item1',
    'A_Item2',
    'A_Item3',
    'A_Item4',
    'B_Item1',
    'B_Item2',
    'B_Item3',
    'B_Item4',
    "anii"
  ];

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
  List<String>  company = ["BEPOSITIVE RACING PRIVATE LIMITED",'MICHAEL EXPORT AND IMPORT PRIVATE LIMITED'];
  String selectcomp="BEPOSITIVE RACING PRIVATE LIMITED";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(

        actions: [
            IconButton(
              icon: Image.asset('lib/assets/profile.png'),
               
              onPressed: () {
                
              },
            ),
          ],
          
          ),
     drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 110, 110, 110),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "lib/assets/logo-white.png",
                        width: 100, // Change width to desired size
                        height: 100, // Change height to desired size
                        fit: BoxFit
                            .contain, // Use BoxFit.contain to maintain aspect ratio
                      ),
                      SizedBox(width: 70,),
                      Text(
                        'BepoSoft',
                        style: TextStyle(
                          color: Color.fromARGB(236, 255, 255, 255),
                          fontSize: 20,
                         
                        ),
                      ),
                      
                    ],
                  )),
                  ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>dashboard()));
              },
            ),
                  ListTile(
              leading: Icon(Icons.person),
              title: Text('Customer'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>customer_list()));
                // Navigate to the Settings page or perform any other action
              },
            ),
             Divider(),
            _buildDropdownTile(context, 'Credit Note', ['Add Credit Note', 'Credit Note List',]),
            _buildDropdownTile(context, 'Recipts', ['Add recipts', 'Recipts List']),
            _buildDropdownTile(context, 'Proforma Invoice', ['New Proforma Invoice', 'Proforma Invoice List',]),
            _buildDropdownTile(context, 'Delivery Note', ['Delivery Note List', 'Daily Goods Movement']),
            _buildDropdownTile(context, 'Orders', ['New Orders', 'Orders List']),
             Divider(),

             Text("Others"),
             Divider(),

            _buildDropdownTile(context, 'Product', ['Product List', 'Stock',]),
            _buildDropdownTile(context, 'Purchase', [' New Purchase', 'Purchase List']),
            _buildDropdownTile(context, 'Expence', ['Add Expence', 'Expence List',]),
            _buildDropdownTile(context, 'Reports', ['Sales Report', 'Credit Sales Report','COD Sales Report','Statewise Sales Report','Expence Report','Delivery Report','Product Sale Report','Stock Report','Damaged Stock']),
            _buildDropdownTile(context, 'GRV', ['Create New GRV', 'GRVs List']),
             _buildDropdownTile(context, 'Banking Module', ['Add Bank ', 'List','Other Transfer']),
               Divider(),




            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Methods'),
              onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context)=>Methods()));

              },
            ),

            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Perform logout action
              },
            ),
            
          
          ],
        ),
      ),


        body: SingleChildScrollView(

          child: Container(
            child: Column(
              children: [
                SizedBox(height: 15,),


                Text("ORDER REQUEST ",style: TextStyle(fontSize: 20,letterSpacing: 9.0,fontWeight: FontWeight.bold),),

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
                        SizedBox(height: 20,),

                 Text("Select Company *",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),


                         Container(
                             width: 304,
                             decoration: BoxDecoration(
                               border: Border.all(color: Colors.grey), // Add border to the Container
                               borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                             ),
                             child: InputDecorator(
                               decoration: InputDecoration(
                                 border: InputBorder.none,
                                 hintText: '',
                                 contentPadding: EdgeInsets.symmetric(horizontal: 1),
                               ),
                               child: DropdownButton<String>(
                                 value: selectcomp,
                                 underline: Container(), // This removes the underline
                                 onChanged: (String? newValue) {
                                   setState(() {
                                     selectcomp = newValue!;
                                     print(selectcomp);
                                   });
                                 },
                                 items: company.map<DropdownMenuItem<String>>((String value) {
                                   return DropdownMenuItem<String>(
                                     value: value,
                                     child: Text(
                                       value,
                                       style: TextStyle(fontSize: 10), // Set the font size here
                                     ),
                                   );
                                 }).toList(),
                                 icon: Container(
                                   padding: EdgeInsets.only(left: 30), // Adjust padding as needed
                                   alignment: Alignment.centerRight,
                                   child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                                 ),
                               ),
                             ),
                           ),
                        
                                    
                SizedBox(height: 8,),
                 Text("Select Family *",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),

                      Container(
                    width: 310,
                    height: 49,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromARGB(255, 62, 62, 62)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Container(
                          width: 280,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Select your class',
                              contentPadding: EdgeInsets.symmetric(horizontal: 1),
                            ),
                            child:DropdownButtonHideUnderline(
              child: DropdownButton<int>(
            hint: Text(
              'Select a Family',
              style: TextStyle(color: Colors.grey[600]),
            ),
            value: selectedFamilyId,
            isExpanded: true,
            dropdownColor: const Color.fromARGB(255, 255, 255, 255),
            icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
            onChanged: (int? newValue) {
              setState(() {
                selectedFamilyId = newValue; // Store the selected family ID
              });
            },
            items: fam.map<DropdownMenuItem<int>>((family) {
              return DropdownMenuItem<int>(
                value: family['id'],
                child: Text(
                  family['name'],
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              );
            }).toList(),
          ),)
          
        
      
                          ),
                        ),
                      ],
                    ),
                  ),



                  

                                         
                SizedBox(height: 8,),
                 Text("Maneger *",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),


                

                 

                  Container(
                    width: 304,
                    height: 49,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Container(
                          width: 276,
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
                              onChanged: (int? newValue) {
                                setState(() {
                                  selectedstaffId = newValue!;
                                  print(selectedstaffId);
                                });
                              },
                              items: sta.map<DropdownMenuItem<int>>((staff) {
                                return DropdownMenuItem<int>(
                                  value:staff['id'],
                                  child: Text(staff['name']),
                                );
                              }).toList(),
                              icon: Container(
                                padding: EdgeInsets.only(left: 190), // Adjust padding as needed
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                     SizedBox(height: 8,),
                 Text("Customer *",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),

                      
                       LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth * 0.9, // Adjusted width based on screen size
          child: DropdownButtonHideUnderline(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Select a Customer',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                ),
                items: customer
                    .map((item) => DropdownMenuItem<String>(
                          value: item['name'], // Use the customer's name as the value
                          child: Text(
                            item['name'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ))
                    .toList(),
                value: selectedValue,
                onChanged: (value) {
                  setState(() {
                    // Update the selected value with the chosen customer's name
                    selectedValue = value;
                  });
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: textEditingController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: const EdgeInsets.only(top: 8, bottom: 4, right: 8, left: 8),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        hintText: 'Search for a customer...',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    // Perform case-insensitive search
                    return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
                  },
                ),
                // Clear the search value when the menu is closed
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    textEditingController.clear();
                  }
                },
              ),
            ),
          ),
        );
      },
    ),    



      SizedBox(height: 8,),
                 Text("State",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),


                

                 

                  Container(
                    width: 304,
                    height: 49,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Container(
                          width: 276,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: 1),
                            ),
                            child: DropdownButton<int>(
                              hint:  Text(
                  'State',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                ),
                              value: selectedstateId,
                                isExpanded: true,
                              underline: Container(), // This removes the underline
                              onChanged: (int? newValue) {
                                setState(() {
                                  selectedstateId = newValue!;
                                  print(selectedstateId);
                                });
                              },
                              items: stat.map<DropdownMenuItem<int>>((State) {
                                return DropdownMenuItem<int>(
                                  value:State['id'],
                                  child: Text(State['name']),
                                );
                              }).toList(),
                              icon: Container(
                                padding: EdgeInsets.only(left: 190), // Adjust padding as needed
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 10,),
                 Text("Invoice ID",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),

 Container(
                              width: 304,
                              child:  TextField(
                                  decoration: InputDecoration(
                                    labelText: 'IN/--',
                                    prefixIcon: Icon(Icons.insert_drive_file),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                  ),
                                ),
                    
                            ),

                        
                    
                        SizedBox(height: 10,),
                           Text("Name of new invoice",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                    
                            Container(
                              width: 304,
                              child:  TextField(
                                  decoration: InputDecoration(
                                    labelText: 'IN/--',
                                    prefixIcon: Icon(Icons.info_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                  ),
                                ),
                    
                            ),

                                                           SizedBox(height: 10,),
                         Text("User management",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),


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
                        Container(
                          width: 276,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: 1),
                            ),
                            child: DropdownButton<String>(
                              value: selectmanager,
                              underline: Container(), // This removes the underline
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectmanager = newValue!;
                                  print(selectmanager);
                                });
                              },
                              items: manager.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              icon: Container(
                                padding: EdgeInsets.only(left: 167), // Adjust padding as needed
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                     
                            

                  

        

              SizedBox(height: 25,),
             
                  Text("Bill To*",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),

              
                          Container(
                    width: 304,
                    height: 49,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Container(
                          width: 276,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: 1),
                            ),
                            child: DropdownButton<String>(
                              value: selectaddress,
                              underline: Container(), // This removes the underline
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectaddress = newValue!;
                                  print(selectaddress);
                                });
                              },
                              items: address.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              icon: Container(
                                padding: EdgeInsets.only(left: 190), // Adjust padding as needed
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  SizedBox(height: 25,),
             
                  Text("Ship To*",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),

              
                          Container(
                    width: 304,
                    height: 49,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Container(
                          width: 276,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '',
                              contentPadding: EdgeInsets.symmetric(horizontal: 1),
                            ),
                            child: DropdownButton<String>(
                              value: selectaddress,
                              underline: Container(), // This removes the underline
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectaddress = newValue!;
                                  print(selectaddress);
                                });
                              },
                              items: address.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              icon: Container(
                                padding: EdgeInsets.only(left: 190), // Adjust padding as needed
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),



                   SizedBox(height: 10,),
                 Text("Invoice Date",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),

 Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
  width: 304, 
  height: 46, 
  decoration: BoxDecoration(
    border: Border.all(
      color: Colors.grey, 
      width: 1.0, 
    ),
    borderRadius: BorderRadius.circular(8.0), 
  ),
  child: Row(
    children: [
      SizedBox(width: 30,),
      Text(
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
        style: TextStyle(fontSize:15,color:Color.fromARGB(255, 116, 116, 116)),
      ),
      SizedBox(width: 162,),
       GestureDetector(
        onTap: () {
         _selectDate(context);
          print('Icon pressed');
        },
        child: Icon(Icons.date_range),
      ),
    ],
  ),
),

           
           
          ],
        ),
                 

             
             


                          

                  


                           
                   SizedBox(height: 15,),

                   ElevatedButton(
                  onPressed: () {
                    // Your onPressed logic goes here
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 17, 173, 0),
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
                  child: Text("Add Product",style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20,)     
                    
                      ],
                    ),
                  )
                  
  
  
),

                ),

               

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