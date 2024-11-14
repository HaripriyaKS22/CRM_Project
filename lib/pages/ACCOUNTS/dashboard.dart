
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_staff.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/bank_list.dart';
import 'package:beposoft/pages/ACCOUNTS/daily_goods_movement.dart';
import 'package:beposoft/pages/ACCOUNTS/delivery_list.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/expence_list.dart';
import 'package:beposoft/pages/ACCOUNTS/grv_list.dart';
import 'package:beposoft/pages/ACCOUNTS/new_grv.dart';
import 'package:beposoft/pages/ACCOUNTS/new_proforma_invoice.dart';
import 'package:beposoft/pages/ACCOUNTS/order_list.dart';
import 'package:beposoft/pages/ACCOUNTS/profile.dart';
import 'package:beposoft/pages/ACCOUNTS/profilepage.dart';
import 'package:beposoft/pages/ACCOUNTS/purchase_list.dart';
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class dashboard  extends StatefulWidget {
  const dashboard({super.key});

  
  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
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

   void logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  await prefs.remove('token');

  // Show a snackbar with the logout success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Logout successfully'),
      duration: Duration(seconds: 2), // Optional: Set how long the snackbar will be visible
    ),
  );

  // Navigate to the HomePage
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) =>login()),
  );
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfileScreen()));
                
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
              title: Text('Company'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>add_company()));
                // Navigate to the Settings page or perform any other action
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
              ListTile(
              leading: Icon(Icons.person),
              title: Text('Departments'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>add_department()));
                // Navigate to the Settings page or perform any other action
              },
            ),
             ListTile(
              leading: Icon(Icons.person),
              title: Text('Supervisors'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>add_supervisor()));
                // Navigate to the Settings page or perform any other action
              },
            ),
              ListTile(
              leading: Icon(Icons.person),
              title: Text('Family'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>add_family()));
                // Navigate to the Settings page or perform any other action
              },
            ),
             ListTile(
              leading: Icon(Icons.person),
              title: Text('Staff'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>add_staff()));
                // Navigate to the Settings page or perform any other action
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Bank'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>add_bank()));
                // Navigate to the Settings page or perform any other action
              },
            ),
             ListTile(
              leading: Icon(Icons.person),
              title: Text('States'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>add_state()));
                // Navigate to the Settings page or perform any other action
              },
            ),
             ListTile(
              leading: Icon(Icons.person),
              title: Text('Attributes'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>add_attribute()));
                // Navigate to the Settings page or perform any other action
              },
            ),
             Divider(),
            _buildDropdownTile(context, 'Staff', ['Add Staff', 'View Staff',]),
            _buildDropdownTile(context, 'Credit Note', ['Add Credit Note', 'Credit Note List',]),
            _buildDropdownTile(context, 'Recipts', ['Add recipts', 'Recipts List']),
            _buildDropdownTile(context, 'Proforma Invoice', ['New Proforma Invoice', 'Proforma Invoice List',]),
            _buildDropdownTile(context, 'Delivery Note', ['Delivery Note List', 'Daily Goods Movement']),
            _buildDropdownTile(context, 'Orders', ['New Orders', 'Orders List']),
             Divider(),

             Text("Others"),
             Divider(),

            _buildDropdownTile(context, 'Product', ['Product List','Product Add', 'Stock',]),
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
                logout();
              },
            ),
            
          
          ],
        ),
      ),
     
        body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 50),
                child: Text(
                  "DASHBOARD",
                  style: TextStyle(
                    letterSpacing: 13.0,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 0, 195, 255),
                                    Color.fromARGB(234, 53, 82, 246),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Number of Bills / Approved Bills",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Text(
                                          "0",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                        SizedBox(width: 85,),
                                        Image.asset(
                                          "lib/assets/right.png",
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 209, 11, 50),
                                    Color.fromARGB(234, 246, 137, 53),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Todays Shipped Orders",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Text(
                                          "25/5",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                        SizedBox(width: 55,),
                                        Image.asset(
                                          "lib/assets/right.png",
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 209, 202, 11),
                                    Color.fromARGB(234, 213, 248, 120),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Delivery Boxes",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "25",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                        SizedBox(width: 30,),
                                        Image.asset(
                                          "lib/assets/right.png",
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Add more Expanded widgets for other cards here
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 110,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 141, 141, 141),
                                    Color.fromARGB(234, 98, 98, 98),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Add Product",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Container(
 color: Color.fromARGB(255, 145, 145, 145),                                      
     width: 140,
                                          height: 25,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 52),
                                            child: Row(
                                              children: [
                                               
                                                SizedBox(width: 8,),
                                                Image.asset(
                                                  "lib/assets/right.png",
                                                  width: 15,
                                                  height: 15,
                                                  fit: BoxFit.contain,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height:110,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 141, 141, 141),
                                    Color.fromARGB(234, 98, 98, 98),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Add Expense",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Container(
 color: Color.fromARGB(255, 145, 145, 145),                                        
   width: 140,
                                          height: 25,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 52),
                                            child: Row(
                                              children: [
                                                
                                                SizedBox(width: 8,),
                                                Image.asset(
                                                  "lib/assets/right.png",
                                                  width: 15,
                                                  height: 15,
                                                  fit: BoxFit.contain,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18, ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                          height: 110,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 141, 141, 141),
                                    Color.fromARGB(234, 98, 98, 98),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Add Receipts",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
         ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Container(
 color: Color.fromARGB(255, 145, 145, 145),                                        
   width: 140,
                                          height: 25,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 52),
                                            child: Row(
                                              children: [
                                                
                                                SizedBox(width: 8,),
                                                Image.asset(
                                                  "lib/assets/right.png",
                                                  width: 15,
                                                  height: 15,
                                                  fit: BoxFit.contain,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                         height: 110,
                        child: Card(
                          elevation: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => add_receipts()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 141, 141, 141),
                                    Color.fromARGB(234, 98, 98, 98),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    Text(
                                      "Add Bank Transfer",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Container(
 color: Color.fromARGB(255, 145, 145, 145),                                         
  width: 140,
                                          height: 25,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 52),
                                            child: Row(
                                              children: [
                                                
                                                SizedBox(width: 8,),
                                                Image.asset(
                                                  "lib/assets/right.png",
                                                  width: 15,
                                                  height: 15,
                                                  fit: BoxFit.contain,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

      );
    

  }

   
   
}
