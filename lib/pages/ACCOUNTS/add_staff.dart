import 'dart:convert';
import 'dart:io';

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
import 'package:beposoft/pages/ACCOUNTS/update_Expense.dart';
import 'package:beposoft/pages/ACCOUNTS/update_department.dart';
import 'package:beposoft/pages/ACCOUNTS/update_staff.dart';
import 'package:beposoft/pages/ACCOUNTS/update_supervisor.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:beposoft/pages/api.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

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
import 'package:beposoft/pages/api.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class add_staff extends StatefulWidget {
  const add_staff({super.key});

  @override
  State<add_staff> createState() => _add_staffState();
}

class _add_staffState extends State<add_staff> {
  List<Map<String, dynamic>> statess = [];
  String staffId = '';

  List<bool> _checkboxValues = [];
  List<int> _selectedFamily = [];
  List<Map<String, dynamic>> fam = [];

  @override
  void initState() {
    super.initState();
    getdepartments();
    getmanegers();
    getstaff();
    initdata();
  }

  void initdata() async {
    await getstates();
    getfamily();
  }

  var url = "$api/api/add/department/";
  String? selectstate;
  int? selectedStateId;
  List stat = [];
  List<int> dynamicStatid = [];
  TextEditingController name = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController alternate_number = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController driving_license = TextEditingController();
  TextEditingController employment_status = TextEditingController();
  TextEditingController designation = TextEditingController();
  TextEditingController grade = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController Country = TextEditingController();

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  List<String> gender = ["Female", 'Male', 'Other'];
  String selectgender = "Female";
  List<String> material = ["Married", 'Single', 'Other'];
  String selectmarital = "Single";
  List<String> approval = ["Approved", 'Disapproved'];
  String approvalstatus = "Approved";

//dateselection
  DateTime selectedDate = DateTime.now();
  var date4;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(picked.year, picked.month, picked.day);
        date4 = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  DateTime selecteExp = DateTime.now();
  DateTime selectejoin = DateTime.now();
  DateTime selecteconf = DateTime.now();

  var date3;
  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selecteExp,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selecteExp) {
      setState(() {
        selecteExp = DateTime(picked.year, picked.month, picked.day);
        date3 = DateFormat('yyyy-MM-dd').format(selecteExp);
      });
    }
  }

  var date1;
  Future<void> _selectDate3(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectejoin,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectejoin) {
      setState(() {
        selectejoin = DateTime(picked.year, picked.month, picked.day);
        date1 = DateFormat('yyyy-MM-dd').format(selectejoin);
      });
    }
  }

  var date2;

  Future<void> _selectDate4(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selecteconf,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selecteconf) {
      setState(() {
        selecteconf = DateTime(picked.year, picked.month, picked.day);
        date2 = DateFormat('yyyy-MM-dd').format(selecteconf);
      });
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
            'id': productData['id'].toString(), // Convert the ID to String
            'name': productData['name'],
          });
        }

        setState(() {
          fam = familylist;
        });
      }
    } catch (error) {
      print("Error fetching family data: $error");
    }
  }

  Future<void> getstates() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/states/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      List<Map<String, dynamic>> stateslist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          stateslist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          statess = stateslist;
          _checkboxValues = List<bool>.filled(statess.length, false);
        });
      }
    } catch (error) {}
  }

  File? selectedImage;

  void imageSelect() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          selectedImage = File(result.files.single.path!);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("image1 selected successfully."),
          backgroundColor: Color.fromARGB(173, 120, 249, 126),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while selecting the file."),
        backgroundColor: Colors.red,
      ));
    }
  }

  File? selectedImage1;

  void imageSelect1() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          selectedImage1 = File(result.files.single.path!);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("image1 selected successfully."),
          backgroundColor: Color.fromARGB(173, 120, 249, 126),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while selecting the file."),
        backgroundColor: Colors.red,
      ));
    }
  }

  var departments;
  List<Map<String, dynamic>> dep = [];
  List<Map<String, dynamic>> manager = [];

  Future<void> getdepartments() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/departments/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      List<Map<String, dynamic>> departmentlist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          departmentlist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          dep = departmentlist;
        });
      }
    } catch (error) {}
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

      List<Map<String, dynamic>> stafflist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          stafflist.add({
            'id': productData['id'],
            'name': productData['name'],
            'email': productData['email']
          });
        }
        setState(() {
          sta = stafflist;
        });
      }
    } catch (error) {}
  }

  Future<void> getmanegers() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/supervisors/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      List<Map<String, dynamic>> managerlist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          managerlist.add({
            'id': productData['id'],
            'name': productData['name'],
            'department_name': productData['department_name'],
          });
        }
        setState(() {
          manager = managerlist;
        });
      }
    } catch (error) {}
  }

  void addsupervisor(String name, BuildContext context) async {
    final token = await gettokenFromPrefs();

    try {
      var response = await http.post(
        Uri.parse("$api/api/add/supervisor/"),
        headers: {
          'Authorization': '$token',
        },
        body: {
          "name": name,
          "department": selectedDepartmentId.toString(),
        },
      );

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => add_staff()));
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

  // Future<void> deletestaff(int Id) async {
  //   final token = await gettokenFromPrefs();

  //   try {
  //     final response = await http.delete(
  //       Uri.parse('$api/api/staff/update/$Id/'),
  //       headers: {
  //         'Authorization': '$token',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Color.fromARGB(255, 49, 212, 4),
  //           content: Text('Deleted sucessfully'),
  //         ),
  //       );
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => add_staff()));
  //     }

  //     if (response.statusCode == 204) {
  //     } else {
  //       throw Exception('Failed to delete wishlist ID: $Id');
  //     }
  //   } catch (error) {}
  // }

  void removeProduct(int index) {
    setState(() {
      sta.removeAt(index);
    });
  }

  int? selectedmanagerId; // Variable to store the selected department's ID
  String?
      selectedmanagerName; // Variable to store the selected department's name

  int? selectedDepartmentId; // Variable to store the selected department's ID
  String?
      selectedDepartmentName; // Variable to store the selected department's name
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
//   void stattt(
//      String state,
//   ){

