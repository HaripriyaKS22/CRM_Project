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
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DamagedStockReport extends StatefulWidget {
  const DamagedStockReport({super.key});

  @override
  State<DamagedStockReport> createState() => _DamagedStockReportState();
}

class _DamagedStockReportState extends State<DamagedStockReport> {
  List<Map<String, dynamic>> damagedstockdata = [];
  List<Map<String, dynamic>> damageList = [];
  TextEditingController searchController = TextEditingController();

  int totalquantity = 0; // Initialize totalquantity to 0
  DateTime? selectedDate; // For single date filter
  DateTime? startDate; // For date range filter
  DateTime? endDate; // For date range filter

  @override
  void initState() {
    super.initState();
    getdamagedstock();

  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Filter products by name
  void _filterProducts(String query) {
    setState(() {
      damageList = damagedstockdata.where((product) {
        final productName = product['product']?.toLowerCase() ?? '';
        return productName.contains(query.toLowerCase());
      }).toList();
    });
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


  // Filter by date range
  void _filterOrdersByDateRange() {
    if (startDate != null && endDate != null) {
      setState(() {
        damageList = damagedstockdata.where((order) {
          if (order['date'] == null) return false;
          final orderDate = DateFormat('yyyy-MM-dd').parse(order['date']);
          return orderDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
              orderDate.isBefore(endDate!.add(Duration(days: 1)));
        }).toList();
        total();
      });
    }
  }

  // Filter by single date
  void _filterOrdersBySingleDate() {
    if (selectedDate != null) {
      setState(() {
        damageList = damagedstockdata.where((order) {
          if (order['date'] == null) return false;
          final orderDate = DateFormat('yyyy-MM-dd').parse(order['date']);
          return orderDate.year == selectedDate!.year &&
              orderDate.month == selectedDate!.month &&
              orderDate.day == selectedDate!.day;
        }).toList();
        total();
      });
    }
  }

  // Select single date
  Future<void> _selectSingleDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _filterOrdersBySingleDate();
    }
  }

  // Select date range
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _filterOrdersByDateRange();
    }
  }

  // Reset filters
  void _resetFilters() {
    setState(() {
      damageList = List.from(damagedstockdata);
    });
  }

void total(){
              num quantitySum = 0;

   for (var productData in damageList) {

quantitySum+=productData['quantity']  as num;
setState(() {
  totalquantity=quantitySum.toInt();

});

   }
}
  Future<void> getdamagedstock() async {
  try {
    final token = await gettokenFromPrefs();

    var response = await http.get(
      Uri.parse('$api/api/grv/data/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    List<Map<String, dynamic>> damagedstocklist = [];
    
    
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['data'];

      for (var productData in productsData) {
        // Handle null value for 'updated_at' or other fields
        String updatedDate = productData['updated_at'] != null
            ? productData['updated_at'].split('T')[0]
            : 'N/A'; // Fallback value if 'updated_at' is null

        damagedstocklist.add({
          'id': productData['id'] ?? 0, // Provide default values if needed
          'product': productData['product'] ?? 'Unknown Product',
          'quantity': productData['quantity'] ?? 0,
          'date': updatedDate,
          'returnreason': productData['returnreason'] ?? 'No reason provided',
        });
      }
      
      setState(() {
        damagedstockdata = damagedstocklist;
        damageList = damagedstockdata;
        total();
      });
      
    }
  } catch (error) {
    
  }
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
          "Damaged Stock Report",
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
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectSingleDate(context),
          ),
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
     
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by product name...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                    width: 2.0,
                  ),
                ),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: getdamagedstock,
              child: damageList.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: damageList.length,
                      itemBuilder: (context, index) {
                        final damage = damageList[index];
                        return Card(
                          color: Colors.white,
                          elevation: 4,
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${damage['date']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Divider(color: Colors.blue),
                                Text(
                                  'Quantity: ${damage['quantity']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '${damage['product']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Reason: ${damage['returnreason']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Material(
            elevation: 12,
            color: const Color.fromARGB(255, 12, 80, 163),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Total Quantity:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '$totalquantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
