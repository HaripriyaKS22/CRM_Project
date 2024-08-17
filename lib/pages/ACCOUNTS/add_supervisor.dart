
import 'dart:convert';

import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/update_department.dart';
import 'package:beposoft/pages/ACCOUNTS/update_supervisor.dart';
import 'package:flutter/material.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

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
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class add_supervisor extends StatefulWidget {
  const add_supervisor({super.key});

  @override
  State<add_supervisor> createState() => _add_supervisorState();
}

class _add_supervisorState extends State<add_supervisor> {
 @override
  void initState() {
    super.initState();
    getdepartments();
    getmanegers();
  }

var url = "$api/api/add/department/";


  TextEditingController name = TextEditingController();
Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
var departments;
  List<Map<String, dynamic>> dep = [];
   List<Map<String, dynamic>> manager = [];

    Future<void> getdepartments() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/departments/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD${response.body}");
        List<Map<String, dynamic>> departmentlist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$parsed");
 for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          departmentlist.add({
            'id': productData['id'],
            'name': productData['name'],
            
          });
        
        }
        setState(() {
          dep = departmentlist;
                  print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$dep");

          
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }
  

    Future<void> getmanegers() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/supervisors/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
        print("=============================================${response.body}");
        List<Map<String, dynamic>> managerlist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$parsed");
 for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          managerlist.add({
            'id': productData['id'],
            'name': productData['name'],
            'department_name':productData['department_name'],
            
          });
        
        }
        setState(() {
          manager = managerlist;
                  print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$dep");

          
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }
  
  void addsupervisor(String name, BuildContext context) async {
    print("eeeeeeeeeeeeeeeeeeeeeeeeee$name");
        print("eeeeeeeeeeeeeeeeeeeeeeeeee$url");

          final token = await gettokenFromPrefs();

    try {
      var response = await http.post(
        Uri.parse("$api/api/add/supervisor/"),
        headers: {
          'Authorization': '$token',
          
        },
        body: {
          "name": name,
          "department":selectedDepartmentId.toString(),

        },
      );

      print("RRRRRRRRRRRRRRRRRRRREEEEEEEEEEEESSSSSSS${response.statusCode}");

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);

     Navigator.push(context, MaterialPageRoute(builder: (context)=>add_supervisor()));
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 49, 212, 4),
          content: Text('sucess'),
        ),
      );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }
 Future<void> deletedepartment(int Id) async {
    final token = await gettokenFromPrefs();

    try {
      final response = await http.delete(
        Uri.parse('$api/api/supervisor/delete/$Id/'),
        headers: {
          'Authorization': '$token',
        },
      );
    print(response.statusCode);
    if(response.statusCode == 200){
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 49, 212, 4),
          content: Text('Deleted sucessfully'),
        ),
      );
         Navigator.push(context, MaterialPageRoute(builder: (context)=>add_supervisor()));
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
      manager.removeAt(index);
    });
  }
 int? selectedDepartmentId; // Variable to store the selected department's ID
  String? selectedDepartmentName; // Variable to store the selected department's name
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


        body: LayoutBuilder(
  builder: (context, constraints) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 15),
            Text(
              "SUPERVISOR",
              style: TextStyle(
                fontSize: 20,
                letterSpacing: 9.0,
                fontWeight: FontWeight.bold,
              ),
            ),
           Padding(
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Add Supervisor",
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
              Text(
                "Name",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: 'name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedDepartmentId,
                  hint: Text('Select a department'),
                  underline: SizedBox(), // Remove the default underline
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedDepartmentId = newValue;
                      selectedDepartmentName = dep
                          .firstWhere((element) => element['id'] == newValue)['name'];
                    });
                  },
                  items: dep.map<DropdownMenuItem<int>>((department) {
                    return DropdownMenuItem<int>(
                      value: department['id'],
                      child: Text(department['name']),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    addsupervisor(name.text, context);
                  });
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
                    Size(MediaQuery.of(context).size.width * 0.4, 50),
                  ),
                ),
                child: Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    ),
 SizedBox(height: 15),
 Padding(
   padding: const EdgeInsets.only(left: 15),
   child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
     children: [
       Text(
                  "Available Supervisors",
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
                  3: FixedColumnWidth(50.0), // Fixed width for the fourth column (Delete)
              
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 234, 231, 231),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "No.",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Manager Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                        Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Edit",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Delete",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  for (int i = 0; i < manager.length; i++)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text((i + 1).toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${manager[i]['name']}(${manager[i]['department_name']})"),
                        ),
                                     Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: GestureDetector(
                                            onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>update_supervisor(id:manager[i]['id'])));
                                       
                                            },
                                            child: Image.asset(
                                                            "lib/assets/edit.jpg",
                                       
                                              width: 20,
                                              height: 20,
                                             
                                            ),
                                          ),
                                     ),
                         Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: GestureDetector(
                                            onTap: () {
                                               deletedepartment(manager[i]['id']);
                                              removeProduct(i);
                                            },
                                            child: Image.asset(
                                              "lib/assets/delete.gif",
                                              width: 20,
                                              height: 20,
                                              
                                            ),
                           ),
                         )
                      ],
                    ),
                ],
              ),
            ),
          ),

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