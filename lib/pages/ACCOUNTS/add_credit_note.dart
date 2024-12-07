

import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
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
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_customer.dart';
import 'package:shared_preferences/shared_preferences.dart';




class add_credit_note extends StatefulWidget {
  const add_credit_note({super.key});

  @override
  State<add_credit_note> createState() => _add_credit_noteState();
}

class _add_credit_noteState extends State<add_credit_note> {

   List<String>  bank = ["ICIC",'SBI','HDFC'];
  String selectbank="ICIC";

//dateselection
   DateTime selectedDate = DateTime.now();
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
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/logo.png",
                        width: 150, // Change width to desired size
                        height: 150, // Change height to desired size
                        fit: BoxFit
                            .contain, // Use BoxFit.contain to maintain aspect ratio
                      ),
                    ],
                  )),
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => dashboard()));
                },
              ),
              _buildDropdownTile(context, 'Reports', [
                'Sales Report',
                'Credit Sales Report',
                'COD Sales Report',
                'Statewise Sales Report',
                'Expence Report',
                'Delivery Report',
                'Product Sale Report',
                'Stock Report',
                'Damaged Stock'
              ]),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Company'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_company()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Departments'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => add_department()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Supervisors'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => add_supervisor()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Family'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_family()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Bank'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_bank()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('States'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_state()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Attributes'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_attribute()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Services'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CourierServices()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
               ListTile(
                leading: Icon(Icons.person),
                title: Text('Delivery Notes'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WarehouseOrderView(status: null,)));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              Divider(),
              _buildDropdownTile(context, 'Customers', [
                'Add Customer',
                'Customers',
              ]),
              _buildDropdownTile(context, 'Staff', [
                'Add Staff',
                'Staff',
              ]),
              _buildDropdownTile(context, 'Credit Note', [
                'Add Credit Note',
                'Credit Note List',
              ]),
              _buildDropdownTile(context, 'Proforma Invoice', [
                'New Proforma Invoice',
                'Proforma Invoice List',
              ]),
              _buildDropdownTile(context, 'Delivery Note',
                  ['Delivery Note List', 'Daily Goods Movement']),
              _buildDropdownTile(
                  context, 'Orders', ['New Orders', 'Orders List']),
              Divider(),
              Text("Others"),
              Divider(),
              _buildDropdownTile(context, 'Product', [
                'Product List',
                'Product Add',
                'Stock',
              ]),
              _buildDropdownTile(context, 'Expence', [
                'Add Expence',
                'Expence List',
              ]),
              _buildDropdownTile(
                  context, 'GRV', ['Create New GRV', 'GRVs List']),
              _buildDropdownTile(context, 'Banking Module',
                  ['Add Bank ', 'List', 'Other Transfer']),
              Divider(),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Methods'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Methods()));
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
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              Text(
                "CREDIT NOTE LIST ",
                style: TextStyle(fontSize: 20, letterSpacing: 9.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                       
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 121, 121, 121),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Text(" New Credit Note ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 13),
                            SizedBox(
                              width: 146,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => add_new_customer()));
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 4, 171, 29)),
                                ),
                                child: Text("New Customer", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: DropdownButton<String>(
                            value: selectcomp,
                            underline: Container(),
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
                                  style: TextStyle(fontSize: 10),
                                ),
                              );
                            }).toList(),
                            icon: Container(
                              padding: EdgeInsets.only(left: 9),
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.arrow_drop_down),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Amount", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
 width: MediaQuery.of(context).size.width * 0.9,                      
   child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            prefixIcon: Icon(Icons.attach_money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Customer", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 46,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
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
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          value: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = items.firstWhere((item) => item.toLowerCase() == value!.toLowerCase(), orElse: () => "null");
                              print(selectedValue);
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
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              textEditingController.clear();
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Payement Date", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 46,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 20),
                            
                            Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 116, 116, 116)),
                              ),
                              SizedBox(width: 160,),
                            

                            
                           
                            GestureDetector(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Icon(Icons.date_range),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width * 0.8,
                            color: Color.fromARGB(255, 215, 201, 201),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text("Transaction Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                      SizedBox(height: 10),
                      Text("Bank Name", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 49,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 20),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 1),
                                ),
                                child: DropdownButton<String>(
                                  value: selectbank,
                                  underline: Container(),
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
                                    padding: EdgeInsets.only(left: 180),
                                    alignment: Alignment.centerRight,
                                    child: Icon(Icons.arrow_drop_down),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Transaction Id", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',
                            prefixIcon: Icon(Icons.payment),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width * 0.8,
                            color: Color.fromARGB(255, 215, 201, 201),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text("Comment", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Enter',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                          maxLines: null, // Set maxLines to null for a multi-line text input
                        ),
                      ),
                      SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {
                          // Your onPressed logic goes here
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 244, 66, 66)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(MediaQuery.of(context).size.width * 0.4, 50), // Set your desired width and height
                          ),
                        ),
                        child: Text("Submit", style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(height: 20),
                    ],
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