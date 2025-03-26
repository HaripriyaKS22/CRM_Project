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
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_admin.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:beposoft/pages/api.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getprofiledata();
  }

  var eid = "";
  var username = "";
  var family = "";
  var email = "";
  var phone = "";
  var alternate_number = "";
  var date_of_birth = "";
  var gender = "";
  var employment_status = "";
  var designation = "";
  var grade = "";
  var address = "";
  var city = "";
  var join_date = "";
  var confirmation_date = "";
  var termination_date = "";
  String imageUrl = '';

  var viewprofileurl = "$api/api/profile/";

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getprofiledata() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$viewprofileurl'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        
print("productsData:$productsData");
        setState(() {
  imageUrl = "${productsData['image'] ?? ''}";

  eid = productsData['eid']?.toString() ?? '';
  username = productsData['name'] ?? '';
  family = productsData['family']?.toString() ?? ''; // also int
  email = productsData['email'] ?? '';
  phone = productsData['phone'] ?? '';
  alternate_number = productsData['alternate_number'] ?? '';
  date_of_birth = productsData['date_of_birth'] ?? '';
  gender = productsData['gender'] ?? '';
  employment_status = productsData['employment_status'] ?? '';
  designation = productsData['designation'] ?? '';
  grade = productsData['grade'] ?? '';
  address = productsData['address'] ?? '';
  city = productsData['city'] ?? '';
  join_date = productsData['join_date'] ?? '';
  confirmation_date = productsData['confirmation_date'] ?? '';
  termination_date = productsData['termination_date'] ?? '';
});


        
      }
    } catch (error) {
      print("eroooo$error");
    }
  }
Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
Future<void> _navigateBack() async {
    final dep = await getdepFromPrefs();
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
else if(dep=="warehouse" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WarehouseDashboard()), // Replace AnotherPage with your target page
            );
}
else if(dep=="Warehouse Admin" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WarehouseAdmin()), // Replace AnotherPage with your target page
            );
}else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => dashboard()),
      );
    }
  }
  @override
Widget build(BuildContext context) {
  return WillPopScope(
     onWillPop: () async {
        // Prevent the swipe-back gesture (and back button)
        _navigateBack();
        return false;
      },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
              fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final dep = await getdepFromPrefs();
            if (dep == "BDO") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => bdo_dashbord()),
              );
            } else if (dep == "BDM") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => bdm_dashbord()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => dashboard()),
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      imageUrl.isNotEmpty ? '$api$imageUrl' : 'lib/assets/profile.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          'lib/assets/profile.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  "$username",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              if (designation.isNotEmpty)
                Center(
                  child: Text(
                    "Job Role: $designation",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              SizedBox(height: 20),
              if (eid.isNotEmpty)
                buildInfoContainer(Icons.badge, "Employee ID : $eid"),
              if (email.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child:
                      buildInfoContainer(Icons.email, "Email ID : $email"),
                ),
              if (phone.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child:
                      buildInfoContainer(Icons.phone, "Phone Number : $phone"),
                ),
              if (alternate_number.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: buildInfoContainer(
                      Icons.phone_android, "Alternate Number : $alternate_number"),
                ),
              if (date_of_birth.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child:
                      buildInfoContainer(Icons.cake, "DOB : $date_of_birth"),
                ),
              if (gender.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: buildInfoContainer(Icons.transgender, "Gender: $gender"),
                ),
              if (employment_status.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: buildInfoContainer(
                      Icons.work, "Employment Status: $employment_status"),
                ),
              if (grade.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: buildInfoContainer(Icons.grade, "Grade: $grade"),
                ),
              if (address.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: buildInfoContainer(Icons.home, "Address: $address"),
                ),
              if (city.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: buildInfoContainer(Icons.location_city, "City: $city"),
                ),
              if (join_date.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: buildInfoContainer(
                      Icons.calendar_today, "Joining Date: $join_date"),
                ),
              if (confirmation_date.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: buildInfoContainer(Icons.check_circle,
                      "Confirmation Date: $confirmation_date"),
                ),
              if (termination_date.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: buildInfoContainer(
                      Icons.close, "Termination Date: $termination_date"),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget buildInfoContainer(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
