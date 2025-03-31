import 'dart:convert';
import 'dart:io';
import 'package:beposoft/pages/ACCOUNTS/view_staff.dart';
import 'package:beposoft/pages/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add this dependency if not already added
class Staff_Update extends StatefulWidget {
  final id;

  const Staff_Update({super.key, required this.id});

  @override
  State<Staff_Update> createState() => _Staff_UpdateState();
}

class _Staff_UpdateState extends State<Staff_Update> {
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
  TextEditingController family = TextEditingController();

  TextEditingController date_of_birth = TextEditingController();
  TextEditingController driving_license_exp_date = TextEditingController();
  TextEditingController join_date = TextEditingController();
  TextEditingController confirmation_date = TextEditingController();
  TextEditingController termination_date = TextEditingController();
  List<Map<String, dynamic>> familyList = [];
  List<int> _selectedFamily = [];
  List<int> _selectedManager = [];
  String? selectstate;
  String staffId = '';

  List<int> allocated_states = []; // To store state IDs
List<String> allocatedStateNames = []; // To store state names

  List<String> type = ["approved", 'disapproved'];
  List<int> _selectedDep = [];
  List<Map<String, dynamic>> stat = [];

  List<Map<String, dynamic>> dep = [];

  List<Map<String, dynamic>> manager = [];
  List<Map<String, dynamic>> Warehouses = [];

  String? signatureUrl; // This is the URL of the current signature from API
  String? gender;
  String? maritalStatus;
  String? approvalStatus=null;
final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  // Variables to store the selected dates
  DateTime? selectedDateOfBirth;
  DateTime? selectedDrivingLicenseExpDate;
  DateTime? selectedJoinDate;
  DateTime? selectedConfirmationDate;
  DateTime? selectedTerminationDate;

  File? selectedSignatureImage; // To hold the selected signature image file
  String? selectedFamilyName;
  String? selecteddepName;
  String? selectedmanagerepName; 
   String? selectedwarehouseName;
  int? selectedwarehouseId;


  @override
  void initState() {
    super.initState();
    initdata();
    getstaff();
  }

  void initdata() async {
    await getfamily();
    await getmanegers();
    await getdepartments();
    await getstate();
    await getwarehouse();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
Future<void> getwarehouse() async {
    final token = await gettokenFromPrefs();
    try {
      final response =
          await http.get(Uri.parse('$api/api/warehouse/add/'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      List<Map<String, dynamic>> warehouselist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        
        for (var productData in parsed) {
          warehouselist.add({
            'id': productData['id'],
            'name': productData['name'],
            'location': productData['location']
          });
        }
        setState(() {
          Warehouses = warehouselist;
          ;
          
        });
      }
    } catch (e) {
      
    }
  }
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
     
      List<Map<String, dynamic>> statelist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        
        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          statelist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          stat = statelist;
          
        });
      }
    } catch (error) {
      
    }
  }

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
      List<Map<String, dynamic>> familyData = [];
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          familyData.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }

        setState(() {
          familyList = familyData;
          
        });
      }
    } catch (error) {
      
    }
  }


   File? selectedImage;
      File? selectedImagee;
      File? selectedSignatureImagee;


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