//    String allocatedStates='';

//   for(int i=0;i<dynamicStatid.length;i++){
//     allocatedStates += '${dynamicStatid[i]},';
//    }
//   }

  Future<void> RegisterUserData(
    int selectedDepartmentId,
    DateTime selectedDate,
    String selectgender,
    String selectmarital,
    DateTime selecteExp,
    DateTime selectejoin,
    DateTime selecteconf,
    BuildContext scaffoldContext,
  ) async {
    final token = await gettokenFromPrefs();

    try {
      // Create the request
      var request = http.Request(
        'POST',
        Uri.parse('$api/api/add/staff/'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Specify content type as JSON
      });

      // Prepare the data to send in JSON format
      Map<String, dynamic> data = {
        'date_of_birth': selectedDate.toIso8601String().substring(0, 10),
        'driving_license_exp_date':
            selecteExp.toIso8601String().substring(0, 10),
        'join_date': selectejoin.toIso8601String().substring(0, 10),
        'confirmation_date': selecteconf.toIso8601String().substring(0, 10),
        'allocated_states':
            dynamicStatid.map((stateId) => stateId.toString()).toList(),
        'name': name.text,
        'username': username.text,
        'email': email.text,
        'phone': phone.text,
        'password': password.text,
        'alternate_number': alternate_number.text,
        'designation': designation.text,
        'grade': grade.text,
        'address': address.text,
        'city': city.text,
        'country': Country.text,
        'driving_license': driving_license.text,
        'department_id': selectedDepartmentId.toString(),
        'supervisor_id': selectedmanagerId.toString(),
        'gender': selectgender,
        'marital_status': selectmarital,
        'employment_status': employment_status.text,
        'APPROVAL_CHOICE': approvalstatus,
        'family': _selectedFamily.isNotEmpty ? _selectedFamily[0] : null,
      };

      // Convert data to JSON and set the request body
      request.body = jsonEncode(data);

      // Send the request
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      // Print the response status and body for debugging
      print("Response statussssssss: ${responseData.statusCode}");
      print("Response bodyyyyyyyyy: ${responseData.body}");

      if (responseData.statusCode == 201) {
        // Parse the response body
        final Map<String, dynamic> responseJson = jsonDecode(responseData.body);

        print("------------------------$responseJson");

        // Store the product ID in the global variable
        staffId = responseJson['data']['id'].toString();

        // Show success message
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Data Added Successfully.'),
          ),
        );

        // Navigate to another page after successful registration
        Navigator.pushReplacement(
          scaffoldContext,
          MaterialPageRoute(builder: (context) => add_staff()),
        );
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> updateStaffImage(
    String staffId,
    File? image1,
    File? image2,
    BuildContext scaffoldContext,
  ) async {
    final token = await gettokenFromPrefs();
    print("============$staffId");
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$api/api/staff/update/$staffId/'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add the images to the request if they are not null
      if (image1 != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image1.path));
      }
      if (image2 != null) {
        request.files
            .add(await http.MultipartFile.fromPath('signatur_up', image2.path));
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Response statusttttttttt: ${response.statusCode}");
      print("Response bodyttttttttttttt: ${response.body}");
      // Handle response based on status code
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: Text('Images Updated Successfully.')),
        );
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
              content: Text(
                  'Something went wrong while updating images. Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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
Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(242, 255, 255, 255),
        appBar: AppBar(
           title: Text(
          "Add Staff",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Custom back arrow
          onPressed: () async{
                    final dep= await getdepFromPrefs();
if(dep=="BDO" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => bdo_dashbord()), // Replace AnotherPage with your target page
            );

}
else if(dep=="BDM" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => bdm_dashbord()), // Replace AnotherPage with your target page
            );
}
else {
    Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => dashboard()), // Replace AnotherPage with your target page
            );

}
           
          },
        ),
          actions: [
            IconButton(
              icon: Image.asset('lib/assets/profile.png'),
              onPressed: () {},
            ),
          ],
        ),
        
        body: Builder(builder: (BuildContext scaffoldContext) {
          return LayoutBuilder(
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
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
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
                                        "Add STAFF",
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: name,
                                    decoration: InputDecoration(
                                      labelText: 'name',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: username,
                                    decoration: InputDecoration(
                                      labelText: 'username',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: email,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: phone,
                                    decoration: InputDecoration(
                                      labelText: 'Phone',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: alternate_number,
                                    decoration: InputDecoration(
                                      labelText: 'Alternate Number',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: password,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: selectedDepartmentId,
                                    hint: Text('Select a department'),
                                    underline:
                                        SizedBox(), // Remove the default underline
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedDepartmentId = newValue;
                                        selectedDepartmentName = dep.firstWhere(
                                            (element) =>
                                                element['id'] ==
                                                newValue)['name'];
                                      });
                                    },
                                    items: dep.map<DropdownMenuItem<int>>(
                                        (department) {
                                      return DropdownMenuItem<int>(
                                        value: department['id'],
                                        child: Text(department['name']),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: selectedmanagerId,
                                    hint: Text('Select a Manager'),
                                    underline:
                                        SizedBox(), // Remove the default underline
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedmanagerId = newValue;
                                        selectedmanagerName =
                                            manager.firstWhere((element) =>
                                                element['id'] ==
                                                newValue)['name'];
                                      });
                                    },
                                    items: manager
                                        .map<DropdownMenuItem<int>>((manager) {
                                      return DropdownMenuItem<int>(
                                        value: manager['id'],
                                        child: Text(manager['name']),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    imageSelect();
                                  },
                                  child: Container(
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(255, 224, 223, 223),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'lib/assets/upload.png', // Replace 'upload_icon.png' with your image asset path
                                          width:
                                              24, // Adjust the width of the image
                                          height:
                                              24, // Adjust the height of the image
                                          color: Color.fromARGB(255, 2, 2,
                                              2), // Adjust the color of the image
                                        ),
                                        SizedBox(
                                            width:
                                                10), // Spacer between icon and text
                                        Text(
                                          "Select Profile Image",
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 116, 116, 116)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Date Of Birth",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: constraints.maxWidth *
                                      0.9, // Adjusted width based on screen size
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 30),
                                            Text(
                                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                      255, 116, 116, 116)),
                                            ),
                                            SizedBox(width: 162),
                                            GestureDetector(
                                              onTap: () {
                                                _selectDate(context);
                                              },
                                              child: Icon(Icons.date_range),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                //    Text("Checkbox Family",
                                //     style: TextStyle(
                                //         fontSize: 15, fontWeight: FontWeight.bold)),
                                // SizedBox(height: 20),
                                // statess.isEmpty
                                //     ? CircularProgressIndicator() // Show a loading indicator while the data is being fetched
                                //     : ListView.builder(
                                //         shrinkWrap: true,
                                //         itemCount: statess.length,
                                //         itemBuilder: (context, index) {
                                //           return CheckboxListTile(
                                //             title: Text(statess[index]['name']),
                                //             value: _checkboxValues[index],
                                //             onChanged: (bool? value) {
                                //               setState(() {
                                //                 _checkboxValues[index] =
                                //                     value ?? false;
                                //                 if (_checkboxValues[index]) {
                                //                   _selectedFamily
                                //                       .add(statess[index]['id']);
                                //                 } else {
                                //                   _selectedFamily
                                //                       .remove(statess[index]['id']);
                                //                 }
                                //               });
                                //             },
                                //             controlAffinity:
                                //                 ListTileControlAffinity.leading,
                                //           );
                                //         },
                                //       ),
                                Padding(
                                  padding: const EdgeInsets.all(.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 46,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<
                                              Map<String, dynamic>>(
                                            isExpanded: true,
                                            hint: Text(
                                              'Select State',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .hintColor),
                                            ),
                                            value: statess.isNotEmpty &&
                                                    selectstate != null
                                                ? statess.firstWhere(
                                                    (element) =>
                                                        element['name'] ==
                                                        selectstate,
                                                    orElse: () => statess[
                                                        0], // Default to first state if not found
                                                  )
                                                : null,
                                            items: statess.isNotEmpty
                                                ? statess.map<
                                                    DropdownMenuItem<
                                                        Map<String, dynamic>>>(
                                                    (Map<String, dynamic>
                                                        state) {
                                                      return DropdownMenuItem<
                                                          Map<String, dynamic>>(
                                                        value: state,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              state['name'],
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                            if (stat.contains(
                                                                state['name']))
                                                              Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .blue, // Indicate selected items
                                                              ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ).toList()
                                                : [
                                                    DropdownMenuItem(
                                                      child: Text(
                                                          'No states available'),
                                                      value: null,
                                                    ),
                                                  ],
                                            onChanged: (Map<String, dynamic>?
                                                newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  selectstate =
                                                      newValue['name'];
                                                  selectedStateId =
                                                      newValue['id'];
                                                  if (!stat.contains(
                                                          selectstate) &&
                                                      !dynamicStatid.contains(
                                                          selectedStateId)) {
                                                    stat.add(selectstate!);
                                                    dynamicStatid
                                                        .add(selectedStateId!);
                                                  } else {
                                                    stat.remove(selectstate!);
                                                    dynamicStatid.remove(
                                                        selectedStateId);
                                                  }
                                                });
                                              }
                                            },
                                            icon: Icon(Icons.arrow_drop_down),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10), // Spacing
                                      // Display selected values
                                      Wrap(
                                        spacing: 8.0,
                                        children: stat.map((value) {
                                          return Chip(
                                            label: Text(value),
                                            deleteIcon: Icon(Icons.close),
                                            onDeleted: () {
                                              setState(() {
                                                int index = stat.indexOf(value);
                                                stat.removeAt(index);
                                                dynamicStatid.removeAt(index);
                                                if (stat.isEmpty) {
                                                  selectstate =
                                                      null; // Reset the selected state
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),

                                // Text(
                                //   "State$stat",
                                //   style: TextStyle(
                                //     fontSize: 15,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                // SizedBox(
                                //   height: 5,
                                // ),
                                // Container(
                                //   width: double
                                //       .infinity, // Use full width available
                                //   height: 49,
                                //   decoration: BoxDecoration(
                                //     border: Border.all(color: Colors.grey),
                                //     borderRadius: BorderRadius.circular(10),
                                //   ),
                                //   child: InputDecorator(
                                //     decoration: InputDecoration(
                                //       border: InputBorder.none,
                                //       contentPadding: EdgeInsets.symmetric(
                                //           horizontal:
                                //               10), // Adjust padding as needed
                                //     ),
                                //     child: DropdownButtonHideUnderline(
                                //       child:
                                //           DropdownButton<Map<String, dynamic>>(
                                //         value: statess.isNotEmpty
                                //             ? statess.firstWhere(
                                //                 (element) =>
                                //                     element['name'] ==
                                //                     selectstate,
                                //                 orElse: () => statess[0],
                                //               )
                                //             : null,
                                //         onChanged: statess.isNotEmpty
                                //             ? (Map<String, dynamic>? newValue) {
                                //                 setState(() {
                                //                   selectstate =
                                //                       newValue!['name'];
                                //                   selectedStateId = newValue[
                                //                       'id']; // Store the selected state's ID

                                //                   // Check if the selected state is already in the list
                                //                   if (!stat.contains(
                                //                           selectstate) &&
                                //                       !dynamicStatid.contains(
                                //                           selectedStateId)) {
                                //                     stat.add(selectstate!);
                                //                     dynamicStatid
                                //                         .add(selectedStateId!);
                                //                   } else {
                                //                     stat.remove(selectstate!);
                                //                     dynamicStatid.remove(
                                //                         selectedStateId);
                                //                   }

                                //                 });
                                //               }
                                //             : null,
                                //         items: statess.isNotEmpty
                                //             ? statess.map<
                                //                 DropdownMenuItem<
                                //                     Map<String, dynamic>>>(
                                //                 (Map<String, dynamic> state) {
                                //                   return DropdownMenuItem<
                                //                       Map<String, dynamic>>(
                                //                     value: state,
                                //                     child: Text(state['name']),
                                //                   );
                                //                 },
                                //               ).toList()
                                //             : [
                                //                 DropdownMenuItem(
                                //                   child: Text(
                                //                       'No states available'),
                                //                   value: null,
                                //                 ),
                                //               ],
                                //         icon: Icon(Icons.arrow_drop_down),
                                //         isExpanded:
                                //             true, // Ensure dropdown takes full width
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                Text(
                                  "Gender",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: constraints.maxWidth *
                                      0.9, // Adjusted width based on screen size
                                  height: 49,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 20),
                                      Container(
                                        width: constraints.maxWidth *
                                            0.7, // Adjusted width based on screen size
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 1),
                                          ),
                                          child: DropdownButton<String>(
                                            value: selectgender,
                                            underline:
                                                Container(), // This removes the underline
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectgender = newValue!;
                                              });
                                            },
                                            items: gender
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            icon: Container(
                                              padding: EdgeInsets.only(
                                                  left: constraints.maxWidth *
                                                      0.35),
                                              alignment: Alignment.centerRight,
                                              child:
                                                  Icon(Icons.arrow_drop_down),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Marital status",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: constraints.maxWidth *
                                      0.9, // Adjusted width based on screen size
                                  height: 49,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 20),
                                      Container(
                                        width: constraints.maxWidth *
                                            0.6, // Adjusted width based on screen size
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 1),
                                          ),
                                          child: DropdownButton<String>(
                                            value: selectmarital,
                                            underline:
                                                Container(), // This removes the underline
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectmarital = newValue!;
                                              });
                                            },
                                            items: material
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            icon: Container(
                                              padding: EdgeInsets.only(
                                                  left: constraints.maxWidth *
                                                      0.35),
                                              alignment: Alignment.centerRight,
                                              child:
                                                  Icon(Icons.arrow_drop_down),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: driving_license,
                                    decoration: InputDecoration(
                                      labelText: 'Driving License',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "License Exp.Date",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: constraints.maxWidth *
                                      0.9, // Adjusted width based on screen size
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 30),
                                            Text(
                                              '${selecteExp.day}/${selecteExp.month}/${selecteExp.year}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                      255, 116, 116, 116)),
                                            ),
                                            SizedBox(width: 162),
                                            GestureDetector(
                                              onTap: () {
                                                _selectDate2(context);
                                              },
                                              child: Icon(Icons.date_range),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: employment_status,
                                    decoration: InputDecoration(
                                      labelText: 'Employment Status',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10),

// Show a loading indicator while the data is being fetched
                                fam.isEmpty
                                    ? CircularProgressIndicator()
                                    : DropdownButton<String>(
                                        isExpanded:
                                            true, // Ensure dropdown takes full width
                                        value: _selectedFamily.isEmpty
                                            ? null
                                            : _selectedFamily[0]
                                                .toString(), // Convert value to String
                                        hint: Text("Select a Family"),
                                        items: fam
                                            .map<DropdownMenuItem<String>>(
                                                (family) {
                                          return DropdownMenuItem<String>(
                                            value: family[
                                                'id'], // Value is now a String
                                            child: Text(family['name']),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            if (newValue != null) {
                                              _selectedFamily = [
                                                int.parse(newValue)
                                              ]; // Convert String back to int and store it
                                            }
                                          });
                                        },
                                      ),
                                SizedBox(height: 10),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: designation,
                                    decoration: InputDecoration(
                                      labelText: 'Designation',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: grade,
                                    decoration: InputDecoration(
                                      labelText: 'Grade',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: address,
                                    decoration: InputDecoration(
                                      labelText: 'Address',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: city,
                                    decoration: InputDecoration(
                                      labelText: 'City',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: TextField(
                                    controller: Country,
                                    decoration: InputDecoration(
                                      labelText: 'Country',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Joining Date",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: constraints.maxWidth *
                                      0.9, // Adjusted width based on screen size
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 30),
                                            Text(
                                              '${selectejoin.day}/${selectejoin.month}/${selectejoin.year}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                      255, 116, 116, 116)),
                                            ),
                                            SizedBox(width: 162),
                                            GestureDetector(
                                              onTap: () {
                                                _selectDate3(context);
                                              },
                                              child: Icon(Icons.date_range),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Confirmation Date",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: constraints.maxWidth *
                                      0.9, // Adjusted width based on screen size
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 30),
                                            Text(
                                              '${selecteconf.day}/${selecteconf.month}/${selecteconf.year}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                      255, 116, 116, 116)),
                                            ),
                                            SizedBox(width: 162),
                                            GestureDetector(
                                              onTap: () {
                                                _selectDate4(context);
                                              },
                                              child: Icon(Icons.date_range),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Signature",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    imageSelect1();
                                  },
                                  child: Container(
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(255, 224, 223, 223),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'lib/assets/upload.png', // Replace 'upload_icon.png' with your image asset path
                                          width:
                                              24, // Adjust the width of the image
                                          height:
                                              24, // Adjust the height of the image
                                          color: Color.fromARGB(255, 2, 2,
                                              2), // Adjust the color of the image
                                        ),
                                        SizedBox(
                                            width:
                                                10), // Spacer between icon and text
                                        Text(
                                          "Select Signature",
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 116, 116, 116)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  "Status",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: constraints.maxWidth *
                                      0.9, // Adjusted width based on screen size
                                  height: 49,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 20),
                                      Container(
                                        width: constraints.maxWidth *
                                            0.6, // Adjusted width based on screen size
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 1),
                                          ),
                                          child: DropdownButton<String>(
                                            value: approvalstatus,
                                            underline:
                                                Container(), // This removes the underline
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                approvalstatus = newValue!;
                                              });
                                            },
                                            items: approval
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            icon: Container(
                                              padding: EdgeInsets.only(
                                                  left: constraints.maxWidth *
                                                      0.1),
                                              alignment: Alignment.centerRight,
                                              child:
                                                  Icon(Icons.arrow_drop_down),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() async {
                                      await RegisterUserData(
                                          selectedDepartmentId!,
                                          selectedDate,
                                          selectgender,
                                          selectmarital,
                                          selecteExp,
                                          selectejoin,
                                          selecteconf,
                                          scaffoldContext);

                                      updateStaffImage(staffId, selectedImage,
                                          selectedImage1, scaffoldContext);
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blue),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // Set your desired border radius
                                      ),
                                    ),
                                    fixedSize: MaterialStateProperty.all<Size>(
                                      Size(
                                          MediaQuery.of(context).size.width *
                                              0.4,
                                          50), // Set your desired width and height
                                    ),
                                  ),
                                  child: Text("Submit",
                                      style: TextStyle(color: Colors.white)),
                                ),
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
                              "Available Staff",
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
                                      "Manager Name",
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
                              for (int i = 0; i < sta.length; i++)
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text((i + 1).toString()),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("${sta[i]['name']}"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Staff_Update(
                                                          id: sta[i]['id'])));
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
                    ],
                  ),
                ),
              );
            },
          );
        }));
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
