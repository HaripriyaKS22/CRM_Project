
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/attribute.dart';
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




class add_new_stock extends StatefulWidget {
  const add_new_stock({super.key});

  @override
  State<add_new_stock> createState() => _add_new_stockState();
}

class _add_new_stockState extends State<add_new_stock> {
  Attribute attribute = Attribute();

  static int incrementedValue = 1;

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

  List<String> bank = ["ICIC", 'SBI', 'HDFC'];
  String selectbank = "ICIC";

  var set1 = 1;
  var set2 = 0;

//dateselection
  DateTime selectedDate = DateTime.now();

  late int counter;
// void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

  //searchable dropdown

  Attribute add=Attribute();

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
  var count = 1;
  void increment() {
    count = count + 1;
  }

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
              onPressed: () {},
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 121, 121, 121),
                          border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "New Stock( Variable Product ) ",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 13),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "External ID",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',
                            prefixIcon: Icon(Icons.local_play),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Select Product",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 46,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text(
                              'Select Item',
                              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                            ),
                            items: items
                                .map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14))))
                                .toList(),
                            value: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = items.firstWhere((item) => item.toLowerCase() == value!.toLowerCase(), orElse: () => "null");
                                print(selectedValue);
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "User management",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),


                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
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
                  SizedBox(width: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
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
            SizedBox(height: 10),
            SizedBox(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: incrementedValue,
                itemBuilder: (context, index) {
                  print(incrementedValue);
                  return  MyCard(count: incrementedValue);
                  
                },
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 50,
                    child: ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
         
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Your form fields go here
                TextFormField(
                  decoration: InputDecoration(labelText: 'Attribute'),
                ),
               
              ],
            ),
          ),
          actions: [
SizedBox(
  height: 30,
  width: 100,
  child: ElevatedButton(
    onPressed: () {
      Navigator.of(context).pop(); // Close the dialog
    },
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 198, 198, 198)), // Change button color if needed
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Adjust the border radius here
        ),
      ),
    ),
    child: Text('Cancel',style: TextStyle(color: Colors.white),),
  ),
),

           SizedBox(
  height: 30,
  width: 90,
  child: ElevatedButton(
    onPressed: () {
      Navigator.of(context).pop(); // Close the dialog
    },
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Change button color if needed
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Adjust the border radius here
        ),
      ),
    ),
    child: Text('save',style: TextStyle(color: Colors.white),),
  ),
),

          ],
        );
      },
    );
  },
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 92, 150, 244)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    fixedSize: MaterialStateProperty.all<Size>(Size(95, 15)),
  ),
  child: Text("Add Attribute", style: TextStyle(color: Colors.white)),
),

                  ),
                  SizedBox(width: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 50,
                    child: ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
         
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Your form fields go here
                TextFormField(
                  decoration: InputDecoration(labelText: 'Attribute'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Variant'),
                ),
              ],
            ),
          ),
          actions: [
SizedBox(
  height: 30,
  width: 100,
  child: ElevatedButton(
    onPressed: () {
      Navigator.of(context).pop(); // Close the dialog
    },
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 198, 198, 198)), // Change button color if needed
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Adjust the border radius here
        ),
      ),
    ),
    child: Text('Cancel',style: TextStyle(color: Colors.white),),
  ),
),

           SizedBox(
  height: 30,
  width: 90,
  child: ElevatedButton(
    onPressed: () {
      Navigator.of(context).pop(); // Close the dialog
    },
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Change button color if needed
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Adjust the border radius here
        ),
      ),
    ),
    child: Text('save',style: TextStyle(color: Colors.white),),
  ),
),

          ],
        );
      },
    );
  },
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 248, 93, 93)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    fixedSize: MaterialStateProperty.all<Size>(Size(95, 15)),
  ),
  child: Text("Add Variant", style: TextStyle(color: Colors.white)),
),

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
                  width: MediaQuery.of(context).size.width * 0.6,
                  color: Color.fromARGB(255, 215, 201, 201),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Submit logic here
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 248, 93, 93)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      fixedSize: MaterialStateProperty.all<Size>(Size(105, 30)),
                    ),
                    child: Text("Submit", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
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

// ignore: must_be_immutable
class MyCard extends StatefulWidget {
  var count;

  MyCard({required this.count});

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  Attribute attribute = Attribute();
  var set2 = 0;

  add_new_stock add = add_new_stock();
  var c;

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
    return SizedBox(
          height: 260,
        
          child: Card(
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Color.fromARGB(255, 236, 236, 236)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Select Attribute",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonHideUnderline(
                      child: Container(
                        
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
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
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
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Select Variant",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonHideUnderline(
                      child: Container(
                       
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
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
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
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        );
      
  }
}