Future<void> RegisterUserData(BuildContext scaffoldContext) async {
  final token = await gettokenFromPrefs(); // Replace with your token retrieval method

  try {
    // Create the request
    var request = http.Request(
      'PUT',
      Uri.parse('$api/api/staff/update/${widget.id}/'), // Replace `$api` with your base URL
    );

    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    // Date formatter
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    // Prepare the data to send in JSON format
    Map<String, dynamic> data = {
      'date_of_birth': selectedDateOfBirth != null ? dateFormatter.format(selectedDateOfBirth!) : null,
      'driving_license_exp_date': selectedDrivingLicenseExpDate != null
          ? dateFormatter.format(selectedDrivingLicenseExpDate!)
          : null,
      'join_date': selectedJoinDate != null ? dateFormatter.format(selectedJoinDate!) : null,
      'confirmation_date': selectedConfirmationDate != null
          ? dateFormatter.format(selectedConfirmationDate!)
          : null,
      'termination_date': selectedTerminationDate != null
          ? dateFormatter.format(selectedTerminationDate!)
          : null,
      'allocated_states': allocated_states, // Replace with your actual states list
      'name': name.text,
      'username': username.text,
      'email': email.text,
      'phone': phone.text,
      'alternate_number': alternate_number.text,
      'designation': designation.text,
      'grade': grade.text,
      'address': address.text,
      'city': city.text,
      'country': Country.text,
      'driving_license': driving_license.text,
      'department_id': selecteddepName != null
          ? dep.firstWhere((element) => element['name'] == selecteddepName, orElse: () => {})['id']
          : null,
      'supervisor_id': selectedmanagerepName != null
          ? manager.firstWhere((element) => element['name'] == selectedmanagerepName, orElse: () => {})['id']
          : null,
      'gender': gender,
      'marital_status': maritalStatus,
      'employment_status': employment_status.text,
              'warehouse_id': selectedwarehouseId ?? "0", // Use 0 if selectedwarehouseId is null

      'approval_status': approvalStatus,
      'family': selectedFamilyName != null
          ? familyList.firstWhere((element) => element['name'] == selectedFamilyName, orElse: () => {})['id']
          : null,
    };
if (password.text.isNotEmpty) {
  data['password'] = password.text;
}
    // Convert data to JSON and set the request body
    request.body = jsonEncode(data);

    // Send the request
    var response = await request.send().timeout(Duration(seconds: 10));
    var responseData = await http.Response.fromStream(response);

    // Debugging output
    
    

    if (responseData.statusCode == 200) {
      // Parse the response body
      final Map<String, dynamic> responseJson = jsonDecode(responseData.body);

      // Store the product ID in the global variable
      staffId = responseJson['data']['id'].toString();

      // Show success message
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Data Added Successfully.'),
        ),
      );

      // Navigate to another page after successful registration
      Navigator.pushReplacement(
        scaffoldContext,
        MaterialPageRoute(builder: (context) => staff_list()), // Replace with your staff list page
      );
    } else {
      
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
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






Future<void> getstaff() async {
  try {
    // Ensure state data is loaded before fetching staff
    if (stat.isEmpty) {
      await getstate();
    }

    final token = await gettokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/staffs/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var staffDataList = parsed['data'];

      for (var staffData in staffDataList) {
        if (widget.id == staffData['id']) {
          // Populate fields with staff details
          name.text = staffData['name'] ?? '';
          username.text = staffData['username'] ?? '';
          email.text = staffData['email'] ?? '';
          phone.text = staffData['phone'] ?? '';
          alternate_number.text = staffData['alternate_number'] ?? '';
          password.text = '';
          driving_license.text = staffData['driving_license'] ?? '';
          employment_status.text = staffData['employment_status'] ?? '';
          designation.text = staffData['designation'] ?? '';
          grade.text = staffData['grade'] ?? '';
          address.text = staffData['address'] ?? '';
          city.text = staffData['state'] ?? '';
          Country.text = staffData['country'] ?? '';
          signatureUrl = staffData['signatur_up'] ?? '';
          gender = staffData['gender'] ?? '';
          maritalStatus = staffData['marital_status'] != null
              ? staffData['marital_status'][0].toUpperCase() +
                  staffData['marital_status'].substring(1).toLowerCase()
              : null;
          approvalStatus = staffData['approval_status'] ?? '';

          // Prepopulate Date Fields
          date_of_birth.text = staffData['date_of_birth'] ?? '';
          driving_license_exp_date.text =
              staffData['driving_license_exp_date'] ?? '';
          join_date.text = staffData['join_date'] ?? '';
          confirmation_date.text = staffData['confirmation_date'] ?? '';
          termination_date.text = staffData['termination_date'] ?? '';
          selectedImagee=staffData['image'] != null
              ? File(staffData['image'])
              : null;
            selectedSignatureImagee = staffData['signatur_up'] != null
              ? File(staffData['signatur_up'])
              : null;
              
              
          selectedwarehouseId=staffData['warehouse_id'] ?? 0;

          // Initialize date variables from API data
          selectedDateOfBirth = staffData['date_of_birth'] != null
              ? DateTime.parse(staffData['date_of_birth'])
              : null;
          selectedDrivingLicenseExpDate =
              staffData['driving_license_exp_date'] != null
                  ? DateTime.parse(staffData['driving_license_exp_date'])
                  : null;
          selectedJoinDate = staffData['join_date'] != null
              ? DateTime.parse(staffData['join_date'])
              : null;
          selectedConfirmationDate = staffData['confirmation_date'] != null
              ? DateTime.parse(staffData['confirmation_date'])
              : null;
          selectedTerminationDate = staffData['termination_date'] != null
              ? DateTime.parse(staffData['termination_date'])
              : null;

          // Set the selected family and department names
          selectedFamilyName = staffData['family_name']?.toString() ?? '';
          selecteddepName = staffData['department_name']?.toString() ?? '';
          selectedmanagerepName =
              staffData['supervisor_name']?.toString() ?? '';

          
          

          // Fetch allocated_states and map to state names
          if (staffData['allocated_states'] != null) {
            allocated_states =
                List<int>.from(staffData['allocated_states']); // Ensure it's a list of integers

            allocatedStateNames = allocated_states
                .map((stateId) => stat.firstWhere(
                      (element) => element['id'] == stateId,
                      orElse: () => {'name': 'Unknown'},
                    )['name'] as String) // Explicitly cast to String
                .toList();

            
          }
        }
      }
      setState(() {});
    }
  } catch (error) {
    
  }
}

