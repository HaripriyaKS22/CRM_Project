
import 'dart:convert';

import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/order_products.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:beposoft/pages/api.dart';






class order_request extends StatefulWidget {
  const order_request({super.key});

  @override
  State<order_request> createState() => _order_requestState();
}

class _order_requestState extends State<order_request> {
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
  List<Map<String, dynamic>> products = [];
final TextEditingController searchController = TextEditingController();
List<Map<String, dynamic>> filteredProducts = [];
  List<String>  manager= ["jeshiya",'hanvi','nimitha','sandheep','sulfi'];
  String selectmanager="jeshiya";
  List<String>  address= ["empty",];
  String selectaddress="empty";
  List<Map<String, dynamic>> fam = [];
    List<Map<String, dynamic>> customer = [];
    List<Map<String, dynamic>> variant= [];

    int? selectedFamilyId;
    String selectedstaff='';
    int? selectedstaffId;
    int? selectedstateId;
  int? selectedAddressId; // Variable to store the selected address ID
  String? selectedAddressName; // Variable to store the selected address name

 Set<int> expandedRows = {};
    var famid;
    var staffid;

 @override
  void initState() {
    super.initState();
    initdata();
    
  }
  void initdata() async{
    await getprofiledata();
    getfamily();
    selectedFamilyId=famid;
    print("famiddd$selectedFamilyId");
    getstaff();
    selectedstaffId=staffid;
    getcustomer();
     getstate();
    await fetchProductList();

      searchController.addListener(() {
      filterProducts();
    });
     

  }
   void toggleExpansion(int productId) {
    setState(() {
      if (expandedRows.contains(productId)) {
        expandedRows.remove(productId);
      } else {
        expandedRows.add(productId);
      }
    });
  }
void filterProducts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products
          .where((product) => product['name'].toLowerCase().contains(query))
          .toList();
    });
  }
