
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:flutter/material.dart';

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
import 'package:shared_preferences/shared_preferences.dart';






class new_expence extends StatefulWidget {
  const new_expence({super.key});

  @override
  State<new_expence> createState() => _new_expenceState();
}

class _new_expenceState extends State<new_expence> {

   List<String>  bank = ["ICIC",'SBI','HDFC'];
  String selectbank="ICIC";
     List<String>  payedby = ["Savio","jeshiya",'nimitha','hanvi','sulfi','yeshitha'];
  String selectpayedby="Savio";

   Attribute add = Attribute();

  static int incrementedValue = 1;



  var set1 = 1;
  var set2 = 0;

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

  //searchable dropdown

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
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
  List<String>  product = ["item1",'item2','item3'];
  String selectproduct="item1";
  List<String>  purpose = ["Against Returned Invoice",'Against Purchase Invoice','Other'];
  String selectpurpose="Against Returned Invoice";
  
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


                Text("STOCK ",style: TextStyle(fontSize: 20,letterSpacing: 9.0,fontWeight: FontWeight.bold),),

                Padding(
                  padding: const EdgeInsets.only(top: 25,left: 15,right: 15),
                child:Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 177, 101, 101),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                    
                  ),
                  width: 700,

                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                      padding: const EdgeInsets.only(right: 10,top:10,),
                      child: Container(
                        width: 600,
                    
                         decoration: BoxDecoration(
                      color: Color.fromARGB(255, 121, 121, 121),
                      borderRadius: BorderRadius.only(
                        
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)
                      ),
                      border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                      
                    ),
                        child: Column(
                          children: [
                            SizedBox(height: 10,),
                            Text(" New Stock( Variable Product ) ",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                            SizedBox(height: 13,),
                    
                          SizedBox(height: 10,)
                    
                          
                          
                         
                    
                    
                    
                    
                          ],
                        ),
                      ),
                    ),
                     SizedBox(height: 10,),
                           Text("External ID",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                    
                            Container(
                              width: 304,
                              child:  TextField(
                                  decoration: InputDecoration(
                                    labelText: 'External ID',
                                    prefixIcon: Icon(Icons.local_play),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                  ),
                                ),
                    
                            ),
                    
                     SizedBox(height: 20,),


                 Text("Select Product",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),

                    
                      
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
                                 value: selectproduct,
                                 underline: Container(), // This removes the underline
                                 onChanged: (String? newValue) {
                                   setState(() {
                                     selectproduct = newValue!;
                                     print(selectproduct);
                                   });
                                 },
                                 items: product.map<DropdownMenuItem<String>>((String value) {
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
                        
                    
                        SizedBox(height: 10,),
                           Text("User management",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                    
                            Container(
                              width: 304,
                              child:  TextField(
                                  decoration: InputDecoration(
                                    labelText: '',
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                  ),
                                ),
                    
                            ),

                      ],
                    ),
                  )
                ),

                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                  
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                               incrementedValue= add.set(set1);
                              
                            });
                          
                           print("======================$incrementedValue");
                           
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 92, 150, 244)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            fixedSize: MaterialStateProperty.all<Size>(Size(95, 15)),
                          ),
                          child: Text("ADD", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 20),
                  
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                               incrementedValue= add.set(set2);
                              
                            });
                           
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 248, 93, 93)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            fixedSize: MaterialStateProperty.all<Size>(Size(95, 15)),
                          ),
                          child: Text("REMOVE", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                  
                    ],
                  ),
                ),
               Container(
                   child: ListView.builder(
                    shrinkWrap: true,
                     physics: NeverScrollableScrollPhysics(),
                     itemCount: incrementedValue, // Ensure a valid itemCount
                     itemBuilder: (context, index) {
                       return Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: MyCard(
                           // Pass data to MyCard if needed
                         ),
                       );
                     },
                   ),
                 ),
               

       SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            incrementedValue= add.set(set2);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 248, 93, 93)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            fixedSize: MaterialStateProperty.all<Size>(Size(95, 15)),
                          ),
                          child: Text("REMOVE", style: TextStyle(color: Colors.white)),
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
          MaterialPageRoute(builder: (context) =>  order_request ()),
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

class MyCard extends StatefulWidget {
  const MyCard({super.key});

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {

   final TextEditingController textEditingController = TextEditingController();

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
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text("helllllllllllllllllllllllllloooooooooooooooo")

    );
  }
}