Future<void> updateStaffImage(
    String staffId,
    File? image1,
    File? image2,
    BuildContext scaffoldContext,
  ) async {
    ;
    final token = await gettokenFromPrefs();
    ;
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$api/api/staff/update/${widget.id}/'),
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

      ;
      ;
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
  // Function to allow the user to select an image
  // void imageSelect1() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.image,
  //     );
  //     if (result != null) {
  //       setState(() {
  //         selectedSignatureImage = File(result.files.single.path!);
          
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text("image1 selected successfully."),
  //         backgroundColor: Color.fromARGB(173, 120, 249, 126),
  //       ));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text("Error while selecting the file."),
  //       backgroundColor: Colors.red,
  //     ));
  //   }
  // }
  // Function to remove the selected image
  void removeSignatureImage() {
    ;
    setState(() {
      selectedSignatureImage = null;
      
    });
  }

   void removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  // Function for Date Picker
  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller,
      Function(DateTime?) onDateSelected) async {
    DateTime selectedDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      selectedDate = DateTime.parse(controller.text);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        controller.text = picked
            .toString()
            .split(' ')[0]; // Store the selected date as YYYY-MM-DD
        onDateSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Image.asset('lib/assets/profile.png'),
            onPressed: () {}, // You can handle profile click here
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Staff Details Heading
              SizedBox(height: 15),
              Text(
                "STAFF UPDATE",
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 9.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border:
                        Border.all(color: Color.fromARGB(255, 202, 202, 202)),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 0, 0, 0),
                            border: Border.all(
                                color: Color.fromARGB(255, 202, 202, 202)),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Text(
                                "Update Staff Details",
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
                        _buildTextField('Name', name),
                        _buildTextField('Username', username),
                        _buildTextField('Email', email),
                        _buildTextField('Phone', phone),
                        _buildTextField('Alternate Number', alternate_number),
                        _buildTextField('Password', password,
                            obscureText: true),
                        _buildTextField('Driving License', driving_license),
                        _buildTextField('Employment Status', employment_status),
                        _buildTextField('Designation', designation),
                        _buildTextField('Grade', grade),
                        _buildTextField('Address', address),
                        _buildTextField('City', city),
                        _buildTextField('Country', Country),

                        // Gender Radio Buttons
                        Text('Gender',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            _genderRadioButton('Male'),
                            _genderRadioButton('Female'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Family',
                            style: TextStyle(
                              fontSize: 13,
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.9, // Make it responsive to screen width
                          height: 49, // Fixed height
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey), // Add border color
                            borderRadius: BorderRadius.circular(
                                10), // Add rounded corners
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                  width:
                                      20), // Add spacing to the left of the dropdown
                              Flexible(
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: InputBorder
                                        .none, // Remove the underline
                                    hintText: '', // Placeholder (if needed)
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 1), // Padding
                                  ),
                                  child: familyList.isNotEmpty
                                      ? DropdownButton<Map<String, dynamic>>(
                                          isExpanded:
                                              true, // Ensures dropdown expands to available width
                                          value: familyList.any((element) =>
                                                  element['name'] ==
                                                  selectedFamilyName)
                                              ? familyList.firstWhere(
                                                  (element) =>
                                                      element['name'] ==
                                                      selectedFamilyName,
                                                )
                                              : null, // Check if selected value matches an item
                                          underline:
                                              Container(), // Remove the dropdown underline
                                          onChanged:
                                              (Map<String, dynamic>? newValue) {
                                            setState(() {
                                              selectedFamilyName = newValue![
                                                  'name']; // Update selected value
                                            });
                                          },
                                          items: familyList.map<
                                              DropdownMenuItem<
                                                  Map<String, dynamic>>>(
                                            (Map<String, dynamic> familyItem) {
                                              return DropdownMenuItem<
                                                  Map<String, dynamic>>(
                                                value:
                                                    familyItem, // Use the item as the value
                                                child: Text(
                                                  familyItem[
                                                      'name'], // Display the name
                                                  overflow: TextOverflow
                                                      .ellipsis, // Handle long text gracefully
                                                ),
                                              );
                                            },
                                          ).toList(),
                                          icon: Container(
                                            alignment: Alignment
                                                .centerRight, // Align the dropdown icon
                                            child: Icon(Icons
                                                .arrow_drop_down), // Dropdown icon
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                              'Loading family data...'), // Fallback for empty familyList
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 5),
                        Text('Department',
                            style: TextStyle(
                              fontSize: 13,
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.9, // Make it responsive to screen width
                          height: 49, // Fixed height
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey), // Add border color
                            borderRadius: BorderRadius.circular(
                                10), // Add rounded corners
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                  width:
                                      20), // Add spacing to the left of the dropdown
                              Flexible(
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: InputBorder
                                        .none, // Remove the underline
                                    hintText: '', // Placeholder (if needed)
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 1), // Padding
                                  ),
                                  child: dep.isNotEmpty
                                      ? DropdownButton<Map<String, dynamic>>(
                                          isExpanded:
                                              true, // Ensures dropdown expands to available width
                                          value: dep.any((element) =>
                                                  element['name'] ==
                                                  selecteddepName)
                                              ? dep.firstWhere(
                                                  (element) =>
                                                      element['name'] ==
                                                      selecteddepName,
                                                )
                                              : null, // Check if selected value matches an item
                                          underline:
                                              Container(), // Remove the dropdown underline
                                          onChanged:
                                              (Map<String, dynamic>? newValue) {
                                            setState(() {
                                              selecteddepName = newValue![
                                                  'name']; // Update selected value
                                            });
                                          },
                                          items: dep.map<
                                              DropdownMenuItem<
                                                  Map<String, dynamic>>>(
                                            (Map<String, dynamic> depItem) {
                                              return DropdownMenuItem<
                                                  Map<String, dynamic>>(
                                                value:
                                                    depItem, // Use the item as the value
                                                child: Text(
                                                  depItem[
                                                      'name'], // Display the name
                                                  overflow: TextOverflow
                                                      .ellipsis, // Handle long text gracefully
                                                ),
                                              );
                                            },
                                          ).toList(),
                                          icon: Padding(
                                            padding: const EdgeInsets.only(
                                                right:
                                                    10), // Adjust icon padding
                                            child: Icon(Icons
                                                .arrow_drop_down), // Dropdown icon
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                              'Loading departments...'), // Fallback for empty dep list
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 5),
                        Text('Maneger',
                            style: TextStyle(
                              fontSize: 13,
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.9, // Make it responsive to screen width
                          height: 49, // Fixed height
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey), // Add border color
                            borderRadius: BorderRadius.circular(
                                10), // Add rounded corners
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                  width:
                                      20), // Add spacing to the left of the dropdown
                              Flexible(
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: InputBorder
                                        .none, // Remove the underline
                                    hintText: '', // Placeholder (if needed)
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 1), // Padding
                                  ),
                                  child: manager.isNotEmpty
                                      ? DropdownButton<Map<String, dynamic>>(
                                          isExpanded:
                                              true, // Ensures dropdown expands to available width
                                          value: manager.any((element) =>
                                                  element['name'] ==
                                                  selectedmanagerepName)
                                              ? manager.firstWhere(
                                                  (element) =>
                                                      element['name'] ==
                                                      selectedmanagerepName,
                                                )
                                              : null, // Check if selected value matches an item
                                          underline:
                                              Container(), // Remove the dropdown underline
                                          onChanged:
                                              (Map<String, dynamic>? newValue) {
                                            setState(() {
                                              selectedmanagerepName = newValue![
                                                  'name']; // Update selected value
                                            });
                                          },
                                          items: manager.map<
                                              DropdownMenuItem<
                                                  Map<String, dynamic>>>(
                                            (Map<String, dynamic> managerItem) {
                                              return DropdownMenuItem<
                                                  Map<String, dynamic>>(
                                                value:
                                                    managerItem, // Use the item as the value
                                                child: Text(
                                                  managerItem[
                                                      'name'], // Display the name
                                                  overflow: TextOverflow
                                                      .ellipsis, // Handle long text gracefully
                                                ),
                                              );
                                            },
                                          ).toList(),
                                          icon: Padding(
                                            padding: const EdgeInsets.only(
                                                right:
                                                    10), // Adjust icon padding
                                            child: Icon(Icons
                                                .arrow_drop_down), // Dropdown icon
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                              'Loading managers...'), // Fallback for empty manager list
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Marital Status Dropdown
                        SizedBox(height: 10),
                        Text('Marital Status',
                            style: TextStyle(
                              fontSize: 13,
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.9, // Make it responsive to screen width
                          height: 49, // Fixed height
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey), // Add border color
                            borderRadius: BorderRadius.circular(
                                10), // Add rounded corners
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                  width:
                                      20), // Add spacing to the left of the dropdown
                              Flexible(
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: InputBorder
                                        .none, // Remove the underline
                                    hintText: '', // Placeholder (if needed)
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 1), // Padding
                                  ),
                                  child: DropdownButton<String>(
                                    isExpanded:
                                        true, // Ensures dropdown expands to available width
                                    value: maritalStatus,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        maritalStatus =
                                            newValue; // Update marital status
                                      });
                                    },
                                    items: <String>[
                                      'Single',
                                      'Married',
                                      'Divorced',
                                      'Widowed'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value:
                                            value, // Use the item as the value
                                        child: Text(
                                          value, // Display the name
                                          overflow: TextOverflow
                                              .ellipsis, // Handle long text gracefully
                                        ),
                                      );
                                    }).toList(),
                                    icon: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10), // Adjust icon padding
                                      child: Icon(Icons
                                          .arrow_drop_down), // Dropdown icon
                                    ),
                                    underline:
                                        Container(), // Remove dropdown underline
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),


       
                                 SizedBox(height: 10),
                        Text('Warehouse',
                            style: TextStyle(
                              fontSize: 13,
                            )),
                                
                                
                                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: selectedwarehouseId,
                                    hint: Text('Select a Warehouse'),
                                    underline:
                                        SizedBox(), // Remove the default underline
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedwarehouseId = newValue;
                                        selectedwarehouseName =
                                            Warehouses.firstWhere((element) =>
                                                element['id'] ==
                                                newValue)['name'];
                                      });
                                    },
                                    items:
                                        Warehouses.map<DropdownMenuItem<int>>(
                                            (Warehouses) {
                                      return DropdownMenuItem<int>(
                                        value: Warehouses['id'],
                                        child: Text(Warehouses['name']),
                                      );
                                    }).toList(),
                                  ),
                                ),
                               
                        SizedBox(
                          height: 10,
                        ),
                       Padding(
  padding: const EdgeInsets.all(0.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 46,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Map<String, dynamic>>(
            isExpanded: true,
            hint: Text(
              'Select State',
              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
            ),
            value: stat.isNotEmpty && selectstate != null
                ? stat.firstWhere(
                    (element) => element['name'] == selectstate,
                    orElse: () => stat[0], // Default to first state if not found
                  )
                : null,
            items: stat.isNotEmpty
                ? stat.map<DropdownMenuItem<Map<String, dynamic>>>(
                    (Map<String, dynamic> state) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: state,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state['name'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (stat.contains(state['name']))
                              Icon(
                                Icons.check,
                                color: Colors.blue, // Indicate selected items
                              ),
                          ],
                        ),
                      );
                    },
                  ).toList()
                : [
                    DropdownMenuItem(
                      child: Text('No states available'),
                      value: null,
                    ),
                  ],
            onChanged: (Map<String, dynamic>? newValue) {
              if (newValue != null) {
                setState(() {
                  // Add the selected state to allocatedStateNames
                  if (!allocatedStateNames.contains(newValue['name'])) {
                    allocatedStateNames.add(newValue['name']);
                    

                      allocated_states = allocatedStateNames
                .map((stateId) => stat.firstWhere(
                      (element) => element['name'] == stateId,
                      orElse: () => {'id': 'Unknown'},
                    )['id'] as int) // Explicitly cast to String
                .toList();


                
                  }
                });
              }
            },
            icon: Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
      SizedBox(height: 13),

      // Display allocated state names as chips
      Wrap(
        spacing: 8.0, // Horizontal space between chips
        runSpacing: 4.0, // Vertical space between lines
        children: allocatedStateNames.map((stateName) {
          return Chip(
            label: Text(stateName),
            onDeleted: () {
              setState(() {
                // Remove the state from allocatedStateNames
                allocatedStateNames.remove(stateName);
                
                 allocated_states = allocatedStateNames
                .map((stateId) => stat.firstWhere(
                      (element) => element['name'] == stateId,
                      orElse: () => {'id': 'Unknown'},
                    )['id'] as int) // Explicitly cast to String
                .toList();


                
              });
            },
            deleteIcon: Icon(Icons.close,color: Colors.red,),
            backgroundColor: Colors.grey[200],
          );
        }).toList(),
      ),
    ],
  ),
),
SizedBox(height: 10,),
                        // Date Fields
                        _buildDateField('Date of Birth', date_of_birth,
                            (newDate) => selectedDateOfBirth = newDate),
                        _buildDateField(
                            'Driving License Expiry Date',
                            driving_license_exp_date,
                            (newDate) =>
                                selectedDrivingLicenseExpDate = newDate),
                        _buildDateField('Join Date', join_date,
                            (newDate) => selectedJoinDate = newDate),
                        _buildDateField('Confirmation Date', confirmation_date,
                            (newDate) => selectedConfirmationDate = newDate),
                        _buildDateField('Termination Date', termination_date,
                            (newDate) => selectedTerminationDate = newDate),

                        // Signature Image Section


