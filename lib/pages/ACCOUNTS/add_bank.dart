

import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
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



class add_bank extends StatefulWidget {
  const add_bank({super.key});

  @override
  State<add_bank> createState() => _add_bankState();
}

class _add_bankState extends State<add_bank> {
   List<String>  bank = ["ICIC",'SBI','PETTY CASH','HDFC'];
  String selectbank="ICIC";

    List<String>  addedby = ["jeshiya",'nimitha','hanvi','sulfi','yeshitha'];
  String selectaddby="jeshiya";
  double number = 0.00;
    double rate = 0.00;
     double margin = 0.00;

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


  void incrementNumber() {
    setState(() {
      number += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      controller.text = number.toStringAsFixed(2);
      
    });
  }
  void incrementrate() {
    setState(() {
      rate += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      controller2.text = rate.toStringAsFixed(2);
      
    });
  }

  void incrementmargin() {
    setState(() {
      margin += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      controller3.text = margin.toStringAsFixed(2);
      
    });
  }


  void decrementNumber() {
    setState(() {
      if (number >= 0.01) {
        number -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller.text = number.toStringAsFixed(2);
         
      }
    });
  }

   void decrementrate() {
    setState(() {
      if (rate >= 0.01) {
        rate -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller2.text = rate.toStringAsFixed(2);
         
      }
    });
  }
  void decrementmargin() {
    setState(() {
      if (margin >= 0.01) {
        margin -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller3.text = margin.toStringAsFixed(2);
         
      }
    });
  }
  final TextEditingController controller = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  var selectedfile;
   @override
  void initState() {
    super.initState();
    controller.text = number.toStringAsFixed(2);

     
    

  }

  Color currentColor = Colors.black;

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
    });
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

                      SizedBox(height: 30,),


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

                               Text("Select Bank For Update",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
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
                              value: selectbank,
                              underline: Container(), // This removes the underline
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectbank = newValue!;
                                  print(selectbank);
                                });
                              },
                              items: bank.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              icon: Container(
                                padding: EdgeInsets.only(left: 153), // Adjust padding as needed
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),SizedBox(height: 60,),
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





                         SizedBox(height: 10,),
                           Text("Bank Name",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            SizedBox(height: 13,),
                    
                            Container(
                              width: 304,
                              child:  TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Bank Name',
                                   
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                  ),
                                ),
                    
                            ),
                          


                       
                        SizedBox(height: 10,),
                           Text("Account Number",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            SizedBox(height: 13,),
                    
                            Container(
                              width: 304,
                              child:  TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Account Number',
                                    
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                  ),
                                ),
                    
                            ),

                              SizedBox(height: 10,),
                           Text("Branch",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            SizedBox(height: 13,),
                    
                            Container(
                              width: 304,
                              child:  TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Branch',
                                   
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                  ),
                                ),
                    
                            ),
                            SizedBox(height: 10,),


                       
                        SizedBox(height: 10,),
                           Text("IFSC Code",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            SizedBox(height: 13,),
                    
                            Container(
                              width: 304,
                              child:  TextField(
                                  decoration: InputDecoration(
                                    labelText: 'IFSC Code',
                                
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                  ),
                                ),
                    
                            ),

                    

                    
                       
                  
                               Text("Opening Balance ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
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
            
              Expanded(
                child: Container(
        
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  
                  controller: controller2,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                   
                    border: InputBorder.none,
                    hintText: '0',
                    // Adjust horizontal padding
                  ),
                  onChanged: (value) {
                    setState(() {
                      rate = double.tryParse(value) ?? 0.00;
                    });
                  },
                ),
              ),
               Container(
                width: 30,
                color:  Color.fromARGB(255, 88, 184, 248),
                 child: IconButton(
                         icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Colors.white), // Down arrow icon with size 20
                         onPressed: decrementrate,
                         
                       ),
               ),
              Container(
                width: 30,
              
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 64, 176, 251),
    border: Border.all(color: Color.fromARGB(255, 64, 176, 251)),
    borderRadius: BorderRadius.only(
      bottomRight: Radius.circular(10),
      topRight: Radius.circular(10)
    )
  ),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_up_rounded, size: 20,color: Colors.white), // Up arrow icon with size 20
                  onPressed: incrementrate,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),


                               Text("Closing Balance",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
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
            
              Expanded(
                child: Container(
        
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  
                  controller: controller3,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                   
                    border: InputBorder.none,
                    hintText: '0',
                    // Adjust horizontal padding
                  ),
                  onChanged: (value) {
                    setState(() {
                      margin = double.tryParse(value) ?? 0.00;
                    });
                  },
                ),
              ),
               Container(
                width: 30,
                color:  Color.fromARGB(255, 88, 184, 248),
                 child: IconButton(
                         icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Colors.white), // Down arrow icon with size 20
                         onPressed: decrementmargin,
                         
                       ),
               ),
              Container(
                width: 30,
              
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 64, 176, 251),
    border: Border.all(color: Color.fromARGB(255, 64, 176, 251)),
    borderRadius: BorderRadius.only(
      bottomRight: Radius.circular(10),
      topRight: Radius.circular(10)
    )
  ),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_up_rounded, size: 20,color: Colors.white), // Up arrow icon with size 20
                  onPressed: incrementmargin,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),


                        


                            SizedBox(height: 10,),

                  

         SizedBox(height: 20,),

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
              

              SizedBox(height: 25,),
             
                
                     
                
                   SizedBox(height: 15,),

                   Row(
                     children:[
                      SizedBox(width: 20,),

                      SizedBox(
                      width: 270,
                       child: ElevatedButton(
                                         onPressed: () {
                        // Your onPressed logic goes here
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
