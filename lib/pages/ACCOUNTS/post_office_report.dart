import 'dart:convert';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PostofficeReport extends StatefulWidget {
  const PostofficeReport({super.key});

  @override
  State<PostofficeReport> createState() => _PostofficeReportState();
}

class _PostofficeReportState extends State<PostofficeReport> {
  List<Map<String, dynamic>> orders = [];
  Map<String, Map<String, double>> parcelData = {};
  String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  DateTime? selectedDate; // For single date filter
  DateTime? startDate; // For date range filter
  DateTime? endDate; // For date range filter
  @override
  void initState() {
    super.initState();
    fetchorders();
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchorders() async {
    final token = await getTokenFromPrefs();
    try {
      final response = await http.get(
        Uri.parse('$api/api/orders/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        print("API Response: $parsed");

        List<Map<String, dynamic>> orderlist = [];
        parcelData.clear();

        for (var orderData in parsed) {
          List<Map<String, dynamic>> warehouseList = [];

          if (orderData['warehouse'] != null) {
            for (var warehouse in orderData['warehouse']) {
              String? parcelService = warehouse['parcel_service'];
              String? postofficeDate = warehouse['postoffice_date'];

              print("Checking warehouse ID ${warehouse['id']} - postoffice_date: $postofficeDate");

              if (parcelService != null &&
                  parcelService.isNotEmpty &&
                  postofficeDate != null &&
                  postofficeDate == todayDate) {
                double actualWeight =
                    double.tryParse(warehouse['actual_weight'].toString()) ?? 0.0;
                double parcelAmount =
                    double.tryParse(warehouse['parcel_amount'].toString()) ?? 0.0;

                if (!parcelData.containsKey(parcelService)) {
                  parcelData[parcelService] = {
                    'total_actual_weight': 0.0,
                    'total_parcel_amount': 0.0,
                  };
                }

                parcelData[parcelService]!['total_actual_weight'] =
                    (parcelData[parcelService]!['total_actual_weight'] ?? 0) +
                        actualWeight;
                parcelData[parcelService]!['total_parcel_amount'] =
                    (parcelData[parcelService]!['total_parcel_amount'] ?? 0) +
                        parcelAmount;


              }
            }
          }

        
        }

        Map<String, double> parcelAverages = {};
        parcelData.forEach((parcelService, data) {
          double totalActualWeight = data['total_actual_weight'] ?? 0.0;
          double totalParcelAmount = data['total_parcel_amount'] ?? 1.0;
          double average = totalActualWeight / totalParcelAmount;
          parcelAverages[parcelService] = average;
        });

        setState(() {
          orders = orderlist;
          print("Processed Orders: $orders");
          print("Parcel Averages: $parcelAverages");
        });
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
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
      fetchorders2();
    }
  }


Future<void> fetchorders2() async {
  final token = await getTokenFromPrefs();
  try {
    final response = await http.get(
      Uri.parse('$api/api/orders/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("API Response: ${response.body}");

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      print("API Response: $parsed");

      List<Map<String, dynamic>> orderlist = [];
      parcelData.clear();

      for (var orderData in parsed) {
        List<Map<String, dynamic>> warehouseList = [];

        if (orderData['warehouse'] != null) {
          for (var warehouse in orderData['warehouse']) {
            String parcelService = warehouse['parcel_service'] ?? ""; // Default to empty string if null
            String? postofficeDate = warehouse['postoffice_date'];
            String? shippedDateStr = warehouse['shipped_date'];
            DateTime? shippedDate;

            // Parse the shipped_date to DateTime
            if (shippedDateStr != null && shippedDateStr.isNotEmpty) {
              shippedDate = DateTime.parse(shippedDateStr);
            }

            print("Checking warehouse ID ${warehouse['id']} - shipped_date: $shippedDate");

            // Check if the shipped_date is within the selected date range
            if (shippedDate != null &&
                shippedDate.isAfter(startDate!) &&
                shippedDate.isBefore(endDate!)) {
              double actualWeight = double.tryParse(warehouse['actual_weight'].toString()) ?? 0.0;
              double parcelAmount = double.tryParse(warehouse['parcel_amount'].toString()) ?? 0.0;

              if (!parcelData.containsKey(parcelService)) {
                parcelData[parcelService] = {
                  'total_actual_weight': 0.0,
                  'total_parcel_amount': 0.0,
                };
              }

              parcelData[parcelService]!['total_actual_weight'] =
                  (parcelData[parcelService]!['total_actual_weight'] ?? 0) + actualWeight;
              parcelData[parcelService]!['total_parcel_amount'] =
                  (parcelData[parcelService]!['total_parcel_amount'] ?? 0) + parcelAmount;

           
            }
          }
        }

      }

      Map<String, double> parcelAverages = {};
    
      setState(() {

        parcelData.forEach((parcelService, data) {
        double totalActualWeight = data['total_actual_weight'] ?? 0.0;
        double totalParcelAmount = data['total_parcel_amount'] ?? 1.0;
        double average = totalActualWeight / totalParcelAmount;
        parcelAverages[parcelService] = average;
      });

        orders = orderlist;
        print("Processed Orders: $orders");
        print("Parcel Averages: $parcelAverages");
      });
    }
  } catch (e) {
    print("Error fetching orders: $e");
  }
}




  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Office Report",style: TextStyle(color: Colors.grey,fontSize: 14),),
            actions: [
         
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],

      ),
      body: parcelData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text(
                    "No data available for today",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: parcelData.length,
              itemBuilder: (context, index) {
                String parcelService = parcelData.keys.elementAt(index);
                double totalWeight = parcelData[parcelService]!['total_actual_weight'] ?? 0.0;
                double totalAmount = parcelData[parcelService]!['total_parcel_amount'] ?? 0.0;
                double average = totalAmount > 0 ? totalWeight / totalAmount : 0.0;

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [const Color.fromARGB(255, 58, 143, 183), const Color.fromARGB(255, 64, 170, 251)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_shipping, color: Colors.white, size: 28),
                            SizedBox(width: 10),
                            Text(
                              parcelService.toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.white70),
                        SizedBox(height: 10),
                        _buildInfoRow("Total Actual Weight", "$totalWeight kg"),
                        _buildInfoRow("Total Parcel Amount", "₹$totalAmount"),
                        _buildInfoRow("Average", average.toStringAsFixed(2)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
