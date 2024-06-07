
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

class new_product extends StatefulWidget {
  const new_product({super.key});

  @override
  State<new_product> createState() => _new_productState();
}

class _new_productState extends State<new_product> {

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
  List<String>  categories = ["Joishya",'Hanvi','nimitha','Hari'];
  String selectededu="Hari";
  List<String>  type = ["Single Product",'varible Product'];
  String selecttype="Single Product";
  List<String>  unit = ["BOX",' NOS','PRS','SET'];
  String selectunit="BOX";
 bool checkbox3 = false;
 bool checkbox1 = false;
bool checkbox2 = false;
bool checkbox4 = false;



double number = 0.00;
double weight= 0.00;
double xsize = 0.00;
double xoversize = 0.00;
double ysize = 0.00;
double yoversize = 0.00;
double zsize = 0.00;
double zoversize = 0.00;

double diameter = 0.00;
double diametersize = 0.00;
double sectionsize = 0.00;


double prate = 0.00;
double tax = 0.00;
double spricetax = 0.00;


  final TextEditingController _controller = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();
  final TextEditingController controller5 = TextEditingController();
  final TextEditingController controller6 = TextEditingController();
  final TextEditingController controller7 = TextEditingController();
  final TextEditingController controller8 = TextEditingController();
  final TextEditingController controller9 = TextEditingController();
  final TextEditingController controller10 = TextEditingController();
  final TextEditingController controller11 = TextEditingController();
  final TextEditingController controller12 = TextEditingController();
  final TextEditingController controller13 = TextEditingController();
  final TextEditingController controller14 = TextEditingController();





  void incrementNumber() {
    setState(() {
      number += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
      _controller.text = number.toStringAsFixed(2);
      
    });
  }

   void incrementweight() {
    setState(() {
      weight += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
       controller2.text = weight.toStringAsFixed(2);

    });
  }
  void incrementxsize() {
    setState(() {
      xsize += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller3.text = xsize.toStringAsFixed(2);

    });
  }
  void incrementxoversize() {
    setState(() {
      xoversize += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller4.text = xoversize.toStringAsFixed(2);

    });
  }
  void incrementysize() {
    setState(() {
      ysize += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller5.text = ysize.toStringAsFixed(2);

    });
  }
  void incrementyoversize() {
    setState(() {
      yoversize += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller6.text = yoversize.toStringAsFixed(2);

    });
  }

  void incrementzsize() {
    setState(() {
      zsize += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller7.text = zsize.toStringAsFixed(2);

    });
  }
  void incrementzoversize() {
    setState(() {
      zoversize += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller8.text = zoversize.toStringAsFixed(2);

    });
  }


  void incrementdiameter() {
    setState(() {
      diameter += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller9.text = diameter.toStringAsFixed(2);

    });
  }
  void incrementydiametersize() {
    setState(() {
      diametersize += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller10.text = diametersize.toStringAsFixed(2);

    });
  }
  void incrementsectionsize() {
    setState(() {
      sectionsize += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller11.text = sectionsize.toStringAsFixed(2);

    });
  }
void incrementprate() {
    setState(() {
      prate += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller12.text = prate.toStringAsFixed(2);

    });
  }
void incrementtax() {
    setState(() {
      tax += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller13.text = tax.toStringAsFixed(2);

    });
  }
void incrementspricetax() {
    setState(() {
      spricetax += 0.01; // Increment by 0.01 (you can adjust the increment value as needed)
     
       controller14.text = spricetax.toStringAsFixed(2);

    });
  }

//decrementttttttttttttttttttttttttttttttttttttt

  void decrementNumber() {
    setState(() {
      if (number >= 0.01) {
        number -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        _controller.text = number.toStringAsFixed(2);
         
      }
    });
  }
  void decrementweight() {
    setState(() {
      if (xsize >= 0.01) {
        xsize -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
      
         controller2.text = xsize.toStringAsFixed(2);
      }
    });
  }
  void decrementxsize() {
    setState(() {
      if (xsize >= 0.01) {
        xsize -= 0.01; 
       
         controller3.text = xsize.toStringAsFixed(2);
      }
    });
  }


void decrementxoversize() {
    setState(() {
      if (xoversize >= 0.01) {
        xoversize -= 0.01; 
       
         controller4.text = xoversize.toStringAsFixed(2);
      }
    });
  }