//dateselection
   DateTime selectedDate = DateTime.now();
     

  Future<void> _selectDate(BuildContext context) async {
       print(selectedDate);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        print("dateeee$selectedDate");
      });
    }
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }


  Future<void> fetchProductList() async {
  final token = await gettokenFromPrefs();

  try {
    final response = await http.get(
      Uri.parse("$api/api/products/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['data'];
      List<Map<String, dynamic>> productList = [];

      print("Products Response: ${response.body}");

      for (var productData in productsData) {
        List<String> familyNames = (productData['family'] as List<dynamic>?)?.map((id) => id as int).map<String>((id) => fam.firstWhere(
            (famItem) => famItem['id'] == id,
            orElse: () => {'name': 'Unknown'})['name'] as String).toList() ?? [];
        var imgurl = '$api/${productData['image']}';

        // Check if the product type is 'variant'
        if (productData['type'] == "variant") {
                      print("nameeeeeeeeeeeeeeeeeeeeeeee====${productData['name']}");


          for (var variant in productData['variant_products']) {
            print("nameeeeeeeeeeeeeeeeeeeeeeee${variant['name']}");
            // Process each variant product
            productList.add({
              'id': variant['id'],
              'name': variant['name'],
              'color': variant['color'],
              'stock': variant['stock'],
              'created_user': variant['created_user'],
              'family': familyNames,
              'image': variant['variant_images'].isNotEmpty
                  ? '$api/${variant['variant_images'][0]['image']}'
                  : imgurl, // Use variant image or fallback to main image
            });
          }
        } else {
          // Process non-variant products
          productList.add({
            'id': productData['id'],
            'name': productData['name'],
            'hsn_code': productData['hsn_code'],
            'type': productData['type'],
            'unit': productData['unit'],
            'purchase_rate': productData['purchase_rate'],
            'tax': productData['tax'],
            'exclude_price': productData['exclude_price'],
            'selling_price': productData['selling_price'],
            'stock': productData['stock'],
            'created_user': productData['created_user'],
            'family': familyNames,
            'image': imgurl,
          });
        }
      }

      setState(() {
        products = productList;
        print("Products: $products");
        filteredProducts = products;
      });
    }
  } catch (error) {
    print("Error: $error");
  }
}

Future<void> getvariant(int id, var type) async {
  print("iddddddddddddddddddd$id");
  try {
    final token = await gettokenFromPrefs();
    List<Map<String, dynamic>> productList = [];
    var response = await http.get(
      Uri.parse('$api/api/products/$id/variants/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['products'];
      print("varianttttt:$productsData");

      for (var product in productsData) {
        // Check if there is at least one image in 'variant_images'
        String firstImageUrl = product['variant_images'].isNotEmpty
            ? product['variant_images'][0]['image']
            : '';
var imgurl="$api/$firstImageUrl";
        productList.add({
          'name': product['name'],
          'color': product['color'],
          'image': imgurl, // Add the first image URL
          'is_variant:': product['is_variant:'],
          'stock': product['stock'],

        });
      }
      setState(() {
        variant = productList;
        print("variantss$variant");
      });

      print("Fetched Products : $productList");
    }
  } catch (error) {
    print("Error: $error");
  }
}

 Future<void> getcustomer() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/customers/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
          "=============================================hoiii${response.body}");
      List<Map<String, dynamic>> managerlist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print(
            "RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDhaaaii$parsed");
        for (var productData in productsData) {
          managerlist.add({
            'id': productData['id'],
            'name': productData['name'],
            'created_at': productData['created_at'],
            'manager':productData['manager']
          });
        }
        setState(() {
          customer = managerlist;

          print("cutomerrrr$customer");
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }
List<Map<String, dynamic>> stat = [];

    Future<void> getstate() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/states/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
        print("state${response.body}");
        List<Map<String, dynamic>> statelist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("stateeeeeeeeeeeee$parsed");
 for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          statelist.add({
            'id': productData['id'],
            'name': productData['name'],
            
          });
        
        }
        setState(() {
          stat = statelist;
                  print("stateeeeeeee$stat");

          
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }
  List<Map<String, dynamic>> addres = [];

    Future<void> getaddress(var id) async {
    try {
      final token = await gettokenFromPrefs();
print('urlllllllllllllllll$api/api/add/customer/address/$id/');
      var response = await http.get(
        Uri.parse('$api/api/add/customer/address/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
        print("addresres${response.body}");
        List<Map<String, dynamic>> addresslist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("addreseeeeeeeeeeeee$parsed");
 for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          addresslist.add({
            'id': productData['id'],
            'name': productData['name'],
            'email': productData['email'],
            'zipcode': productData['zipcode'],
            'address': productData['address'],
            'phone': productData['phone'],
            'country': productData['country'],
            'city': productData['city'],
            'state': productData['state'],


            
          });
        
        }
        setState(() {
          addres = addresslist;
                  print("addres$addres");

          
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }


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

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];
        List<Map<String, dynamic>> familylist = [];

        for (var productData in productsData) {
          familylist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }

        setState(() {
          fam = familylist;
          print("fammmmmmmmmmmmmm$fam");
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }
  //searchable dropdown


  Future<void> getprofiledata() async{
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse("$api/api/profile/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("==============0000000000000000000000000${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("profileeeeeee$productsData");

        setState(() {
          famid=productsData['family'];
          staffid=productsData['id'];

          print("fammmmmmmmmmmmmmid$famid");
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }


  


List<Map<String, dynamic>> sta = [];

  Future<void> getstaff() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/staffs/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
          "RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD${response.body}");
      List<Map<String, dynamic>> stafflist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$parsed");
        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          stafflist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          sta = stafflist;
          print("sataffffffffffff$sta");
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }



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
  int? selectedCustomerId;
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
      double screenWidth = MediaQuery.of(context).size.width;
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


                Text("ORDER REQUEST ",style: TextStyle(fontSize: 20,letterSpacing: 9.0,fontWeight: FontWeight.bold),),

                Padding(
                  padding: const EdgeInsets.only(top: 15,left: 15,right: 15),
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

                 Text("Company ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                  SizedBox(height:5,),


                        Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '',
          contentPadding: EdgeInsets.symmetric(horizontal: 1),
        ),
        child: DropdownButton<String>(
          value: selectcomp,
          underline: Container(), // Removes the underline
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
                style: TextStyle(
                  fontSize: screenWidth < 400 ? 8 : 10, // Adjust font size for smaller screens
                ),
              ),
            );
          }).toList(),
          icon: Container(
            padding: EdgeInsets.only(left: 30),
            alignment: Alignment.centerRight,
            child: Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
    ),
                        
                                    
                SizedBox(height: 8,),
                 Text("Family",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),

                      Container(
                    width: 310,
                    height: 49,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromARGB(255, 206, 206, 206)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Container(
                          width: 280,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Select your class',
                              contentPadding: EdgeInsets.symmetric(horizontal: 1),
                            ),
                            child:DropdownButtonHideUnderline(
              child: DropdownButton<int>(
            hint: Text(
              'Select a Family',
              
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600]),
              
            ),
            value: selectedFamilyId,
            isExpanded: true,
            dropdownColor: const Color.fromARGB(255, 255, 255, 255),
            icon: Icon(Icons.arrow_drop_down, color:const Color.fromARGB(255, 107, 107, 107)),
            onChanged: (int? newValue) {
              setState(() {
                selectedFamilyId = newValue; // Store the selected family ID
              });
            },
            items: fam.map<DropdownMenuItem<int>>((family) {
              return DropdownMenuItem<int>(
                value: family['id'],
                child: Text(
                  family['name'],
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                ),
              );
            }).toList(),
          ),)
          
        
      
                          ),
                        ),
                      ],
                    ),
                  ),



                  

                                         
                SizedBox(height: 8,),
                 Text("Maneger",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),


                

                 

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
                            child: DropdownButton<int>(
                              value: selectedstaffId,
                                isExpanded: true,
                              underline: Container(), // This removes the underline
                              onChanged: (int? newValue) {
                                setState(() {
                                  selectedstaffId = newValue!;
                                  print(selectedstaffId);
                                });
                              },
                              items: sta.map<DropdownMenuItem<int>>((staff) {
                                return DropdownMenuItem<int>(
                                  value:staff['id'],
                                  child: Text(staff['name'],style: TextStyle(fontSize: 12),),
                                );
                              }).toList(),
                              icon: Container(
                                padding: EdgeInsets.only(left: 190), // Adjust padding as needed
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                     SizedBox(height: 8,),
                 Text("Customer",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),

                      
                      LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: 300, // Adjusted width based on screen size
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
                  'Select a Customer',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                ),
                items: customer
                    .map((item) => DropdownMenuItem<String>(
                          value: item['name'], // Use the customer's name as the value
                          child: Text(
                            item['name'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ))
                    .toList(),
                value: selectedValue,
                onChanged: (value) {
                  setState(() {
                    // Update the selected value with the chosen customer's name
                    selectedValue = value;
                    // Find the corresponding customer ID
                    selectedCustomerId = customer
                        .firstWhere((item) => item['name'] == value)['id'];
                    print("Selected Customer ID: $selectedCustomerId");
                  });

              getaddress(selectedCustomerId);
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
                    padding: const EdgeInsets.only(top: 8, bottom: 4, right: 8, left: 8),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        hintText: 'Search for a customer...',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    // Perform case-insensitive search
                    return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
                  },
                ),
                // Clear the search value when the menu is closed
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    textEditingController.clear();
                  }
                },
              ),
            ),
          ),
        );
      },
    ),

      SizedBox(height: 8,),
      Text("State",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
      SizedBox(height: 5,),
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
                            child: DropdownButton<int>(
                              hint:  Text(
                  'State',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                ),
                              value: selectedstateId,
                                isExpanded: true,
                              underline: Container(), // This removes the underline
                              onChanged: (int? newValue) {
                                setState(() {
                                  selectedstateId = newValue!;
                                  print(selectedstateId);
                                });
                              },
                              items: stat.map<DropdownMenuItem<int>>((State) {
                                return DropdownMenuItem<int>(
                                  value:State['id'],
                                  child: Text(State['name']),
                                );
                              }).toList(),
                              icon: Container(
                                padding: EdgeInsets.only(left: 190), // Adjust padding as needed
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

 SizedBox(height: 8),
Text("Shipping Address", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
SizedBox(height: 5),
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
          child: DropdownButton<int>(
            hint: Text(
              'Address',
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
            ),
            value: selectedAddressId,
            isExpanded: true,
            underline: Container(), // This removes the underline
            onChanged: (int? newValue) {
              setState(() {
                selectedAddressId = newValue!;
                print(selectedAddressId);
              });
            },
            items: addres.map<DropdownMenuItem<int>>((address) {
              return DropdownMenuItem<int>(
                value: address['id'],
                child: Text("${address['address']}", style: TextStyle(fontSize: 12)),
              );
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              return addres.map<Widget>((address) {
                return Text(
                  selectedAddressId != null && selectedAddressId == address['id']
                      ? "${address['address']}"
                      : "Address",
                  style: TextStyle(fontSize: 12, color: Colors.black),
                );
              }).toList();
            },
            icon: Container(
              padding: EdgeInsets.only(left: 190), // Adjust padding as needed
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
            ),
          ),
        ),
      ),
    ],
  ),
),

