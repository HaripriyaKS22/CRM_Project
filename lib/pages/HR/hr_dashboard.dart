import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_staff.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/profilepage.dart';
import 'package:beposoft/pages/HR/attendance.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HrDashboard extends StatefulWidget {
  const HrDashboard({super.key});

  @override
  State<HrDashboard> createState() => _HrDashboardState();
}

class _HrDashboardState extends State<HrDashboard> {
  String? username = '';
  void initState() {
    super.initState();
    _getUsername(); // Get the username when the page loads
  }

  Future<String?> getusernameFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // Retrieve the username from SharedPreferences
  Future<void> _getUsername() async {
    final name = await getusernameFromPrefs();
    setState(() {
      username = name ?? 'Guest'; // Default to 'Guest' if no username
    });
  }

  Widget _buildDropdownTile(
      BuildContext context, String title, List<String> options) {
    return ExpansionTile(
      title: Text(title),
      children: options.map((option) {
        return ListTile(
          title: Text(option),
          onTap: () {
            Navigator.pop(context);
            d.navigateToSelectedPage2(
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

    // Show the SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged out successfully'),
        duration: Duration(seconds: 2),
      ),
    );

    // Wait for the SnackBar to disappear before navigating
    await Future.delayed(Duration(seconds: 2));

    // Navigate to the HomePage after the snackbar is shown
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => login()),
    );
  }

  drower d = drower();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HR Dashboard',style: TextStyle(color: Colors.grey,fontSize: 12),),
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
                    MaterialPageRoute(builder: (context) => HrDashboard()));
              },
            ),
            Divider(),
            ListTile(
              title: Text('Attendence Sheet'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AttendanceSheet()));
              },
            ),
            ListTile(
              title: Text('Add Staff'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => add_staff()));
              },
            ),
            
           
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
                logout();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(
                          'lib/assets/female.jpeg'), // Replace with your new image
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '$username',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: [
                    // Display the count of today's shipped orders in cards
                    GestureDetector(
                      onTap: () {
                                  Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AttendanceSheet()),
                        );
                      },
                      child: _buildCard(
                        Icons.calendar_today,
                        'Attendance  ',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                                  Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => add_staff()),
                        );
                      },
                      child: _buildCard(
                        Icons.person,
                        'Staff',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildCard(IconData icon, String title, [int count = 0]) {
  return Container(
    height: 120.0, // Set a fixed height for each card
    margin: EdgeInsets.symmetric(vertical: 8.0),
    child: Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 20,
              ),
              ListTile(
                leading: Icon(icon, size: 40, color: Colors.blue),
                title:
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  // Handle item tap if needed
                },
              ),
            ],
          ),
          if (count > 0)
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
