import 'dart:convert';

import 'package:beposoft/pages/ACCOUNTS/ASD_dashborad.dart';
import 'package:beposoft/pages/ACCOUNTS/provider.dart';
import 'package:beposoft/pages/ADMIN/admin_dashboard.dart';
import 'package:beposoft/pages/ADMIN/ceo_dashboard.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/HR/hr_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_admin.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_dashboard.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:new_version_plus/new_version_plus.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
void main() {
  runApp(const beposoftmain());
}

class beposoftmain extends StatefulWidget {
  const beposoftmain({super.key});

  @override
  State<beposoftmain> createState() => _beposoftmainState();
}

class _beposoftmainState extends State<beposoftmain> {
  bool tok = false;
  bool tokenn = true;
  var department;

  @override
  void initState() {
    super.initState();
    check();
    getbank();
    // checkForUpdate();
    getCurrentAppVersion();
  
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }

  Future<void> storeUserData(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  void check() async {
    final token = await gettokenFromPrefs();

    try {
      if (token != null) {
        final jwt = JWT.decode(token);
        var dep = jwt.payload['active'];

        setState(() {
          department = dep;
          tok = true; // Token is valid
        });
      } else {
        setState(() {
          tokenn = false;
        });
        navigateToLogin();
      }
    } catch (e) {
      setState(() {
        tokenn = false;
      });
      navigateToLogin();
    }
  }

  Future<void> getbank() async {
    final token = await gettokenFromPrefs();

    try {
      final response = await http.get(
        Uri.parse('$api/api/banks/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final parsed = jsonDecode(response.body);

      if (parsed['message'] == "Token has expired" || parsed['message'] == "Invalid token") {
        await clearToken();
        setState(() {
          tokenn = false;
        });
        navigateToLogin();
      }
    } catch (e) {
      setState(() {
        tokenn = false;
      });
      navigateToLogin();
    }
  }

  Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => login()),
    );
  }
Future<void> checkLatestVersion() async {
  final newVersion = NewVersionPlus(
    androidId: 'com.bepositive.beposoft', // Your Android package name
    iOSId: '1234567890', // Your iOS App ID
  );

  final status = await newVersion.getVersionStatus();
  if (status != null) {
  

    if (status.canUpdate) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Update Available',
        dismissButtonText: 'Later',
        updateButtonText: 'Update Now',
      );
    }
  }
}
  void checkForUpdate() async {
  
    final newVersion = NewVersionPlus(
      androidId: '.beposoft', // Replace with your package name
      iOSId: 'your.ios.bundle.id', // Replace if you have iOS
    );
    final status = await newVersion.getVersionStatus();
 
    if (status != null && status.canUpdate) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Update Available',
        dialogText: 'A new version of the app is available! Please update.',
        updateButtonText: 'Update',
        dismissButtonText: 'Later',
      );
    }
  }
Future<void> getCurrentAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

    checkLatestVersion();
}
  @override
  Widget build(BuildContext context) {
    // Ensure that we only call layout-related code after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final RenderBox? renderBoxNullable = context.findRenderObject() as RenderBox?;
        if (renderBoxNullable != null) {
          final RenderBox renderBox = renderBoxNullable;
          // Safe to use renderBox here
        } else {
        }
        // Safe to call localToGlobal or any other method if needed
      } catch (e) {
      }
    });

    return MultiProvider(

      providers: [
        ChangeNotifierProvider<counterModel>
        (create: (_) => counterModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: tokenn
            ? department == "BDM"
                ? bdm_dashbord()
                : department == "warehouse"
                    ? WarehouseDashboard()
                    : department == "BDO"
                        ? bdo_dashbord()
                        : department == "ADMIN"
                            ? admin_dashboard()
                            : department == "Accounts / Accounting "
                                ? admin_dashboard()
                                : department == "CEO"
                                  ? ceo_dashboard()
                                  : department == "ASD"
                                    ? asd_dashbord()
                                    : department == "Information Technology"
                                        ? admin_dashboard()
                                        : department == "HR"
                                          ? HrDashboard()
                                          : department == "Warehouse Admin"
                                            ? WarehouseAdmin()
                                              : department == "COO"
                                                ? admin_dashboard()
                                                : dashboard()
            : login(),
      ),
    );
  }
}