// Display the selected address below the dropdown
if (selectedAddressId != null)
  Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Text(
      " ${addres.firstWhere((address) => address['id'] == selectedAddressId)['address']}",
      style: TextStyle(fontSize: 12, color: Colors.black),
    ),
  ),

                 SizedBox(height:8,),
                 Text("Invoice Date",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                 SizedBox(height: 5,),

          Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
        width: 304, 
        height: 46, 
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey, 
            width: 1.0, 
          ),
          borderRadius: BorderRadius.circular(8.0), 
        ),
        child: Row(
          children: [
            SizedBox(width: 30,),
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(fontSize:12,color:Color.fromARGB(255, 116, 116, 116)),
            ),
            SizedBox(width: 162,),
            GestureDetector(
              onTap: () {
              _selectDate(context);
                print('Icon pressed');
              },
              child: Icon(Icons.date_range),
            ),
          ],
        ),
      ),
        ],
              ),          
                        SizedBox(height: 15,),
                   SizedBox(
                    width: 150,
                     child: ElevatedButton(
                       onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>order_products()));
                            },
                     style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 17, 173, 0),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), 
                        ),
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(95, 15), 
                      ), ),
                      child: Text("Add Product",style: TextStyle(color: Colors.white)),
                      ),
                   ),
                SizedBox(height: 20,),

