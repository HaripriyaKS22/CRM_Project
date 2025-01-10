
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
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
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/new_product.dart';
import 'package:beposoft/pages/ACCOUNTS/order_request.dart';
import 'package:beposoft/pages/ACCOUNTS/purchases_request.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_customer.dart';





class log_new_grv extends StatefulWidget {
  const log_new_grv({super.key});

  @override
  State<log_new_grv> createState() => _log_new_grvState();
}

class _log_new_grvState extends State<log_new_grv> {

   List<String>  bank = ["ICIC",'SBI','HDFC'];
  String selectbank="ICIC";

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

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
  List<String>  customer = ["hari",'jerry','jerin',"joseph",'unni'];
  String selectcustomer="hari";
  
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
          
          children: [
            Container(
              width: 10, 
              child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 110, 110, 110),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "lib/assets/logo-white.png",
                        width: 100, 
                        height: 100, 
                        fit: BoxFit
                            .contain, 
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
            ),
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
              },
            ),
             ListTile(
                leading: Icon(Icons.note),
                title: Text('Credit note'),
              
                onTap: () {
                  // Open the dropdown menu
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('Add credit note'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 1');
                              },
                            ),
                            ListTile(
                              title: Text('Credit note list '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 2');
                              },
                            ),
                            
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.receipt),
                title: Text('Receipts'),
              
                onTap: () {
                  // Open the dropdown menu
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('Add Receipts'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 3');
                              },
                            ),
                            ListTile(
                              title: Text('Receipts List '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 4');
                              },
                            ),
                            
                            
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
               ListTile(
                leading: Icon(Icons.book),
                title: Text('Delivey notes'),
              
                onTap: () {
                  // Open the dropdown menu
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('Deliverys notes list'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 5');
                              },
                            ),
                            ListTile(
                              title: Text('Daily Goods Movement '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 6');
                              },
                            ),
                            
                            
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
               ListTile(
                leading: Icon(Icons.sports_basketball),
                title: Text('Orders'),
              
                onTap: () {
                  // Open the dropdown menu
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('New Orders'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 7');
                              },
                            ),
                            ListTile(
                              title: Text('orders List '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 8');
                              },
                            ),
                            
                            
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 17),
                child: Text("Others",style: TextStyle(fontSize: 15),),
              ),


              ListTile(
                leading: Icon(Icons.list),
                title: Text('Product'),
              
                onTap: () {
                  // Open the dropdown menu
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text(' Product list'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 9');
                              },
                            ),
                            ListTile(
                              title: Text('Stock '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 10');
                              },
                            ),
                            
                            
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Purchase'),
              
                onTap: () {
                  // Open the dropdown menu
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('New Purchase'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 11');
                              },
                            ),
                            ListTile(
                              title: Text('Purchase List '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 12');
                              },
                            ),
                            
                            
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.currency_bitcoin),
                title: Text('Expence'),
              
                onTap: () {
                  // Open the dropdown menu
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('Add expence'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 13');
                              },
                            ),
                            ListTile(
                              title: Text(' List Expence '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 14');
                              },
                            ),
                            
                            
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.report),
                title: Text('Reports'),
              
                onTap: () {
                  // Open the dropdown menu
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('Sales Report'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 15');
                              },
                            ),
                            ListTile(
                              title: Text('Credit Sales Report '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 16');
                              },
                            ),
                              ListTile(
                              title: Text('COD Sales Report '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 17');
                              },
                            ),
                              ListTile(
                              title: Text('Statewise Sales Report '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 18');
                              },
                            ),
                            ListTile(
                              title: Text('Expence Report'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 19');
                              },
                            ),
                            ListTile(
                              title: Text('Delivery Report '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 19');
                              },
                            ),
                              ListTile(
                              title: Text('Product Sales Report '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 20');
                              },
                            ),
                              ListTile(
                              title: Text('Stock Report '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 21');
                              },
                            ),
                             ListTile(
                              title: Text('Damaged Stock '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 22');
                              },
                            ),
                            
                            
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.grid_view),
                title: Text('GRV'),
              
                onTap: () {
                  // Open the dropdown menu
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('Create New '),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 23');
                              },
                            ),
                            ListTile(
                              title: Text('GRVs List'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 24');
                              },
                            ),
                            
                            
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
               ListTile(
              leading: Icon(Icons.settings),
              title: Text('Methods'),
              onTap: () {},
            ),
             ListTile(
                leading: Icon(Icons.backup),
                title: Text('Banking Module '),
              
                onTap: () {
                  // Open the dropdown menu
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('Add Bank'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 25');
                              },
                            ),
                            ListTile(
                              title: Text(' List'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 26');
                              },
                            ),
                             ListTile(
                              title: Text('Other Transfer'),
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToSelectedPage(context, 'Option 27');
                              },
                            ),
                            
                            
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
               ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chats'),
              onTap: () {},
            ),
              


              
            ],
          ),
        ),


        body:SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            
            children: [
              SizedBox(height: 15),
              Text(
                "NEW GRV",
                style: TextStyle(fontSize: 20, letterSpacing: 9.0, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text("Search for Invoice  *", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Select Bank',
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: DropdownButtonHideUnderline(
  child: Container(
    width: 304,
    height: 46, // Set the desired width here
    
    child: DropdownButton2<String>(
      isExpanded: true,
      hint: Text(
        'Select Item',
        
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).hintColor,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ))
          .toList(),
      value: selectedValue,
      onChanged: (value) {
        setState(() {
          // Retain the case of the selected item while performing case-insensitive comparison
          selectedValue = items.firstWhere((item) => item.toLowerCase() == value!.toLowerCase(), orElse: () => "null");
          print(selectedValue);
        });
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
        height: 40,
        // Remove the width property from buttonStyleData
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
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 4,
            right: 8,
            left: 8,
          ),
          child: TextFormField(
            expands: true,
            maxLines: null,
            controller: textEditingController,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              hintText: 'Search for an item...',
              hintStyle: const TextStyle(fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        searchMatchFn: (item, searchValue) {
          return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
        },
      ),
      // This clears the search value when you close the menu
      onMenuStateChange: (isOpen) {
        if (!isOpen) {
          textEditingController.clear();
        }
      },
    ),
  ),
),
                          ),
                        ),


                          SizedBox(height: 10),
                        Text("Select Invoice Number *", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text('Select Item'),
                              value: selectedValue,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValue = newValue;
                                });
                              },
                              items: items.map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Payment Date", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      
                        SizedBox(height: 10),
                        Text("Comment", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                              hintText: 'Enter your comment',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                            ),
                            maxLines: null,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            
                          },
                          child: Text("Submit"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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