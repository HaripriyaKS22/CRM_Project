
import 'dart:convert';

import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
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


class update_family extends StatefulWidget {
   final id;
  const update_family({super.key ,required this.id});

  @override
  State<update_family> createState() => _update_familyState();
}

class _update_familyState extends State<update_family> {
 @override
  void initState() {
    super.initState();
    getfamily();
  }

var url = "$api/api/add/department/";


  TextEditingController family= TextEditingController();
Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
var departments;

 Future<void> deletefamily(int Id) async {
    final token = await gettokenFromPrefs();

    try {
      final response = await http.delete(
        Uri.parse('$api/api/family/update/$Id/'),
        headers: {
          'Authorization': 'Bearer $token',
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
         Navigator.push(context, MaterialPageRoute(builder: (context)=>add_family()));
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

  List<Map<String, dynamic>> fam = [];

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
        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD${response.body}");
        List<Map<String, dynamic>> familylist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$parsed");
 for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          familylist.add({
            'id': productData['id'],
            'name': productData['name'],
            
          });
          
           if(widget.id==productData['id']){
          family.text=productData['name']?? '';;
        }
        
        }
        setState(() {
          fam = familylist;
                  print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$familylist");

          
        });
        
      }
    } catch (error) {
      print("Error: $error");
    }
  }
   
 
  Future<void> updatefamily() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.put(
        Uri.parse('$api/api/family/update/${widget.id}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'name':family.text,
            
          },
        ),
      );

    

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>add_family()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile'),
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
              "FAMILY",
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
    width: constraints.maxWidth * 0.9,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: constraints.maxWidth * 0.9,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 121, 121, 121),
              border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
            ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "Update Family",
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
            "Family",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: constraints.maxWidth * 0.9,
            child: TextField(
              controller: family,
              decoration: InputDecoration(
                hintText: family.text.isNotEmpty ? family.text : 'Enter your family',
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
                updatefamily();
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
 Padding(
   padding: const EdgeInsets.only(left: 15),
   child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
     children: [
       Text(
                  "Available Departments",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
     ],
   ),
 ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 15,left: 15),
            child: Table(
              border: TableBorder.all(color: const Color.fromARGB(255, 255, 255, 255)),
              columnWidths: {
                0: FixedColumnWidth(40.0),
                1: FlexColumnWidth(),
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
                        "Department Name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                      Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "No.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                   
                  ],
                ),
                for (int i = 0; i < fam.length; i++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text((i + 1).toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(fam[i]['name']),
                      ),
                       Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: GestureDetector(
                                            onTap: () {
                                               deletefamily(fam[i]['id']);
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