   void decrementysize() {
    setState(() {
      if (ysize >= 0.01) {
        ysize -= 0.01; 
       
         controller5.text = ysize.toStringAsFixed(2);
      }
    });
  }


void decrementyoversize() {
    setState(() {
      if (yoversize >= 0.01) {
        yoversize -= 0.01; 
       
         controller6.text = yoversize.toStringAsFixed(2);
      }
    });
  }
   void decrementzsize() {
    setState(() {
      if (zsize >= 0.01) {
        zsize -= 0.01; 
       
         controller7.text = zsize.toStringAsFixed(2);
      }
    });
  }


void decrementzoversize() {
    setState(() {
      if (zoversize >= 0.01) {
        zoversize -= 0.01; 
       
         controller8.text = zoversize.toStringAsFixed(2);
      }
    });
  }


  void decrementdiameter() {
    setState(() {
      if (diameter >= 0.01) {
        diameter -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller9.text = diameter.toStringAsFixed(2);
         
      }
    });
  }
  void decrementdiametersize() {
    setState(() {
      if (diametersize >= 0.01) {
        diametersize -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller10.text = diametersize.toStringAsFixed(2);
         
      }
    });
  }
  void decrementsectionsize() {
    setState(() {
      if (sectionsize >= 0.01) {
        sectionsize -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller11.text = sectionsize.toStringAsFixed(2);
         
      }
    });
  }
void decrementprate() {
    setState(() {
      if (prate >= 0.01) {
        prate -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller12.text = prate.toStringAsFixed(2);
         
      }
    });
  }
void decrementstax() {
    setState(() {
      if (tax >= 0.01) {
        tax -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller13.text = tax.toStringAsFixed(2);
         
      }
    });
  }
void decrementspricetax() {
    setState(() {
      if (spricetax >= 0.01) {
        spricetax -= 0.01; // Decrement by 0.01 (you can adjust the decrement value as needed)
        controller14.text = spricetax.toStringAsFixed(2);
         
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.text = number.toStringAsFixed(2);
    controller2.text = weight.toStringAsFixed(2);
    controller3.text = xsize.toStringAsFixed(2);
    controller4.text = xoversize.toStringAsFixed(2);
    controller5.text = ysize.toStringAsFixed(2);
    controller6.text = yoversize.toStringAsFixed(2);
    controller7.text = zsize.toStringAsFixed(2);
    controller8.text = zoversize.toStringAsFixed(2);
    controller9.text = diameter.toStringAsFixed(2);
    controller10.text = diametersize.toStringAsFixed(2);
    controller11.text = sectionsize.toStringAsFixed(2);
    controller12.text = prate.toStringAsFixed(2);
    controller13.text = tax.toStringAsFixed(2);
    controller14.text = spricetax.toStringAsFixed(2);

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

          child: Padding(
            padding: const EdgeInsets.only(top:30,left: 12,right: 12),
            child: Container(
              color:Colors.white,
              width: 700,
             
              
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                     Text("New Product ",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),


                    ],
                  ),
                  SizedBox(height: 15,),
                 SizedBox(
                  height: 300,
                  width: 340,
                   child: Card(
                    elevation: 4,
                    child: Container(
                          decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0), // Set border radius for Container
                          border: Border.all(color: Color.fromARGB(255, 236, 236, 236)), // Add border to Container if needed
                        ),
                                    
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(

                         
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text("ID ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),


                           TextField(
                          decoration: InputDecoration(
                            labelText: 'AAA00',
                            prefixIcon: Icon(Icons.numbers), 
                            border: OutlineInputBorder( 
                              borderRadius: BorderRadius.circular(10.0), 
                              borderSide: BorderSide(color: Colors.grey), 
                              
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding

                          ),
                        ),
                         SizedBox(height: 10,),
                         Text("Product Name * ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),


                           TextField(
                                decoration: InputDecoration(
                                  labelText: 'Label/Description of prodct',
                                  prefixIcon: Icon(Icons.mode_edit),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Set vertical padding
                                ),
                              ),
                                                      SizedBox(height: 10,),
                         Text("HSN Code",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),

                           TextField(
                                decoration: InputDecoration(
                                  labelText: 'Index',
                                  
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 10.0), 
                                  
                                  // Set vertical padding
                                ),

                              ),


                            
                                           
                                           
                                           
                                           
                                           
                          ],
                        ),
                      ),
                    ),
                   
                   ),
                 ),
                 SizedBox(height: 15,),
                SizedBox(
  height: 500,
  width: 340,
  child: Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Set border radius
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0), // Set border radius for Container
        border: Border.all(color: Color.fromARGB(255, 236, 236, 236)), // Add border to Container if needed
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Product Type * ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
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
                        value: selecttype,
                        underline: Container(), // This removes the underline
                        onChanged: (String? newValue) {
                          setState(() {
                            selecttype = newValue!;
                            print(selecttype);
                          });
                        },
                        items: type.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        icon: Container(
                          padding: EdgeInsets.only(left: 137), // Adjust padding as needed
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text("Checkbox Group", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text('Bepocart'),
              value: checkbox1,
              onChanged: (bool? value) {
                setState(() {
                  checkbox1 = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading, // Place checkbox on the left side
            ),
            CheckboxListTile(
              title: Text('Skating'),
              value: checkbox2,
              onChanged: (bool? value) {
                setState(() {
                  checkbox2 = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading, // Place checkbox on the left side
            ),
            CheckboxListTile(
              title: Text('Cycling '),
              value: checkbox3,
              onChanged: (bool? value) {
                setState(() {
                  checkbox3 = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading, // Place checkbox on the left side
            ),

             CheckboxListTile(
              title: Text('Fitness '),
              value: checkbox4,
              onChanged: (bool? value) {
                setState(() {
                  checkbox4 = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading, // Place checkbox on the left side
            ),
            SizedBox(height: 10),
            Text("Unit * ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
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
                        value: selectunit,
                        underline: Container(), // This removes the underline
                        onChanged: (String? newValue) {
                          setState(() {
                            selectunit = newValue!;
                            print(selectunit);
                          });
                        },
                        items: unit.map<DropdownMenuItem<String>>((String value) {
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
          ],
        ),
      ),
    ),
  ),
),


                 SizedBox(height: 15,),
                 SizedBox(
                  height: 900,
                  width: 340,
                   child: Card(
                    elevation: 4,
                     shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Set border radius
    ),
                    
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0), // Set border radius for Container
                        border: Border.all(color: Color.fromARGB(255, 236, 236, 236)), // Add border to Container if needed
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(

                         
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text("Proprieties ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                  
                           TextField(
                          decoration: InputDecoration(
                            labelText: 'Materials ',
                            
                            border: OutlineInputBorder( 
                              borderRadius: BorderRadius.circular(10.0), 
                              borderSide: BorderSide(color: Colors.grey), 
                              
                            ),
                             contentPadding: EdgeInsets.symmetric(vertical: 8.0), 

                          ),
                        ),

                          SizedBox(height: 10,),

                           Text("Thickness ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
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
                  
                  controller: _controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                     prefixIcon: Icon(Icons.line_weight),
                    border: InputBorder.none,
                    hintText: '',
                    // Adjust horizontal padding
                  ),
                  onChanged: (value) {
                    setState(() {
                      number = double.tryParse(value) ?? 0.00;
                    });
                  },
                ),
              ),
               Container(
                width: 30,
                color:  Color.fromARGB(255, 88, 184, 248),
                 child: IconButton(
                         icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Colors.white), // Down arrow icon with size 20
                         onPressed: decrementNumber,
                         
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
                  onPressed: incrementNumber,
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
                          Text("Weight: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
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
                     prefixIcon: Icon(Icons.line_weight),
                    border: InputBorder.none,
                    hintText: '',
                    
                  ),
                  onChanged: (value) {
                    setState(() {
                      weight = double.tryParse(value) ?? 0.00;
                    });
                  },
                ),
              ),
               Container(
                width: 30,
                color:  Color.fromARGB(255, 88, 184, 248),
                 child: IconButton(
                         icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Colors.white), // Down arrow icon with size 20
                         onPressed: decrementweight,
                         
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
                  onPressed: incrementweight,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),


SizedBox(height: 15,),
Row(
  children: [
     


     Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text("X size: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),


         Container(
              width: 150,
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
                        hintText: '',
                        
                      ),
                      onChanged: (value) {
                        setState(() {
                          xsize = double.tryParse(value) ?? 0.00;
                        });
                      },
                    ),
                  ),
                   Container(
                    color:  Color.fromARGB(255, 88, 184, 248),
                    width: 30,
                     child: IconButton(
                             icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Color.fromARGB(255, 255, 255, 255)), // Down arrow icon with size 20
                             onPressed: decrementxsize,
                             
                           ),
                   ),
                  Container(
                     width: 30,
                  
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 64, 176, 251),
             border: Border.all(color: Color.fromARGB(255, 64, 176, 251),),
             borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(10),
          topRight: Radius.circular(10)
             )
           ),
                    child: IconButton(
                      icon: Icon(Icons.keyboard_arrow_up_rounded, size: 20,color: Color.fromARGB(255, 255, 255, 255)), // Up arrow icon with size 20
                      onPressed: incrementxsize,
                    ),
                  ),
                ],
              ),
            ),
          ),
             ],
           ),
         ),
       ],
     ),