Text("Profile Image",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
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
// If signature image is selected, show image with remove icon
Column(
    children: [
      if (selectedImage != null) 
        Stack(
          alignment: Alignment.topRight,
          children: [
            Image.file(
              File(selectedImage!.path),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: removeImage,
            ),
          ],
        )
      else if (selectedImagee != null)  // Ensure selectedImagee is also not null
        Stack(
          alignment: Alignment.topRight,
          children: [
            Image.network(
              '$api${selectedImagee!.path}',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, color: Colors.red),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: removeImage,
            ),
          ],
        )
      else
        Text("No Image Selected"), // Show a default text if both are null
    ],
  ),




                        Text("Signature",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),

                        // If image is not removed, show current image with the option to remove it

                        // Show option to upload image
                        GestureDetector(
                          onTap: imageSelect1,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(255, 224, 223, 223),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/upload.png',
                                  width: 24,
                                  height: 24,
                                  color: Color.fromARGB(255, 2, 2, 2),
                                ),
                                SizedBox(width: 10),
                                Text("Select Signature",
                                    style: TextStyle(
                                        color: Color.fromARGB(
                                            255, 116, 116, 116))),
                              ],
                            ),
                          ),
                        ),


SizedBox(height: 5),
Column(
    children: [
      if (selectedSignatureImage != null) 
        Stack(
          alignment: Alignment.topRight,
          children: [
            Image.file(
              File(selectedSignatureImage!.path),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: removeSignatureImage,
            ),
          ],
        )
      else if (selectedSignatureImagee != null)  // Ensure selectedImagee is also not null
        Stack(
          alignment: Alignment.topRight,
          children: [
            Image.network(
              '$api${selectedSignatureImagee!.path}',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, color: Colors.red),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: removeSignatureImage,
            ),
          ],
        )
      else
        Text("No Image Selected"), // Show a default text if both are null
    ],
  ),

                        // If signature image is selected, show image with remove icon
                     // If signature image is selected, show image with remove icon


