import 'package:beposoft/pages/ACCOUNTS/add_recipts.dart';
import 'package:beposoft/pages/ACCOUNTS/credit_note_list.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/BDO/bdo_customer_list.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/BDO/bdo_order_list.dart';
import 'package:beposoft/pages/BDO/order_request.dart';
import 'package:beposoft/pages/BDO/performa_invoice.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class bod_oredr_list extends StatefulWidget {
  const bod_oredr_list({super.key});

  @override
  State<bod_oredr_list> createState() => _bod_oredr_listState();
}

class _bod_oredr_listState extends State<bod_oredr_list> {


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
  
  
     List<String>  company = ["BEPOSITIVE RACING PRIVATE LIMITED",'MICHAEL EXPORT AND IMPORT PRIVATE LIMITED'];
  String selectcomp="BEPOSITIVE RACING PRIVATE LIMITED";

   List<String>  status = ["sort on status",'Invoice created','invoice approved'];
  String selectstatus="sort on status";


  drower d=drower();

    Widget _buildDropdownTile(BuildContext context, String title, List<String> options) {
    return ExpansionTile(
      title: Text(title),
      children: options.map((option) {
        return ListTile(
          title: Text(option),
          onTap: () {
            Navigator.pop(context);
            d.navigateToSelectedPage2(context, option); // Navigate to selected page
          },
        );
      }).toList(),
    );
  }


    List<String>  user = ["",];
  String selectuser="";

   DateTime? _selectedDate=DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

   DateTime? _selectedDate2=DateTime.now();

    Future<void> _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate2 ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate2) {
      setState(() {
        _selectedDate2 = picked;
      });
    }
  }

 
  var selectedfile;
   @override
  void initState() {
    super.initState();
   

     
    

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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>bdo_dashbord()));
              },
            ),
                  ListTile(
              leading: Icon(Icons.person),
              title: Text('Customer'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>bdo_customer_list()));
              },
            ),
             Divider(),
         
            _buildDropdownTile(context, 'Proforma Invoice', ['New Proforma Invoice', 'Proforma Invoice List',]),
            _buildDropdownTile(context, 'Orders', ['New Orders', 'Orders List']),
             Divider(),

             Text("Others"),
             Divider(),






           

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

        body: Container(
            child: Column(
              children: [
                 Padding(
                padding: const EdgeInsets.only(top: 20, left: 50),
                child: Text(
                  "BILLS",
                  style: TextStyle(
                    letterSpacing: 9.0,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
                              
                Padding(
                  padding: const EdgeInsets.only(top: 5,left: 15,right: 15),
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
                        SizedBox(height: 15,),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
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
                              'Search Item...',
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
                          ),
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
                                  child: Text(value,style: TextStyle(fontSize: 10)),
                                );
                              }).toList(),
                              icon: Container(
                                padding: EdgeInsets.only(left: 15), // Adjust padding as needed
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
                              value: selectstatus,
                              underline: Container(), // This removes the underline
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectstatus = newValue!;
                                  print(selectstatus);
                                });
                              },
                              items: status.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,style: TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              icon: Container(
                                padding: EdgeInsets.only(left: 150), // Adjust padding as needed
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           SizedBox(height: 15,),
                           Text("Start date",style: TextStyle(fontSize: 15,),),
                            SizedBox(height: 5,),

                            Container(
  width: 144,
  height: 49,
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.circular(8.0),
  ),
  child: TextFormField(
    readOnly: true,
    controller: TextEditingController(
      text: _selectedDate != null
          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
          : "",
    ),
    onTap: () => _selectDate(context),
    decoration: InputDecoration(
      labelText: '',
      suffixIcon: Icon(Icons.calendar_today),
      border: InputBorder.none, // This removes the underline
    ), 
  ), 
),
                        ],
                      ),SizedBox(width: 12,),
                      Column(
                      
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [  
                      SizedBox(height: 15,),
                           Text("End date",style: TextStyle(fontSize: 15,),),
                            SizedBox(height: 5,),

                            Container(
  width: 144,
  height: 49,
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.circular(8.0),
  ),
  child: TextFormField(
    readOnly: true,
    controller: TextEditingController(
      text: _selectedDate2 != null
          ? "${_selectedDate2!.day}/${_selectedDate2!.month}/${_selectedDate2!.year}"
          : "",
    ),
    onTap: () => _selectDate2(context),
    decoration: InputDecoration(
      labelText: '',
      suffixIcon: Icon(Icons.calendar_today),
      border: InputBorder.none, // This removes the underline
    ),
  ),
),


                        ],
                      )

                    ],
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

             
                       
               
                     SizedBox(height: 20,)
                      ],
                    ),
                  )),

                ),
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
          MaterialPageRoute(builder: (context) => performa_invoice()),
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
          MaterialPageRoute(builder: (context) => bdo_order_request()),
        );
        break;
        case 'Option 4':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bod_oredr_list()),
        );
        break; 
      default:
        // Handle default case or unexpected options
        break;
    }
  }
}