SizedBox(width: 5,),

 Column(
  
  crossAxisAlignment: CrossAxisAlignment.start,
   children: [
    

    Text("X oversize: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
     Container(
              width: 150,
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
                      
                      controller: controller4,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        
                        border: InputBorder.none,
                        hintText: '',
                        
                      ),
                      onChanged: (value) {
                        setState(() {
                          xoversize = double.tryParse(value) ?? 0.00;
                        });
                      },
                    ),
                  ),
                   Container(
                    width: 30,
                    color:  Color.fromARGB(255, 88, 184, 248),
                     child: IconButton(
                             icon: Icon(Icons.keyboard_arrow_down_rounded, size: 15,color: Colors.white), // Down arrow icon with size 20
                             onPressed: decrementxoversize,
                             
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
                      icon: Icon(Icons.keyboard_arrow_up_rounded, size: 15,color: Colors.white), // Up arrow icon with size 20
                      onPressed: incrementxoversize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
     ),
   ],
 ),
  ],
),

//yyyyyyyyyyyyyyy


SizedBox(height: 15,),
Row(
  children: [
     


     Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text("Y size: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),


         Container(
              width: 150,
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
                      
                      controller: controller5,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        
                        border: InputBorder.none,
                        hintText: '',
                        
                      ),
                      onChanged: (value) {
                        setState(() {
                          ysize = double.tryParse(value) ?? 0.00;
                        });
                      },
                    ),
                  ),
                   Container(
                    color:  Color.fromARGB(255, 88, 184, 248),
                    width: 30,
                     child: IconButton(
                             icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Color.fromARGB(255, 255, 255, 255)), // Down arrow icon with size 20
                             onPressed: decrementysize,
                             
                           ),
                   ),
                  Container(
                     width: 30,
                  
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 64, 176, 251),
             border: Border.all(color: Color.fromARGB(255, 64, 176, 251),),
             borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(10),
          topRight: Radius.circular(10)
             )
           ),
                    child: IconButton(
                      icon: Icon(Icons.keyboard_arrow_up_rounded, size: 20,color: Color.fromARGB(255, 255, 255, 255)), // Up arrow icon with size 20
                      onPressed: incrementysize,
                    ),
                  ),
                ],
              ),
            ),
          ),
             ],
           ),
         ),
       ],
     ),
