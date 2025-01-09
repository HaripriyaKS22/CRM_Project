
import 'dart:convert';
import 'dart:io';
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_staff.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/update_supervisor.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:beposoft/pages/api.dart';
import 'package:beposoft/pages/ACCOUNTS/add_recipts.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/recipts_list.dart';
import 'package:beposoft/pages/ACCOUNTS/credit_note_list.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class update_staff extends StatefulWidget {
  final id;
   update_staff({super.key,required this.id});

  @override
  State<update_staff> createState() => _update_staffState();
}

class _update_staffState extends State<update_staff> {
 @override
  void initState() {
    super.initState();
    initdata();
    getmanegers();
    getstaff();
    getstates();
      getstafff();
  }
  void initdata()async{
    await getdepartments();

  }

var url = "$api/api/add/department/";
  String? selectedManagerName;
  int? selectedManagerId;
 String? selectstate;
  int? selectedStateId;
  List stat=[];
 List<int> dynamicStatid=[];
                    TextEditingController name = TextEditingController();
                    TextEditingController username = TextEditingController();
                    TextEditingController email = TextEditingController();
                    TextEditingController phone = TextEditingController();
                    TextEditingController alternate_number = TextEditingController();
                    TextEditingController password = TextEditingController();
                    TextEditingController driving_license = TextEditingController();
                    TextEditingController employment_status= TextEditingController();
                    TextEditingController designation= TextEditingController();
                    TextEditingController grade= TextEditingController();
                    TextEditingController address= TextEditingController();
                    TextEditingController city= TextEditingController();
                    TextEditingController Country= TextEditingController();
Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
   List<String>  gender = ["Female",'Male','Other'];
  String selectgender="Female";
   List<String>  material =["Married",'Single','Other'];
  String selectmarital="Single";
  List<String>  approval =["Approved",'Disapproved'];
  String approvalstatus="Approved";



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
      date4=DateFormat('yyyy-MM-dd').format(selectejoin);
            print("------------------------------$date4");
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
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selecteExp = DateTime(picked.year, picked.month, picked.day);
      date3=DateFormat('yyyy-MM-dd').format(selectejoin);
            print("------------------------------$date3");
      });
    }
  }


    var date1;
