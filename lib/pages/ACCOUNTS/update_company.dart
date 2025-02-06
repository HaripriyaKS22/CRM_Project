import 'dart:convert';
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
import 'package:beposoft/pages/ACCOUNTS/update_department.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:flutter/material.dart';
import 'package:beposoft/pages/ACCOUNTS/add_recipts.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/recipts_list.dart';
import 'package:beposoft/pages/ACCOUNTS/credit_note_list.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class update_company extends StatefulWidget {
  final id;
  const update_company({super.key, required this.id});

  @override
  State<update_company> createState() => _update_companyState();
}

class _update_companyState extends State<update_company> {
  @override
  void initState() {
    super.initState();
    getcompany();
  }

  TextEditingController name = TextEditingController();
  TextEditingController gst = TextEditingController();

  TextEditingController address = TextEditingController();
  TextEditingController zip = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController website = TextEditingController();
  TextEditingController prefix = TextEditingController();

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  var departments;
  List<Map<String, dynamic>> company = [];

Future<void> getcompany() async {
  try {
    final token = await gettokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/company/data/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

  

    if (response.statusCode == 200) {
      // Decode the JSON response
      final responseData = jsonDecode(response.body);

      // Access the `data` field which is a list
      List<dynamic> productsData = responseData['data'];

      List<Map<String, dynamic>> companylist = [];

      for (var productData in productsData) {
        companylist.add({
          'id': productData['id'],
          'name': productData['name'],
          'gst': productData['gst'],
          'address': productData['address'],
          'zip': productData['zip'].toString(),
          'city': productData['city'],
          'country': productData['country'],
          'phone': productData['phone'],
          'email': productData['email'],
          'web_site': productData['web_site'],
          'prefix': productData['prefix'],
        });

        // Populate the form if the current product matches the widget ID
        if (widget.id == productData['id']) {
          setState(() {
            name.text = productData['name'] ?? '';
            gst.text = productData['gst'] ?? '';
            address.text = productData['address'] ?? '';
            zip.text = productData['zip'].toString();
            city.text = productData['city'] ?? '';
            country.text = productData['country'] ?? '';
            phone.text = productData['phone'] ?? '';
            email.text = productData['email'] ?? '';
            website.text = productData['web_site'] ?? '';
            prefix.text = productData['prefix'] ?? '';
          });
        }
      }

      // Update the state with the company list
      setState(() {
        company = companylist;
      });
    } else {
      throw Exception('Failed to fetch company data');
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('An error occurred while fetching company data.'),
      ),
    );
  }
}


  void updatecompany(BuildContext context) async {
    final token = await gettokenFromPrefs();

    try {
      var response = await http.put(
        Uri.parse('$api/api/company/update-del/${widget.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {
          "name": name.text,
          "gst": gst.text,
          "zip": zip.text,
          "city": city.text,
          "country": country.text,
          "email": email.text,
          "phone": phone.text,
          "address": address.text,
          "web_site": website.text,
          "prefix": prefix.text
        },
      );

     

      if (response.statusCode == 201) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Company updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
         Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => add_company()),
        );
        var responseData = jsonDecode(response.body);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => update_company(id: widget.id)));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 49, 212, 4),
            content: Text('sucess'),
          ),
        );
      }
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }
//  Future<void> deletedepartment(int Id) async {
//     final token = await gettokenFromPrefs();

//     try {
//       final response = await http.delete(
//         Uri.parse('$api/api/department/update/$Id/'),
//         headers: {
//           'Authorization': '$token',
//         },
//       );
//     
//     if(response.statusCode == 200){
//          ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Color.fromARGB(255, 49, 212, 4),
//           content: Text('Deleted sucessfully'),
//         ),
//       );
//          Navigator.push(context, MaterialPageRoute(builder: (context)=>add_department()));
//     }

//       if (response.statusCode == 204) {
//       } else {
//         throw Exception('Failed to delete wishlist ID: $Id');
//       }
//     } catch (error) {
//     }
//   }

  void removeProduct(int index) {
    setState(() {
      company.removeAt(index);
    });
  }

  drower d = drower();
  Widget _buildDropdownTile(
      BuildContext context, String title, List<String> options) {
    return ExpansionTile(
      title: Text(title),
      children: options.map((option) {
        return ListTile(
          title: Text(option),
          onTap: () {
            Navigator.pop(context);
            d.navigateToSelectedPage(
                context, option); // Navigate to selected page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(242, 255, 255, 255),
        appBar: AppBar(
           title: Text(
            'Update Company',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
            Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Image.asset('lib/assets/profile.png'),
              onPressed: () {},
            ),
          ],
        ),
        
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                              color: Color.fromARGB(255, 202, 202, 202)),
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
                                  color: const Color.fromARGB(255, 2, 65, 96),
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(255, 202, 202, 202)),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      " Company",
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

                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: name,
                                  decoration: InputDecoration(
                                    labelText: 'Company',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: gst,
                                  decoration: InputDecoration(
                                    labelText: 'gst no.',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: address,
                                  decoration: InputDecoration(
                                    labelText: 'Address',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: zip,
                                  decoration: InputDecoration(
                                    labelText: 'Zip code',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: city,
                                  decoration: InputDecoration(
                                    labelText: 'City',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: country,
                                  decoration: InputDecoration(
                                    labelText: 'Country',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: phone,
                                  decoration: InputDecoration(
                                    labelText: 'Phone',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: email,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: website,
                                  decoration: InputDecoration(
                                    labelText: 'Web site',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child: TextField(
                                  controller: prefix,
                                  decoration: InputDecoration(
                                    labelText: 'Prefix',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    updatecompany(context);
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.blue,
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  fixedSize: MaterialStateProperty.all<Size>(
                                    Size(constraints.maxWidth * 0.4, 50),
                                  ),
                                ),
                                child: Text("Submit",
                                    style: TextStyle(color: Colors.white)),
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
                            "Available Company",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 15, left: 15),
                      child: Container(
                        color: Colors.white,
                        child: Table(
                          border: TableBorder.all(
                              color: Color.fromARGB(255, 214, 213, 213)),
                          columnWidths: {
                            0: FixedColumnWidth(
                                40.0), // Fixed width for the first column (No.)
                            1: FlexColumnWidth(
                                2), // Flex width for the second column (Department Name)
                            2: FixedColumnWidth(
                                50.0), // Fixed width for the third column (Edit)
                            3: FixedColumnWidth(
                                50.0), // Fixed width for the fourth column (Delete)
                          },
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "No.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Company Name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            for (int i = 0; i < company.length; i++)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text((i + 1).toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(company[i]['name']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                      Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    update_company(
                                                        id: company[i]['id'])));
                                      },
                                      child: Image.asset(
                                        "lib/assets/edit.jpg",
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
            );
          },
        ));
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