SizedBox(width: 5,),

 Column(
  
  crossAxisAlignment: CrossAxisAlignment.start,
   children: [
    

    Text("Y oversize: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
     Container(
              width: 150,
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
                      
                      controller: controller6,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        
                        border: InputBorder.none,
                        hintText: '',
                        
                      ),
                      onChanged: (value) {
                        setState(() {
                          yoversize = double.tryParse(value) ?? 0.00;
                        });
                      },
                    ),
                  ),
                   Container(
                    width: 30,
                    color:  Color.fromARGB(255, 88, 184, 248),
                     child: IconButton(
                             icon: Icon(Icons.keyboard_arrow_down_rounded, size: 15,color: Colors.white), // Down arrow icon with size 20
                             onPressed: decrementyoversize,
                             
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
                      icon: Icon(Icons.keyboard_arrow_up_rounded, size: 15,color: Colors.white), // Up arrow icon with size 20
                      onPressed: incrementyoversize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
     ),
   ],
 ),
  ],
),



//zzzzzzzzzzzzzzzzzzz


SizedBox(height: 15,),
Row(
  children: [
     


     Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text("Z size: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),


         Container(
              width: 150,
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
                      
                      controller: controller7,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        
                        border: InputBorder.none,
                        hintText: '',
                        
                      ),
                      onChanged: (value) {
                        setState(() {
                          zsize = double.tryParse(value) ?? 0.00;
                        });
                      },
                    ),
                  ),
                   Container(
                    color:  Color.fromARGB(255, 88, 184, 248),
                    width: 30,
                     child: IconButton(
                             icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Color.fromARGB(255, 255, 255, 255)), // Down arrow icon with size 20
                             onPressed: decrementzsize,
                             
                           ),
                   ),
                  Container(
                     width: 30,
                  
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 64, 176, 251),
             border: Border.all(color: Color.fromARGB(255, 64, 176, 251),),
             borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(10),
          topRight: Radius.circular(10)
             )
           ),
                    child: IconButton(
                      icon: Icon(Icons.keyboard_arrow_up_rounded, size: 20,color: Color.fromARGB(255, 255, 255, 255)), // Up arrow icon with size 20
                      onPressed: incrementzsize,
                    ),
                  ),
                ],
              ),
            ),
          ),
             ],
           ),
         ),
       ],
     ),
