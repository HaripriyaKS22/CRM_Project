import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/creditsale_date_report.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ADMIN/admin_dashboard.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Creditsalereport2 extends StatefulWidget {
  const Creditsalereport2({super.key});

  @override
  State<Creditsalereport2> createState() => _Creditsalereport2State();
}

class _Creditsalereport2State extends State<Creditsalereport2> {
  List<Map<String, dynamic>> allSalesReportList = [];
  List<Map<String, dynamic>> fam = [];
  List<Map<String, dynamic>> sta = [];
  String? selectedFamily;
  String? selectedStaff;

  @override
  void initState() {
    super.initState();
    getfamily();
    getCreditsaleReport();
    getstaff();
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch staff list from the API
  Future<void> getstaff() async {
    try {
      final token = await getTokenFromPrefs();

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
          stafflist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          sta = stafflist;
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  // Fetch family list from the API
  Future<void> getfamily() async {
    try {
      final token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/familys/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      List<Map<String, dynamic>> familylist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        for (var productData in productsData) {
          familylist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          fam = familylist;
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  // Fetch sales report
 Future<void> getCreditsaleReport() async {
  setState(() {});
  try {
    final token = await getTokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/credit/sales/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final salesData = jsonDecode(response.body);

      List<Map<String, dynamic>> salesReportDataList = [];
      double totalAmount = 0.0;
      int totalOrders = 0;
      double totalPaidAmount = 0.0;
      double balanceAmount = 0.0;

      // Loop over the data and extract values
      for (var reportData in salesData) {
        // Get the date for the current report (assuming each reportData has a `date` field)
        String date = reportData['date'] ?? 'Unknown'; // Default to 'Unknown' if no date is found

        // Filter orders based on the selected family and staff name
        if (selectedFamily != null) {
          reportData['orders'] = reportData['orders'].where((order) {
            return order['family_name'] == selectedFamily;
          }).toList();
        }

        if (selectedStaff != null) {
          reportData['orders'] = reportData['orders'].where((order) {
            return order['staff_name'] == selectedStaff;
          }).toList();
        }

        for (var order in reportData['orders']) {
          totalOrders++;
          totalAmount += order['total_amount'];

          // Calculate the total received payment for this order
          double totalReceivedPayment = 0.0;
          for (var payment in order['recived_payment']) {
            // Parse the amount as a double
            totalReceivedPayment += double.parse(payment['amount']);
          }

          totalPaidAmount += totalReceivedPayment;
          balanceAmount += (order['total_amount'] - totalReceivedPayment);
        }

        // Add calculated values to the report list
        salesReportDataList.add({
          'date': date, // Use the extracted date
          'total_amount': totalAmount,
          'total_orders': totalOrders,
          'total_paid_amount': totalPaidAmount,
          'balance_amount': balanceAmount,
        });
      }

      setState(() {
        allSalesReportList = salesReportDataList;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch sales report data'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error fetching sales report data'),
        duration: Duration(seconds: 2),
      ),
    );
  } finally {
    setState(() {});
  }
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
Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Credit Sale Report',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
       leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Custom back arrow
          onPressed: () async {
            final dep = await getdepFromPrefs();
            if (dep == "BDO") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        bdo_dashbord()), // Replace AnotherPage with your target page
              );
            } else if (dep == "BDM") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        bdm_dashbord()), // Replace AnotherPage with your target page
              );
            }

            else if (dep == "ADMIN") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        admin_dashboard()), // Replace AnotherPage with your target page
              );
            }
            
            
            else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        dashboard()), // Replace AnotherPage with your target page
              );
            }
          },
        ),
      ),
    
      body: Column(
        children: [
          // Dropdown for selecting a family
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Select Family',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select Family"),
                  value: selectedFamily,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFamily = newValue;
                    });
                    getCreditsaleReport();
                  },
                  items: fam.map((family) {
                    return DropdownMenuItem<String>(
                      value: family['name'],
                      child: Text(family['name']),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // Dropdown for selecting staff
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Select Staff',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select Staff"),
                  value: selectedStaff,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStaff = newValue;
                    });
                    getCreditsaleReport();
                  },
                  items: sta.map((staff) {
                    return DropdownMenuItem<String>(
                      value: staff['name'],
                      child: Text(staff['name']),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // Displaying the sales report data
          allSalesReportList.isEmpty
              ? Center(child: CircularProgressIndicator()) // Loading indicator
              : Expanded(
                  child: ListView.builder(
                    itemCount: allSalesReportList.length,
                    itemBuilder: (context, index) {
                      final report = allSalesReportList[index];
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.all(8.0),
                        elevation: 5.0,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            'Date: ${report['date']}',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: Colors.grey),
                              Text(
                                'Total Orders: ${report['total_orders']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total Amount: ₹${report['total_amount']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total Paid Amount: ₹${report['total_paid_amount']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Balance Amount: ₹${report['balance_amount']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CreditsaleDateReport(
                                              date: report['date']),
                                    ),
                                  );
                                },
                                child: Text(
                                  "View",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
