import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/codsale_date_report.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CodSales2 extends StatefulWidget {
  const CodSales2({super.key});

  @override
  State<CodSales2> createState() => _CodSales2State();
}

class _CodSales2State extends State<CodSales2> {
  List<Map<String, dynamic>> allCodReportList = [];
  List<Map<String, dynamic>> stat = [];

  List<Map<String, dynamic>> fam = [];
  String? selectedFamily;
  String? selectedStaff;
   String? selectedState; 
  List<Map<String, dynamic>> sta = [];

  @override
  void initState() {
    super.initState();
    getCODsaleReport();
    getfamily();
    getstaff();
    getstate();
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getstate() async {
    try {
      final token = await getTokenFromPrefs();

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
    } catch (error) {}
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
Future<void> getCODsaleReport() async {
  setState(() {});
  try {
    final token = await getTokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/COD/sales/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final salesData = jsonDecode(response.body);

      List<Map<String, dynamic>> salesReportDataList = [];

      for (var reportData in salesData) {
        // Filter orders based on the selected family, staff name, and state
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

        if (selectedState != null) {
          reportData['orders'] = reportData['orders'].where((order) {
            return order['state'] == selectedState;
          }).toList();
        }

        double totalAmount = 0.0;
        int totalOrders = 0;
        double totalPaidAmount = 0.0;
        double balanceAmount = 0.0;

        for (var order in reportData['orders']) {
          totalAmount += order['total_amount'];
        }

        totalOrders = reportData['orders'].length;
        totalPaidAmount = reportData['orders']
            .fold(0.0, (sum, order) => sum + order['total_paid_amount']);
        balanceAmount = reportData['orders']
            .fold(0.0, (sum, order) => sum + order['balance_amount']);

        salesReportDataList.add({
          'date': reportData['date'],
          'total_amount': totalAmount,
          'total_orders': totalOrders,
          'total_paid_amount': totalPaidAmount,
          'balance_amount': balanceAmount,
        });
      }

      setState(() {
        allCodReportList = salesReportDataList;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'COD Sales Report',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
      body: Column(
        children: [
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
                    getCODsaleReport();
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
                    getCODsaleReport();
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

          Padding(
  padding: const EdgeInsets.all(8.0),
  child: InputDecorator(
    decoration: InputDecoration(
      labelText: 'Select State',
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
        hint: Text("Select State"),
        value: selectedState,
        onChanged: (String? newValue) {
          setState(() {
            selectedState = newValue;
          });
          getCODsaleReport(); // Filter report based on state
        },
        items: stat.map((state) {
          return DropdownMenuItem<String>(
            value: state['name'],
            child: Text(state['name']),
          );
        }).toList(),
      ),
    ),
  ),
),

          // Show the total orders and amounts for the selected family

          allCodReportList.isEmpty
              ? Center(child: CircularProgressIndicator()) // Loading indicator
              : Expanded(
                  child: ListView.builder(
                    itemCount: allCodReportList.length,
                    itemBuilder: (context, index) {
                      final report = allCodReportList[index];
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
                              SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              codsalereport_datewise_view(
                                                  date: report['date'])));
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