SizedBox(width: 5,),

 Column(
  
  crossAxisAlignment: CrossAxisAlignment.start,
   children: [
    

    Text("Z oversize: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
     Container(
              width: 150,
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
                      
                      controller: controller8,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        
                        border: InputBorder.none,
                        hintText: '',
                        
                      ),
                      onChanged: (value) {
                        setState(() {
                          zoversize = double.tryParse(value) ?? 0.00;
                        });
                      },
                    ),
                  ),
                   Container(
                    width: 30,
                    color:  Color.fromARGB(255, 88, 184, 248),
                     child: IconButton(
                             icon: Icon(Icons.keyboard_arrow_down_rounded, size: 15,color: Colors.white), // Down arrow icon with size 20
                             onPressed: decrementzoversize,
                             
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
                      icon: Icon(Icons.keyboard_arrow_up_rounded, size: 15,color: Colors.white), // Up arrow icon with size 20
                      onPressed: incrementzoversize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
     ),
   ],
 ),
  ],
),


 SizedBox(
                height: 30,
              ),
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

               SizedBox(
                height: 20,
              ),




// diameterrrrrrrrrrrrrrrrrrrrrrrrrrrrr
              
                        

          Text("Diameter ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
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
                  
                  controller: controller9,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                     prefixIcon: Icon(Icons.line_weight),
                    border: InputBorder.none,
                    hintText: '',
                    // Adjust horizontal padding
                  ),
                  onChanged: (value) {
                    setState(() {
                      diameter = double.tryParse(value) ?? 0.00;
                    });
                  },
                ),
              ),
               Container(
                width: 30,
                color:  Color.fromARGB(255, 88, 184, 248),
                 child: IconButton(
                         icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Colors.white), // Down arrow icon with size 20
                         onPressed: decrementdiameter,
                         
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
                  onPressed: incrementdiameter,
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
                          Text("Diameter oversize: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
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
                  
                  controller: controller10,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                     prefixIcon: Icon(Icons.line_weight),
                    border: InputBorder.none,
                    hintText: '',
                    
                  ),
                  onChanged: (value) {
                    setState(() {
                      diametersize = double.tryParse(value) ?? 0.00;
                    });
                  },
                ),
              ),
               Container(
                width: 30,
                color:  Color.fromARGB(255, 88, 184, 248),
                 child: IconButton(
                         icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Colors.white), // Down arrow icon with size 20
                         onPressed: decrementdiametersize,
                         
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
                  onPressed: incrementydiametersize,
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
                          Text("Section size: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
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
                  
                  controller: controller11,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                     prefixIcon: Icon(Icons.line_weight),
                    border: InputBorder.none,
                    hintText: '',
                    
                  ),
                  onChanged: (value) {
                    setState(() {
                      sectionsize = double.tryParse(value) ?? 0.00;
                    });
                  },
                ),
              ),
               Container(
                width: 30,
                color:  Color.fromARGB(255, 88, 184, 248),
                 child: IconButton(
                         icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Colors.white), // Down arrow icon with size 20
                         onPressed: decrementsectionsize,
                         
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
                  onPressed: incrementsectionsize,
                ),
              ),
            ],
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
                   
                   ),
                 ),



                  //next cardddddddddddddddddddddddddddddddddddddddddddd 






                    SizedBox(height: 15,),

                       SizedBox(
                  height: 480,
                  width: 340,
                   child: Card(
                    elevation: 4,
                    child: Container(
                          decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0), // Set border radius for Container
                          border: Border.all(color: Color.fromARGB(255, 236, 236, 236)), // Add border to Container if needed
                        ),
                                    
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(

                         
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: 10,),


                           Text("Other Information",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),

                          SizedBox(height: 15,),
                          Text("Purchase Rate (Including Tax): ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                     
                                 Container(
          width: 310,
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 158, 157, 157)),
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
                  
                  controller: controller12,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                     prefixIcon: Icon(Icons.rate_review),
                    border: InputBorder.none,
                    hintText: '',
                    
                  ),
                  onChanged: (value) {
                    setState(() {
                      prate = double.tryParse(value) ?? 0.00;
                    });
                  },
                ),
              ),
               Container(
                width: 30,
                color:  Color.fromARGB(255, 88, 184, 248),
                 child: IconButton(
                         icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Colors.white), // Down arrow icon with size 20
                         onPressed: decrementprate,
                         
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
                  onPressed: incrementprate,
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

Text("Selling Price (Excluding Tax) ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          
                        



                           TextField(
                          decoration: InputDecoration(
                            labelText: ' ',
                            
                            border: OutlineInputBorder( 
                              borderRadius: BorderRadius.circular(10.0), 
                              borderSide: BorderSide(color: Colors.grey), 
                              
                            ),
                             contentPadding: EdgeInsets.symmetric(vertical: 8.0), 

                          ),
                        ),

                        


 SizedBox(height: 10,),
                          Text("Tax Amount (in %) ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
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
                  
                  controller: controller13,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                     prefixIcon: Icon(Icons.monetization_on),
                    border: InputBorder.none,
                    hintText: '',
                    
                  ),
                  onChanged: (value) {
                    setState(() {
                      tax = double.tryParse(value) ?? 0.00;
                    });
                  },
                ),
              ),
               Container(
                width: 30,
                color:  Color.fromARGB(255, 88, 184, 248),
                 child: IconButton(
                         icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Colors.white), // Down arrow icon with size 20
                         onPressed: decrementstax,
                         
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
                  onPressed: incrementtax,
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
                          Text("Actual Selling Price (Including Tax)",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
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
                  
                  controller: controller14,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                     prefixIcon: Icon(Icons.local_offer),
                    border: InputBorder.none,
                    hintText: '',
                    
                  ),
                  onChanged: (value) {
                    setState(() {
                      spricetax = double.tryParse(value) ?? 0.00;
                    });
                  },
                ),
              ),
               Container(
                width: 30,
                color:  Color.fromARGB(255, 88, 184, 248),
                 child: IconButton(
                         icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: Colors.white), // Down arrow icon with size 20
                         onPressed: decrementspricetax,
                         
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
                  onPressed: incrementspricetax,
                ),
              ),
            ],
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
                   
                   ),
                 ),

                 
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

               SizedBox(height: 13,),
              Padding(
                padding: const EdgeInsets.only(left: 120),
                child: Row(
                  children: [
                    ElevatedButton(
                  onPressed: () {
                    // Your onPressed logic goes here
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 164, 164, 164),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Set your desired border radius
                      ),
                    ),
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(85, 15), // Set your desired width and heigh
                    ),
                  ),
                  child: Text("Close",style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 13),
                
                
                ElevatedButton(
                  onPressed: () {
                    // Your onPressed logic goes here
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 244, 66, 66),
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
                
                
                  ],
                ),
              ),
              SizedBox(height: 35,)
            
            
            
                ],
            
              ),
            ),
          ),

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