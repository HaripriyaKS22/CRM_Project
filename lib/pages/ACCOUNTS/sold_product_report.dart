import 'dart:convert';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SoldProductReport extends StatefulWidget {
  const SoldProductReport({super.key});

  @override
  State<SoldProductReport> createState() => _SoldProductReportState();
}

class _SoldProductReportState extends State<SoldProductReport> {
Map<String, Map<String, Map<String, dynamic>>> filteredGroupedData = {}; // Add a filtered version    List<Map<String, dynamic>> soldproducdata = [];
  TextEditingController searchController = TextEditingController();
List<Map<String, dynamic>> sta = [];
    int? selectedstaffId;

  double totalBills = 0.0;
  double totalAmount = 0.0;
  double approvedBills = 0.0;
  double approvedAmount = 0.0;
  double rejectedBills = 0.0;
  double rejectedAmount = 0.0;

  DateTime? selectedDate; // For single date filter
  DateTime? startDate; // For date range filter
  DateTime? endDate; // For date range filter

  @override
  void initState() {
    super.initState();
    getSoldReport();
    getstaff();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
          _filterDataByDateRange();

    }
  }

  drower d = drower();

  // Get token from SharedPreferences
  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
   
   Map<String, Map<String, Map<String, dynamic>>> groupedData = {};

 void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredGroupedData = groupedData; // If query is empty, show all data
      });
    } else {
      Map<String, Map<String, Map<String, dynamic>>> tempFilteredData = {};

      groupedData.forEach((orderDate, products) {
        Map<String, Map<String, dynamic>> tempProductData = {};

        products.forEach((productName, productData) {
          if (productName.toLowerCase().contains(query.toLowerCase())) {
            tempProductData[productName] = productData; // Add matching product
          }
        });

        if (tempProductData.isNotEmpty) {
          tempFilteredData[orderDate] = tempProductData;
        }
      });

      setState(() {
        filteredGroupedData = tempFilteredData; // Update filtered data
      });
    }
  }
 void _filterDataByDateRange() {
  if (startDate != null && endDate != null) {
    Map<String, Map<String, Map<String, dynamic>>> tempFilteredData = {};

    groupedData.forEach((orderDateString, products) {
      final orderDate = DateTime.parse(orderDateString);

      // Check if the order date is within the selected date range (inclusive)
      if ((orderDate.isAfter(startDate!.subtract(Duration(days: 1))) || orderDate.isAtSameMomentAs(startDate!)) &&
          (orderDate.isBefore(endDate!.add(Duration(days: 1))) || orderDate.isAtSameMomentAs(endDate!))) {
        tempFilteredData[orderDateString] = products;
      }
    });

    setState(() {
      filteredGroupedData = tempFilteredData; // Update filtered data with date range filter
    });
  }
}


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
      print(
          "RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD${response.body}");
      List<Map<String, dynamic>> stafflist = [];

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        print("RRRRRRRRRRRRRRRREEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDD$parsed");
        for (var productData in productsData) {
          String imageUrl = "${productData['image']}";
          stafflist.add({
            'id': productData['id'],
            'name': productData['name'],
          });
        }
        setState(() {
          sta = stafflist;
          print("sataffffffffffff$sta");
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }

void _filterDataByStaff(int staffId) {
  if (staffId != null) {
    Map<String, Map<String, Map<String, dynamic>>> tempFilteredData = {};
print("groupedData:$groupedData");
    groupedData.forEach((orderDate, products) {
      products.forEach((productName, productData) {
        if (productData['staff_id'] == staffId) { // Match staff ID
          tempFilteredData.putIfAbsent(orderDate, () => {});
          tempFilteredData[orderDate]![productName] = productData;
        }
      });
    });

    setState(() {
      filteredGroupedData = tempFilteredData; // Update filtered data
      print("filter:$filteredGroupedData");
    });
  }
}


Future<void> getSoldReport() async {
  try {
    final token = await getTokenFromPrefs();
    var response = await http.get(
      Uri.parse('$api/api/productstock/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print(response.body);

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      final List<dynamic> soldproducts = parsed['data'];

      // Initialize the groupedData structure
      Map<String, Map<String, Map<String, dynamic>>> tempGroupedData = {};
      for (var reportData in soldproducts) {
        final orderDate = reportData['order_date'];
        final staffId = reportData['manage_staff']; // Assuming the staff ID is part of the order data
        final items = reportData['items'];

        for (var item in items) {
          final productName = item['product_name'];
          final productStock = item['product_stock'] ?? 0;
          final quantity = item['quantity'] ?? 0;
          final itemTotalAmount = item['total_amount'] ?? 0.0;

          // Initialize nested structure
          tempGroupedData.putIfAbsent(orderDate, () => {});
          tempGroupedData[orderDate]!.putIfAbsent(productName, () => {
                'available_stock': productStock,
                'total_quantity': 0,
                'total_amount': 0.0,
                'staff_id': staffId, // Include staff ID in the product data
              });

          // Update product data
          final productData = tempGroupedData[orderDate]![productName]!;
          productData['available_stock'] = productStock; // Static value
          productData['total_quantity'] += quantity; // Aggregate quantity
          productData['total_amount'] += itemTotalAmount; // Aggregate total amount
        }
      }

      setState(() {
        groupedData = tempGroupedData;
        print("::::::::::::::::::$groupedData");
        filteredGroupedData = groupedData; // Initially show all data
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch sold product report data'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (error) {
    print("Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error fetching sold product report data'),
        duration: Duration(seconds: 2),
      ),
    );
  }
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
            d.navigateToSelectedPage(
                context, option); // Navigate to selected page
          },
        );
      }).toList(),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
       appBar: AppBar(
        title: const Text(
          "Sold Product Report",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
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
            onChanged: _filterProducts, // Call filter on change
          ),
        ),

       Padding(
  padding: const EdgeInsets.all(10),
  child: Container(
    height: 49,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blue),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        SizedBox(width: 20),
        Container(
          width: 276,
          child: InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 1),
            ),
            child: DropdownButton<int>(
              value: selectedstaffId,
              isExpanded: true,
              hint: Text( // Add hint text here
                "Select Staff",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              underline: Container(), // This removes the underline
              onChanged: (int? newValue) {
                setState(() {
                  selectedstaffId = newValue!;
                  print(selectedstaffId);
                });
                _filterDataByStaff(selectedstaffId!);
              },
              items: sta.map<DropdownMenuItem<int>>((staff) {
                return DropdownMenuItem<int>(
                  value: staff['id'],
                  child: Text(staff['name'], style: TextStyle(fontSize: 12)),
                );
              }).toList(),
              icon: Container(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_drop_down), // Dropdown arrow icon
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),

        // Use ListView for automatic scrolling
        filteredGroupedData.isNotEmpty
            ? Expanded(
                child: ListView(
                  children: filteredGroupedData.entries.map((dateEntry) {
                    final orderDate = dateEntry.key;
                    final products = dateEntry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: products.entries.map((productEntry) {
                        final productName = productEntry.key;
                        final productData = productEntry.value;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: $orderDate',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Divider(color: Colors.blue,),
                                Text(
                                  'Product: $productName',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Available Stock: ${productData['available_stock']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Item Sold: ${productData['total_quantity']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Net Sale: ₹${productData['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              )
            : Center(
                child: Text("No data available"),
              ),
      ],
    ),
  );
}


}