// Container(
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search for products...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: DataTable(
//     columns: [
//       DataColumn(label: Text('Image')),
//       DataColumn(label: Text('Name')),
//       DataColumn(label: Text('Price')),
//       DataColumn(label: Text('Stock')),
//       DataColumn(label: Text('Quantity')),
//       DataColumn(label: Text('Action')),
//     ],
//     rows: [
//       for (var product in filteredProducts) ...[
//         // Main Product Row
//         DataRow(
//           cells: [
//             DataCell(
//               Image.network(
//                 product['image'],
//                 width: 40,
//                 height: 40,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Icon(Icons.error, color: Colors.red);
//                 },
//               ), 
//             ),
//             DataCell(
//               Text(
//                 product['name'].length > 20
//                     ? product['name'].substring(0, 20) + '...'
//                     : product['name'],
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             DataCell(Text('\$${product['selling_price']}')),
//             DataCell(Text(product['stock']?.toString() ?? 'N/A')),
//             DataCell(
//               SizedBox(
//                 width: 60,
//                 child: TextField(
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 8),
//                   ),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     // Handle quantity change
//                   },
//                 ),
//               ),
//             ),
//             DataCell(
//               ElevatedButton(
//                 onPressed: () async {
//                   await getvariant(product['id'], product['type']);
//                   toggleExpansion(product['id']);
//                 },
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(
//                     expandedRows.contains(product['id'])
//                         ? Color.fromARGB(255, 255, 160, 0)
//                         : Color.fromARGB(255, 15, 168, 233),
//                   ),
//                 ),
//                 child: Text(
//                   expandedRows.contains(product['id']) ? 'Hide Variants' : 'Variants',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         // Rows for each variant if the product row is expanded
//         if (expandedRows.contains(product['id']))
//           for (var variantItem in variant) 
//             DataRow(
//               cells: [
//                 DataCell(
//                   Image.network(
//                     variantItem['image'] ?? '', // Image URL for the variant
//                     width: 40,
//                     height: 40,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Icon(Icons.error, color: Colors.red);
//                     },
//                   ),
//                 ),
//                 DataCell(
//                   Text(
//                     variantItem['name'].length > 20
//                         ? variantItem['name'].substring(0, 20) + '...'
//                         : variantItem['name'],
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 DataCell(Text('\$${variantItem['price'] ?? 'N/A'}')), // Price if available
//                 DataCell(Text(variantItem['stock']?.toString() ?? 'N/A')), // Stock if available
//                 DataCell(Container()), // Empty cell to align with main table
//                 DataCell(Container()), // Empty cell to align with main table
//               ],
//             ),
//       ],
//     ],
//   ),
// ),

//         ],
//       ),
//     ),
                    
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
    
    switch (selectedOption) 
    {
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