SizedBox(height: 8,),
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
                                    width: 276,
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '',
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 1),
                                      ),
                                      child: DropdownButton<String>(
                                        value: approvalStatus,
                                        underline:
                                            Container(), // This removes the underline
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            approvalStatus = newValue!;
                                            
                                          });
                                        },
                                        items: type
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        icon: Container(
                                          padding: EdgeInsets.only(
                                              left:
                                                  137), // Adjust padding as needed
                                          alignment: Alignment.centerRight,
                                          child: Icon(Icons
                                              .arrow_drop_down), // Dropdown arrow icon
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
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {

                  RegisterUserData(context);
                  // Handle Submit action with updated dates and image

                 updateStaffImage(staffId, selectedImage,
                                          selectedImage1, context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 244, 66, 66),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width * 0.4, 50),
                  ),
                ),
                child: Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Utility method to build a TextField with controller
  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
          ),
        ),
      ),
    );
  }

  // Gender Radio Button helper
  Widget _genderRadioButton(String genderOption) {
    return Row(
      children: [
        Radio<String>(
          value: genderOption,
          groupValue: gender,
          onChanged: (String? value) {
            setState(() {
              gender = value;
            });
          },
        ),
        Text(genderOption),
      ],
    );
  }

  // Date Picker Helper
  Widget _buildDateField(String label, TextEditingController controller,
      Function(DateTime?) onDateSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          _selectDate(context, controller, onDateSelected);
        },
        child: AbsorbPointer(
          child: _buildTextField(label, controller),
        ),
      ),
    );
  }
}