Future<void> _selectDate3(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );
  if (picked != null && picked != selectedDate) {
    setState(() {
      selectejoin = DateTime(picked.year, picked.month, picked.day);
      date1=DateFormat('yyyy-MM-dd').format(selectejoin);
            print("------------------------------$date1");

    });
  }
}
var date2;

      Future<void> _selectDate4(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
         selecteconf = DateTime(picked.year, picked.month, picked.day);
      date2=DateFormat('yyyy-MM-dd').format(selectejoin);
            print("------------------------------$date1");
      });
    }
  }



  List<Map<String, dynamic>> statess = [];

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
      print(
          "=============================================statesssssss${response.body}");
      List<Map<String, dynamic>> stateslist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print(
            "RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDhaaaiistatess$parsed");
        for (var productData in productsData) {
          stateslist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          statess = stateslist;

          print("WWWWWWWWWWWTTTTTTTTTTTTTTTTTTTTTTTTTTTTTstatesss$statess");
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }


   File? selectedImage;

  void imageSelect() async {
    try {
      print("sdgs");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          selectedImage = File(result.files.single.path!);

          print("imggg$selectedImage");
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
      print("sdgs");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          selectedImage1 = File(result.files.single.path!);

          print("imggg$selectedImage");
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
        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD${response.body}");
        List<Map<String, dynamic>> departmentlist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$parsed");
 for (var productData in productsData) {
          departmentlist.add({
            'id': productData['id'],
            'name': productData['name'],
            
          });
        
        }
        setState(() {
          dep = departmentlist;
                  print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$dep");

          
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }


   List sta = [];
Future<void> getstafff() async {
  try {
    final token = await gettokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/staff/update/${widget.id}/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['data'];

      // Extract allocated_states
      List<int> allocatedStates = [];
      if (productsData['allocated_states'] != null && productsData['allocated_states'] is List) {
        allocatedStates = List<int>.from(productsData['allocated_states']);
      }

      print("Allocated States: $allocatedStates");

      // Use the variable as needed
      setState(() {
      });
    } else {
      print("Failed to fetch staff: ${response.statusCode}");
    }
  } catch (error) {
    print("Error: $error");
  }
}

  Future<void> getstaff() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/staff/update/${widget.id}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];
print(response.body);
        print("staffffffffffffffffffffffff$parsed");


           if(widget.id==productsData['id']){
          name.text=productsData['name']?? '';;
           username.text = productsData['username'] ?? ''; // Assuming 'eid' corresponds to username
          email.text = productsData['email'] ?? '';
          phone.text = productsData['phone'] ?? '';
          alternate_number.text = productsData['alternate_number'] ?? '';
          password.text = ''; // You can leave this blank or handle it according to your logic
          driving_license.text = productsData['driving_license'] ?? ''; // Assuming there is a field for it
          employment_status.text = productsData['employment_status'] ?? '';
          designation.text = productsData['designation'] ?? '';
          grade.text = productsData['grade'] ?? ''; // If grade is available in productData
          address.text = productsData['address'] ?? ''; // Assuming there's an address field
          city.text = productsData['city'] ?? '';
          Country.text = productsData['country'] ?? ''; // Assuming there's a country field
selectedDepartmentId=productsData['department_id'];
print("oooooooooooooooooooooooooooooooo$selectedDepartmentId");
selectedManagerId=productsData['supervisor_id'];
print("oooooooooooooooooooooooooooooooo$selectedManagerId");
selectedDate = DateTime.parse(productsData['date_of_birth']);
selecteExp=DateTime.parse(productsData['driving_license_exp_date']);
selectejoin=DateTime.parse(productsData['join_date']);
selecteconf=DateTime.parse(productsData['confirmation_date']);



           }
        setState(() {
         
          
        });
      }
    } catch (error) {
      print("Error: $error");
    }
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
        print("=============================================${response.body}");
        List<Map<String, dynamic>> managerlist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$parsed");
 for (var productData in productsData) {
          managerlist.add({
            'id': productData['id'],
            'name': productData['name'],
            'department_name':productData['department_name'],
            
          });
        
        }
        setState(() {
          manager = managerlist;
                  print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$dep");

          
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }
  
  void addsupervisor(String name, BuildContext context) async {
    print("eeeeeeeeeeeeeeeeeeeeeeeeee$name");
        print("eeeeeeeeeeeeeeeeeeeeeeeeee$url");

          final token = await gettokenFromPrefs();

    try {
      var response = await http.post(
        Uri.parse("$api/api/add/supervisor/"),
        headers: {
          'Authorization': '$token',
          
        },
        body: {
          "name": name,
          "department":selectedDepartmentId.toString(),

        },
      );

      print("RRRRRRRRRRRRRRRRRRRREEEEEEEEEEEESSSSSSS${response.statusCode}");

      if (response.statusCode == 201) {

     Navigator.push(context, MaterialPageRoute(builder: (context)=>add_staff()));
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 49, 212, 4),
          content: Text('sucess'),
        ),
      );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }
 Future<void> deletedepartment(int Id) async {
    final token = await gettokenFromPrefs();

    try {
      final response = await http.delete(
        Uri.parse('$api/api/supervisor/delete/$Id/'),
        headers: {
          'Authorization': '$token',
        },
      );
    print(response.statusCode);
    if(response.statusCode == 200){
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 49, 212, 4),
          content: Text('Deleted sucessfully'),
        ),
      );
         Navigator.push(context, MaterialPageRoute(builder: (context)=>add_staff()));
    }

      if (response.statusCode == 204) {
      } else {
        throw Exception('Failed to delete wishlist ID: $Id');
      }
    } catch (error) {
    }
  }

  void removeProduct(int index) {
    setState(() {
      manager.removeAt(index);
    });
  }

   int? selectedmanagerId; // Variable to store the selected department's ID
  String? selectedmanagerName; // Variable to store the selected department's name


 int? selectedDepartmentId; // Variable to store the selected department's ID
  String? selectedDepartmentName; // Variable to store the selected department's name
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


 void update(
    int selectedDepartmentId,
    File? image1,
    DateTime selectedDate,
    
    String selectgender,
    String selectmarital,
    DateTime selecteExp,
    DateTime selectejoin,
    DateTime selecteconf,
    File? image2,
    BuildContext scaffoldContext,
  ) async {
    final token = await gettokenFromPrefs();
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$api/api/add/staff/'));
      // Add headers to the request
      request.headers['Authorization'] = 'Bearer $token';

      // Prepare the JSON data for the text fields
      Map<String, dynamic> data = {
        'date_of_birth': selectedDate.toIso8601String(),
        'driving_license_exp_date': selecteExp.toIso8601String(),
        'join_date': selectejoin.toIso8601String(),
        'confirmation_date': selecteconf.toIso8601String(),
        'allocated_states': dynamicStatid,
      };
      // Add JSON data as a field
      request.fields['data'] = jsonEncode(data);
      request.fields['name'] = name.text;
      request.fields['username'] = username.text;

      print("nameeeeeeeeeeeeeeeeeee${name.text}");
      request.fields['email'] = email.text;
      request.fields['phone'] = phone.text;
      request.fields['password'] = password.text;
      request.fields['alternate_number'] = alternate_number.text;
      request.fields['designation'] = designation.text;
      request.fields['grade'] = grade.text;
      request.fields['address'] = address.text;
      request.fields['city'] = city.text;
      request.fields['country'] = Country.text;
      request.fields['driving_license'] = driving_license.text;
      request.fields['department_id'] = selectedDepartmentId.toString();
      request.fields['supervisor_id'] = selectedmanagerId.toString();
      request.fields['gender'] = selectgender;
      request.fields['marital_status'] = selectmarital;
      request.fields['employment_status'] = employment_status.text;
      request.fields['APPROVAL_CHOICE'] = approvalstatus;
      // Add images to the request if they are not null
      if (image1 != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image1.path));
      }
      if (image2 != null) {
        request.files
            .add(await http.MultipartFile.fromPath('signatur_up', image2.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Response: ${response.body}");
      // Handle response based on status code
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: Text('Data Added Successfully.')),
        );
        Navigator.pushReplacement(
          scaffoldContext,
          MaterialPageRoute(builder: (context) => add_staff()),
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
              content: Text('Something went wrong. Please try again later.')),
        );
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
              content: Text('Something went wrong. Please try again later.')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(content: Text('Network error. Please check your connection.')),
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
          "Update Staff",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Custom back arrow
          onPressed: () async{
                 Navigator.pop(context);
          },
        ),
        actions: [
            IconButton(
              icon: Image.asset('lib/assets/profile.png'),
               
              onPressed: () {
                
              },
            ),
          ],
          
          ),


        body: Builder(
          builder: (BuildContext scaffoldContext) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 15),
                Text(
                  "STAFF",
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
              border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
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
                      border: Border.all(color: Color.fromARGB(255, 202, 202, 202)),
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
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: name,
                      decoration: InputDecoration(
                        labelText: 'name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: username,
                      decoration: InputDecoration(
                        labelText: 'username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                 
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: alternate_number,
                      decoration: InputDecoration(
                        labelText: 'Alternate Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                 
                   Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(color: Colors.grey),
  ),
  padding: EdgeInsets.symmetric(horizontal: 12),
  child: DropdownButton<int>(
    isExpanded: true,
    value: selectedDepartmentId != null
        ? dep.firstWhere(
            (department) => department['id'] == selectedDepartmentId,
            orElse: () => dep[0],
          )['id']
        : 
        dep[0]['id'],
    
    underline: SizedBox(), // Remove the default underline
    onChanged: (int? newValue) {
      setState(() {
        selectedDepartmentId = newValue;
        print("departmentid::::::::::::;$selectedDepartmentId");
        selectedDepartmentName = dep
            .firstWhere((element) => element['id'] == newValue)['name'];
      });
    },
    items:dep.isNotEmpty ?
     dep.map<DropdownMenuItem<int>>((department) {
      return DropdownMenuItem<int>(
        value: department['id'],
        child: Text(department['name']),
      );
    }).toList()
     : [
                                 DropdownMenuItem(
                                   child: Text('No depatment available'),
                                   value: null,
                                 ),
                               ],
  ),
),
                  SizedBox(height: 10,),
                 
                
                   Container(
                     decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(color: Colors.grey),
  ),
                     child: InputDecorator(
                       decoration: InputDecoration(
                         border: InputBorder.none,
                         hintText: '',
                         contentPadding: EdgeInsets.symmetric(horizontal: 1),
                       ),
                       child: DropdownButton<Map<String, dynamic>>(
                         value: manager.isNotEmpty
                             ? manager.firstWhere(
                                 (element) => element['id'] == selectedManagerId,
                                 orElse: () => manager[0],
                               )
                                      : null,
                         underline: Container(),
                         onChanged: manager.isNotEmpty
                             ? (Map<String, dynamic>? newValue) {
                                 setState(() {
                                   selectedManagerName = newValue!['name'];
                                   selectedManagerId = newValue['id'];
                                   print('Selected Manager Name: $selectedManagerName');
                                   print('Selected Manager ID: $selectedManagerId');
                                 });
                               }
                             : null,
                         items: manager.isNotEmpty
                             ? manager.map<DropdownMenuItem<Map<String, dynamic>>>(
                                 (Map<String, dynamic> manager) {
                                   return DropdownMenuItem<Map<String, dynamic>>(
                                     value: manager,
                                     child: Text(manager['name']),
                                   );
                                 },
                               ).toList()
                             : [
                                 DropdownMenuItem(
                                   child: Text('No managers available'),
                                   value: null,
                                 ),
                               ],
                         icon: Container(
                           alignment: Alignment.centerRight,
                           child: Icon(Icons.arrow_drop_down),
                         ),
                       ),
                     ),
                   ),
                  SizedBox(height: 10,),
            
            
                  GestureDetector(
                                              onTap: () {
                                               imageSelect();
                                              },
                                              child: Container(
                                                height: 55,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Color.fromARGB(
                                                      255, 224, 223, 223),
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
                                                      color: Color.fromARGB(
                                                          255,
                                                          2,
                                                          2,
                                                          2), // Adjust the color of the image
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            10), // Spacer between icon and text
                                                    Text(
                                                      "Select Profile Image",
                                                      style: TextStyle(
                                                          color:
                                                              const Color.fromARGB(
                                                                  255,
                                                                  116,
                                                                  116,
                                                                  116)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5,),
            
                                             Text(
                    "Date Of Birth",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                                                             SizedBox(height: 5,),
            
                                            Container(
                            width: constraints.maxWidth * 0.9, // Adjusted width based on screen size
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 30),
                                      Text(
                                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                        style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 116, 116, 116)),
                                      ),
                                      SizedBox(width: 162),
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
                          ),
            
                          SizedBox(height: 5),
                                               Text(
                    "State$stat",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5,),
                               Container(
              width: double.infinity, // Use full width available
              height: 49,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: InputDecorator(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10), // Adjust padding as needed
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
            value: statess.isNotEmpty
                ? statess.firstWhere(
                    (element) => element['name'] == selectstate,
                    orElse: () => statess[0],
                  )
                : null,
            onChanged: statess.isNotEmpty
                ? (Map<String, dynamic>? newValue) {
                    setState(() {
                        selectstate = newValue!['name'];
                        selectedStateId = newValue['id']; // Store the selected state's ID

                        // Check if the selected state is already in the list
                        if (!stat.contains(selectstate)&&!dynamicStatid.contains(selectedStateId)) {
                          stat.add(selectstate!);
                          dynamicStatid.add(selectedStateId!);


                        }
                        else{
                          stat.remove(selectstate!);
                                                    dynamicStatid.remove(selectedStateId);

                        }

                        print('Selected State Name: $stat');
                        print('Selected State ID: $dynamicStatid');
                      });

                  }
                : null,
            items: statess.isNotEmpty
                ? statess.map<DropdownMenuItem<Map<String, dynamic>>>(
                    (Map<String, dynamic> state) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: state,
                        child: Text(state['name']),
                      );
                    },
                  ).toList()
                : [
                    DropdownMenuItem(
                      child: Text('No states available'),
                      value: null,
                    ),
                  ],
            icon: Icon(Icons.arrow_drop_down),
            isExpanded: true, // Ensure dropdown takes full width
                  ),
                ),
              ),
            ),
              SizedBox(height: 5),
                                               Text(
                    "Gender",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5,),
                          Container(
                            width: constraints.maxWidth * 0.9, // Adjusted width based on screen size
                            height: 49,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 20),
                                Container(
                                  width: constraints.maxWidth * 0.7, // Adjusted width based on screen size
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 1),
                                    ),
                                    child: DropdownButton<String>(
                                      value: selectgender,
                                      underline: Container(), // This removes the underline
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectgender = newValue!;
                                          print(selectgender);
                                        });
                                      },
                                      items: gender.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      icon: Container(
                                        padding: EdgeInsets.only(left: constraints.maxWidth * 0.35),
                                        alignment: Alignment.centerRight,
                                        child: Icon(Icons.arrow_drop_down),
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
                  SizedBox(height: 5,),
                          Container(
                            width: constraints.maxWidth * 0.9, // Adjusted width based on screen size
                            height: 49,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 20),
                                Container(
                                  width: constraints.maxWidth * 0.6, // Adjusted width based on screen size
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 1),
                                    ),
                                    child: DropdownButton<String>(
                                      value: selectmarital,
                                      underline: Container(), // This removes the underline
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectmarital = newValue!;
                                          print(selectmarital);
                                        });
                                      },
                                      items: material.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      icon: Container(
                                        padding: EdgeInsets.only(left: constraints.maxWidth * 0.35),
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: driving_license,
                      decoration: InputDecoration(
                        labelText: 'Driving License',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
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
                  SizedBox(height: 5,),
                                            Container(
                            width: constraints.maxWidth * 0.9, // Adjusted width based on screen size
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 30),
                                      Text(
                                        '${selecteExp.day}/${selecteExp.month}/${selecteExp.year}',
                                        style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 116, 116, 116)),
                                      ),
                                      SizedBox(width: 162),
                                      GestureDetector(
                                        onTap: () {
                                          _selectDate2(context);
                                          print('Icon pressed');
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
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: employment_status,
                      decoration: InputDecoration(
                        labelText: 'Employment Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                   SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: designation,
                      decoration: InputDecoration(
                        labelText: 'Designation',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                   SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: grade,
                      decoration: InputDecoration(
                        labelText: 'Grade',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
             SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: address,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
            
                   SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: city,
                      decoration: InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
            
                   SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: Country,
                      decoration: InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
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
                  SizedBox(height: 5,),
                                            Container(
                            width: constraints.maxWidth * 0.9, // Adjusted width based on screen size
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 30),
                                      Text(
                                        '${selectejoin.day}/${selectejoin.month}/${selectejoin.year}',
                                        style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 116, 116, 116)),
                                      ),
                                      SizedBox(width: 162),
                                      GestureDetector(
                                        onTap: () {
                                          _selectDate3(context);
                                          print('Icon pressed');
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
                  SizedBox(height: 5,),
                                            Container(
                            width: constraints.maxWidth * 0.9, // Adjusted width based on screen size
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 30),
                                      Text(
                                        '${selecteconf.day}/${selecteconf.month}/${selecteconf.year}',
                                        style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 116, 116, 116)),
                                      ),
                                      SizedBox(width: 162),
                                      GestureDetector(
                                        onTap: () {
                                          _selectDate4(context);
                                          print('Icon pressed');
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
                  SizedBox(height: 5,),
            
              GestureDetector(
                                              onTap: () {
                                               imageSelect1();
                                              },
                                              child: Container(
                                                height: 55,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Color.fromARGB(
                                                      255, 224, 223, 223),
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
                                                      color: Color.fromARGB(
                                                          255,
                                                          2,
                                                          2,
                                                          2), // Adjust the color of the image
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            10), // Spacer between icon and text
                                                    Text(
                                                      "Select Signature",
                                                      style: TextStyle(
                                                          color:
                                                              const Color.fromARGB(
                                                                  255,
                                                                  116,
                                                                  116,
                                                                  116)),
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
                  SizedBox(height: 5,),
                          Container(
                            width: constraints.maxWidth * 0.9, // Adjusted width based on screen size
                            height: 49,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 20),
                                Container(
                                  width: constraints.maxWidth * 0.6, // Adjusted width based on screen size
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 1),
                                    ),
                                    child: DropdownButton<String>(
                                      value: approvalstatus,
                                      underline: Container(), // This removes the underline
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          approvalstatus = newValue!;
                                          print(approvalstatus);
                                        });
                                      },
                                      items: approval.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      icon: Container(
                                        padding: EdgeInsets.only(left: constraints.maxWidth * 0.1),
                                        alignment: Alignment.centerRight,
                                        child: Icon(Icons.arrow_drop_down),
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
                      setState(() {
                        // stattt(stat.toString());
                        print(stat);
                                        update(selectedDepartmentId!,selectedImage,selectedDate,selectgender,selectmarital,selecteExp,selectejoin,selecteconf,selectedImage1,scaffoldContext);
            
                      });
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
                ),
             SizedBox(height: 15),
             Padding(
               padding: const EdgeInsets.only(left: 15),
               child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                 children: [
                   Text(
                      "Available Staff",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                 ],
               ),
             ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 15,left: 15),
                child: Container(
                  color: Colors.white,
                  child: Table(
                    
                    border: TableBorder.all(color: Color.fromARGB(255, 214, 213, 213)),
                    columnWidths: {
                         0: FixedColumnWidth(40.0), // Fixed width for the first column (No.)
                      1: FlexColumnWidth(2),     // Flex width for the second column (Department Name)
                      2: FixedColumnWidth(50.0), // Fixed width for the third column (Edit)
                      3: FixedColumnWidth(50.0), // Fixed width for the fourth column (Delete)
                  
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 234, 231, 231),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "No.",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Manager Name",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                            Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Edit",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Delete",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>update_supervisor(id:manager[i]['id'])));
                                           
                                                },
                                                child: Image.asset(
                                                                "lib/assets/edit.jpg",
                                           
                                                  width: 20,
                                                  height: 20,
                                                 
                                                ),
                                              ),
                                         ),
                             Padding(
                               padding: const EdgeInsets.all(8.0),
                               child: GestureDetector(
                                                onTap: () {
                                                   deletedepartment(sta[i]['id']);
                                                  removeProduct(i);
                                                },
                                                child: Image.asset(
                                                  "lib/assets/delete.gif",
                                                  width: 20,
                                                  height: 20,
                                                  
                                                ),
                               ),
                             )
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
          }
        )




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